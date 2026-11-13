#!/usr/bin/env bash
# Métadonnées et traitements propres au logiciel ; opérations communes dans le moteur.
# shellcheck disable=SC2034

software_apt_recipe_chatgpt() {
    local field="${1:-}"
    shift
    set -- chatgpt "$@"
    local software=chatgpt release perl_package version state="${2:-}"
    case "$field" in
        package)
            printf '%s\n' chatgpt
            ;;
        variable)
            printf '%s\n' SOFTWARE_APT_CHATGPT
            ;;
        install_options)
            printf '\n'
            ;;
        remove_action)
            printf '%s\n' remove
            ;;
        install_packages)
            software_apt_convergence_package "$software"
            ;;
        repository)
            printf '%s\n' cgpt
            ;;
        repository_variable)
            printf '%s\n' SYSTEM_APT_CGPT
            ;;
        repository_state_valid)
            [[ "$state" == 0 || "$state" == 1 ]]
            ;;
        repository_expected)
            printf '1\n'
            ;;
        remove_repository)
            printf '1\n'
            ;;
        detector)
            printf '%s\n' software_apt_chatgpt_real_state
            ;;
        artifact_url)
            printf '\n'
            ;;
        environment_hook)
            software_apt_convergence_variable "${1:-}" >/dev/null || return 1; printf '\n'
            ;;
        sensitive_install)
            software_apt_convergence_variable "${1:-}" >/dev/null || return 1; printf '0\n'
            ;;
        pre_install_hook)
            software_apt_convergence_variable "${1:-}" >/dev/null || return 1; printf '\n'
            ;;
        configuration_hook)
            printf '%s\n' software_apt_configure_chatgpt
            ;;
        cleanup_hook)
            printf '%s\n' software_apt_cleanup_chatgpt
            ;;
        configuration_check)
            printf '\n'
            ;;
        update_configuration_policy)
            software_apt_convergence_variable "${1:-}" >/dev/null || return 1; printf 'explicit\n'
            ;;
        remove_packages)
            software_apt_convergence_package "${1:-}"
            ;;
        pre_remove_hook)
            software_apt_convergence_variable "${1:-}" >/dev/null || return 1; printf '\n'
            ;;
        components) printf "\n" ;;
        variant) printf "%s\n" repository ;;
        *) return 2 ;;
    esac
}

software_apt_chatgpt_real_state() { software_apt_package_state chatgpt; }

software_apt_configure_chatgpt() { return 0; }

software_apt_cleanup_chatgpt() { software_apt_cleanup_repository chatgpt; }

config="DYNAMIC"
state="ENABLE"
scope="softwares"
variable_config_file="/root/diu/config/${scope}.env"
if [[ "${SOFTWARE_GLOBAL_DECLARATIONS_ONLY:-0}" != 1 ]]; then
    software_apt_declare_desired "$variable_config_file" "chatgpt" || return 1
fi

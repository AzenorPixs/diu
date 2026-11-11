#!/usr/bin/env bash
# Métadonnées et traitements propres au logiciel ; opérations communes dans le moteur.
# shellcheck disable=SC2034

software_apt_recipe_webmin() {
    local field="${1:-}"
    shift
    set -- webmin "$@"
    local software=webmin release perl_package version state="${2:-}"
    case "$field" in
        package)
            printf '%s\n' webmin
            ;;
        variable)
            printf '%s\n' SOFTWARE_APT_WEBMIN
            ;;
        install_options)
            printf '%s\n' --install-recommends
            ;;
        remove_action)
            printf '%s\n' purge
            ;;
        install_packages)
            software_apt_convergence_package "$software"
            ;;
        repository)
            printf '%s\n' webmin
            ;;
        repository_variable)
            printf '%s\n' SYSTEM_APT_WEBMIN
            ;;
        repository_state_valid)
            [[ "$state" == 0 || "$state" == 1 ]]
            ;;
        repository_expected)
            printf '1\n'
            ;;
        remove_repository)
            printf '0\n'
            ;;
        detector)
            printf '%s\n' software_apt_webmin_detect
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
            printf '\n'
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

software_apt_webmin_detect() { software_apt_package_state webmin; }

config="DYNAMIC"
state="ENABLE"
scope="softwares"
variable_config_file="/root/diu/config/${scope}.env"
if [[ "${SOFTWARE_GLOBAL_DECLARATIONS_ONLY:-0}" != 1 ]]; then
    software_apt_declare_desired "$variable_config_file" "webmin" || return 1
fi

#!/usr/bin/env bash
# Métadonnées et traitements propres au logiciel ; opérations communes dans le moteur.
# shellcheck disable=SC2034

software_apt_recipe_lemonldap() {
    local field="${1:-}"
    shift
    set -- lemonldap "$@"
    local software=lemonldap release perl_package version state="${2:-}"
    case "$field" in
        package)
            printf '%s\n' lemonldap-ng
            ;;
        variable)
            printf '%s\n' SOFTWARE_APT_LEMONLDAP
            ;;
        install_options)
            printf '\n'
            ;;
        remove_action)
            printf '%s\n' remove
            ;;
        install_packages)
            printf '%s\n' lemonldap-ng lemonldap-ng-doc liblasso-perl krb5-user
            ;;
        repository)
            printf '%s\n' lemonldap
            ;;
        repository_variable)
            printf '%s\n' SYSTEM_APT_LEMONLDAP
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
            printf '%s\n' software_apt_lemonldap_detect
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

software_apt_lemonldap_detect() { software_apt_package_state lemonldap-ng; }

config="DYNAMIC"
state="ENABLE"
scope="softwares"
variable_config_file="/root/diu/config/${scope}.env"
if [[ "${SOFTWARE_GLOBAL_DECLARATIONS_ONLY:-0}" != 1 ]]; then
    software_apt_declare_desired "$variable_config_file" "lemonldap" || return 1
fi

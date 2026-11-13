#!/usr/bin/env bash
# Métadonnées et traitements propres au logiciel ; opérations communes dans le moteur.
# shellcheck disable=SC2034

software_apt_recipe_syslog_client() {
    local field="${1:-}"
    shift
    set -- syslog-client "$@"
    local software=syslog-client release perl_package version state="${2:-}"
    case "$field" in
        package)
            printf '%s\n' rsyslog
            ;;
        variable)
            printf '%s\n' SOFTWARE_APT_SYSLOG_CLIENT
            ;;
        install_options)
            printf '\n'
            ;;
        remove_action)
            printf '%s\n' remove
            ;;
        install_packages)
            printf '%s\n' rsyslog ulogd2
            ;;
        repository)
            printf '\n'
            ;;
        repository_variable)
            printf '\n'
            ;;
        repository_state_valid)
            return 1
            ;;
        repository_expected)
            printf '\n'
            ;;
        remove_repository)
            printf '0\n'
            ;;
        detector)
            printf '%s\n' software_apt_syslog_client_detect
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
            printf '%s\n' software_apt_preflight_syslog_client
            ;;
        configuration_hook)
            printf '%s\n' software_apt_configure_syslog_client
            ;;
        cleanup_hook)
            printf '%s\n' software_apt_cleanup_syslog_client
            ;;
        configuration_check)
            printf '%s\n' software_apt_check_syslog_client_configuration
            ;;
        update_configuration_policy)
            software_apt_convergence_variable "${1:-}" >/dev/null || return 1; printf 'explicit\n'
            ;;
        remove_packages)
            software_apt_syslog_remove_packages "${1:-}"
            ;;
        pre_remove_hook)
            printf '%s\n' software_apt_disable_syslog_client
            ;;
        components) printf "\n" ;;
        variant) printf "%s\n" debian ;;
        *) return 2 ;;
    esac
}

software_apt_preflight_syslog_client() { software_apt_syslog_helper preflight client keep-package; }

software_apt_configure_syslog_client() { software_apt_syslog_helper configure client keep-package; }

software_apt_check_syslog_client_configuration() { software_apt_syslog_check_configuration client; }

software_apt_disable_syslog_client() { software_apt_disable_syslog_role client; }

software_apt_syslog_client_detect() { software_apt_syslog_role_state client "${1:-/}"; }

software_apt_cleanup_syslog_client() { software_apt_cleanup_repository syslog-client; }

config="DYNAMIC"
state="ENABLE"
scope="softwares"
variable_config_file="/root/diu/config/${scope}.env"
if [[ "${SOFTWARE_GLOBAL_DECLARATIONS_ONLY:-0}" != 1 ]]; then
    software_apt_declare_desired "$variable_config_file" "syslog-client" || return 1
fi

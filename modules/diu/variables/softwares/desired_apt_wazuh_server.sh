#!/usr/bin/env bash
# Métadonnées et traitements propres au logiciel ; opérations communes dans le moteur.
# shellcheck disable=SC2034

software_apt_recipe_wazuh_server() {
    local field="${1:-}"
    shift
    set -- wazuh-server "$@"
    local software=wazuh-server release perl_package version state="${2:-}"
    case "$field" in
        package)
            printf '%s\n' wazuh-manager
            ;;
        variable)
            printf '%s\n' SOFTWARE_APT_WAZUH_SERVER
            ;;
        install_options)
            printf '\n'
            ;;
        remove_action)
            printf '%s\n' remove
            ;;
        install_packages)
            printf '%s\n' debhelper tar curl libcap2-bin wazuh-indexer wazuh-manager filebeat wazuh-dashboard
            ;;
        repository)
            printf '%s\n' wazuh-4
            ;;
        repository_variable)
            printf '%s\n' SYSTEM_APT_WAZUH
            ;;
        repository_state_valid)
            [[ "$state" == 0 || "$state" == 4 ]]
            ;;
        repository_expected)
            printf '4\n'
            ;;
        remove_repository)
            printf '0\n'
            ;;
        detector)
            printf '%s\n' software_apt_wazuh_server_detect
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
            printf '%s\n' software_apt_configure_wazuh_server
            ;;
        cleanup_hook)
            printf '%s\n' software_apt_cleanup_wazuh_server
            ;;
        configuration_check)
            printf '%s\n' software_apt_check_wazuh_server_configuration
            ;;
        update_configuration_policy)
            printf 'always\n'
            ;;
        remove_packages)
            software_apt_wazuh_server_installed_packages
            ;;
        pre_remove_hook)
            software_apt_convergence_variable "${1:-}" >/dev/null || return 1; printf '\n'
            ;;
        components) printf "\n" ;;
        variant) printf "%s\n" repository ;;
        *) return 2 ;;
    esac
}

software_apt_wazuh_server_installed_packages() {
    local rows name state matched=0
    if ! rows="$(dpkg-query -W -f='${binary:Package}\t${db:Status-Status}\n')"; then
        printf '%s\n' 'État des paquets Debian indisponible.' >&2
        return 2
    fi
    while IFS=$'\t' read -r name state; do
        [[ "$name" =~ ^wazuh-(indexer|manager|dashboard)(:[a-z0-9][a-z0-9-]*)?$ ]] || continue
        case "$state" in
            installed) printf '%s\n' "$name"; matched=1 ;;
            not-installed|config-files) ;;
            *) printf '%s\n' 'État Wazuh serveur incomplet.' >&2; return 2 ;;
        esac
    done <<< "$rows"
    [[ "$matched" == 1 ]]
}

software_apt_wazuh_server_detect() {
    local packages status
    if packages="$(software_apt_wazuh_server_installed_packages)"; then
        [[ -n "$packages" ]] || return 2
        printf '1\n'
    else
        status=$?
        if [[ "$status" == 1 ]]; then printf '0\n'; else return "$status"; fi
    fi
}

software_apt_check_wazuh_server_configuration() {
    local package actual
    for package in wazuh-indexer wazuh-manager filebeat wazuh-dashboard; do
        actual="$(software_apt_package_state "$package")" || return 2
        [[ "$actual" == 1 ]] || return 1
    done
}

software_apt_configure_wazuh_server() { return 0; }

software_apt_cleanup_wazuh_server() { software_apt_cleanup_repository wazuh-server; }

config="DYNAMIC"
state="ENABLE"
scope="softwares"
variable_config_file="/root/diu/config/${scope}.env"
if [[ "${SOFTWARE_GLOBAL_DECLARATIONS_ONLY:-0}" != 1 ]]; then
    software_apt_declare_desired "$variable_config_file" "wazuh-server" || return 1
fi

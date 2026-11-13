#!/usr/bin/env bash
# Métadonnées et traitements propres au logiciel ; opérations communes dans le moteur.
# shellcheck disable=SC2034

software_apt_recipe_wazuh_agent() {
    local field="${1:-}"
    shift
    set -- wazuh-agent "$@"
    local software=wazuh-agent release perl_package version state="${2:-}"
    case "$field" in
        package)
            printf '%s\n' wazuh-agent
            ;;
        variable)
            printf '%s\n' SOFTWARE_APT_WAZUH_AGENT
            ;;
        install_options)
            printf '\n'
            ;;
        remove_action)
            printf '%s\n' purge
            ;;
        install_packages)
            software_apt_convergence_package "$software"
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
            printf '%s\n' software_apt_wazuh_agent_detect
            ;;
        artifact_url)
            version="${WAZUH_CLIENT_VERSION:-}"
                        [[ "$version" =~ ^[0-9][A-Za-z0-9.+~-]*$ ]] || { printf '%s\n' 'Version Wazuh agent invalide.' >&2; return 1; }
                        printf 'https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_%s_amd64.deb\n' "$version"
            ;;
        environment_hook)
            printf '%s\n' software_apt_prepare_wazuh_agent_environment
            ;;
        sensitive_install)
            printf '1\n'
            ;;
        pre_install_hook)
            software_apt_convergence_variable "${1:-}" >/dev/null || return 1; printf '\n'
            ;;
        configuration_hook)
            printf '%s\n' software_apt_configure_wazuh_agent
            ;;
        cleanup_hook)
            printf '%s\n' software_apt_cleanup_wazuh_agent
            ;;
        configuration_check)
            printf '%s\n' software_apt_check_wazuh_agent_configuration
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
        artifact_version) dpkg-deb -f "${2:-}" Version ;;
        components) printf "\n" ;;
        variant) printf "%s\n" direct ;;
        *) return 2 ;;
    esac
}

software_apt_wazuh_agent_detect() { software_apt_package_state wazuh-agent; }

software_apt_prepare_wazuh_agent_environment() {
    local manager="${SOFTWARE_APT_WAZUH_AGENT_MANAGER:-}"
    local password="${SOFTWARE_APT_WAZUH_AGENT_REGISTRATION_PASSWORD:-}"
    local group="${SOFTWARE_APT_WAZUH_AGENT_GROUP:-Linux}" protocol="${SOFTWARE_APT_WAZUH_AGENT_PROTOCOL:-UDP}"
    if [[ ! "$manager" =~ ^[A-Za-z0-9._:-]+$ || -z "$password" || "$password" == *$'\n'* || "$password" == *$'\r'* ||
          ! "$group" =~ ^[A-Za-z0-9._-]+$ || ( "$protocol" != UDP && "$protocol" != TCP ) ]]; then
        printf '%s\n' "Paramètres sécurisés d'enregistrement Wazuh absents ou invalides." >&2
        return 1
    fi
    export WAZUH_MANAGER="$manager" WAZUH_REGISTRATION_PASSWORD="$password"
    export WAZUH_AGENT_GROUP="$group" WAZUH_PROTOCOL="$protocol"
}

software_apt_configure_wazuh_agent() {
    systemctl enable wazuh-agent.service || return 1
    systemctl start wazuh-agent.service || return 1
}

software_apt_check_wazuh_agent_configuration() {
    local load_state status
    if ! load_state="$(systemctl show --property=LoadState --value wazuh-agent.service 2>/dev/null)"; then return 2; fi
    [[ "$load_state" == loaded ]] || return 1
    if systemctl is-enabled --quiet wazuh-agent.service; then :; else
        status=$?; [[ "$status" == 1 ]] && return 1; return 2
    fi
    if systemctl is-active --quiet wazuh-agent.service; then return 0; else
        status=$?; [[ "$status" == 3 ]] && return 1; return 2
    fi
}

software_apt_cleanup_wazuh_agent() { software_apt_cleanup_repository wazuh-agent; }

config="DYNAMIC"
state="ENABLE"
scope="softwares"
variable_config_file="/root/diu/config/${scope}.env"
if [[ "${SOFTWARE_GLOBAL_DECLARATIONS_ONLY:-0}" != 1 ]]; then
    software_apt_declare_desired "$variable_config_file" "wazuh-agent" || return 1
fi

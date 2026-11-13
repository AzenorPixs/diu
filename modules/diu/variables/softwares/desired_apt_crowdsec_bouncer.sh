#!/usr/bin/env bash
# Métadonnées et traitements propres au logiciel ; opérations communes dans le moteur.
# shellcheck disable=SC2034

software_apt_recipe_crowdsec_bouncer() {
    local field="${1:-}"
    shift
    set -- crowdsec-bouncer "$@"
    local software=crowdsec-bouncer release perl_package version state="${2:-}"
    case "$field" in
        package)
            printf '%s\n' crowdsec-firewall-bouncer-iptables
            ;;
        variable)
            printf '%s\n' SOFTWARE_APT_CROWDSEC_BOUNCER
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
            printf '%s\n' crowdsec
            ;;
        repository_variable)
            printf '%s\n' SOFTWARE_APT_CROWDSEC
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
            printf '%s\n' software_apt_crowdsec_bouncer_role_detect
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
            printf '%s\n' software_apt_preflight_crowdsec
            ;;
        configuration_hook)
            printf '%s\n' software_apt_configure_crowdsec_bouncer
            ;;
        cleanup_hook)
            printf '%s\n' software_apt_cleanup_crowdsec_bouncer
            ;;
        configuration_check)
            printf '%s\n' software_apt_check_crowdsec_bouncer_configuration
            ;;
        update_configuration_policy)
            printf 'always\n'
            ;;
        remove_packages)
            software_apt_crowdsec_bouncer_remove_packages
            ;;
        pre_remove_hook)
            printf '%s\n' software_apt_disable_crowdsec_bouncer
            ;;
        components) printf "\n" ;;
        variant) printf "%s\n" repository ;;
        *) return 2 ;;
    esac
}

software_apt_crowdsec_bouncer_detect() { software_apt_package_state crowdsec-firewall-bouncer-iptables; }

software_apt_crowdsec_bouncer_mode() {
    local needed
    needed="$(software_shared_resource_needed "${software_management_config:-}" SOFTWARE_APT_CROWDSEC_AGENT software_apt_crowdsec_agent_detect)" || return 1
    if [[ "$needed" == 1 ]]; then printf 'local\n'; else printf 'remote\n'; fi
}

software_apt_configure_crowdsec_bouncer() {
    local mode="${1:-}"
    [[ -n "$mode" ]] || mode="$(software_apt_crowdsec_bouncer_mode)" || return 1
    [[ "$mode" == local || "$mode" == remote ]] || return 2
    software_apt_crowdsec_helper bouncer "$mode" || return 1
    systemctl disable crowdsec-firewall-bouncer.service || return 1
    service crowdsec-firewall-bouncer restart
}

software_apt_check_crowdsec_bouncer_configuration() {
    local mode status
    mode="$(software_apt_crowdsec_bouncer_mode)" || return 2
    if software_apt_crowdsec_helper check-bouncer "$mode"; then :; else
        status=$?; [[ "$status" == 1 ]] && return 1; return 2
    fi
    software_apt_crowdsec_service_check crowdsec-firewall-bouncer.service 0
}

software_apt_disable_crowdsec_bouncer() {
    local mode
    mode="$(software_apt_crowdsec_bouncer_mode)" || return 1
    if [[ "$mode" == local ]]; then
        software_apt_crowdsec_helper disable-bouncer local || return 1
        service crowdsec-firewall-bouncer restart
    else
        software_apt_crowdsec_helper disable-bouncer absent
    fi
}

software_apt_crowdsec_bouncer_remove_packages() {
    local needed
    needed="$(software_shared_resource_needed "${software_management_config:-}" SOFTWARE_APT_CROWDSEC_AGENT software_apt_crowdsec_agent_detect)" || return 1
    if [[ "$needed" == 0 ]]; then printf '%s\n' crowdsec-firewall-bouncer-iptables; fi
}

software_apt_crowdsec_bouncer_role_detect() {
    local prefix="${1:-/}" package_state agent_state marker configuration line url='' count=0
    package_state="$(software_apt_package_state crowdsec-firewall-bouncer-iptables)" || return 2
    [[ "$package_state" == 1 ]] || { [[ "$package_state" == 0 ]] && { printf '0\n'; return 0; }; return 2; }
    agent_state="$(software_apt_crowdsec_agent_detect)" || return 2
    [[ "$agent_state" == 0 || "$agent_state" == 1 ]] || return 2
    marker="${prefix%/}/etc/crowdsec/bouncers/.diu-standalone-enabled"
    configuration="${prefix%/}/etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml"
    if [[ -L "$marker" || -L "$configuration" ]]; then return 2; fi
    if [[ -e "$marker" ]]; then
        [[ -f "$marker" && -r "$marker" && "$(<"$marker")" == 1 ]] || return 2
        printf '1\n'
        return 0
    fi
    if [[ "$agent_state" == 0 ]]; then printf '1\n'; return 0; fi
    [[ -f "$configuration" && -r "$configuration" ]] || return 2
    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" =~ ^[[:space:]]*api_url:[[:space:]]*([^[:space:]#]+)[[:space:]]*(#.*)?$ ]]; then
            url="${BASH_REMATCH[1]}"
            (( count += 1 ))
        elif [[ "$line" =~ ^[[:space:]]*api_url: ]]; then
            return 2
        fi
    done < "$configuration"
    [[ "$count" == 1 ]] || return 2
    if [[ "$url" == \"*\" || "$url" == \'*\' ]]; then
        url="${url:1:${#url}-2}"
    fi
    if [[ "$url" == http://127.0.0.1:8080/ || "$url" == http://localhost:8080/ ]]; then
        printf '0\n'
    else
        printf '1\n'
    fi
}

software_apt_cleanup_crowdsec_bouncer() { software_apt_cleanup_repository crowdsec-bouncer; }

config="DYNAMIC"
state="ENABLE"
scope="softwares"
variable_config_file="/root/diu/config/${scope}.env"
if [[ "${SOFTWARE_GLOBAL_DECLARATIONS_ONLY:-0}" != 1 ]]; then
    software_apt_declare_desired "$variable_config_file" "crowdsec-bouncer" || return 1
fi

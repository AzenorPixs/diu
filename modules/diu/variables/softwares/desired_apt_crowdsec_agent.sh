#!/usr/bin/env bash
# Métadonnées et traitements propres au logiciel ; opérations communes dans le moteur.
# shellcheck disable=SC2034

software_apt_recipe_crowdsec_agent() {
    local field="${1:-}"
    shift
    set -- crowdsec-agent "$@"
    local software=crowdsec-agent release perl_package version state="${2:-}"
    case "$field" in
        package)
            printf '%s\n' crowdsec
            ;;
        variable)
            printf '%s\n' SOFTWARE_APT_CROWDSEC_AGENT
            ;;
        install_options)
            printf '\n'
            ;;
        remove_action)
            printf '%s\n' remove
            ;;
        install_packages)
            printf '%s\n' crowdsec crowdsec-firewall-bouncer-iptables
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
            printf '%s\n' software_apt_crowdsec_agent_detect
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
            printf '%s\n' software_apt_configure_crowdsec_agent
            ;;
        configuration_check)
            printf '%s\n' software_apt_check_crowdsec_agent_configuration
            ;;
        update_configuration_policy)
            software_apt_convergence_variable "${1:-}" >/dev/null || return 1; printf 'explicit\n'
            ;;
        remove_packages)
            software_apt_convergence_package "${1:-}"
            ;;
        pre_remove_hook)
            printf '%s\n' software_apt_preflight_crowdsec_agent_remove
            ;;
        components) printf "\n" ;;
        variant) printf "%s\n" repository ;;
        *) return 2 ;;
    esac
}

software_apt_crowdsec_agent_detect() { software_apt_package_state crowdsec; }

software_apt_configure_crowdsec_agent() {
    software_apt_crowdsec_helper agent local || return 1
    systemctl daemon-reload || return 1
    systemctl enable crowdsec.service || return 1
    systemctl restart crowdsec.service || return 1
    cscli hub update || return 1
    cscli collections install crowdsecurity/linux || return 1
    cscli collections install crowdsecurity/sshd || return 1
    cscli collections install crowdsecurity/iptables || return 1
    systemctl disable crowdsec-firewall-bouncer.service || return 1
    service crowdsec-firewall-bouncer restart
}

software_apt_check_crowdsec_agent_configuration() {
    local status
    if software_apt_crowdsec_helper check-agent local; then :; else
        status=$?; [[ "$status" == 1 ]] && return 1; return 2
    fi
    software_apt_crowdsec_service_check crowdsec.service 1 || return $?
    software_apt_crowdsec_service_check crowdsec-firewall-bouncer.service 0
}

software_apt_preflight_crowdsec_agent_remove() {
    local desired
    desired="$(software_desired_read_verified "${software_management_config:-}" SOFTWARE_APT_CROWDSEC_BOUNCER)" || return 1
    if [[ "$desired" == 1 ]]; then
        software_apt_configure_crowdsec_bouncer remote || return 1
    fi
}

config="DYNAMIC"
state="ENABLE"
scope="softwares"
variable_config_file="/root/diu/config/${scope}.env"
if [[ "${SOFTWARE_GLOBAL_DECLARATIONS_ONLY:-0}" != 1 ]]; then
    software_apt_declare_desired "$variable_config_file" "crowdsec-agent" || return 1
fi

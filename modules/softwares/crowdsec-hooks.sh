#!/usr/bin/env bash

software_apt_crowdsec_helper() {
    local helper
    helper="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/crowdsec_configuration.py" || return 1
    python3 "$helper" "$@"
}

software_apt_preflight_crowdsec() {
    software_apt_crowdsec_helper preflight local
}

software_apt_crowdsec_service_check() {
    local service="${1:-}" require_enabled="${2:-0}" load_state status
    [[ -n "$service" ]] || return 2
    if ! load_state="$(systemctl show --property=LoadState --value "$service" 2>/dev/null)"; then return 2; fi
    [[ "$load_state" == loaded ]] || return 1
    if [[ "$require_enabled" == 1 ]]; then
        if systemctl is-enabled --quiet "$service"; then :; else
            status=$?; [[ "$status" == 1 ]] && return 1; return 2
        fi
    fi
    if systemctl is-active --quiet "$service"; then return 0; else
        status=$?; [[ "$status" == 3 ]] && return 1; return 2
    fi
}

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

software_apt_preflight_crowdsec_agent_remove() {
    local desired
    desired="$(software_desired_read_verified "${software_management_config:-}" SOFTWARE_APT_CROWDSEC_BOUNCER)" || return 1
    if [[ "$desired" == 1 ]]; then
        software_apt_configure_crowdsec_bouncer remote || return 1
    fi
}

software_apt_crowdsec_bouncer_remove_packages() {
    local needed
    needed="$(software_shared_resource_needed "${software_management_config:-}" SOFTWARE_APT_CROWDSEC_AGENT software_apt_crowdsec_agent_detect)" || return 1
    if [[ "$needed" == 0 ]]; then printf '%s\n' crowdsec-firewall-bouncer-iptables; fi
}

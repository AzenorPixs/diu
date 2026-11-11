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









# Les détecteurs et hooks propres aux logiciels appartiennent aux déclarations GLOBAL.
# shellcheck disable=SC1091 source=modules/softwares/apt-recipes.sh
. "$(dirname -- "${BASH_SOURCE[0]}")/apt-recipes.sh"
software_apt_load_recipes || return 1

#!/usr/bin/env bash

# shellcheck disable=SC1091 source=modules/system/apt-source-state.sh
. "$(dirname -- "${BASH_SOURCE[0]}")/../system/apt-source-state.sh"

software_crowdsec_repository_detect() {
    system_apt_source_state SOFTWARE_APT_CROWDSEC
}

software_declare_crowdsec_repository() {
    local config_file="${1:-}" value
    [[ -n "$config_file" ]] || return 2
    if [[ -v SOFTWARE_APT_CROWDSEC ]]; then
        value="$SOFTWARE_APT_CROWDSEC"
        [[ "$value" == 0 || "$value" == 1 ]] || return 1
    elif ! value="$(software_crowdsec_repository_detect)"; then
        printf '%s\n' 'Initialisation du dépôt CrowdSec différée.' >&2
        return 0
    fi
    software_write_desired_state "$config_file" SOFTWARE_APT_CROWDSEC "$value" initialize || return $?
    SOFTWARE_APT_CROWDSEC="$value"
    export SOFTWARE_APT_CROWDSEC
}

software_declare_crowdsec_secret() {
    local config_file="${1:-}"
    [[ "$-" != *x* ]] || { printf '%s\n' 'Initialisation sensible refusée avec traçage shell actif.' >&2; return 1; }
    [[ -n "$config_file" ]] || return 2
    if [[ ! -v SOFTWARE_APT_CROWDSEC_BOUNCER_API_KEY ]]; then
        SOFTWARE_APT_CROWDSEC_BOUNCER_API_KEY=''
    fi
    software_write_crowdsec_secret_from_environment "$config_file" SOFTWARE_APT_CROWDSEC_BOUNCER_API_KEY || return $?
    export SOFTWARE_APT_CROWDSEC_BOUNCER_API_KEY
}

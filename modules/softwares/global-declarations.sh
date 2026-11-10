#!/usr/bin/env bash

software_crowdsec_repository_detect() {
    local path status
    if [[ "${SOFTWARE_APT_CROWDSEC_AGENT:-0}" == 1 || "${SOFTWARE_APT_CROWDSEC_BOUNCER:-0}" == 1 ]]; then
        printf '1\n'
        return 0
    fi
    for path in /etc/apt/sources.list /etc/apt/sources.list.d; do
        [[ -e "$path" ]] || continue
        if grep -RqsE 'crowdsec|packagecloud\.io/crowdsec' "$path"; then
            printf '1\n'
            return 0
        else
            status=$?
            [[ "$status" == 1 ]] || return 1
        fi
    done
    printf '0\n'
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

#!/usr/bin/env bash

# Le bouncer peut être une dépendance de l'agent ou un rôle autonome.
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

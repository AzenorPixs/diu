#!/usr/bin/env bash

software_apt_recipe_names() {
    printf '%s\n' apache2 chatgpt crowdsec-agent crowdsec-bouncer fastfetch jsvc lemonldap mongodb omada openjdk openvswitch postfix postgresql qemu-guest-agent ssh-server syncthing syslog-client syslog-server wazuh-agent wazuh-server webmin zoom zsh
}

software_apt_recipe() {
    local wanted="${1:-}" field="${2:-}" name
    [[ $# -ge 2 ]] || return 2
    shift 2
    while IFS= read -r name; do
        if [[ "$name" == "$wanted" ]]; then
            "software_apt_recipe_${name//-/_}" "$field" "$@"
            return $?
        fi
    done < <(software_apt_recipe_names)
    printf 'Logiciel APT non déclaré : %s\n' "$wanted" >&2
    return 1
}

software_apt_load_recipes() {
    local directory name file
    # Contexte consommé par les déclarations sourcées, sans initialisation.
    # shellcheck disable=SC2034
    local SOFTWARE_GLOBAL_DECLARATIONS_ONLY=1 config state scope default_value variable_config_file
    directory="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../diu/variables/softwares" && pwd)" || return 1
    while IFS= read -r name; do
        file="$directory/desired_apt_${name//-/_}.sh"
        # shellcheck disable=SC1090
        source "$file" || return 1
    done < <(software_apt_recipe_names)
}

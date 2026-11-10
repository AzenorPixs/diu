#!/usr/bin/env bash

# Une valeur chargée doit toujours correspondre à sa configuration persistée.
software_desired_read_verified() {
    local config_file="${1:-}" variable="${2:-}" desired
    if [[ -z "$config_file" || ! "$variable" =~ ^SOFTWARE_(APT|GITHUB|FLATPAK)_[A-Z0-9_]+$ ]]; then return 2; fi
    [[ -v "$variable" ]] || { printf '%s\n' 'État désiré du rôle partagé absent.' >&2; return 1; }
    desired="${!variable}"
    [[ "$desired" == 0 || "$desired" == 1 ]] || return 1
    software_write_desired_state "$config_file" "$variable" "$desired" verify || return $?
    printf '%s\n' "$desired"
}

# Une ressource reste nécessaire si l'autre rôle la désire ou l'utilise encore.
software_shared_resource_needed() {
    local config_file="${1:-}" variable="${2:-}" detector="${3:-}" desired actual
    if [[ ! "$detector" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] || ! declare -F "$detector" >/dev/null; then return 2; fi
    desired="$(software_desired_read_verified "$config_file" "$variable")" || return $?
    if ! actual="$("$detector")" || [[ "$actual" != 0 && "$actual" != 1 ]]; then
        printf '%s\n' 'État réel du rôle partagé inconnu.' >&2
        return 1
    fi
    if [[ "$desired" == 1 || "$actual" == 1 ]]; then printf '1\n'; else printf '0\n'; fi
}

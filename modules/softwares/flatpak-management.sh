#!/usr/bin/env bash

# Le chemin de configuration est fourni par le répartiteur, jamais par la CLI.
software_flatpak_manage_one() {
    local config_file="${1:-}" action="${2:-}" software="${3:-}"
    local variable detector
    variable="$(software_flatpak_variable_name "$software")" || return $?
    software_flatpak_register_detector "$software" || return $?
    detector="$(software_flatpak_detector_name "$software")" || return $?
    software_manage_one "$config_file" "$action" "$software" "$variable" "$detector" software_flatpak_converge
}

software_flatpak_manage_all() {
    local config_file="${1:-}" variable software result=0 count=0
    [[ -n "$config_file" ]] || return 2
    software_flatpak_inventory_initialize "$config_file" || return $?
    while IFS= read -r variable; do
        [[ -n "$variable" ]] || continue
        (( count += 1 ))
        if ! software="$(software_flatpak_identifier_from_variable "$variable")"; then
            printf '%s\n' 'Variable Flatpak non reconnue ; convergence ignorée.' >&2
            result=1
            continue
        fi
        if ! software_flatpak_manage_one "$config_file" update "$software"; then
            result=1
        fi
    done < <(compgen -A variable SOFTWARE_FLATPAK_X)
    if (( count == 0 )); then
        printf '%s\n' 'Aucune application Flatpak gérée.'
    fi
    return "$result"
}

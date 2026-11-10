#!/usr/bin/env bash

software_github_declare_desired() {
    local config_file="${1:-}" software="${2:-}" variable
    variable="$(software_github_convergence_metadata "$software" variable)" || return $?
    software_declare_one "$config_file" "$software" "$variable" software_github_convergence_detect
}

software_github_manage_one() {
    local config_file="${1:-}" action="${2:-}" software="${3:-}" variable
    variable="$(software_github_convergence_metadata "$software" variable)" || return $?
    software_manage_one "$config_file" "$action" "$software" "$variable" software_github_convergence_detect software_github_converge
}

software_github_manage_all() {
    local config_file="${1:-}" software result=0
    [[ -n "$config_file" ]] || return 2
    while IFS= read -r software; do
        [[ -n "$software" ]] || continue
        if ! software_github_manage_one "$config_file" update "$software"; then
            result=1
        fi
    done < <(software_github_convergence_names)
    return "$result"
}

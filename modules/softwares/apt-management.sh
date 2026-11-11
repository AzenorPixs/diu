#!/usr/bin/env bash

software_apt_declare_desired() {
    local config_file="${1:-}" software="${2:-}" variable
    variable="$(software_apt_convergence_variable "$software")" || return $?
    software_declare_one "$config_file" "$software" "$variable" software_apt_convergence_detect
}

software_apt_manage_one() {
    local config_file="${1:-}" action="${2:-}" software="${3:-}" variable
    # Les gardes de ressources partagées lisent ce contexte par portée dynamique.
    # shellcheck disable=SC2034
    local software_management_config="$config_file"
    variable="$(software_apt_convergence_variable "$software")" || return $?
    software_manage_one "$config_file" "$action" "$software" "$variable" software_apt_convergence_detect software_apt_converge || return $?
    # Une demande explicite prépare aussi les sources d'un logiciel déjà présent.
    if [[ "$action" == install ]]; then
        software_apt_prepare_sources "$software" || return $?
    fi
    if [[ "$action" == remove ]]; then
        software_apt_explicit_remove_cleanup "$software" || return $?
    fi
}

software_apt_explicit_remove_cleanup() {
    local software="${1:-}" cleanup repository variable state
    cleanup="$(software_apt_convergence_remove_repository "$software")" || return 1
    [[ "$cleanup" == 1 ]] || return 0
    repository="$(software_apt_convergence_repository "$software")" || return 1
    variable="$(software_apt_convergence_repository_variable "$software")" || return 1
    [[ -n "$repository" && -n "$variable" ]] || return 1
    if [[ -v "$variable" ]]; then state="${!variable}"; else state=0; fi
    software_apt_convergence_repository_state_valid "$software" "$state" || return 1
    [[ "$state" == 1 ]] || return 0
    declare -F system_apt_remove_repository >/dev/null || return 1
    system_apt_remove_repository "$repository" || return 1
    apt -y update
}

software_apt_manage_all() {
    local config_file="${1:-}" software result=0
    local -A failed=()
    [[ -n "$config_file" ]] || return 2
    while IFS= read -r software; do
        [[ -n "$software" ]] || continue
        if ! software_apt_initialize_one "$config_file" "$software"; then
            failed["$software"]=1
            result=1
        fi
    done < <(software_apt_convergence_names)
    while IFS= read -r software; do
        [[ -n "$software" ]] || continue
        [[ "${failed[$software]:-0}" == 0 ]] || continue
        if ! software_apt_manage_one "$config_file" update "$software"; then
            result=1
        fi
    done < <(software_apt_convergence_names)
    return "$result"
}

software_apt_initialize_one() {
    local config_file="${1:-}" software="${2:-}" variable
    variable="$(software_apt_convergence_variable "$software")" || return $?
    software_initialize_one "$config_file" "$software" "$variable" software_apt_convergence_detect
}

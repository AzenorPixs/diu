#!/usr/bin/env bash

# Les recettes sont enregistrées explicitement par le module qui les fournit.
software_github_recipe() {
    case "${1,,}:${2,,}" in
        *) return 1 ;;
    esac
}

software_github_version_is_newer() {
    local local_version="$1" remote_version="$2"
    [[ -n "$local_version" && -n "$remote_version" && "$local_version" != "$remote_version" ]] || return 1
    if [[ "$local_version" =~ ^v?[0-9]+([.][0-9]+)*$ && "$remote_version" =~ ^v?[0-9]+([.][0-9]+)*$ ]]; then
        [[ "$(printf '%s\n%s\n' "${local_version#v}" "${remote_version#v}" | sort -V | tail -n 1)" == "${remote_version#v}" ]]
    else
        return 0
    fi
}

software_github_latest_release_tag() {
    local owner="${1:-}" repository="${2:-}" response
    [[ "$owner" =~ ^[A-Za-z0-9_.-]+$ && "$repository" =~ ^[A-Za-z0-9_.-]+$ ]] || return 2
    command -v curl >/dev/null 2>&1 || { print_error "curl est requis pour interroger GitHub."; return 1; }
    response="$(curl --fail --silent --show-error --location \
        --header 'Accept: application/vnd.github+json' \
        "https://api.github.com/repos/${owner}/${repository}/releases/latest")" || return 1
    printf '%s\n' "$response" | sed -n 's/^  "tag_name": "\([^"]*\)",$/\1/p' | head -n 1
}

software_github_action() {
    local action="${1:-}" software="${2:-}" recipe=""
    [[ "$action" == install || "$action" == remove || "$action" == update ]] || { print_error "Action GitHub invalide : $action"; return 2; }
    [[ "$software" =~ ^[a-z0-9][a-z0-9+.-]*$ ]] || { print_error "Identifiant logiciel invalide : $software"; return 2; }
    recipe="$(software_github_recipe "$software" "$action")" || { print_error "Logiciel GitHub non pris en charge : $software"; return 1; }
    "$recipe" "$software"
}

software_github_known_software() { return 0; }

software_github_update_all() {
    local software result=0
    while IFS= read -r software; do
        [[ -n "$software" ]] || continue
        if software_github_action update "$software"; then print_success "softwares/github/$software : terminé."; else print_error "softwares/github/$software : échec."; result=1; fi
    done < <(software_github_known_software)
    return "$result"
}

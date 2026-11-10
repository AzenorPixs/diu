#!/usr/bin/env bash

# Mise à jour de version appelée par le système, sans modifier l'état désiré.
software_github_update_version() {
    local software="${1:-}" config_file="${2:-}" variable desired actual binary command_name owner repository prefix
    local metadata tag remote_version local_version
    variable="$(software_github_convergence_metadata "$software" variable)" || return 1
    [[ -n "$config_file" ]] || return 2
    [[ -v "$variable" ]] || return 0
    desired="${!variable}"
    if [[ "$desired" != 0 && "$desired" != 1 ]]; then
        printf '%s\n' 'État désiré GitHub invalide.' >&2
        return 1
    fi
    software_write_desired_state "$config_file" "$variable" "$desired" verify || return $?
    [[ "$desired" == 1 ]] || return 0
    actual="$(software_github_convergence_detect "$software")" || return 1
    [[ "$actual" == 1 ]] || { [[ "$actual" == 0 ]] && return 0; return 1; }
    binary="$(software_github_convergence_metadata "$software" binary)" || return 1
    command_name="$(software_github_convergence_metadata "$software" command)" || return 1
    if [[ ! -x "$binary" ]]; then
        binary="$(command -v "$command_name")" || return 1
    fi
    local_version="$("$binary" --version 2>/dev/null | sed -n 's/.* \([0-9][0-9A-Za-z.+-]*\)$/\1/p' | head -n 1)"
    owner="$(software_github_convergence_metadata "$software" owner)" || return 1
    repository="$(software_github_convergence_metadata "$software" repository)" || return 1
    prefix="$(software_github_convergence_metadata "$software" tag-prefix)" || return 1
    metadata="$(curl --fail --silent --show-error --location --header 'Accept: application/vnd.github+json' "https://api.github.com/repos/$owner/$repository/releases/latest")" || return 1
    tag="$(printf '%s\n' "$metadata" | sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)"
    if [[ "$tag" != "$prefix"[0-9]* || ! "$tag" =~ ^[A-Za-z0-9.+_-]+$ || -z "$local_version" ]]; then
        printf '%s\n' 'Versions GitHub non vérifiables.' >&2
        return 1
    fi
    remote_version="${tag#"$prefix"}"
    if ! software_github_version_is_newer "$local_version" "$remote_version"; then
        printf '%s : version déjà à jour (%s).\n' "$software" "$local_version"
        return 0
    fi
    software_github_install "$software" upgrade
}

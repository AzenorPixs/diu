#!/usr/bin/env bash

system_flatpak_update_applications() {
    local applications
    if ! command -v flatpak >/dev/null 2>&1; then
        printf '%s\n' 'Client Flatpak indisponible.' >&2
        return 1
    fi
    if ! applications="$(flatpak list --system --app --columns=application)"; then
        printf '%s\n' 'Inventaire Flatpak indisponible.' >&2
        return 1
    fi
    if [[ -z "$applications" ]]; then
        printf '%s\n' 'Aucune application Flatpak système à mettre à jour.'
        return 0
    fi
    if ! flatpak update --system --noninteractive; then
        printf '%s\n' 'Mise à jour Flatpak échouée.' >&2
        return 1
    fi
    printf '%s\n' 'Applications Flatpak système mises à jour.'
}

system_github_update_applications() {
    local config_file="${1:-}" software result=0
    [[ -n "$config_file" ]] || return 2
    while IFS= read -r software; do
        [[ -n "$software" ]] || continue
        if ! software_github_update_version "$software" "$config_file"; then
            printf 'Mise à jour GitHub échouée : %s.\n' "$software" >&2
            result=1
        fi
    done < <(software_github_convergence_names)
    return "$result"
}

system_apt_update_external_one() (
    local config_file="${1:-}" software="${2:-}" variable desired actual package url
    local temporary='' artifact installed_version available_version status
    [[ -n "$config_file" ]] || return 2
    variable="$(software_apt_convergence_variable "$software")" || return 1
    [[ -v "$variable" ]] || return 0
    desired="${!variable}"
    [[ "$desired" == 0 || "$desired" == 1 ]] || return 1
    software_write_desired_state "$config_file" "$variable" "$desired" verify || return $?
    [[ "$desired" == 1 ]] || return 0
    actual="$(software_apt_convergence_detect "$software")" || return 1
    [[ "$actual" == 1 ]] || { [[ "$actual" == 0 ]] && return 0; return 1; }
    package="$(software_apt_convergence_package "$software")" || return 1
    url="$(software_apt_convergence_artifact_url "$software")" || return 1
    [[ -n "$url" ]] || return 1
    installed_version="$(dpkg-query -W -f='${Version}' "$package")" || return 1
    [[ -n "$installed_version" ]] || return 1
    temporary="$(mktemp -d)" || return 1
    [[ -n "$temporary" && -d "$temporary" ]] || return 1
    trap 'rm -rf -- "$temporary"' EXIT
    artifact="$(software_apt_fetch_artifact "$url" "$package" "$temporary")" || return 1
    available_version="$(dpkg-deb -f "$artifact" Version)" || return 1
    [[ -n "$available_version" ]] || return 1
    if dpkg --compare-versions "$available_version" gt "$installed_version"; then
        apt -y install -- "$artifact" || return 1
        printf '%s : version mise à jour.\n' "$software"
    else
        status=$?
        if [[ "$status" != 1 ]]; then
            printf '%s\n' 'Comparaison des versions Debian impossible.' >&2
            return 1
        fi
        printf '%s : version déjà à jour.\n' "$software"
    fi
)

system_apt_update_external_applications() {
    local config_file="${1:-}" software result=0
    [[ -n "$config_file" ]] || return 2
    while IFS= read -r software; do
        [[ -n "$software" ]] || continue
        if ! system_apt_update_external_one "$config_file" "$software"; then
            printf 'Mise à jour APT externe échouée : %s.\n' "$software" >&2
            result=1
        fi
    done < <(software_apt_convergence_external_names)
    return "$result"
}

#!/usr/bin/env bash

software_github_install() (
    local software="${1:-}" mode="${2:-install}" owner repository prefix system architecture asset manifest root binary executable companion
    local metadata tag checksum actual work='' target previous='' linked_target helper actual_state
    [[ "$mode" == install || "$mode" == upgrade ]] || return 2
    owner="$(software_github_convergence_metadata "$software" owner)" || return 1
    repository="$(software_github_convergence_metadata "$software" repository)" || return 1
    prefix="$(software_github_convergence_metadata "$software" tag-prefix)" || return 1
    system="$(software_github_convergence_metadata "$software" system)" || return 1
    architecture="$(software_github_convergence_metadata "$software" architecture)" || return 1
    asset="$(software_github_convergence_metadata "$software" asset)" || return 1
    manifest="$(software_github_convergence_metadata "$software" manifest)" || return 1
    root="$(software_github_convergence_metadata "$software" root)" || return 1
    binary="$(software_github_convergence_metadata "$software" binary)" || return 1
    executable="$(software_github_convergence_metadata "$software" executable)" || return 1
    companion="$(software_github_convergence_metadata "$software" companion)" || return 1
    if [[ "$(uname -s)" != "$system" || "$(uname -m)" != "$architecture" || -L "$root" ]]; then
        printf '%s\n' 'Plateforme ou répertoire GitHub non pris en charge.' >&2
        return 1
    fi
    target="$root/packages/standalone/current"
    linked_target="$target/$executable"
    if [[ -e "$binary" || -L "$binary" ]]; then
        if [[ ! -L "$binary" || "$(readlink -- "$binary")" != "$linked_target" ]]; then
            printf '%s\n' 'Le chemin du binaire GitHub est déjà occupé.' >&2
            return 1
        fi
    fi
    metadata="$(curl --fail --silent --show-error --location --header 'Accept: application/vnd.github+json' "https://api.github.com/repos/$owner/$repository/releases/latest")" || return 1
    tag="$(printf '%s\n' "$metadata" | sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)"
    if [[ "$tag" != "$prefix"[0-9]* || ! "$tag" =~ ^[A-Za-z0-9.+_-]+$ ]] || ! printf '%s\n' "$metadata" | grep -Fq -- "$asset"; then
        printf '%s\n' 'Release GitHub ou artefact invalide.' >&2
        return 1
    fi
    mkdir -p -- "$root/packages/standalone" "$(dirname -- "$binary")" || return 1
    work="$(mktemp -d "$root/.software-github.XXXXXXXX")" || return 1
    trap '[[ -z "$work" ]] || rm -rf -- "$work"' EXIT
    curl --fail --silent --show-error --location "https://github.com/$owner/$repository/releases/download/$tag/$manifest" -o "$work/manifest" || return 1
    checksum="$(awk -v asset="$asset" 'length($1) == 64 && $1 !~ /[^0-9a-fA-F]/ && $2 == asset { print tolower($1); exit }' "$work/manifest")"
    [[ "$checksum" =~ ^[0-9a-f]{64}$ ]] || { printf '%s\n' 'Empreinte GitHub absente.' >&2; return 1; }
    curl --fail --silent --show-error --location "https://github.com/$owner/$repository/releases/download/$tag/$asset" -o "$work/archive" || return 1
    actual="$(sha256sum -- "$work/archive")" || return 1
    if [[ "${actual%% *}" != "$checksum" ]]; then
        printf '%s\n' 'Vérification SHA-256 GitHub échouée.' >&2
        return 1
    fi
    mkdir -p -- "$work/payload" || return 1
    helper="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/safe_archive.py" || return 1
    python3 "$helper" "$work/archive" "$work/payload" || return 1
    if [[ ! -x "$work/payload/$executable" || ! -x "$work/payload/$companion" ]]; then
        printf '%s\n' 'Paquet GitHub incomplet.' >&2
        return 1
    fi
    if [[ "$mode" == install ]]; then
        actual_state="$(software_github_convergence_detect "$software")" || return 1
        if [[ "$actual_state" == 1 ]]; then
            printf '%s : logiciel déjà présent.\n' "$software"
            return 0
        fi
        [[ "$actual_state" == 0 ]] || return 1
    fi
    if [[ -e "$target" || -L "$target" ]]; then
        previous="$work/previous"
        mv -- "$target" "$previous" || return 1
    fi
    if ! mv -- "$work/payload" "$target"; then
        if [[ -n "$previous" ]] && ! mv -- "$previous" "$target"; then
            printf 'Ancienne installation conservée dans %s.\n' "$work" >&2
            work=''
        fi
        return 1
    fi
    if ! ln -sfn -- "$linked_target" "$binary"; then
        if [[ -n "$previous" ]]; then
            if ! mv -- "$target" "$work/failed" || ! mv -- "$previous" "$target"; then
                printf 'Ancienne installation conservée dans %s.\n' "$work" >&2
                work=''
            fi
        fi
        return 1
    fi
    printf 'Logiciel GitHub installé : %s.\n' "$software"
)

software_github_remove() {
    local software="${1:-}" root binary executable target
    root="$(software_github_convergence_metadata "$software" root)" || return 1
    binary="$(software_github_convergence_metadata "$software" binary)" || return 1
    executable="$(software_github_convergence_metadata "$software" executable)" || return 1
    [[ ! -L "$root" ]] || { printf '%s\n' 'Répertoire GitHub non pris en charge.' >&2; return 1; }
    target="$root/packages/standalone/current/$executable"
    if [[ -e "$binary" || -L "$binary" ]]; then
        if [[ ! -L "$binary" || "$(readlink -- "$binary")" != "$target" ]]; then
            printf '%s\n' 'Le binaire GitHub ne correspond pas à une installation DIU.' >&2
            return 1
        fi
        rm -f -- "$binary" || return 1
    fi
    rm -rf -- "$root/packages/standalone" "$root/packages/tmp" || return 1
    printf 'Logiciel GitHub désinstallé : %s.\n' "$software"
}

software_github_converge() {
    software_converge "${1:-}" "${2:-}" software_github_convergence_detect software_github_install software_github_remove
}

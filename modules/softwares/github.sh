#!/usr/bin/env bash
# shellcheck disable=SC2016,SC2088

# Les recettes sont enregistrées explicitement par le module qui les fournit.
software_github_recipe() {
    case "${1,,}:${2,,}" in
        codex-cli:install) printf '%s' software_github_codex_cli_install ;;
        codex-cli:remove) printf '%s' software_github_codex_cli_remove ;;
        codex-cli:update) printf '%s' software_github_codex_cli_update ;;
        *) return 1 ;;
    esac
}

software_github_codex_cli_root() {
    local configured_home="${SOFTWARES_APT_CODEX_CLI_HOME:-~/.codex}"
    case "$configured_home" in
        '~/'*) printf '%s/%s\n' "$HOME" "${configured_home#\~/}" ;;
        *) printf '%s\n' "$configured_home" ;;
    esac
}
software_github_codex_cli_binary() { printf '%s\n' "${SOFTWARES_APT_CODEX_CLI_BIN:-$HOME/.local/bin/codex}"; }
software_github_codex_cli_version() { "$(software_github_codex_cli_binary)" --version 2>/dev/null | sed -n 's/.* \([0-9][0-9A-Za-z.+-]*\)$/\1/p' | head -n 1; }

software_github_codex_cli_install() {
    local root archive checksum_file metadata tag asset checksum expected actual staging binary
    [[ "$(uname -s)" == Linux && "$(uname -m)" == x86_64 ]] || { print_error "Codex CLI GitHub est pris en charge uniquement sur Linux x86_64."; return 1; }
    command -v curl >/dev/null 2>&1 || { print_error "curl est requis pour Codex CLI."; return 1; }
    command -v tar >/dev/null 2>&1 || { print_error "tar est requis pour Codex CLI."; return 1; }
    command -v sha256sum >/dev/null 2>&1 || { print_error "sha256sum est requis pour Codex CLI."; return 1; }
    root="$(software_github_codex_cli_root)"
    binary="$(software_github_codex_cli_binary)"
    archive="$root/.codex-package.tar.gz"
    checksum_file="$root/.codex-package_SHA256SUMS"
    metadata="$(curl --fail --silent --show-error --location --header 'Accept: application/vnd.github+json' 'https://api.github.com/repos/openai/codex/releases/latest')" || return 1
    tag="$(printf '%s\n' "$metadata" | sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)"
    [[ "$tag" == rust-v[0-9]* ]] || { print_error "Release Codex CLI GitHub invalide."; return 1; }
    asset="codex-package-x86_64-unknown-linux-musl.tar.gz"
    printf '%s\n' "$metadata" | grep -F "$asset" >/dev/null || { print_error "Archive Codex CLI x86_64 introuvable dans la release GitHub."; return 1; }
    mkdir -p "$root"
    curl --fail --silent --show-error --location "https://github.com/openai/codex/releases/download/$tag/codex-package_SHA256SUMS" -o "$checksum_file" || return 1
    checksum="$(awk -v asset="$asset" 'length($1) == 64 && $1 !~ /[^0-9a-fA-F]/ && $2 == asset { print tolower($1); exit }' "$checksum_file")"
    [[ "$checksum" =~ ^[0-9a-fA-F]{64}$ ]] || { print_error "Digest SHA-256 Codex CLI introuvable dans le manifeste GitHub."; rm -f "$checksum_file"; return 1; }
    curl --fail --silent --show-error --location "https://github.com/openai/codex/releases/download/$tag/$asset" -o "$archive" || return 1
    expected="$(printf '%s  %s\n' "$checksum" "$archive")"
    actual="$(sha256sum "$archive")"
    [[ "$actual" == "$expected" ]] || { print_error "Vérification SHA-256 de Codex CLI échouée."; rm -f "$archive"; return 1; }
    staging="$root/.staging.$$"
    rm -rf "$staging"
    mkdir -p "$staging"
    tar -xzf "$archive" -C "$staging" || { rm -rf "$staging" "$archive"; return 1; }
    [[ -x "$staging/bin/codex" && -x "$staging/codex-path/rg" ]] || { print_error "Paquet Codex CLI incomplet."; rm -rf "$staging" "$archive"; return 1; }
    mkdir -p "$root/packages/standalone"
    rm -rf "$root/packages/standalone/current"
    mv "$staging" "$root/packages/standalone/current"
    mkdir -p "$(dirname "$binary")"
    {
        printf '%s\n' '#!/bin/sh'
        printf '%s\n' 'config_file="${DIU_CONFIG_FILE:-/root/diu/config/softwares.env}"'
        printf '%s\n' '[ -r "$config_file" ] && . "$config_file"'
        printf '%s\n' 'configured_home="${SOFTWARES_APT_CODEX_CLI_HOME:-~/.codex}"'
        printf '%s\n' 'case "$configured_home" in'
        printf '%s\n' '    ~/*) CODEX_HOME="$HOME/${configured_home#~/}" ;;'
        printf '%s\n' '    *) CODEX_HOME="$configured_home" ;;'
        printf '%s\n' 'esac'
        printf '%s\n' 'export CODEX_HOME'
        printf '%s\n' 'exec "$CODEX_HOME/packages/standalone/current/bin/codex" "$@"'
    } >"$binary"
    chmod 0755 "$binary"
    rm -f "$archive" "$checksum_file"
    SOFTWARES_APT_CODEX_CLI=1
    export SOFTWARES_APT_CODEX_CLI
    local installed_version
    installed_version="$(software_github_codex_cli_version)"
    print_success "softwares/github/codex-cli (${installed_version:-inconnue}): installé."
}

software_github_codex_cli_remove() {
    local root binary installed_version
    root="$(software_github_codex_cli_root)"
    binary="$(software_github_codex_cli_binary)"
    if [[ "${SOFTWARES_APT_CODEX_CLI:-0}" == 1 ]]; then
        installed_version="$(software_github_codex_cli_version)"
    else
        print_info "softwares/github/codex-cli : déjà désinstallé."
        return 0
    fi
    rm -f "$binary"
    rm -rf "$root/packages/standalone"
    SOFTWARES_APT_CODEX_CLI=0
    export SOFTWARES_APT_CODEX_CLI
    print_success "softwares/github/codex-cli (${installed_version:-inconnue}): désinstallé."
}

software_github_codex_cli_update() {
    local binary local_version metadata remote_version updated_version
    [[ "${SOFTWARES_APT_CODEX_CLI:-0}" == 1 ]] || { print_error "Codex CLI n'est pas installé."; return 1; }
    binary="$(software_github_codex_cli_binary)"
    local_version="$(software_github_codex_cli_version)"
    metadata="$(curl --fail --silent --show-error --location --header 'Accept: application/vnd.github+json' 'https://api.github.com/repos/openai/codex/releases/latest')" || return 1
    remote_version="$(printf '%s\n' "$metadata" | sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"rust-v\([^"]*\)".*/\1/p' | head -n 1)"
    if [[ -n "$local_version" && -n "$remote_version" ]] && ! software_github_version_is_newer "$local_version" "$remote_version"; then
        print_info "Codex CLI est déjà à jour ($local_version)."
        return 0
    fi
    software_github_codex_cli_install >/dev/null || return 1
    updated_version="$(software_github_codex_cli_version)"
    print_success "softwares/github/codex-cli (${local_version:-inconnue} --> ${updated_version:-inconnue}): mis à jour."
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

software_github_known_software() {
    [[ "${SOFTWARES_APT_CODEX_CLI:-0}" == 1 ]] && printf '%s\n' codex-cli
}

software_github_update_all() {
    local software result=0
    while IFS= read -r software; do
        [[ -n "$software" ]] || continue
        if ! software_github_action update "$software"; then print_error "softwares/github/$software : échec."; result=1; fi
    done < <(software_github_known_software)
    return "$result"
}

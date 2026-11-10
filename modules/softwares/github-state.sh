#!/usr/bin/env bash

# Catalogue fermé : seuls des identifiants déclarés peuvent piloter un chemin ou une URL.
software_github_convergence_metadata() {
    case "${1:-}:${2:-}" in
        codex-cli:variable) printf '%s\n' SOFTWARE_GITHUB_CODEX_CLI ;;
        codex-cli:owner) printf '%s\n' openai ;;
        codex-cli:repository) printf '%s\n' codex ;;
        codex-cli:tag-prefix) printf '%s\n' rust-v ;;
        codex-cli:system) printf '%s\n' Linux ;;
        codex-cli:architecture) printf '%s\n' x86_64 ;;
        codex-cli:asset) printf '%s\n' codex-package-x86_64-unknown-linux-musl.tar.gz ;;
        codex-cli:manifest) printf '%s\n' codex-package_SHA256SUMS ;;
        codex-cli:root) printf '%s\n' /usr/local/lib/codex ;;
        codex-cli:binary) printf '%s\n' /usr/local/bin/codex ;;
        codex-cli:command) printf '%s\n' codex ;;
        codex-cli:executable) printf '%s\n' bin/codex ;;
        codex-cli:companion) printf '%s\n' codex-path/rg ;;
        *) printf 'Métadonnée GitHub non déclarée : %s\n' "${1:-}" >&2; return 1 ;;
    esac
}

software_github_convergence_names() {
    printf '%s\n' codex-cli
}

software_github_codex_cli_detect() {
    local binary
    binary="$(software_github_convergence_metadata codex-cli binary)" || return 1
    if [[ -x "$binary" ]] || command -v codex >/dev/null 2>&1; then
        printf '1\n'
    else
        printf '0\n'
    fi
}

software_github_convergence_detect() {
    case "${1:-}" in
        codex-cli) software_github_codex_cli_detect ;;
        *) printf 'Logiciel GitHub non déclaré : %s\n' "${1:-}" >&2; return 1 ;;
    esac
}

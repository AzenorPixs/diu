#!/usr/bin/env bash

# Catalogue fermé : seuls des identifiants déclarés peuvent piloter un chemin ou une URL.
software_github_convergence_metadata() {
    case "${1:-}:${2:-}" in
        codex-cli:variable) printf '%s\n' SOFTWARE_GITHUB_CODEX_CLI ;;
        codex-cli:configuration-hook) printf '%s\n' software_github_configure_codex_cli ;;
        codex-cli:cleanup-hook) printf '%s\n' software_github_cleanup_codex_cli ;;
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
        opencode:variable) printf '%s\n' SOFTWARE_GITHUB_OPENCODE ;;
        opencode:configuration-hook) printf '%s\n' software_github_configure_opencode ;;
        opencode:cleanup-hook) printf '%s\n' software_github_cleanup_opencode ;;
        opencode:owner) printf '%s\n' anomalyco ;;
        opencode:repository) printf '%s\n' opencode ;;
        opencode:tag-prefix) printf '%s\n' v ;;
        opencode:system) printf '%s\n' Linux ;;
        opencode:architecture) printf '%s\n' x86_64 ;;
        opencode:asset) printf '%s\n' opencode-linux-x64.tar.gz ;;
        opencode:manifest) printf '%s\n' SHA256SUMS ;;
        opencode:root) printf '%s\n' /usr/local/lib/opencode ;;
        opencode:binary) printf '%s\n' /usr/local/bin/opencode ;;
        opencode:command) printf '%s\n' opencode ;;
        opencode:executable) printf '%s\n' opencode ;;
        opencode:companion) printf '%s\n' opencode ;;
        *) printf 'Métadonnée GitHub non déclarée : %s\n' "${1:-}" >&2; return 1 ;;
    esac
}

software_github_configure_codex_cli() { return 0; }
software_github_cleanup_codex_cli() {
    local root
    root="$(software_github_convergence_metadata codex-cli root)" || return 1
    [[ ! -L "$root" ]] || return 1
    rm -rf -- "$root/packages/tmp"
}

software_github_convergence_names() {
    printf '%s\n' codex-cli opencode
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

software_github_opencode_detect() {
    local binary
    binary="$(software_github_convergence_metadata opencode binary)" || return 1
    if [[ -x "$binary" ]]; then printf '1\n'; else printf '0\n'; fi
}

software_github_opencode_latest_stable_tag() {
    local owner repository asset manifest releases tag page
    owner="$(software_github_convergence_metadata opencode owner)" || return 1
    repository="$(software_github_convergence_metadata opencode repository)" || return 1
    asset="$(software_github_convergence_metadata opencode asset)" || return 1
    manifest="$(software_github_convergence_metadata opencode manifest)" || return 1
    for ((page = 1; page <= 20; page++)); do
        releases="$(curl --fail --silent --show-error --location \
            --header 'Accept: application/vnd.github+json' \
            "https://api.github.com/repos/$owner/$repository/releases?per_page=100&page=$page")" || return 1
        if ! tag="$(printf '%s\n' "$releases" | python3 -c '
import json
import re
import sys

asset, manifest = sys.argv[1:]
try:
    releases = json.load(sys.stdin)
except (ValueError, TypeError):
    sys.exit(2)
if not isinstance(releases, list):
    sys.exit(2)
if not releases:
    print("__NO_RELEASES__")
    sys.exit(0)
pattern = re.compile(r"v2\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\Z")
versions = []
for release in releases:
    if not isinstance(release, dict) or release.get("draft") or release.get("prerelease"):
        continue
    candidate = release.get("tag_name")
    match = pattern.fullmatch(candidate) if isinstance(candidate, str) else None
    assets = release.get("assets")
    if not match or not isinstance(assets, list):
        continue
    names = {item.get("name") for item in assets if isinstance(item, dict)}
    if asset in names and manifest in names:
        versions.append(((int(match.group(1)), int(match.group(2))), candidate))
if not versions:
    sys.exit(0)
print(max(versions)[1])
' "$asset" "$manifest")"; then
            printf '%s\n' 'Réponse de releases OpenCode invalide.' >&2
            return 1
        fi
        case "$tag" in
            __NO_RELEASES__) break ;;
            '') continue ;;
            *) printf '%s\n' "$tag"; return 0 ;;
        esac
    done
    printf '%s\n' 'Aucune release stable OpenCode V2 compatible trouvée sur GitHub.' >&2
    return 1
}
software_github_opencode_version() {
    local binary output version
    binary="$(software_github_convergence_metadata opencode binary)" || return 1
    [[ -x "$binary" ]] || return 1
    output="$("$binary" --version 2>/dev/null)" || return 1
    version="${output##*$'\n'}"
    version="${version##* }"
    version="${version#v}"
    [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || return 1
    printf '%s\n' "$version"
}

software_github_configure_opencode() { return 0; }
software_github_cleanup_opencode() { return 0; }

software_github_convergence_detect() {
    case "${1:-}" in
        codex-cli) software_github_codex_cli_detect ;;
        opencode) software_github_opencode_detect ;;
        *) printf 'Logiciel GitHub non déclaré : %s\n' "${1:-}" >&2; return 1 ;;
    esac
}

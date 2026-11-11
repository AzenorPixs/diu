#!/usr/bin/env bash

software_apt_effective_release() {
    local file="${1:-/etc/os-release}" release="${SYSTEM_DEBIAN_RELEASE:-}" line found=0
    if [[ -z "$release" ]]; then
        [[ -f "$file" && -r "$file" ]] || return 1
        while IFS= read -r line || [[ -n "$line" ]]; do
            if [[ "$line" =~ ^VERSION_CODENAME=([a-z0-9-]+)$ || "$line" =~ ^VERSION_CODENAME=\"([a-z0-9-]+)\"$ ]]; then
                release="${BASH_REMATCH[1]}"
                (( found += 1 ))
            elif [[ "$line" == VERSION_CODENAME=* ]]; then
                return 1
            fi
        done < "$file"
        [[ "$found" == 1 ]] || return 1
    fi
    case "$release" in bullseye|bookworm|trixie) printf '%s\n' "$release" ;; *) return 1 ;; esac
}

# Interroge la base entière pour distinguer un paquet inconnu d'une erreur dpkg.
software_apt_package_state() {
    local package="${1:-}" rows name state found=0
    if [[ ! "$package" =~ ^[a-z0-9][a-z0-9+.-]+$ ]]; then
        printf '%s\n' 'Identifiant de paquet invalide.' >&2
        return 2
    fi
    if ! rows="$(dpkg-query -W -f='${binary:Package}\t${db:Status-Status}\n')"; then
        printf '%s\n' 'État des paquets Debian indisponible.' >&2
        return 2
    fi
    while IFS=$'\t' read -r name state; do
        [[ "$name" == "$package" || "$name" == "$package:"* ]] || continue
        case "$state" in
            installed) found=1 ;;
            not-installed|config-files) ;;
            *) printf 'État Debian incomplet pour %s.\n' "$package" >&2; return 1 ;;
        esac
    done <<< "$rows"
    printf '%s\n' "$found"
}






# Les détecteurs et hooks propres aux logiciels appartiennent aux déclarations GLOBAL.
# shellcheck disable=SC1091 source=modules/softwares/apt-recipes.sh
. "$(dirname -- "${BASH_SOURCE[0]}")/apt-recipes.sh"
software_apt_load_recipes || return 1

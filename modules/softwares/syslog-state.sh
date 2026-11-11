#!/usr/bin/env bash

# Vérifie les rôles sans restituer le contenu des configurations de journalisation.
software_apt_syslog_role_state() (
    local role="${1:-}" prefix="${2:-/}" package_state main directory file expression status
    local -a files=()
    # Le dollar du motif serveur fait partie de la syntaxe historique de rsyslog.
    # shellcheck disable=SC2016
    case "$role" in
        client) expression='^[[:space:]]*\*\.\*[[:space:]]+@@?[^[:space:]]+|^[[:space:]]*action\([[:space:]]*type="omfwd"' ;;
        server) expression='^[[:space:]]*input\([[:space:]]*type="im(udp|tcp)"|^[[:space:]]*\$(UDPServerRun|InputTCPServerRun)[[:space:]]+' ;;
        *) return 2 ;;
    esac
    package_state="$(software_apt_package_state rsyslog)" || return 2
    [[ "$package_state" == 1 ]] || { [[ "$package_state" == 0 ]] && { printf '0\n'; return 0; }; return 2; }
    main="${prefix%/}/etc/rsyslog.conf"
    directory="${prefix%/}/etc/rsyslog.d"
    if [[ -L "$main" || ! -f "$main" || ! -r "$main" || -L "$directory" ]]; then
        printf '%s\n' 'Configuration syslog inaccessible ou non vérifiable.' >&2
        return 2
    fi
    shopt -s nullglob
    files=("$main" "$directory"/*.conf)
    for file in "${files[@]}"; do
        if [[ -L "$file" || ! -f "$file" || ! -r "$file" ]]; then
            printf '%s\n' 'Configuration syslog inaccessible ou non vérifiable.' >&2
            return 2
        fi
        if grep -Eq -- "$expression" "$file"; then
            printf '1\n'
            return 0
        else
            status=$?
            [[ "$status" == 1 ]] || return 2
        fi
    done
    printf '0\n'
)


# Les détecteurs et hooks propres aux logiciels appartiennent aux déclarations GLOBAL.
# shellcheck disable=SC1091 source=modules/softwares/apt-recipes.sh
. "$(dirname -- "${BASH_SOURCE[0]}")/apt-recipes.sh"
software_apt_load_recipes || return 1

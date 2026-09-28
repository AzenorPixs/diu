#!/usr/bin/env bash

# Supprime les affectations historiques avant de charger la configuration locale.
config_cleanup() {
    local variables_file="${1:-/root/diu/variables.sh}"
    local legacy_assignment='^[[:blank:]]*(export[[:blank:]]+)?(DEBIAN_RELEASE|DEBIAN_TYPE|DISPLAY_LINK)='
    local status

    [[ -e "$variables_file" ]] || return 0

    if grep -E "$legacy_assignment" "$variables_file" > /dev/null 2>&1; then
        if ! sed -i -E "/$legacy_assignment/d" "$variables_file"; then
            printf '%s\n' 'Erreur : nettoyage de la configuration historique impossible.' >&2
            return 1
        fi
    else
        status=$?
        if [[ "$status" -ne 1 ]]; then
            printf '%s\n' 'Erreur : lecture de la configuration historique impossible.' >&2
            return 1
        fi
    fi
}



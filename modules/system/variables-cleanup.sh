#!/usr/bin/env bash

# Supprime les affectations historiques avant de charger la configuration locale.
config_cleanup() {
    local variables_file="${1:-/root/diu/variables.sh}"
    local system_config_file="${2:-/root/diu/config/system.env}"
    local legacy_assignment='^[[:blank:]]*(export[[:blank:]]+)?(DEBIAN_RELEASE|DEBIAN_TYPE|DISPLAY_LINK|TIME_ZONE|PROXY_CA|PROXY)='
    local status line proxy_value='' proxy_found=0 system_proxy_declared=0

    [[ -e "$variables_file" ]] || return 0

    if [[ ! -f "$variables_file" || ! -r "$variables_file" ]]; then
        printf '%s\n' 'Erreur : lecture de la configuration historique impossible.' >&2
        return 1
    fi

    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?PROXY= ]] || continue
        proxy_found=1
        if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?PROXY=([[:blank:]]*)([01])[[:blank:]]*(#.*)?$ ]]; then
            proxy_value="${BASH_REMATCH[3]}"
        else
            printf '%s\n' 'Erreur : affectation historique PROXY ambiguë ; nettoyage impossible.' >&2
            return 1
        fi
    done < "$variables_file"

    if [[ "$proxy_found" == 1 && -e "$system_config_file" ]]; then
        if [[ ! -f "$system_config_file" || ! -r "$system_config_file" ]]; then
            printf '%s\n' 'Erreur : lecture de la configuration système impossible.' >&2
            return 1
        fi
        if grep -E '^[[:blank:]]*(export[[:blank:]]+)?SYSTEM_PROXY=' "$system_config_file" > /dev/null 2>&1; then
            system_proxy_declared=1
        else
            status=$?
            if [[ "$status" -ne 1 ]]; then
                printf '%s\n' 'Erreur : lecture de la configuration système impossible.' >&2
                return 1
            fi
        fi
    fi

    if [[ "$proxy_found" == 1 && "$system_proxy_declared" == 0 ]]; then
        if ! install -d -m 0755 "$(dirname "$system_config_file")"; then
            printf '%s\n' 'Erreur : création de la configuration système impossible.' >&2
            return 1
        fi
        if ! printf 'export SYSTEM_PROXY=%s\n' "$proxy_value" >> "$system_config_file"; then
            printf '%s\n' 'Erreur : migration de la configuration proxy impossible.' >&2
            return 1
        fi
    fi

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



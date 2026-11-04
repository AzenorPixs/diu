#!/usr/bin/env bash
# shellcheck disable=SC2034

config="STATIC"
state="ENABLE"
scope="system"
default_value="1G"
variable_config_file="/root/diu/config/${scope}.env"

if [[ "$state" == "ENABLE" ]]; then
    if [[ -z "${SYSTEM_JOURNALD_KEEP_FREE+x}" ]]; then
        if ! install -d -m 0755 "$(dirname "$variable_config_file")"; then
            printf '%s\n' 'SYSTEM_JOURNALD_KEEP_FREE : création du répertoire de configuration impossible.' >&2
            return 1
        fi
        if ! printf 'export SYSTEM_JOURNALD_KEEP_FREE=%q\n' "$default_value" >> "$variable_config_file"; then
            printf '%s\n' 'SYSTEM_JOURNALD_KEEP_FREE : persistance impossible.' >&2
            return 1
        fi
        export SYSTEM_JOURNALD_KEEP_FREE="$default_value"
    elif [[ "$SYSTEM_JOURNALD_KEEP_FREE" =~ ^[0-9]+[KMGTPE]?$ ]]; then
        export SYSTEM_JOURNALD_KEEP_FREE
    else
        printf '%s\n' 'SYSTEM_JOURNALD_KEEP_FREE : valeur invalide, attendu un entier avec suffixe optionnel K, M, G, T, P ou E.' >&2
        return 1
    fi
else
    unset SYSTEM_JOURNALD_KEEP_FREE
    if [[ -f "$variable_config_file" ]]; then
        if ! sed -i '/^[[:blank:]]*export[[:blank:]]\+SYSTEM_JOURNALD_KEEP_FREE=/d' "$variable_config_file"; then
            printf '%s\n' 'SYSTEM_JOURNALD_KEEP_FREE : suppression de la déclaration impossible.' >&2
            return 1
        fi
    fi
fi

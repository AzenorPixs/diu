#!/usr/bin/env bash
# shellcheck disable=SC2034

config="STATIC"
state="ENABLE"
scope="system"
default_value=0
variable_config_file="/root/diu/config/${scope}.env"

if [[ "$state" == "ENABLE" ]]; then
    if [[ -z "${SYSTEM_NO_SLEEP+x}" ]]; then
        if ! install -d -m 0755 "$(dirname "$variable_config_file")"; then
            printf '%s\n' 'SYSTEM_NO_SLEEP : création du répertoire de configuration impossible.' >&2
            return 1
        fi
        if ! printf 'export SYSTEM_NO_SLEEP=%q\n' "$default_value" >> "$variable_config_file"; then
            printf '%s\n' 'SYSTEM_NO_SLEEP : persistance impossible.' >&2
            return 1
        fi
        export SYSTEM_NO_SLEEP="$default_value"
    elif [[ "$SYSTEM_NO_SLEEP" =~ ^[01]$ ]]; then
        export SYSTEM_NO_SLEEP
    else
        printf '%s\n' 'SYSTEM_NO_SLEEP : valeur invalide, attendu 0 ou 1.' >&2
        return 1
    fi
else
    unset SYSTEM_NO_SLEEP
    if [[ -f "$variable_config_file" ]]; then
        if ! sed -i '/^[[:blank:]]*export[[:blank:]]\+SYSTEM_NO_SLEEP=/d' "$variable_config_file"; then
            printf '%s\n' 'SYSTEM_NO_SLEEP : suppression de la déclaration impossible.' >&2
            return 1
        fi
    fi
fi

#!/usr/bin/env bash
# shellcheck disable=SC2034

config="STATIC"
state="ENABLE"
scope="system"
default_value=0
variable_config_file="/root/diu/config/${scope}.env"

if [[ "$state" == "ENABLE" ]]; then
    if [[ -z "${SYSTEM_LOG_ROTATE+x}" ]]; then
        if ! install -d -m 0755 "$(dirname "$variable_config_file")"; then
            printf '%s\n' 'SYSTEM_LOG_ROTATE : création du répertoire de configuration impossible.' >&2
            return 1
        fi
        if ! printf 'export SYSTEM_LOG_ROTATE=%q\n' "$default_value" >> "$variable_config_file"; then
            printf '%s\n' 'SYSTEM_LOG_ROTATE : persistance impossible.' >&2
            return 1
        fi
        export SYSTEM_LOG_ROTATE="$default_value"
    elif [[ "$SYSTEM_LOG_ROTATE" =~ ^[01]$ ]]; then
        export SYSTEM_LOG_ROTATE
    else
        printf '%s\n' 'SYSTEM_LOG_ROTATE : valeur invalide, attendu 0 ou 1.' >&2
        return 1
    fi
else
    unset SYSTEM_LOG_ROTATE
    if [[ -f "$variable_config_file" ]]; then
        if ! sed -i '/^[[:blank:]]*export[[:blank:]]\+SYSTEM_LOG_ROTATE=/d' "$variable_config_file"; then
            printf '%s\n' 'SYSTEM_LOG_ROTATE : suppression de la déclaration impossible.' >&2
            return 1
        fi
    fi
fi

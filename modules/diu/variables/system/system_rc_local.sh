#!/usr/bin/env bash
# shellcheck disable=SC2034

config="STATIC"
state="ENABLE"
scope="system"
default_value=0
variable_config_file="/root/diu/config/${scope}.env"

if [[ "$state" == "ENABLE" ]]; then
    if [[ -z "${SYSTEM_RC_LOCAL+x}" ]]; then
        if ! install -d -m 0755 "$(dirname "$variable_config_file")"; then
            printf '%s\n' 'SYSTEM_RC_LOCAL : création du répertoire de configuration impossible.' >&2
            return 1
        fi
        if ! printf 'export SYSTEM_RC_LOCAL=%q\n' "$default_value" >> "$variable_config_file"; then
            printf '%s\n' 'SYSTEM_RC_LOCAL : persistance impossible.' >&2
            return 1
        fi
        export SYSTEM_RC_LOCAL="$default_value"
    elif [[ "$SYSTEM_RC_LOCAL" =~ ^[01]$ ]]; then
        export SYSTEM_RC_LOCAL
    else
        printf '%s\n' 'SYSTEM_RC_LOCAL : valeur invalide, attendu 0 ou 1.' >&2
        return 1
    fi
else
    unset SYSTEM_RC_LOCAL
    if [[ -f "$variable_config_file" ]]; then
        if ! sed -i '/^[[:blank:]]*export[[:blank:]]\+SYSTEM_RC_LOCAL=/d' "$variable_config_file"; then
            printf '%s\n' 'SYSTEM_RC_LOCAL : suppression de la déclaration impossible.' >&2
            return 1
        fi
    fi
fi

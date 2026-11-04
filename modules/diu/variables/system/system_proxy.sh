#!/usr/bin/env bash
# shellcheck disable=SC2034

config="STATIC"
state="ENABLE"
scope="system"
default_value=0
variable_config_file="/root/diu/config/${scope}.env"

if [[ "$state" == "ENABLE" ]]; then
    if [[ -z "${SYSTEM_PROXY+x}" ]]; then
        if ! install -d -m 0755 "$(dirname "$variable_config_file")"; then
            printf '%s\n' 'SYSTEM_PROXY : création du répertoire de configuration impossible.' >&2
            return 1
        fi
        if ! printf 'export SYSTEM_PROXY=%q\n' "$default_value" >> "$variable_config_file"; then
            printf '%s\n' 'SYSTEM_PROXY : persistance impossible.' >&2
            return 1
        fi
        export SYSTEM_PROXY="$default_value"
    else
        export SYSTEM_PROXY
    fi
else
    unset SYSTEM_PROXY
    if [[ -f "$variable_config_file" ]]; then
        if ! sed -i '/^[[:blank:]]*export[[:blank:]]\+SYSTEM_PROXY=/d' "$variable_config_file"; then
            printf '%s\n' 'SYSTEM_PROXY : suppression de la déclaration impossible.' >&2
            return 1
        fi
    fi
fi

#!/usr/bin/env bash
# shellcheck disable=SC2034

config="STATIC"
state="ENABLE"
scope="system"
default_value=0
variable_config_file="/root/diu/config/${scope}.env"

if [[ "$state" == "ENABLE" ]]; then
    if [[ -z "${SYSTEM_PROXY_CA+x}" ]]; then
        if ! install -d -m 0755 "$(dirname "$variable_config_file")"; then
            printf '%s\n' 'SYSTEM_PROXY_CA : création du répertoire de configuration impossible.' >&2
            return 1
        fi
        if ! printf 'export SYSTEM_PROXY_CA=%q\n' "$default_value" >> "$variable_config_file"; then
            printf '%s\n' 'SYSTEM_PROXY_CA : persistance impossible.' >&2
            return 1
        fi
        export SYSTEM_PROXY_CA="$default_value"
    else
        export SYSTEM_PROXY_CA
    fi
else
    unset SYSTEM_PROXY_CA
    if [[ -f "$variable_config_file" ]]; then
        if ! sed -i '/^[[:blank:]]*export[[:blank:]]\+SYSTEM_PROXY_CA=/d' "$variable_config_file"; then
            printf '%s\n' 'SYSTEM_PROXY_CA : suppression de la déclaration impossible.' >&2
            return 1
        fi
    fi
fi

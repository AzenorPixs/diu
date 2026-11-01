#!/usr/bin/env bash
# shellcheck disable=SC2034

config="STATIC"
state="ENABLE"
scope="system"
default_value=0
variable_config_file="/root/diu/config/${scope}.env"

if [[ "$state" == "ENABLE" ]]; then
    if [[ -z "${SYSTEM_FILES2RAM+x}" ]]; then
        if ! install -d -m 0755 "$(dirname "$variable_config_file")"; then
            printf '%s\n' 'SYSTEM_FILES2RAM : création du répertoire de configuration impossible.' >&2
            return 1
        fi
        if ! printf 'export SYSTEM_FILES2RAM=%q\n' "$default_value" >> "$variable_config_file"; then
            printf '%s\n' 'SYSTEM_FILES2RAM : persistance impossible.' >&2
            return 1
        fi
        export SYSTEM_FILES2RAM="$default_value"
    else
        export SYSTEM_FILES2RAM
    fi
else
    unset SYSTEM_FILES2RAM
    if [[ -f "$variable_config_file" ]]; then
        if ! sed -i '/^[[:blank:]]*export[[:blank:]]\+SYSTEM_FILES2RAM=/d' "$variable_config_file"; then
            printf '%s\n' 'SYSTEM_FILES2RAM : suppression de la déclaration impossible.' >&2
            return 1
        fi
    fi
fi

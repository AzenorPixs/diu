#!/usr/bin/env bash
# shellcheck disable=SC2034

config="STATIC"
state="ENABLE"
scope="system"
default_value=0
variable_config_file="/root/diu/config/${scope}.env"

if [[ "$state" == "ENABLE" ]]; then
    if [[ -z "${SYSTEM_DRIVERS_NVIDIA+x}" ]]; then
        if ! install -d -m 0755 "$(dirname "$variable_config_file")"; then
            printf '%s\n' 'SYSTEM_DRIVERS_NVIDIA : création du répertoire de configuration impossible.' >&2
            return 1
        fi
        if ! printf 'export SYSTEM_DRIVERS_NVIDIA=%q\n' "$default_value" >> "$variable_config_file"; then
            printf '%s\n' 'SYSTEM_DRIVERS_NVIDIA : persistance impossible.' >&2
            return 1
        fi
        export SYSTEM_DRIVERS_NVIDIA="$default_value"
    else
        export SYSTEM_DRIVERS_NVIDIA
    fi
else
    unset SYSTEM_DRIVERS_NVIDIA
    if [[ -f "$variable_config_file" ]]; then
        if ! sed -i '/^[[:blank:]]*export[[:blank:]]\+SYSTEM_DRIVERS_NVIDIA=/d' "$variable_config_file"; then
            printf '%s\n' 'SYSTEM_DRIVERS_NVIDIA : suppression de la déclaration impossible.' >&2
            return 1
        fi
    fi
fi

#!/usr/bin/env bash
# shellcheck disable=SC2034

config="STATIC"
state="ENABLE"
scope="system"
default_value=0
variable_config_file="/root/diu/config/${scope}.env"

if [[ "$state" == "ENABLE" ]]; then
    if [[ -z "${SYSTEM_GRUB_CONFIG+x}" ]]; then
        if ! install -d -m 0755 "$(dirname "$variable_config_file")"; then
            printf '%s\n' 'SYSTEM_GRUB_CONFIG : création du répertoire de configuration impossible.' >&2
            return 1
        fi
        if ! printf 'export SYSTEM_GRUB_CONFIG=%q\n' "$default_value" >> "$variable_config_file"; then
            printf '%s\n' 'SYSTEM_GRUB_CONFIG : persistance impossible.' >&2
            return 1
        fi
        export SYSTEM_GRUB_CONFIG="$default_value"
    else
        export SYSTEM_GRUB_CONFIG
    fi
else
    unset SYSTEM_GRUB_CONFIG
    if [[ -f "$variable_config_file" ]]; then
        if ! sed -i '/^[[:blank:]]*export[[:blank:]]\+SYSTEM_GRUB_CONFIG=/d' "$variable_config_file"; then
            printf '%s\n' 'SYSTEM_GRUB_CONFIG : suppression de la déclaration impossible.' >&2
            return 1
        fi
    fi
fi

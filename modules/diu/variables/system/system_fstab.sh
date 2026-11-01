#!/usr/bin/env bash
# shellcheck disable=SC2034

config="STATIC"
state="ENABLE"
scope="system"
default_value=0
variable_config_file="/root/diu/config/${scope}.env"

if [[ "$state" == "ENABLE" ]]; then
    if [[ -z "${SYSTEM_FSTAB+x}" ]]; then
        if ! install -d -m 0755 "$(dirname "$variable_config_file")"; then
            printf '%s\n' 'SYSTEM_FSTAB : création du répertoire de configuration impossible.' >&2
            return 1
        fi
        if ! printf 'export SYSTEM_FSTAB=%q\n' "$default_value" >> "$variable_config_file"; then
            printf '%s\n' 'SYSTEM_FSTAB : persistance impossible.' >&2
            return 1
        fi
        export SYSTEM_FSTAB="$default_value"
    else
        export SYSTEM_FSTAB
    fi
else
    unset SYSTEM_FSTAB
    if [[ -f "$variable_config_file" ]]; then
        if ! sed -i '/^[[:blank:]]*export[[:blank:]]\+SYSTEM_FSTAB=/d' "$variable_config_file"; then
            printf '%s\n' 'SYSTEM_FSTAB : suppression de la déclaration impossible.' >&2
            return 1
        fi
    fi
fi

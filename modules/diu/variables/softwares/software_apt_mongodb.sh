#!/usr/bin/env bash
# shellcheck disable=SC2034

config="STATIC"
state="ENABLE"
scope="softwares"
default_value=0
variable_config_file="/root/diu/config/${scope}.env"

if [[ "$state" == "ENABLE" ]]; then
    if [[ -z "${SOFTWARES_APT_MONGODB+x}" ]]; then
        if ! install -d -m 0755 "$(dirname "$variable_config_file")"; then
            printf '%s\n' 'SOFTWARES_APT_MONGODB : création du répertoire de configuration impossible.' >&2
            return 1
        fi
        if ! printf 'export SOFTWARES_APT_MONGODB=%q\n' "$default_value" >> "$variable_config_file"; then
            printf '%s\n' 'SOFTWARES_APT_MONGODB : persistance impossible.' >&2
            return 1
        fi
        export SOFTWARES_APT_MONGODB="$default_value"
    elif [[ "$SOFTWARES_APT_MONGODB" =~ ^[01]$ ]]; then
        export SOFTWARES_APT_MONGODB
    else
        printf '%s\n' 'SOFTWARES_APT_MONGODB : valeur invalide, attendu 0 ou 1.' >&2
        return 1
    fi
else
    unset SOFTWARES_APT_MONGODB
    if [[ -f "$variable_config_file" ]]; then
        if ! sed -i '/^[[:blank:]]*export[[:blank:]]\+SOFTWARES_APT_MONGODB=/d' "$variable_config_file"; then
            printf '%s\n' 'SOFTWARES_APT_MONGODB : suppression de la déclaration impossible.' >&2
            return 1
        fi
    fi
fi

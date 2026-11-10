#!/usr/bin/env bash
# shellcheck disable=SC2034

config="STATIC"
state="DISABLE"
scope="softwares"
default_value=0
variable_config_file="/root/diu/config/${scope}.env"

if [[ "$state" == "ENABLE" ]]; then
    if [[ -z "${SOFTWARES_APT_OMADA+x}" ]]; then
        if ! install -d -m 0755 "$(dirname "$variable_config_file")"; then
            printf '%s\n' 'SOFTWARES_APT_OMADA : création du répertoire de configuration impossible.' >&2
            return 1
        fi
        if ! printf 'export SOFTWARES_APT_OMADA=%q\n' "$default_value" >> "$variable_config_file"; then
            printf '%s\n' 'SOFTWARES_APT_OMADA : persistance impossible.' >&2
            return 1
        fi
        export SOFTWARES_APT_OMADA="$default_value"
    elif [[ "$SOFTWARES_APT_OMADA" =~ ^[01]$ ]]; then
        export SOFTWARES_APT_OMADA
    else
        printf '%s\n' 'SOFTWARES_APT_OMADA : valeur invalide, attendu 0 ou 1.' >&2
        return 1
    fi
else
    unset SOFTWARES_APT_OMADA
    if [[ -f "$variable_config_file" ]]; then
        if ! sed -i '/^[[:blank:]]*export[[:blank:]]\+SOFTWARES_APT_OMADA=/d' "$variable_config_file"; then
            printf '%s\n' 'SOFTWARES_APT_OMADA : suppression de la déclaration impossible.' >&2
            return 1
        fi
    fi
fi

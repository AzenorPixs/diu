#!/usr/bin/env bash
# shellcheck disable=SC2034

config="STATIC"
state="ENABLE"
scope="softwares"
default_value=0
variable_config_file="/root/diu/config/${scope}.env"

if [[ "$state" == "ENABLE" ]]; then
    if [[ -z "${SOFTWARES_APT_ZOOM+x}" ]]; then
        if ! install -d -m 0755 "$(dirname "$variable_config_file")"; then
            printf '%s\n' 'SOFTWARES_APT_ZOOM : création du répertoire de configuration impossible.' >&2
            return 1
        fi
        if ! printf 'export SOFTWARES_APT_ZOOM=%q\n' "$default_value" >> "$variable_config_file"; then
            printf '%s\n' 'SOFTWARES_APT_ZOOM : persistance impossible.' >&2
            return 1
        fi
        export SOFTWARES_APT_ZOOM="$default_value"
    elif [[ "$SOFTWARES_APT_ZOOM" =~ ^[01]$ ]]; then
        export SOFTWARES_APT_ZOOM
    else
        printf '%s\n' 'SOFTWARES_APT_ZOOM : valeur invalide, attendu 0 ou 1.' >&2
        return 1
    fi
else
    unset SOFTWARES_APT_ZOOM
    if [[ -f "$variable_config_file" ]]; then
        if ! sed -i '/^[[:blank:]]*export[[:blank:]]\+SOFTWARES_APT_ZOOM=/d' "$variable_config_file"; then
            printf '%s\n' 'SOFTWARES_APT_ZOOM : suppression de la déclaration impossible.' >&2
            return 1
        fi
    fi
fi

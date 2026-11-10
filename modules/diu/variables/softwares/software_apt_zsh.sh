#!/usr/bin/env bash
# shellcheck disable=SC2034

config="STATIC"
state="DISABLE"
scope="softwares"
default_value=0
variable_config_file="/root/diu/config/${scope}.env"

if [[ "$state" == "ENABLE" ]]; then
    if [[ -z "${SOFTWARES_APT_ZSH+x}" ]]; then
        if ! install -d -m 0755 "$(dirname "$variable_config_file")"; then
            printf '%s\n' 'SOFTWARES_APT_ZSH : création du répertoire de configuration impossible.' >&2
            return 1
        fi
        if ! printf 'export SOFTWARES_APT_ZSH=%q\n' "$default_value" >> "$variable_config_file"; then
            printf '%s\n' 'SOFTWARES_APT_ZSH : persistance impossible.' >&2
            return 1
        fi
        export SOFTWARES_APT_ZSH="$default_value"
    elif [[ "$SOFTWARES_APT_ZSH" =~ ^[01]$ ]]; then
        export SOFTWARES_APT_ZSH
    else
        printf '%s\n' 'SOFTWARES_APT_ZSH : valeur invalide, attendu 0 ou 1.' >&2
        return 1
    fi
else
    unset SOFTWARES_APT_ZSH
    if [[ -f "$variable_config_file" ]]; then
        if ! sed -i '/^[[:blank:]]*export[[:blank:]]\+SOFTWARES_APT_ZSH=/d' "$variable_config_file"; then
            printf '%s\n' 'SOFTWARES_APT_ZSH : suppression de la déclaration impossible.' >&2
            return 1
        fi
    fi
fi

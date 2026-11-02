#!/usr/bin/env bash
# Déclare l'activation du profil de bureau.
# shellcheck disable=SC2034

config="STATIC"
state="ENABLE"
scope="desktop"
default_value=0
variable_config_file="/root/diu/config/${scope}.env"

if [[ "$state" == ENABLE ]]; then
    if [[ -z "${DESKTOP+x}" ]]; then
        if ! install -d -m 0755 "$(dirname "$variable_config_file")"; then
            printf '%s\n' 'DESKTOP : création du répertoire de configuration impossible.' >&2
            return 1
        fi
        if ! printf 'export DESKTOP=%q\n' "$default_value" >> "$variable_config_file"; then
            printf '%s\n' 'DESKTOP : persistance impossible.' >&2
            return 1
        fi
        export DESKTOP="$default_value"
    elif [[ "$DESKTOP" =~ ^[01]$ ]]; then
        export DESKTOP
    else
        printf '%s\n' 'DESKTOP : valeur invalide, attendu 0 ou 1.' >&2
        return 1
    fi
else
    unset DESKTOP
    if [[ -f "$variable_config_file" ]]; then
        if ! sed -i '/^[[:blank:]]*export[[:blank:]]\+DESKTOP=/d' "$variable_config_file"; then
            printf '%s\n' 'DESKTOP : suppression de la déclaration impossible.' >&2
            return 1
        fi
    fi
fi

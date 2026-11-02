#!/usr/bin/env bash
# Déclare l'activation du provisionnement de l'environnement IA.
# shellcheck disable=SC2034

config="STATIC"
state="ENABLE"
scope="environnements"
default_value=0
variable_config_file="/root/diu/config/${scope}.env"

if [[ "$state" == ENABLE ]]; then
    if [[ -z "${ENVIRONMENT_IA+x}" ]]; then
        if ! install -d -m 0755 "$(dirname "$variable_config_file")"; then
            printf '%s\n' 'ENVIRONMENT_IA : création du répertoire de configuration impossible.' >&2
            return 1
        fi
        if ! printf 'export ENVIRONMENT_IA=%q\n' "$default_value" >> "$variable_config_file"; then
            printf '%s\n' 'ENVIRONMENT_IA : persistance impossible.' >&2
            return 1
        fi
        export ENVIRONMENT_IA="$default_value"
    elif [[ "$ENVIRONMENT_IA" =~ ^[01]$ ]]; then
        export ENVIRONMENT_IA
    else
        printf '%s\n' 'ENVIRONMENT_IA : valeur invalide, attendu 0 ou 1.' >&2
        return 1
    fi
else
    unset ENVIRONMENT_IA
    if [[ -f "$variable_config_file" ]]; then
        if ! sed -i '/^[[:blank:]]*export[[:blank:]]\+ENVIRONMENT_IA=/d' "$variable_config_file"; then
            printf '%s\n' 'ENVIRONMENT_IA : suppression de la déclaration impossible.' >&2
            return 1
        fi
    fi
fi

#!/usr/bin/env bash
# Déclare l'activation du provisionnement de l'environnement DevOps.
# shellcheck disable=SC2034

config="STATIC"
state="ENABLE"
scope="environnements"
default_value=0
variable_config_file="/root/diu/config/${scope}.env"

if [[ "$state" == ENABLE ]]; then
    if [[ -z "${ENVIRONMENTS_DEVOPS+x}" ]]; then
        if ! install -d -m 0755 "$(dirname "$variable_config_file")"; then
            printf '%s\n' 'ENVIRONMENTS_DEVOPS : création du répertoire de configuration impossible.' >&2
            return 1
        fi
        if ! printf 'export ENVIRONMENTS_DEVOPS=%q\n' "$default_value" >> "$variable_config_file"; then
            printf '%s\n' 'ENVIRONMENTS_DEVOPS : persistance impossible.' >&2
            return 1
        fi
        export ENVIRONMENTS_DEVOPS="$default_value"
    elif [[ "$ENVIRONMENTS_DEVOPS" =~ ^[01]$ ]]; then
        export ENVIRONMENTS_DEVOPS
    else
        printf '%s\n' 'ENVIRONMENTS_DEVOPS : valeur invalide, attendu 0 ou 1.' >&2
        return 1
    fi
else
    unset ENVIRONMENTS_DEVOPS
    if [[ -f "$variable_config_file" ]]; then
        if ! sed -i '/^[[:blank:]]*export[[:blank:]]\+ENVIRONMENTS_DEVOPS=/d' "$variable_config_file"; then
            printf '%s\n' 'ENVIRONMENTS_DEVOPS : suppression de la déclaration impossible.' >&2
            return 1
        fi
    fi
fi

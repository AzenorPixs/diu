#!/usr/bin/env bash
# Déclare le compte utilisé pour l'environnement DevOps.
# shellcheck disable=SC2034

config="STATIC"
state="ENABLE"
scope="environnements"
default_value="root"
variable_config_file="/root/diu/config/${scope}.env"

if [[ "$state" == ENABLE ]]; then
    if [[ -z "${ENV_DEVOPS_USER+x}" ]]; then
        if [[ -n "${DEVOPS_USER+x}" ]]; then
            default_value="$DEVOPS_USER"
        fi
        if ! install -d -m 0755 "$(dirname "$variable_config_file")"; then
            printf '%s\n' 'ENV_DEVOPS_USER : création du répertoire impossible.' >&2
            return 1
        fi
        if ! printf 'export ENV_DEVOPS_USER=%q\n' "$default_value" >> "$variable_config_file"; then
            printf '%s\n' 'ENV_DEVOPS_USER : persistance impossible.' >&2
            return 1
        fi
        export ENV_DEVOPS_USER="$default_value"
    else
        export ENV_DEVOPS_USER
    fi
else
    unset ENV_DEVOPS_USER
    if [[ -f "$variable_config_file" ]]; then
        if ! sed -i '/^[[:blank:]]*export[[:blank:]]\+ENV_DEVOPS_USER=/d' "$variable_config_file"; then
            printf '%s\n' 'ENV_DEVOPS_USER : suppression impossible.' >&2
            return 1
        fi
    fi
fi

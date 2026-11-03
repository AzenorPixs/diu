#!/usr/bin/env bash
# Déclare le chemin statique de la racine des projets DevOps.
# shellcheck disable=SC2034

config="STATIC"
state="ENABLE"
scope="environnements"
default_value=""
variable_config_file="/root/diu/config/${scope}.env"

if [[ "$state" == ENABLE ]]; then
    if [[ -z "${ENV_DEVOPS_PROJECTS_ROOT+x}" ]]; then
        if [[ -n "${DEVOPS_PROJECTS_ROOT+x}" ]]; then
            default_value="$DEVOPS_PROJECTS_ROOT"
        else
            if [[ -z "${ENV_DEVOPS_USER:-}" ]]; then
                printf '%s\n' 'ENV_DEVOPS_PROJECTS_ROOT : ENV_DEVOPS_USER est absent.' >&2
                return 1
            fi
            default_value="/home/${ENV_DEVOPS_USER}/datas"
        fi
        if ! install -d -m 0755 "$(dirname "$variable_config_file")"; then
            printf '%s\n' 'ENV_DEVOPS_PROJECTS_ROOT : création du répertoire impossible.' >&2
            return 1
        fi
        if ! printf 'export ENV_DEVOPS_PROJECTS_ROOT=%q\n' "$default_value" >> "$variable_config_file"; then
            printf '%s\n' 'ENV_DEVOPS_PROJECTS_ROOT : persistance impossible.' >&2
            return 1
        fi
        export ENV_DEVOPS_PROJECTS_ROOT="$default_value"
    else
        export ENV_DEVOPS_PROJECTS_ROOT
    fi
else
    unset ENV_DEVOPS_PROJECTS_ROOT
    if [[ -f "$variable_config_file" ]]; then
        if ! sed -i '/^[[:blank:]]*export[[:blank:]]\+ENV_DEVOPS_PROJECTS_ROOT=/d' "$variable_config_file"; then
            printf '%s\n' 'ENV_DEVOPS_PROJECTS_ROOT : suppression impossible.' >&2
            return 1
        fi
    fi
fi

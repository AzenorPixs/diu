#!/usr/bin/env bash
# Déclare le compte propriétaire des stacks Docker.
# shellcheck disable=SC2034

config="STATIC"
state="ENABLE"
scope="docker"
default_value="docker"
variable_config_file="/root/diu/config/${scope}.env"

if [[ "$state" == ENABLE ]]; then
    if [[ -z "${ENVIRONMENT_DOCKER_USER+x}" ]]; then
        if ! install -d -m 0755 "$(dirname "$variable_config_file")"; then
            printf '%s\n' 'ENVIRONMENT_DOCKER_USER : création du répertoire de configuration impossible.' >&2
            return 1
        fi
        if ! printf 'export ENVIRONMENT_DOCKER_USER=%q\n' "$default_value" >> "$variable_config_file"; then
            printf '%s\n' 'ENVIRONMENT_DOCKER_USER : persistance impossible.' >&2
            return 1
        fi
        export ENVIRONMENT_DOCKER_USER="$default_value"
    elif [[ "$ENVIRONMENT_DOCKER_USER" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
        export ENVIRONMENT_DOCKER_USER
    else
        printf '%s\n' 'ENVIRONMENT_DOCKER_USER : nom de compte invalide.' >&2
        return 1
    fi
else
    unset ENVIRONMENT_DOCKER_USER
    if [[ -f "$variable_config_file" ]]; then
        if ! sed -i '/^[[:blank:]]*export[[:blank:]]\+ENVIRONMENT_DOCKER_USER=/d' "$variable_config_file"; then
            printf '%s\n' 'ENVIRONMENT_DOCKER_USER : suppression de la déclaration impossible.' >&2
            return 1
        fi
    fi
fi

#!/usr/bin/env bash
# shellcheck disable=SC2034

config="STATIC"
state="ENABLE"
scope="docker"
default_value=0
variable_config_file="/root/diu/config/${scope}.env"

if [[ "$state" == "ENABLE" ]]; then
    if [[ -z "${DOCKER_STACK_DEVOPS+x}" ]]; then
        if ! install -d -m 0755 "$(dirname "$variable_config_file")"; then
            printf '%s\n' 'DOCKER_STACK_DEVOPS : création du répertoire de configuration impossible.' >&2
            return 1
        fi
        if ! printf 'export DOCKER_STACK_DEVOPS=%q\n' "$default_value" >> "$variable_config_file"; then
            printf '%s\n' 'DOCKER_STACK_DEVOPS : persistance impossible.' >&2
            return 1
        fi
        export DOCKER_STACK_DEVOPS="$default_value"
    elif [[ "$DOCKER_STACK_DEVOPS" =~ ^[01]$ ]]; then
        export DOCKER_STACK_DEVOPS
    else
        printf '%s\n' 'DOCKER_STACK_DEVOPS : valeur invalide, attendu 0 ou 1.' >&2
        return 1
    fi
else
    unset DOCKER_STACK_DEVOPS
    if [[ -f "$variable_config_file" ]]; then
        if ! sed -i '/^[[:blank:]]*export[[:blank:]]\+DOCKER_STACK_DEVOPS=/d' "$variable_config_file"; then
            printf '%s\n' 'DOCKER_STACK_DEVOPS : suppression de la déclaration impossible.' >&2
            return 1
        fi
    fi
fi

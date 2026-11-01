#!/usr/bin/env bash
# shellcheck disable=SC2034

config="STATIC"
state="ENABLE"
scope="docker"
default_value=0
variable_config_file="/root/diu/config/${scope}.env"

if [[ "$state" == "ENABLE" ]]; then
    if [[ -z "${DOCKER_STACK_TRAEFIK_DOCKHAND+x}" ]]; then
        if ! install -d -m 0755 "$(dirname "$variable_config_file")"; then
            printf '%s\n' 'DOCKER_STACK_TRAEFIK_DOCKHAND : création du répertoire de configuration impossible.' >&2
            return 1
        fi
        if ! printf 'export DOCKER_STACK_TRAEFIK_DOCKHAND=%q\n' "$default_value" >> "$variable_config_file"; then
            printf '%s\n' 'DOCKER_STACK_TRAEFIK_DOCKHAND : persistance impossible.' >&2
            return 1
        fi
        export DOCKER_STACK_TRAEFIK_DOCKHAND="$default_value"
    elif [[ "$DOCKER_STACK_TRAEFIK_DOCKHAND" =~ ^[01]$ ]]; then
        export DOCKER_STACK_TRAEFIK_DOCKHAND
    else
        printf '%s\n' 'DOCKER_STACK_TRAEFIK_DOCKHAND : valeur invalide, attendu 0 ou 1.' >&2
        return 1
    fi
else
    unset DOCKER_STACK_TRAEFIK_DOCKHAND
    if [[ -f "$variable_config_file" ]]; then
        if ! sed -i '/^[[:blank:]]*export[[:blank:]]\+DOCKER_STACK_TRAEFIK_DOCKHAND=/d' "$variable_config_file"; then
            printf '%s\n' 'DOCKER_STACK_TRAEFIK_DOCKHAND : suppression de la déclaration impossible.' >&2
            return 1
        fi
    fi
fi

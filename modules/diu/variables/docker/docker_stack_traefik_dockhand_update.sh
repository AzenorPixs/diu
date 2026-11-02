#!/usr/bin/env bash
# shellcheck disable=SC2034

config="STATIC"
state="ENABLE"
scope="docker"
default_value=0
variable_config_file="/root/diu/config/${scope}.env"

if [[ "$state" == "ENABLE" ]]; then
    if [[ -z "${DOCKER_STACK_TRAEFIK_DOCKHAND_UPDATE+x}" ]]; then
        if ! install -d -m 0755 "$(dirname "$variable_config_file")"; then
            printf '%s\n' 'DOCKER_STACK_TRAEFIK_DOCKHAND_UPDATE : création du répertoire de configuration impossible.' >&2
            return 1
        fi
        if ! printf 'export DOCKER_STACK_TRAEFIK_DOCKHAND_UPDATE=%q\n' "$default_value" >> "$variable_config_file"; then
            printf '%s\n' 'DOCKER_STACK_TRAEFIK_DOCKHAND_UPDATE : persistance impossible.' >&2
            return 1
        fi
        export DOCKER_STACK_TRAEFIK_DOCKHAND_UPDATE="$default_value"
    elif [[ "$DOCKER_STACK_TRAEFIK_DOCKHAND_UPDATE" =~ ^[01]$ ]]; then
        export DOCKER_STACK_TRAEFIK_DOCKHAND_UPDATE
    else
        printf '%s\n' 'DOCKER_STACK_TRAEFIK_DOCKHAND_UPDATE : valeur invalide, attendu 0 ou 1.' >&2
        return 1
    fi
else
    unset DOCKER_STACK_TRAEFIK_DOCKHAND_UPDATE
    if [[ -f "$variable_config_file" ]]; then
        if ! sed -i '/^[[:blank:]]*export[[:blank:]]\+DOCKER_STACK_TRAEFIK_DOCKHAND_UPDATE=/d' "$variable_config_file"; then
            printf '%s\n' 'DOCKER_STACK_TRAEFIK_DOCKHAND_UPDATE : suppression de la déclaration impossible.' >&2
            return 1
        fi
    fi
fi

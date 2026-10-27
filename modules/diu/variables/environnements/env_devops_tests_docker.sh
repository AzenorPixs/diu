#!/usr/bin/env bash
# Variable déclarative : ENV_DEVOPS_TESTS_DOCKER.
# shellcheck disable=SC2034

config="STATIC"
state="ENABLE"
scope="environnements"

# Valeurs prévues : 0 | 1 ; toute valeur existante est conservée.
default_value=0
variable_config_file="/root/diu/config/${scope}.env"

if [[ "$state" == ENABLE ]]; then
    if [[ -z "${ENV_DEVOPS_TESTS_DOCKER+x}" ]]; then
        if ! install -d -m 0755 "$(dirname "$variable_config_file")"; then
            printf '%s\n' 'ENV_DEVOPS_TESTS_DOCKER : création du répertoire de configuration impossible.' >&2
            return 1
        fi
        if ! printf '        export ENV_DEVOPS_TESTS_DOCKER=%s\n' "$default_value" >> "$variable_config_file"; then
            printf '%s\n' 'ENV_DEVOPS_TESTS_DOCKER : persistance impossible.' >&2
            return 1
        fi
        export ENV_DEVOPS_TESTS_DOCKER="$default_value"
    else
        export ENV_DEVOPS_TESTS_DOCKER
    fi
else
    unset ENV_DEVOPS_TESTS_DOCKER
    if [[ -f "$variable_config_file" ]]; then
        if ! sed -i '/^[[:blank:]]*export ENV_DEVOPS_TESTS_DOCKER=/d' "$variable_config_file"; then
            printf '%s\n' 'ENV_DEVOPS_TESTS_DOCKER : suppression de la déclaration impossible.' >&2
            return 1
        fi
    fi
fi

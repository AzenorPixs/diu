#!/usr/bin/env bash
# Variable déclarative : ENV_DEVOPS_TESTS_LXC.
# shellcheck disable=SC2034

config="STATIC"
state="ENABLE"
scope="environnements"

# Valeurs prévues : 0 | 1 ; toute valeur existante est conservée.
default_value=0
variable_config_file="/root/diu/config/${scope}.env"

if [[ "$state" == ENABLE ]]; then
    if [[ -z "${ENV_DEVOPS_TESTS_LXC+x}" ]]; then
        if ! install -d -m 0755 "$(dirname "$variable_config_file")"; then
            printf '%s\n' 'ENV_DEVOPS_TESTS_LXC : création du répertoire de configuration impossible.' >&2
            return 1
        fi
        if ! printf '        export ENV_DEVOPS_TESTS_LXC=%s\n' "$default_value" >> "$variable_config_file"; then
            printf '%s\n' 'ENV_DEVOPS_TESTS_LXC : persistance impossible.' >&2
            return 1
        fi
        export ENV_DEVOPS_TESTS_LXC="$default_value"
    else
        export ENV_DEVOPS_TESTS_LXC
    fi
else
    unset ENV_DEVOPS_TESTS_LXC
    if [[ -f "$variable_config_file" ]]; then
        if ! sed -i '/^[[:blank:]]*export ENV_DEVOPS_TESTS_LXC=/d' "$variable_config_file"; then
            printf '%s\n' 'ENV_DEVOPS_TESTS_LXC : suppression de la déclaration impossible.' >&2
            return 1
        fi
    fi
fi

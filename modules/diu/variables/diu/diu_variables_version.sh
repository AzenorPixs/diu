#!/usr/bin/env bash
# Déclare la version du paquet DIU comme version des variables.
# shellcheck disable=SC2034

config="DYNAMIC"
state="ENABLE"
scope="diu"
default_value=""
variable_config_file="/root/diu/config/${scope}.env"

variable_generator() {
    local version
    if ! command -v dpkg-query > /dev/null 2>&1; then
        printf '%s\n' 'DIU_VARIABLES_VERSION : commande dpkg-query indisponible.' >&2
        return 1
    fi
    if ! version="$(dpkg-query -W -f='${Version}' diu 2>/dev/null)" ||
        [[ -z "$version" ]]; then
        printf '%s\n' 'DIU_VARIABLES_VERSION : version du paquet diu installé indisponible.' >&2
        return 1
    fi
    printf '%s\n' "$version"
}

if [[ "$state" == ENABLE ]]; then
    if [[ -z "${DIU_VARIABLES_VERSION+x}" ]]; then
        if ! DIU_VARIABLES_VERSION="$(variable_generator)"; then
            unset DIU_VARIABLES_VERSION
            return 1
        fi
        export DIU_VARIABLES_VERSION
    else
        export DIU_VARIABLES_VERSION
    fi
else
    unset DIU_VARIABLES_VERSION
    if [[ -f "$variable_config_file" ]]; then
        if ! sed -i '/^[[:blank:]]*export[[:blank:]]\+DIU_VARIABLES_VERSION=/d' "$variable_config_file"; then
            printf '%s\n' 'DIU_VARIABLES_VERSION : suppression de la déclaration impossible.' >&2
            return 1
        fi
    fi
fi

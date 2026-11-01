#!/usr/bin/env bash
# shellcheck disable=SC2034

config="STATIC"
state="ENABLE"
scope="system"
default_value=0
variable_config_file="/root/diu/config/${scope}.env"

if [[ "$state" == "ENABLE" ]]; then
    if [[ -z "${SYSTEM_CROWDSEC_AGENT+x}" ]]; then
        if ! install -d -m 0755 "$(dirname "$variable_config_file")"; then
            printf '%s\n' 'SYSTEM_CROWDSEC_AGENT : création du répertoire de configuration impossible.' >&2
            return 1
        fi
        if ! printf 'export SYSTEM_CROWDSEC_AGENT=%q\n' "$default_value" >> "$variable_config_file"; then
            printf '%s\n' 'SYSTEM_CROWDSEC_AGENT : persistance impossible.' >&2
            return 1
        fi
        export SYSTEM_CROWDSEC_AGENT="$default_value"
    elif [[ "$SYSTEM_CROWDSEC_AGENT" =~ ^[01]$ ]]; then
        export SYSTEM_CROWDSEC_AGENT
    else
        printf '%s\n' 'SYSTEM_CROWDSEC_AGENT : valeur invalide, attendu 0 ou 1.' >&2
        return 1
    fi
else
    unset SYSTEM_CROWDSEC_AGENT
    if [[ -f "$variable_config_file" ]]; then
        if ! sed -i '/^[[:blank:]]*export[[:blank:]]\+SYSTEM_CROWDSEC_AGENT=/d' "$variable_config_file"; then
            printf '%s\n' 'SYSTEM_CROWDSEC_AGENT : suppression de la déclaration impossible.' >&2
            return 1
        fi
    fi
fi

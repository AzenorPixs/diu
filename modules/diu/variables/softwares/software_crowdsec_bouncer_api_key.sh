#!/usr/bin/env bash
# Déclare la clé locale du bouncer CrowdSec sans en exposer la valeur.
# shellcheck disable=SC2034

config="STATIC"
state="DISABLE"
scope="softwares"
default_value=""
variable_config_file="/root/diu/config/${scope}.env"

if [[ "$state" == ENABLE ]]; then
    if [[ -z "${SOFTWARES_CROWDSEC_BOUNCER_API_KEY+x}" ]]; then
        if ! install -d -m 0755 "$(dirname "$variable_config_file")"; then
            printf '%s\n' 'SOFTWARES_CROWDSEC_BOUNCER_API_KEY : création du répertoire de configuration impossible.' >&2
            return 1
        fi
        if [[ -e "$variable_config_file" ]]; then
            if ! chmod 0600 "$variable_config_file"; then
                printf '%s\n' 'SOFTWARES_CROWDSEC_BOUNCER_API_KEY : sécurisation de la configuration impossible.' >&2
                return 1
            fi
        fi
        if ! printf 'export SOFTWARES_CROWDSEC_BOUNCER_API_KEY=%q\n' "$default_value" >> "$variable_config_file"; then
            printf '%s\n' 'SOFTWARES_CROWDSEC_BOUNCER_API_KEY : persistance impossible.' >&2
            return 1
        fi
        export SOFTWARES_CROWDSEC_BOUNCER_API_KEY="$default_value"
    else
        export SOFTWARES_CROWDSEC_BOUNCER_API_KEY
    fi
    if [[ ! "$SOFTWARES_CROWDSEC_BOUNCER_API_KEY" =~ ^[[:alnum:]_./:+@=-]*$ ]]; then
        printf '%s\n' 'SOFTWARES_CROWDSEC_BOUNCER_API_KEY : format invalide.' >&2
        return 1
    fi
    if [[ -n "$SOFTWARES_CROWDSEC_BOUNCER_API_KEY" && -f "$variable_config_file" ]]; then
        if ! chmod 0600 "$variable_config_file"; then
            printf '%s\n' 'SOFTWARES_CROWDSEC_BOUNCER_API_KEY : sécurisation de la configuration impossible.' >&2
            return 1
        fi
    fi
else
    unset SOFTWARES_CROWDSEC_BOUNCER_API_KEY
    if [[ -f "$variable_config_file" ]]; then
        if ! sed -i '/^[[:blank:]]*export[[:blank:]]\+SOFTWARES_CROWDSEC_BOUNCER_API_KEY=/d' "$variable_config_file"; then
            printf '%s\n' 'SOFTWARES_CROWDSEC_BOUNCER_API_KEY : suppression de la déclaration impossible.' >&2
            return 1
        fi
    fi
fi

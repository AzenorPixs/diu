#!/usr/bin/env bash
# shellcheck disable=SC2034

config="STATIC"
state="ENABLE"
scope="softwares"
default_value=0
variable_config_file="/root/diu/config/${scope}.env"

if [[ "$state" == "ENABLE" ]]; then
    if [[ -z "${SOFTWARES_APT_WAZUH_AGENT+x}" ]]; then
        if ! install -d -m 0755 "$(dirname "$variable_config_file")"; then
            printf '%s\n' 'SOFTWARES_APT_WAZUH_AGENT : création du répertoire de configuration impossible.' >&2
            return 1
        fi
        if ! printf 'export SOFTWARES_APT_WAZUH_AGENT=%q\n' "$default_value" >> "$variable_config_file"; then
            printf '%s\n' 'SOFTWARES_APT_WAZUH_AGENT : persistance impossible.' >&2
            return 1
        fi
        export SOFTWARES_APT_WAZUH_AGENT="$default_value"
    elif [[ "$SOFTWARES_APT_WAZUH_AGENT" =~ ^[01]$ ]]; then
        export SOFTWARES_APT_WAZUH_AGENT
    else
        printf '%s\n' 'SOFTWARES_APT_WAZUH_AGENT : valeur invalide, attendu 0 ou 1.' >&2
        return 1
    fi
else
    unset SOFTWARES_APT_WAZUH_AGENT
    if [[ -f "$variable_config_file" ]]; then
        if ! sed -i '/^[[:blank:]]*export[[:blank:]]\+SOFTWARES_APT_WAZUH_AGENT=/d' "$variable_config_file"; then
            printf '%s\n' 'SOFTWARES_APT_WAZUH_AGENT : suppression de la déclaration impossible.' >&2
            return 1
        fi
    fi
fi

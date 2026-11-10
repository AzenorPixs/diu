#!/usr/bin/env bash
# shellcheck disable=SC2034

config="STATIC"
state="DISABLE"
scope="softwares"
default_value=0
variable_config_file="/root/diu/config/${scope}.env"

if [[ "$state" == "ENABLE" ]]; then
    if [[ -z "${SOFTWARES_APT_WAZUH_SERVER+x}" ]]; then
        if ! install -d -m 0755 "$(dirname "$variable_config_file")"; then
            printf '%s\n' 'SOFTWARES_APT_WAZUH_SERVER : création du répertoire de configuration impossible.' >&2
            return 1
        fi
        if ! printf 'export SOFTWARES_APT_WAZUH_SERVER=%q\n' "$default_value" >> "$variable_config_file"; then
            printf '%s\n' 'SOFTWARES_APT_WAZUH_SERVER : persistance impossible.' >&2
            return 1
        fi
        export SOFTWARES_APT_WAZUH_SERVER="$default_value"
    elif [[ "$SOFTWARES_APT_WAZUH_SERVER" =~ ^[01]$ ]]; then
        export SOFTWARES_APT_WAZUH_SERVER
    else
        printf '%s\n' 'SOFTWARES_APT_WAZUH_SERVER : valeur invalide, attendu 0 ou 1.' >&2
        return 1
    fi
else
    unset SOFTWARES_APT_WAZUH_SERVER
    if [[ -f "$variable_config_file" ]]; then
        if ! sed -i '/^[[:blank:]]*export[[:blank:]]\+SOFTWARES_APT_WAZUH_SERVER=/d' "$variable_config_file"; then
            printf '%s\n' 'SOFTWARES_APT_WAZUH_SERVER : suppression de la déclaration impossible.' >&2
            return 1
        fi
    fi
fi

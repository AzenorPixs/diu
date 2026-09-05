#!/usr/bin/env bash
# shellcheck disable=SC2034

# Configuration déclarative de l'intégration ChatGPT Desktop.
config="DYNAMIC"
state="ENABLE"
scope="softwares"
default_value=0
default_home="~""/.codex"
variable_config_file="/root/diu/config/${scope}.env"

software_apt_chatgpt_detect() {
    if dpkg-query -W -f='${db:Status-Status}' chatgpt 2>/dev/null | grep -qx installed; then
        printf '1'
    else
        printf '%s' "$default_value"
    fi
}

if [[ "$state" == ENABLE ]]; then
    detected_value="$(software_apt_chatgpt_detect)"
    export SOFTWARES_APT_CHATGPT="$detected_value"
    if [[ -z "${SOFTWARES_APT_CHATGPT_HOME+x}" ]]; then
        export SOFTWARES_APT_CHATGPT_HOME="$default_home"
        if [[ -d "$(dirname "$variable_config_file")" &&
              ( ! -e "$variable_config_file" || -w "$variable_config_file" ) &&
              -w "$(dirname "$variable_config_file")" ]]; then
            printf 'export SOFTWARES_APT_CHATGPT_HOME=%q\n' "$SOFTWARES_APT_CHATGPT_HOME" >> "$variable_config_file"
        fi
    fi
else
    unset SOFTWARES_APT_CHATGPT SOFTWARES_APT_CHATGPT_HOME
    if [[ -f "$variable_config_file" ]]; then
        sed -i '/^export SOFTWARES_APT_CHATGPT=/d; /^export SOFTWARES_APT_CHATGPT_HOME=/d' "$variable_config_file"
    fi
fi

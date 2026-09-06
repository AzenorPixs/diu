#!/usr/bin/env bash
# shellcheck disable=SC2034

# Configuration déclarative de l'intégration ChatGPT Desktop.
config="STATIC"
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

software_apt_chatgpt_persist() {
    local home_value="${SOFTWARES_APT_CHATGPT_HOME:-$default_home}"
    local config_directory
    config_directory="$(dirname "$variable_config_file")"
    [[ -d "$config_directory" && -w "$config_directory" ]] || return 0
    [[ ! -e "$variable_config_file" || -w "$variable_config_file" ]] || return 0

    if [[ -f "$variable_config_file" ]]; then
        sed -i '/^export SOFTWARES_APT_CHATGPT=/d; /^export SOFTWARES_APT_CHATGPT_HOME=/d' \
            "$variable_config_file"
    fi
    printf 'export SOFTWARES_APT_CHATGPT=%s\n' "$SOFTWARES_APT_CHATGPT" >> "$variable_config_file"
    if [[ "$home_value" == "$default_home" ]]; then
        printf 'export SOFTWARES_APT_CHATGPT_HOME=~/.codex\n' >> "$variable_config_file"
    else
        printf 'export SOFTWARES_APT_CHATGPT_HOME=%q\n' "$home_value" >> "$variable_config_file"
    fi
}

if [[ "$state" == ENABLE ]]; then
    if [[ -z "${SOFTWARES_APT_CHATGPT+x}" ]]; then
        detected_value="$(software_apt_chatgpt_detect)"
        export SOFTWARES_APT_CHATGPT="$detected_value"
    fi
    if [[ -z "${SOFTWARES_APT_CHATGPT_HOME+x}" ]]; then
        export SOFTWARES_APT_CHATGPT_HOME="$default_home"
    fi
    while [[ "${SOFTWARES_APT_CHATGPT_HOME:-}" == \\~/* ]]; do
        export SOFTWARES_APT_CHATGPT_HOME="${SOFTWARES_APT_CHATGPT_HOME:1}"
    done
    if [[ "${SOFTWARES_APT_CHATGPT_HOME:-}" == "${HOME:-}/.codex" ]]; then
        export SOFTWARES_APT_CHATGPT_HOME="$default_home"
    fi
    software_apt_chatgpt_persist
else
    unset SOFTWARES_APT_CHATGPT SOFTWARES_APT_CHATGPT_HOME
    if [[ -f "$variable_config_file" ]]; then
        sed -i '/^export SOFTWARES_APT_CHATGPT=/d; /^export SOFTWARES_APT_CHATGPT_HOME=/d' "$variable_config_file"
    fi
fi

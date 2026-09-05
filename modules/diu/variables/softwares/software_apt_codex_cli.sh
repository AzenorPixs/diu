#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2088,SC2155

config="STATIC"
state="ENABLE"
scope="softwares"
default_value=0
default_home="~/.codex"
variable_config_file="/root/diu/config/${scope}.env"

software_apt_codex_cli_detect() {
    if command -v codex >/dev/null 2>&1 && [[ -x "$(command -v codex)" ]]; then
        printf '1'
    else
        printf '%s' "$default_value"
    fi
}

software_apt_codex_cli_persist() {
    local home_value="${SOFTWARES_APT_CODEX_CLI_HOME:-$default_home}"
    local config_directory
    config_directory="$(dirname "$variable_config_file")"
    [[ -d "$config_directory" && -w "$config_directory" ]] || return 0
    [[ ! -e "$variable_config_file" || -w "$variable_config_file" ]] || return 0

    if [[ -f "$variable_config_file" ]]; then
        sed -i '/^export SOFTWARES_APT_CODEX_CLI=/d; /^export SOFTWARES_APT_CODEX_CLI_HOME=/d' \
            "$variable_config_file"
    fi
    printf 'export SOFTWARES_APT_CODEX_CLI=%s\n' "$SOFTWARES_APT_CODEX_CLI" >> "$variable_config_file"
    if [[ "$home_value" == "$default_home" ]]; then
        printf 'export SOFTWARES_APT_CODEX_CLI_HOME=~/.codex\n' >> "$variable_config_file"
    else
        printf 'export SOFTWARES_APT_CODEX_CLI_HOME=%q\n' "$home_value" >> "$variable_config_file"
    fi
}

if [[ "$state" == ENABLE ]]; then
    if [[ -z "${SOFTWARES_APT_CODEX_CLI+x}" ]]; then
        export SOFTWARES_APT_CODEX_CLI="$(software_apt_codex_cli_detect)"
    fi
    if [[ -z "${SOFTWARES_APT_CODEX_CLI_HOME+x}" ]]; then
        export SOFTWARES_APT_CODEX_CLI_HOME="$default_home"
    fi
    software_apt_codex_cli_persist
else
    unset SOFTWARES_APT_CODEX_CLI SOFTWARES_APT_CODEX_CLI_HOME
    if [[ -f "$variable_config_file" ]]; then
        sed -i '/^export SOFTWARES_APT_CODEX_CLI=/d; /^export SOFTWARES_APT_CODEX_CLI_HOME=/d' \
            "$variable_config_file"
    fi
fi

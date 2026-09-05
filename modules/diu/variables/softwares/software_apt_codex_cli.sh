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

if [[ "$state" == ENABLE ]]; then
    if [[ -z "${SOFTWARES_APT_CODEX_CLI+x}" ]]; then
        export SOFTWARES_APT_CODEX_CLI="$(software_apt_codex_cli_detect)"
    fi
    if [[ -z "${SOFTWARES_APT_CODEX_CLI_HOME+x}" ]]; then
        export SOFTWARES_APT_CODEX_CLI_HOME="$default_home"
    fi
else
    unset SOFTWARES_APT_CODEX_CLI SOFTWARES_APT_CODEX_CLI_HOME
fi

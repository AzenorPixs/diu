#!/usr/bin/env bash
# shellcheck disable=SC2034
config="STATIC"
state="ENABLE"
scope="system"
variable_config_file="/root/diu/config/${scope}.env"
if [[ -z "${SYSTEM_GITHUB_ENGINE+x}" ]]; then
    default_value=0
    if command -v curl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1 && command -v tar >/dev/null 2>&1 && command -v gzip >/dev/null 2>&1 && command -v sha256sum >/dev/null 2>&1; then default_value=1; fi
    export SYSTEM_GITHUB_ENGINE="$default_value"
    install -d -m 0755 "$(dirname "$variable_config_file")" || return 1
    printf 'export SYSTEM_GITHUB_ENGINE=%s\n' "$SYSTEM_GITHUB_ENGINE" >> "$variable_config_file" || return 1
fi
if [[ ! "$SYSTEM_GITHUB_ENGINE" =~ ^(0|1)$ ]]; then
    printf '%s\n' 'SYSTEM_GITHUB_ENGINE : valeur invalide.' >&2
    return 1
fi

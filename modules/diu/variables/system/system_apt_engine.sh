#!/usr/bin/env bash
# shellcheck disable=SC2034
config="STATIC"
state="ENABLE"
scope="system"
variable_config_file="/root/diu/config/${scope}.env"
if [[ -z "${SYSTEM_APT_ENGINE+x}" ]]; then
    default_value=1
    export SYSTEM_APT_ENGINE="$default_value"
    install -d -m 0755 "$(dirname "$variable_config_file")" || return 1
    printf 'export SYSTEM_APT_ENGINE=%s\n' "$SYSTEM_APT_ENGINE" >> "$variable_config_file" || return 1
fi
if [[ ! "$SYSTEM_APT_ENGINE" =~ ^(0|1)$ ]]; then
    printf '%s\n' 'SYSTEM_APT_ENGINE : valeur invalide.' >&2
    return 1
fi

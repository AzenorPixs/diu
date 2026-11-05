#!/usr/bin/env bash
# Variable déclarative : SYSTEM_FLATPAK_ENGINE.
# shellcheck disable=SC2034

config="STATIC"
state="ENABLE"
scope="system"
variable_config_file="/root/diu/config/${scope}.env"

system_flatpak_detect() {
    local status result

    if ! command -v dpkg-query >/dev/null 2>&1; then
        printf '%s' UNSET
        return 0
    fi

    result=0
    status="$(dpkg-query -W -f='${db:Status-Status}' flatpak 2>/dev/null)" || result=$?
    if [[ "$result" -eq 0 ]]; then
        [[ "$status" == installed ]] && printf '%s' 1 || printf '%s' 0
        return 0
    fi
    [[ "$result" -eq 1 ]] && printf '%s' 0 || printf '%s' UNSET
}

if [[ "$state" == ENABLE ]]; then
    if [[ -z "${SYSTEM_FLATPAK_ENGINE+x}" ]]; then
        if [[ -n "${SYSTEM_FLATPAK+x}" ]]; then
            default_value="$SYSTEM_FLATPAK"
        else
            default_value="$(system_flatpak_detect)"
        fi
        if [[ ! "$default_value" =~ ^(0|1|UNSET)$ ]]; then
            printf '%s\n' 'SYSTEM_FLATPAK : valeur historique invalide.' >&2
            return 1
        fi
        export SYSTEM_FLATPAK_ENGINE="$default_value"
        install -d -m 0755 "$(dirname "$variable_config_file")" || return 1
        printf 'export SYSTEM_FLATPAK_ENGINE=%s\n' "$SYSTEM_FLATPAK_ENGINE" >> "$variable_config_file" || return 1
    fi

    if [[ ! "$SYSTEM_FLATPAK_ENGINE" =~ ^(0|1|UNSET)$ ]]; then
        printf '%s\n' "SYSTEM_FLATPAK_ENGINE : valeur invalide : $SYSTEM_FLATPAK_ENGINE" >&2
        return 1
    fi
else
    unset SYSTEM_FLATPAK_ENGINE
    [[ -f "$variable_config_file" ]] && sed -i '/^export SYSTEM_FLATPAK_ENGINE=/d' "$variable_config_file"
fi

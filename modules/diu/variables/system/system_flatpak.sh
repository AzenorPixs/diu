#!/usr/bin/env bash
# Variable déclarative : SYSTEM_FLATPAK.
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
    if [[ -z "${SYSTEM_FLATPAK+x}" ]]; then
        default_value="$(system_flatpak_detect)"
        export SYSTEM_FLATPAK="$default_value"
        install -d -m 0755 "$(dirname "$variable_config_file")"
        printf 'export SYSTEM_FLATPAK=%s\n' "$SYSTEM_FLATPAK" >> "$variable_config_file"
    fi

    if [[ ! "$SYSTEM_FLATPAK" =~ ^(0|1|UNSET)$ ]]; then
        printf '%s\n' "SYSTEM_FLATPAK : valeur invalide : $SYSTEM_FLATPAK" >&2
        return 1
    fi
else
    unset SYSTEM_FLATPAK
    [[ -f "$variable_config_file" ]] && sed -i '/^export SYSTEM_FLATPAK=/d' "$variable_config_file"
fi

#!/usr/bin/env bash
# shellcheck disable=SC2034

config="STATIC"
state="ENABLE"
scope="system"
default_value=1
variable_config_file="/root/diu/config/${scope}.env"

if [[ "${state}" == "ENABLE" ]]; then
    if [[ -z "${SYSTEM_APT_DEBIAN_BACKPORT+x}" ]]; then
        export SYSTEM_APT_DEBIAN_BACKPORT="${default_value}"
        printf '%s\n' "export SYSTEM_APT_DEBIAN_BACKPORT=${default_value}" >> "${variable_config_file}"
    fi
else
    unset SYSTEM_APT_DEBIAN_BACKPORT
    [[ -f "${variable_config_file}" ]] && sed -i '/^export SYSTEM_APT_DEBIAN_BACKPORT=/d' "${variable_config_file}"
fi

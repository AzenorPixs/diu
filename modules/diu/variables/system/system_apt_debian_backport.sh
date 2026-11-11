#!/usr/bin/env bash
# shellcheck disable=SC2034
config="STATIC"
state="ENABLE"
scope="system"
default_value=0
variable_config_file="/root/diu/config/${scope}.env"

if [[ "$state" == ENABLE ]]; then
    system_apt_repository_declare "$variable_config_file" SYSTEM_APT_DEBIAN_BACKPORT || return 1
else
    unset SYSTEM_APT_DEBIAN_BACKPORT
    if [[ -f "$variable_config_file" ]]; then
        sed -i '/^export SYSTEM_APT_DEBIAN_BACKPORT=/d' "$variable_config_file" || return 1
    fi
fi

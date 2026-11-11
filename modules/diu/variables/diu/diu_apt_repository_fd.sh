#!/usr/bin/env bash
# shellcheck disable=SC2034
config="STATIC"
state="ENABLE"
scope="diu"
default_value=0
variable_config_file="/root/diu/config/${scope}.env"
if [[ "$state" == ENABLE ]]; then
    system_apt_repository_declare "$variable_config_file" DIU_APT_REPOSITORY_FD || return 1
else
    unset DIU_APT_REPOSITORY_FD
    if [[ -f "$variable_config_file" ]]; then
        sed -i '/^export DIU_APT_REPOSITORY_FD=/d' "$variable_config_file" || return 1
    fi
fi

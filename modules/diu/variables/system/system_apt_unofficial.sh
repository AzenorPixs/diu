#!/usr/bin/env bash
# Initialisation unique des dépôts tiers depuis leurs sources actives.
# shellcheck disable=SC2034
config="STATIC"
state="ENABLE"
scope="system"
variable_config_file="/root/diu/config/${scope}.env"

system_apt_unofficial_detect() { system_apt_source_state "$1"; }
system_apt_unofficial_declare() { system_apt_repository_declare "$variable_config_file" "$1"; }

system_apt_unofficial_declare SYSTEM_APT_DOCKER || return 1
system_apt_unofficial_declare SYSTEM_APT_LEMONLDAP || return 1
system_apt_unofficial_declare SYSTEM_APT_MONGODB || return 1
system_apt_unofficial_declare SYSTEM_APT_NODEJS || return 1
system_apt_unofficial_declare SYSTEM_APT_NVIDIA || return 1
system_apt_unofficial_declare SYSTEM_APT_PROXMOX || return 1
system_apt_unofficial_declare SYSTEM_APT_VSCODE || return 1
system_apt_unofficial_declare SYSTEM_APT_WAZUH || return 1
system_apt_unofficial_declare SYSTEM_APT_WEBMIN || return 1
system_apt_unofficial_declare SYSTEM_APT_CGPT || return 1

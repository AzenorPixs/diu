#!/usr/bin/env bash
# shellcheck disable=SC2034
config="DYNAMIC"
state="ENABLE"
scope="softwares"
variable_config_file="/root/diu/config/${scope}.env"
software_github_declare_desired "$variable_config_file" codex-cli

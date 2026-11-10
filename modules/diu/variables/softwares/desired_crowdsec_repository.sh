#!/usr/bin/env bash
# shellcheck disable=SC2034
config="DYNAMIC"
state="ENABLE"
scope="softwares"
variable_config_file="/root/diu/config/${scope}.env"
software_declare_crowdsec_repository "$variable_config_file"

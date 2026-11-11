#!/usr/bin/env bash

software_apt_syslog_helper() {
    local helper
    helper="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/syslog_configuration.py" || return 1
    python3 "$helper" "$@"
}


software_apt_syslog_service_check() {
    local service="${1:-}" status
    if service "$service" status >/dev/null 2>&1; then return 0; else
        status=$?; [[ "$status" == 1 || "$status" == 3 ]] && return 1; return 2
    fi
}

software_apt_syslog_check_configuration() {
    local role="${1:-}" status
    if software_apt_syslog_helper check "$role" keep-package; then :; else
        status=$?; [[ "$status" == 1 ]] && return 1; return 2
    fi
    software_apt_syslog_service_check rsyslog || return $?
    software_apt_syslog_service_check ulogd2
}


software_apt_disable_syslog_role() {
    local role="${1:-}" mode=keep-package
    [[ "${software_remove_packages_present:-0}" == 1 ]] && mode=remove-package
    software_apt_syslog_helper remove "$role" "$mode"
}


software_apt_syslog_remove_packages() {
    local role="${1:-}" other_variable detector needed
    case "$role" in
        syslog-client) other_variable=SOFTWARE_APT_SYSLOG_SERVER; detector=software_apt_syslog_server_detect ;;
        syslog-server) other_variable=SOFTWARE_APT_SYSLOG_CLIENT; detector=software_apt_syslog_client_detect ;;
        *) return 2 ;;
    esac
    needed="$(software_shared_resource_needed "${software_management_config:-}" "$other_variable" "$detector")" || return 1
    [[ "$needed" == 0 ]] && printf 'rsyslog\n'
    return 0
}


# Les détecteurs et hooks propres aux logiciels appartiennent aux déclarations GLOBAL.
# shellcheck disable=SC1091 source=modules/softwares/apt-recipes.sh
. "$(dirname -- "${BASH_SOURCE[0]}")/apt-recipes.sh"
software_apt_load_recipes || return 1

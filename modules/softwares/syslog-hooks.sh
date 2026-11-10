#!/usr/bin/env bash

software_apt_syslog_helper() {
    local helper
    helper="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/syslog_configuration.py" || return 1
    python3 "$helper" "$@"
}

software_apt_preflight_syslog_client() { software_apt_syslog_helper preflight client keep-package; }
software_apt_preflight_syslog_server() { software_apt_syslog_helper preflight server keep-package; }
software_apt_configure_syslog_client() { software_apt_syslog_helper configure client keep-package; }
software_apt_configure_syslog_server() { software_apt_syslog_helper configure server keep-package; }

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

software_apt_check_syslog_client_configuration() { software_apt_syslog_check_configuration client; }
software_apt_check_syslog_server_configuration() { software_apt_syslog_check_configuration server; }

software_apt_disable_syslog_role() {
    local role="${1:-}" mode=keep-package
    [[ "${software_remove_packages_present:-0}" == 1 ]] && mode=remove-package
    software_apt_syslog_helper remove "$role" "$mode"
}

software_apt_disable_syslog_client() { software_apt_disable_syslog_role client; }
software_apt_disable_syslog_server() { software_apt_disable_syslog_role server; }

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


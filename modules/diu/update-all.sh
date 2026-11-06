#!/usr/bin/env bash

update_all() {
    local diu_status=0 system_status=0 projects_status=0

    diu_update || diu_status=$?
    system_update || system_status=$?
    environments_update
    ia_update
    projects_update || projects_status=$?

    if [[ "${projects_status}" -ne 0 ]]; then
        return "${projects_status}"
    fi
    if [[ "${diu_status}" -ne 0 ]]; then
        return "${diu_status}"
    fi
    if [[ "${system_status}" -ne 0 ]]; then
        return "${system_status}"
    fi
    return 0
}

manage_update_action() {
    if [[ $# -eq 0 ]]; then
        update_all
    elif [[ "$1" == diu && $# -eq 1 ]]; then
        diu_update
    else
        manage_software_action update "$@"
    fi
}

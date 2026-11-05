#!/usr/bin/env bash

update_all() {
    local diu_status=0 projects_status=0 softwares_status=0

    diu_update || diu_status=$?
    DIU_UPDATE_DEFER_SOFTWARES=1 system_update
    environments_update
    ia_update
    projects_update || projects_status=$?
    softwares_update || softwares_status=$?

    if [[ "${projects_status}" -ne 0 ]]; then
        return "${projects_status}"
    fi
    if [[ "${diu_status}" -ne 0 ]]; then
        return "${diu_status}"
    fi
    return "${softwares_status}"
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

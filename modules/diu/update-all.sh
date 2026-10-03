#!/usr/bin/env bash

update_all() {
    local projects_status=0 softwares_status=0

    system_update
    diu_update
    environments_update
    ia_update
    projects_update || projects_status=$?
    softwares_update || softwares_status=$?

    if [[ "${projects_status}" -ne 0 ]]; then
        return "${projects_status}"
    fi
    return "${softwares_status}"
}

manage_update_action() {
    if [[ $# -eq 0 ]]; then
        update_all
    elif [[ "$1" == diu && $# -eq 1 ]]; then
        update_diu
    else
        manage_software_action update "$@"
    fi
}

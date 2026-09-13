#!/usr/bin/env bash

update_all() {
    system_update
    diu_update
    environments_update
    ia_update
    projects_update
    softwares_update
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

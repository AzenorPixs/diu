#!/usr/bin/env bash

diu_update_playlist() {
    local diu_status=0 system_status=0 environments_status=0 ia_status=0 projects_status=0 softwares_status=0
    diu_update || diu_status=$?
    system_update || system_status=$?
    environments_update || environments_status=$?
    ia_update || ia_status=$?
    projects_update || projects_status=$?
    softwares_update || softwares_status=$?
    if [[ "$projects_status" -ne 0 ]]; then return "$projects_status"; fi
    if [[ "$diu_status" -ne 0 ]]; then return "$diu_status"; fi
    if [[ "$system_status" -ne 0 ]]; then return "$system_status"; fi
    if [[ "$environments_status" -ne 0 ]]; then return "$environments_status"; fi
    if [[ "$ia_status" -ne 0 ]]; then return "$ia_status"; fi
    if [[ "$softwares_status" -ne 0 ]]; then return "$softwares_status"; fi
    return 0
}

#!/usr/bin/env bash

diu_infos() {
    printf '\n%s\n' 'DIU'
    diu_version
}

infos() {
    local function status=0
    for function in desktop_infos diu_infos environments_infos ia_infos projects_infos softwares_infos system_info; do
        "$function" || status=1
    done
    return "$status"
}

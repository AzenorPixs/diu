#!/usr/bin/env bash

proj_find_sync() {
    local project_id="${1:-}"
    local project_dir="/home/devops/datas/${project_id}"

    if [[ -z "${project_id}" ]]; then
        echo "Usage : proj_find_sync <PROJECT_ID>" >&2
        return 1
    fi

    if [[ ! -d "${project_dir}" ]]; then
        echo "Erreur : le projet n'existe pas : ${project_dir}" >&2
        return 1
    fi

    find "${project_dir}" -type f -name '*sync-conflict*'
}

proj_find_and_delete_sync() {
    local project_id="${1:-}"
    local project_dir="/home/devops/datas/${project_id}"

    if [[ -z "${project_id}" ]]; then
        echo "Usage : proj_find_and_delete_sync <PROJECT_ID>" >&2
        return 1
    fi

    if [[ ! -d "${project_dir}" ]]; then
        echo "Erreur : le projet n'existe pas : ${project_dir}" >&2
        return 1
    fi

    find "${project_dir}" -type f -name '*sync-conflict*' -print -delete
}

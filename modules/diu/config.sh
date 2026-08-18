#!/usr/bin/env bash
# Fonctions de Génération et de gestion de la configuration du DIU


# ============================================================
# Chargement de la configuration
# ============================================================

config_load () {

    config_load_diu
    config_load_desktop
    config_load_devops
    config_load_docker
    config_load_environments
    config_load_ia
    config_load_projects
    config_load_softwares
    config_load_system
    config_generator
    config_sort

}


config_load_diu() {
    local config_file_diu="/root/diu/config/diu.env"

    [[ -f "$config_file_diu" ]] || return 0

    # shellcheck disable=SC1090
    source "$config_file_diu"
}


config_load_desktop() {
    local config_file_desktop="/root/desktop/config/desktop.env"

    [[ -f "$config_file_desktop" ]] || return 0

    # shellcheck disable=SC1090
    source "$config_file_desktop"
}


config_load_devops() {
    local config_file_devops="/root/devops/config/devops.env"

    [[ -f "$config_file_devops" ]] || return 0

    # shellcheck disable=SC1090
    source "$config_file_devops"
}


config_load_docker() {
    local config_file_docker="/root/docker/config/docker.env"

    [[ -f "$config_file_docker" ]] || return 0

    # shellcheck disable=SC1090
    source "$config_file_docker"
}


config_load_environments() {
    local config_file_environnements="/root/diu/config/environnements.env"

    [[ -f "$config_file_environnements" ]] || return 0

    # shellcheck disable=SC1090
    source "$config_file_environnements"
}


config_load_ia() {
    local config_file_ia="/root/diu/config/ia.env"

    [[ -f "$config_file_ia" ]] || return 0

    # shellcheck disable=SC1090
    source "$config_file_ia"
}


config_load_projects() {
    local config_file_projects="/root/diu/config/projects.env"

    [[ -f "$config_file_projects" ]] || return 0

    # shellcheck disable=SC1090
    source "$config_file_projects"
}


config_load_softwares() {
    local config_file_softwares="/root/diu/config/softwares.env"

    [[ -f "$config_file_softwares" ]] || return 0

    # shellcheck disable=SC1090
    source "$config_file_softwares"
}


config_load_system() {
    local config_file_system="/root/diu/config/system.env"

    [[ -f "$config_file_system" ]] || return 0

    # shellcheck disable=SC1090
    source "$config_file_system"
}


# ============================================================
# Génération de la configuration
# ============================================================

config_generator() {

    local variables_directory="/root/diu/modules/diu/variables"

    [[ -d "${variables_directory}" ]] || return 0

    while IFS= read -r variable_file; do

        # shellcheck disable=SC1090
        source "${variable_file}"

    done < <(
        find "${variables_directory}" \
            -mindepth 2 \
            -maxdepth 2 \
            -type f \
            -name "*.sh" \
            -print | sort
    )
}


# ============================================================
# Tri des fichiers de configuration
# ============================================================

config_sort() {

    local config_directory="/root/diu/config"

    [[ -d "${config_directory}" ]] || return 0

    local config_file

    while IFS= read -r config_file; do

        sort -u "${config_file}" -o "${config_file}"

    done < <(
        find "${config_directory}" \
            -maxdepth 1 \
            -type f \
            -name "*.env" \
            -print | sort
    )
}


# ============================================================
# Mise à jour de la configuration
# ============================================================

config_update() {

    config_load
    config_generator

}

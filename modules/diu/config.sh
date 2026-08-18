#!/usr/bin/env bash
# Fonctions de Génération et de gestion de la configuration du DIU

load_config () {

	load_diu_config
	load_desktop_config
	load_environments_config
	load_ia_config
	load_projects_config
	load_softwares_config
	load_system_config

}

load_diu_config() {
    local config_file_diu="/root/diu/config/diu.env"

    [[ -f "$config_file_diu" ]] || return 0

    # shellcheck disable=SC1090
    source "$config_file_diu"
}

load_desktop_config() {
    local config_file_desktop="/root/desktop/config/desktop.env"

    [[ -f "$config_file_desktop" ]] || return 0

    # shellcheck disable=SC1090
    source "$config_file_desktop"
}

load_environments_config() {
    local config_file_environnements="/root/diu/config/environnements.env"

    [[ -f "$config_file_environnements" ]] || return 0

    # shellcheck disable=SC1090
    source "$config_file_environnements"
}

load_ia_config() {
    local config_file_ia="/root/diu/config/ia.env"

    [[ -f "$config_file_ia" ]] || return 0

    # shellcheck disable=SC1090
    source "$config_file_ia"
}

load_projects_config() {
    local config_file_projects="/root/diu/config/projects.env"

    [[ -f "$config_file_projects" ]] || return 0

    # shellcheck disable=SC1090
    source "$config_file_projects"
}

load_softwares_config() {
    local config_file_softwares="/root/diu/config/softwares.env"

    [[ -f "$config_file_softwares" ]] || return 0

    # shellcheck disable=SC1090
    source "$config_file_softwares"
}

load_system_config() {
    local config_file_system="/root/diu/config/system.env"

    [[ -f "$config_file_system" ]] || return 0

    # shellcheck disable=SC1090
    source "$config_file_system"
}

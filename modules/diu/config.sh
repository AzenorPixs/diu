#!/usr/bin/env bash
# Fonctions de Génération et de gestion de la configuration du DIU

load_environments_config() {
    local config_file="${BASH_SCRIPT_PATH}/config/environnements.env"

    [[ -f "$config_file" ]] || return 0

    # shellcheck disable=SC1090
    source "$config_file"
}

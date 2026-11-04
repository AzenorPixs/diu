#!/usr/bin/env bash
# Fonctions de Génération et de gestion de la configuration du DIU


# ============================================================
# Chargement de la configuration
# ============================================================

config_load () {

    local diu_env_devops_user_loaded=0
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
    local config_file_desktop="/root/diu/config/desktop.env"

    [[ -f "$config_file_desktop" ]] || return 0

    # shellcheck disable=SC1090
    source "$config_file_desktop"
}


config_load_devops() {
    local config_file_devops="/root/diu/config/devops.env"

    [[ -f "$config_file_devops" ]] || return 0

    # shellcheck disable=SC1090
    source "$config_file_devops"
}


config_load_docker() {
    local config_file_docker="/root/diu/config/docker.env"

    [[ -f "$config_file_docker" ]] || return 0

    # shellcheck disable=SC1090
    source "$config_file_docker"
}


config_load_environments() {
    local config_file_environnements="/root/diu/config/environnements.env"
    local line raw user_value='' user_found=0 root_uses_user=0
    local legacy_user_value='' legacy_user_found=0 legacy_root_uses_user=0

    [[ -f "$config_file_environnements" ]] || return 0

    # Une racine historique interpolée peut être triée avant son utilisateur.
    while IFS= read -r line || [[ -n "$line" ]]; do
        # shellcheck disable=SC2016
        if [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?ENV_DEVOPS_PROJECTS_ROOT= ]] &&
            [[ "$line" == *'${ENV_DEVOPS_USER}'* || "$line" == *'$ENV_DEVOPS_USER'* ]]; then
            root_uses_user=1
        elif [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?DEVOPS_PROJECTS_ROOT= ]] &&
            [[ "$line" == *'${DEVOPS_USER}'* ]]; then
            legacy_root_uses_user=1
        elif [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?ENV_DEVOPS_USER= ]]; then
            ((user_found += 1))
            raw="${line#*=}"
            if [[ "$raw" =~ ^[[:blank:]]*([a-z_][a-z0-9_-]*)[[:blank:]]*(#.*)?$ ]]; then
                user_value="${BASH_REMATCH[1]}"
            elif [[ "$raw" =~ ^[[:blank:]]*\"([a-z_][a-z0-9_-]*)\"[[:blank:]]*(#.*)?$ ]]; then
                user_value="${BASH_REMATCH[1]}"
            elif [[ "$raw" =~ ^[[:blank:]]*\'([a-z_][a-z0-9_-]*)\'[[:blank:]]*(#.*)?$ ]]; then
                user_value="${BASH_REMATCH[1]}"
            else
                user_value=''
            fi
        elif [[ "$line" =~ ^[[:blank:]]*(export[[:blank:]]+)?DEVOPS_USER= ]]; then
            ((legacy_user_found += 1))
            raw="${line#*=}"
            if [[ "$raw" =~ ^[[:blank:]]*([a-z_][a-z0-9_-]*)[[:blank:]]*(#.*)?$ ]]; then
                legacy_user_value="${BASH_REMATCH[1]}"
            elif [[ "$raw" =~ ^[[:blank:]]*\"([a-z_][a-z0-9_-]*)\"[[:blank:]]*(#.*)?$ ]]; then
                legacy_user_value="${BASH_REMATCH[1]}"
            elif [[ "$raw" =~ ^[[:blank:]]*\'([a-z_][a-z0-9_-]*)\'[[:blank:]]*(#.*)?$ ]]; then
                legacy_user_value="${BASH_REMATCH[1]}"
            else
                legacy_user_value=''
            fi
        fi
    done < "$config_file_environnements"
    if [[ "$legacy_root_uses_user" == 1 ]]; then
        if ((legacy_user_found > 1)) || { ((legacy_user_found == 1)) && [[ -z "$legacy_user_value" ]]; }; then
            printf '%s\n' 'DEVOPS_USER : déclaration historique ambiguë dans la configuration.' >&2
            return 1
        fi
        if ((legacy_user_found == 1)); then
            export DEVOPS_USER="$legacy_user_value"
        elif [[ -z "${DEVOPS_USER:-}" ]]; then
            printf '%s\n' 'DEVOPS_PROJECTS_ROOT : DEVOPS_USER est absent.' >&2
            return 1
        fi
    fi
    if [[ "$root_uses_user" == 1 ]]; then
        if ((user_found > 1)) || { ((user_found == 1)) && [[ -z "$user_value" ]]; }; then
            printf '%s\n' 'ENV_DEVOPS_USER : déclaration ambiguë dans la configuration.' >&2
            return 1
        fi
        if ((user_found == 1)); then
            export ENV_DEVOPS_USER="$user_value"
        elif [[ -z "${ENV_DEVOPS_USER:-}" ]]; then
            local user_file="${BASH_SCRIPT_PATH:-}/modules/diu/variables/environnements/env_devops_user.sh"
            if [[ ! -f "$user_file" || -L "$user_file" ]]; then
                printf '%s\n' 'ENV_DEVOPS_PROJECTS_ROOT : ENV_DEVOPS_USER est absent.' >&2
                return 1
            fi
            # shellcheck disable=SC1090
            source "$user_file" || return 1
            diu_env_devops_user_loaded=1
        fi
    fi

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

    local variables_directory="${BASH_SCRIPT_PATH}/modules/diu/variables"
    local devops_user_file="${variables_directory}/environnements/env_devops_user.sh"
    local projects_root_file="${variables_directory}/environnements/env_devops_projects_root.sh"
    local devops_user_loaded="${diu_env_devops_user_loaded:-0}" variable_file

    [[ -d "${variables_directory}" ]] || return 0

    while IFS= read -r variable_file; do

        if [[ "$variable_file" == "$projects_root_file" && "$devops_user_loaded" == 0 && -f "$devops_user_file" && ! -L "$devops_user_file" ]]; then
            # shellcheck disable=SC1090
            source "$devops_user_file" || return 1
            devops_user_loaded=1
        fi
        if [[ "$variable_file" == "$devops_user_file" && "$devops_user_loaded" == 1 ]]; then
            continue
        fi
        # shellcheck disable=SC1090
        source "${variable_file}" || return 1

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

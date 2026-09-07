#!/usr/bin/env bash

# Authentification GitHub locale, sur le modèle des fournisseurs existants.

_github_resolve_remote() {
    local project_path="${1:-}"
    local remote_name="${2:-${REMOTE_GITHUB_NAME:-origin}}"
    local remote_url=""
    local remote_authority=""
    local remote_path=""
    local remote_parts=()

    if [[ -z "${project_path}" || ! -d "${project_path}/.git" ]]; then
        print_error "Le dépôt Git du projet est introuvable : ${project_path}"
        return 1
    fi

    if ! remote_url="$(runuser -u "${DEVOPS_USER}" -- git -C "${project_path}" remote get-url "${remote_name}" 2>/dev/null)"; then
        print_error "Impossible de déterminer le remote GitHub du projet."
        return 1
    fi

    if [[ "${remote_url}" != https://* ]]; then
        print_error "Le remote GitHub doit utiliser une URL HTTPS."
        return 1
    fi

    remote_authority="${remote_url#https://}"
    remote_authority="${remote_authority%%/*}"
    remote_path="${remote_url#https://}"
    remote_path="${remote_path#*/}"

    if [[ "${remote_authority}" == *"@" || -z "${remote_authority}" || "${remote_path}" == "${remote_url}" ]]; then
        print_error "Le remote GitHub ne respecte pas le format HTTPS attendu."
        return 1
    fi

    IFS='/' read -r -a remote_parts <<< "${remote_path}"
    if [[ "${#remote_parts[@]}" -ne 2 || -z "${remote_parts[0]}" || -z "${remote_parts[1]}" ]]; then
        print_error "Le remote GitHub doit respecter le format https://hôte/propriétaire/dépôt.git."
        return 1
    fi
}

_github_read_username() {
    local project_path="${1:-}"
    local username_file="${project_path}/config/github.username"

    if [[ ! -f "${username_file}" ]]; then
        print_error "Le nom d'utilisateur GitHub est absent : ${username_file}"
        return 1
    fi
    if [[ "$(stat -c '%a' "${username_file}" 2>/dev/null)" != "600" ]]; then
        print_error "Les permissions de ${username_file} doivent être 600."
        return 1
    fi
    if ! IFS= read -r github_username < "${username_file}" || [[ -z "${github_username}" ]]; then
        print_error "Le nom d'utilisateur GitHub est vide."
        return 1
    fi
}

_github_read_token() {
    local project_path="${1:-}"
    local token_file="${project_path}/config/github.token"

    if [[ ! -f "${token_file}" ]]; then
        print_error "Le token GitHub est absent : ${token_file}"
        return 1
    fi
    if [[ "$(stat -c '%a' "${token_file}" 2>/dev/null)" != "600" ]]; then
        print_error "Les permissions de ${token_file} doivent être 600."
        return 1
    fi
    if ! IFS= read -r github_token < "${token_file}" || [[ -z "${github_token}" ]]; then
        print_error "Le token GitHub est vide."
        return 1
    fi
}

_github_initialize_credentials() {
    local project_path="${1:-}"
    local config_dir="${project_path}/config"
    local username_file="${config_dir}/github.username"
    local token_file="${config_dir}/github.token"
    local username_input=""
    local token_input=""
    local token_confirmation=""
    local temporary_file=""

    if [[ -z "${project_path}" || ! -d "${project_path}" ]]; then
        print_error "Le répertoire du projet est introuvable : ${project_path}"
        return 1
    fi

    if [[ ! -d "${config_dir}" ]]; then
        if ! install -d -m 700 -o "${DEVOPS_USER}" -g "${DEVOPS_GROUP}" "${config_dir}"; then
            print_error "Impossible de créer le répertoire de configuration GitHub."
            return 1
        fi
    fi

    if [[ -f "${username_file}" ]]; then
        _github_read_username "${project_path}" || return 1
    else
        read -r -p "Nom d'utilisateur GitHub : " username_input
        if [[ -z "${username_input}" ]]; then
            print_error "Le nom d'utilisateur GitHub ne peut pas être vide."
            return 1
        fi
        if ! temporary_file="$(mktemp "${config_dir}/.github.username.XXXXXX")"; then
            print_error "Impossible de préparer le fichier utilisateur GitHub."
            return 1
        fi
        if ! printf '%s\n' "${username_input}" > "${temporary_file}" || ! chmod 600 "${temporary_file}" || ! chown "${DEVOPS_USER}:${DEVOPS_GROUP}" "${temporary_file}" || ! mv -f "${temporary_file}" "${username_file}"; then
            rm -f "${temporary_file}"
            print_error "Impossible d'enregistrer le nom d'utilisateur GitHub."
            return 1
        fi
    fi

    if [[ -f "${token_file}" ]]; then
        _github_read_token "${project_path}" || return 1
        return 0
    fi

    printf 'Le token GitHub sera stocké uniquement dans %s avec les permissions 600.\n' "${token_file}"
    read -r -s -p "Token GitHub : " token_input
    printf '\n'
    read -r -s -p "Confirmation du token GitHub : " token_confirmation
    printf '\n'

    if [[ -z "${token_input}" || "${token_input}" != "${token_confirmation}" ]]; then
        print_error "Le token GitHub est vide ou les saisies ne correspondent pas."
        return 1
    fi

    if ! temporary_file="$(mktemp "${config_dir}/.github.token.XXXXXX")"; then
        print_error "Impossible de préparer le fichier token GitHub."
        return 1
    fi
    if ! printf '%s\n' "${token_input}" > "${temporary_file}" || ! chmod 600 "${temporary_file}" || ! chown "${DEVOPS_USER}:${DEVOPS_GROUP}" "${temporary_file}" || ! mv -f "${temporary_file}" "${token_file}"; then
        rm -f "${temporary_file}"
        print_error "Impossible d'enregistrer le token GitHub."
        return 1
    fi
}

_github_validate_credentials() {
    local project_path="${1:-}"
    local remote_name="${2:-${REMOTE_GITHUB_NAME:-origin}}"

    _github_resolve_remote "${project_path}" "${remote_name}" || return 1
    _github_read_username "${project_path}" || return 1
    _github_read_token "${project_path}" || return 1
}

_github_ensure_credentials() {
    local project_path="${1:-}"
    local remote_name="${2:-${REMOTE_GITHUB_NAME:-origin}}"

    if [[ -z "${project_path}" || ! -d "${project_path}" ]]; then
        print_error "Le répertoire du projet est introuvable : ${project_path}"
        return 1
    fi

    if [[ -f "${project_path}/config/github.username" && -f "${project_path}/config/github.token" ]]; then
        _github_validate_credentials "${project_path}" "${remote_name}"
        return $?
    fi

    _github_initialize_credentials "${project_path}" || return 1
    _github_validate_credentials "${project_path}" "${remote_name}"
}

github_git_push() {
    local project_path="${1:-}"
    shift || true
    local push_args=("${@}")

    _github_ensure_credentials "${project_path}" "${REMOTE_GITHUB_NAME:-origin}" || return 1
    _github_read_username "${project_path}" || return 1
    _github_read_token "${project_path}" || return 1
    git_with_token \
        "${project_path}" \
        "${github_username}" \
        "${github_token}" \
        push "${push_args[@]}"
}

#!/usr/bin/env bash

# Authentification GitLab locale, sur le modèle du fournisseur Forgejo.

_gitlab_resolve_remote() {
    local project_path="${1:-}"
    local remote_name="${2:-${REMOTE_GITLAB_NAME:-origin}}"
    local remote_url=""
    local remote_authority=""
    local remote_path=""
    local remote_parts=()

    if [[ -z "${project_path}" || ! -d "${project_path}/.git" ]]; then
        print_error "Le dépôt Git du projet est introuvable : ${project_path}"
        return 1
    fi

    if ! remote_url="$(runuser -u "${ENV_DEVOPS_USER}" -- git -C "${project_path}" remote get-url "${remote_name}" 2>/dev/null)"; then
        print_error "Impossible de déterminer le remote GitLab du projet."
        return 1
    fi

    if [[ "${remote_url}" != https://* ]]; then
        print_error "Le remote GitLab doit utiliser une URL HTTPS."
        return 1
    fi

    remote_authority="${remote_url#https://}"
    remote_authority="${remote_authority%%/*}"
    remote_path="${remote_url#https://${remote_authority}/}"

    if [[ "${remote_authority}" == *"@" || -z "${remote_authority}" || "${remote_path}" == "${remote_url}" ]]; then
        print_error "Le remote GitLab ne respecte pas le format HTTPS attendu."
        return 1
    fi

    IFS='/' read -r -a remote_parts <<< "${remote_path}"
    if [[ "${#remote_parts[@]}" -ne 2 || -z "${remote_parts[0]}" || -z "${remote_parts[1]}" ]]; then
        print_error "Le remote GitLab doit respecter le format https://hôte/propriétaire/dépôt.git."
        return 1
    fi

    gitlab_host="${remote_authority}"
    gitlab_owner="${remote_parts[0]}"
    gitlab_repository="${remote_parts[1]%.git}"
    gitlab_base_url="https://${gitlab_host}"
}

_gitlab_read_username() {
    local project_path="${1:-}"
    local username_file="${project_path}/config/gitlab.username"
    local username_perms=""

    if [[ ! -f "${username_file}" ]]; then
        print_error "Le nom d'utilisateur GitLab est absent : ${username_file}"
        return 1
    fi
    username_perms="$(stat -c '%a' "${username_file}" 2>/dev/null)"
    if [[ "${username_perms}" != "600" && "${username_perms}" != "660" ]]; then
        print_error "Les permissions de ${username_file} doivent être 600 ou 660."
        return 1
    fi
    if ! IFS= read -r gitlab_username < "${username_file}" || [[ -z "${gitlab_username}" ]]; then
        print_error "Le nom d'utilisateur GitLab est vide."
        return 1
    fi
}

_gitlab_read_token() {
    local project_path="${1:-}"
    local token_file="${project_path}/config/gitlab.token"
    local token_perms=""

    if [[ ! -f "${token_file}" ]]; then
        print_error "Le token GitLab est absent : ${token_file}"
        return 1
    fi
    token_perms="$(stat -c '%a' "${token_file}" 2>/dev/null)"
    if [[ "${token_perms}" != "600" && "${token_perms}" != "660" ]]; then
        print_error "Les permissions de ${token_file} doivent être 600 ou 660."
        return 1
    fi
    if ! IFS= read -r gitlab_token < "${token_file}" || [[ -z "${gitlab_token}" ]]; then
        print_error "Le token GitLab est vide."
        return 1
    fi
}

_gitlab_initialize_credentials() {
    local project_path="${1:-}"
    local config_dir="${project_path}/config"
    local username_file="${config_dir}/gitlab.username"
    local token_file="${config_dir}/gitlab.token"
    local username_input=""
    local token_input=""
    local token_confirmation=""
    local temporary_file=""

    if [[ -z "${project_path}" || ! -d "${project_path}" ]]; then
        print_error "Le répertoire du projet est introuvable : ${project_path}"
        return 1
    fi

    if [[ ! -d "${config_dir}" ]]; then
        if ! install -d -m 700 -o "${ENV_DEVOPS_USER}" -g "${DEVOPS_GROUP}" "${config_dir}"; then
            print_error "Impossible de créer le répertoire de configuration GitLab."
            return 1
        fi
    fi

    if [[ -f "${username_file}" ]]; then
        _gitlab_read_username "${project_path}" || return 1
    else
        read -r -p "Nom d'utilisateur GitLab : " username_input
        if [[ -z "${username_input}" ]]; then
            print_error "Le nom d'utilisateur GitLab ne peut pas être vide."
            return 1
        fi
        if ! temporary_file="$(mktemp "${config_dir}/.gitlab.username.XXXXXX")"; then
            print_error "Impossible de préparer le fichier utilisateur GitLab."
            return 1
        fi
        if ! printf '%s\n' "${username_input}" > "${temporary_file}" || ! chmod 600 "${temporary_file}" || ! chown "${ENV_DEVOPS_USER}:${DEVOPS_GROUP}" "${temporary_file}" || ! mv -f "${temporary_file}" "${username_file}"; then
            rm -f "${temporary_file}"
            print_error "Impossible d'enregistrer le nom d'utilisateur GitLab."
            return 1
        fi
    fi

    if [[ -f "${token_file}" ]]; then
        _gitlab_read_token "${project_path}" || return 1
        return 0
    fi

    printf 'Le token GitLab sera stocké uniquement dans %s avec les permissions 600.\n' "${token_file}"
    read -r -s -p "Token GitLab : " token_input
    printf '\n'
    read -r -s -p "Confirmation du token GitLab : " token_confirmation
    printf '\n'

    if [[ -z "${token_input}" || "${token_input}" != "${token_confirmation}" ]]; then
        print_error "Le token GitLab est vide ou les saisies ne correspondent pas."
        return 1
    fi

    if ! temporary_file="$(mktemp "${config_dir}/.gitlab.token.XXXXXX")"; then
        print_error "Impossible de préparer le fichier token GitLab."
        return 1
    fi
    if ! printf '%s\n' "${token_input}" > "${temporary_file}" || ! chmod 600 "${temporary_file}" || ! chown "${ENV_DEVOPS_USER}:${DEVOPS_GROUP}" "${temporary_file}" || ! mv -f "${temporary_file}" "${token_file}"; then
        rm -f "${temporary_file}"
        print_error "Impossible d'enregistrer le token GitLab."
        return 1
    fi
}

_gitlab_validate_credentials() {
    local project_path="${1:-}"
    local remote_name="${2:-${REMOTE_GITLAB_NAME:-origin}}"

    _gitlab_resolve_remote "${project_path}" "${remote_name}" || return 1
    _gitlab_read_username "${project_path}" || return 1
    _gitlab_read_token "${project_path}" || return 1
}

_gitlab_ensure_credentials() {
    local project_path="${1:-}"
    local remote_name="${2:-${REMOTE_GITLAB_NAME:-origin}}"

    if [[ -z "${project_path}" || ! -d "${project_path}" ]]; then
        print_error "Le répertoire du projet est introuvable : ${project_path}"
        return 1
    fi

    if [[ -f "${project_path}/config/gitlab.username" && -f "${project_path}/config/gitlab.token" ]]; then
        _gitlab_validate_credentials "${project_path}" "${remote_name}"
        return $?
    fi

    _gitlab_initialize_credentials "${project_path}" || return 1
    _gitlab_validate_credentials "${project_path}" "${remote_name}"
}

_gitlab_git_with_token() {
    local project_path="${1:-}"
    local username="${2:-}"
    local token="${3:-}"
    shift 3 || true

    case "${REMOTE_GITLAB_SSL_VERIFY:-Yes}" in
        No|no|non|NON|false|FALSE|0)
            (
                export GIT_SSL_NO_VERIFY=true
                git_with_token \
                    "${project_path}" \
                    "${username}" \
                    "${token}" \
                    "${@}"
            )
            ;;
        Yes|yes|oui|OUI|true|TRUE|1)
            git_with_token \
                "${project_path}" \
                "${username}" \
                "${token}" \
                "${@}"
            ;;
        *)
            print_error "REMOTE_GITLAB_SSL_VERIFY doit valoir Yes ou No."
            return 1
            ;;
    esac
}

gitlab_git_fetch() {
    local project_path="${1:-}"
    shift || true
    local fetch_args=("${@}")

    _gitlab_ensure_credentials "${project_path}" "${REMOTE_GITLAB_NAME:-origin}" || return 1
    _gitlab_read_username "${project_path}" || return 1
    _gitlab_read_token "${project_path}" || return 1
    _gitlab_git_with_token \
        "${project_path}" \
        "${gitlab_username}" \
        "${gitlab_token}" \
        fetch "${fetch_args[@]}"
}

gitlab_git_push() {
    local project_path="${1:-}"
    shift || true
    local push_args=("${@}")

    _gitlab_ensure_credentials "${project_path}" "${REMOTE_GITLAB_NAME:-origin}" || return 1
    _gitlab_read_username "${project_path}" || return 1
    _gitlab_read_token "${project_path}" || return 1
    _gitlab_git_with_token \
        "${project_path}" \
        "${gitlab_username}" \
        "${gitlab_token}" \
        push "${push_args[@]}"
}

# Clone un dépôt GitLab HTTPS avec les identifiants locaux du projet.
gitlab_git_clone() {
    local project_path="${1:-}"
    local remote_url="${2:-}"
    local remote_branch="${3:-}"
    local destination_path="${4:-}"

    if [[ -z "${project_path}" || -z "${remote_url}" ||
        -z "${remote_branch}" || -z "${destination_path}" ]]; then
        print_error "Usage : gitlab_git_clone <projet> <url> <branche> <destination>"
        return 1
    fi

    if [[ "${remote_url}" != https://* ]]; then
        print_error "L'URL de clonage GitLab doit utiliser HTTPS."
        return 1
    fi

    if [[ ! -f "${project_path}/config/gitlab.username" ||
        ! -f "${project_path}/config/gitlab.token" ]]; then
        _gitlab_initialize_credentials "${project_path}" || return 1
    fi

    _gitlab_read_username "${project_path}" || return 1
    _gitlab_read_token "${project_path}" || return 1
    _gitlab_git_with_token \
        "${project_path}" \
        "${gitlab_username}" \
        "${gitlab_token}" \
        clone --branch "${remote_branch}" --single-branch \
        "${remote_url}" "${destination_path}"
}

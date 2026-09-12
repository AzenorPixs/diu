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

_github_ensure_api_credentials() {
    local project_path="${1:-}"

    if [[ -z "${project_path}" || ! -d "${project_path}" ]]; then
        print_error "Le répertoire du projet est introuvable : ${project_path}"
        return 1
    fi

    _github_initialize_credentials "${project_path}" || return 1
    _github_read_username "${project_path}" || return 1
    _github_read_token "${project_path}"
}

_github_api_base() {
    local remote_base_url="${1:-}"

    remote_base_url="${remote_base_url%/}"

    if [[ "${remote_base_url}" == "https://github.com" ]]; then
        printf '%s\n' "https://api.github.com"
        return 0
    fi

    if [[ "${remote_base_url}" == https://* ]]; then
        printf '%s/api/v3\n' "${remote_base_url}"
        return 0
    fi

    print_error "L'URL de base GitHub doit utiliser HTTPS."
    return 1
}

_github_api_request() {
    local api_base="${1:-}"
    local method="${2:-}"
    local endpoint="${3:-}"
    local payload="${4:-}"
    local curl_config=""
    local response_file=""
    local http_code=""
    local curl_rc=0

    if [[ -z "${api_base}" || -z "${method}" || -z "${endpoint}" ]]; then
        print_error "_github_api_request : paramètres API manquants."
        return 1
    fi

    if [[ "${endpoint}" != /* ]]; then
        print_error "_github_api_request : l'endpoint API doit commencer par /."
        return 1
    fi

    if ! command -v curl >/dev/null 2>&1; then
        print_error "curl est requis pour utiliser l'API GitHub."
        return 1
    fi

    if [[ "${github_token:-}" == *$'\n'* || "${github_token:-}" == *'"'* ]]; then
        print_error "Le token GitHub contient un caractère non supporté par l'appel API."
        return 1
    fi

    if ! curl_config="$(mktemp)" || ! response_file="$(mktemp)"; then
        rm -f "${curl_config}" "${response_file}"
        print_error "Impossible de préparer l'appel API GitHub."
        return 1
    fi

    if ! chmod 600 "${curl_config}" "${response_file}"; then
        rm -f "${curl_config}" "${response_file}"
        print_error "Impossible de sécuriser les fichiers temporaires GitHub."
        return 1
    fi

    if ! printf '%s\n' \
        'silent' \
        'show-error' \
        'header = "Accept: application/vnd.github+json"' \
        'header = "X-GitHub-Api-Version: 2022-11-28"' \
        "header = \"Authorization: Bearer ${github_token}\"" \
        > "${curl_config}"; then
        rm -f "${curl_config}" "${response_file}"
        print_error "Impossible de préparer l'authentification API GitHub."
        return 1
    fi

    if [[ -n "${payload}" ]]; then
        http_code="$(curl --config "${curl_config}" --request "${method}" \
            --header 'Content-Type: application/json' \
            --data-binary "${payload}" --output "${response_file}" \
            --write-out '%{http_code}' "${api_base}${endpoint}")" || curl_rc=$?
    else
        http_code="$(curl --config "${curl_config}" --request "${method}" \
            --output "${response_file}" --write-out '%{http_code}' \
            "${api_base}${endpoint}")" || curl_rc=$?
    fi

    rm -f "${curl_config}"

    if [[ "${curl_rc}" -ne 0 ]]; then
        rm -f "${response_file}"
        print_error "L'appel API GitHub a échoué (code ${curl_rc})."
        return "${curl_rc}"
    fi

    printf '%s\n' "${http_code}"
    cat "${response_file}"
    rm -f "${response_file}"
}

github_repository_ensure() {
    local project_path="${1:-}"
    local remote_base_url="${2:-}"
    local remote_owner="${3:-}"
    local remote_repository="${4:-}"
    local api_base=""
    local api_response=""
    local http_code=""
    local api_body=""
    local github_account=""
    local confirmation=""
    local visibility=""
    local endpoint=""
    local payload=""

    if [[ -z "${project_path}" || -z "${remote_base_url}" || \
        -z "${remote_owner}" || -z "${remote_repository}" ]]; then
        print_error "Usage : github_repository_ensure <project_path> <base_url> <owner> <repository>"
        return 1
    fi

    _github_ensure_api_credentials "${project_path}" || return 1

    if ! command -v jq >/dev/null 2>&1; then
        print_error "jq est requis pour vérifier le dépôt GitHub."
        return 1
    fi

    api_base="$(_github_api_base "${remote_base_url}")" || return 1

    api_response="$(_github_api_request "${api_base}" "GET" \
        "/repos/${remote_owner}/${remote_repository}")" || return 1
    http_code="${api_response%%$'\n'*}"

    case "${http_code}" in
        200)
            print_info "Dépôt GitHub '${remote_owner}/${remote_repository}' vérifié."
            return 0
            ;;
        404)
            print_info "Le dépôt GitHub '${remote_owner}/${remote_repository}' est absent ou inaccessible."
            ;;
        *)
            print_error "La vérification du dépôt GitHub a retourné HTTP ${http_code:-inconnu}."
            return 1
            ;;
    esac

    read -r -p "Créer le dépôt GitHub '${remote_owner}/${remote_repository}' ? [o/N] : " confirmation

    case "${confirmation}" in
        o|O|oui|OUI|y|Y|yes|YES)
            ;;
        *)
            print_info "Création du dépôt GitHub annulée."
            return 1
            ;;
    esac

    while :; do
        read -r -p "Visibilité du dépôt [private] : " visibility
        visibility="${visibility:-private}"

        case "${visibility}" in
            private|public)
                break
                ;;
            *)
                print_error "La visibilité doit être private ou public."
                ;;
        esac
    done

    api_response="$(_github_api_request "${api_base}" "GET" "/user")" || return 1
    http_code="${api_response%%$'\n'*}"
    api_body="${api_response#*$'\n'}"

    if [[ "${http_code}" != "200" ]] || ! github_account="$(printf '%s' "${api_body}" | jq -er '.login')"; then
        print_error "Impossible d'identifier le compte GitHub authentifié."
        return 1
    fi

    if [[ "${github_account,,}" == "${remote_owner,,}" ]]; then
        endpoint="/user/repos"
    else
        endpoint="/orgs/${remote_owner}/repos"
    fi

    if ! payload="$(jq -cn --arg name "${remote_repository}" \
        --argjson private "$([[ "${visibility}" == "private" ]] && printf true || printf false)" \
        '{name: $name, private: $private, auto_init: false}')"; then
        print_error "Impossible de préparer la création du dépôt GitHub."
        return 1
    fi

    api_response="$(_github_api_request "${api_base}" "POST" \
        "${endpoint}" "${payload}")" || return 1
    http_code="${api_response%%$'\n'*}"

    if [[ "${http_code}" != "201" ]]; then
        print_error "La création du dépôt GitHub a retourné HTTP ${http_code:-inconnu}."
        return 1
    fi

    print_success "Dépôt GitHub '${remote_owner}/${remote_repository}' créé."
    return 0
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

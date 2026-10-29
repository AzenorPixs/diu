#!/usr/bin/env bash

_forgejo_curl() {
    local transport=curl
    if [[ -n "${projects_git_unavailable_file:-}" ]] &&
        declare -F projects_git_curl >/dev/null; then
        transport=projects_git_curl
    fi
    case "${REMOTE_FORGEJO_SSL_VERIFY:-Yes}" in
        Yes|yes|oui|OUI|true|TRUE|1)
            "${transport}" "$@"
            ;;
        No|no|non|NON|false|FALSE|0)
            "${transport}" --insecure "$@"
            ;;
        *)
            print_error "REMOTE_FORGEJO_SSL_VERIFY doit valoir Yes ou No."
            return 1
            ;;
    esac
}

_forgejo_resolve_remote() {

    # Provider d'authentification et d'accès Forgejo
    #
    # Responsabilités :
    #   - résolution du remote Forgejo
    #   - gestion des credentials locaux
    #   - validation du token Forgejo
    #   - git fetch/push HTTPS authentifié
    #   - appels API Forgejo authentifiés
    #
    # Credentials :
    #   config/forgejo.username
    #   config/forgejo.token
    #
    # Les credentials existants doivent être en permissions 600 ou 660.
    #
    # API :
    #   forgejo_api_get
    #   forgejo_api_post_json
    #   forgejo_api_upload

    # ==========================================================
    # Résolution du remote Forgejo
    # ==========================================================

    local project_path="${1:-}"
    local remote_name="${2:-origin}"
    local remote_url=""
    local url_path=""
    local authority=""
    local -a url_segments=()
    local segment_count=""

    if [[ -z "${project_path}" ]]; then
        print_error "_forgejo_resolve_remote : project_path est vide."
        return 1
    fi

    remote_url="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" remote get-url "${remote_name}" 2>/dev/null
    )"

    if [[ -z "${remote_url}" ]]; then
        print_error \
            "forgejo-auth : impossible de récupérer l'URL du remote ${remote_name}."
        return 1
    fi

    if [[ "${remote_url}" != https://* ]]; then
        print_error \
            "forgejo-auth : le remote ${remote_name} doit utiliser HTTPS."
        return 1
    fi

    url_path="${remote_url#https://}"
    url_path="${url_path%/}"

    authority="${url_path%%/*}"

    if [[ "${authority}" == *"@"* ]]; then
        print_error \
            "forgejo-auth : l'URL du remote ${remote_name} contient des informations d'identification interdites."
        return 1
    fi

    IFS='/' read -r -a url_segments <<< "${url_path}"

    segment_count="${#url_segments[@]}"

    if [[ "${segment_count}" -ne 3 ]]; then
        print_error \
            "forgejo-auth : format remote invalide."
        print_error \
            "Format attendu : https://<host>/<owner>/<repo>[.git]"
        return 1
    fi

    forgejo_host="${url_segments[0]}"
    forgejo_owner="${url_segments[1]}"
    forgejo_repo="${url_segments[2]}"

    if [[ -z "${forgejo_host}" ]]; then
        print_error "forgejo-auth : host Forgejo vide."
        return 1
    fi

    if [[ -z "${forgejo_owner}" ]]; then
        print_error "forgejo-auth : owner Forgejo vide."
        return 1
    fi

    if [[ -z "${forgejo_repo}" ]]; then
        print_error "forgejo-auth : repository Forgejo vide."
        return 1
    fi

    forgejo_repo="${forgejo_repo%.git}"

    if [[ -z "${forgejo_repo}" ]]; then
        print_error \
            "forgejo-auth : repository vide après suppression de .git."
        return 1
    fi

    forgejo_base="https://${forgejo_host}"

    return 0
}

# Lecture du username
_forgejo_read_username() {
    local project_path="${1:-}"
    local username_file="${project_path}/config/forgejo.username"
    local username_perms=""

    if [[ ! -f "${username_file}" ]]; then
        print_error \
            "forgejo-auth : fichier username manquant : ${username_file}"
        return 1
    fi

    username_perms="$(stat -c %a "${username_file}" 2>/dev/null)"

    if [[ "${username_perms}" != "600" && "${username_perms}" != "660" ]]; then
        print_error \
            "forgejo-auth : permissions invalides sur ${username_file} : ${username_perms}"
        print_error "Permissions attendues : 600 ou 660"
        return 1
    fi

    forgejo_username=""

    IFS= read -r forgejo_username < "${username_file}"

    if [[ -z "${forgejo_username}" ]]; then
        print_error \
            "forgejo-auth : le fichier username est vide."
        return 1
    fi

    return 0
}

# Lecture du token
_forgejo_read_token() {
    local project_path="${1:-}"
    local token_file="${project_path}/config/forgejo.token"
    local token_perms=""

    if [[ ! -f "${token_file}" ]]; then
        print_error \
            "forgejo-auth : fichier token manquant : ${token_file}"
        return 1
    fi

    token_perms="$(stat -c %a "${token_file}" 2>/dev/null)"

    if [[ "${token_perms}" != "600" && "${token_perms}" != "660" ]]; then
        print_error \
            "forgejo-auth : permissions invalides sur ${token_file} : ${token_perms}"
        print_error "Permissions attendues : 600 ou 660"
        return 1
    fi

    forgejo_token=""

    IFS= read -r forgejo_token < "${token_file}"

    if [[ -z "${forgejo_token}" ]]; then
        print_error \
            "forgejo-auth : le fichier token est vide."
        return 1
    fi

    return 0
}

# Création d'un fichier curl temporaire contenant le token
# Le token n'est jamais placé dans les arguments de curl.
_forgejo_create_api_curl_config() {
    local token="${1:-}"
    local config_file=""

    if [[ -z "${token}" ]]; then
        print_error \
            "_forgejo_create_api_curl_config : token vide."
        return 1
    fi

    config_file="$(mktemp)" || {
        print_error \
            "Impossible de créer le fichier temporaire d'authentification Forgejo."
        return 1
    }

    if ! chmod 600 "${config_file}"; then
        print_error \
            "Impossible de sécuriser le fichier temporaire Forgejo."
        rm -f "${config_file}"
        return 1
    fi

    if ! printf 'header = "Authorization: token %s"\n' \
        "${token}" > "${config_file}"; then

        print_error \
            "Impossible d'écrire le fichier temporaire Forgejo."
        rm -f "${config_file}"
        return 1
    fi

    printf '%s' "${config_file}"
}

# Préparation du contexte Forgejo
# Cette fonction est utilisée par les opérations Git et API.
_forgejo_prepare_context() {
    local project_path="${1:-}"
    local remote_name="${2:-origin}"

    if [[ -z "${project_path}" ]]; then
        print_error "_forgejo_prepare_context : project_path est vide."
        return 1
    fi

    if [[ ! -d "${project_path}" ]]; then
        print_error \
            "Projet introuvable : ${project_path}"
        return 1
    fi

    if ! _forgejo_resolve_remote "${project_path}" "${remote_name}"; then
        return 1
    fi

    if ! _forgejo_read_username "${project_path}"; then
        return 1
    fi

    if ! _forgejo_read_token "${project_path}"; then
        return 1
    fi

    return 0
}

_forgejo_api_request() {

    # ==========================================================
    # Requête API Forgejo générique
    #
    # Usage :
    #
    #   _forgejo_api_request \
    #       <project_path> \
    #       <method> \
    #       <endpoint> \
    #       [json_payload] \
    #       [upload_file]
    #
    # stdout :
    #   <body>
    #   <HTTP code>
    #
    # return 0 :
    #   curl a obtenu une réponse HTTP
    #
    # return != 0 :
    #   erreur réseau / préparation de requête
    # ==========================================================

    local project_path="${1:-}"
    local method="${2:-}"
    local endpoint="${3:-}"
    local payload="${4:-}"
    local upload_file="${5:-}"

    local curl_config=""
    local response=""
    local curl_rc=0
    local api_url=""
    local response_file=""
    local http_code=""

    if [[ -z "${project_path}" ]]; then
        print_error "_forgejo_api_request : project_path vide."
        return 1
    fi

    if [[ -z "${method}" ]]; then
        print_error "_forgejo_api_request : méthode HTTP vide."
        return 1
    fi

    if [[ -z "${endpoint}" ]]; then
        print_error "_forgejo_api_request : endpoint vide."
        return 1
    fi

    if [[ "${endpoint}" != /* ]]; then
        print_error \
            "_forgejo_api_request : endpoint API doit commencer par /."
        return 1
    fi

    if [[ -n "${upload_file}" && ! -f "${upload_file}" ]]; then
        print_error \
            "_forgejo_api_request : fichier upload introuvable : ${upload_file}"
        return 1
    fi

    if ! _forgejo_prepare_context "${project_path}"; then
        return 1
    fi

    api_url="${forgejo_base}/api/v1${endpoint}"

    curl_config="$(
        _forgejo_create_api_curl_config "${forgejo_token}"
    )" || return 1

    if [[ -z "${curl_config}" || ! -f "${curl_config}" ]]; then
        print_error \
            "_forgejo_api_request : configuration curl invalide."
        return 1
    fi

    response_file="$(mktemp)" || {
        rm -f "${curl_config}"
        print_error "Impossible de créer le fichier temporaire de réponse Forgejo."
        return 1
    }

    if ! chmod 600 "${response_file}"; then
        rm -f "${curl_config}" "${response_file}"
        print_error "Impossible de sécuriser le fichier temporaire de réponse Forgejo."
        return 1
    fi

    if [[ -n "${upload_file}" ]]; then

        if http_code="$(
            _forgejo_curl -sS \
                -o "${response_file}" \
                -w '%{http_code}' \
                --config "${curl_config}" \
                -X "${method}" \
                -F "attachment=@${upload_file}" \
                "${api_url}" \
                2>/dev/null
        )"; then
            curl_rc=0
        else
            curl_rc=$?
        fi

    elif [[ -n "${payload}" ]]; then

        if http_code="$(
            _forgejo_curl -sS \
                -o "${response_file}" \
                -w '%{http_code}' \
                --config "${curl_config}" \
                -X "${method}" \
                -H "Content-Type: application/json" \
                -d "${payload}" \
                "${api_url}" \
                2>/dev/null
        )"; then
            curl_rc=0
        else
            curl_rc=$?
        fi

    else

        if http_code="$(
            _forgejo_curl -sS \
                -o "${response_file}" \
                -w '%{http_code}' \
                --config "${curl_config}" \
                -X "${method}" \
                "${api_url}" \
                2>/dev/null
        )"; then
            curl_rc=0
        else
            curl_rc=$?
        fi

    fi

    rm -f "${curl_config}"

    if [[ "${curl_rc}" -ne 0 ]]; then
        rm -f "${response_file}"
        print_error \
            "Erreur réseau lors de l'appel API Forgejo (curl=${curl_rc})."
        return "${curl_rc}"
    fi

    if ! response="$(tr -d '\000' < "${response_file}")"; then
        rm -f "${response_file}"
        print_error "Impossible de lire la réponse API Forgejo."
        return 1
    fi

    rm -f "${response_file}"

    if declare -F projects_git_note_unavailable >/dev/null &&
        projects_git_note_unavailable http "${http_code}"; then
        return 1
    fi

    printf '%s\n%s' "${response}" "${http_code}"

    return 0
}

# API GET
# forgejo_api_get <project_path> <endpoint>
forgejo_api_get() {
    local project_path="${1:-}"
    local endpoint="${2:-}"

    if [[ -z "${project_path}" ]]; then
        print_error "forgejo_api_get : project_path vide."
        return 1
    fi

    if [[ -z "${endpoint}" ]]; then
        print_error "forgejo_api_get : endpoint vide."
        return 1
    fi

    _forgejo_api_request \
        "${project_path}" \
        "GET" \
        "${endpoint}"
}

# API POST JSON
# forgejo_api_post_json <project_path> <endpoint> <payload>
forgejo_api_post_json() {
    local project_path="${1:-}"
    local endpoint="${2:-}"
    local payload="${3:-}"

    if [[ -z "${project_path}" ]]; then
        print_error "forgejo_api_post_json : project_path vide."
        return 1
    fi

    if [[ -z "${endpoint}" ]]; then
        print_error "forgejo_api_post_json : endpoint vide."
        return 1
    fi

    if [[ -z "${payload}" ]]; then
        print_error "forgejo_api_post_json : payload JSON vide."
        return 1
    fi

    if ! printf '%s' "${payload}" | jq empty >/dev/null 2>&1; then
        print_error \
            "forgejo_api_post_json : payload JSON invalide."
        return 1
    fi

    _forgejo_api_request \
        "${project_path}" \
        "POST" \
        "${endpoint}" \
        "${payload}"
}

# Vérifie que le dépôt Forgejo distant existe.
# Retourne 2 lorsque Forgejo devra le créer au premier push Git.
# forgejo_repository_ensure <project_path> <remote_name>
forgejo_repository_ensure() {
    local project_path="${1:-}"
    local remote_name="${2:-origin}"
    local repository_response=""
    local repository_code=""

    if [[ -z "${project_path}" ]]; then
        print_error "forgejo_repository_ensure : project_path vide."
        return 1
    fi

    if ! _forgejo_prepare_context "${project_path}" "${remote_name}"; then
        return 1
    fi

    if ! repository_response="$(
        forgejo_api_get \
            "${project_path}" \
            "/repos/${forgejo_owner}/${forgejo_repo}"
    )"; then
        print_error "Impossible de vérifier l'existence du dépôt Forgejo."
        return 1
    fi

    if [[ "${repository_response}" != *$'\n'* ]]; then
        print_error "Réponse API Forgejo invalide lors de la vérification du dépôt."
        return 1
    fi

    repository_code="${repository_response##*$'\n'}"

    case "${repository_code}" in
        200)
            return 0
            ;;
        404)
            print_info \
                "Le dépôt Forgejo ${forgejo_owner}/${forgejo_repo} sera créé par le premier push Git."
            return 2
            ;;
        *)
            print_error \
                "Impossible de vérifier le dépôt Forgejo (HTTP ${repository_code})."
            return 1
            ;;
    esac
}

# API upload
# forgejo_api_upload <project_path> <endpoint> <file>
forgejo_api_upload() {
    local project_path="${1:-}"
    local endpoint="${2:-}"
    local file="${3:-}"

    if [[ -z "${project_path}" ]]; then
        print_error "forgejo_api_upload : project_path vide."
        return 1
    fi

    if [[ -z "${endpoint}" ]]; then
        print_error "forgejo_api_upload : endpoint vide."
        return 1
    fi

    if [[ -z "${file}" ]]; then
        print_error "forgejo_api_upload : fichier vide."
        return 1
    fi

    if [[ ! -f "${file}" ]]; then
        print_error \
            "forgejo_api_upload : fichier introuvable : ${file}"
        return 1
    fi

    if [[ ! -r "${file}" ]]; then
        print_error \
            "forgejo_api_upload : fichier illisible : ${file}"
        return 1
    fi

    _forgejo_api_request \
        "${project_path}" \
        "POST" \
        "${endpoint}" \
        "" \
        "${file}"
}

_forgejo_validate_credentials() {

    # ==========================================================
    # Validation réelle du token Forgejo
    #
    # Première vérification :
    #
    #   GET /api/v1/user
    #
    # Cette vérification ne dépend donc pas de l'existence
    # du repository.
    #
    # Retour :
    #   0 = token valide
    #   2 = token invalide / accès refusé
    #   1 = erreur technique
    # ==========================================================

    local project_path="${1:-}"
    local remote_name="${2:-origin}"
    local credentials_path="${3:-${1:-}}"

    local http_code=""
    local curl_rc=0
    local request_config="" escaped_token=""
    local forgejo_url=""

    if [[ -z "${project_path}" ]]; then
        print_error \
            "_forgejo_validate_credentials : project_path est vide."
        return 1
    fi

    if [[ ! -d "${project_path}" ]]; then
        print_error \
            "_forgejo_validate_credentials : projet introuvable : ${project_path}"
        return 1
    fi

    # ==========================================================
    # Étape 1 : Résolution du remote Forgejo
    # ==========================================================

    if ! _forgejo_resolve_remote "${project_path}" "${remote_name}"; then
        return 1
    fi

    if [[ -z "${forgejo_base}" ]]; then
        print_error \
            "_forgejo_validate_credentials : URL Forgejo non initialisée."
        return 1
    fi

    if [[ -z "${forgejo_owner}" ]]; then
        print_error \
            "_forgejo_validate_credentials : owner Forgejo non initialisé."
        return 1
    fi

    if [[ -z "${forgejo_repo}" ]]; then
        print_error \
            "_forgejo_validate_credentials : repository Forgejo non initialisé."
        return 1
    fi

    # ==========================================================
    # Étape 2 : Lecture du username
    # ==========================================================

    if ! _forgejo_read_username "${credentials_path}"; then
        return 1
    fi

    if [[ -z "${forgejo_username}" ]]; then
        print_error \
            "_forgejo_validate_credentials : username vide."
        return 1
    fi

    # ==========================================================
    # Étape 3 : Lecture du token
    # ==========================================================

    if ! _forgejo_read_token "${credentials_path}"; then
        return 1
    fi

    if [[ -z "${forgejo_token}" ]]; then
        print_error \
            "_forgejo_validate_credentials : token vide."
        return 1
    fi

    # ==========================================================
    # Étape 4 : Validation du token sur le repository
    #
    # IMPORTANT :
    #
    # Nous validons directement une ressource /repos/.
    #
    # Le scope write:repository couvre les routes repository
    # ainsi que les opérations de Release.
    #
    # Nous n'utilisons volontairement pas /api/v1/user :
    # ce endpoint nécessite le scope user et n'est pas nécessaire
    # pour le fonctionnement du token de publication DIU.
    #
    # ==========================================================

    print_info \
        "Vérification de la validité du token Forgejo..."

    print_info \
        "Vérification de l'accès au dépôt Forgejo..."

    forgejo_url="${forgejo_base}/api/v1/repos/${forgejo_owner}/${forgejo_repo}"

    if [[ "${forgejo_token}" == *$'\n'* || "${forgejo_token}" == *$'\r'* ]]; then
        print_error "Format du token Forgejo invalide."
        return 1
    fi
    request_config="$(mktemp)" || return 1
    escaped_token="${forgejo_token//\\/\\\\}"
    escaped_token="${escaped_token//\"/\\\"}"
    if ! chmod 600 "${request_config}" ||
        ! printf 'header = "Authorization: token %s"\n' "${escaped_token}" > "${request_config}"; then
        rm -f -- "${request_config}"
        print_error "Impossible de préparer la validation Forgejo."
        return 1
    fi
    if http_code="$(_forgejo_curl -sS -o /dev/null -w '%{http_code}' \
        --config "${request_config}" -H 'Accept: application/json' "${forgejo_url}" 2>/dev/null)"; then
        curl_rc=0
    else
        curl_rc=$?
    fi
    rm -f -- "${request_config}"
    unset escaped_token
    if [[ "${curl_rc}" -ne 0 ]]; then
        print_error "Impossible de contacter Forgejo pour valider les identifiants."
        return 1
    fi

    # ==========================================================
    # Étape 5 : Interprétation du code HTTP
    # ==========================================================

    if declare -F projects_git_note_unavailable >/dev/null &&
        projects_git_note_unavailable http "${http_code}"; then
        return 1
    fi

    case "${http_code}" in

        200)
            print_success \
                "Token Forgejo valide."

            print_success \
                "Dépôt Forgejo ${forgejo_owner}/${forgejo_repo} accessible."

            return 0
            ;;

        404)
            # --------------------------------------------------
            # Le token est accepté mais le dépôt n'existe pas.
            #
            # Cette situation est valide pour un premier push
            # lorsque Forgejo autorise la création du dépôt par
            # push.
            # --------------------------------------------------

            print_success \
                "Token Forgejo valide."

            print_info \
                "Le dépôt Forgejo ${forgejo_owner}/${forgejo_repo} n'existe pas encore."

            print_info \
                "Le premier git push pourra créer le dépôt selon la configuration Forgejo."

            return 0
            ;;

        401)
            print_error \
                "_forgejo_validate_credentials : token Forgejo invalide ou expiré."

            return 2
            ;;

        403)
            print_error \
                "_forgejo_validate_credentials : accès au dépôt Forgejo refusé (HTTP 403)."

            print_error \
                "Le token existe mais ne possède pas les droits nécessaires."

            print_error \
                "Vérifiez le scope write:repository et les restrictions du token."

            return 2
            ;;

        000|"")
            print_error \
                "_forgejo_validate_credentials : impossible de contacter Forgejo."

            return 1
            ;;

        *)
            print_error "Réponse Forgejo inattendue (HTTP ${http_code})."
            return 1
            ;;
    esac
}

_forgejo_ensure_credentials() {
    local project_path="${1:-}" remote_name="${2:-origin}" missing=0 kind=""
    local forgejo_username="" forgejo_token=""
    if [[ -z "${project_path}" || ! -d "${project_path}" ]]; then
        print_error "Projet invalide pour les identifiants Forgejo."
        return 1
    fi
    if [[ -L "${project_path}/config" ]]; then
        print_error "Configuration Forgejo symbolique refusée."
        return 1
    fi
    for kind in username token; do
        if [[ -L "${project_path}/config/forgejo.${kind}" ]]; then
            print_error "Fichier d’identifiant Forgejo symbolique refusé."
            return 1
        elif [[ -e "${project_path}/config/forgejo.${kind}" ]]; then
            "_forgejo_read_${kind}" "${project_path}" || return 1
        else
            missing=1
        fi
    done
    # Statut interne réservé à l’orchestration ; les transports retournent une erreur.
    if [[ "${missing}" == 1 ]]; then
        return 3
    fi
    _forgejo_validate_credentials "${project_path}" "${remote_name}"
}

# Exécute une commande Git Forgejo avec l'option TLS configurée.
_forgejo_git_with_token() {
    local project_path="${1:-}"
    local username="${2:-}"
    local token="${3:-}"
    shift 3 || true

    case "${REMOTE_FORGEJO_SSL_VERIFY:-Yes}" in
        Yes|yes|oui|OUI|true|TRUE|1)
            git_with_token \
                "${project_path}" \
                "${username}" \
                "${token}" \
                "${@}"
            ;;
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
        *)
            print_error "REMOTE_FORGEJO_SSL_VERIFY doit valoir Yes ou No."
            return 1
            ;;
    esac
}

# Git fetch authentifié vers le remote historique origin.
forgejo_git_fetch() {
    local project_path="${1:-}"

    if [[ -z "${project_path}" ]]; then
        print_error "forgejo_git_fetch : project_path vide."
        return 1
    fi

    forgejo_git_fetch_named "${project_path}" origin
}

# Git fetch authentifié vers un remote Forgejo nommé.
# forgejo_git_fetch_named <project_path> <remote_name>
forgejo_git_fetch_named() {
    local project_path="${1:-}"
    local remote_name="${2:-}"

    if [[ -z "${project_path}" || -z "${remote_name}" ]]; then
        print_error \
            "forgejo_git_fetch_named : project_path et remote_name sont obligatoires."
        return 1
    fi

    if ! _forgejo_ensure_credentials "${project_path}" "${remote_name}"; then
        return 1
    fi

    if ! _forgejo_read_username "${project_path}"; then
        return 1
    fi

    if ! _forgejo_read_token "${project_path}"; then
        return 1
    fi

    _forgejo_git_with_token \
        "${project_path}" \
        "${forgejo_username}" \
        "${forgejo_token}" \
        fetch "${remote_name}"
}

# Git push authentifié vers le remote historique origin.
# forgejo_git_push <project_path> [push_args...]
forgejo_git_push() {
    local project_path="${1:-}"
    shift || true
    forgejo_git_push_named "${project_path}" origin "${@}"
}

# Git push authentifié vers un remote Forgejo nommé.
# forgejo_git_push_named <project_path> <remote_name> [push_args...]
forgejo_git_push_named() {
    local project_path="${1:-}"
    local remote_name="${2:-}"
    shift 2 || true

    local push_args=("${@}")

    if [[ -z "${project_path}" || -z "${remote_name}" ]]; then
        print_error \
            "forgejo_git_push_named : project_path et remote_name sont obligatoires."
        return 1
    fi

    if ! _forgejo_ensure_credentials "${project_path}" "${remote_name}"; then
        print_error \
            "forgejo_git_push : impossible d'initialiser les credentials Forgejo."
        return 1
    fi

    if ! _forgejo_read_username "${project_path}"; then
        return 1
    fi

    if ! _forgejo_read_token "${project_path}"; then
        return 1
    fi

    _forgejo_git_with_token \
        "${project_path}" \
        "${forgejo_username}" \
        "${forgejo_token}" \
        push \
        "${push_args[@]}"
}

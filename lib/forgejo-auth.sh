#!/usr/bin/env bash

_forgejo_curl() {
    case "${REMOTE_FORGEJO_SSL_VERIFY:-Yes}" in
        Yes|yes|oui|OUI|true|TRUE|1)
            curl "$@"
            ;;
        No|no|non|NON|false|FALSE|0)
            curl --insecure "$@"
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
    # Les credentials doivent être en permissions 600.
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

    if [[ "${username_perms}" != "600" ]]; then
        print_error \
            "forgejo-auth : permissions invalides sur ${username_file} : ${username_perms}"
        print_error "Permissions attendues : 600"
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

    if [[ "${token_perms}" != "600" ]]; then
        print_error \
            "forgejo-auth : permissions invalides sur ${token_file} : ${token_perms}"
        print_error "Permissions attendues : 600"
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

    if [[ -n "${upload_file}" ]]; then

        if response="$(
            _forgejo_curl -sS \
                -w '\n%{http_code}' \
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

        if response="$(
            _forgejo_curl -sS \
                -w '\n%{http_code}' \
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

        if response="$(
            _forgejo_curl -sS \
                -w '\n%{http_code}' \
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
        print_error \
            "Erreur réseau lors de l'appel API Forgejo (curl=${curl_rc})."
        return "${curl_rc}"
    fi

    printf '%s' "${response}"

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

# Vérifie que le dépôt Forgejo distant existe et le crée vide si nécessaire.
# forgejo_repository_ensure <project_path> <remote_name>
forgejo_repository_ensure() {
    local project_path="${1:-}"
    local remote_name="${2:-origin}"
    local repository_response=""
    local organization_response=""
    local creation_response=""
    local repository_code=""
    local organization_code=""
    local creation_code=""
    local creation_endpoint=""
    local creation_payload=""

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
            ;;
        *)
            print_error \
                "Impossible de vérifier le dépôt Forgejo (HTTP ${repository_code})."
            return 1
            ;;
    esac

    if [[ -z "${forgejo_username:-}" ]]; then
        print_error "Identifiant Forgejo authentifié absent."
        return 1
    fi

    if [[ "${forgejo_owner}" == "${forgejo_username}" ]]; then
        creation_endpoint="/user/repos"
    else
        if ! organization_response="$(
            forgejo_api_get "${project_path}" "/orgs/${forgejo_owner}"
        )"; then
            print_error "Impossible de vérifier l'organisation Forgejo cible."
            return 1
        fi

        if [[ "${organization_response}" != *$'\n'* ]]; then
            print_error "Réponse API Forgejo invalide pour l'organisation cible."
            return 1
        fi

        organization_code="${organization_response##*$'\n'}"

        if [[ "${organization_code}" != "200" ]]; then
            print_error \
                "Le propriétaire Forgejo ${forgejo_owner} n'est pas une organisation accessible."
            return 1
        fi

        creation_endpoint="/orgs/${forgejo_owner}/repos"
    fi

    creation_payload="$(
        jq -cn --arg name "${forgejo_repo}" '{name: $name, auto_init: false}'
    )" || {
        print_error "Impossible de préparer la création du dépôt Forgejo."
        return 1
    }

    if ! creation_response="$(
        forgejo_api_post_json \
            "${project_path}" \
            "${creation_endpoint}" \
            "${creation_payload}"
    )"; then
        print_error "Impossible de créer le dépôt Forgejo absent."
        return 1
    fi

    if [[ "${creation_response}" != *$'\n'* ]]; then
        print_error "Réponse API Forgejo invalide lors de la création du dépôt."
        return 1
    fi

    creation_code="${creation_response##*$'\n'}"

    if [[ "${creation_code}" != "201" ]]; then
        print_error "Création du dépôt Forgejo refusée (HTTP ${creation_code})."
        return 1
    fi

    if ! repository_response="$(
        forgejo_api_get \
            "${project_path}" \
            "/repos/${forgejo_owner}/${forgejo_repo}"
    )"; then
        print_error "Impossible de vérifier le dépôt Forgejo créé."
        return 1
    fi

    repository_code="${repository_response##*$'\n'}"

    if [[ "${repository_code}" != "200" ]]; then
        print_error \
            "Le dépôt Forgejo créé n'est pas accessible (HTTP ${repository_code})."
        return 1
    fi

    print_success "Dépôt Forgejo ${forgejo_owner}/${forgejo_repo} créé."
    return 0
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

    local http_code=""
    local curl_rc=0
    local error_body=""
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

    if ! _forgejo_read_username "${project_path}"; then
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

    if ! _forgejo_read_token "${project_path}"; then
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

    http_code="$(
        _forgejo_curl -sS \
            -o /dev/null \
            -w '%{http_code}' \
            -H "Authorization: token ${forgejo_token}" \
            -H "Accept: application/json" \
            "${forgejo_url}" \
            2>/dev/null
    )"

    curl_rc=$?

    if [[ "${curl_rc}" -ne 0 ]]; then
        print_error \
            "_forgejo_validate_credentials : impossible de contacter Forgejo."
        print_error \
            "Code curl : ${curl_rc}"
        return 1
    fi

    # ==========================================================
    # Étape 5 : Interprétation du code HTTP
    # ==========================================================

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
            # --------------------------------------------------
            # Pour les erreurs inattendues, récupération séparée
            # du message JSON.
            #
            # Le corps n'est PAS capturé dans la commande qui
            # récupère le code HTTP : cela évite le problème
            # d'octet NUL observé précédemment.
            # --------------------------------------------------

            error_body="$(
                _forgejo_curl -sS \
                    -H "Authorization: token ${forgejo_token}" \
                    -H "Accept: application/json" \
                    "${forgejo_url}" \
                    2>/dev/null |
                    tr -d '\000'
            )"

            forgejo_error="$(
                printf '%s' "${error_body}" |
                    jq -r '.message // empty' 2>/dev/null
            )"

            if [[ -n "${forgejo_error}" ]]; then
                print_error \
                    "_forgejo_validate_credentials : Forgejo répond HTTP ${http_code} : ${forgejo_error}"
            else
                print_error \
                    "_forgejo_validate_credentials : réponse Forgejo inattendue (HTTP ${http_code})."
            fi

            return 1
            ;;
    esac
}

_forgejo_ensure_credentials() {

    # ==========================================================
    # Validation / initialisation des credentials
    #
    # Cette fonction conserve le principe actuel :
    #
    #   credentials valides → OK
    #   credentials invalides → reconfiguration
    #   credentials absents → configuration
    #
    # La génération automatique du token est conservée.
    # ==========================================================

    local project_path="${1:-}"
    local remote_name="${2:-${REMOTE_FORGEJO_NAME:-origin}}"

    local forgejo_host=""
    local forgejo_base=""
    local forgejo_owner=""
    local forgejo_repo=""

    local forgejo_user=""
    local forgejo_username=""
    local forgejo_password=""
    local forgejo_token=""

    local token_file=""
    local username_file=""

    local token_choice=""
    local token_http_response=""
    local token_http_code=""
    local token_http_body=""

    local auth_http_code=""
    local bootstrap_curl_rc=0
    local credentials_rc=0

    local netrc_file=""
    local token_write_file=""
    local username_write_file=""

    local final_token_perms=""
    local final_username_perms=""

    if [[ -z "${project_path}" ]]; then
        print_error "forgejo_ensure_credentials : project_path est vide."
        return 1
    fi

    if [[ ! -d "${project_path}" ]]; then
        print_error "Projet introuvable : ${project_path}"
        return 1
    fi

    token_file="${project_path}/config/forgejo.token"
    username_file="${project_path}/config/forgejo.username"

    # ==========================================================
    # Étape 1 : Déduction des informations Forgejo
    # ==========================================================

    if ! _forgejo_resolve_remote "${project_path}" "${remote_name}"; then
        return 1
    fi

    # ==========================================================
    # Étape 2 : Vérification des credentials locaux
    # ==========================================================

    if [[ -f "${token_file}" && -f "${username_file}" ]]; then

        if ! _forgejo_read_username "${project_path}"; then
            print_error "Impossible de lire l'identifiant Forgejo local."
            return 1
        fi

        if ! _forgejo_read_token "${project_path}"; then
            print_error "Impossible de lire le token Forgejo local."
            return 1
        fi

        if [[ -z "${forgejo_username}" ]]; then
            print_error "L'identifiant Forgejo local est vide."
            return 1
        fi

        if [[ -z "${forgejo_token}" ]]; then
            print_error "Le token Forgejo local est vide."
            return 1
        fi

        print_info "Vérification des credentials Forgejo locaux..."

        credentials_rc=0

        _forgejo_validate_credentials \
            "${project_path}" "${remote_name}" || credentials_rc=$?

        case "${credentials_rc}" in

            0)
                print_success \
                    "Authentification Forgejo locale validée."
                return 0
                ;;

            2)
                print_error \
                    "Les credentials Forgejo locaux sont invalides ou expirés."

                print_info \
                    "Le token local doit être remplacé."

                rm -f "${token_file}" "${username_file}"

                if [[ -e "${token_file}" || -e "${username_file}" ]]; then
                    print_error \
                        "Impossible de supprimer les anciens credentials Forgejo."
                    return 1
                fi
                ;;

            *)
                print_error \
                    "Impossible de valider les credentials Forgejo locaux."
                return 1
                ;;
        esac

    else
        print_info "Les credentials Forgejo locaux sont incomplets."
    fi

    # ==========================================================
    # Étape 3 : Choix du mode de configuration du token
    # ==========================================================

    print_info "Le token Forgejo est absent ou invalide."
    echo ""
    echo "Comment souhaitez-vous configurer les credentials Forgejo ?"
    echo ""
    echo "  1) Saisir un token Forgejo existant"
    echo "     → aucun mot de passe Forgejo requis"
    echo ""
    echo "  2) Créer automatiquement un nouveau token via l'API Forgejo"
    echo "     → identifiant et mot de passe Forgejo requis"
    echo ""

    read -r -p "Votre choix [1-2] : " token_choice

    case "${token_choice}" in

        1)
            # ==================================================
            # Étape 4A : Saisie manuelle du token
            # ==================================================

            echo ""
            print_title "Configuration manuelle du token Forgejo"
            echo ""

            read -r -p \
                "Identifiant Forgejo : " forgejo_user

            if [[ -z "${forgejo_user}" ]]; then
                print_error \
                    "L'identifiant Forgejo ne peut pas être vide."
                return 1
            fi

            echo ""

            read -r -s -p \
                "Token Forgejo pour ${forgejo_user} : " forgejo_token
            echo ""

            if [[ -z "${forgejo_token}" ]]; then
                print_error "Le token Forgejo ne peut pas être vide."
                return 1
            fi

            forgejo_username="${forgejo_user}"

            if ! mkdir -p "${project_path}/config"; then
                print_error \
                    "Impossible de créer le répertoire config."
                return 1
            fi

            username_write_file="$(
                mktemp "${project_path}/config/.forgejo.username.XXXXXX"
            )" || {
                print_error \
                    "Impossible de créer le fichier temporaire username."
                return 1
            }

            chmod 600 "${username_write_file}" || {
                print_error \
                    "Impossible de sécuriser le fichier username temporaire."
                rm -f "${username_write_file}"
                return 1
            }

            if ! printf '%s' "${forgejo_username}" \
                > "${username_write_file}"; then

                print_error \
                    "Impossible d'écrire l'identifiant Forgejo."
                rm -f "${username_write_file}"
                return 1
            fi

            if ! mv "${username_write_file}" "${username_file}"; then
                print_error \
                    "Impossible d'enregistrer l'identifiant Forgejo."
                rm -f "${username_write_file}"
                return 1
            fi

            chmod 600 "${username_file}"

            token_write_file="$(
                mktemp "${project_path}/config/.forgejo.token.XXXXXX"
            )" || {
                print_error \
                    "Impossible de créer le fichier temporaire token."
                return 1
            }

            chmod 600 "${token_write_file}" || {
                print_error \
                    "Impossible de sécuriser le fichier token temporaire."
                rm -f "${token_write_file}"
                return 1
            }

            if ! printf '%s' "${forgejo_token}" \
                > "${token_write_file}"; then

                print_error \
                    "Impossible d'écrire le token Forgejo."
                rm -f "${token_write_file}"
                return 1
            fi

            if ! mv "${token_write_file}" "${token_file}"; then
                print_error \
                    "Impossible d'enregistrer le token Forgejo."
                rm -f "${token_write_file}"
                return 1
            fi

            chmod 600 "${token_file}"

            echo ""
            print_info \
                "Validation du token Forgejo auprès de l'API..."

            credentials_rc=0

            _forgejo_validate_credentials \
                "${project_path}" "${remote_name}" || credentials_rc=$?

            case "${credentials_rc}" in

                0)
                    print_success \
                        "Authentification Forgejo réussie."
                    return 0
                    ;;

                2)
                    print_error \
                        "Le token Forgejo fourni est invalide ou expiré."
                    ;;

                *)
                    print_error \
                        "Impossible de valider le token Forgejo."
                    ;;
            esac

            rm -f "${token_file}" "${username_file}"

            return 1
            ;;

        2)
            # ==================================================
            # Étape 4B : Génération automatique du token
            # ==================================================

            echo ""
            print_title "Création automatique du token Forgejo"
            echo ""

            print_info \
                "DIU va se connecter à Forgejo avec votre compte."

            print_info \
                "L'API Forgejo sera utilisée pour créer"

            print_info \
                "automatiquement un nouveau token."

            echo ""

            read -r -p \
                "Identifiant Forgejo : " forgejo_user

            if [[ -z "${forgejo_user}" ]]; then
                print_error \
                    "L'identifiant Forgejo ne peut pas être vide."
                return 1
            fi

            echo ""

            read -r -s -p \
                "Mot de passe Forgejo pour ${forgejo_user} : " \
                forgejo_password
            echo ""

            if [[ -z "${forgejo_password}" ]]; then
                print_error \
                    "Le mot de passe Forgejo ne peut pas être vide."
                unset forgejo_password
                return 1
            fi

            forgejo_username="${forgejo_user}"

            # ==================================================
            # Étape 5 : Authentification HTTP
            # ==================================================

            echo ""
            print_title "Authentification Forgejo"
            echo ""

            print_info \
                "Vérification des identifiants HTTP Forgejo..."

            netrc_file="$(mktemp)" || {
                print_error \
                    "Impossible de créer le fichier temporaire d'authentification."
                unset forgejo_password
                return 1
            }

            if ! chmod 600 "${netrc_file}"; then
                print_error \
                    "Impossible de sécuriser le fichier temporaire."
                rm -f "${netrc_file}"
                unset forgejo_password
                return 1
            fi

            if ! printf 'machine %s\nlogin %s\npassword %s\n' \
                "${forgejo_host}" \
                "${forgejo_user}" \
                "${forgejo_password}" \
                > "${netrc_file}"; then

                print_error \
                    "Impossible de préparer l'authentification HTTP."
                rm -f "${netrc_file}"
                unset forgejo_password
                return 1
            fi

            unset forgejo_password

            auth_http_code="$(
                _forgejo_curl -sS \
                    -o /dev/null \
                    -w '%{http_code}' \
                    --netrc-file "${netrc_file}" \
                    "${forgejo_base}/api/v1/user" \
                    2>/dev/null
            )"

            case "${auth_http_code}" in

                200)
                    print_success \
                        "Authentification HTTP Forgejo réussie."
                    ;;

                401)
                    print_error \
                        "Authentification HTTP Forgejo échouée."
                    print_error \
                        "Forgejo a refusé l'identifiant ou le mot de passe (HTTP 401)."
                    rm -f "${netrc_file}"
                    return 1
                    ;;

                403)
                    print_error \
                        "Authentification HTTP Forgejo refusée (HTTP 403)."
                    rm -f "${netrc_file}"
                    return 1
                    ;;

                000|"")
                    print_error \
                        "Impossible de contacter Forgejo."
                    rm -f "${netrc_file}"
                    return 1
                    ;;

                *)
                    print_error \
                        "Authentification HTTP Forgejo échouée."
                    print_error \
                        "Réponse inattendue de Forgejo : HTTP ${auth_http_code}"
                    rm -f "${netrc_file}"
                    return 1
                    ;;
            esac

            # ==================================================
            # Étape 6 : Création du token
            # ==================================================

            echo ""
            print_title "Création du token Forgejo"
            echo ""

            print_info \
                "Nom du token : diu-publish"

            print_info \
                "Scope demandé : write:repository write:package"

            print_info \
                "Création du token en cours..."

            token_http_response="$(
                    _forgejo_curl -sS \
                    -w '\n%{http_code}' \
                    --netrc-file "${netrc_file}" \
                    -X POST \
                    -H "Content-Type: application/json" \
                    -d '{
                        "name": "diu-publish",
						"scopes": [
							"write:repository",
							"write:package"
						]
                    }' \
                    "${forgejo_base}/api/v1/users/${forgejo_user}/tokens" \
                    2>/dev/null
            )"

            bootstrap_curl_rc=$?

            rm -f "${netrc_file}"

            if [[ "${bootstrap_curl_rc}" -ne 0 ]]; then
                print_error \
                    "Échec réseau lors de la création du token."
                print_error \
                    "Code curl : ${bootstrap_curl_rc}"
                return 1
            fi

            token_http_code="${token_http_response##*$'\n'}"
            token_http_body="${token_http_response%$'\n'*}"

            case "${token_http_code}" in

                200|201)
                    print_success \
                        "Token Forgejo créé avec succès."
                    ;;

                401)
                    print_error \
                        "Forgejo a refusé l'authentification lors de la création du token."
                    print_error \
                        "Réponse HTTP : 401"
                    return 1
                    ;;

                403)
                    print_error \
                        "Forgejo refuse la création du token pour ce compte."
                    print_error \
                        "Réponse HTTP : 403"
                    return 1
                    ;;

                400)
                    local error_msg=""

                    error_msg="$(
                        printf '%s' "${token_http_body}" |
                            jq -r \
                                '.message // .error // "erreur inconnue"' \
                                2>/dev/null
                    )"

                    print_error \
                        "Forgejo a refusé la requête de création du token (HTTP 400)."

                    print_error \
                        "Message Forgejo : ${error_msg}"

                    return 1
                    ;;

                *)
                    print_error \
                        "Échec de la création du token Forgejo."
                    print_error \
                        "Réponse HTTP : ${token_http_code}"
                    return 1
                    ;;
            esac

            # ==================================================
            # Étape 7 : Extraction du token
            # ==================================================

            if ! printf '%s' "${token_http_body}" |
                jq empty 2>/dev/null; then

                print_error \
                    "Réponse JSON invalide de Forgejo."
                return 1
            fi

            forgejo_token="$(
                printf '%s' "${token_http_body}" |
                    jq -r '.sha1 // .token // empty'
            )"

            if [[ -z "${forgejo_token}" ]]; then
                print_error \
                    "Forgejo n'a retourné aucun token exploitable."
                return 1
            fi

            # ==================================================
            # Étape 8 : Persistance locale
            # ==================================================

            if ! mkdir -p "${project_path}/config"; then
                print_error \
                    "Impossible de créer le répertoire config."
                return 1
            fi

            username_write_file="$(
                mktemp "${project_path}/config/.forgejo.username.XXXXXX"
            )" || {
                print_error \
                    "Impossible de créer le fichier temporaire username."
                return 1
            }

            chmod 600 "${username_write_file}" || {
                print_error \
                    "Impossible de sécuriser le fichier username."
                rm -f "${username_write_file}"
                return 1
            }

            if ! printf '%s' "${forgejo_username}" \
                > "${username_write_file}"; then

                print_error \
                    "Impossible d'écrire l'identifiant Forgejo."
                rm -f "${username_write_file}"
                return 1
            fi

            if ! mv "${username_write_file}" "${username_file}"; then
                print_error \
                    "Impossible d'enregistrer l'identifiant Forgejo."
                rm -f "${username_write_file}"
                return 1
            fi

            chmod 600 "${username_file}"

            token_write_file="$(
                mktemp "${project_path}/config/.forgejo.token.XXXXXX"
            )" || {
                print_error \
                    "Impossible de créer le fichier temporaire token."
                return 1
            }

            chmod 600 "${token_write_file}" || {
                print_error \
                    "Impossible de sécuriser le fichier token."
                rm -f "${token_write_file}"
                return 1
            }

            if ! printf '%s' "${forgejo_token}" \
                > "${token_write_file}"; then

                print_error \
                    "Impossible d'écrire le token Forgejo."
                rm -f "${token_write_file}"
                return 1
            fi

            if ! mv "${token_write_file}" "${token_file}"; then
                print_error \
                    "Impossible d'enregistrer le token Forgejo."
                rm -f "${token_write_file}"
                return 1
            fi

            chmod 600 "${token_file}"

            final_token_perms="$(
                stat -c %a "${token_file}" 2>/dev/null
            )"

            final_username_perms="$(
                stat -c %a "${username_file}" 2>/dev/null
            )"

            if [[ "${final_token_perms}" != "600" ]]; then
                print_error \
                    "Permissions invalides sur ${token_file} : ${final_token_perms}"
                rm -f "${token_file}"
                return 1
            fi

            if [[ "${final_username_perms}" != "600" ]]; then
                print_error \
                    "Permissions invalides sur ${username_file} : ${final_username_perms}"
                rm -f "${username_file}" "${token_file}"
                return 1
            fi

            print_success \
                "Token Forgejo enregistré dans ${token_file}"

            print_success \
                "Identifiant Forgejo enregistré dans ${username_file}"

            # ==================================================
            # Étape 9 : Validation du nouveau token
            # ==================================================

            echo ""
            print_title "Validation du nouveau token Forgejo"
            echo ""

            print_info \
                "Vérification du token auprès de l'API Forgejo..."

            credentials_rc=0

            _forgejo_validate_credentials \
                "${project_path}" "${remote_name}" || credentials_rc=$?

            case "${credentials_rc}" in

                0)
                    print_success \
                        "Nouveau token Forgejo validé avec succès."
                    return 0
                    ;;

                2)
                    print_error \
                        "Le token nouvellement créé est refusé par Forgejo."
                    ;;

                *)
                    print_error \
                        "Impossible de valider le nouveau token Forgejo."
                    ;;
            esac

            return 1
            ;;

        *)
            print_error \
                "Choix invalide. Sélectionnez 1 ou 2."
            return 1
            ;;
    esac
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

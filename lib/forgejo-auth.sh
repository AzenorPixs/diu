#!/usr/bin/env bash
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

. "$BASH_SCRIPT_PATH/lib/logging.sh"
. "$BASH_SCRIPT_PATH/lib/git-auth.sh"


# ==========================================================
# Résolution du remote Forgejo
# ==========================================================

_forgejo_resolve_remote() {
    local project_path="${1:-}"

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
            git -C "${project_path}" remote get-url origin 2>/dev/null
    )"

    if [[ -z "${remote_url}" ]]; then
        print_error \
            "forgejo-auth : impossible de récupérer l'URL du remote origin."
        return 1
    fi

    if [[ "${remote_url}" != https://* ]]; then
        print_error \
            "forgejo-auth : le remote origin doit utiliser HTTPS."
        return 1
    fi

    url_path="${remote_url#https://}"
    url_path="${url_path%/}"

    authority="${url_path%%/*}"

    if [[ "${authority}" == *"@"* ]]; then
        print_error \
            "forgejo-auth : l'URL du remote origin contient des informations d'identification interdites."
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


# ==========================================================
# Lecture du username
# ==========================================================

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


# ==========================================================
# Lecture du token
# ==========================================================

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


# ==========================================================
# Création d'un fichier curl temporaire contenant le token
#
# Le token n'est jamais placé dans les arguments de curl.
# ==========================================================

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


# ==========================================================
# Préparation du contexte Forgejo
#
# Cette fonction est utilisée par les opérations Git et API.
# ==========================================================

_forgejo_prepare_context() {
    local project_path="${1:-}"

    if [[ -z "${project_path}" ]]; then
        print_error "_forgejo_prepare_context : project_path est vide."
        return 1
    fi

    if [[ ! -d "${project_path}" ]]; then
        print_error \
            "Projet introuvable : ${project_path}"
        return 1
    fi

    if ! _forgejo_resolve_remote "${project_path}"; then
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

_forgejo_api_request() {
    local project_path="${1:-}"
    local method="${2:-}"
    local endpoint="${3:-}"
    local payload="${4:-}"
    local upload_file="${5:-}"

    local curl_config=""
    local response=""
    local curl_rc=0

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
            curl -sS \
                -w '\n%{http_code}' \
                --config "${curl_config}" \
                -X "${method}" \
                -F "attachment=@${upload_file}" \
                "${forgejo_base}${endpoint}" \
                2>/dev/null
        )"; then
            curl_rc=0
        else
            curl_rc=$?
        fi

    elif [[ -n "${payload}" ]]; then

        if response="$(
            curl -sS \
                -w '\n%{http_code}' \
                --config "${curl_config}" \
                -X "${method}" \
                -H "Content-Type: application/json" \
                -d "${payload}" \
                "${forgejo_base}${endpoint}" \
                2>/dev/null
        )"; then
            curl_rc=0
        else
            curl_rc=$?
        fi

    else

        if response="$(
            curl -sS \
                -w '\n%{http_code}' \
                --config "${curl_config}" \
                -X "${method}" \
                "${forgejo_base}${endpoint}" \
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


# ==========================================================
# API GET
#
# forgejo_api_get <project_path> <endpoint>
# ==========================================================

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


# ==========================================================
# API POST JSON
#
# forgejo_api_post_json <project_path> <endpoint> <payload>
# ==========================================================

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


# ==========================================================
# API upload
#
# forgejo_api_upload <project_path> <endpoint> <file>
# ==========================================================

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

_forgejo_validate_credentials() {
    local project_path="${1:-}"

    local response=""
    local http_code=""
    local http_body=""
    local curl_rc=0

    if [[ -z "${project_path}" ]]; then
        print_error \
            "_forgejo_validate_credentials : project_path vide."
        return 1
    fi

    if ! _forgejo_prepare_context "${project_path}"; then
        return 1
    fi

    if response="$(
        forgejo_api_get \
            "${project_path}" \
            "/api/v1/user"
    )"; then
        curl_rc=0
    else
        curl_rc=$?
    fi

    if [[ "${curl_rc}" -ne 0 ]]; then
        return 1
    fi

    http_code="${response##*$'\n'}"
    http_body="${response%$'\n'*}"

    case "${http_code}" in

        200)
            if ! printf '%s' "${http_body}" |
                jq empty >/dev/null 2>&1; then

                print_error \
                    "Réponse JSON invalide de Forgejo."
                return 1
            fi

            return 0
            ;;

        401)
            print_error \
                "Token Forgejo invalide ou expiré."
            return 2
            ;;

        403)
            print_error \
                "Forgejo refuse l'accès avec ce token."
            return 2
            ;;

        000|"")
            print_error \
                "Impossible de contacter Forgejo."
            return 1
            ;;

        *)
            print_error \
                "Réponse inattendue lors de la validation du token : HTTP ${http_code}"

            if [[ -n "${http_body}" ]]; then
                local error_message=""
                error_message="$(
                    printf '%s' "${http_body}" |
                        jq -r '.message // empty' 2>/dev/null
                )"

                if [[ -n "${error_message}" ]]; then
                    print_error "${error_message}"
                fi
            fi

            return 1
            ;;
    esac
}


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

forgejo_ensure_credentials() {
    local project_path="${1:-}"

    local token_file=""
    local username_file=""

    local forgejo_user=""
    local forgejo_password=""
    local token_choice=""

    local netrc_file=""
    local auth_http_code=""

    local token_http_response=""
    local token_http_code=""
    local token_http_body=""
    local token_curl_rc=0

    local forgejo_token_generated=""

    local username_write_file=""
    local token_write_file=""

    local credentials_rc=0

    if [[ -z "${project_path}" ]]; then
        print_error \
            "forgejo_ensure_credentials : project_path vide."
        return 1
    fi

    if [[ ! -d "${project_path}" ]]; then
        print_error \
            "Projet introuvable : ${project_path}"
        return 1
    fi

    token_file="${project_path}/config/forgejo.token"
    username_file="${project_path}/config/forgejo.username"

    # ------------------------------------------------------
    # Résolution Forgejo
    # ------------------------------------------------------

    if ! _forgejo_resolve_remote "${project_path}"; then
        return 1
    fi

    # ------------------------------------------------------
    # Credentials existants
    # ------------------------------------------------------

    if [[ -f "${token_file}" && -f "${username_file}" ]]; then

        if ! _forgejo_read_username "${project_path}"; then
            return 1
        fi

        if ! _forgejo_read_token "${project_path}"; then
            return 1
        fi

        print_info \
            "Vérification des credentials Forgejo locaux..."

        credentials_rc=0

        _forgejo_validate_credentials \
            "${project_path}" || credentials_rc=$?

        case "${credentials_rc}" in

            0)
                print_success \
                    "Authentification Forgejo locale validée."
                return 0
                ;;

            2)
                print_error \
                    "Les credentials Forgejo locaux sont invalides ou expirés."

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
        print_info \
            "Les credentials Forgejo locaux sont incomplets."
    fi

    # ------------------------------------------------------
    # Choix du mode de configuration
    # ------------------------------------------------------

    print_info \
        "Le token Forgejo est absent ou invalide."

    echo ""
    echo "Comment souhaitez-vous configurer les credentials Forgejo ?"
    echo ""
    echo "  1) Saisir un token Forgejo existant"
    echo "  2) Créer automatiquement un nouveau token via l'API Forgejo"
    echo ""

    read -r -p "Votre choix [1-2] : " token_choice

    case "${token_choice}" in

        # ==================================================
        # Token existant
        # ==================================================

        1)

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
                "Token Forgejo pour ${forgejo_user} : " \
                forgejo_token

            echo ""

            if [[ -z "${forgejo_token}" ]]; then
                print_error \
                    "Le token Forgejo ne peut pas être vide."
                unset forgejo_token
                return 1
            fi

            forgejo_username="${forgejo_user}"

            if ! mkdir -p "${project_path}/config"; then
                print_error \
                    "Impossible de créer le répertoire config."
                unset forgejo_token
                return 1
            fi

            username_write_file="$(
                mktemp "${project_path}/config/.forgejo.username.XXXXXX"
            )" || {
                print_error \
                    "Impossible de créer le fichier temporaire username."
                unset forgejo_token
                return 1
            }

            chmod 600 "${username_write_file}" || {
                rm -f "${username_write_file}"
                unset forgejo_token
                return 1
            }

            if ! printf '%s' "${forgejo_username}" \
                > "${username_write_file}"; then

                rm -f "${username_write_file}"
                unset forgejo_token
                return 1
            fi

            if ! mv "${username_write_file}" "${username_file}"; then
                rm -f "${username_write_file}"
                unset forgejo_token
                return 1
            fi

            chmod 600 "${username_file}"

            token_write_file="$(
                mktemp "${project_path}/config/.forgejo.token.XXXXXX"
            )" || {
                print_error \
                    "Impossible de créer le fichier temporaire token."
                rm -f "${username_file}"
                unset forgejo_token
                return 1
            }

            chmod 600 "${token_write_file}" || {
                rm -f "${token_write_file}"
                rm -f "${username_file}"
                unset forgejo_token
                return 1
            }

            if ! printf '%s' "${forgejo_token}" \
                > "${token_write_file}"; then

                rm -f "${token_write_file}"
                rm -f "${username_file}"
                unset forgejo_token
                return 1
            fi

            if ! mv "${token_write_file}" "${token_file}"; then
                rm -f "${token_write_file}"
                rm -f "${username_file}"
                unset forgejo_token
                return 1
            fi

            chmod 600 "${token_file}"

            unset forgejo_token

            print_info \
                "Validation du token Forgejo..."

            credentials_rc=0

            _forgejo_validate_credentials \
                "${project_path}" || credentials_rc=$?

            if [[ "${credentials_rc}" -eq 0 ]]; then
                print_success \
                    "Authentification Forgejo réussie."
                return 0
            fi

            rm -f "${token_file}" "${username_file}"

            if [[ "${credentials_rc}" -eq 2 ]]; then
                print_error \
                    "Le token Forgejo fourni est invalide ou expiré."
            else
                print_error \
                    "Impossible de valider le token Forgejo."
            fi

            return 1
            ;;

        # ==================================================
        # Génération automatique
        # ==================================================

        2)

            echo ""
            print_title "Création automatique du token Forgejo"
            echo ""

            print_info \
                "DIU va se connecter à Forgejo avec votre compte."

            print_info \
                "L'API Forgejo sera utilisée pour créer automatiquement un token."

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

            # ------------------------------------------------
            # Authentification temporaire par .netrc
            # ------------------------------------------------

            netrc_file="$(mktemp)" || {
                print_error \
                    "Impossible de créer le fichier temporaire d'authentification."
                unset forgejo_password
                return 1
            }

            chmod 600 "${netrc_file}" || {
                rm -f "${netrc_file}"
                unset forgejo_password
                return 1
            }

            if ! printf \
                'machine %s\nlogin %s\npassword %s\n' \
                "${forgejo_host}" \
                "${forgejo_user}" \
                "${forgejo_password}" \
                > "${netrc_file}"; then

                rm -f "${netrc_file}"
                unset forgejo_password
                return 1
            fi

            unset forgejo_password

            auth_http_code="$(
                curl -sS \
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
                        "Identifiant ou mot de passe Forgejo invalide."
                    rm -f "${netrc_file}"
                    return 1
                    ;;

                403)
                    print_error \
                        "Authentification Forgejo refusée (HTTP 403)."
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
                        "Réponse inattendue de Forgejo : HTTP ${auth_http_code}"
                    rm -f "${netrc_file}"
                    return 1
                    ;;
            esac

            # ------------------------------------------------
            # Création du token
            # ------------------------------------------------

            print_title "Création du token Forgejo"

            print_info "Nom du token : diu-publish"
            print_info "Scope demandé : write:repository"

            token_http_response="$(
                curl -sS \
                    -w '\n%{http_code}' \
                    --netrc-file "${netrc_file}" \
                    -X POST \
                    -H "Content-Type: application/json" \
                    -d '{
                        "name": "diu-publish",
                        "scopes": [
                            "write:repository"
                        ]
                    }' \
                    "${forgejo_base}/api/v1/users/${forgejo_user}/tokens" \
                    2>/dev/null
            )"

            token_curl_rc=$?

            rm -f "${netrc_file}"

            if [[ "${token_curl_rc}" -ne 0 ]]; then
                print_error \
                    "Échec réseau lors de la création du token."
                return 1
            fi

            token_http_code="${token_http_response##*$'\n'}"
            token_http_body="${token_http_response%$'\n'*}"

            case "${token_http_code}" in

                200|201)
                    print_success \
                        "Token Forgejo créé avec succès."
                    ;;

                400)
                    print_error \
                        "Forgejo a refusé la requête de création du token (HTTP 400)."
                    return 1
                    ;;

                401)
                    print_error \
                        "Forgejo a refusé l'authentification (HTTP 401)."
                    return 1
                    ;;

                403)
                    print_error \
                        "Forgejo refuse la création du token (HTTP 403)."
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

            if ! printf '%s' "${token_http_body}" |
                jq empty >/dev/null 2>&1; then

                print_error \
                    "Réponse JSON invalide de Forgejo."
                return 1
            fi

            forgejo_token_generated="$(
                printf '%s' "${token_http_body}" |
                    jq -r '.sha1 // .token // empty'
            )"

            if [[ -z "${forgejo_token_generated}" ]]; then
                print_error \
                    "Forgejo n'a retourné aucun token exploitable."
                return 1
            fi

            forgejo_token="${forgejo_token_generated}"
            unset forgejo_token_generated

            # ------------------------------------------------
            # Persistance
            # ------------------------------------------------

            if ! mkdir -p "${project_path}/config"; then
                print_error \
                    "Impossible de créer le répertoire config."
                unset forgejo_token
                return 1
            fi

            username_write_file="$(
                mktemp "${project_path}/config/.forgejo.username.XXXXXX"
            )" || {
                unset forgejo_token
                return 1
            }

            chmod 600 "${username_write_file}" || {
                rm -f "${username_write_file}"
                unset forgejo_token
                return 1
            }

            if ! printf '%s' "${forgejo_username}" \
                > "${username_write_file}"; then

                rm -f "${username_write_file}"
                unset forgejo_token
                return 1
            fi

            if ! mv "${username_write_file}" "${username_file}"; then
                rm -f "${username_write_file}"
                unset forgejo_token
                return 1
            fi

            chmod 600 "${username_file}"

            token_write_file="$(
                mktemp "${project_path}/config/.forgejo.token.XXXXXX"
            )" || {
                rm -f "${username_file}"
                unset forgejo_token
                return 1
            }

            chmod 600 "${token_write_file}" || {
                rm -f "${token_write_file}"
                rm -f "${username_file}"
                unset forgejo_token
                return 1
            }

            if ! printf '%s' "${forgejo_token}" \
                > "${token_write_file}"; then

                rm -f "${token_write_file}"
                rm -f "${username_file}"
                unset forgejo_token
                return 1
            fi

            if ! mv "${token_write_file}" "${token_file}"; then
                rm -f "${token_write_file}"
                rm -f "${username_file}"
                unset forgejo_token
                return 1
            fi

            chmod 600 "${token_file}"

            unset forgejo_token

            print_success \
                "Credentials Forgejo enregistrés."

            # ------------------------------------------------
            # Validation finale
            # ------------------------------------------------

            credentials_rc=0

            _forgejo_validate_credentials \
                "${project_path}" || credentials_rc=$?

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

            rm -f "${token_file}" "${username_file}"

            return 1
            ;;

        *)
            print_error \
                "Choix invalide. Sélectionnez 1 ou 2."
            return 1
            ;;
    esac
}


# ==========================================================
# Git fetch authentifié
# ==========================================================

forgejo_git_fetch() {
    local project_path="${1:-}"

    if [[ -z "${project_path}" ]]; then
        print_error \
            "forgejo_git_fetch : project_path vide."
        return 1
    fi

    if ! forgejo_ensure_credentials "${project_path}"; then
        return 1
    fi

    if ! _forgejo_read_username "${project_path}"; then
        return 1
    fi

    if ! _forgejo_read_token "${project_path}"; then
        return 1
    fi

    git_with_token \
        "${project_path}" \
        "${forgejo_username}" \
        "${forgejo_token}" \
        fetch origin
}


# ==========================================================
# Git push authentifié
#
# forgejo_git_push <project_path> [push_args...]
# ==========================================================

forgejo_git_push() {
    local project_path="${1:-}"
    shift || true

    local push_args=("${@}")

    if [[ -z "${project_path}" ]]; then
        print_error \
            "forgejo_git_push : project_path vide."
        return 1
    fi

    if ! forgejo_ensure_credentials "${project_path}"; then
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

    if [[ ${#push_args[@]} -gt 0 ]]; then

        git_with_token \
            "${project_path}" \
            "${forgejo_username}" \
            "${forgejo_token}" \
            push \
            "${push_args[@]}"

    else

        git_with_token \
            "${project_path}" \
            "${forgejo_username}" \
            "${forgejo_token}" \
            push

    fi
}

#!/usr/bin/env bash
# Provider d'authentification Git HTTPS spécifique à Forgejo
# Résolution Forgejo + validation token/username + délégation à git-auth

. "$BASH_SCRIPT_PATH/lib/logging.sh"
. "$BASH_SCRIPT_PATH/lib/git-auth.sh"

# Déduit les informations Forgejo depuis l'URL du remote origin.
# Variables en sortie (scope appelant) :
#   forgejo_host, forgejo_owner, forgejo_repo
# Retourne 0 si succès, 1 si URL non conforme.
#
# Format attendu : https://<host>/<owner>/<repo>[.git]

_forgejo_resolve_remote() {
    local project_path="${1:-}"

    local remote_url=""
    local url_path=""
    local authority=""
    local -a url_segments=()
    local segment_count=""

    remote_url="$(runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" remote get-url origin 2>/dev/null)"

    if [[ -z "${remote_url}" ]]; then
        print_error "forgejo-auth : impossible de récupérer l'URL du remote origin."
        return 1
    fi

    # Schéma HTTPS obligatoire
    if [[ "${remote_url}" != https://* ]]; then
        print_error "forgejo-auth : l'URL du remote origin n'est pas une URL HTTPS compatible."
        return 1
    fi

    url_path="${remote_url#https://}"

    # Supprimer trailing slash éventuel
    url_path="${url_path%/}"

    # Rejeter les URLs avec userinfo (credentials dans l'authority)
    authority="${url_path%%/*}"
    if [[ "${authority}" == *"@"* ]]; then
        print_error "forgejo-auth : l'URL du remote origin contient des informations d'identification interdites."
        return 1
    fi

    # Découper par / — attend exactement 3 segments : host / owner / repo
    IFS='/' read -ra url_segments <<< "${url_path}"
    segment_count="${#url_segments[@]}"

    if [[ "${segment_count}" -ne 3 ]]; then
        print_error "forgejo-auth : l'URL du remote origin ne respecte pas le format attendu (host/owner/repo)."
        return 1
    fi

    forgejo_host="${url_segments[0]}"
    forgejo_owner="${url_segments[1]}"
    forgejo_repo="${url_segments[2]}"

    # Host non vide
    if [[ -z "${forgejo_host}" ]]; then
        print_error "forgejo-auth : le host Forgejo est vide."
        return 1
    fi

    # Owner non vide
    if [[ -z "${forgejo_owner}" ]]; then
        print_error "forgejo-auth : le propriétaire du repository est vide."
        return 1
    fi

    # Repo non vide avant suppression de .git
    if [[ -z "${forgejo_repo}" ]]; then
        print_error "forgejo-auth : le nom du repository est vide."
        return 1
    fi

    # Supprimer le suffixe .git optionnel
    forgejo_repo="${forgejo_repo%.git}"

    # Repo non vide après suppression de .git
    if [[ -z "${forgejo_repo}" ]]; then
        print_error "forgejo-auth : le nom du repository est vide après suppression du suffixe .git."
        return 1
    fi

    forgejo_base="https://${forgejo_host}"

    return 0
}

# Lit et valide config/forgejo.username.
# Vérifie existence, permissions 600, contenu non vide.
# Écrit le résultat dans forgejo_username (scope appelant).
# Retourne 0 si succès, 1 sinon.

_forgejo_read_username() {
    local project_path="${1:-}"
    local username_file="${project_path}/config/forgejo.username"
    local username_perms=""

    if [[ ! -f "${username_file}" ]]; then
        print_error "forgejo-auth : fichier manquant : ${username_file}"
        print_error "Créez ce fichier avec votre identifiant Forgejo (chmod 600)."
        print_error "Exemple : printf '%s' 'votre_identifiant' > ${username_file} && chmod 600 ${username_file}"
        return 1
    fi

    username_perms="$(stat -c %a "${username_file}" 2>/dev/null)"

    if [[ "${username_perms}" != "600" ]]; then
        print_error "forgejo-auth : permissions invalides sur ${username_file} : ${username_perms} (attendu : 600)"
        print_error "Corrigez avec : chmod 600 ${username_file}"
        return 1
    fi

    IFS= read -r forgejo_username < "${username_file}"

    if [[ -z "${forgejo_username}" ]]; then
        print_error "forgejo-auth : le fichier ${username_file} est vide."
        return 1
    fi

    return 0
}

# Lit et valide config/forgejo.token.
# Vérifie existence, permissions 600, contenu non vide.
# Écrit le résultat dans forgejo_token (scope appelant).
# Retourne 0 si succès, 1 sinon.

_forgejo_read_token() {
    local project_path="${1:-}"
    local token_file="${project_path}/config/forgejo.token"
    local token_perms=""

    if [[ ! -f "${token_file}" ]]; then
        print_error "forgejo-auth : fichier token manquant : ${token_file}"
        return 1
    fi

    token_perms="$(stat -c %a "${token_file}" 2>/dev/null)"

    if [[ "${token_perms}" != "600" ]]; then
        print_error "forgejo-auth : permissions invalides sur ${token_file} : ${token_perms} (attendu : 600)"
        print_error "Corrigez avec : chmod 600 ${token_file}"
        return 1
    fi

    IFS= read -r forgejo_token < "${token_file}"

    if [[ -z "${forgejo_token}" ]]; then
        print_error "forgejo-auth : le fichier token est vide : ${token_file}"
        return 1
    fi

    return 0
}

# Exécute un git fetch authentifié vers Forgejo.
# forgejo_git_fetch <project_path>
# Retourne le code de sortie de git fetch.

forgejo_git_fetch() {
    local project_path="${1:-}"
    local forgejo_host=""
    local forgejo_base=""
    local forgejo_owner=""
    local forgejo_repo=""
    local forgejo_username=""
    local forgejo_token=""

    if [[ -z "${project_path}" ]]; then
        print_error "forgejo_git_fetch : project_path est vide."
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

    git_with_token "${project_path}" "${forgejo_username}" "${forgejo_token}" fetch origin
}

# Exécute un git push authentifié vers Forgejo.
# forgejo_git_push <project_path> [push_args...]
# Les push_args reproduisent la sémantique exacte de git_push() :
#   premier push : forgejo_git_push "${project_path}" -u "${remote_name}" "${current_branch}"
#   push normal   : forgejo_git_push "${project_path}"
# Retourne le code de sortie de git push.

forgejo_git_push() {
    local project_path="${1:-}"
    shift 2>/dev/null || true
    local push_args=("${@}")
    local forgejo_username=""
    local forgejo_token=""

    if [[ -z "${project_path}" ]]; then
        print_error "forgejo_git_push : project_path est vide."
        return 1
    fi

    # ----------------------------------------------------------
    # Initialisation / validation des credentials Forgejo
    # ----------------------------------------------------------

    if ! forgejo_ensure_credentials "${project_path}"; then
        print_error \
            "forgejo_git_push : impossible d'initialiser les credentials Forgejo."
        return 1
    fi

    # ----------------------------------------------------------
    # Lecture des credentials
    # ----------------------------------------------------------

    if ! _forgejo_read_username "${project_path}"; then
        return 1
    fi

    if ! _forgejo_read_token "${project_path}"; then
        return 1
    fi

    # ----------------------------------------------------------
    # Push authentifié
    #
    # Si le dépôt Forgejo n'existe pas encore et que :
    #
    #   ENABLE_PUSH_CREATE_USER = true
    #
    # Forgejo crée automatiquement le dépôt lors du premier push.
    # ----------------------------------------------------------

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

# Exécute une vérification des Crédiential, et les regénère si pas OK

forgejo_ensure_credentials() {
    local project_path="${1:-}"

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

    if ! _forgejo_resolve_remote "${project_path}"; then
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

        # Les fonctions _forgejo_read_* renseignent les variables
        # globales forgejo_username et forgejo_token.

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

            # --------------------------------------------------
            # Persistance du username
            # --------------------------------------------------

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

            # --------------------------------------------------
            # Persistance du token
            # --------------------------------------------------

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

            # --------------------------------------------------
            # Validation réelle du token
            # --------------------------------------------------

            echo ""
            print_info \
                "Validation du token Forgejo auprès de l'API..."

            credentials_rc=0

            _forgejo_validate_credentials \
                "${project_path}" || credentials_rc=$?

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
                "Scope demandé : write:repository"

            print_info \
                "Création du token en cours..."

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
                    print_error \
                        "Forgejo a refusé la requête de création du token."
                    print_error \
                        "Réponse HTTP : 400"
                    print_error \
                        "Le payload envoyé à l'API Forgejo est invalide."
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

            # --------------------------------------------------
            # Username
            # --------------------------------------------------

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

            # --------------------------------------------------
            # Token
            # --------------------------------------------------

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

            return 1
            ;;

        *)
            print_error \
                "Choix invalide. Sélectionnez 1 ou 2."
            return 1
            ;;
    esac
}

# Exécute une validation des Crédiential

_forgejo_validate_credentials() {
    local project_path="${1:-}"
    local http_code=""

    if [[ -z "${project_path}" ]]; then
        print_error "_forgejo_validate_credentials : project_path est vide."
        return 1
    fi

    if [[ ! -d "${project_path}" ]]; then
        print_error \
            "_forgejo_validate_credentials : projet introuvable : ${project_path}"
        return 1
    fi

    # ----------------------------------------------------------
    # Lecture des credentials locaux
    # ----------------------------------------------------------

    if ! _forgejo_read_username "${project_path}"; then
        return 1
    fi

    if ! _forgejo_read_token "${project_path}"; then
        return 1
    fi

    if [[ -z "${forgejo_username}" ]]; then
        print_error "_forgejo_validate_credentials : username vide."
        return 1
    fi

    if [[ -z "${forgejo_token}" ]]; then
        print_error "_forgejo_validate_credentials : token vide."
        return 1
    fi

    # ----------------------------------------------------------
    # Vérification de l'URL Forgejo
    # ----------------------------------------------------------

    if [[ -z "${forgejo_base}" ]]; then
        print_error \
            "_forgejo_validate_credentials : URL Forgejo non initialisée."
        return 1
    fi

    # ----------------------------------------------------------
    # Vérification du dépôt
    #
    # Le dépôt peut ne pas encore exister.
    #
    # Dans ce cas Forgejo peut le créer automatiquement lors
    # du premier git push grâce à :
    #
    #   ENABLE_PUSH_CREATE_USER = true
    #
    # ----------------------------------------------------------

    http_code="$(
        curl -sS \
            -o /dev/null \
            -w '%{http_code}' \
            -u "${forgejo_username}:${forgejo_token}" \
            "${forgejo_base}/api/v1/repos/${forgejo_owner}/${forgejo_repo}" \
            2>/dev/null
    )"

    case "${http_code}" in

        200)
            print_success \
                "Dépôt Forgejo ${forgejo_owner}/${forgejo_repo} accessible."
            return 0
            ;;

        404)
            print_info \
                "Le dépôt Forgejo ${forgejo_owner}/${forgejo_repo} n'existe pas encore."
            print_info \
                "Le premier git push demandera à Forgejo de le créer automatiquement."
            return 0
            ;;

        401)
            print_error \
                "_forgejo_validate_credentials : token Forgejo invalide ou expiré."
            return 2
            ;;

        403)
            print_error \
                "_forgejo_validate_credentials : accès Forgejo refusé (HTTP 403)."
            print_error \
                "Vérifiez les droits du token Forgejo."
            return 2
            ;;

        000|"")
            print_error \
                "_forgejo_validate_credentials : impossible de contacter Forgejo."
            return 1
            ;;

        *)
            print_error \
                "_forgejo_validate_credentials : réponse Forgejo inattendue (HTTP ${http_code})."
            return 1
            ;;

    esac
}

# Exécute une validation du token

_forgejo_validate_publish_token() {

	# ----------------------------------------------------------
	# Validation du token Forgejo pour les opérations de publication
	#
	# Vérifie :
	#   1. authentification auprès de l'API Forgejo
	#   2. accès API au repository cible
	#
	# Le repository peut ne pas encore exister.
	#
	# Retour :
	#   0 = token utilisable
	#   2 = token invalide ou droits insuffisants
	#   1 = erreur technique
	# ----------------------------------------------------------

    local project_path="${1:-}"

    local forgejo_http_code=""
    local repository_http_code=""

    if [[ -z "${project_path}" ]]; then
        print_error \
            "_forgejo_validate_publish_token : project_path est vide."
        return 1
    fi

    if [[ ! -d "${project_path}" ]]; then
        print_error \
            "_forgejo_validate_publish_token : projet introuvable : ${project_path}"
        return 1
    fi

    # ----------------------------------------------------------
    # Résolution du remote Forgejo
    # ----------------------------------------------------------

    if ! _forgejo_resolve_remote "${project_path}"; then
        return 1
    fi

    # ----------------------------------------------------------
    # Lecture des credentials locaux
    # ----------------------------------------------------------

    if ! _forgejo_read_username "${project_path}"; then
        return 1
    fi

    if ! _forgejo_read_token "${project_path}"; then
        return 1
    fi

    if [[ -z "${forgejo_username}" ]]; then
        print_error \
            "_forgejo_validate_publish_token : username vide."
        return 1
    fi

    if [[ -z "${forgejo_token}" ]]; then
        print_error \
            "_forgejo_validate_publish_token : token vide."
        return 1
    fi

    # ==========================================================
    # Étape 1 : validation de l'identité API
    # ==========================================================

    print_info "Vérification de l'identité du token Forgejo..."

    forgejo_http_code="$(
        curl -sS \
            -o /dev/null \
            -w '%{http_code}' \
            -H "Authorization: token ${forgejo_token}" \
            "${forgejo_base}/api/v1/user" \
            2>/dev/null
    )"

    case "${forgejo_http_code}" in

        200)
            print_success \
                "Token Forgejo authentifié auprès de l'API."
            ;;

        401)
            print_error \
                "Token Forgejo invalide ou expiré (HTTP 401)."
            return 2
            ;;

        403)
            print_error \
                "Token Forgejo refusé par l'API (HTTP 403)."
            print_error \
                "Le token ne permet pas l'accès API requis."
            return 2
            ;;

        000|"")
            print_error \
                "Impossible de contacter l'API Forgejo."
            return 1
            ;;

        *)
            print_error \
                "Réponse inattendue de l'API Forgejo : HTTP ${forgejo_http_code}"
            return 1
            ;;
    esac

    # ==========================================================
    # Étape 2 : validation de l'accès au repository
    # ==========================================================

    print_info \
        "Vérification de l'accès API au repository ${forgejo_owner}/${forgejo_repo}..."

    repository_http_code="$(
        curl -sS \
            -o /dev/null \
            -w '%{http_code}' \
            -H "Authorization: token ${forgejo_token}" \
            "${forgejo_base}/api/v1/repos/${forgejo_owner}/${forgejo_repo}" \
            2>/dev/null
    )"

    case "${repository_http_code}" in

        200)
            print_success \
                "Accès API au repository Forgejo validé."
            ;;

        404)
            print_info \
                "Le repository ${forgejo_owner}/${forgejo_repo} n'existe pas encore."
            print_info \
                "Le token reste valide pour le premier git push."
            ;;

        401)
            print_error \
                "Token Forgejo refusé pour le repository (HTTP 401)."
            return 2
            ;;

        403)
            print_error \
                "Accès API au repository refusé (HTTP 403)."
            print_error \
                "Le token ne possède probablement pas le scope write:repository."
            return 2
            ;;

        000|"")
            print_error \
                "Impossible de contacter Forgejo."
            return 1
            ;;

        *)
            print_error \
                "Réponse inattendue lors de la vérification du repository : HTTP ${repository_http_code}"
            return 1
            ;;
    esac

    return 0
}

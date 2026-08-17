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
    local forgejo_host=""
    local forgejo_base=""
    local forgejo_owner=""
    local forgejo_repo=""
    local forgejo_username=""
    local forgejo_token=""

    if [[ -z "${project_path}" ]]; then
        print_error "forgejo_git_push : project_path est vide."
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

    if [[ ${#push_args[@]} -gt 0 ]]; then
        git_with_token "${project_path}" "${forgejo_username}" "${forgejo_token}" push "${push_args[@]}"
    else
        git_with_token "${project_path}" "${forgejo_username}" "${forgejo_token}" push
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
    local forgejo_password=""
    local forgejo_token=""
    local token_file=""
    local username_file=""
    local create_token=""
    local netrc_file=""
    local token_http_response=""
    local token_http_code=""
    local token_http_body=""
    local bootstrap_curl_rc=0

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

    # ----------------------------------------------------------
    # Étape 1 : Déduction des informations Forgejo
    # ----------------------------------------------------------

    if ! _forgejo_resolve_remote "${project_path}"; then
        return 1
    fi

    # ----------------------------------------------------------
    # Étape 2 : Credentials déjà présents
    # ----------------------------------------------------------

    if [[ -f "${token_file}" && -f "${username_file}" ]]; then

        if ! _forgejo_read_token "${project_path}"; then
            return 1
        fi

        if ! _forgejo_read_username "${project_path}"; then
            return 1
        fi

        print_success "Authentification Forgejo locale validée."
        return 0
    fi

    # ----------------------------------------------------------
    # Étape 3 : Bootstrap des credentials
    # ----------------------------------------------------------

    print_info "Les credentials Forgejo locaux sont incomplets."

    read -r -p \
        "Créer automatiquement un token Forgejo ? [o/N] : " \
        create_token

    case "${create_token}" in
        o|O|oui|OUI|y|Y|yes|YES)
            ;;
        *)
            print_error \
                "Création de token annulée. Veuillez créer manuellement le token dans Forgejo."
            return 1
            ;;
    esac

    read -r -p "Identifiant Forgejo : " forgejo_user

    if [[ -z "${forgejo_user}" ]]; then
        print_error "L'identifiant Forgejo ne peut pas être vide."
        return 1
    fi

    read -r -s -p "Mot de passe Forgejo : " forgejo_password
    echo ""

    if [[ -z "${forgejo_password}" ]]; then
        print_error "Le mot de passe ne peut pas être vide."
        return 1
    fi

    # ----------------------------------------------------------
    # Étape 4 : Fichier netrc temporaire
    # ----------------------------------------------------------

    netrc_file="$(mktemp)" || {
        print_error \
            "Impossible de créer un fichier temporaire pour l'authentification."
        unset forgejo_password
        return 1
    }

    if ! chmod 600 "${netrc_file}"; then
        print_error "Échec des permissions sur le fichier temporaire."
        rm -f "${netrc_file}"
        unset forgejo_password
        return 1
    fi

    if ! printf 'machine %s\nlogin %s\npassword %s\n' \
        "${forgejo_host}" \
        "${forgejo_user}" \
        "${forgejo_password}" \
        > "${netrc_file}"; then

        print_error "Échec de l'écriture du fichier temporaire."
        rm -f "${netrc_file}"
        unset forgejo_password
        return 1
    fi

    unset forgejo_password

    # ----------------------------------------------------------
    # Étape 5 : Création du token Forgejo
    # ----------------------------------------------------------

    if token_http_response="$(curl -s -w '\n%{http_code}' \
        --netrc-file "${netrc_file}" \
        -X POST \
        -H "Content-Type: application/json" \
        -d "$(jq -n \
            --arg name "diu-publish" \
            --arg owner "${forgejo_owner}" \
            --arg repo "${forgejo_repo}" \
            '{
                name: $name,
                scopes: ["write:repository"],
                repositories: [{owner: $owner, name: $repo}]
            }')" \
        "${forgejo_base}/api/v1/users/${forgejo_user}/tokens" \
        2>/dev/null)"; then

        bootstrap_curl_rc=0
    else
        bootstrap_curl_rc=$?
    fi

    rm -f "${netrc_file}"

    if [[ "${bootstrap_curl_rc}" -ne 0 ]]; then
        print_error \
            "Échec réseau lors de la création du token (curl=${bootstrap_curl_rc})."
        print_error \
            "Veuillez créer manuellement le token dans Forgejo."
        return 1
    fi

    token_http_code="${token_http_response##*$'\n'}"
    token_http_body="${token_http_response%$'\n'*}"

    if [[ "${token_http_code}" -lt 200 ||
          "${token_http_code}" -ge 300 ]]; then

        print_error \
            "Échec de la création du token Forgejo (HTTP ${token_http_code})."
        print_error \
            "Vérifiez l'identifiant, le mot de passe et les droits du compte Forgejo."
        print_error \
            "Aucun détail renvoyé par Forgejo n'est affiché afin d'éviter toute fuite de credential."
        print_error \
            "Veuillez créer manuellement le token dans Forgejo."
        return 1
    fi

    if ! printf '%s' "${token_http_body}" | jq empty 2>/dev/null; then
        print_error \
            "Réponse invalide de l'API Forgejo lors de la création du token."
        print_error \
            "Veuillez créer manuellement le token dans Forgejo."
        return 1
    fi

    forgejo_token="$(printf '%s' "${token_http_body}" |
        jq -r '.sha1 // empty')"

    if [[ -z "${forgejo_token}" ]]; then
        print_error \
            "Impossible d'extraire le token de la réponse Forgejo."
        print_error \
            "Veuillez créer manuellement le token dans Forgejo."
        return 1
    fi

    # ----------------------------------------------------------
    # Étape 6 : Persistance locale
    # ----------------------------------------------------------

    if ! mkdir -p "${project_path}/config"; then
        print_error "Impossible de créer le répertoire config."
        print_error \
            "Le token distant a été créé, mais la configuration locale n'a pas pu être finalisée."
        print_error "Aucun rollback distant automatique n'est effectué."
        return 1
    fi

    # ----------------------------------------------------------
    # Persistance du token
    # ----------------------------------------------------------

    local token_write_file=""

    token_write_file="$(
        mktemp "${project_path}/config/.forgejo.token.XXXXXX"
    )" || {
        print_error \
            "Impossible de créer un fichier temporaire pour le token."
        print_error \
            "Le token distant a été créé, mais la configuration locale n'a pas pu être finalisée."
        print_error "Aucun rollback distant automatique n'est effectué."
        return 1
    }

    if ! chmod 600 "${token_write_file}"; then
        print_error "Échec des permissions sur le fichier token."
        rm -f "${token_write_file}"
        return 1
    fi

    if ! printf '%s' "${forgejo_token}" > "${token_write_file}"; then
        print_error "Échec de l'écriture du token."
        rm -f "${token_write_file}"
        return 1
    fi

    if ! mv "${token_write_file}" "${token_file}"; then
        print_error "Échec du déplacement du fichier token."
        rm -f "${token_write_file}"
        return 1
    fi

    local final_token_perms=""
    final_token_perms="$(stat -c %a "${token_file}" 2>/dev/null)"

    if [[ "${final_token_perms}" != "600" ]]; then
        print_error \
            "Permissions du token invalides après création : ${final_token_perms}"
        rm -f "${token_file}"
        return 1
    fi

    # ----------------------------------------------------------
    # Persistance du username
    # ----------------------------------------------------------

    local username_write_file=""

    username_write_file="$(
        mktemp "${project_path}/config/.forgejo.username.XXXXXX"
    )" || {
        print_error \
            "Impossible de créer un fichier temporaire pour le username."
        rm -f "${token_file}"
        return 1
    }

    if ! chmod 600 "${username_write_file}"; then
        print_error "Échec des permissions sur le fichier username."
        rm -f "${username_write_file}"
        rm -f "${token_file}"
        return 1
    fi

    if ! printf '%s' "${forgejo_user}" > "${username_write_file}"; then
        print_error "Échec de l'écriture du username."
        rm -f "${username_write_file}"
        rm -f "${token_file}"
        return 1
    fi

    if ! mv "${username_write_file}" "${username_file}"; then
        print_error "Échec du déplacement du fichier username."
        rm -f "${username_write_file}"
        rm -f "${token_file}"
        return 1
    fi

    local final_username_perms=""
    final_username_perms="$(stat -c %a "${username_file}" 2>/dev/null)"

    if [[ "${final_username_perms}" != "600" ]]; then
        print_error \
            "Permissions du username invalides après création : ${final_username_perms}"
        rm -f "${username_file}"
        rm -f "${token_file}"
        return 1
    fi

    print_success "Token créé et enregistré dans ${token_file}"
    print_success "Username enregistré dans ${username_file}"

    return 0
}

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

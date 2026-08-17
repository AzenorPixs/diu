#!/usr/bin/env bash
# Publication d'une Release Forgejo à partir du paquet Debian DIU

# ===========================================================
# ENDPOINTS FORGEJO CONFIRMÉS (vérifiés sur forgejo.pixs.fr/api/swagger)
# ===========================================================
#
# GET  /api/v1/repos/{owner}/{repo}/tags/{tag}
# POST /api/v1/repos/{owner}/{repo}/tags
# GET  /api/v1/repos/{owner}/{repo}/releases/tags/{tag}
# POST /api/v1/repos/{owner}/{repo}/releases
# POST /api/v1/repos/{owner}/{repo}/releases/{id}/assets
# POST /api/v1/users/{username}/tokens
#
# Auth : Authorization: token <TOKEN> (appels API)
# Auth : BasicAuth via netrc (création de token)
# Token : extrait de .sha1 dans la réponse AccessToken
# Scope V1 : write:repository + repositories[] pour restriction au dépôt
#
# ===========================================================

publish_release() {
    local project_id="${1:-}"
    local project_path=""
    local dist_files=()
    local deb_file=""
    local deb_filename=""
    local deb_version=""
    local package_name=""
    local package_version=""
    local forgejo_host=""
    local forgejo_base=""
    local forgejo_owner=""
    local forgejo_repo=""
    local forgejo_token=""
    local token_file=""
    local head_sha=""
    local head_message=""
    local release_id=""
    local tag_name=""

    # ----------------------------------------------------------
    # Étape 1 : Vérification des prérequis
    # ----------------------------------------------------------

    print_title "Étape 1/12 — Vérification des prérequis"

    local missing_tools=()

    if ! command -v git >/dev/null 2>&1; then
        missing_tools+=("git")
    fi

    if ! command -v curl >/dev/null 2>&1; then
        missing_tools+=("curl")
    fi

    if ! command -v jq >/dev/null 2>&1; then
        missing_tools+=("jq")
    fi

    if ! command -v dpkg-deb >/dev/null 2>&1; then
        missing_tools+=("dpkg-deb")
    fi

    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        print_error "Outils manquants : ${missing_tools[*]}"
        return 1
    fi

    print_success "Tous les prérequis sont disponibles."

    # ----------------------------------------------------------
    # Étape 2 : Validation du projet
    # ----------------------------------------------------------

    print_title "Étape 2/12 — Validation du projet"

    if [[ -z "${project_id}" ]]; then
        print_error "Usage : publish_release <project_id>"
        return 1
    fi

    project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"

    if [[ ! -d "${project_path}" ]]; then
        print_error "Projet introuvable : ${project_path}"
        return 1
    fi

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" rev-parse \
        --is-inside-work-tree >/dev/null 2>&1; then

        print_error "Aucun dépôt Git valide dans : ${project_path}"
        return 1
    fi

    print_success "Projet validé : ${project_path}"

    # ----------------------------------------------------------
    # Étape 3 : Sélection du paquet dans dist/
    # ----------------------------------------------------------

    print_title "Étape 3/12 — Sélection du paquet dans dist/"

    dist_files=()

    while IFS= read -r -d '' file; do
        dist_files+=("${file}")
    done < <(
        find "${project_path}/dist" -maxdepth 1 -type f \
            -name "diu_*_all.deb" -print0 2>/dev/null
    )

    if [[ ${#dist_files[@]} -eq 0 ]]; then
        print_error "Aucun paquet diu_*_all.deb trouvé dans ${project_path}/dist/"
        return 1
    fi

    if [[ ${#dist_files[@]} -gt 1 ]]; then
        print_error "Plusieurs paquets diu_*_all.deb trouvés dans ${project_path}/dist/ :"
        for f in "${dist_files[@]}"; do
            echo "  $(basename "${f}")"
        done
        return 1
    fi

    deb_file="${dist_files[0]}"
    deb_filename="$(basename "${deb_file}")"

    print_success "Paquet sélectionné : ${deb_filename}"

    # ----------------------------------------------------------
    # Étape 4 : Vérification des métadonnées du paquet
    # ----------------------------------------------------------

    print_title "Étape 4/12 — Vérification des métadonnées du paquet"

    deb_version="${deb_filename#diu_}"
    deb_version="${deb_version%_all.deb}"

    if [[ -z "${deb_version}" ]]; then
        print_error "Impossible d'extraire la version du nom de fichier : ${deb_filename}"
        return 1
    fi

    package_name="$(dpkg-deb --show --showformat='${Package}' "${deb_file}" 2>/dev/null)"
    package_version="$(dpkg-deb --show --showformat='${Version}' "${deb_file}" 2>/dev/null)"

    if [[ "${package_name}" != "diu" ]]; then
        print_error "Incohérence : Package du paquet = '${package_name}' (attendu : diu)"
        return 1
    fi

    if [[ "${package_version}" != "${deb_version}" ]]; then
        print_error "Incohérence : Version du paquet = '${package_version}' (attendu : ${deb_version})"
        return 1
    fi

    print_success "Métadonnées cohérentes : ${package_name} ${package_version}"

    tag_name="v${deb_version}"

    # ----------------------------------------------------------
    # Étape 5 : Déduction des informations Forgejo
    # ----------------------------------------------------------

    print_title "Étape 5/12 — Déduction des informations Forgejo"

    if ! _forgejo_resolve_remote "${project_path}"; then
        return 1
    fi

    print_success "Base : ${forgejo_base}"
    print_success "Owner : ${forgejo_owner}"
    print_success "Repository : ${forgejo_repo}"

    # ----------------------------------------------------------
    # Étape 6 : Authentification Forgejo
    # ----------------------------------------------------------

    print_title "Étape 6/12 — Authentification Forgejo"

    token_file="${project_path}/config/forgejo.token"

    if ! forgejo_ensure_credentials "${project_path}"; then
        return 1
    fi
    # ----------------------------------------------------------
    # Étape 7 : Rafraîchissement de l'état distant
    # ----------------------------------------------------------

    print_title "Étape 7/12 — Rafraîchissement de l'état distant"

    if ! forgejo_git_fetch "${project_path}"; then
        print_error "Échec du git fetch authentifié."
        return 1
    fi

    print_success "git fetch origin authentifié effectué."

    # ----------------------------------------------------------
    # Étape 8 : Vérification de la synchronisation Git
    # ----------------------------------------------------------

    print_title "Étape 8/12 — Vérification de la synchronisation Git"

    local current_branch=""
    current_branch="$(runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" branch --show-current 2>/dev/null)"

    if [[ "${current_branch}" != "main" ]]; then
        print_error "La branche courante est '${current_branch}' (attendu : main)"
        return 1
    fi

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" rev-parse \
        --verify origin/main >/dev/null 2>&1; then

        print_error "La branche distante origin/main n'existe pas."
        return 1
    fi

    local head_sha_local=""
    local origin_main_sha=""
    head_sha_local="$(runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" rev-parse HEAD 2>/dev/null)"
    origin_main_sha="$(runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" rev-parse origin/main 2>/dev/null)"

    if [[ "${head_sha_local}" != "${origin_main_sha}" ]]; then
        print_error "HEAD (${head_sha_local:0:12}) != origin/main (${origin_main_sha:0:12})"
        print_error "Le dépôt n'est pas synchronisé. Effectuez un git pull ou un git merge."
        return 1
    fi

    head_sha="${head_sha_local}"

    print_success "HEAD == origin/main (${head_sha:0:12})"

    # ----------------------------------------------------------
    # Étape 9 : Vérification existence tag/Release
    # ----------------------------------------------------------

    print_title "Étape 9/12 — Vérification existence tag/Release"

    # --- Vérification du tag ---
    local tag_curl_auth_file=""
    tag_curl_auth_file="$(mktemp)" || {
        print_error "Impossible de créer un fichier temporaire pour l'authentification."
        return 1
    }

    if ! chmod 600 "${tag_curl_auth_file}"; then
        print_error "Échec des permissions sur le fichier temporaire."
        rm -f "${tag_curl_auth_file}"
        return 1
    fi

    if ! printf 'header = "Authorization: token %s"\n' "${forgejo_token}" \
        > "${tag_curl_auth_file}"; then
        print_error "Échec de l'écriture du fichier temporaire d'authentification."
        rm -f "${tag_curl_auth_file}"
        return 1
    fi

    local tag_http_response=""
    local tag_http_code=""
    local tag_http_body=""
    local tag_curl_rc=0

    if tag_http_response="$(curl -s -w '\n%{http_code}' \
        --config "${tag_curl_auth_file}" \
        "${forgejo_base}/api/v1/repos/${forgejo_owner}/${forgejo_repo}/tags/${tag_name}" \
        2>/dev/null)"; then
        tag_curl_rc=0
    else
        tag_curl_rc=$?
    fi

    rm -f "${tag_curl_auth_file}"

    if [[ "${tag_curl_rc}" -ne 0 ]]; then
        print_error "Échec réseau lors de la vérification du tag (curl=${tag_curl_rc})."
        return 1
    fi

    tag_http_code="${tag_http_response##*$'\n'}"
    tag_http_body="${tag_http_response%$'\n'*}"

    if [[ "${tag_http_code}" == "200" ]]; then
        if ! printf '%s' "${tag_http_body}" | jq empty 2>/dev/null; then
            print_error "Réponse invalide lors de la vérification du tag."
            return 1
        fi
        print_error "Le tag ${tag_name} existe déjà sur Forgejo."
        print_error "Aucune Release n'est créée. Le tag existant n'est ni déplacé, ni recréé, ni modifié."
        return 1
    fi

    if [[ "${tag_http_code}" != "404" ]]; then
        local error_msg=""
        error_msg="$(printf '%s' "${tag_http_body}" | jq -r '.message // "erreur inconnue"' 2>/dev/null)"
        print_error "Erreur lors de la vérification du tag (HTTP ${tag_http_code}) : ${error_msg}"
        return 1
    fi

    # --- Vérification de la Release ---
    local release_check_curl_auth_file=""
    release_check_curl_auth_file="$(mktemp)" || {
        print_error "Impossible de créer un fichier temporaire pour l'authentification."
        return 1
    }

    if ! chmod 600 "${release_check_curl_auth_file}"; then
        print_error "Échec des permissions sur le fichier temporaire."
        rm -f "${release_check_curl_auth_file}"
        return 1
    fi

    if ! printf 'header = "Authorization: token %s"\n' "${forgejo_token}" \
        > "${release_check_curl_auth_file}"; then
        print_error "Échec de l'écriture du fichier temporaire d'authentification."
        rm -f "${release_check_curl_auth_file}"
        return 1
    fi

    local release_check_http_response=""
    local release_check_http_code=""
    local release_check_http_body=""
    local release_check_curl_rc=0

    if release_check_http_response="$(curl -s -w '\n%{http_code}' \
        --config "${release_check_curl_auth_file}" \
        "${forgejo_base}/api/v1/repos/${forgejo_owner}/${forgejo_repo}/releases/tags/${tag_name}" \
        2>/dev/null)"; then
        release_check_curl_rc=0
    else
        release_check_curl_rc=$?
    fi

    rm -f "${release_check_curl_auth_file}"

    if [[ "${release_check_curl_rc}" -ne 0 ]]; then
        print_error "Échec réseau lors de la vérification de la Release (curl=${release_check_curl_rc})."
        return 1
    fi

    release_check_http_code="${release_check_http_response##*$'\n'}"
    release_check_http_body="${release_check_http_response%$'\n'*}"

    if [[ "${release_check_http_code}" == "200" ]]; then
        if ! printf '%s' "${release_check_http_body}" | jq empty 2>/dev/null; then
            print_error "Réponse invalide lors de la vérification de la Release."
            return 1
        fi
        print_error "Une Release pour le tag ${tag_name} existe déjà sur Forgejo."
        print_error "Rien n'est écrasé ni modifié."
        return 1
    fi

    if [[ "${release_check_http_code}" != "404" ]]; then
        local error_msg=""
        error_msg="$(printf '%s' "${release_check_http_body}" | jq -r '.message // "erreur inconnue"' 2>/dev/null)"
        print_error "Erreur lors de la vérification de la Release (HTTP ${release_check_http_code}) : ${error_msg}"
        return 1
    fi

    print_success "Tag ${tag_name} et Release inexistants. Continuation."

    # ----------------------------------------------------------
    # Étape 10 : Création du tag v<VERSION>
    # ----------------------------------------------------------

    print_title "Étape 10/12 — Création du tag ${tag_name}"

    head_message="$(runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" log -1 --format='%s' 2>/dev/null)"

    local tag_create_curl_auth_file=""
    tag_create_curl_auth_file="$(mktemp)" || {
        print_error "Impossible de créer un fichier temporaire pour l'authentification."
        return 1
    }

    if ! chmod 600 "${tag_create_curl_auth_file}"; then
        print_error "Échec des permissions sur le fichier temporaire."
        rm -f "${tag_create_curl_auth_file}"
        return 1
    fi

    if ! printf 'header = "Authorization: token %s"\n' "${forgejo_token}" \
        > "${tag_create_curl_auth_file}"; then
        print_error "Échec de l'écriture du fichier temporaire d'authentification."
        rm -f "${tag_create_curl_auth_file}"
        return 1
    fi

    local tag_create_http_response=""
    local tag_create_http_code=""
    local tag_create_http_body=""
    local tag_create_curl_rc=0

    if tag_create_http_response="$(curl -s -w '\n%{http_code}' \
        --config "${tag_create_curl_auth_file}" \
        -X POST \
        -H "Content-Type: application/json" \
        -d "$(jq -n \
            --arg tag_name "${tag_name}" \
            --arg target "${head_sha}" \
            --arg message "Release ${tag_name}" \
            '{
                tag_name: $tag_name,
                target: $target,
                message: $message
            }')" \
        "${forgejo_base}/api/v1/repos/${forgejo_owner}/${forgejo_repo}/tags" \
        2>/dev/null)"; then
        tag_create_curl_rc=0
    else
        tag_create_curl_rc=$?
    fi

    rm -f "${tag_create_curl_auth_file}"

    if [[ "${tag_create_curl_rc}" -ne 0 ]]; then
        print_error "Échec réseau lors de la création du tag (curl=${tag_create_curl_rc})."
        return 1
    fi

    tag_create_http_code="${tag_create_http_response##*$'\n'}"
    tag_create_http_body="${tag_create_http_response%$'\n'*}"

    if [[ "${tag_create_http_code}" -lt 200 || "${tag_create_http_code}" -ge 300 ]]; then
        local error_msg=""
        error_msg="$(printf '%s' "${tag_create_http_body}" | jq -r '.message // "erreur inconnue"' 2>/dev/null)"
        print_error "Échec de la création du tag ${tag_name} (HTTP ${tag_create_http_code}) : ${error_msg}"
        return 1
    fi

    print_success "Tag ${tag_name} créé sur ${head_sha:0:12}"

    # ----------------------------------------------------------
    # Étape 11 : Création de la Release
    # ----------------------------------------------------------

    print_title "Étape 11/12 — Création de la Release DIU ${deb_version}"

    local release_notes=""
    release_notes="$(printf 'Version : %s\nCommit : %s\nMessage : %s' \
        "${deb_version}" "${head_sha}" "${head_message}")"

    local release_curl_auth_file=""
    release_curl_auth_file="$(mktemp)" || {
        print_error "Impossible de créer un fichier temporaire pour l'authentification."
        return 1
    }

    if ! chmod 600 "${release_curl_auth_file}"; then
        print_error "Échec des permissions sur le fichier temporaire."
        rm -f "${release_curl_auth_file}"
        return 1
    fi

    if ! printf 'header = "Authorization: token %s"\n' "${forgejo_token}" \
        > "${release_curl_auth_file}"; then
        print_error "Échec de l'écriture du fichier temporaire d'authentification."
        rm -f "${release_curl_auth_file}"
        return 1
    fi

    local release_http_response=""
    local release_http_code=""
    local release_http_body=""
    local release_curl_rc=0

    if release_http_response="$(curl -s -w '\n%{http_code}' \
        --config "${release_curl_auth_file}" \
        -X POST \
        -H "Content-Type: application/json" \
        -d "$(jq -n \
            --arg tag_name "${tag_name}" \
            --arg name "DIU ${deb_version}" \
            --arg body "${release_notes}" \
            '{
                tag_name: $tag_name,
                name: $name,
                body: $body
            }')" \
        "${forgejo_base}/api/v1/repos/${forgejo_owner}/${forgejo_repo}/releases" \
        2>/dev/null)"; then
        release_curl_rc=0
    else
        release_curl_rc=$?
    fi

    rm -f "${release_curl_auth_file}"

    if [[ "${release_curl_rc}" -ne 0 ]]; then
        print_error "Échec réseau lors de la création de la Release (curl=${release_curl_rc})."
        return 1
    fi

    release_http_code="${release_http_response##*$'\n'}"
    release_http_body="${release_http_response%$'\n'*}"

    if [[ "${release_http_code}" -lt 200 || "${release_http_code}" -ge 300 ]]; then
        local error_msg=""
        error_msg="$(printf '%s' "${release_http_body}" | jq -r '.message // "erreur inconnue"' 2>/dev/null)"
        print_error "Échec de la création de la Release (HTTP ${release_http_code}) : ${error_msg}"
        return 1
    fi

    if ! printf '%s' "${release_http_body}" | jq empty 2>/dev/null; then
        print_error "Réponse invalide de l'API Forgejo lors de la création de la Release."
        return 1
    fi

    release_id="$(printf '%s' "${release_http_body}" | jq -r '.id // empty')"

    if [[ -z "${release_id}" ]]; then
        print_error "Impossible de récupérer l'identifiant de la Release créée."
        return 1
    fi

    print_success "Release créée (ID: ${release_id})"

    # ----------------------------------------------------------
    # Étape 12 : Upload de l'asset
    # ----------------------------------------------------------

    print_title "Étape 12/12 — Upload du paquet ${deb_filename}"

    local upload_curl_auth_file=""
    upload_curl_auth_file="$(mktemp)" || {
        print_error "Impossible de créer un fichier temporaire pour l'authentification."
        return 1
    }

    if ! chmod 600 "${upload_curl_auth_file}"; then
        print_error "Échec des permissions sur le fichier temporaire."
        rm -f "${upload_curl_auth_file}"
        return 1
    fi

    if ! printf 'header = "Authorization: token %s"\n' "${forgejo_token}" \
        > "${upload_curl_auth_file}"; then
        print_error "Échec de l'écriture du fichier temporaire d'authentification."
        rm -f "${upload_curl_auth_file}"
        return 1
    fi

    local upload_http_response=""
    local upload_http_code=""
    local upload_http_body=""
    local upload_curl_rc=0

    if upload_http_response="$(curl -s -w '\n%{http_code}' \
        --config "${upload_curl_auth_file}" \
        -X POST \
        -F "attachment=@${deb_file}" \
        "${forgejo_base}/api/v1/repos/${forgejo_owner}/${forgejo_repo}/releases/${release_id}/assets" \
        2>/dev/null)"; then
        upload_curl_rc=0
    else
        upload_curl_rc=$?
    fi

    rm -f "${upload_curl_auth_file}"

    if [[ "${upload_curl_rc}" -ne 0 ]]; then
        print_error "Échec réseau lors de l'upload de l'asset (curl=${upload_curl_rc})."
        print_error "La Release reste visible mais incomplète. Aucun rollback."
        return 1
    fi

    upload_http_code="${upload_http_response##*$'\n'}"
    upload_http_body="${upload_http_response%$'\n'*}"

    if [[ "${upload_http_code}" -lt 200 || "${upload_http_code}" -ge 300 ]]; then
        local error_msg=""
        error_msg="$(printf '%s' "${upload_http_body}" | jq -r '.message // "erreur inconnue"' 2>/dev/null)"
        print_error "Échec de l'upload de l'asset (HTTP ${upload_http_code}) : ${error_msg}"
        print_error "La Release reste visible mais incomplète. Aucun rollback."
        return 1
    fi

    if ! printf '%s' "${upload_http_body}" | jq empty 2>/dev/null; then
        print_error "Réponse invalide de l'API Forgejo lors de l'upload de l'asset."
        print_error "La Release reste visible mais incomplète. Aucun rollback."
        return 1
    fi

    print_success "Asset uploadé : ${deb_filename}"
    print_success "Release DIU ${deb_version} publiée avec succès."
}

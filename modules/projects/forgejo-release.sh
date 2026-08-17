#!/usr/bin/env bash
# Publication d'une Release Forgejo à partir du paquet Debian DIU
#
# Authentification :
#   forgejo-auth.sh est l'unique fournisseur de credentials Forgejo.
#
# Flux :
#   1. Vérification des prérequis
#   2. Validation du projet
#   3. Sélection du paquet Debian
#   4. Validation des métadonnées
#   5. Résolution du remote Forgejo
#   6. Validation / initialisation des credentials
#   7. Synchronisation Git
#   8. Vérification tag / release
#   9. Création du tag
#  10. Création de la Release
#  11. Upload du paquet
#
# Le token utilisé ici est exactement celui utilisé par git push.
#
# Endpoints Forgejo :
#   GET  /api/v1/repos/{owner}/{repo}/tags/{tag}
#   POST /api/v1/repos/{owner}/{repo}/tags
#   GET  /api/v1/repos/{owner}/{repo}/releases/tags/{tag}
#   POST /api/v1/repos/{owner}/{repo}/releases
#   POST /api/v1/repos/{owner}/{repo}/releases/{id}/assets

publish_release() {

    local project_id="${1:-}"
    local project_path=""

    local deb_file=""
    local deb_filename=""
    local deb_version=""

    local package_name=""
    local package_version=""

    local forgejo_host=""
    local forgejo_base=""
    local forgejo_owner=""
    local forgejo_repo=""
    local forgejo_username=""
    local forgejo_token=""

    local current_branch=""
    local head_sha=""
    local origin_main_sha=""
    local head_message=""

    local tag_name=""
    local release_id=""

    local -a missing_tools=()
    local -a dist_files=()

    # ==========================================================
    # Fonction locale d'appel API Forgejo
    # ==========================================================
    #
    # Usage :
    #
    #   _forgejo_release_api METHOD URL [DATA]
    #
    # Retour :
    #   stdout = réponse HTTP complète avec code sur dernière ligne
    #
    # Le token n'est jamais placé directement dans la ligne de
    # commande curl. Un fichier de configuration temporaire
    # sécurisé est utilisé.
    #

    _forgejo_release_api() {

        local method="${1:-GET}"
        local url="${2:-}"
        local data="${3:-}"

        local auth_file=""
        local response=""
        local curl_rc=0

        if [[ -z "${url}" ]]; then
            print_error "_forgejo_release_api : URL vide."
            return 1
        fi

        auth_file="$(mktemp)" || {
            print_error \
                "_forgejo_release_api : impossible de créer le fichier temporaire."
            return 1
        }

        if ! chmod 600 "${auth_file}"; then
            print_error \
                "_forgejo_release_api : impossible de sécuriser le fichier temporaire."
            rm -f "${auth_file}"
            return 1
        fi

        if ! printf 'header = "Authorization: token %s"\n' \
            "${forgejo_token}" > "${auth_file}"; then

            print_error \
                "_forgejo_release_api : impossible d'écrire les credentials."
            rm -f "${auth_file}"
            return 1
        fi

        if [[ -n "${data}" ]]; then

            if response="$(
                curl -sS \
                    -w '\n%{http_code}' \
                    --config "${auth_file}" \
                    -X "${method}" \
                    -H "Content-Type: application/json" \
                    -d "${data}" \
                    "${url}" \
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
                    --config "${auth_file}" \
                    -X "${method}" \
                    "${url}" \
                    2>/dev/null
            )"; then
                curl_rc=0
            else
                curl_rc=$?
            fi

        fi

        rm -f "${auth_file}"

        if [[ "${curl_rc}" -ne 0 ]]; then
            print_error \
                "_forgejo_release_api : erreur réseau (curl=${curl_rc})."
            return 1
        fi

        printf '%s' "${response}"

        return 0
    }

    # ==========================================================
    # Fonction locale d'extraction du code HTTP
    # ==========================================================

    _forgejo_release_http_code() {
        local response="${1:-}"
        printf '%s' "${response##*$'\n'}"
    }

    # ==========================================================
    # Fonction locale d'extraction du body
    # ==========================================================

    _forgejo_release_http_body() {
        local response="${1:-}"
        printf '%s' "${response%$'\n'*}"
    }

    # ==========================================================
    # Étape 1 — Prérequis
    # ==========================================================

    print_title "Étape 1/11 — Vérification des prérequis"

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

    if ! command -v find >/dev/null 2>&1; then
        missing_tools+=("find")
    fi

    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        print_error "Outils manquants : ${missing_tools[*]}"
        return 1
    fi

    print_success "Tous les prérequis sont disponibles."

    # ==========================================================
    # Étape 2 — Validation du projet
    # ==========================================================

    print_title "Étape 2/11 — Validation du projet"

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

        print_error \
            "Aucun dépôt Git valide dans : ${project_path}"
        return 1
    fi

    if [[ ! -d "${project_path}/dist" ]]; then
        print_error \
            "Répertoire dist/ introuvable : ${project_path}/dist"
        return 1
    fi

    print_success "Projet validé : ${project_path}"

    # ==========================================================
    # Étape 3 — Sélection du paquet
    # ==========================================================

    print_title "Étape 3/11 — Sélection du paquet Debian"

    while IFS= read -r -d '' file; do
        dist_files+=("${file}")
    done < <(
        find "${project_path}/dist" \
            -maxdepth 1 \
            -type f \
            -name "diu_*_all.deb" \
            -print0 \
            2>/dev/null
    )

    if [[ ${#dist_files[@]} -eq 0 ]]; then
        print_error \
            "Aucun paquet diu_*_all.deb trouvé dans ${project_path}/dist/"
        return 1
    fi

    if [[ ${#dist_files[@]} -gt 1 ]]; then
        print_error \
            "Plusieurs paquets diu_*_all.deb sont présents :"

        for deb_file in "${dist_files[@]}"; do
            echo "  $(basename "${deb_file}")"
        done

        print_error \
            "Le répertoire dist/ doit contenir un seul paquet DIU."
        return 1
    fi

    deb_file="${dist_files[0]}"
    deb_filename="$(basename "${deb_file}")"

    print_success \
        "Paquet sélectionné : ${deb_filename}"

    # ==========================================================
    # Étape 4 — Métadonnées Debian
    # ==========================================================

    print_title "Étape 4/11 — Vérification des métadonnées Debian"

    package_name="$(
        dpkg-deb \
            --show \
            --showformat='${Package}' \
            "${deb_file}" \
            2>/dev/null
    )"

    package_version="$(
        dpkg-deb \
            --show \
            --showformat='${Version}' \
            "${deb_file}" \
            2>/dev/null
    )"

    if [[ "${package_name}" != "diu" ]]; then
        print_error \
            "Nom de paquet invalide : '${package_name}' (attendu : diu)"
        return 1
    fi

    if [[ -z "${package_version}" ]]; then
        print_error \
            "Impossible de déterminer la version Debian."
        return 1
    fi

    deb_version="${package_version}"

    if [[ "${deb_filename}" != "diu_${deb_version}_all.deb" ]]; then
        print_error \
            "Incohérence entre le nom du fichier et la version Debian."
        print_error \
            "Fichier   : ${deb_filename}"
        print_error \
            "Version   : ${deb_version}"
        return 1
    fi

    print_success \
        "Paquet Debian valide : ${package_name} ${package_version}"

    tag_name="v${deb_version}"

    # ==========================================================
    # Étape 5 — Résolution Forgejo
    # ==========================================================

    print_title "Étape 5/11 — Résolution du dépôt Forgejo"

    if ! _forgejo_resolve_remote "${project_path}"; then
        return 1
    fi

    print_success "Forgejo : ${forgejo_base}"
    print_success "Owner   : ${forgejo_owner}"
    print_success "Repo    : ${forgejo_repo}"

    # ==========================================================
    # Étape 6 — Authentification Forgejo
    # ==========================================================

    print_title "Étape 6/11 — Authentification Forgejo"

    #
    # IMPORTANT :
    #
    # Aucun accès direct à config/forgejo.token ici.
    #
    # forgejo_ensure_credentials() :
    #   - vérifie les credentials existants ;
    #   - les régénère si nécessaire ;
    #   - valide réellement le token ;
    #   - garantit les permissions 600.
    #

    if ! _forgejo_ensure_credentials "${project_path}"; then
        print_error \
            "Impossible d'obtenir des credentials Forgejo valides."
        return 1
    fi

    if ! _forgejo_read_username "${project_path}"; then
        return 1
    fi

    if ! _forgejo_read_token "${project_path}"; then
        return 1
    fi

    print_success \
        "Credentials Forgejo disponibles."

    # ==========================================================
    # Étape 7 — Synchronisation Git
    # ==========================================================

    print_title "Étape 7/11 — Vérification de la synchronisation Git"

    if ! forgejo_git_fetch "${project_path}"; then
        print_error \
            "Échec du git fetch authentifié."
        return 1
    fi

    print_success \
        "git fetch origin authentifié effectué."

    current_branch="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" \
            branch --show-current \
            2>/dev/null
    )"

    if [[ "${current_branch}" != "main" ]]; then
        print_error \
            "La branche courante est '${current_branch}' (attendu : main)."
        return 1
    fi

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" \
        rev-parse --verify origin/main >/dev/null 2>&1; then

        print_error \
            "La branche distante origin/main n'existe pas."
        return 1
    fi

    head_sha="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" \
            rev-parse HEAD \
            2>/dev/null
    )"

    origin_main_sha="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" \
            rev-parse origin/main \
            2>/dev/null
    )"

    if [[ -z "${head_sha}" || -z "${origin_main_sha}" ]]; then
        print_error \
            "Impossible de déterminer l'état Git."
        return 1
    fi

    if [[ "${head_sha}" != "${origin_main_sha}" ]]; then
        print_error \
            "Le dépôt local n'est pas synchronisé avec origin/main."

        print_error \
            "HEAD         : ${head_sha:0:12}"

        print_error \
            "origin/main  : ${origin_main_sha:0:12}"

        print_error \
            "Effectuez d'abord le git push."
        return 1
    fi

    head_message="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" \
            log -1 \
            --format='%s' \
            2>/dev/null
    )"

    print_success \
        "HEAD == origin/main (${head_sha:0:12})"

    # ==========================================================
    # Étape 8 — Vérification tag / Release
    # ==========================================================

    print_title \
        "Étape 8/11 — Vérification du tag ${tag_name} et de la Release"

    local api_response=""
    local http_code=""
    local http_body=""
    local error_msg=""

    # ----------------------------------------------------------
    # Tag
    # ----------------------------------------------------------

    api_response="$(
        _forgejo_release_api \
            GET \
            "${forgejo_base}/api/v1/repos/${forgejo_owner}/${forgejo_repo}/tags/${tag_name}"
    )" || {
        return 1
    }

    http_code="$(
        _forgejo_release_http_code "${api_response}"
    )"

    http_body="$(
        _forgejo_release_http_body "${api_response}"
    )"

    case "${http_code}" in

        200)
            print_error \
                "Le tag ${tag_name} existe déjà sur Forgejo."
            print_error \
                "Aucun tag existant ne sera déplacé ou modifié."
            return 1
            ;;

        404)
            print_success \
                "Le tag ${tag_name} n'existe pas."
            ;;

        401)
            print_error \
                "Token Forgejo invalide ou expiré (HTTP 401)."
            return 1
            ;;

        403)
            print_error \
                "Token Forgejo refusé (HTTP 403)."
            print_error \
                "Vérifiez les permissions du token."
            return 1
            ;;

        *)
            error_msg="$(
                printf '%s' "${http_body}" |
                    jq -r '.message // "erreur inconnue"' \
                    2>/dev/null
            )"

            print_error \
                "Erreur lors de la vérification du tag."
            print_error \
                "HTTP ${http_code} : ${error_msg}"
            return 1
            ;;
    esac

    # ----------------------------------------------------------
    # Release
    # ----------------------------------------------------------

    api_response="$(
        _forgejo_release_api \
            GET \
            "${forgejo_base}/api/v1/repos/${forgejo_owner}/${forgejo_repo}/releases/tags/${tag_name}"
    )" || {
        return 1
    }

    http_code="$(
        _forgejo_release_http_code "${api_response}"
    )"

    http_body="$(
        _forgejo_release_http_body "${api_response}"
    )"

    case "${http_code}" in

        200)
            print_error \
                "Une Release ${tag_name} existe déjà sur Forgejo."
            print_error \
                "Aucune Release existante ne sera modifiée."
            return 1
            ;;

        404)
            print_success \
                "Aucune Release ${tag_name} existante."
            ;;

        401)
            print_error \
                "Token Forgejo invalide ou expiré (HTTP 401)."
            return 1
            ;;

        403)
            print_error \
                "Accès Forgejo refusé (HTTP 403)."
            return 1
            ;;

        *)
            error_msg="$(
                printf '%s' "${http_body}" |
                    jq -r '.message // "erreur inconnue"' \
                    2>/dev/null
            )"

            print_error \
                "Erreur lors de la vérification de la Release."
            print_error \
                "HTTP ${http_code} : ${error_msg}"
            return 1
            ;;
    esac

    # ==========================================================
    # Étape 9 — Création du tag
    # ==========================================================

    print_title \
        "Étape 9/11 — Création du tag ${tag_name}"

    api_response="$(
        _forgejo_release_api \
            POST \
            "${forgejo_base}/api/v1/repos/${forgejo_owner}/${forgejo_repo}/tags" \
            "$(jq -n \
                --arg tag_name "${tag_name}" \
                --arg target "${head_sha}" \
                --arg message "Release ${tag_name}" \
                '{
                    tag_name: $tag_name,
                    target: $target,
                    message: $message
                }'
            )"
    )" || {
        return 1
    }

    http_code="$(
        _forgejo_release_http_code "${api_response}"
    )"

    http_body="$(
        _forgejo_release_http_body "${api_response}"
    )"

    if [[ "${http_code}" -lt 200 || "${http_code}" -ge 300 ]]; then

        error_msg="$(
            printf '%s' "${http_body}" |
                jq -r '.message // "erreur inconnue"' \
                2>/dev/null
        )"

        print_error \
            "Impossible de créer le tag ${tag_name}."

        print_error \
            "HTTP ${http_code} : ${error_msg}"

        return 1
    fi

    print_success \
        "Tag ${tag_name} créé sur ${head_sha:0:12}."

    # ==========================================================
    # Étape 10 — Création de la Release
    # ==========================================================

    print_title \
        "Étape 10/11 — Création de la Release DIU ${deb_version}"

    local release_notes=""

    release_notes="$(
        printf \
            'Version : %s\nCommit : %s\nMessage : %s' \
            "${deb_version}" \
            "${head_sha}" \
            "${head_message}"
    )"

    api_response="$(
        _forgejo_release_api \
            POST \
            "${forgejo_base}/api/v1/repos/${forgejo_owner}/${forgejo_repo}/releases" \
            "$(jq -n \
                --arg tag_name "${tag_name}" \
                --arg name "DIU ${deb_version}" \
                --arg body "${release_notes}" \
                '{
                    tag_name: $tag_name,
                    name: $name,
                    body: $body
                }'
            )"
    )" || {
        return 1
    }

    http_code="$(
        _forgejo_release_http_code "${api_response}"
    )"

    http_body="$(
        _forgejo_release_http_body "${api_response}"
    )"

    if [[ "${http_code}" -lt 200 || "${http_code}" -ge 300 ]]; then

        error_msg="$(
            printf '%s' "${http_body}" |
                jq -r '.message // "erreur inconnue"' \
                2>/dev/null
        )"

        print_error \
            "Impossible de créer la Release."

        print_error \
            "HTTP ${http_code} : ${error_msg}"

        print_error \
            "Le tag ${tag_name} existe désormais."
        print_error \
            "Aucun rollback automatique n'est effectué."

        return 1
    fi

    if ! printf '%s' "${http_body}" |
        jq empty >/dev/null 2>&1; then

        print_error \
            "Réponse JSON invalide lors de la création de la Release."

        print_error \
            "Le tag ${tag_name} existe désormais."

        return 1
    fi

    release_id="$(
        printf '%s' "${http_body}" |
            jq -r '.id // empty'
    )"

    if [[ -z "${release_id}" ]]; then

        print_error \
            "L'API Forgejo n'a retourné aucun identifiant de Release."

        print_error \
            "Le tag ${tag_name} existe désormais."

        return 1
    fi

    print_success \
        "Release créée : DIU ${deb_version} (ID ${release_id})."

    # ==========================================================
    # Étape 11 — Upload du paquet
    # ==========================================================

    print_title \
        "Étape 11/11 — Upload du paquet ${deb_filename}"

    #
    # Ici on utilise volontairement un appel curl dédié car
    # l'upload multipart/form-data n'est pas un appel JSON.
    #

    local upload_auth_file=""
    local upload_response=""
    local upload_code=""
    local upload_body=""
    local upload_rc=0

    upload_auth_file="$(mktemp)" || {
        print_error \
            "Impossible de créer le fichier temporaire d'authentification."
        return 1
    }

    if ! chmod 600 "${upload_auth_file}"; then
        print_error \
            "Impossible de sécuriser le fichier temporaire."
        rm -f "${upload_auth_file}"
        return 1
    fi

    if ! printf \
        'header = "Authorization: token %s"\n' \
        "${forgejo_token}" \
        > "${upload_auth_file}"; then

        print_error \
            "Impossible de préparer l'authentification."
        rm -f "${upload_auth_file}"
        return 1
    fi

    if upload_response="$(
        curl -sS \
            -w '\n%{http_code}' \
            --config "${upload_auth_file}" \
            -X POST \
            -F "attachment=@${deb_file}" \
            "${forgejo_base}/api/v1/repos/${forgejo_owner}/${forgejo_repo}/releases/${release_id}/assets" \
            2>/dev/null
    )"; then

        upload_rc=0

    else

        upload_rc=$?

    fi

    rm -f "${upload_auth_file}"

    if [[ "${upload_rc}" -ne 0 ]]; then

        print_error \
            "Échec réseau lors de l'upload de l'asset."
        print_error \
            "Code curl : ${upload_rc}"
        print_error \
            "La Release reste visible mais incomplète."
        print_error \
            "Aucun rollback automatique."

        return 1
    fi

    upload_code="$(
        _forgejo_release_http_code "${upload_response}"
    )"

    upload_body="$(
        _forgejo_release_http_body "${upload_response}"
    )"

    if [[ "${upload_code}" -lt 200 ||
          "${upload_code}" -ge 300 ]]; then

        error_msg="$(
            printf '%s' "${upload_body}" |
                jq -r '.message // "erreur inconnue"' \
                2>/dev/null
        )"

        print_error \
            "Échec de l'upload de l'asset."

        print_error \
            "HTTP ${upload_code} : ${error_msg}"

        print_error \
            "La Release reste visible mais incomplète."
        print_error \
            "Aucun rollback automatique."

        return 1
    fi

    if ! printf '%s' "${upload_body}" |
        jq empty >/dev/null 2>&1; then

        print_error \
            "Réponse JSON invalide lors de l'upload."

        print_error \
            "La Release reste visible mais incomplète."

        return 1
    fi

    print_success \
        "Asset uploadé : ${deb_filename}"

    echo ""

    print_success \
        "=============================================="

    print_success \
        "Release DIU ${deb_version} publiée avec succès."

    print_success \
        "Tag     : ${tag_name}"

    print_success \
        "Commit  : ${head_sha:0:12}"

    print_success \
        "Release : ${release_id}"

    print_success \
        "Asset   : ${deb_filename}"

    print_success \
        "=============================================="

    return 0
}

#!/usr/bin/env bash

# shellcheck source=lib/project-version.sh
. "$(dirname -- "${BASH_SOURCE[0]}")/../../lib/project-version.sh"

publish_release_debian() {
    local project_id="${1:-}"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"
    local project_env="${project_path}/project.env"
    project_version_get "$project_env" >/dev/null || return 1

    local project_name=""
    local local_default_branch=""

    local remote_base_url=""
    local remote_owner=""
    local remote_repository=""
    local remote_name=""
    local remote_default_branch=""
    local remote_url=""
    local configured_remote_url=""
    local remote_branch_ref=""

    local deb_file=""
    local deb_filename=""
    local deb_version=""

    local package_name=""
    local package_version=""

    # Ancre locale consommée par _forgejo_read_username via la portée dynamique Bash.
    # shellcheck disable=SC2034
    local forgejo_username=""
    local forgejo_token=""

    local current_branch=""
    local head_sha=""
    local remote_branch_sha=""
    local head_message=""

    local local_git_tag=""
    local tag_name=""
    local tag_source=""
    local remote_tag_exists=0

    local release_id=""
    local release_notes=""

    local api_response=""
    local http_code=""
    local http_body=""
    local error_msg=""

    local upload_auth_file=""
    local upload_response=""
    local upload_code=""
    local upload_body=""
    local upload_rc=0

    local -a missing_tools=()
    local -a dist_files=()

    if [[ -z "${project_id}" ]]; then
        print_error "Usage : publish_release_debian <project_id>"
        return 1
    fi

    # ==========================================================
    # Fonction locale d'appel API Forgejo
    # ==========================================================

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

        if ! printf \
            'header = "Authorization: token %s"\n' \
            "${forgejo_token}" \
            > "${auth_file}"; then

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
    # Étape 1 - Vérification des prérequis
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
        print_error \
            "Outils manquants : ${missing_tools[*]}"
        return 1
    fi

    if ! check_devops_user; then
        print_error \
            "L'utilisateur DevOps n'est pas disponible."
        return 1
    fi

    if ! runuser -u "${DEVOPS_USER}" -- \
        git --version >/dev/null 2>&1; then

        print_error \
            "Git n'est pas accessible pour ${DEVOPS_USER}."
        return 1
    fi

    print_success \
        "Tous les prérequis sont disponibles."

    # ==========================================================
    # Étape 2 - Validation du projet
    # ==========================================================

    print_title "Étape 2/11 — Validation du projet"

    if [[ ! -d "${project_path}" ]]; then
        print_error \
            "Projet introuvable : ${project_path}"
        return 1
    fi

    # Chargement de project.env
    if [[ ! -f "${project_env}" ]]; then
        print_info \
            "Le fichier project.env est absent pour le projet ${project_id}."

        if ! update_projects "${project_id}" ||
            ! git_update "${project_id}" ||
            ! forgejo_update "${project_id}"; then
            print_error \
                "Impossible d'initialiser la configuration du projet."
            return 1
        fi
    fi

    if [[ ! -f "${project_env}" ]]; then
        print_error \
            "Le fichier project.env est toujours absent : ${project_env}"
        return 1
    fi

    # Nettoyage des variables susceptibles d'être déjà présentes
    unset \
        PROJECT_ID \
        PROJECT_NAME \
        PROJECT_TYPE \
        PROJECT_DOCKERED \
        LOCAL_DEFAULT_BRANCH \
        GIT_USER_NAME \
        GIT_USER_EMAIL \
        REMOTE_FORGEJO_BASE_URL \
        REMOTE_FORGEJO_OWNER \
        REMOTE_FORGEJO_REPOSITORY \
        REMOTE_FORGEJO_NAME \
        REMOTE_FORGEJO_BRANCH \
        REMOTE_FORGEJO_SSL_VERIFY

    # shellcheck disable=SC1090
    source "${project_env}"

    # Vérification des variables essentielles
    if [[ \
        -z "${PROJECT_ID:-}" ||
        -z "${PROJECT_NAME:-}" ||
        -z "${LOCAL_DEFAULT_BRANCH:-}" ||
        -z "${REMOTE_FORGEJO_BASE_URL:-}" ||
        -z "${REMOTE_FORGEJO_OWNER:-}" ||
        -z "${REMOTE_FORGEJO_REPOSITORY:-}" ||
        -z "${REMOTE_FORGEJO_NAME:-}" ||
        -z "${REMOTE_FORGEJO_BRANCH:-}" \
    ]]; then

        print_info \
            "La configuration du projet est incomplète."

        if ! update_projects "${project_id}" ||
            ! git_update "${project_id}" ||
            ! forgejo_update "${project_id}"; then
            print_error \
                "Impossible de mettre à jour la configuration du projet."
            return 1
        fi

        # Recharge project.env après git_update
        unset \
            PROJECT_ID \
            PROJECT_NAME \
            PROJECT_TYPE \
            PROJECT_DOCKERED \
            LOCAL_DEFAULT_BRANCH \
            GIT_USER_NAME \
            GIT_USER_EMAIL \
            REMOTE_FORGEJO_BASE_URL \
            REMOTE_FORGEJO_OWNER \
            REMOTE_FORGEJO_REPOSITORY \
            REMOTE_FORGEJO_NAME \
            REMOTE_FORGEJO_BRANCH \
            REMOTE_FORGEJO_SSL_VERIFY

        # shellcheck disable=SC1090
        source "${project_env}"
    fi

    # Vérification finale des variables essentielles
    if [[ "${PROJECT_ID:-}" != "${project_id}" ]]; then
        print_error \
            "PROJECT_ID '${PROJECT_ID:-}' ne correspond pas au projet '${project_id}'."
        return 1
    fi

    if [[ -z "${PROJECT_NAME:-}" ]]; then
        print_error \
            "PROJECT_NAME n'est pas défini dans project.env."
        return 1
    fi

    if [[ -z "${LOCAL_DEFAULT_BRANCH:-}" ]]; then
        print_error \
            "LOCAL_DEFAULT_BRANCH n'est pas défini dans project.env."
        return 1
    fi

    if [[ -z "${REMOTE_FORGEJO_BASE_URL:-}" ]]; then
        print_error \
            "REMOTE_FORGEJO_BASE_URL n'est pas défini dans project.env."
        return 1
    fi

    if [[ -z "${REMOTE_FORGEJO_OWNER:-}" ]]; then
        print_error \
            "REMOTE_FORGEJO_OWNER n'est pas défini dans project.env."
        return 1
    fi

    if [[ -z "${REMOTE_FORGEJO_REPOSITORY:-}" ]]; then
        print_error \
            "REMOTE_FORGEJO_REPOSITORY n'est pas défini dans project.env."
        return 1
    fi

    if [[ -z "${REMOTE_FORGEJO_NAME:-}" ]]; then
        print_error \
            "REMOTE_FORGEJO_NAME n'est pas défini dans project.env."
        return 1
    fi

    if [[ -z "${REMOTE_FORGEJO_BRANCH:-}" ]]; then
        print_error \
            "REMOTE_FORGEJO_BRANCH n'est pas défini dans project.env."
        return 1
    fi

    # Affectation locale de la configuration du projet
    project_name="${PROJECT_NAME}"
    local_default_branch="${LOCAL_DEFAULT_BRANCH}"

    remote_base_url="${REMOTE_FORGEJO_BASE_URL%/}"
    remote_owner="${REMOTE_FORGEJO_OWNER}"
    remote_repository="${REMOTE_FORGEJO_REPOSITORY}"
    remote_name="${REMOTE_FORGEJO_NAME}"
    remote_default_branch="${REMOTE_FORGEJO_BRANCH}"

    remote_url="${remote_base_url}/${remote_owner}/${remote_repository}.git"
    remote_branch_ref="${remote_name}/${remote_default_branch}"

    # Vérification du dépôt Git local
    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" rev-parse \
        --is-inside-work-tree >/dev/null 2>&1; then

        print_error \
            "Aucun dépôt Git valide dans : ${project_path}"
        return 1
    fi

    # Vérification du remote Git réel
    configured_remote_url=""

    if configured_remote_url="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" \
            remote get-url "${remote_name}" 2>/dev/null
    )"; then
        :
    fi

    if [[ -z "${configured_remote_url}" ]]; then
        print_error \
            "Le dépôt distant '${remote_name}' n'est pas configuré."
        return 1
    fi

    if [[ "${configured_remote_url}" != "${remote_url}" ]]; then
        print_error \
            "L'URL Git configurée ne correspond pas à project.env."

        printf '%-22s : %s\n' \
            "URL configurée" "${configured_remote_url}"

        printf '%-22s : %s\n' \
            "URL déclarée" "${remote_url}"

        return 1
    fi

    if [[ ! -d "${project_path}/dist" ]]; then
        print_error \
            "Répertoire dist/ introuvable : ${project_path}/dist"
        return 1
    fi

    printf '%-22s : %s\n' \
        "Projet" "${project_name}"
    printf '%-22s : %s\n' \
        "ID projet" "${project_id}"
    printf '%-22s : %s\n' \
        "Répertoire" "${project_path}"
    printf '%-22s : %s\n' \
        "Type distant" "Forgejo"
    printf '%-22s : %s\n' \
        "Dépôt distant" "${remote_name}"
    printf '%-22s : %s\n' \
        "URL distante" "${remote_url}"
    printf '%-22s : %s\n' \
        "Branche locale" "${local_default_branch}"
    printf '%-22s : %s\n' \
        "Branche distante" "${remote_branch_ref}"

    print_success \
        "Projet validé : ${project_path}"

    # ==========================================================
    # Étape 3 - Sélection du paquet Debian
    # ==========================================================

    print_title "Étape 3/11 — Sélection du paquet Debian"

    while IFS= read -r -d '' file; do
        dist_files+=("${file}")
    done < <(
        find "${project_path}/dist" \
            -maxdepth 1 \
            -type f \
            -name '*.deb' \
            -print0 \
            2>/dev/null
    )

    if [[ ${#dist_files[@]} -eq 0 ]]; then
        print_error \
            "Aucun paquet Debian trouvé dans ${project_path}/dist/"
        return 1
    fi

    if [[ ${#dist_files[@]} -gt 1 ]]; then
        print_error \
            "Plusieurs paquets Debian sont présents dans ${project_path}/dist/ :"

        for deb_file in "${dist_files[@]}"; do
            printf '  %s\n' "$(basename "${deb_file}")"
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
    # Étape 4 - Vérification des métadonnées Debian
    # ==========================================================

    print_title "Étape 4/11 — Vérification des métadonnées Debian"

    # Les marqueurs sont interprétés par dpkg-deb, pas par Bash.
    # shellcheck disable=SC2016
    package_name="$(
        dpkg-deb \
            --show \
            --showformat='${Package}' \
            "${deb_file}" \
            2>/dev/null
    )"

    # Expansion différée volontaire du marqueur Debian Version.
    # shellcheck disable=SC2016
    package_version="$(
        dpkg-deb \
            --show \
            --showformat='${Version}' \
            "${deb_file}" \
            2>/dev/null
    )"

    if [[ "${package_name}" != "${project_id}" ]]; then
        print_error \
            "Nom de paquet invalide : '${package_name}' (attendu : ${project_id})"
        return 1
    fi

    if [[ -z "${package_version}" ]]; then
        print_error \
            "Impossible de déterminer la version Debian."
        return 1
    fi

    deb_version="${package_version}"

    if [[ "${deb_filename}" != "${project_id}_${deb_version}_all.deb" ]]; then
        print_error \
            "Incohérence entre le nom du fichier et la version Debian."
        print_error \
            "Fichier : ${deb_filename}"
        print_error \
            "Version : ${deb_version}"
        return 1
    fi

    print_success \
        "Paquet Debian valide : ${package_name} ${package_version}"

    # ----------------------------------------------------------
    # Recherche d'un tag sur le dernier commit Git
    # ----------------------------------------------------------

    if ! local_git_tag="$(diu_release_version_matches "${project_path}" "${deb_version}")"; then
        return 1
    fi
    tag_name="v${deb_version}"
    if [[ -n "${local_git_tag}" ]]; then
        tag_source="git"
    else
        tag_source="debian"
    fi

    # ==========================================================
    # Étape 5 - Validation du dépôt Forgejo
    # ==========================================================

    print_title "Étape 5/11 — Validation du dépôt Forgejo"

    print_success \
        "Forgejo : ${remote_base_url}"
    print_success \
        "Owner   : ${remote_owner}"
    print_success \
        "Repo    : ${remote_repository}"
    print_success \
        "Remote  : ${remote_name}"

    # ==========================================================
    # Étape 6 - Authentification Forgejo
    # ==========================================================

    print_title "Étape 6/11 — Authentification Forgejo"

    if ! forgejo_credentials_prepare "${project_path}" "${remote_name}"; then
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
    # Étape 7 - Vérification de la synchronisation Git
    # ==========================================================

    print_title "Étape 7/11 — Vérification de la synchronisation Git"

    if ! forgejo_git_fetch "${project_path}"; then
        print_error \
            "Échec du git fetch authentifié."
        return 1
    fi

    print_success \
        "git fetch ${remote_name} authentifié effectué."

    current_branch="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" \
            branch --show-current \
            2>/dev/null
    )"

    if [[ "${current_branch}" != "${local_default_branch}" ]]; then
        print_error \
            "La branche courante est '${current_branch}' (attendu : ${local_default_branch})."
        return 1
    fi

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" \
        rev-parse --verify \
        "${remote_branch_ref}" >/dev/null 2>&1; then

        print_error \
            "La branche distante ${remote_branch_ref} n'existe pas."
        return 1
    fi

    head_sha="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" \
            rev-parse HEAD \
            2>/dev/null
    )"

    remote_branch_sha="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" \
            rev-parse "${remote_branch_ref}" \
            2>/dev/null
    )"

    if [[ -z "${head_sha}" || -z "${remote_branch_sha}" ]]; then
        print_error \
            "Impossible de déterminer l'état Git."
        return 1
    fi

    if [[ "${head_sha}" != "${remote_branch_sha}" ]]; then
        print_error \
            "Le dépôt local n'est pas synchronisé avec ${remote_branch_ref}."

        print_error \
            "HEAD                  : ${head_sha:0:12}"

        print_error \
            "${remote_branch_ref} : ${remote_branch_sha:0:12}"

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
        "HEAD == ${remote_branch_ref} (${head_sha:0:12})"

    # ==========================================================
    # Étape 8 - Vérification du tag et de la Release
    # ==========================================================

    print_title \
        "Étape 8/11 — Vérification du tag ${tag_name} et de la Release"

    remote_tag_exists=0

    # Vérification du tag
    api_response="$(
        _forgejo_release_api \
            GET \
            "${remote_base_url}/api/v1/repos/${remote_owner}/${remote_repository}/tags/${tag_name}"
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
            remote_tag_exists=1

            if [[ "${tag_source}" == "git" ]]; then

                print_success \
                    "Le tag ${tag_name} existe déjà sur Forgejo."

                print_info \
                    "Le tag du commit local sera réutilisé pour la Release."

            else

                # Comportement historique lorsque le tag est généré
                # depuis la version Debian.
                print_error \
                    "Le tag ${tag_name} existe déjà sur Forgejo."

                print_error \
                    "Aucun tag existant ne sera déplacé ou modifié."

                return 1
            fi
            ;;

        404)
            remote_tag_exists=0

            print_success \
                "Le tag ${tag_name} n'existe pas sur Forgejo."
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
                    jq -r \
                        '.message // "erreur inconnue"' \
                        2>/dev/null
            )"

            print_error \
                "Erreur lors de la vérification du tag."

            print_error \
                "HTTP ${http_code} : ${error_msg}"

            return 1
            ;;
    esac

    # Vérification de la Release
    api_response="$(
        _forgejo_release_api \
            GET \
            "${remote_base_url}/api/v1/repos/${remote_owner}/${remote_repository}/releases/tags/${tag_name}"
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
                    jq -r \
                        '.message // "erreur inconnue"' \
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
    # Étape 9 - Création / réutilisation du tag
    # ==========================================================

    if [[ "${remote_tag_exists}" -eq 1 ]]; then

        print_title \
            "Étape 9/11 — Réutilisation du tag ${tag_name}"

        print_success \
            "Tag ${tag_name} déjà disponible sur Forgejo."

    else

        print_title \
            "Étape 9/11 — Création du tag ${tag_name}"

        api_response="$(
            _forgejo_release_api \
                POST \
                "${remote_base_url}/api/v1/repos/${remote_owner}/${remote_repository}/tags" \
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

        if [[ "${http_code}" -lt 200 ||
              "${http_code}" -ge 300 ]]; then

            error_msg="$(
                printf '%s' "${http_body}" |
                    jq -r \
                        '.message // "erreur inconnue"' \
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
    fi

    # ==========================================================
    # Étape 10 - Création de la Release
    # ==========================================================

    print_title \
        "Étape 10/11 — Création de la Release ${project_name} ${deb_version}"

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
            "${remote_base_url}/api/v1/repos/${remote_owner}/${remote_repository}/releases" \
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

    if [[ "${http_code}" -lt 200 ||
          "${http_code}" -ge 300 ]]; then

        error_msg="$(
            printf '%s' "${http_body}" |
                jq -r \
                    '.message // "erreur inconnue"' \
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
    # Étape 11 - Upload du paquet
    # ==========================================================

    print_title \
        "Étape 11/11 — Upload du paquet ${deb_filename}"

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
            "${remote_base_url}/api/v1/repos/${remote_owner}/${remote_repository}/releases/${release_id}/assets" \
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
                jq -r \
                    '.message // "erreur inconnue"' \
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

    printf '\n'

    print_success \
        "Release Debian ${project_id} ${deb_version} publiée avec succès."

    printf '%-12s : %s\n' \
        "Projet" "${project_name}"

    printf '%-12s : %s\n' \
        "Tag" "${tag_name}"

    printf '%-12s : %s\n' \
        "Source tag" "${tag_source}"

    printf '%-12s : %s\n' \
        "Commit" "${head_sha:0:12}"

    printf '%-12s : %s\n' \
        "Release" "${release_id}"

    printf '%-12s : %s\n' \
        "Asset" "${deb_filename}"

    return 0
}

# Compatibilité avec le parcours historique de publication du paquet DIU.
publish_release_diu() {
    publish_release_debian "diu"
}

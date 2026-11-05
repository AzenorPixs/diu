#!/usr/bin/env bash
# Publication des paquets Debian dans GitHub Releases.

# shellcheck source=modules/projects/diu-packaging.sh
. "$(dirname -- "${BASH_SOURCE[0]}")/diu-packaging.sh"

_github_release_created_json() {
    local response="$1" code="${1%%$'\n'*}" body="${1#*$'\n'}"
    if [[ "$code" != 201 ]] || ! jq -e 'type == "object"' <<< "$body" >/dev/null 2>&1; then
        print_error "Échec de l’écriture GitHub ou réponse JSON invalide (HTTP ${code})."
        return 1
    fi
    printf '%s' "${response#*$'\n'}"
}

projects_github_release_debian() {
    PROJECTS_DEBIAN_RELEASE_STATUS=""
    local project_id="${1:-}" project_path="" project_env="" tool=""
    local package_name="" package_version="" architecture="" deb_file="" deb_filename=""
    local remote_url="" configured_url="" current_branch="" head_sha="" remote_sha=""
    local api_base="" repository_path="" selected_version="" tag_source="" tag_name=""
    local response="" http_code="" body="" tag_exists=0 object_type="" object_sha="" depth=0
    local display_project_label='Répertoire      '
    if [[ "${PROJECTS_CICD_REPLAY:-0}" == 1 ]]; then display_project_label='Répertoire isolé'; fi
    local release_id="" upload_url="" payload="" asset_size="" head_message="" release_existing=0 asset_count=0
    # Ancres consommées par les lecteurs et transports via la portée dynamique Bash.
    # shellcheck disable=SC2034
    local github_username="" github_token=""
    local -a packages=()

    if [[ $# -ne 1 || ! "$project_id" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ||
        "$project_id" == . || "$project_id" == .. || -z "${ENV_DEVOPS_PROJECTS_ROOT:-}" ]]; then
        print_error 'Usage : diu projects github release <ID PROJECT>'
        return 1
    fi
    project_path="${ENV_DEVOPS_PROJECTS_ROOT}/${project_id}"
    project_env="$project_path/project.env"
    if [[ ! -d "$project_path" || -L "$project_path" || ! -f "$project_env" ]]; then
        print_error 'Projet ou configuration GitHub introuvable.'
        return 1
    fi
    project_version_get "$project_env" >/dev/null || return 1
    unset PROJECT_ID PROJECT_NAME PROJECT_TYPE PROJECT_DOCKERED PROJECT_DEBIAN_PACKAGE \
        LOCAL_DEFAULT_BRANCH REMOTE_GITHUB_BASE_URL REMOTE_GITHUB_OWNER \
        REMOTE_GITHUB_REPOSITORY REMOTE_GITHUB_NAME REMOTE_GITHUB_BRANCH
    # shellcheck disable=SC1090
    source "$project_env" || return 1
    case "${PROJECT_DEBIAN_PACKAGE:-}" in
        Yes|YES|1) ;;
        *) print_info "Le projet $project_id ne produit aucun paquet Debian."; return 0 ;;
    esac
    if [[ "${PROJECT_ID:-}" != "$project_id" || -z "${PROJECT_NAME:-}" ||
        -z "${LOCAL_DEFAULT_BRANCH:-}" || -z "${REMOTE_GITHUB_BASE_URL:-}" ||
        -z "${REMOTE_GITHUB_OWNER:-}" || -z "${REMOTE_GITHUB_REPOSITORY:-}" ||
        -z "${REMOTE_GITHUB_NAME:-}" || -z "${REMOTE_GITHUB_BRANCH:-}" ]]; then
        print_error 'Configuration générale ou GitHub incomplète pour la release Debian.'
        return 1
    fi
    if [[ ! "$REMOTE_GITHUB_OWNER" =~ ^[A-Za-z0-9][A-Za-z0-9-]*$ ||
        ! "$REMOTE_GITHUB_REPOSITORY" =~ ^[A-Za-z0-9_.-]+$ ||
        "$REMOTE_GITHUB_REPOSITORY" == . || "$REMOTE_GITHUB_REPOSITORY" == .. ||
        "$REMOTE_GITHUB_BASE_URL" != https://* || "$REMOTE_GITHUB_BASE_URL" == *@* ||
        "$REMOTE_GITHUB_BASE_URL" == *\?* || "$REMOTE_GITHUB_BASE_URL" == *\#* ||
        "$REMOTE_GITHUB_BASE_URL" == *[[:space:]]* ]]; then
        print_error 'Identité du dépôt GitHub invalide.'
        return 1
    fi
    for tool in git curl jq dpkg-deb find; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            print_error "Outil requis absent : $tool"; return 1
        fi
    done
    if ! check_devops_user; then return 1; fi
    remote_url="${REMOTE_GITHUB_BASE_URL%/}/${REMOTE_GITHUB_OWNER}/${REMOTE_GITHUB_REPOSITORY}.git"
    configured_url="$(runuser -u "$ENV_DEVOPS_USER" -- git -C "$project_path" remote get-url "$REMOTE_GITHUB_NAME")" || return 1
    if [[ "$configured_url" != "$remote_url" ]]; then
        print_error 'Le remote GitHub ne correspond pas à project.env.'
        return 1
    fi
    if [[ ! -d "$project_path/dist" || -L "$project_path/dist" ]]; then
        print_error 'Répertoire dist absent ou symbolique.'; return 1
    fi
    while IFS= read -r -d '' deb_file; do packages+=("$deb_file"); done < <(
        find "$project_path/dist" -maxdepth 1 -type f -name '*.deb' -print0
    )
    if [[ ${#packages[@]} -ne 1 ]]; then
        print_error 'dist doit contenir un seul paquet Debian pour la publication GitHub.'
        return 1
    fi
    deb_file="${packages[0]}"
    deb_filename="$(basename -- "$deb_file")"
    package_name="$(dpkg-deb -f "$deb_file" Package)" || return 1
    package_version="$(dpkg-deb -f "$deb_file" Version)" || return 1
    architecture="$(dpkg-deb -f "$deb_file" Architecture)" || return 1
    if [[ "$package_name" != "$project_id" || "$architecture" != all ||
        "$deb_filename" != "${project_id}_${package_version}_all.deb" ]]; then
        print_error 'Nom, architecture ou métadonnées du paquet Debian incohérents.'
        return 1
    fi
    selected_version="$(diu_release_version_matches "$project_path" "$package_version")" || return 1
    tag_name="v${package_version}"
    tag_source=debian
    if [[ -n "$selected_version" ]]; then tag_source=git; fi
    api_base="$(_github_api_base "$REMOTE_GITHUB_BASE_URL")" || return 1
    repository_path="/repos/${REMOTE_GITHUB_OWNER}/${REMOTE_GITHUB_REPOSITORY}"

    print_info "Publication Debian GitHub : projet $project_id, dépôt ${REMOTE_GITHUB_OWNER}/${REMOTE_GITHUB_REPOSITORY}, tag $tag_name."
    print_info 'GitHub : vérification des identifiants.'
    _github_ensure_api_credentials "$project_path" || return 1
    print_info 'GitHub : identifiants disponibles.'
    github_git_fetch "$project_path" "$REMOTE_GITHUB_NAME" || return 1
    print_info "GitHub : récupération Git effectuée depuis $REMOTE_GITHUB_NAME."
    current_branch="$(runuser -u "$ENV_DEVOPS_USER" -- git -C "$project_path" branch --show-current)" || return 1
    head_sha="$(runuser -u "$ENV_DEVOPS_USER" -- git -C "$project_path" rev-parse HEAD)" || return 1
    remote_sha="$(runuser -u "$ENV_DEVOPS_USER" -- git -C "$project_path" rev-parse "refs/remotes/${REMOTE_GITHUB_NAME}/${REMOTE_GITHUB_BRANCH}")" || return 1
    if [[ "$current_branch" != "$LOCAL_DEFAULT_BRANCH" || -z "$head_sha" || -z "$remote_sha" ]]; then
        print_error 'La branche locale doit être attendue et HEAD synchronisé avec GitHub.'
        return 1
    fi
    if [[ "$head_sha" != "$remote_sha" ]] &&
        { [[ "${PROJECTS_CICD_REPLAY:-0}" != 1 && "${PROJECTS_CICD_RECONCILED:-0}" != 1 ]] ||
          ! runuser -u "$ENV_DEVOPS_USER" -- git -C "$project_path" merge-base --is-ancestor "$head_sha" "$remote_sha"; }; then
        print_error 'Le commit du tag est absent de la branche GitHub distante.'
        return 1
    fi
    printf '%s : %s\n' \
        'Projet          ' "$PROJECT_NAME" \
        'ID projet       ' "$project_id" \
        "$display_project_label" "$project_path" \
        'Type distant    ' 'GitHub' \
        'Dépôt distant   ' "$REMOTE_GITHUB_NAME" \
        'URL distante    ' "$configured_url" \
        'Branche locale  ' "$current_branch" \
        'Branche distante' "$REMOTE_GITHUB_NAME/$REMOTE_GITHUB_BRANCH"
    if [[ "$head_sha" == "$remote_sha" ]]; then
        print_info "GitHub : HEAD synchronisé avec ${REMOTE_GITHUB_NAME}/${REMOTE_GITHUB_BRANCH} (${head_sha:0:12})."
    else
        print_info "GitHub : commit du tag présent dans ${REMOTE_GITHUB_NAME}/${REMOTE_GITHUB_BRANCH} (${head_sha:0:12})."
    fi
    head_message="$(runuser -u "$ENV_DEVOPS_USER" -- git -C "$project_path" log -1 --format=%s)" || return 1

    response="$(_github_api_request "$api_base" GET "$repository_path/git/ref/tags/$tag_name")" || return 1
    http_code="${response%%$'\n'*}"; body="${response#*$'\n'}"
    case "$http_code" in
        200)
            if [[ "$tag_source" != git ]]; then
                print_error 'Le tag existe déjà sans source Git locale ; aucun tag ne sera déplacé.'; return 1
            fi
            object_type="$(jq -er '.object.type | select(. == "tag" or . == "commit")' <<< "$body")" || return 1
            object_sha="$(jq -er '.object.sha | strings | select(test("^[a-f0-9]{40}([a-f0-9]{24})?$"))' <<< "$body")" || return 1
            while [[ "$object_type" == tag ]]; do
                depth=$((depth+1))
                if [[ "$depth" -gt 8 ]]; then print_error 'Chaîne de tags GitHub invalide.'; return 1; fi
                response="$(_github_api_request "$api_base" GET "$repository_path/git/tags/$object_sha")" || return 1
                if [[ "${response%%$'\n'*}" != 200 ]]; then print_error 'Impossible de vérifier le tag GitHub.'; return 1; fi
                body="${response#*$'\n'}"
                object_type="$(jq -er '.object.type | select(. == "tag" or . == "commit")' <<< "$body")" || return 1
                object_sha="$(jq -er '.object.sha | strings | select(test("^[a-f0-9]{40}([a-f0-9]{24})?$"))' <<< "$body")" || return 1
            done
            if [[ "$object_sha" != "$head_sha" ]]; then
                print_error 'Le tag distant ne désigne pas HEAD ; aucun déplacement autorisé.'; return 1
            fi
            tag_exists=1
            print_info "GitHub : tag $tag_name déjà présent et cohérent."
            ;;
        404) print_info "GitHub : tag $tag_name absent." ;;
        *) print_error "Vérification du tag GitHub refusée (HTTP ${http_code})."; return 1 ;;
    esac
    response="$(_github_api_request "$api_base" GET "$repository_path/releases/tags/$tag_name")" || return 1
    http_code="${response%%$'\n'*}"
    if [[ "$http_code" == 200 ]]; then
        body="${response#*$'\n'}"
        if [[ "$tag_exists" != 1 ]] || ! jq -e --arg tag "$tag_name" \
            'type == "object" and .tag_name == $tag and (.assets | type == "array")' <<< "$body" >/dev/null; then
            print_error 'Release GitHub existante incohérente.'; return 1
        fi
        asset_count="$(jq -er --arg name "$deb_filename" '[.assets[] | select(.name == $name)] | length' <<< "$body")" || return 1
        if [[ "$asset_count" -gt 1 ]]; then
            print_error 'Assets GitHub ambigus pour cette version.'; return 1
        fi
        if [[ "$asset_count" -eq 1 ]]; then
            if ! jq -e --arg name "$deb_filename" 'any(.assets[]; .name == $name and .state == "uploaded")' <<< "$body" >/dev/null; then
                print_error 'Asset GitHub existant incomplet ou incohérent.'; return 1
            fi
            print_info "Paquet Debian déjà présent sur GitHub pour $tag_name ; cohérence du contenu non vérifiée."
            # Statut consommé par le bilan CI/CD.
            # shellcheck disable=SC2034
            PROJECTS_DEBIAN_RELEASE_STATUS="déjà publié"
            return 0
        fi
        release_id="$(jq -er '.id | numbers | select(. > 0 and floor == .)' <<< "$body")" || return 1
        upload_url="$(jq -er '.upload_url | strings | select(length > 0)' <<< "$body")" || return 1
        release_existing=1
    elif [[ "$http_code" != 404 ]]; then
        print_error "Vérification de release GitHub refusée (HTTP ${http_code})."; return 1
    else
        print_info "GitHub : aucune release existante pour $tag_name."
    fi
    if [[ "$tag_exists" == 0 ]]; then
        payload="$(jq -n --arg tag "$tag_name" --arg sha "$head_sha" \
            '{tag:$tag,message:("Release "+$tag),object:$sha,type:"commit"}')" || return 1
        response="$(_github_api_request "$api_base" POST "$repository_path/git/tags" "$payload")" || return 1
        body="$(_github_release_created_json "$response")" || return 1
        object_sha="$(jq -er '.sha | strings | select(test("^[a-f0-9]{40}([a-f0-9]{24})?$"))' <<< "$body")" || return 1
        payload="$(jq -n --arg ref "refs/tags/$tag_name" --arg sha "$object_sha" '{ref:$ref,sha:$sha}')" || return 1
        response="$(_github_api_request "$api_base" POST "$repository_path/git/refs" "$payload")" || return 1
        _github_release_created_json "$response" >/dev/null || return 1
    fi
    if [[ "$release_existing" == 0 ]]; then
    payload="$(jq -n --arg tag "$tag_name" --arg sha "$head_sha" \
        --arg name "$PROJECT_NAME $package_version" --arg message "$head_message" \
        '{tag_name:$tag,target_commitish:$sha,name:$name,body:("Version : "+$tag+"\nCommit : "+$sha+"\nMessage : "+$message),draft:false,prerelease:false}')" || return 1
    response="$(_github_api_request "$api_base" POST "$repository_path/releases" "$payload")" || {
        print_error 'Création de release GitHub échouée ; aucun rollback automatique.'; return 1;
    }
    body="$(_github_release_created_json "$response")" || {
        print_error 'Création de release non confirmée ; une release peut rester incomplète, sans rollback automatique.'; return 1;
    }
    release_id="$(jq -er '.id | numbers | select(. > 0 and floor == .)' <<< "$body")" || {
        print_error 'Identifiant de release invalide ; une release peut rester incomplète, sans rollback automatique.'; return 1;
    }
    upload_url="$(jq -er '.upload_url | strings | select(length > 0)' <<< "$body")" || {
        print_error "Release créée sans URL d’upload valide ; publication incomplète."; return 1;
    }
    fi
    response="$(_github_upload_release_asset "$api_base" "$upload_url" "$deb_file" "$repository_path" "$release_id")" || {
        print_error "Release GitHub créée mais incomplète après échec d’upload ; aucun rollback automatique."; return 1;
    }
    body="$(_github_release_created_json "$response")" || {
        print_error 'Release GitHub créée mais asset non confirmé ; aucun rollback automatique.'; return 1;
    }
    asset_size="$(stat -c '%s' "$deb_file")" || return 1
    if ! jq -e --arg name "$deb_filename" --argjson size "$asset_size" \
        '(.id | type == "number") and .name == $name and .state == "uploaded" and .size == $size' \
        <<< "$body" >/dev/null; then
        print_error 'Asset GitHub incohérent ; release incomplète, aucun rollback automatique.'
        return 1
    fi
    print_success "Paquet Debian publié sur GitHub : $deb_filename ($tag_name)."
    printf 'Téléchargement : %s/releases/download/%s/%s\n' \
        "${REMOTE_GITHUB_BASE_URL%/}/${REMOTE_GITHUB_OWNER}/${REMOTE_GITHUB_REPOSITORY}" "$tag_name" "$deb_filename"
}

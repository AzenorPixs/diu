#!/usr/bin/env bash

_diu_update_version_gt() {
    local left="$1" right="$2" stable='^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$'
    if [[ "$left" =~ $stable && ! "$right" =~ $stable ]]; then
        return 0
    fi
    if [[ ! "$left" =~ $stable && "$right" =~ $stable ]]; then
        return 1
    fi
    dpkg --compare-versions "$left" gt "$right"
}

# Lire uniquement les paramètres publics du fournisseur demandé, sans exécuter project.env.
_diu_update_config() {
    local file="$1" provider="$2" line key value raw
    local assignment="^[[:blank:]]*(export[[:blank:]]+)?(REMOTE_(${provider})_(BASE_URL|OWNER|REPOSITORY))[[:blank:]]*=(.*)$"
    local literal="^[[:blank:]]*([A-Za-z0-9._:/%+~-]+|\"[A-Za-z0-9._:/%+~-]+\"|'[A-Za-z0-9._:/%+~-]+')[[:blank:]]*$"
    local -A seen=()
    [[ -f "$file" && -r "$file" && ! -L "$file" ]] || {
        print_error "Configuration du projet DIU inaccessible : $file" >&2
        return 1
    }
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ "$line" =~ $assignment ]] || continue
        key="${BASH_REMATCH[2]}"; raw="${BASH_REMATCH[5]}"
        [[ ! ${seen[$key]+present} ]] || { print_error "Variable dupliquée : $key" >&2; return 1; }
        seen[$key]=1
        # Une valeur vide est traitée comme une absence de configuration.
        [[ "$raw" =~ ^[[:blank:]]*$ || "$raw" == "''" || "$raw" == '""' ]] && continue
        [[ "$raw" =~ $literal ]] || { print_error "Valeur non littérale : $key" >&2; return 1; }
        value="${BASH_REMATCH[1]}"
        value="${value#\"}"; value="${value%\"}"
        value="${value#\'}"; value="${value%\'}"
        printf -v "$key" '%s' "$value"
    done < "$file"
}

# Choisir un candidat dans un seul fournisseur ; les résultats remontent au sous-shell appelant.
_diu_update_select() {
    local provider="$1" prefix base_key owner_key repo_key base owner repo api page response previous_response count rows
    local tag name url version
    local REMOTE_GITHUB_BASE_URL='' REMOTE_GITHUB_OWNER='' REMOTE_GITHUB_REPOSITORY=''
    local REMOTE_FORGEJO_BASE_URL='' REMOTE_FORGEJO_OWNER='' REMOTE_FORGEJO_REPOSITORY=''
    # Les paramètres sont résolus par expansion indirecte.
    # shellcheck disable=SC2034
    : "$REMOTE_GITHUB_BASE_URL" "$REMOTE_GITHUB_OWNER" "$REMOTE_GITHUB_REPOSITORY" "$REMOTE_FORGEJO_BASE_URL" "$REMOTE_FORGEJO_OWNER" "$REMOTE_FORGEJO_REPOSITORY"
    if [[ "$provider" == GITHUB ]]; then
        base='https://github.com'; owner='AzenorPixs'; repo='diu'
        api="https://api.github.com/repos/$owner/$repo/releases"
    else
        [[ -n "$project_path" ]] || { print_error 'Configuration Forgejo indisponible.'; return 1; }
        _diu_update_config "${project_path}/project.env" "$provider" || return 1
        prefix="REMOTE_${provider}"; base_key="${prefix}_BASE_URL"; owner_key="${prefix}_OWNER"; repo_key="${prefix}_REPOSITORY"
        base="${!base_key}"; owner="${!owner_key}"; repo="${!repo_key}"
        [[ -n "$base" && -n "$owner" && -n "$repo" ]] || { print_error "Configuration $provider incomplète."; return 1; }
        [[ "$base" =~ ^https://[A-Za-z0-9.-]+(:[0-9]+)?(/[A-Za-z0-9._~-]+)*/*$ && "$owner" =~ ^[A-Za-z0-9._/-]+$ && "$repo" =~ ^[A-Za-z0-9._-]+$ && "$owner" != *..* && "$repo" != *..* ]] || { print_error "Configuration $provider invalide."; return 1; }
        base="${base%/}"
        api="$base/api/v1/repos/$owner/$repo/releases"
    fi
    page=1; previous_response=''
    while :; do
        response="$(curl --disable --compressed --fail --silent --show-error --location --proto '=https' --proto-redir '=https' --connect-timeout 10 --max-time 60 "${api}?per_page=100&page=${page}")" || { print_error "Impossible de consulter les releases $provider."; return 1; }
        count="$(jq -er 'if type == "array" then length else error("réponse invalide") end' <<< "$response")" || { print_error "Réponse $provider invalide."; return 1; }
        [[ "$count" -gt 0 ]] || break
        if [[ "$response" == "$previous_response" || "$page" -gt 1000 ]]; then
            print_error "Pagination $provider invalide."; return 1
        fi
        previous_response="$response"
        jq -e 'all(.[]; type == "object" and (.tag_name | type == "string") and ((.assets // []) | type == "array"))' <<< "$response" >/dev/null || { print_error "Réponse $provider invalide."; return 1; }
        rows="$(jq -er '[.[] | select(.draft != true and .prerelease != true and (.tag_name|type)=="string") | .tag_name as $tag | (.assets // [])[] | select((.name|type)=="string" and (.browser_download_url|type)=="string") | [$tag,.name,.browser_download_url] | @tsv] | .[]' <<< "$response")" || { [[ "$?" == 4 ]] || { print_error "Assets $provider invalides."; return 1; }; }
        while IFS=$'\t' read -r tag name url; do
            [[ -n "$tag" && "$tag" == v* ]] || continue
            version="${tag#v}"
            [[ "$version" =~ ^[0-9][A-Za-z0-9.+~:-]*$ && "$name" == "diu_${version}_all.deb" ]] || continue
            dpkg --validate-version "$version" >/dev/null 2>&1 || continue
            [[ -z "$requested_version" || "$version" == "$requested_version" ]] || continue
            [[ "$url" == "$base/"* && "$url" != *[[:space:]]* ]] || { print_error "URL d'asset $provider non conforme."; return 1; }
            if [[ -z "$best_version" ]] || _diu_update_version_gt "$version" "$best_version"; then
                best_version="$version"; best_url="$url"; best_provider="$provider"
            fi
        done <<< "$rows"
        page=$((page + 1))
    done
    [[ -n "$best_version" ]] || { print_error 'Aucun paquet DIU admissible trouvé.'; return 1; }
    return 0
}

# Exécuter dans un sous-shell afin de limiter configuration et temporaires.
update_diu() (
    local best_version='' best_url='' best_provider='' installed='' status='' temp_dir='' file=''
    local project_path='' requested_version="${1:-}"
    local package_version='' package_name='' package_arch=''
    local executable
    for executable in curl jq dpkg dpkg-query dpkg-deb mktemp; do
        command -v "$executable" >/dev/null 2>&1 || { print_error "Commande indisponible : $executable"; return 1; }
    done
    if [[ $# -gt 1 || ( $# -eq 1 && ( -z "$requested_version" || ! "$requested_version" =~ ^[0-9][A-Za-z0-9.+~:-]*$ ) ) ]]; then
        print_error 'Usage : diu diu update [VERSION] ; version Debian invalide.'; return 2
    fi
    if [[ -n "$requested_version" ]] && ! dpkg --validate-version "$requested_version" >/dev/null 2>&1; then
        print_error 'Version DIU invalide.'; return 2
    fi
    [[ -z "${ENV_DEVOPS_PROJECTS_ROOT:-}" ]] || project_path="${ENV_DEVOPS_PROJECTS_ROOT%/}/diu"
    trap '[[ -z "${temp_dir:-}" ]] || rm -rf -- "$temp_dir"' EXIT
    # shellcheck disable=SC2016
    status="$(dpkg-query -W -f='${db:Status-Status} ${Version}' diu 2>/dev/null)" || { print_error 'Version installée du DIU indisponible.'; return 1; }
    [[ "$status" == 'installed '* ]] || { print_error "Le paquet DIU n'est pas installé."; return 1; }
    installed="${status#installed }"
    if [[ -z "$installed" ]] || ! dpkg --validate-version "$installed" >/dev/null 2>&1; then
        print_error 'Version installée du DIU invalide.'; return 1
    fi
    if ! _diu_update_select GITHUB; then
        if [[ -n "$requested_version" ]]; then
            print_error "Version DIU $requested_version indisponible sur GitHub."; return 1
        fi
        best_version=''; best_url=''; best_provider=''
        print_info 'GitHub indisponible ou sans paquet admissible ; tentative Forgejo.'
        _diu_update_select FORGEJO || { print_error 'Aucun fournisseur DIU disponible avec un paquet admissible.'; return 1; }
    fi
    if [[ -z "$requested_version" ]] && ! _diu_update_version_gt "$best_version" "$installed"; then
        print_info "DIU déjà à jour : $installed (dernière version : $best_version)."
        return 0
    fi
    temp_dir="$(mktemp -d)" || { print_error 'Impossible de créer le répertoire temporaire.'; return 1; }
    file="$temp_dir/diu_${best_version}_all.deb"
    print_info "Téléchargement DIU $best_version depuis $best_provider."
    curl --disable --compressed --fail --silent --show-error --location --proto '=https' --proto-redir '=https' --connect-timeout 10 --max-time 300 --output "$file" "$best_url" || { print_error 'Téléchargement du paquet DIU échoué.'; return 1; }
    # Les champs dpkg sont des expressions littérales.
    # shellcheck disable=SC2016
    package_name="$(dpkg-deb --show --showformat='${Package}' "$file" 2>/dev/null)" || { print_error 'Lecture du nom du paquet impossible.'; return 1; }
    # shellcheck disable=SC2016
    package_version="$(dpkg-deb --show --showformat='${Version}' "$file" 2>/dev/null)" || { print_error 'Lecture de la version du paquet impossible.'; return 1; }
    # shellcheck disable=SC2016
    package_arch="$(dpkg-deb --show --showformat='${Architecture}' "$file" 2>/dev/null)" || { print_error "Lecture de l'architecture du paquet impossible."; return 1; }
    [[ "$package_name" == diu && "$package_version" == "$best_version" && "$package_arch" == all ]] || { print_error 'Métadonnées du paquet DIU incohérentes.'; return 1; }
    dpkg --install "$file" || { print_error 'Installation du paquet DIU échouée.'; return 1; }
)

# Isolation de la mise à jour lors du parcours global.
diu_update() {
    (update_diu "$@")
}

# Affiche la version du DIU

diu_version() {
    local version=""

    if ! command -v dpkg-query >/dev/null 2>&1; then
        print_error "La commande dpkg-query est indisponible."
        return 1
    fi

    version="$(
        dpkg-query \
            -W \
            -f='${Version}' \
            diu 2>/dev/null
    )"

    if [[ -z "${version}" ]]; then
        print_error "Le paquet DIU n'est pas installé sur ce système."
        return 1
    fi

    printf '%s\n' "${version}"
}

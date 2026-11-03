#!/usr/bin/env bash

# Lire uniquement les paramètres publics des fournisseurs, sans exécuter project.env.
_diu_update_config() {
    local file="$1" line key value raw
    local assignment='^[[:blank:]]*(export[[:blank:]]+)?(REMOTE_(FORGEJO|GITHUB|GITLAB)_(BASE_URL|OWNER|REPOSITORY))[[:blank:]]*=(.*)$'
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

# Exécuter dans un sous-shell afin de limiter configuration et temporaires.
update_diu() (
    # Les valeurs sont utilisées par expansion indirecte pour chaque fournisseur.
    # shellcheck disable=SC2034
    local REMOTE_FORGEJO_BASE_URL='' REMOTE_FORGEJO_OWNER='' REMOTE_FORGEJO_REPOSITORY=''
    # shellcheck disable=SC2034
    local REMOTE_GITHUB_BASE_URL='' REMOTE_GITHUB_OWNER='' REMOTE_GITHUB_REPOSITORY=''
    # shellcheck disable=SC2034
    local REMOTE_GITLAB_BASE_URL='' REMOTE_GITLAB_OWNER='' REMOTE_GITLAB_REPOSITORY=''
    local provider prefix base_key owner_key repo_key base owner repo api path page response previous_response count rows
    local tag name url version best_version='' best_url='' best_provider='' installed='' status='' temp_dir='' file=''
    local project_path='' github_token='' github_config='' github_authenticated=0 best_github_authenticated=0
    local package_version='' package_name='' package_arch='' configured=0
    local executable
    for executable in curl jq dpkg dpkg-query dpkg-deb mktemp; do
        command -v "$executable" >/dev/null 2>&1 || { print_error "Commande indisponible : $executable"; return 1; }
    done
    [[ -n "${DEVOPS_PROJECTS_ROOT:-}" ]] || { print_error 'DEVOPS_PROJECTS_ROOT est absent.'; return 1; }
    project_path="${DEVOPS_PROJECTS_ROOT%/}/diu"
    _diu_update_config "${project_path}/project.env" || return 1
    trap '[[ -z "${github_config:-}" ]] || rm -f -- "$github_config"; [[ -z "${temp_dir:-}" ]] || rm -rf -- "$temp_dir"' EXIT
    # shellcheck disable=SC2016
    status="$(dpkg-query -W -f='${db:Status-Status} ${Version}' diu 2>/dev/null)" || { print_error 'Version installée du DIU indisponible.'; return 1; }
    [[ "$status" == 'installed '* ]] || { print_error "Le paquet DIU n'est pas installé."; return 1; }
    installed="${status#installed }"
    if [[ -z "$installed" ]] || ! dpkg --validate-version "$installed" >/dev/null 2>&1; then
        print_error 'Version installée du DIU invalide.'; return 1
    fi
    for provider in FORGEJO GITHUB GITLAB; do
        prefix="REMOTE_${provider}"; base_key="${prefix}_BASE_URL"; owner_key="${prefix}_OWNER"; repo_key="${prefix}_REPOSITORY"
        base="${!base_key}"; owner="${!owner_key}"; repo="${!repo_key}"
        [[ -n "$base$owner$repo" ]] || continue
        [[ -n "$base" && -n "$owner" && -n "$repo" ]] || { print_error "Configuration $provider incomplète."; return 1; }
        [[ "$base" =~ ^https://[A-Za-z0-9.-]+(:[0-9]+)?(/[A-Za-z0-9._~-]+)*/*$ && "$owner" =~ ^[A-Za-z0-9._/-]+$ && "$repo" =~ ^[A-Za-z0-9._-]+$ && "$owner" != *..* && "$repo" != *..* ]] || { print_error "Configuration $provider invalide."; return 1; }
        configured=$((configured + 1)); base="${base%/}"
        case "$provider" in
            FORGEJO) api="$base/api/v1/repos/$owner/$repo/releases" ;;
            GITHUB)
                if [[ "$base" == https://github.com ]]; then api="https://api.github.com/repos/$owner/$repo/releases"; else api="$base/api/v3/repos/$owner/$repo/releases"; fi
                if [[ -e "$project_path/config/github.token" ]]; then
                    set +x
                    if ! declare -F _github_read_token >/dev/null || ! _github_read_token "$project_path"; then
                        print_error 'Impossible de lire les identifiants GitHub du projet.'; return 1
                    fi
                    if [[ -z "$github_token" || "$github_token" == *$'\r'* || "$github_token" == *$'\n'* || "$github_token" == *'"'* || "$github_token" == *\\* ]]; then
                        print_error 'Identifiant GitHub invalide.'; return 1
                    fi
                    github_config="$(mktemp)" || { print_error "Impossible de préparer l'authentification GitHub."; return 1; }
                    chmod 600 "$github_config" || { print_error "Impossible de sécuriser l'authentification GitHub."; return 1; }
                    printf 'header = "Authorization: Bearer %s"\n' "$github_token" > "$github_config" || return 1
                    github_authenticated=1
                fi ;;
            GITLAB)
                path="$(jq -rn --arg value "$owner/$repo" '$value|@uri')" || return 1
                api="$base/api/v4/projects/$path/releases" ;;
        esac
        page=1; previous_response=''
        while :; do
            if [[ "$provider" == GITHUB && "$github_authenticated" == 1 ]]; then
                response="$(curl --config "$github_config" --header 'Accept: application/vnd.github+json' --compressed --fail --silent --show-error --location --proto '=https' --proto-redir '=https' --connect-timeout 10 --max-time 60 "${api}?per_page=100&page=${page}")" || { print_error "Impossible de consulter les releases $provider."; return 1; }
            else
                response="$(curl --compressed --fail --silent --show-error --location --proto '=https' --proto-redir '=https' --connect-timeout 10 --max-time 60 "${api}?per_page=100&page=${page}")" || { print_error "Impossible de consulter les releases $provider."; return 1; }
            fi
            count="$(jq -er 'if type == "array" then length else error("réponse invalide") end' <<< "$response")" || { print_error "Réponse $provider invalide."; return 1; }
            [[ "$count" -gt 0 ]] || break
            if [[ "$response" == "$previous_response" || "$page" -gt 1000 ]]; then
                print_error "Pagination $provider invalide."; return 1
            fi
            previous_response="$response"
            if [[ "$provider" == GITLAB ]]; then
                jq -e 'all(.[]; type == "object" and (.tag_name | type == "string") and ((.assets // {}) | type == "object") and ((.assets.links // []) | type == "array"))' <<< "$response" >/dev/null || { print_error "Réponse $provider invalide."; return 1; }
            else
                jq -e 'all(.[]; type == "object" and (.tag_name | type == "string") and ((.assets // []) | type == "array"))' <<< "$response" >/dev/null || { print_error "Réponse $provider invalide."; return 1; }
            fi
            if [[ "$provider" == GITLAB ]]; then
                rows="$(jq -er '[.[] | select((.tag_name|type)=="string") | .tag_name as $tag | (.assets.links // [])[] | select((.name|type)=="string" and (.url|type)=="string") | [$tag,.name,.url] | @tsv] | .[]' <<< "$response")" || { [[ "$?" == 4 ]] || { print_error "Assets $provider invalides."; return 1; }; }
            elif [[ "$provider" == GITHUB && "$github_authenticated" == 1 ]]; then
                rows="$(jq -er '[.[] | select(.draft != true and .prerelease != true and (.tag_name|type)=="string") | .tag_name as $tag | (.assets // [])[] | select((.name|type)=="string") | [$tag,.name,((.id // "")|tostring)] | @tsv] | .[]' <<< "$response")" || { [[ "$?" == 4 ]] || { print_error "Assets $provider invalides."; return 1; }; }
            else
                rows="$(jq -er '[.[] | select(.draft != true and .prerelease != true and (.tag_name|type)=="string") | .tag_name as $tag | (.assets // [])[] | select((.name|type)=="string" and (.browser_download_url|type)=="string") | [$tag,.name,.browser_download_url] | @tsv] | .[]' <<< "$response")" || { [[ "$?" == 4 ]] || { print_error "Assets $provider invalides."; return 1; }; }
            fi
            while IFS=$'\t' read -r tag name url; do
                [[ -n "$tag" && "$tag" == v* ]] || continue
                version="${tag#v}"
                [[ "$version" =~ ^[0-9][A-Za-z0-9.+~:-]*$ && "$name" == "diu_${version}_all.deb" ]] || continue
                dpkg --validate-version "$version" >/dev/null 2>&1 || continue
                if [[ "$provider" == GITHUB && "$github_authenticated" == 1 ]]; then
                    [[ "$url" =~ ^[1-9][0-9]*$ ]] || { print_error "Identifiant d'asset GitHub invalide."; return 1; }
                    url="${api%/releases}/releases/assets/${url}"
                else
                    [[ "$url" == "$base/"* && "$url" != *[[:space:]]* ]] || { print_error "URL d'asset $provider non conforme."; return 1; }
                fi
                if [[ -z "$best_version" ]] || dpkg --compare-versions "$version" gt "$best_version"; then
                    best_version="$version"; best_url="$url"; best_provider="$provider"
                    if [[ "$provider" == GITHUB ]]; then best_github_authenticated="$github_authenticated"; else best_github_authenticated=0; fi
                fi
            done <<< "$rows"
            page=$((page + 1))
        done
    done
    [[ "$configured" -gt 0 && -n "$best_version" ]] || { print_error 'Aucun paquet DIU admissible trouvé.'; return 1; }
    if dpkg --compare-versions "$best_version" le "$installed"; then
        print_info "DIU déjà à jour : $installed (dernière version : $best_version)."
        return 0
    fi
    temp_dir="$(mktemp -d)" || { print_error 'Impossible de créer le répertoire temporaire.'; return 1; }
    file="$temp_dir/diu_${best_version}_all.deb"
    print_info "Téléchargement DIU $best_version depuis $best_provider."
    if [[ "$best_github_authenticated" == 1 ]]; then
        curl --config "$github_config" --header 'Accept: application/octet-stream' --compressed --fail --silent --show-error --location --proto '=https' --proto-redir '=https' --connect-timeout 10 --max-time 300 --output "$file" "$best_url" || { print_error 'Téléchargement du paquet DIU échoué.'; return 1; }
    else
        curl --compressed --fail --silent --show-error --location --proto '=https' --proto-redir '=https' --connect-timeout 10 --max-time 300 --output "$file" "$best_url" || { print_error 'Téléchargement du paquet DIU échoué.'; return 1; }
    fi
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
    (update_diu)
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

#!/usr/bin/env bash

# shellcheck source=lib/project-version.sh
. "$(dirname -- "${BASH_SOURCE[0]}")/../../lib/project-version.sh"
# Construction déclarative des paquets Debian de projets.

projects_debian_enabled() {
    local project_env="$1" line="" raw="" value="" found=0
    local assignment='^[[:blank:]]*(export[[:blank:]]+)?PROJECT_DEBIAN_PACKAGE[[:blank:]]*=(.*)$'
    local literal="^[[:blank:]]*([A-Za-z0-9_-]*|\"[A-Za-z0-9_-]*\"|'[A-Za-z0-9_-]*')[[:blank:]]*(#.*)?$"
    if [[ ! -e "$project_env" && ! -L "$project_env" ]]; then
        return 0
    fi
    if [[ -L "$project_env" || ! -f "$project_env" || ! -r "$project_env" ]]; then
        print_error 'Configuration du projet illisible ou symbolique.' >&2
        return 1
    fi
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ "$line" =~ $assignment ]] || continue
        raw="${BASH_REMATCH[2]}"
        if [[ "$found" == 1 || ! "$raw" =~ $literal ]]; then
            print_error 'PROJECT_DEBIAN_PACKAGE est ambigu ou non littéral.' >&2
            return 1
        fi
        value="${BASH_REMATCH[1]}"
        value="${value#\"}"; value="${value%\"}"
        value="${value#\'}"; value="${value%\'}"
        found=1
    done < "$project_env"
    case "$value" in Yes|YES|1) printf '1' ;; esac
    return 0
}

projects_debian_version() {
    local project_path="$1" tags="" tag="" candidate="" version=""
    if [[ ! -e "$project_path/.git" ]]; then return 0; fi
    if ! tags="$(runuser -u "$ENV_DEVOPS_USER" -- git -C "$project_path" tag --points-at HEAD)"; then
        print_error 'Impossible de consulter les tags du projet source.' >&2
        return 1
    fi
    tags="$(printf '%s\n' "$tags" | project_version_prefer_stable_tags)" || return 1
    while IFS= read -r tag; do
        [[ -n "$tag" ]] || continue
        candidate="${tag#v}"
        if ! dpkg --validate-version "$candidate" >/dev/null 2>&1; then
            print_error 'Un tag de HEAD ne définit pas une version Debian valide.' >&2
            return 1
        fi
        if [[ -n "$version" && "$version" != "$candidate" ]]; then
            print_error 'Plusieurs versions distinctes sont associées à HEAD.' >&2
            return 1
        fi
        version="$candidate"
    done <<< "$tags"
    printf '%s' "$version"
}

projects_debian_path_valid() {
    local path="$1"
    [[ -n "$path" && "$path" != *[[:cntrl:]]* && "$path" != */ &&
        "$path" != *//* && "/$path/" != */../* && "/$path/" != */./* ]]
}

# Un sous-shell isole le trap et les variables de la commande appelante.
projects_build_deb() (
    set -Eeuo pipefail
    local project_id="${1:-}" project_path="" projects_root="" recipe="" enabled=""
    local package="" architecture="" maintainer="" description="" depends="" version=""
    local staging_dir="" build_dir="" package_file="" source="" destination="" real_source=""
    local forbidden="" row="" previous="" tool=""
    local -a sources=() destinations=()

    if [[ $# -ne 1 || ! "$project_id" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ||
        "$project_id" == . || "$project_id" == .. || -z "${ENV_DEVOPS_PROJECTS_ROOT:-}" ]]; then
        print_error 'Usage : rid projects build debian <ID PROJECT>'
        return 2
    fi
    projects_root="$(realpath -e -- "$ENV_DEVOPS_PROJECTS_ROOT")" || return 1
    project_path="$projects_root/$project_id"
    if [[ -L "$project_path" || ! -d "$project_path" ]]; then
        print_error "Projet absent ou symbolique : $project_id"
        return 1
    fi
    project_path="$(realpath -e -- "$project_path")" || return 1
    [[ "$(dirname -- "$project_path")" == "$projects_root" ]] || return 1
    enabled="$(projects_debian_enabled "$project_path/project.env")" || return 1
    if [[ "$enabled" != 1 ]]; then
        print_info "Le projet $project_id ne produit aucun paquet Debian."
        return 0
    fi

    recipe="$project_path/build/debian-package.json"
    if [[ ! -e "$recipe" && ! -L "$recipe" ]]; then
        print_error "Fichier de build Debian absent : $recipe ; le paquet ne peut pas être construit."
        return 1
    fi
    if [[ -L "$project_path/build" || -L "$recipe" || ! -f "$recipe" || ! -r "$recipe" ]]; then
        print_error 'Recette Debian illisible, non régulière ou symbolique.'
        return 1
    fi
    for tool in jq dpkg dpkg-deb; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            print_error "Outil de construction absent : $tool"
            return 1
        fi
    done
    if ! dpkg-deb --help 2>&1 | grep -q -- '--root-owner-group'; then
        print_error 'dpkg-deb ne supporte pas --root-owner-group.'
        return 1
    fi
    # Les chaînes de contrôle Debian et les chemins ne sont jamais interprétés.
    if ! jq -e '
        def text: type == "string" and length > 0 and (explode | all(. >= 32 and . != 127));
        type == "object" and
        ((keys - ["package","architecture","maintainer","description","depends","version","files"]) | length == 0) and
        (.package | text and test("^[a-z0-9][a-z0-9+.-]+$")) and
        (.architecture | text and test("^[a-z0-9][a-z0-9-]*$")) and
        (.maintainer | text) and (.description | text) and
        ((has("version") | not) or (.version | text)) and
        ((has("depends") | not) or (.depends | type == "array" and all(.[]; text))) and
        (.files | type == "array" and length > 0 and all(.[];
            type == "object" and keys == ["destination","source"] and
            (.source | text) and (.destination | text)))
        ' "$recipe" >/dev/null 2>&1; then
        print_error 'Recette Debian invalide : métadonnées ou copies incorrectes.'
        return 1
    fi
    package="$(jq -r '.package' "$recipe")"
    architecture="$(jq -r '.architecture' "$recipe")"
    maintainer="$(jq -r '.maintainer' "$recipe")"
    description="$(jq -r '.description' "$recipe")"
    depends="$(jq -r '(.depends // []) | join(", ")' "$recipe")"
    version="$(project_version_get "$project_path/project.env")" || return 1
    if [[ -z "$version" ]]; then
        version="$(jq -r '.version // empty' "$recipe")"
    fi
    if [[ -z "$version" ]]; then
        version="$(projects_debian_version "$project_path")" || return 1
        if [[ -z "$version" ]]; then version="$(date '+%Y.%m.%d.%H.%M')" || return 1; fi
    fi
    if [[ "$version" == */* ]] || ! dpkg --validate-version "$version" >/dev/null 2>&1; then
        print_error 'Version du paquet Debian invalide.'
        return 1
    fi
    if [[ -L "$project_path/dist" || ( -e "$project_path/dist" && ! -d "$project_path/dist" ) ]]; then
        print_error 'Destination dist invalide ou symbolique.'
        return 1
    fi
    # Valider toutes les copies avant de créer les répertoires de construction.
    while IFS= read -r row; do
        source="$(jq -r '.source' <<< "$row")"
        destination="$(jq -r '.destination' <<< "$row")"
        if [[ "$source" == /* || "$destination" != /* || "$destination" == /DEBIAN ||
            "$destination" == /DEBIAN/* ]] ||
            ! projects_debian_path_valid "$source" || ! projects_debian_path_valid "$destination"; then
            print_error 'Chemin de recette Debian invalide.'
            return 1
        fi
        real_source="$(realpath -e -- "$project_path/$source")" || {
            print_error "Source Debian absente : $source"; return 1;
        }
        if [[ "$real_source" != "$project_path/"* || -L "$project_path/$source" ||
            "$real_source" == "$project_path/dist" || "$real_source" == "$project_path/dist/"* ||
            "$recipe" == "$real_source" || "$recipe" == "$real_source/"* ]]; then
            print_error 'Source Debian hors périmètre ou incluant la recette ou dist.'
            return 1
        fi
        for previous in "${destinations[@]}"; do
            if [[ "$destination" == "$previous" || "$destination" == "$previous/"* || "$previous" == "$destination/"* ]]; then
                print_error 'Destinations Debian recouvrantes.'; return 1
            fi
        done
        forbidden="$(find "$project_path/$source" \( -type l -o \( ! -type f ! -type d \) -o \
            -name .git -o -name .opencode -o -name openspec -o -name deb -o -name dist -o \
            -name .cache -o -name __pycache__ -o -name node_modules -o -name .mypy_cache -o \
            -name .pytest_cache -o -name .ruff_cache -o -name .venv -o -name venv -o -name logs -o -name tmp -o \
            -name '*.pyc' -o -name '*.pyo' -o -name '*.log' -o -name '*.tmp' -o -name '*.temp' -o \
            -name '*.swp' -o -name '*.swo' -o -name '*~' -o -name '*.bak' -o -name '*.orig' -o -name '*.rej' -o \
            -name .env -o -name '*.env' -o -name '*.env.*' -o -name '*.key' -o -name '*.pem' -o \
            -name '*.crt' -o -name '*.cer' -o -name '*.der' -o -name '*.p12' -o -name '*.pfx' -o \
            -name id_rsa -o -name id_ed25519 -o \
            -name credentials.json -o -name credentials.yaml -o -name secrets.json -o -name secrets.yaml \) -print)" || return 1
        if [[ -n "$forbidden" ]]; then
            print_error 'Source Debian contenant un lien, fichier spécial ou élément privé/temporaire interdit.'
            return 1
        fi
        # Un parent symbolique interne reste interdit, même s'il résout dans le projet.
        if [[ "$real_source" != "$project_path/$source" ]]; then
            print_error 'Source Debian traversant un lien symbolique.'; return 1
        fi
        sources+=("$real_source"); destinations+=("$destination")
    done < <(jq -c '.files[]' "$recipe")

    trap 'rm -rf -- "${staging_dir:-}" "${build_dir:-}"' EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM
    staging_dir="$(mktemp -d)" || return 1
    mkdir -p -- "$staging_dir/DEBIAN" || return 1
    chmod 00755 "$staging_dir/DEBIAN" || return 1
    local index
    for index in "${!sources[@]}"; do
        destination="$staging_dir${destinations[$index]}"
        mkdir -p -- "$(dirname -- "$destination")" || return 1
        cp -R -- "${sources[$index]}" "$destination" || return 1
    done
    {
        printf 'Package: %s\nVersion: %s\nArchitecture: %s\nMaintainer: %s\nDescription: %s\n' \
            "$package" "$version" "$architecture" "$maintainer" "$description"
        if [[ -n "$depends" ]]; then printf 'Depends: %s\n' "$depends"; fi
    } > "$staging_dir/DEBIAN/control"
    build_dir="$(mktemp -d "$project_path/.debian-build.XXXXXX")" || return 1
    package_file="${package}_${version}_${architecture}.deb"
    print_info "Construction Debian : $package ($version, $architecture)"
    if ! dpkg-deb --build --root-owner-group "$staging_dir" "$build_dir/$package_file"; then
        print_error 'Échec de la construction du paquet Debian.'; return 1
    fi
    mkdir -p -- "$project_path/dist" || return 1
    if ! mv -- "$build_dir/$package_file" "$project_path/dist/$package_file"; then
        print_error 'Échec du dépôt du paquet Debian dans dist.'; return 1
    fi
    if ! find "$project_path/dist" -maxdepth 1 -type f -name "${package}_*_${architecture}.deb" \
        ! -name "$package_file" -delete; then
        print_error 'Échec de la rotation des anciens paquets Debian.'; return 1
    fi
    print_success "Paquet construit : $project_path/dist/$package_file"
)

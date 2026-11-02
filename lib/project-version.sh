#!/usr/bin/env bash
# Sélection explicite de version, sans exécuter la configuration du projet.

project_version_get() {
    local project_env="${1:-}" line="" raw="" value="" found=0
    local assignment='^[[:blank:]]*(export[[:blank:]]+)?PROJECT_VERSION[[:blank:]]*=(.*)$'
    local literal="^[[:blank:]]*([0-9.]+|\"[0-9.]+\"|'[0-9.]+')([[:blank:]]+#.*)?[[:blank:]]*$"
    local version_pattern='^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$'
    if [[ -z "$project_env" ]]; then
        printf '%s\n' 'Erreur : chemin de configuration du projet absent.' >&2
        return 1
    fi
    if [[ ! -e "$project_env" && ! -L "$project_env" ]]; then return 0; fi
    if [[ -L "$project_env" || ! -f "$project_env" || ! -r "$project_env" ]]; then
        printf '%s\n' 'Erreur : configuration de version illisible ou symbolique.' >&2
        return 1
    fi
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ "$line" =~ $assignment ]] || continue
        raw="${BASH_REMATCH[2]}"
        if [[ "$found" == 1 || ! "$raw" =~ $literal ]]; then
            printf '%s\n' 'Erreur : PROJECT_VERSION doit être une affectation littérale unique x.y.z.' >&2
            return 1
        fi
        value="${BASH_REMATCH[1]}"
        value="${value#\"}"; value="${value%\"}"
        value="${value#\'}"; value="${value%\'}"
        if [[ ! "$value" =~ $version_pattern || ${#value} -gt 128 ]]; then
            printf '%s\n' 'Erreur : PROJECT_VERSION doit respecter le format x.y.z sans zéro initial.' >&2
            return 1
        fi
        found=1
    done < "$project_env"
    printf '%s' "$value"
}

# Références vers les paramètres locaux du commit ou du flux appelant.
project_version_commit_parameters() {
    local version_project_path="$1" selected_project_version=""
    local -n version_commit_name_ref="$2" version_commit_tag_ref="$3"
    selected_project_version="$(project_version_get "$version_project_path/project.env")" || return 1
    if [[ -n "$selected_project_version" ]]; then
        # Sortie par référence vers le paramètre de l'appelant.
        # shellcheck disable=SC2034
        version_commit_tag_ref="v${selected_project_version}"
        if [[ -z "$version_commit_name_ref" ||
            "$version_commit_name_ref" =~ ^[0-9]{4}(\.[0-9]{2}){4}$ ]]; then
            version_commit_name_ref="$selected_project_version"
        fi
    fi
}

# Une publication versionnée exige un tag local cohérent, sans en créer un.
project_version_tag_for_head() {
    local project_path="$1" version="$2" git_user="${3:-${DEVOPS_USER:-}}"
    local head_sha="" tag_sha=""
    if ! head_sha="$(runuser -u "$git_user" -- env -u GIT_COMMON_DIR git -C "$project_path" rev-parse --verify HEAD)" ||
        ! tag_sha="$(runuser -u "$git_user" -- env -u GIT_COMMON_DIR git -C "$project_path" rev-parse --verify "refs/tags/v${version}^{commit}" 2>/dev/null)" ||
        [[ -z "$head_sha" || "$tag_sha" != "$head_sha" ]]; then
        printf '%s\n' 'Erreur : le tag correspondant à PROJECT_VERSION doit exister et désigner HEAD.' >&2
        return 1
    fi
    printf 'v%s' "$version"
}

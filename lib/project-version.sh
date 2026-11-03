#!/usr/bin/env bash
# Sélection explicite de version, sans exécuter la configuration du projet.

# Conserver les tags non horodatés lorsque des versions stables sont présentes.
project_version_prefer_stable_tags() {
    local tag="" has_stable=0
    local stable='^v?(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$'
    local timestamp='^v?[0-9]{4}(\.[0-9]{2}){4}$'
    local -a version_tags_buffer=()
    while IFS= read -r tag; do
        [[ -n "$tag" ]] || continue
        version_tags_buffer+=("$tag")
        [[ "$tag" =~ $stable ]] && has_stable=1
    done
    for tag in "${version_tags_buffer[@]}"; do
        if [[ "$has_stable" == 1 && "$tag" =~ $timestamp ]]; then continue; fi
        printf '%s\n' "$tag"
    done
}

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

# Modifier uniquement la version, sans interpréter le reste de la configuration.
project_version_set() {
    local file="${1:-}" version="${2:-}" current=""
    local pattern='^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$'
    if [[ ! "$version" =~ $pattern || ${#version} -gt 128 || ! -f "$file" || -L "$file" ]]; then
        printf '%s\n' 'Erreur : version ou configuration du projet invalide.' >&2
        return 1
    fi
    current="$(project_version_get "$file")" || return 1
    if [[ "$current" == "$version" ]]; then
        printf '%s\n' 'ℹ️  PROJECT_VERSION est déjà configurée à cette version.'
        return 0
    fi
    if ! command -v python3 >/dev/null 2>&1; then
        printf '%s\n' 'Erreur : python3 est nécessaire pour modifier PROJECT_VERSION.' >&2
        return 1
    fi
    python3 - "$file" "$version" <<'PY'
import os, re, stat, sys, tempfile
path, version = sys.argv[1:]
tmp = None
try:
    with open(path, 'rb') as stream:
        before = os.fstat(stream.fileno())
        data = stream.read()
    if not stat.S_ISREG(before.st_mode):
        raise ValueError('configuration non régulière')
    assignment = re.compile(rb'''(?m)^([ \t]*(?:export[ \t]+)?PROJECT_VERSION[ \t]*=[ \t]*)([0-9.]+|"[0-9.]+"|'[0-9.]+')([ \t]*(?:\#[^\n]*)?)(\n|$)''')
    matches = list(assignment.finditer(data))
    if len(matches) > 1:
        raise ValueError('version dupliquée')
    replacement = b'PROJECT_VERSION=' + version.encode('ascii')
    if matches:
        match = matches[0]
        previous = match.group(2)
        quote = previous[:1] if previous[:1] in (b"'", b'"') else b''
        updated = match.group(1) + quote + version.encode('ascii') + quote + match.group(3) + match.group(4)
        result = data[:match.start()] + updated + data[match.end():]
    else:
        result = data + (b'\n' if data and not data.endswith(b'\n') else b'') + replacement + b'\n'
    fd, tmp = tempfile.mkstemp(prefix='.project-version-', dir=os.path.dirname(path) or '.')
    with os.fdopen(fd, 'wb') as stream:
        os.fchown(stream.fileno(), before.st_uid, before.st_gid)
        os.fchmod(stream.fileno(), stat.S_IMODE(before.st_mode))
        stream.write(result)
    now = os.lstat(path)
    if (now.st_dev, now.st_ino, now.st_mtime_ns, now.st_size) != (before.st_dev, before.st_ino, before.st_mtime_ns, before.st_size):
        raise ValueError('configuration modifiée simultanément')
    os.replace(tmp, path)
    tmp = None
except (OSError, ValueError) as error:
    print('Erreur : impossible de mettre à jour PROJECT_VERSION : ' + str(error), file=sys.stderr)
    sys.exit(1)
finally:
    if tmp is not None:
        os.unlink(tmp)
PY
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

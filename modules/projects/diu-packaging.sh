#!/usr/bin/env bash

# shellcheck source=lib/project-version.sh
. "$(dirname -- "${BASH_SOURCE[0]}")/../../lib/project-version.sh"
# Fonctions de construction du paquet Debian DIU

# Retourne la version unique de HEAD, ou une sortie vide sans tag.
diu_package_version_from_head() {
    local project_path="${1:-}" tags="" tag="" candidate="" version=""
    version="$(project_version_get "${project_path}/project.env")" || return 1
    if [[ -n "$version" ]]; then printf '%s' "$version"; return 0; fi
    if [[ ! -e "${project_path}/.git" ]]; then
        return 0
    fi
    if ! tags="$(runuser -u "${DEVOPS_USER}" -- git -C "${project_path}" tag --points-at HEAD)"; then
        print_error "Impossible de consulter les tags du projet source."
        return 1
    fi
    tags="$(printf '%s\n' "$tags" | project_version_prefer_stable_tags)" || return 1
    while IFS= read -r tag; do
        [[ -n "${tag}" ]] || continue
        candidate="${tag#v}"
        if ! dpkg --validate-version "${candidate}" >/dev/null 2>&1; then
            print_error "Un tag de HEAD ne définit pas une version Debian valide."
            return 1
        fi
        if [[ -n "${version}" && "${version}" != "${candidate}" ]]; then
            print_error "Plusieurs versions distinctes sont associées à HEAD."
            return 1
        fi
        version="${candidate}"
    done <<< "${tags}"
    printf '%s' "${version}"
}

# Sans tag, la release conserve la version du paquet existant.
diu_release_version_matches() {
    local project_path="${1:-}" package_version="${2:-}" version=""
    if ! dpkg --validate-version "${package_version}" >/dev/null 2>&1; then
        print_error "Version du paquet Debian invalide."
        return 1
    fi
    local selected_project_version=""
    selected_project_version="$(project_version_get "${project_path}/project.env")" || return 1
    if [[ -n "$selected_project_version" ]]; then
        project_version_tag_for_head "$project_path" "$selected_project_version" >/dev/null || return 1
    fi
    version="$(diu_package_version_from_head "${project_path}")" || return 1
    if [[ -n "${version}" && "${version}" != "${package_version}" ]]; then
        print_error "Le tag Git et la version du paquet Debian sont incohérents."
        return 1
    fi
    printf '%s' "${version}"
}

build_deb_diu() {
    local project_id="${1-diu}"
    local project_path=""
    local staging_dir=""
    local build_dir=""
    local package_version=""
    local diu_maintainer=""
    local package_name=""
    local forbidden_list=""

    # ----------------------------------------------------------
    # Validation du paramètre
    # ----------------------------------------------------------

    if [[ $# -gt 1 || ! "${project_id}" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ||
        "${project_id}" == . || "${project_id}" == .. || -z "${ENV_DEVOPS_PROJECTS_ROOT:-}" ]]; then
        print_error "Usage : build_deb_diu [project_id]"
        return 1
    fi
    project_path="${ENV_DEVOPS_PROJECTS_ROOT}/${project_id}"
    if [[ -L "${project_path}" || ! -d "${project_path}" ]]; then
        print_error "Projet source DIU absent ou symbolique."
        return 1
    fi
    local projects_root_real="" project_real=""
    projects_root_real="$(realpath -e -- "${ENV_DEVOPS_PROJECTS_ROOT}")" || return 1
    project_real="$(realpath -e -- "${project_path}")" || return 1
    if [[ "$(dirname -- "${project_real}")" != "${projects_root_real}" ]]; then
        print_error "Projet source hors de la racine autorisée."
        return 1
    fi
    project_path="${project_real}"

    # ----------------------------------------------------------
    # Vérification des prérequis
    # ----------------------------------------------------------

    if ! command -v dpkg-deb >/dev/null 2>&1; then
        print_error "dpkg-deb n'est pas disponible. Paquet dpkg requis."
        return 1
    fi

    if ! dpkg-deb --help 2>&1 | grep -q '\-\-root-owner-group'; then
        print_error "dpkg-deb ne supporte pas --root-owner-group."
        return 1
    fi

    # ----------------------------------------------------------
    # Validation du projet cible
    # ----------------------------------------------------------

    if [[ ! -d "${project_path}" ]]; then
        print_error "Projet introuvable : ${project_path}"
        return 1
    fi

    local missing=()
    [[ ! -f "${project_path}/root-install-debian.sh" ]] && missing+=("root-install-debian.sh")
    [[ ! -d "${project_path}/lib" ]] && missing+=("lib/")
    [[ ! -d "${project_path}/modules" ]] && missing+=("modules/")

    if [[ ${#missing[@]} -gt 0 ]]; then
        print_error "Éléments manquants dans le projet : ${missing[*]}"
        return 1
    fi

    # ----------------------------------------------------------
    # Génération des métadonnées du paquet
    # ----------------------------------------------------------

    if ! package_version="$(diu_package_version_from_head "${project_path}")"; then
        return 1
    fi
    if [[ -z "${package_version}" ]]; then
        if ! package_version="$(date +'%Y.%m.%d.%H.%M')"; then
            print_error "Impossible de déterminer la version du paquet."
            return 1
        fi
    fi
    if ! dpkg --validate-version "${package_version}" >/dev/null 2>&1; then
        print_error "Version du paquet Debian invalide."
        return 1
    fi
    print_info "Version du paquet : ${package_version}"

    diu_maintainer="Anthony DEMARD <postmaster@pixs.fr>"

    # ----------------------------------------------------------
    # Préparation de dist/
    # ----------------------------------------------------------

    if ! mkdir -p "${project_path}/dist"; then
        print_error "Impossible de créer ${project_path}/dist."
        return 1
    fi

    # ----------------------------------------------------------
    # Création du staging temporaire
    # ----------------------------------------------------------

    staging_dir="$(mktemp -d)" || {
        print_error "Impossible de créer un répertoire temporaire."
        return 1
    }

    if [[ -z "${staging_dir}" ]] || [[ ! -d "${staging_dir}" ]]; then
        print_error "Répertoire temporaire invalide : '${staging_dir}'."
        return 1
    fi

    if ! mkdir -p "${staging_dir}/root/diu"; then
        print_error "Impossible de créer ${staging_dir}/root/diu."
        rm -rf "${staging_dir}"
        return 1
    fi

    if ! mkdir -p "${staging_dir}/DEBIAN"; then
        print_error "Impossible de créer ${staging_dir}/DEBIAN."
        rm -rf "${staging_dir}"
        return 1
    fi

    # ----------------------------------------------------------
    # Copie de la liste blanche
    # ----------------------------------------------------------

    # Le contrôle Debian ne doit pas hériter du bit setgid du répertoire parent.
    if ! chmod 00755 "${staging_dir}/DEBIAN"; then
        print_error "Impossible de préparer les permissions du contrôle Debian."
        rm -rf "${staging_dir}"
        return 1
    fi

    if ! cp "${project_path}/root-install-debian.sh" "${staging_dir}/root/diu/"; then
        print_error "Échec de la copie de root-install-debian.sh."
        rm -rf "${staging_dir}"
        return 1
    fi

    if ! cp -r "${project_path}/lib" "${staging_dir}/root/diu/"; then
        print_error "Échec de la copie de lib/."
        rm -rf "${staging_dir}"
        return 1
    fi

    if ! cp -r "${project_path}/modules" "${staging_dir}/root/diu/"; then
        print_error "Échec de la copie de modules/."
        rm -rf "${staging_dir}"
        return 1
    fi

    # ----------------------------------------------------------
    # Vérification que variables.sh et config/ ne sont pas présents
    # dans le staging
    # ----------------------------------------------------------

    if [[ -f "${staging_dir}/root/diu/variables.sh" ]]; then
        print_error "variables.sh ne doit pas être présent dans le paquet."
        rm -rf "${staging_dir}"
        return 1
    fi

    if [[ -d "${staging_dir}/root/diu/config" ]]; then
        print_error "config/ ne doit pas être présent dans le paquet."
        rm -rf "${staging_dir}"
        return 1
    fi

    # ----------------------------------------------------------
    # Inspection du staging (barrière de sécurité)
    # ----------------------------------------------------------

    forbidden_list="$(find "${staging_dir}/root/diu" -type d \( \
        -name ".git" -o \
        -name ".opencode" -o \
        -name "openspec" -o \
        -name "deb" -o \
        -name "dist" -o \
        -name ".cache" -o \
        -name "__pycache__" -o \
        -name "node_modules" -o \
        -name ".mypy_cache" -o \
        -name ".pytest_cache" -o \
        -name ".ruff_cache" -o \
        -name ".venv" -o \
        -name "venv" -o \
        -name "logs" -o \
        -name "tmp" \
    \) -print 2>&1)" || {
        print_error "Erreur lors de l'inspection des répertoires du staging."
        rm -rf "${staging_dir}"
        return 1
    }

    if [[ -n "${forbidden_list}" ]]; then
        print_error "Répertoires interdits détectés dans le staging :"
        echo "${forbidden_list}"
        rm -rf "${staging_dir}"
        return 1
    fi

    forbidden_list="$(find "${staging_dir}/root/diu" -type f \( \
        -name "*.pyc" -o \
        -name "*.pyo" -o \
        -name "*.log" -o \
        -name "*.tmp" -o \
        -name "*.temp" -o \
        -name "*.swp" -o \
        -name "*.swo" -o \
        -name "*~" -o \
        -name "*.bak" -o \
        -name "*.orig" -o \
        -name "*.rej" -o \
        -name ".env" -o \
        -name "*.env" -o \
        -name "credentials.json" -o \
        -name "credentials.yaml" -o \
        -name "secrets.json" -o \
        -name "secrets.yaml" \
    \) -print 2>&1)" || {
        print_error "Erreur lors de l'inspection des fichiers du staging."
        rm -rf "${staging_dir}"
        return 1
    }

    if [[ -n "${forbidden_list}" ]]; then
        print_error "Fichiers interdits détectés dans le staging :"
        echo "${forbidden_list}"
        rm -rf "${staging_dir}"
        return 1
    fi

    # ----------------------------------------------------------
    # Génération du fichier control
    # ----------------------------------------------------------

    if ! cat > "${staging_dir}/DEBIAN/control" <<EOF
Package: diu
Version: ${package_version}
Architecture: all
Maintainer: ${diu_maintainer}
Description: Debian Installeur Unifié
Depends: awk
EOF
    then
        print_error "Échec de la génération de DEBIAN/control."
        rm -rf "${staging_dir}"
        return 1
    fi

    # ----------------------------------------------------------
    # Construction du paquet dans un répertoire temporaire dédié
    # ----------------------------------------------------------

    package_name="diu_${package_version}_all.deb"

    build_dir="$(mktemp -d "${project_path}/.diu-build.XXXXXX")" || {
        print_error "Impossible de créer le répertoire de construction."
        rm -rf "${staging_dir}"
        return 1
    }

    if ! dpkg-deb --build --root-owner-group \
        "${staging_dir}" \
        "${build_dir}/${package_name}"; then

        print_error "Échec de la construction du paquet."
        rm -rf "${staging_dir}"
        rm -rf "${build_dir}"
        return 1
    fi

    # ----------------------------------------------------------
    # Publication dans dist/
    # ----------------------------------------------------------

    local final_destination="${project_path}/dist/${package_name}"

    if ! mv "${build_dir}/${package_name}" "${final_destination}"; then
        print_error "Échec de la publication du paquet dans dist/."
        rm -rf "${staging_dir}"
        rm -rf "${build_dir}"
        return 1
    fi

    # ----------------------------------------------------------
    # Rotation des anciens paquets
    # ----------------------------------------------------------

    if ! find "${project_path}/dist" -maxdepth 1 -type f \
        -name "diu_*_all.deb" \
        ! -name "${package_name}" \
        -delete 2>/dev/null; then

        print_error \
            "Échec de la rotation des anciens paquets dans dist/."
        rm -rf "${staging_dir}"
        rm -rf "${build_dir}"
        return 1
    fi

    # ----------------------------------------------------------
    # Nettoyage
    # ----------------------------------------------------------

    rm -rf "${staging_dir}"
    rm -rf "${build_dir}"

    print_success \
        "Paquet construit : ${final_destination}"

    return 0
}

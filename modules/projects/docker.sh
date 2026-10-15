#!/usr/bin/env bash

# Gestion des commandes docker au sein d'un projet

# Lire exclusivement les arguments publics, sans interprétation shell.
projects_docker_load_build_args() {
    local project_dir="$1"
    local -n result="$2"
    local args_file="${project_dir}/build/docker-build.args"
    local LC_ALL=C
    local size args_fd content read_status=0 line key line_number=0
    local -a parsed=()
    local -A seen=()

    result=()
    if [[ ! -e "${args_file}" && ! -L "${args_file}" ]]; then
        return 0
    fi
    if [[ -L "${project_dir}/build" || -L "${args_file}" || ! -f "${args_file}" || ! -r "${args_file}" ]]; then
        echo "❌ Fichier d'arguments Docker non régulier, symbolique ou illisible." >&2
        return 1
    fi
    if ! size=$(stat -c '%s' -- "${args_file}" 2>/dev/null) || [[ ! ${size} =~ ^[0-9]+$ ]] || (( size > 65536 )); then
        echo "❌ Fichier d'arguments Docker inaccessible ou supérieur à 64 Kio." >&2
        return 1
    fi
    if ! { exec {args_fd}< "${args_file}"; } 2>/dev/null; then
        echo "❌ Ouverture du fichier d'arguments Docker impossible." >&2
        return 1
    fi
    # read jusqu'à NUL : 1 signifie EOF normal, 0 détecte un octet interdit.
    IFS= read -r -d '' -n 65537 content <&"${args_fd}" || read_status=$?
    if ! exec {args_fd}<&-; then
        echo "❌ Fermeture du fichier d'arguments Docker impossible." >&2
        return 1
    fi
    if (( read_status != 1 )) || [[ ${content} == *$'\r'* ]]; then
        echo "❌ Fichier d'arguments Docker invalide : lecture, NUL ou CR." >&2
        return 1
    fi
    while IFS= read -r line || [[ -n ${line} ]]; do
        line_number=$((line_number + 1))
        if [[ ${line} =~ ^[[:blank:]]*(#.*)?$ ]]; then
            continue
        fi
        key=${line%%=*}
        if [[ ${line} != *=* || ! ${key} =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
            echo "❌ Arguments Docker invalides (ligne ${line_number}) : NOM=VALEUR attendu." >&2
            return 1
        fi
        if [[ ${seen[${key}]+present} ]]; then
            echo "❌ Arguments Docker invalides (ligne ${line_number}) : doublon." >&2
            return 1
        fi
        seen[${key}]=1
        parsed+=(--build-arg "${line}")
    done <<< "${content}"
    # Le tableau appartient à l'appelant et est affecté via la nameref.
    # shellcheck disable=SC2034
    result=("${parsed[@]}")
}

# ============================================================
# Construction de l'image Docker d'un projet
# ============================================================

projects_docker_build() {

    local project_id="${1:-}"
    local dockerfile="${2:-dockerfile}"

    local project_dir
    local project_env
    local image_name
    local -a docker_build_args=()

    # --------------------------------------------------------
    # Vérification des arguments
    # --------------------------------------------------------

    if [[ -z "${project_id}" ]]; then
        echo "❌ ID du projet obligatoire."
        return 1
    fi

    # --------------------------------------------------------
    # Définition des chemins
    # --------------------------------------------------------

    project_dir="/home/${DEVOPS_USER}/datas/${project_id}"
    project_env="${project_dir}/project.env"

    # --------------------------------------------------------
    # Vérification du projet
    # --------------------------------------------------------

    if [[ ! -d "${project_dir}" ]]; then
        echo "❌ Projet introuvable : ${project_dir}"
        return 1
    fi

    if [[ ! -f "${project_env}" ]]; then
        echo "❌ Fichier project.env introuvable : ${project_env}"
        return 1
    fi

    # --------------------------------------------------------
    # Chargement de la configuration du projet
    # --------------------------------------------------------

    # shellcheck disable=SC1090
    source "${project_env}"

    # --------------------------------------------------------
    # Vérification que le projet est Dockerisé
    # --------------------------------------------------------

    case "${PROJECT_DOCKERED:-}" in
        Yes|YES|1)
            ;;
        *)
            echo "❌ Le projet '${project_id}' n'est pas déclaré comme Dockerisé."
            return 1
            ;;
    esac

    # --------------------------------------------------------
    # Vérification de l'entrypoint
    # --------------------------------------------------------

    if [[ ! -f "${project_dir}/entrypoint.sh" ]]; then
        echo "❌ Entrypoint introuvable : ${project_dir}/entrypoint.sh"
        return 1
    fi

    # --------------------------------------------------------
    # Vérification du Dockerfile
    # --------------------------------------------------------

    if [[ ! -f "${project_dir}/${dockerfile}" ]]; then
        echo "❌ Dockerfile introuvable : ${project_dir}/${dockerfile}"
        return 1
    fi

    # --------------------------------------------------------
    # Nom de l'image
    # --------------------------------------------------------

    image_name="${PROJECT_ID:-${project_id}}"

    if ! projects_docker_load_build_args "${project_dir}" docker_build_args; then
        return 1
    fi

    # --------------------------------------------------------
    # Construction
    # --------------------------------------------------------

    echo
    echo "=========================================================="
    echo " Construction de l'image Docker"
    echo "=========================================================="
    echo
    echo "Projet      : ${PROJECT_NAME:-${project_id}}"
    echo "Répertoire  : ${project_dir}"
    echo "Dockerfile  : ${dockerfile}"
    echo "Image       : ${image_name}:latest"
    echo

    if ! runuser -u "${DEVOPS_USER}" -- \
        docker build \
            --file "${project_dir}/${dockerfile}" \
            --tag "${image_name}:latest" \
            "${docker_build_args[@]}" \
            "${project_dir}"
    then
        echo
        echo "❌ Échec de la construction de l'image Docker."
        return 1
    fi

    echo
    echo "✅ Image Docker construite : ${image_name}:latest"

    return 0
}

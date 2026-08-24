#!/usr/bin/env bash

# Gestion des commandes docker au sein d'un projet

# ============================================================
# Construction de l'image Docker d'un projet
# ============================================================

proj_docker_build() {

    local project_id="${1:-}"
    local dockerfile="${2:-dockerfile}"

    local project_dir
    local project_env
    local image_name

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

    if [[ "${PROJECT_DOCKERED:-No}" != "Yes" ]]; then
        echo "❌ Le projet '${project_id}' n'est pas déclaré comme Dockerisé."
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

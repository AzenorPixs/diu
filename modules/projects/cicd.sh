#!/usr/bin/env bash

# Flux DIU CI/CD 

cicd_project() {
    local project_id="${1:-}"
    local project_name="${2:-}"
    local commit_message="${3:-}"

    local project_path=""

    # ==========================================================
    # Validation des arguments
    # ==========================================================

    if [[ -z "${project_id}" || -z "${project_name}" || -z "${commit_message}" ]]; then
        print_error "Usage : cicd_project <ID Projet> <Nom Projet> <Nom du Commit>"
        return 1
    fi

    # ==========================================================
    # Vérification de l'environnement
    #
    # CI/CD autorisé uniquement dans l'environnement de
    # développement du DIU.
    #
    # Production :
    #   /root/diu
    #
    # Développement :
    #   /home/devops/datas/diu
    # ==========================================================

    if [[ "${DEVOPS_PROJECTS_ROOT}" != "/home/devops/datas" ]]; then
        print_error "La commande CI/CD est interdite dans l'environnement de production."
        print_error "Environnement autorisé : /home/devops/datas/diu"
        print_error "Environnement détecté : ${DEVOPS_PROJECTS_ROOT}/${project_id}"
        return 1
    fi

    project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"

    if [[ ! -d "${project_path}" ]]; then
        print_error "Projet introuvable : ${project_path}"
        return 1
    fi

    if [[ ! -d "/home/devops/datas/diu" ]]; then
        print_error "L'environnement de développement DIU est introuvable."
        return 1
    fi

    # Sécurité supplémentaire :
    # on vérifie que le projet DIU courant est bien celui
    # attendu par le workflow de développement.

    if [[ "$(realpath "${project_path}")" != "/home/devops/datas/${project_id}" ]]; then
        print_error "Chemin du projet inattendu : ${project_path}"
        return 1
    fi

    # ==========================================================
    # Affichage
    # ==========================================================

    print_title "CI/CD du projet ${project_name}"

    print_info "Projet       : ${project_name}"
    print_info "ID Projet    : ${project_id}"
    print_info "Répertoire   : ${project_path}"
    print_info "Commit       : ${commit_message}"

    # ==========================================================
    # Étape 1 — Commit Git
    # ==========================================================

    print_title "Étape 1/4 — Commit Git"

    if ! git_commit \
        "${project_id}" \
        "${project_name}" \
        "${commit_message}"; then

        print_error "Échec du commit Git."
        return 1
    fi

    # ==========================================================
    # Étape 2 — Push Git
    # ==========================================================

    print_title "Étape 2/4 — Push Git"

    if ! git_push \
        "${project_id}" \
        "${project_name}"; then

        print_error "Échec du push Git."
        return 1
    fi

    # ==========================================================
    # Étape 3 — Build Debian
    # ==========================================================

    print_title "Étape 3/4 — Build du paquet Debian"

    if ! build_deb \
        "${project_id}"; then

        print_error "Échec de la construction du paquet Debian."
        return 1
    fi

    # ==========================================================
    # Étape 4 — Publication Release Forgejo
    # ==========================================================

    print_title "Étape 4/4 — Publication de la Release Forgejo"

    if ! publish_release \
        "${project_id}"; then

        print_error "Échec de la publication de la Release Forgejo."
        return 1
    fi

    # ==========================================================
    # Succès
    # ==========================================================

    print_success "CI/CD du projet ${project_name} terminé avec succès."

    return 0
}

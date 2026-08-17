#!/usr/bin/env bash

# ===========================================================
# CI/CD complet d'un projet DIU
# ===========================================================

cicd_project() {
    local project_id="${1:-}"
    local project_name="${2:-}"
    local commit_message="${3:-}"

    local current_diu_root=""
    current_diu_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." 2>/dev/null && pwd)"

    # ----------------------------------------------------------
    # Validation des arguments
    # ----------------------------------------------------------

    if [[ -z "${project_id}" || -z "${project_name}" || -z "${commit_message}" ]]; then
        print_error "Usage : ridt proj cicd <ID Projet> <Nom Projet> <Nom du Commit>"
        return 1
    fi

    # ----------------------------------------------------------
    # Sécurité : CI/CD autorisé uniquement en développement
    # ----------------------------------------------------------

    if [[ "${current_diu_root}" != "/home/devops/datas/diu" ]]; then
        print_error "La commande CI/CD est interdite dans cet environnement."
        print_error "Environnement détecté : ${current_diu_root}"
        print_error "Environnement autorisé : /home/devops/datas/diu"
        return 1
    fi

    # Sécurité supplémentaire : refuser explicitement la production
    if [[ "${current_diu_root}" == "/root/diu" ]]; then
        print_error "La commande CI/CD est interdite en production."
        print_error "Environnement de production : /root/diu"
        return 1
    fi

    print_title "CI/CD du projet ${project_name}"

    print_info "Projet       : ${project_name}"
    print_info "ID           : ${project_id}"
    print_info "Commit       : ${commit_message}"
    print_info "Environnement : ${current_diu_root}"

    # ----------------------------------------------------------
    # Étape 1 : Git commit
    # ----------------------------------------------------------

    print_title "Étape 1/4 — Git commit"

    if ! git_commit \
        "${project_id}" \
        "${project_name}" \
        "${commit_message}"; then

        print_error "Échec du git commit."
        return 1
    fi

    # ----------------------------------------------------------
    # Étape 2 : Git push
    # ----------------------------------------------------------

    print_title "Étape 2/4 — Git push"

    if ! git_push \
        "${project_id}" \
        "${project_name}"; then

        print_error "Échec du git push."
        return 1
    fi

    # ----------------------------------------------------------
    # Étape 3 : Build Debian
    # ----------------------------------------------------------

    print_title "Étape 3/4 — Build Debian"

    if ! build_deb \
        "${project_id}"; then

        print_error "Échec du build Debian."
        return 1
    fi

    # ----------------------------------------------------------
    # Étape 4 : Publication Release Forgejo
    # ----------------------------------------------------------

    print_title "Étape 4/4 — Publication Release Forgejo"

    if ! publish_release \
        "${project_id}"; then

        print_error "Échec de la publication de la Release Forgejo."
        return 1
    fi

    # ----------------------------------------------------------
    # Succès
    # ----------------------------------------------------------

    print_success "CI/CD du projet ${project_name} terminé avec succès."

    return 0
}

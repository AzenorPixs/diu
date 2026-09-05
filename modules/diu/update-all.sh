#!/usr/bin/env bash

# Les participants sont explicites : ne pas exécuter des fonctions découvertes
# à partir de leur nom (config_update et git_update ne mettent pas à jour un logiciel).
update_all() {
    local result=0 module hermes_directory=""
    print_title "Mise à jour de tous les modules DIU"
    if declare -F software_apt_update_all >/dev/null 2>&1; then
        if (set -Eeuo pipefail; software_apt_update_all); then
            print_success "softwares/apt : terminé."
        else
            print_error "softwares/apt : échec."
            result=1
        fi
    elif declare -F system_apt_update >/dev/null 2>&1; then
        if (set -Eeuo pipefail; system_apt_update); then
            print_success "softwares/apt : terminé."
        else
            print_error "softwares/apt : échec."
            result=1
        fi
    else
        print_info "softwares/apt : non chargé dans ce contexte."
    fi
    for module in desktop environment projects system; do
        print_info "$module : aucune sous-fonction de mise à jour prise en charge."
    done
    if [[ -n "${ENV_IA_USER:-}" ]]; then
        hermes_directory="$(_hermes_dir)" || return 1
    fi
    if [[ -z "$hermes_directory" ]]; then
        print_info "ia/hermes : non applicable (non configuré)."
    elif [[ ! -f "$hermes_directory/compose.yml" ]]; then
        print_info "ia/hermes : non applicable (non installé)."
    elif (set -Eeuo pipefail; update_agent_hermes); then
        print_success "ia/hermes : terminé."
    else
        print_error "ia/hermes : échec."
        result=1
    fi
    # exec dpkg dans update_diu reste confiné au sous-shell pour rendre le bilan.
    if (set -Eeuo pipefail; update_diu); then
        print_success "diu : terminé."
    else
        print_error "diu : échec."
        result=1
    fi
    if [[ "$result" -eq 0 ]]; then
        print_success "Mise à jour globale terminée pour les composants pris en charge."
    else
        print_error "Mise à jour globale incomplète : au moins un composant en échec."
    fi
    return "$result"
}

manage_update_action() {
    if [[ $# -eq 0 ]]; then
        update_all
    elif [[ "$1" == diu && $# -eq 1 ]]; then
        update_diu
    else
        manage_software_action update "$@"
    fi
}

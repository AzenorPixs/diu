#!/usr/bin/env bash

# Registre explicite des recettes APT. Il restera vide tant qu'aucun logiciel
# tiers n'aura été déclaré par une évolution dédiée.
software_apt_recipe() {
    case "${1,,}:${2,,}" in
        *) return 1 ;;
    esac
}

software_apt_action() {
    local action="${1:-}" software="${2:-}" recipe=""
    [[ "$action" == install || "$action" == remove || "$action" == update ]] || {
        print_error "Action APT invalide : $action"
        return 2
    }
    [[ "$software" =~ ^[a-z0-9][a-z0-9+.-]*$ ]] || {
        print_error "Identifiant logiciel invalide : $software"
        return 2
    }
    if ! recipe="$(software_apt_recipe "$software" "$action")"; then
        print_error "Logiciel APT non pris en charge : $software"
        return 1
    fi
    "$recipe" "$software"
}

software_apt_update() {
    if declare -F system_apt_update >/dev/null 2>&1; then
        system_apt_update
    else
        print_error "Moteur de mise à jour APT indisponible."
        return 1
    fi
}

manage_softwares_action() {
    local action="${1:-}" engine="${2:-}" software="${3:-}"
    case "$action:$engine" in
        install:apt|remove:apt|update:apt)
            [[ $# -eq 3 ]] || { print_error "Usage : rid softwares $action apt <SOFTWARE>"; return 2; }
            software_apt_action "$action" "$software"
            ;;
        apt:update)
            [[ $# -eq 2 ]] || { print_error "Usage : rid softwares apt update"; return 2; }
            software_apt_update
            ;;
        *)
            print_error "Commande softwares inconnue : $*"
            return 2
            ;;
    esac
}


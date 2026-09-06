#!/usr/bin/env bash

# Les moteurs tiers seront ajoutés lorsque leurs recettes seront disponibles.
manage_software_action() {
    local action="${1:-}" engine="${2:-}" software="${3:-}"
    if [[ $# -lt 2 || $# -gt 3 ]] ||
       [[ "$action" != install && "$action" != remove && "$action" != update ]] ||
       [[ "$action" != update && -z "$software" ]] ||
       [[ $# -eq 3 && -z "$software" ]]; then
        print_error "Usage : rid <install|remove|update> <deb|apt|github> [SOFTWARE]"
        return 2
    fi
    if [[ -n "$software" && ! "$software" =~ ^[a-z0-9][a-z0-9+.-]+(:[a-z0-9][a-z0-9-]*)?$ ]]; then
        print_error "Identifiant logiciel invalide : $software"
        return 2
    fi
    case "$engine" in
        deb) software_deb "$action" "$software" ;;
        apt) software_apt_action "$action" "$software" ;;
        github) software_github_action "$action" "$software" ;;
        *)
            print_error "Moteur logiciel inconnu : $engine"
            return 2
            ;;
    esac
}

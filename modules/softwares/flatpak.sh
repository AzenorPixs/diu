#!/usr/bin/env bash

software_flatpak_validate_application() {
    local software="${1:-}"

    [[ "$software" =~ ^[A-Za-z0-9]+(\.[A-Za-z0-9][A-Za-z0-9_-]*)+$ ]] || {
        print_error "Identifiant Flatpak invalide : $software"
        return 2
    }
}

software_flatpak_require_client() {
    command -v flatpak >/dev/null 2>&1 || {
        print_error "Flatpak est indisponible. Exécutez : diu system install flatpak"
        return 1
    }
}

software_flatpak_require_flathub() {
    flatpak remotes --system --columns=name | grep -Fxq flathub || {
        print_error "Le remote Flathub est absent. Exécutez : diu system install flatpak"
        return 1
    }
}

software_flatpak_is_installed() {
    flatpak info --system --app -- "$1" >/dev/null 2>&1
}

software_flatpak_install() {
    local software="$1"

    software_flatpak_require_client || return 1
    software_flatpak_require_flathub || return 1
    if software_flatpak_is_installed "$software"; then
        print_info "softwares/flatpak/$software : déjà installé."
        return 0
    fi
    flatpak install --system --noninteractive flathub -- "$software" || return 1
    print_success "softwares/flatpak/$software : installé."
}

software_flatpak_remove() {
    local software="$1"

    software_flatpak_require_client || return 1
    software_flatpak_require_flathub || return 1
    if ! software_flatpak_is_installed "$software"; then
        print_info "softwares/flatpak/$software : déjà absent."
        return 0
    fi
    flatpak uninstall --system --noninteractive -- "$software" || return 1
    print_success "softwares/flatpak/$software : désinstallé."
}

software_flatpak_action() {
    local action="${1:-}" software="${2:-}"

    [[ "$action" == install || "$action" == remove ]] || {
        print_error "Action Flatpak invalide : $action"
        return 2
    }
    software_flatpak_validate_application "$software" || return $?
    case "$action" in
        install) software_flatpak_install "$software" ;;
        remove) software_flatpak_remove "$software" ;;
    esac
}

software_flatpak_has_applications() {
    flatpak list --system --app --columns=application | grep -q '.'
}

software_flatpak_update_all() {
    software_flatpak_require_client || return 1
    software_flatpak_require_flathub || return 1
    if ! software_flatpak_has_applications; then
        print_info "softwares/flatpak : aucune application installée."
        return 0
    fi
    flatpak update --system --noninteractive || return 1
    print_success "softwares/flatpak : mise à jour terminée."
}

#!/usr/bin/env bash

software_apt_recipe() {
    case "${1,,}:${2,,}" in
        chatgpt:install) printf '%s' software_apt_chatgpt_install ;;
        chatgpt:remove) printf '%s' software_apt_chatgpt_remove ;;
        chatgpt:update) printf '%s' software_apt_chatgpt_update ;;
        *) return 1 ;;
    esac
}

software_apt_chatgpt_update_indexes() {
    apt -y update
}

software_apt_chatgpt_is_installed() {
    dpkg-query -W -f='${db:Status-Status}' chatgpt 2>/dev/null | grep -qx installed
}

software_apt_chatgpt_version() {
    dpkg-query -W -f='${Version}' chatgpt 2>/dev/null
}

software_apt_chatgpt_install() {
    local was_installed=0
    if [[ "${SYSTEM_APT_CGPT:-0}" != 1 ]]; then
        declare -F system_apt_install_repository >/dev/null 2>&1 || {
            print_error "Moteur de dépôts APT indisponible pour ChatGPT."
            return 1
        }
        system_apt_install_repository cgpt || return 1
        software_apt_chatgpt_update_indexes || return 1
    fi
    if software_apt_chatgpt_is_installed; then
        was_installed=1
        print_info "softwares/apt/chatgpt : déjà installé ($(software_apt_chatgpt_version))."
    else
        apt -y install chatgpt || return 1
    fi
    if [[ "$was_installed" == 0 ]]; then
        print_success "softwares/apt/chatgpt ($(software_apt_chatgpt_version)): installé."
    fi
}

software_apt_chatgpt_remove() {
    local installed_version
    if software_apt_chatgpt_is_installed; then
        installed_version="$(software_apt_chatgpt_version)"
        apt -y remove chatgpt || return 1
        print_success "softwares/apt/chatgpt (${installed_version:-inconnue}): désinstallé."
    else
        print_info "softwares/apt/chatgpt : déjà désinstallé."
    fi
    declare -F system_apt_remove_repository >/dev/null 2>&1 || {
        print_error "Moteur de dépôts APT indisponible pour ChatGPT."
        return 1
    }
    system_apt_remove_repository cgpt || return 1
    software_apt_chatgpt_update_indexes
}

software_apt_chatgpt_update() {
    software_apt_chatgpt_is_installed || {
        print_error "ChatGPT n'est pas installé."
        return 1
    }
    print_info "ChatGPT est déjà à jour ($(software_apt_chatgpt_version))."
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

software_apt_known_software() {
    printf '%s\n' chatgpt
}

software_apt_update_selective() {
    local software result=0
    while IFS= read -r software; do
        [[ -n "${software}" ]] || continue
        [[ "${SOFTWARES_APT_CHATGPT:-0}" == 1 && "$software" == chatgpt ]] || continue
        if ! software_apt_action update "$software"; then
            print_error "softwares/apt/$software : échec."
            result=1
        fi
    done < <(software_apt_known_software)
    return "$result"
}

software_apt_update_all() {
    local result=0
    if ! software_apt_update; then
        result=1
    fi
    if ! software_apt_update_selective; then
        result=1
    fi
    return "$result"
}

manage_softwares_action() {
    local action="${1:-}" engine="${2:-}" software="${3:-}"
    case "$action:$engine" in
        install:apt|remove:apt)
            [[ $# -eq 3 ]] || { print_error "Usage : rid softwares $action apt <SOFTWARE>"; return 2; }
            software_apt_action "$action" "$software"
            ;;
        apt:update)
            [[ $# -eq 2 ]] || { print_error "Usage : rid softwares apt update"; return 2; }
            software_apt_update
            ;;
        update:apt)
            if [[ $# -eq 3 ]]; then
                software_apt_action update "$software"
            elif [[ $# -eq 2 ]]; then
                software_apt_update_all
            else
                print_error "Usage : rid softwares update apt [SOFTWARE]"
                return 2
            fi
            ;;
        install:github|remove:github)
            [[ $# -eq 3 ]] || { print_error "Usage : rid softwares $action github <SOFTWARE>"; return 2; }
            software_github_action "$action" "$software"
            ;;
        update:github)
            if [[ $# -eq 3 ]]; then software_github_action update "$software"; elif [[ $# -eq 2 ]]; then software_github_update_all; else print_error "Usage : rid softwares update github [SOFTWARE]"; return 2; fi
            ;;
        update:)
            [[ $# -eq 1 ]] || { print_error "Usage : rid softwares update"; return 2; }
            local result=0
            software_apt_update_all || result=1
            software_github_update_all || result=1
            return "$result"
            ;;
        *)
            print_error "Commande softwares inconnue : $*"
            return 2
            ;;
    esac
}

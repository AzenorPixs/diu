#!/usr/bin/env bash

software_converge_all() {
    local config_file="${1:-}" result=0 engine state
    [[ -n "$config_file" ]] || return 2
    for engine in apt flatpak github; do
        case "$engine" in
            apt) state="${SYSTEM_APT_ENGINE:-1}" ;;
            flatpak) state="${SYSTEM_FLATPAK_ENGINE:-UNSET}" ;;
            github) state="${SYSTEM_GITHUB_ENGINE:-0}" ;;
        esac
        case "$state" in
            0) continue ;;
            UNSET) if [[ "$engine" == flatpak ]]; then continue; fi ;;
            1)
                "software_${engine}_manage_all" "$config_file" || result=1
                continue ;;
        esac
        printf 'État invalide du moteur logiciel %s : %s\n' "$engine" "$state" >&2
        result=1
    done
    return "$result"
}

software_dispatch() {
    local config_file="${1:-}" action="${2:-}" engine="${3:-}" software="${4:-}"
    local engine_state=''
    [[ -n "$config_file" ]] || return 2
    shift
    if [[ "$action:$engine" == flatpak:update && $# -eq 2 ]]; then
        set -- update flatpak
        action=update
        engine=flatpak
        software=''
    fi
    case "$action:$engine" in
        update:)
            [[ $# -eq 1 ]] || return 2
            software_converge_all "$config_file"
            return $?
            ;;
        install:apt|remove:apt|install:flatpak|remove:flatpak|install:github|remove:github)
            [[ $# -eq 3 && -n "$software" ]] || return 2 ;;
        update:apt|update:flatpak|update:github)
            [[ $# -eq 2 || ( $# -eq 3 && -n "$software" ) ]] || return 2 ;;
        *) printf '%s\n' 'Commande logiciels inconnue ou invalide.' >&2; return 2 ;;
    esac
    case "$engine" in
        apt) engine_state="${SYSTEM_APT_ENGINE:-1}" ;;
        flatpak) engine_state="${SYSTEM_FLATPAK_ENGINE:-UNSET}" ;;
        github) engine_state="${SYSTEM_GITHUB_ENGINE:-0}" ;;
    esac
    if [[ "$engine_state" != 1 ]]; then
        printf 'Moteur logiciel désactivé ou indisponible : %s\n' "$engine" >&2
        return 1
    fi
    case "$engine:$action" in
        apt:update) if [[ $# -eq 2 ]]; then software_apt_manage_all "$config_file"; else software_apt_manage_one "$config_file" update "$software"; fi ;;
        flatpak:update) if [[ $# -eq 2 ]]; then software_flatpak_manage_all "$config_file"; else software_flatpak_manage_one "$config_file" update "$software"; fi ;;
        github:update) if [[ $# -eq 2 ]]; then software_github_manage_all "$config_file"; else software_github_manage_one "$config_file" update "$software"; fi ;;
        apt:*) software_apt_manage_one "$config_file" "$action" "$software" ;;
        flatpak:*) software_flatpak_manage_one "$config_file" "$action" "$software" ;;
        github:*) software_github_manage_one "$config_file" "$action" "$software" ;;
    esac
}

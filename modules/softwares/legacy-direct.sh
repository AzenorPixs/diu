#!/usr/bin/env bash

# Les anciennes syntaxes agissent sur l'installation sans changer le désir.
software_legacy_direct() {
    local config_file="${1:-}" action="${2:-}" engine="${3:-}" software="${4:-}" desired
    # Les gardes de ressources partagées lisent ce contexte par portée dynamique.
    # shellcheck disable=SC2034
    local software_management_config="$config_file"
    # Les opérations historiques sont des demandes explicites.
    # shellcheck disable=SC2034
    local software_management_action=install
    [[ $# -eq 4 && -n "$config_file" ]] || return 2
    case "$action" in install) desired=1 ;; remove) desired=0 ;; *) return 2 ;; esac
    case "$engine:$software" in
        apt:chatgpt)
            [[ "${SYSTEM_APT_ENGINE:-1}" == 1 ]] || return 1
            software_apt_converge "$software" "$desired" || return $?
            if [[ "$action" == remove ]]; then software_apt_explicit_remove_cleanup "$software" || return $?; fi
            ;;
        github:codex-cli)
            [[ "${SYSTEM_GITHUB_ENGINE:-0}" == 1 ]] || return 1
            software_github_converge "$software" "$desired"
            ;;
        *) printf '%s\n' 'Ancienne syntaxe non prise en charge pour ce logiciel.' >&2; return 2 ;;
    esac
}

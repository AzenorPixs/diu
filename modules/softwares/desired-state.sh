#!/usr/bin/env bash

# N'écrit qu'un nom logiciel et une valeur littérale ; ne source pas la configuration.
software_write_desired_state() (
    local file="${1:-}" variable="${2:-}" desired="${3:-}" mode="${4:-set}"
    local snapshot='' temporary='' line prefix_re value_re seen=0 existing='' file_existed=0

    if [[ ! "$variable" =~ ^SOFTWARE_(APT|GITHUB|FLATPAK)_[A-Z0-9_]+$ || ( "$desired" != 0 && "$desired" != 1 ) || ( "$mode" != set && "$mode" != initialize && "$mode" != verify ) ]]; then
        printf '%s\n' 'État désiré logiciel invalide.' >&2
        return 2
    fi
    if [[ -L "$file" || ( -e "$file" && ( ! -f "$file" || ! -r "$file" ) ) ]]; then
        printf '%s\n' 'Configuration logicielle inaccessible ou non régulière.' >&2
        return 1
    fi
    [[ -e "$file" ]] && file_existed=1
    trap '[[ -z "$temporary" ]] || rm -f -- "$temporary"; [[ -z "$snapshot" ]] || rm -f -- "$snapshot"' EXIT
    snapshot="$(mktemp "${file}.snapshot.XXXXXXXX")" || return 1
    if [[ "$file_existed" == 1 ]] && ! cat -- "$file" > "$snapshot"; then
        printf '%s\n' 'Lecture de configuration impossible.' >&2
        return 1
    fi
    prefix_re="^[[:space:]]*(export[[:space:]]+)?${variable}([^a-zA-Z0-9_]|$)"
    value_re="^[[:space:]]*(export[[:space:]]+)?${variable}[[:space:]]*=[[:space:]]*([01])[[:space:]]*(#.*)?$"
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ "$line" =~ $prefix_re ]] || continue
        if [[ ! "$line" =~ $value_re ]]; then
            printf '%s\n' 'État désiré ambigu ; écriture interrompue.' >&2
            return 1
        fi
        (( seen += 1 ))
        existing="${BASH_REMATCH[2]}"
    done < "$snapshot"
    if (( seen > 1 )); then
        printf '%s\n' 'État désiré dupliqué ; écriture interrompue.' >&2
        return 1
    fi
    if [[ "$seen" == 1 && "$existing" == "$desired" ]]; then
        if [[ "$file_existed" == 1 ]] && cmp -s -- "$snapshot" "$file"; then
            return 0
        fi
        printf '%s\n' "Configuration modifiée pendant la lecture ; opération interrompue." >&2
        return 1
    fi
    if [[ "$mode" == initialize && "$seen" == 1 ]]; then
        printf '%s\n' 'Un état désiré existe déjà ; initialisation interrompue.' >&2
        return 1
    fi
    if [[ "$mode" == verify ]]; then
        printf '%s\n' 'État désiré différent de la configuration persistée.' >&2
        return 1
    fi
    temporary="$(mktemp "${file}.desired.XXXXXXXX")" || return 1
    if [[ "$file_existed" == 1 ]]; then
        chmod --reference="$file" "$temporary" || return 1
        if [[ "$(stat -c '%u:%g' -- "$file")" != "$(stat -c '%u:%g' -- "$temporary")" ]]; then
            printf '%s\n' 'Propriétaire de configuration incompatible.' >&2
            return 1
        fi
    fi
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ "$line" =~ $prefix_re ]] && continue
        printf '%s\n' "$line" >> "$temporary" || return 1
    done < "$snapshot"
    printf 'export %s=%s\n' "$variable" "$desired" >> "$temporary" || return 1
    if [[ "$file_existed" == 1 ]]; then
        if ! cmp -s -- "$snapshot" "$file"; then
            printf '%s\n' "Configuration modifiée pendant l'écriture ; opération interrompue." >&2
            return 1
        fi
        mv -f -- "$temporary" "$file" || return 1
        temporary=''
    else
        # La création exclusive échoue si un autre processus a créé le fichier.
        ln -- "$temporary" "$file" || return 1
    fi
)

# Les callbacks sont choisis par le catalogue du moteur, jamais par la CLI.
software_initialize_one() {
    local config_file="${1:-}" software="${2:-}" variable="${3:-}" detector="${4:-}" desired
    if [[ -z "$config_file" || -z "$software" || ! "$variable" =~ ^SOFTWARE_(APT|GITHUB|FLATPAK)_[A-Z0-9_]+$ ||
          ! "$detector" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] || ! declare -F "$detector" >/dev/null; then return 2; fi
    if [[ -v "$variable" ]]; then
        desired="${!variable}"
        [[ "$desired" == 0 || "$desired" == 1 ]] || return 1
        software_write_desired_state "$config_file" "$variable" "$desired" verify
        return $?
    fi
    if ! desired="$("$detector" "$software")" || [[ "$desired" != 0 && "$desired" != 1 ]]; then
        printf '%s\n' 'Initialisation impossible : état réel inconnu.' >&2
        return 1
    fi
    software_write_desired_state "$config_file" "$variable" "$desired" initialize || return $?
    printf -v "$variable" '%s' "$desired"
    export "${variable?}"
}

# Une détection impossible est différée pour ne pas bloquer les autres modules.
software_declare_one() {
    local config_file="${1:-}" software="${2:-}" variable="${3:-}" detector="${4:-}" desired
    if [[ -z "$config_file" || -z "$software" || ! "$variable" =~ ^SOFTWARE_(APT|GITHUB|FLATPAK)_[A-Z0-9_]+$ ||
          ! "$detector" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] || ! declare -F "$detector" >/dev/null; then return 2; fi
    if [[ -v "$variable" ]]; then
        desired="${!variable}"
        [[ "$desired" == 0 || "$desired" == 1 ]] || return 1
    elif ! desired="$("$detector" "$software")" || [[ "$desired" != 0 && "$desired" != 1 ]]; then
        printf 'Initialisation différée pour %s : état réel non vérifiable.\n' "$software" >&2
        return 0
    fi
    software_write_desired_state "$config_file" "$variable" "$desired" initialize || return $?
    printf -v "$variable" '%s' "$desired"
    export "${variable?}"
}

software_manage_one() {
    local config_file="${1:-}" action="${2:-}" software="${3:-}" variable="${4:-}"
    local detector="${5:-}" converge="${6:-}" desired callback
    # Les vérifications d'un moteur peuvent distinguer demande explicite et convergence.
    # shellcheck disable=SC2034
    local software_management_action="$action"
    if [[ -z "$config_file" || -z "$software" || ! "$variable" =~ ^SOFTWARE_(APT|GITHUB|FLATPAK)_[A-Z0-9_]+$ ]]; then
        printf '%s\n' 'Paramètres de gestion logicielle invalides.' >&2
        return 2
    fi
    for callback in "$detector" "$converge"; do
        if [[ ! "$callback" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] || ! declare -F "$callback" >/dev/null; then
            printf '%s\n' 'Opération logicielle indisponible.' >&2
            return 1
        fi
    done
    case "$action" in
        install) desired=1 ;;
        remove) desired=0 ;;
        update)
            software_initialize_one "$config_file" "$software" "$variable" "$detector" || return $?
            desired="${!variable}"
            "$converge" "$software" "$desired"
            return $?
            ;;
        *) printf '%s\n' 'Action logicielle invalide.' >&2; return 2 ;;
    esac
    software_write_desired_state "$config_file" "$variable" "$desired" || return $?
    printf -v "$variable" '%s' "$desired"
    export "${variable?}"
    "$converge" "$software" "$desired"
}

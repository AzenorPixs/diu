#!/usr/bin/env bash

# Les callbacks proviennent du catalogue interne, jamais directement de la CLI.
software_converge() {
    local software="${1:-}" desired="${2:-}" detect="${3:-}"
    local install="${4:-}" remove="${5:-}" conform="${6:-}"
    local configure="${7:-}" cleanup="${8:-}"
    local actual final operation status discrepancy=0 software_convergence_actual
    local software_configuration_done=0

    if [[ -z "$software" || ( "$desired" != 0 && "$desired" != 1 ) ]]; then
        printf '❌ État désiré invalide pour %s.\n' "$software" >&2
        return 2
    fi
    for operation in "$detect" "$install" "$remove"; do
        if [[ ! "$operation" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] || ! declare -F "$operation" >/dev/null; then
            printf '❌ Opération indisponible pour %s.\n' "$software" >&2
            return 1
        fi
    done
    if [[ -n "$conform" ]] && { [[ ! "$conform" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] || ! declare -F "$conform" >/dev/null; }; then
        printf '❌ Vérification indisponible pour %s.\n' "$software" >&2
        return 1
    fi
    for operation in "$configure" "$cleanup"; do
        [[ -n "$operation" ]] || continue
        if [[ ! "$operation" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] || ! declare -F "$operation" >/dev/null; then
            printf '❌ Opération de cycle de vie indisponible pour %s.\n' "$software" >&2
            return 1
        fi
    done
    if ! actual="$("$detect" "$software")"; then
        printf '❌ %s : état réel indéterminé.\n' "$software" >&2
        return 1
    fi
    if [[ "$actual" != 0 && "$actual" != 1 ]]; then
        printf '❌ %s : état réel invalide.\n' "$software" >&2
        return 1
    fi
    if [[ "$actual" == 0 && "$desired" == 0 ]]; then
        return 0
    fi
    if [[ "$actual" == "$desired" && -n "$conform" ]]; then
        if "$conform" "$software" "$desired" "$actual"; then
            :
        else
            status=$?
            if [[ "$status" != 1 ]]; then
                printf '❌ %s : conformité indéterminée.\n' "$software" >&2
                return 1
            fi
            discrepancy=1
        fi
    fi
    if [[ "$actual" == "$desired" && "$discrepancy" == 0 ]]; then
        if [[ "$desired" == 1 && -n "$configure" ]] && ! "$configure" "$software"; then
            printf '❌ %s : configuration échouée.\n' "$software" >&2
            return 1
        fi
        printf '\033[32m✓\033[0m %s : état réel %s, conforme.\n' "$software" "$actual"
        return 0
    fi
    if [[ "$actual" == "$desired" ]]; then
        printf '\033[31m✗\033[0m %s : état réel %s, configuration non conforme ; convergence.\n' "$software" "$actual"
    else
        printf '\033[31m✗\033[0m %s : état réel %s, attendu %s ; convergence.\n' "$software" "$actual" "$desired"
    fi
    operation="$remove"
    [[ "$desired" == 1 ]] && operation="$install"
    # Le callback APT lit cette variable locale par portée dynamique Bash.
    # shellcheck disable=SC2034
    software_convergence_actual="$actual"
    if ! "$operation" "$software"; then
        printf '❌ %s : échec de la convergence.\n' "$software" >&2
        return 1
    fi
    if ! final="$("$detect" "$software")" || [[ "$final" != "$desired" ]]; then
        printf '❌ %s : état réel non confirmé après convergence.\n' "$software" >&2
        return 1
    fi
    if [[ "$actual" != "$desired" && "$desired" == 0 && -n "$cleanup" ]] && ! "$cleanup" "$software"; then
        printf '❌ %s : nettoyage échoué.\n' "$software" >&2
        return 1
    fi
    if [[ "$desired" == 1 && -n "$configure" && "$software_configuration_done" == 0 ]] && ! "$configure" "$software"; then
        printf '❌ %s : configuration échouée.\n' "$software" >&2
        return 1
    fi
    if [[ -n "$conform" ]] && ! "$conform" "$software" "$desired" "$final"; then
        printf '❌ %s : configuration non confirmée après convergence.\n' "$software" >&2
        return 1
    fi
    printf '\033[32m✓\033[0m %s : état réel %s, conforme.\n' "$software" "$final"
}

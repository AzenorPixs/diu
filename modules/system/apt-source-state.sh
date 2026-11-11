#!/usr/bin/env bash

system_apt_source_state() {
    local helper
    local -a options=()
    [[ "${2:-}" != binary ]] || options+=(--binary)
    helper="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/apt_sources.py" || return 1
    python3 "$helper" "${1:-}" --root "${SYSTEM_APT_SOURCE_ROOT:-/etc/apt}" "${options[@]}"
}

system_apt_repository_value_valid() {
    case "${1:-}" in
        SYSTEM_APT_MONGODB) [[ "${2:-}" =~ ^(0|4|5|6|7|8)$ ]] ;;
        SYSTEM_APT_WAZUH) [[ "${2:-}" =~ ^(0|1|4)$ ]] ;;
        SYSTEM_APT_*|DIU_APT_REPOSITORY_FD|SOFTWARE_APT_CROWDSEC) [[ "${2:-}" == 0 || "${2:-}" == 1 ]] ;;
        *) return 1 ;;
    esac
}

system_apt_repository_declare() {
    local file="${1:-}" variable="${2:-}" value
    [[ "$variable" =~ ^(SYSTEM_APT_[A-Z0-9_]+|DIU_APT_REPOSITORY_FD|SOFTWARE_APT_CROWDSEC)$ && -n "$file" ]] || return 2
    if [[ -v "$variable" ]]; then
        system_apt_repository_value_valid "$variable" "${!variable}" || {
            printf 'Variable de dépôt invalide : %s.\n' "$variable" >&2; return 1;
        }
        export "${variable?}"
        return 0
    fi
    value="$(system_apt_source_state "$variable")" || return 1
    system_apt_repository_value_valid "$variable" "$value" || return 1
    system_apt_repository_initialize "$file" "$variable" "$value" || return 1
    printf -v "$variable" '%s' "$value"
    export "${variable?}"
}

# L'initialisation n'écrase jamais une déclaration déjà persistée ou ambiguë.
system_apt_repository_initialize() (
    local file="$1" variable="$2" value="$3" snapshot='' temporary='' line pattern existing=0
    local existed=0
    [[ ! -L "$file" && ( ! -e "$file" || ( -f "$file" && -r "$file" ) ) ]] || return 1
    if [[ ! -d "$(dirname -- "$file")" ]]; then
        install -d -m 0755 -- "$(dirname -- "$file")" || return 1
    fi
    [[ ! -e "$file" ]] || existed=1
    snapshot="$(mktemp "${file}.snapshot.XXXXXXXX")" || return 1
    trap '[[ -z "$snapshot" ]] || rm -f -- "$snapshot"; [[ -z "$temporary" ]] || rm -f -- "$temporary"' EXIT
    if [[ "$existed" == 1 ]]; then cat -- "$file" > "$snapshot" || return 1; fi
    pattern="^[[:space:]]*(export[[:space:]]+)?${variable}([^A-Za-z0-9_]|$)"
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ ! "$line" =~ $pattern ]] || existing=1
    done < "$snapshot"
    if [[ "$existing" == 1 ]]; then
        printf 'Déclaration de dépôt déjà persistée : %s ; recharge requise.\n' "$variable" >&2
        return 1
    fi
    temporary="$(mktemp "${file}.initial.XXXXXXXX")" || return 1
    if [[ "$existed" == 1 ]]; then
        chmod --reference="$file" "$temporary" || return 1
        [[ "$(stat -c '%u:%g' -- "$file")" == "$(stat -c '%u:%g' -- "$temporary")" ]] || return 1
    fi
    cat -- "$snapshot" > "$temporary" || return 1
    if [[ -s "$snapshot" && -n "$(tail -c 1 -- "$snapshot")" ]]; then
        printf '\n' >> "$temporary" || return 1
    fi
    printf 'export %s=%s\n' "$variable" "$value" >> "$temporary" || return 1
    if [[ "$existed" == 1 ]]; then
        cmp -s -- "$file" "$snapshot" || { printf '%s\n' 'Configuration APT modifiée simultanément.' >&2; return 1; }
        mv -f -- "$temporary" "$file" || return 1
        temporary=''
    else
        ln -- "$temporary" "$file" || return 1
    fi
)

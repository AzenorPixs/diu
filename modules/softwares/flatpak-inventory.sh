#!/usr/bin/env bash

software_flatpak_inventory_marker_state() {
    local file="${1:-}" line count=0
    [[ -n "$file" ]] || return 2
    if [[ -L "$file" || ( -e "$file" && ( ! -f "$file" || ! -r "$file" ) ) ]]; then
        printf '%s\n' 'Configuration Flatpak inaccessible ou non régulière.' >&2
        return 1
    fi
    if [[ ! -e "$file" ]]; then printf '0\n'; return 0; fi
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ "$line" == '# DIU_FLATPAK_INVENTORY_INITIALIZED='* ]] || continue
        if [[ "$line" != '# DIU_FLATPAK_INVENTORY_INITIALIZED=1' ]]; then
            printf '%s\n' 'Marqueur Flatpak invalide.' >&2
            return 1
        fi
        (( count += 1 ))
    done < "$file"
    if (( count > 1 )); then
        printf '%s\n' 'Marqueur Flatpak dupliqué.' >&2
        return 1
    fi
    printf '%s\n' "$count"
}

software_flatpak_inventory_mark() (
    local file="${1:-}" snapshot='' temporary='' existed=0 marker
    [[ -n "$file" ]] || return 2
    if [[ -L "$file" || ( -e "$file" && ( ! -f "$file" || ! -r "$file" ) ) ]]; then
        printf '%s\n' 'Configuration Flatpak inaccessible ou non régulière.' >&2
        return 1
    fi
    [[ -e "$file" ]] && existed=1
    trap '[[ -z "$temporary" ]] || rm -f -- "$temporary"; [[ -z "$snapshot" ]] || rm -f -- "$snapshot"' EXIT
    snapshot="$(mktemp "${file}.snapshot.XXXXXXXX")" || return 1
    if [[ "$existed" == 1 ]] && ! cat -- "$file" > "$snapshot"; then return 1; fi
    marker="$(software_flatpak_inventory_marker_state "$snapshot")" || return 1
    [[ "$marker" == 1 ]] && return 0
    temporary="$(mktemp "${file}.flatpak.XXXXXXXX")" || return 1
    if [[ "$existed" == 1 ]]; then
        chmod --reference="$file" "$temporary" || return 1
        if [[ "$(stat -c '%u:%g' -- "$file")" != "$(stat -c '%u:%g' -- "$temporary")" ]]; then
            printf '%s\n' 'Propriétaire de configuration incompatible.' >&2
            return 1
        fi
    fi
    cat -- "$snapshot" > "$temporary" || return 1
    printf '\n%s\n' '# DIU_FLATPAK_INVENTORY_INITIALIZED=1' >> "$temporary" || return 1
    if [[ "$existed" == 1 ]]; then
        if ! cmp -s -- "$snapshot" "$file"; then
            printf '%s\n' 'Configuration modifiée pendant la préparation Flatpak.' >&2
            return 1
        fi
        mv -f -- "$temporary" "$file" || return 1
        temporary=''
    else
        ln -- "$temporary" "$file" || return 1
    fi
)

software_flatpak_inventory_initialize() {
    local file="${1:-}" marker applications software variable desired detector
    [[ -n "$file" ]] || return 2
    marker="$(software_flatpak_inventory_marker_state "$file")" || return 1
    [[ "$marker" == 1 ]] && return 0
    software_flatpak_require_client || return 1
    if ! applications="$(flatpak list --system --app --columns=application)"; then
        printf '%s\n' 'Inventaire initial Flatpak indisponible.' >&2
        return 1
    fi
    while IFS= read -r software; do
        [[ -n "$software" ]] || continue
        software_flatpak_validate_application "$software" || return $?
    done <<< "$applications"
    while IFS= read -r software; do
        [[ -n "$software" ]] || continue
        variable="$(software_flatpak_variable_name "$software")" || return $?
        if [[ -v "$variable" ]]; then
            desired="${!variable}"
            [[ "$desired" == 0 || "$desired" == 1 ]] || return 1
            software_write_desired_state "$file" "$variable" "$desired" verify || return $?
            continue
        fi
        software_flatpak_register_detector "$software" || return $?
        detector="$(software_flatpak_detector_name "$software")" || return $?
        if ! desired="$("$detector")" || [[ "$desired" != 0 && "$desired" != 1 ]]; then
            printf '%s\n' 'État réel Flatpak initial inconnu.' >&2
            return 1
        fi
        software_write_desired_state "$file" "$variable" "$desired" initialize || return $?
        printf -v "$variable" '%s' "$desired"
        export "${variable?}"
    done <<< "$applications"
    software_flatpak_inventory_mark "$file"
}

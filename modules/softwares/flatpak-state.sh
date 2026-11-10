#!/usr/bin/env bash

# Une erreur du client ne doit jamais être interprétée comme une application absente.
software_flatpak_application_state() {
    local software="${1:-}" applications application
    software_flatpak_validate_application "$software" || return $?
    software_flatpak_require_client || return 1
    if ! applications="$(flatpak list --system --app --columns=application)"; then
        printf '%s\n' 'État des applications Flatpak indisponible.' >&2
        return 1
    fi
    while IFS= read -r application; do
        if [[ "$application" == "$software" ]]; then
            printf '1\n'
            return 0
        fi
    done <<< "$applications"
    printf '0\n'
}

software_flatpak_identifier_token() {
    local software="${1:-}" token='X' character code index
    local LC_ALL=C
    software_flatpak_validate_application "$software" || return $?
    for ((index = 0; index < ${#software}; index++)); do
        character="${software:index:1}"
        printf -v code '%02X' "'$character"
        token+="$code"
    done
    printf '%s\n' "$token"
}

software_flatpak_variable_name() {
    local token
    token="$(software_flatpak_identifier_token "${1:-}")" || return $?
    printf 'SOFTWARE_FLATPAK_%s\n' "$token"
}

software_flatpak_identifier_from_variable() {
    local variable="${1:-}" token byte character software='' index value
    local LC_ALL=C
    [[ "$variable" == SOFTWARE_FLATPAK_X* ]] || return 2
    token="${variable#SOFTWARE_FLATPAK_X}"
    [[ "$token" =~ ^([0-9A-F][0-9A-F])+$ ]] || return 2
    for ((index = 0; index < ${#token}; index += 2)); do
        byte="${token:index:2}"
        value=$((16#$byte))
        (( value >= 32 && value <= 126 )) || return 2
        printf -v character '%b' "\\x$byte"
        software+="$character"
    done
    software_flatpak_validate_application "$software" || return $?
    [[ "$(software_flatpak_variable_name "$software")" == "$variable" ]] || return 2
    printf '%s\n' "$software"
}

software_flatpak_detector_name() {
    local token
    token="$(software_flatpak_identifier_token "${1:-}")" || return $?
    printf 'software_flatpak_detect_%s\n' "$token"
}

software_flatpak_register_detector() {
    local software="${1:-}" detector
    detector="$(software_flatpak_detector_name "$software")" || return $?
    # Le nom est hexadécimal et l'identifiant a été limité à ASCII, points,
    # chiffres, traits et soulignements par le validateur avant cette définition.
    eval "$detector() { software_flatpak_application_state '$software'; }"
}

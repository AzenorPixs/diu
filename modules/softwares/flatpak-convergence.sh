#!/usr/bin/env bash

software_flatpak_converge() {
    local software="${1:-}" desired="${2:-}" detector
    software_flatpak_register_detector "$software" || return $?
    detector="$(software_flatpak_detector_name "$software")" || return $?
    software_converge "$software" "$desired" "$detector" software_flatpak_install software_flatpak_remove '' software_flatpak_configure software_flatpak_cleanup
}

software_flatpak_lifecycle_hook() {
    local software="${1:-}" phase="${2:-}" token hook
    token="$(software_flatpak_identifier_token "$software")" || return 1
    [[ "$phase" == configure || "$phase" == cleanup ]] || return 2
    hook="software_flatpak_${phase}_${token}"
    # Le jeton est exclusivement hexadécimal après validation de l'identifiant.
    if ! declare -F "$hook" >/dev/null; then eval "$hook() { return 0; }"; fi
    "$hook"
}
software_flatpak_configure() { software_flatpak_lifecycle_hook "${1:-}" configure; }
software_flatpak_cleanup() { software_flatpak_lifecycle_hook "${1:-}" cleanup; }

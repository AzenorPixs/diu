#!/usr/bin/env bash

software_flatpak_converge() {
    local software="${1:-}" desired="${2:-}" detector
    software_flatpak_register_detector "$software" || return $?
    detector="$(software_flatpak_detector_name "$software")" || return $?
    software_converge "$software" "$desired" "$detector" software_flatpak_install software_flatpak_remove
}

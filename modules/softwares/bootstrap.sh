#!/usr/bin/env bash

# Charge les moteurs avant la génération des variables et le routage des commandes.
software_load_convergence_modules() {
    local root="${1:-}" module
    [[ -n "$root" ]] || return 2
    for module in convergence desired-state migration global-declarations \
        shared-resource apt-state crowdsec-state syslog-state apt-configuration \
        crowdsec-hooks syslog-hooks apt-convergence apt-management \
        flatpak-state flatpak-convergence flatpak-inventory flatpak-management \
        github-state github-convergence github-management github-version \
        dispatch; do
        # shellcheck disable=SC1090
        source "$root/modules/softwares/$module.sh" || return 1
    done
    # shellcheck disable=SC1090,SC1091
    source "$root/modules/system/software-versions.sh" || return 1
}

#!/usr/bin/env bash

# Crée un lien sans remplacer une entrée existante, même pendante.
diu_create_link() {
    local target="$1" link="$2"
    if [[ -e "$link" || -L "$link" ]]; then
        return 0
    fi
    if ! ln -sT -- "$target" "$link"; then
        printf 'Impossible de créer le lien %s.\n' "$link" >&2
        return 1
    fi
}

diu_create_development_link() {
    local projects_root="$1" link="$2"
    local target="${projects_root}/diu/root-install-debian.sh"
    if [[ -n "$projects_root" && -f "$target" ]]; then
        diu_create_link "$target" "$link"
    fi
}

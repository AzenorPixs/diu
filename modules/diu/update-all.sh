#!/usr/bin/env bash

update_all() {
    diu_update_playlist
}

manage_update_action() {
    if [[ $# -eq 0 ]]; then
        update_all
    elif [[ "$1" == diu && $# -eq 1 ]]; then
        diu_update
    else
        printf '%s\n' 'Commande de mise à jour inconnue.' >&2
        return 2
    fi
}

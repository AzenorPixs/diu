#!/usr/bin/env bash
# Fonctions génériques Git

git_get_latest_release() {

    # ===========================================================
    # Récupération du dernier tag d'un dépôt Git public
    #
    # Compatible :
    #   - GitHub
    #   - GitLab
    #   - Forgejo
    #
    # Arguments :
    #   $1 = URL de l'instance
    #   $2 = compte / owner
    #   $3 = dépôt
    #
    # Exemple :
    #   git_get_latest_release \
    #       "https://forgejo.pixs.fr" \
    #       "rootforgejo" \
    #       "diu"
    #
    # Retour :
    #   dernier tag distant sur stdout
    #
    # IMPORTANT :
    #   Le dépôt doit être public.
    #   Aucun credential n'est utilisé.
    # ===========================================================

    local remote_url="${1:-}"
    local owner="${2:-}"
    local repository="${3:-}"

    local remote=""
    local latest_tag=""

    # ----------------------------------------------------------
    # Validation
    # ----------------------------------------------------------

    if [[ -z "${remote_url}" || -z "${owner}" || -z "${repository}" ]]; then
        print_error \
            "Usage : git_get_latest_release <url dépôt> <compte> <dépôt>"
        return 1
    fi

    if ! command -v git >/dev/null 2>&1; then
        print_error "La commande git est indisponible."
        return 1
    fi

    # ----------------------------------------------------------
    # Construction du dépôt
    # ----------------------------------------------------------

    remote="${remote_url%/}/${owner}/${repository}.git"

    # ----------------------------------------------------------
    # Récupération des tags
    #
    # GIT_TERMINAL_PROMPT=0
    #
    # Empêche Git de demander :
    #
    # Username for ...
    #
    # pour un dépôt public.
    #
    # credential.helper=
    #
    # Empêche l'utilisation d'un credential helper configuré
    # localement.
    # ----------------------------------------------------------

    latest_tag="$(
        GIT_TERMINAL_PROMPT=0 \
        git \
            -c credential.helper= \
            ls-remote \
            --tags \
            --sort='-v:refname' \
            "${remote}" 2>/dev/null |
        awk '
            $2 !~ /\^\{\}$/ {
                sub("^refs/tags/", "", $2)
                print $2
                exit
            }
        '
    )"

    if [[ -z "${latest_tag}" ]]; then
        print_error \
            "Impossible de récupérer le dernier tag de ${remote}"
        return 1
    fi

    # ----------------------------------------------------------
    # Résultat
    # ----------------------------------------------------------

    printf '%s\n' "${latest_tag}"

    return 0
}

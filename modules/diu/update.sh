#!/usr/bin/env bash

# Mise à jour du DIU

update_diu() {
    local forgejo_url="https://forgejo.pixs.fr"
    local forgejo_owner="rootforgejo"
    local forgejo_repository="diu"

    local latest_release=""
    local latest_version=""
    local installed_version=""

    local deb_filename=""
    local deb_file=""
    local download_url=""

    local downloaded_package=""
    local downloaded_version=""

    # ----------------------------------------------------------
    # Cette fonction travaille exclusivement sur le dépôt public
    # du DIU.
    #
    # AUCUNE authentification Forgejo/Git ne doit être utilisée.
    #
    # git_get_latest_release doit donc interroger l'API publique
    # du forge distant.
    # ----------------------------------------------------------

    # ----------------------------------------------------------
    # Vérification des prérequis
    # ----------------------------------------------------------

    if ! command -v dpkg >/dev/null 2>&1; then
        print_error "La commande dpkg est indisponible."
        return 1
    fi

    if ! command -v dpkg-query >/dev/null 2>&1; then
        print_error "La commande dpkg-query est indisponible."
        return 1
    fi

    if ! command -v dpkg-deb >/dev/null 2>&1; then
        print_error "La commande dpkg-deb est indisponible."
        return 1
    fi

    if ! command -v curl >/dev/null 2>&1; then
        print_error "La commande curl est indisponible."
        return 1
    fi

    # ----------------------------------------------------------
    # Récupération de la dernière release
    # ----------------------------------------------------------

    print_title "Recherche de la dernière release DIU"

    print_info "Dépôt public : ${forgejo_url}/${forgejo_owner}/${forgejo_repository}"

    if ! latest_release="$(
        git_get_latest_release \
            "${forgejo_url}" \
            "${forgejo_owner}" \
            "${forgejo_repository}"
    )"; then

        print_error "Impossible de récupérer la dernière release du DIU."
        return 1
    fi

    if [[ -z "${latest_release}" ]]; then
        print_error "La dernière release DIU est vide."
        return 1
    fi

    print_success "Dernière release : ${latest_release}"

    # ----------------------------------------------------------
    # Conversion du tag en version Debian
    #
    # v2026.08.17.14.58
    #       ↓
    # 2026.08.17.14.58
    # ----------------------------------------------------------

    latest_version="${latest_release#v}"

    if [[ -z "${latest_version}" ]]; then
        print_error "Impossible d'extraire la version depuis ${latest_release}."
        return 1
    fi

    # ----------------------------------------------------------
    # Validation de la version Debian
    # ----------------------------------------------------------

    if ! dpkg --compare-versions \
        "${latest_version}" eq "${latest_version}" 2>/dev/null; then

        print_error "La version distante n'est pas une version Debian valide : ${latest_version}"
        return 1
    fi

    # ----------------------------------------------------------
    # Récupération de la version installée
    # ----------------------------------------------------------

    if ! installed_version="$(
        dpkg-query \
            -W \
            -f='${Version}' \
            diu 2>/dev/null
    )"; then
        print_error "Impossible de lire la version installée du DIU."
        return 1
    fi

    if [[ -z "${installed_version}" ]]; then
        print_error "Le paquet DIU n'est pas installé sur ce système."
        return 1
    fi

    print_info "Version installée : ${installed_version}"
    print_info "Dernière version  : ${latest_version}"

    # ----------------------------------------------------------
    # Comparaison des versions Debian
    # ----------------------------------------------------------

    if dpkg --compare-versions \
        "${latest_version}" le "${installed_version}"; then

        if [[ "${latest_version}" == "${installed_version}" ]]; then
            print_success "Le DIU est déjà à jour (${installed_version})."
        else
            print_info \
                "La version installée (${installed_version}) est plus récente que la release distante (${latest_version})."
            print_info "Aucune mise à jour ne sera effectuée."
        fi

        return 0
    fi

    print_success \
        "Nouvelle version disponible : ${installed_version} → ${latest_version}"

    # ----------------------------------------------------------
    # Préparation du fichier Debian
    # ----------------------------------------------------------

    deb_filename="diu_${latest_version}_all.deb"
    deb_file="/tmp/${deb_filename}"

    # ----------------------------------------------------------
    # URL publique de téléchargement Forgejo
    # ----------------------------------------------------------

    download_url="${forgejo_url}/${forgejo_owner}/${forgejo_repository}/releases/download/${latest_release}/${deb_filename}"

    print_info "Téléchargement : ${download_url}"
    print_info "Destination    : ${deb_file}"
    print_info "Authentification HTTP : aucune"

    # ----------------------------------------------------------
    # Nettoyage d'un éventuel ancien paquet
    # ----------------------------------------------------------

    rm -f "${deb_file}"

    # ----------------------------------------------------------
    # Téléchargement public
    #
    # IMPORTANT :
    #
    # Aucun --user
    # Aucun Authorization:
    # Aucun token Forgejo
    # Aucun credential Git
    # ----------------------------------------------------------

	if ! curl \
		--fail \
		--silent \
		--show-error \
		--location \
		--compressed \
		--output "${deb_file}" \
		"${download_url}"; then

        print_error "Échec du téléchargement du paquet DIU."
        rm -f "${deb_file}"
        return 1
    fi

    # ----------------------------------------------------------
    # Vérification du paquet téléchargé
    # ----------------------------------------------------------

    if [[ ! -s "${deb_file}" ]]; then
        print_error "Le paquet téléchargé est vide."
        rm -f "${deb_file}"
        return 1
    fi

    # Format dpkg-deb : conserver les expressions littérales.
    # shellcheck disable=SC2016
    if ! downloaded_package="$(
        dpkg-deb \
            --show \
            --showformat='${Package}' \
            "${deb_file}" \
            2>/dev/null
    )"; then
        print_error "Impossible de lire le nom du paquet téléchargé."
        return 1
    fi

    # shellcheck disable=SC2016
    if ! downloaded_version="$(
        dpkg-deb \
            --show \
            --showformat='${Version}' \
            "${deb_file}" \
            2>/dev/null
    )"; then
        print_error "Impossible de lire la version du paquet téléchargé."
        return 1
    fi

    if [[ "${downloaded_package}" != "diu" ]]; then
        print_error "Le paquet téléchargé n'est pas un paquet DIU."
        print_error "Package détecté : ${downloaded_package}"
        rm -f "${deb_file}"
        return 1
    fi

    if [[ "${downloaded_version}" != "${latest_version}" ]]; then
        print_error "Version du paquet téléchargé incohérente."
        print_error "Attendue : ${latest_version}"
        print_error "Trouvée   : ${downloaded_version}"
        rm -f "${deb_file}"
        return 1
    fi

    print_success "Paquet DIU téléchargé et vérifié."

    # ----------------------------------------------------------
    # Installation
    #
    # IMPORTANT :
    #
    # exec remplace le processus DIU courant par dpkg.
    #
    # Le shell DIU ne poursuit donc aucune exécution après le
    # lancement de l'installation Debian.
    # ----------------------------------------------------------

    print_title "Installation du DIU ${latest_version}"

    print_info "Le processus DIU va maintenant être remplacé par dpkg."
    print_info "Installation : ${deb_file}"

    exec dpkg --install "${deb_file}"
}

diu_update() {
    (update_diu)
}

# Affiche la version du DIU

diu_version() {
    local version=""

    if ! command -v dpkg-query >/dev/null 2>&1; then
        print_error "La commande dpkg-query est indisponible."
        return 1
    fi

    version="$(
        dpkg-query \
            -W \
            -f='${Version}' \
            diu 2>/dev/null
    )"

    if [[ -z "${version}" ]]; then
        print_error "Le paquet DIU n'est pas installé sur ce système."
        return 1
    fi

    printf '%s\n' "${version}"
}

#!/usr/bin/env bash

# Chaque opération utilise des index distincts, signés par les clés Debian.
# Les fichiers de configuration APT de la machine ne sont pas modifiés.
software_deb() (
    local action="$1" software="${2:-}" temporary="" indexes="" codename=""
    local origin suite uri component identifier package package_version status policy candidate
    local installed="" simulation="" result=0 command_name rest operation installed_version
    local -a options=() packages=() apt_command=()
    for command_name in apt-get apt-cache dpkg-query dpkg awk sort mktemp; do
        if ! command -v "$command_name" >/dev/null 2>&1; then
            print_error "Commande requise indisponible : $command_name"
            return 1
        fi
    done
    if [[ ! -r /usr/share/keyrings/debian-archive-keyring.gpg ]]; then
        print_error "Le trousseau officiel Debian est indisponible."
        return 1
    fi
    # shellcheck source=/dev/null
    codename="$(. /etc/os-release && printf '%s' "${VERSION_CODENAME:-}")" || return 1
    if [[ ! "$codename" =~ ^[a-z][a-z0-9]+$ ]]; then
        print_error "Impossible de déterminer la version Debian installée."
        return 1
    fi
    temporary="$(mktemp -d)" || return 1
    trap 'rm -rf -- "$temporary"' EXIT
    mkdir -p "$temporary/lists/partial" || return 1
    chmod 755 "$temporary" "$temporary/lists" || return 1
    : > "$temporary/sources.list" || return 1
    # Les expressions $(...) sont interprétées par APT, pas par Bash.
    # shellcheck disable=SC2016
    indexes="$(LC_ALL=C apt-get indextargets --format '$(ORIGIN)|$(CODENAME)|$(REPO_URI)|$(COMPONENT)|$(IDENTIFIER)')" || {
        print_error "Impossible de lire les métadonnées des dépôts APT."
        return 1
    }
    while IFS='|' read -r origin suite uri component identifier; do
        [[ "$identifier" == Packages && "$origin" == Debian ]] || continue
        case "$suite" in
            "$codename"|"$codename-updates"|"$codename-security") ;;
            *) continue ;;
        esac
        [[ "$uri" =~ ^https?://[^[:space:]]+$ && "$uri" != *"["* && "$uri" != *"]"* && "$component" =~ ^[a-z0-9-]+$ ]] || continue
        printf 'deb [signed-by=/usr/share/keyrings/debian-archive-keyring.gpg] %s %s %s\n' \
            "$uri" "$suite" "$component" >> "$temporary/sources.list" || return 1
    done <<< "$indexes"
    if [[ ! -s "$temporary/sources.list" ]]; then
        print_error "Aucun index Debian officiel pour $codename. Actualisez les index APT avant de réessayer."
        return 1
    fi
    sort -u -o "$temporary/sources.list" "$temporary/sources.list" || return 1
    options=(-o "Dir::Etc::sourcelist=$temporary/sources.list"
             -o 'Dir::Etc::sourceparts=-'
             -o "Dir::State::lists=$temporary/lists"
             -o "Dir::Cache::pkgcache=$temporary/pkgcache.bin"
             -o "Dir::Cache::srcpkgcache=$temporary/srcpkgcache.bin"
             -o 'APT::Get::AllowUnauthenticated=false'
             -o 'Acquire::AllowInsecureRepositories=false')
    if ! LC_ALL=C apt-get "${options[@]}" -o APT::Update::Error-Mode=any update; then
        print_error "Échec de l'actualisation des index Debian officiels."
        return 1
    fi
    # L'ancien cache permet de reconnaître une version installée devenue obsolète
    # après l'actualisation des index isolés ; les versions inconnues sont refusées.
    if [[ -n "$software" ]]; then
        packages=("$software")
    else
        installed="$(dpkg-query -W -f='${binary:Package}\t${Version}\t${db:Status-Status}\n')" || return 1
        while IFS=$'\t' read -r package package_version status; do
            [[ "$status" == installed ]] || continue
            policy="$(LC_ALL=C apt-cache "${options[@]}" policy "$package")" || return 1
            candidate="$(software_deb_candidate "$policy")"
            if [[ -z "$candidate" || "$candidate" == '(none)' ]] ||
               ! software_deb_version_available "$policy" "$candidate"; then
                continue
            fi
            if ! software_deb_installed_official "$package" "$package_version" "$policy" "$indexes"; then
                print_error "deb/$package : origine de la version installée non vérifiable ; mise à jour bloquée."
                result=1
                continue
            fi
            packages+=("$package")
        done <<< "$installed"
    fi
    if [[ ${#packages[@]} -eq 0 ]]; then
        print_info "deb : aucun paquet applicable."
        return "$result"
    fi
    local -a targets=()
    for package in "${packages[@]}"; do
        policy="$(LC_ALL=C apt-cache "${options[@]}" policy "$package")" || return 1
        candidate="$(software_deb_candidate "$policy")"
        package_version="$(awk '$1 == "Installed:" { print $2; exit }' <<< "$policy")"
        if [[ -z "$candidate" || "$candidate" == '(none)' ]] ||
           ! software_deb_version_available "$policy" "$candidate"; then
            print_error "Paquet officiel introuvable : $package"
            return 1
        fi
        if [[ -n "$package_version" && "$package_version" != '(none)' ]] &&
           ! software_deb_installed_official "$package" "$package_version" "$policy" "$indexes"; then
            print_error "Origine installée non vérifiable pour $package ; opération refusée."
            return 1
        fi
        case "$action" in
            remove)
                if [[ -z "$package_version" || "$package_version" == '(none)' ]]; then
                    print_info "$package : déjà absent."
                    continue
                fi
                targets+=("$package")
                ;;
            update)
                if [[ -z "$package_version" || "$package_version" == '(none)' ]]; then
                    print_error "$package : non installé."
                    return 1
                fi
                if dpkg --compare-versions "$candidate" le "$package_version"; then
                    continue
                fi
                targets+=("$package=$candidate")
                ;;
            install) targets+=("$package=$candidate") ;;
            *) print_error "Action deb invalide : $action"; return 2 ;;
        esac
    done
    [[ ${#targets[@]} -gt 0 ]] || return "$result"
    if [[ "$action" == remove ]]; then
        apt_command=(remove)
    elif [[ "$action" == update ]]; then
        apt_command=(--no-remove --only-upgrade install)
    else
        apt_command=(--no-remove install)
    fi
    simulation="$(LC_ALL=C apt-get "${options[@]}" --simulate "${apt_command[@]}" -- "${targets[@]}")" || {
        print_error "Impossible de résoudre l'opération Debian."
        return 1
    }
    # Vérifie aussi les dépendances que le solveur souhaite installer ou retirer.
    while read -r operation package rest; do
        case "$operation" in
            Inst)
                package_version="${rest#*(}"; package_version="${package_version%% *}"; package_version="${package_version%)}"
                policy="$(LC_ALL=C apt-cache "${options[@]}" policy "$package")" || return 1
                if ! software_deb_version_available "$policy" "$package_version"; then
                    print_error "Version non officielle dans la résolution : $package $package_version"
                    return 1
                fi
                installed_version="$(awk '$1 == "Installed:" { print $2; exit }' <<< "$policy")"
                if [[ -n "$installed_version" && "$installed_version" != '(none)' ]] &&
                   ! software_deb_installed_official "$package" "$installed_version" "$policy" "$indexes"; then
                    print_error "Remplacement d'une dépendance d'origine inconnue ou tierce refusé : $package"
                    return 1
                fi
                ;;
            Remv)
                policy="$(LC_ALL=C apt-cache "${options[@]}" policy "$package")" || return 1
                package_version="$(awk '$1 == "Installed:" { print $2; exit }' <<< "$policy")"
                if ! software_deb_installed_official "$package" "$package_version" "$policy" "$indexes"; then
                    print_error "Suppression d'un paquet d'origine inconnue ou tierce refusée : $package"
                    return 1
                fi
                ;;
        esac
    done <<< "$simulation"
    if ! LC_ALL=C apt-get "${options[@]}" "${apt_command[@]}" -- "${targets[@]}"; then
        print_error "Échec de l'opération deb/$action."
        return 1
    fi
    return "$result"
)

software_deb_candidate() {
    awk '$1 == "Candidate:" { print $2; exit }' <<< "$1"
}

# Un enregistrement de version doit avoir une source, pas seulement dpkg/status.
software_deb_version_available() {
    awk -v wanted="$2" '
        $1 == "***" { active = ($2 == wanted); next }
        NF == 2 && $2 ~ /^-?[0-9]+$/ { active = ($1 == wanted); next }
        active && $1 ~ /^[0-9]+$/ && $2 ~ /^https?:\/\// { found = 1 }
        END { exit !found }
    ' <<< "$1"
}

software_deb_installed_official() {
    local package="$1" package_version="$2" policy="$3" indexes="$4" previous sources
    if software_deb_version_available "$policy" "$package_version"; then
        return 0
    fi
    previous="$(LC_ALL=C apt-cache policy "$package")" || return 1
    sources="$(awk -F '|' '$1 == "Debian" && $5 == "Packages" {
        sub(/\/$/, "", $3); print $3 " " $2 "/" $4
    }' <<< "$indexes")"
    # Les anciens index sont uniquement une preuve de présence de la version,
    # jamais une source de téléchargement pour la transaction.
    awk -v wanted="$package_version" -v sources="$sources" '
        BEGIN { split(sources, rows, "\n"); for (i in rows) official[rows[i]] = 1 }
        $1 == "***" { active = ($2 == wanted); next }
        NF == 2 && $2 ~ /^-?[0-9]+$/ { active = ($1 == wanted); next }
        active && (($2 " " $3) in official) { found = 1 }
        END { exit !found }
    ' <<< "$previous"
}

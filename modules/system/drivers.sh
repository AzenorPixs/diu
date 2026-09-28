#!/usr/bin/env bash

system_drivers_error() {
    printf '❌ DisplayLink : %s. État de configuration conservé ; les opérations système déjà effectuées ne sont pas annulées.\n' "$*" >&2
    return 1
}

# 0 : configuré ; 1 : absent ; 2 : incomplet ; 3 : découverte impossible.
system_drivers_package_state() {
    local state status
    if state=$(LC_ALL=C dpkg-query -W -f='${db:Status-Status}' "$1" 2>/dev/null); then
        case "$state" in
            installed) return 0 ;;
            not-installed|config-files) return 1 ;;
            unpacked|half-installed|half-configured|triggers-awaited|triggers-pending) return 2 ;;
            *) return 3 ;;
        esac
    else
        status=$?
        [[ $status -eq 1 && -z "$state" ]] && return 1
        return 3
    fi
}

system_drivers_candidate() {
    local policy
    policy=$(LC_ALL=C apt-cache policy "$1") || return 1
    awk '$1 == "Candidate:" && $2 != "(none)" { print $2; exit }' <<< "$policy"
}

system_drivers_headers_ready() {
    [[ -r "/lib/modules/$1/build/Makefile" ]]
}

system_drivers_headers_package() {
    local kernel="$1" package candidate
    local -a packages=("linux-headers-$kernel")
    [[ "$kernel" != *-pve ]] || packages=("proxmox-headers-$kernel" "pve-headers-$kernel")
    for package in "${packages[@]}"; do
        candidate=$(system_drivers_candidate "$package") || return 1
        if [[ -n "$candidate" ]]; then
            printf '%s\n' "$package"
            return 0
        fi
    done
    return 1
}

system_drivers_download_evdi() {
    local destination="$1" metadata
    local version='1.15.1+dfsg-1'
    local sha256='afed3ea5fe42b3d4aea3bcc20c7f1baa894d8d07d292c34dd93f419de9493a1a'
    curl --fail --location --proto '=https' --proto-redir '=https' \
        --output "$destination" \
        "https://deb.debian.org/debian/pool/main/e/evdi/evdi-dkms_${version}_all.deb" || return 1
    printf '%s  %s\n' "$sha256" "$destination" | sha256sum --check --status || return 1
    metadata=$(dpkg-deb -f "$destination" Package) || return 1
    [[ "$metadata" == evdi-dkms ]] || return 1
    metadata=$(dpkg-deb -f "$destination" Version) || return 1
    [[ "$metadata" == "$version" ]] || return 1
    metadata=$(dpkg-deb -f "$destination" Architecture) || return 1
    [[ "$metadata" == all ]]
}

system_drivers_module_loaded() {
    [[ -d /sys/module/evdi ]]
}

system_drivers_module_current() {
    local loaded available
    [[ -r /sys/module/evdi/srcversion ]] || return 1
    read -r loaded < /sys/module/evdi/srcversion || return 1
    available=$(modinfo -k "$1" -F srcversion evdi) || return 1
    [[ -n "$loaded" && "$loaded" == "$available" ]]
}

system_drivers_library_ready() {
    local files file
    files=$(dpkg-query -L libevdi-dev) || return 1
    while IFS= read -r file; do
        if [[ "$file" == /*/libevdi.so && -r "$file" ]]; then
            return 0
        fi
    done <<< "$files"
    return 1
}

system_drivers_dkms_ready() {
    local status
    status=$(dkms status -m evdi -v "$2" -k "$1") || return 1
    [[ "$status" == *': installed' ]]
}

system_drivers_stop_service() {
    local state
    state=$(systemctl show -p LoadState --value displaylink-driver.service) || return 1
    case "$state" in
        not-found) return 0 ;;
        loaded) systemctl stop displaylink-driver.service ;;
        *) return 1 ;;
    esac
}

system_drivers_service_inactive() {
    local status
    if systemctl is-active --quiet displaylink-driver.service; then
        return 1
    else
        status=$?
        [[ $status -eq 3 || $status -eq 4 ]]
    fi
}

system_drivers_remove_packages() {
    local simulation action package rest
    simulation=$(LC_ALL=C apt-get --simulate remove --no-auto-remove -- "$@") || return 1
    while read -r action package rest; do
        [[ "$action" == Remv ]] || continue
        case "${package%%:*}" in
            displaylink-driver|evdi-dkms) ;;
            *) printf 'Suppression supplémentaire refusée : %s\n' "$package" >&2; return 1 ;;
        esac
    done <<< "$simulation"
    apt-get remove -y --no-auto-remove -- "$@"
}

system_drivers_persist_state() {
    local value="$1" file="${2:-/root/diu/config/system.env}" temporary
    [[ "$value" == 0 || "$value" == 1 ]] || return 1
    if [[ ! -d "${file%/*}" ]]; then
        install -d -m 0755 -- "${file%/*}" || return 1
    fi
    temporary=$(mktemp "${file}.XXXXXX") || return 1
    if [[ -e "$file" ]]; then
        if ! cp -p -- "$file" "$temporary" ||
            ! awk -v value="$value" '
                !/^[[:blank:]]*(export[[:blank:]]+)?SYSTEM_DRIVERS_DISPLAY_LINK=/ { print }
                END { print "export SYSTEM_DRIVERS_DISPLAY_LINK=" value }
            ' "$file" > "$temporary"; then
            rm -f -- "$temporary"
            return 1
        fi
    elif ! printf 'export SYSTEM_DRIVERS_DISPLAY_LINK=%s\n' "$value" > "$temporary"; then
        rm -f -- "$temporary"
        return 1
    fi
    if ! mv -f -- "$temporary" "$file"; then
        rm -f -- "$temporary"
        return 1
    fi
    export SYSTEM_DRIVERS_DISPLAY_LINK="$value"
}

system_drivers_install_displaylink() {
    local kernel package state version='' candidate headers module_version temporary='' evdi='evdi-dkms'
    local repair=0 changed=0
    local -a packages=(dkms displaylink-driver libevdi-dev)
    case "${SYSTEM_DEBIAN_ENVIRONNEMENT:-UNSET}" in
        PHYSICAL|PROXMOX) ;;
        *) system_drivers_error 'installation réservée à PHYSICAL ou PROXMOX'; return 1 ;;
    esac
    kernel=$(uname -r) || { system_drivers_error 'noyau indéterminé'; return 1; }
    [[ -n "$kernel" ]] || { system_drivers_error 'noyau vide'; return 1; }
    for package in dkms displaylink-driver libevdi-dev evdi-dkms; do
        if system_drivers_package_state "$package"; then
            continue
        else
            state=$?
            [[ $state -ne 3 ]] || { system_drivers_error "état de $package indéterminé"; return 1; }
            repair=1
        fi
    done
    if system_drivers_package_state evdi-dkms; then
        version=$(dpkg-query -W -f='${Version}' evdi-dkms) || {
            system_drivers_error 'version EVDI indéterminée'; return 1;
        }
    fi
    if ! system_drivers_headers_ready "$kernel"; then
        headers=$(system_drivers_headers_package "$kernel") || {
            system_drivers_error "headers introuvables pour $kernel"; return 1;
        }
        packages+=("$headers")
        repair=1
    fi
    if [[ "$kernel" == 7.* ]] && { [[ -z "$version" ]] || ! dpkg --compare-versions "$version" ge 1.15.1; }; then
        candidate=$(system_drivers_candidate evdi-dkms) || {
            system_drivers_error 'candidat EVDI indéterminé'; return 1;
        }
        if [[ -n "$candidate" ]] && dpkg --compare-versions "$candidate" ge 1.15.1; then
            evdi="evdi-dkms=$candidate"
        else
            temporary=$(mktemp -d) || return 1
            evdi="$temporary/evdi-dkms_1.15.1+dfsg-1_all.deb"
            if ! system_drivers_download_evdi "$evdi"; then
                rm -rf -- "$temporary"
                system_drivers_error "téléchargement EVDI ou contrôle d’intégrité échoué"
                return 1
            fi
        fi
        repair=1
    fi
    if [[ $repair -eq 1 ]]; then
        if ! apt-get install -y --no-remove -- "${packages[@]}" "$evdi"; then
            [[ -z "$temporary" ]] || rm -rf -- "$temporary"
            system_drivers_error 'installation APT échouée'
            return 1
        fi
        [[ -z "$temporary" ]] || rm -rf -- "$temporary"
        changed=1
    fi
    for package in dkms displaylink-driver libevdi-dev evdi-dkms; do
        system_drivers_package_state "$package" || {
            system_drivers_error "paquet $package non configuré"; return 1;
        }
    done
    system_drivers_headers_ready "$kernel" || { system_drivers_error "headers absents pour $kernel"; return 1; }
    version=$(dpkg-query -W -f='${Version}' evdi-dkms) || {
        system_drivers_error 'version EVDI indéterminée'; return 1;
    }
    [[ -n "$version" ]] || { system_drivers_error 'version EVDI vide'; return 1; }
    if [[ "$kernel" == 7.* ]] && ! dpkg --compare-versions "$version" ge 1.15.1; then
        system_drivers_error 'EVDI trop ancien pour Linux 7.x'; return 1
    fi
    module_version="${version#*:}"
    module_version="${module_version%-*}"
    if ! system_drivers_dkms_ready "$kernel" "$module_version"; then
        dkms install -m evdi -v "$module_version" -k "$kernel" || {
            system_drivers_error "compilation DKMS échouée pour $kernel"; return 1;
        }
        changed=1
    fi
    system_drivers_dkms_ready "$kernel" "$module_version" || {
        system_drivers_error 'module DKMS non installé'; return 1;
    }
    system_drivers_library_ready || { system_drivers_error 'libevdi.so inaccessible'; return 1; }
    if system_drivers_module_loaded && { [[ $changed -eq 1 ]] || ! system_drivers_module_current "$kernel"; }; then
        if ! system_drivers_stop_service || ! modprobe -r evdi; then
            system_drivers_error 'ancien module EVDI impossible à décharger (écrans utilisés ?)'; return 1
        fi
    fi
    if ! system_drivers_module_loaded; then
        modprobe evdi || { system_drivers_error 'chargement EVDI échoué ; vérifier le journal noyau et Secure Boot'; return 1; }
    fi
    if ! system_drivers_module_loaded || ! system_drivers_module_current "$kernel"; then
        system_drivers_error 'module chargé différent du module installé'; return 1
    fi
    if ! systemctl enable --now displaylink-driver.service ||
        ! systemctl is-active --quiet displaylink-driver.service; then
        system_drivers_error 'service DisplayLink inactif'; return 1
    fi
    system_drivers_persist_state 1 || { system_drivers_error 'persistance impossible'; return 1; }
    printf 'DISPLAY LINK OK ✅\n'
}

system_drivers_remove_displaylink() {
    local package state
    local -a packages=()
    for package in displaylink-driver evdi-dkms; do
        if system_drivers_package_state "$package"; then
            packages+=("$package")
        else
            state=$?
            case "$state" in
                1) ;;
                2) packages+=("$package") ;;
                *) system_drivers_error "état de $package indéterminé"; return 1 ;;
            esac
        fi
    done
    system_drivers_stop_service || { system_drivers_error 'arrêt du service impossible'; return 1; }
    if [[ ${#packages[@]} -gt 0 ]]; then
        system_drivers_remove_packages "${packages[@]}" || { system_drivers_error 'suppression APT échouée'; return 1; }
    fi
    if system_drivers_module_loaded; then
        modprobe -r evdi || { system_drivers_error 'module EVDI encore utilisé'; return 1; }
    fi
    for package in displaylink-driver evdi-dkms; do
        if system_drivers_package_state "$package"; then
            system_drivers_error "$package encore installé"; return 1
        else
            state=$?
            [[ $state -eq 1 ]] || { system_drivers_error "absence de $package non confirmée"; return 1; }
        fi
    done
    if system_drivers_module_loaded || ! system_drivers_service_inactive; then
        system_drivers_error 'absence du module ou arrêt du service non confirmé'; return 1
    fi
    system_drivers_persist_state 0 || { system_drivers_error 'persistance impossible'; return 1; }
    printf 'DISPLAY LINK SUPPRIMÉ ✅\n'
}

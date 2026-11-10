#!/usr/bin/env bash

software_apt_effective_release() {
    local file="${1:-/etc/os-release}" release="${SYSTEM_DEBIAN_RELEASE:-}" line found=0
    if [[ -z "$release" ]]; then
        [[ -f "$file" && -r "$file" ]] || return 1
        while IFS= read -r line || [[ -n "$line" ]]; do
            if [[ "$line" =~ ^VERSION_CODENAME=([a-z0-9-]+)$ || "$line" =~ ^VERSION_CODENAME=\"([a-z0-9-]+)\"$ ]]; then
                release="${BASH_REMATCH[1]}"
                (( found += 1 ))
            elif [[ "$line" == VERSION_CODENAME=* ]]; then
                return 1
            fi
        done < "$file"
        [[ "$found" == 1 ]] || return 1
    fi
    case "$release" in bullseye|bookworm|trixie) printf '%s\n' "$release" ;; *) return 1 ;; esac
}

# Interroge la base entière pour distinguer un paquet inconnu d'une erreur dpkg.
software_apt_package_state() {
    local package="${1:-}" rows name state found=0
    if [[ ! "$package" =~ ^[a-z0-9][a-z0-9+.-]+$ ]]; then
        printf '%s\n' 'Identifiant de paquet invalide.' >&2
        return 2
    fi
    if ! rows="$(dpkg-query -W -f='${binary:Package}\t${db:Status-Status}\n')"; then
        printf '%s\n' 'État des paquets Debian indisponible.' >&2
        return 2
    fi
    while IFS=$'\t' read -r name state; do
        [[ "$name" == "$package" || "$name" == "$package:"* ]] || continue
        case "$state" in
            installed) found=1 ;;
            not-installed|config-files) ;;
            *) printf 'État Debian incomplet pour %s.\n' "$package" >&2; return 1 ;;
        esac
    done <<< "$rows"
    printf '%s\n' "$found"
}

software_apt_apache2_detect() { software_apt_package_state apache2; }
software_apt_chatgpt_real_state() { software_apt_package_state chatgpt; }
software_apt_crowdsec_agent_detect() { software_apt_package_state crowdsec; }
software_apt_crowdsec_bouncer_detect() { software_apt_package_state crowdsec-firewall-bouncer-iptables; }
software_apt_fastfetch_detect() {
    local release
    release="$(software_apt_effective_release /etc/os-release)" || return 1
    case "$release" in
        bullseye|bookworm) software_apt_package_state neofetch ;;
        trixie) software_apt_package_state fastfetch ;;
        *) printf '%s\n' 'Version Debian non prise en charge pour Fastfetch.' >&2; return 1 ;;
    esac
}
software_apt_jsvc_detect() { software_apt_package_state jsvc; }
software_apt_lemonldap_detect() { software_apt_package_state lemonldap-ng; }
software_apt_mongodb_installed_packages() {
    local rows name state matched=0
    if ! rows="$(dpkg-query -W -f='${binary:Package}\t${db:Status-Status}\n')"; then
        printf '%s\n' 'État des paquets Debian indisponible.' >&2
        return 2
    fi
    while IFS=$'\t' read -r name state; do
        [[ "$name" =~ ^mongodb-org(-[a-z0-9-]+)?(:[a-z0-9][a-z0-9-]*)?$ ]] || continue
        case "$state" in
            installed) printf '%s\n' "$name"; matched=1 ;;
            not-installed|config-files) ;;
            *) printf '%s\n' 'État MongoDB incomplet.' >&2; return 2 ;;
        esac
    done <<< "$rows"
    [[ "$matched" == 1 ]]
}

software_apt_mongodb_detect() {
    local packages status
    if packages="$(software_apt_mongodb_installed_packages)"; then
        if [[ "$packages" =~ (^|$'\n')mongodb-org-server(:[a-z0-9][a-z0-9-]*)?($|$'\n') ]]; then
            printf '1\n'
        else
            printf '%s\n' 'Composants MongoDB présents sans serveur vérifié.' >&2
            return 1
        fi
    else
        status=$?
        if [[ "$status" == 1 ]]; then printf '0\n'; else return "$status"; fi
    fi
}
software_apt_openjdk_installed_packages() {
    local rows name state matched=0
    if ! rows="$(dpkg-query -W -f='${binary:Package}\t${db:Status-Status}\n')"; then
        printf '%s\n' 'État des paquets Debian indisponible.' >&2
        return 2
    fi
    while IFS=$'\t' read -r name state; do
        [[ "$name" =~ ^openjdk-[0-9]+-jre-headless(:[a-z0-9][a-z0-9-]*)?$ ]] || continue
        case "$state" in
            installed) printf '%s\n' "$name"; matched=1 ;;
            not-installed|config-files) ;;
            *) printf '%s\n' 'État OpenJDK incomplet.' >&2; return 2 ;;
        esac
    done <<< "$rows"
    [[ "$matched" == 1 ]]
}

software_apt_openjdk_detect() {
    local packages status
    if packages="$(software_apt_openjdk_installed_packages)"; then
        [[ -n "$packages" ]] || return 2
        printf '1\n'
    else
        status=$?
        if [[ "$status" == 1 ]]; then printf '0\n'; else return "$status"; fi
    fi
}
software_apt_openvswitch_detect() { software_apt_package_state openvswitch-switch; }
software_apt_omada_detect() { software_apt_package_state omadac; }
software_apt_postfix_detect() { software_apt_package_state postfix; }
software_apt_postgresql_installed_packages() {
    local rows name state matched=0
    if ! rows="$(dpkg-query -W -f='${binary:Package}\t${db:Status-Status}\n')"; then
        printf '%s\n' 'État des paquets Debian indisponible.' >&2
        return 2
    fi
    while IFS=$'\t' read -r name state; do
        [[ "$name" =~ ^postgresql(-[0-9]+)?(:[a-z0-9][a-z0-9-]*)?$ ]] || continue
        case "$state" in
            installed) printf '%s\n' "$name"; matched=1 ;;
            not-installed|config-files) ;;
            *) printf '%s\n' 'État PostgreSQL incomplet.' >&2; return 2 ;;
        esac
    done <<< "$rows"
    [[ "$matched" == 1 ]]
}

software_apt_postgresql_detect() {
    local packages status
    if packages="$(software_apt_postgresql_installed_packages)"; then
        if [[ "$packages" =~ (^|$'\n')postgresql-[0-9]+(:[a-z0-9][a-z0-9-]*)?($|$'\n') ]]; then
            printf '1\n'
        else
            printf '%s\n' 'Métapaquet PostgreSQL présent sans serveur vérifié.' >&2
            return 1
        fi
    else
        status=$?
        # Le catalogue vide est distinct d'une erreur dpkg par l'état retourné ci-dessous.
        if [[ "$status" == 1 ]]; then
            printf '0\n'
        else
            return "$status"
        fi
    fi
}
software_apt_qemu_guest_agent_detect() { software_apt_package_state qemu-guest-agent; }
software_apt_ssh_server_detect() { software_apt_package_state openssh-server; }
software_apt_syncthing_detect() { software_apt_package_state syncthing; }
software_apt_wazuh_agent_detect() { software_apt_package_state wazuh-agent; }
software_apt_wazuh_server_installed_packages() {
    local rows name state matched=0
    if ! rows="$(dpkg-query -W -f='${binary:Package}\t${db:Status-Status}\n')"; then
        printf '%s\n' 'État des paquets Debian indisponible.' >&2
        return 2
    fi
    while IFS=$'\t' read -r name state; do
        [[ "$name" =~ ^wazuh-(indexer|manager|dashboard)(:[a-z0-9][a-z0-9-]*)?$ ]] || continue
        case "$state" in
            installed) printf '%s\n' "$name"; matched=1 ;;
            not-installed|config-files) ;;
            *) printf '%s\n' 'État Wazuh serveur incomplet.' >&2; return 2 ;;
        esac
    done <<< "$rows"
    [[ "$matched" == 1 ]]
}

software_apt_wazuh_server_detect() {
    local packages status
    if packages="$(software_apt_wazuh_server_installed_packages)"; then
        [[ -n "$packages" ]] || return 2
        printf '1\n'
    else
        status=$?
        if [[ "$status" == 1 ]]; then printf '0\n'; else return "$status"; fi
    fi
}
software_apt_webmin_detect() { software_apt_package_state webmin; }
software_apt_zoom_detect() { software_apt_package_state zoom; }
software_apt_zsh_detect() { software_apt_package_state zsh; }

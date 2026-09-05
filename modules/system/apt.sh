#!/usr/bin/env bash

SYSTEM_APT_DEBIAN_SOURCES_FILE="/etc/apt/sources.list.d/debian.sources"
SYSTEM_APT_THIRD_PARTY_DIRECTORY="/etc/apt/sources.list.d"
SYSTEM_APT_THIRD_PARTY_KEYRING_DIRECTORY="/usr/share/keyrings"

system_apt_is_deb822() {
    local version_id=""
    # shellcheck disable=SC1091
    source /etc/os-release
    version_id="${VERSION_ID:-}"
    [[ "$version_id" =~ ^([0-9]+)(\.[0-9]+)?$ ]] && (( BASH_REMATCH[1] >= 13 ))
}

system_apt_repository_engine() {
    local enable="$1" name="$2" url_gpg_key="$3" type="$4"
    local suites="$5" architecture="$6" uris="$7" components="${8-main}"
    local modern_file="${SYSTEM_APT_THIRD_PARTY_DIRECTORY}/${name}.sources"
    local legacy_file="${SYSTEM_APT_THIRD_PARTY_DIRECTORY}/${name}.list"
    local keyring="${SYSTEM_APT_THIRD_PARTY_KEYRING_DIRECTORY}/${name}-archive-keyring.gpg"

    [[ "$name" =~ ^[a-z0-9][a-z0-9+._-]*$ ]] || { print_error "Nom de dépôt APT invalide : $name"; return 1; }
    [[ "$type" =~ ^[a-z][a-z0-9-]*$ ]] || { print_error "Type de dépôt APT invalide : $type"; return 1; }
    [[ "$enable" == 0 || "$enable" == 1 ]] || { print_error "Activation de dépôt APT invalide : $name"; return 1; }

    if [[ "$enable" == 0 ]]; then
        rm -f -- "$modern_file" "$legacy_file" "$keyring"
        return 0
    fi

    [[ -n "$url_gpg_key" && -n "$suites" && -n "$uris" ]] || {
        print_error "Paramètres incomplets pour le dépôt APT : $name"
        return 1
    }
    install -d -m 0755 "$SYSTEM_APT_THIRD_PARTY_DIRECTORY" "$SYSTEM_APT_THIRD_PARTY_KEYRING_DIRECTORY"
    if ! curl -fsSL "$url_gpg_key" | gpg --dearmor --yes --output "$keyring"; then
        print_error "Impossible d'installer la clé GPG du dépôt APT : $name"
        return 1
    fi
    chmod 0644 "$keyring"

    if system_apt_is_deb822; then
        rm -f -- "$legacy_file"
        {
            printf 'Types: %s\n' "$type"
            printf 'URIs: %s\n' "$uris"
            printf 'Suites: %s\n' "$suites"
            [[ -n "$architecture" ]] && printf 'Architectures: %s\n' "$architecture"
            [[ -n "$components" ]] && printf 'Components: %s\n' "$components"
            printf 'Signed-By: %s\n\n' "$keyring"
        } > "$modern_file"
    else
        rm -f -- "$modern_file"
        local options="signed-by=${keyring}"
        [[ -n "$architecture" ]] && options="arch=${architecture} ${options}"
        printf '%s [%s] %s %s %s\n' "$type" "$options" "$uris" "$suites" "$components" > "$legacy_file"
    fi
}

system_apt_configure_unofficial() {
    system_apt_repository_engine "${SYSTEM_APT_CROWDSEC:-0}" crowdsec \
        https://packagecloud.io/crowdsec/crowdsec/gpgkey deb any "" http://packagecloud.io/crowdsec/crowdsec/any
    system_apt_repository_engine "${SYSTEM_APT_DOCKER:-0}" docker \
        https://download.docker.com/linux/debian/gpg deb "${SYSTEM_DEBIAN_RELEASE}" "" https://download.docker.com/linux/debian stable
    system_apt_repository_engine "${SYSTEM_APT_LEMONLDAP:-0}" lemonldap \
        https://lemonldap-ng.org/lemonldap-debian-packages-pub.gpg deb 2.0 amd64 https://lemonldap-ng.org/deb
    case "${SYSTEM_APT_MONGODB:-0}" in
        4|5|6|7|8) system_apt_repository_engine 1 mongodb \
            "https://www.mongodb.org/static/pgp/server-${SYSTEM_APT_MONGODB}.0.asc" deb \
            "bookworm/mongodb-org/${SYSTEM_APT_MONGODB}.0" amd64 http://repo.mongodb.org/apt/debian ;;
        *) system_apt_repository_engine 0 mongodb "" deb "" "" "" ;;
    esac
    system_apt_repository_engine "${SYSTEM_APT_NODEJS:-0}" nodesource \
        https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key deb nodistro amd64 https://deb.nodesource.com/node_24.x
    system_apt_repository_engine "${SYSTEM_APT_NVIDIA:-0}" nvidia \
        https://developer.download.nvidia.com/compute/cuda/repos/debian13/x86_64/8793F200.pub deb / amd64 https://developer.download.nvidia.com/compute/cuda/repos/debian13/x86_64/ ""
    system_apt_repository_engine "${SYSTEM_APT_NVIDIA:-0}" nvidia-container-toolkit \
        https://nvidia.github.io/libnvidia-container/gpgkey deb / amd64 https://nvidia.github.io/libnvidia-container/stable/deb/amd64/ ""
    system_apt_repository_engine "${SYSTEM_APT_PROXMOX:-0}" proxmox \
        https://enterprise.proxmox.com/debian/proxmox-release-trixie.gpg deb "${SYSTEM_DEBIAN_RELEASE}" "" http://download.proxmox.com/debian/pve pve-no-subscription
    system_apt_repository_engine "${SYSTEM_APT_VSCODE:-0}" vscode \
        https://packages.microsoft.com/keys/microsoft.asc deb stable amd64 https://packages.microsoft.com/repos/code
    system_apt_repository_engine "${SYSTEM_APT_WAZUH:-0}" wazuh \
        https://packages.wazuh.com/key/GPG-KEY-WAZUH deb stable amd64 https://packages.wazuh.com/4.x/apt
    system_apt_repository_engine "${SYSTEM_APT_WEBMIN:-0}" webmin \
        https://download.webmin.com/jcameron-key.asc deb sarge "" http://download.webmin.com/download/repository contrib
}

system_apt_debian_is_deb822() {
    local version_id=""
    # shellcheck disable=SC1091
    source /etc/os-release
    version_id="${VERSION_ID:-}"
    [[ "$version_id" =~ ^([0-9]+)(\.[0-9]+)?$ ]] && (( BASH_REMATCH[1] >= 13 ))
}

system_apt_debian_components() {
    local components=(main)
    [[ "${SYSTEM_APT_DEBIAN_CONTRIB:-1}" == 1 ]] && components+=(contrib)
    if [[ "${SYSTEM_APT_DEBIAN_NONFRFEE:-1}" == 1 ]]; then
        components+=(non-free-firmware non-free)
    fi
    printf '%s' "${components[*]}"
}

system_apt_debian_configure_deb822() {
    local release="$1" components
    components="$(system_apt_debian_components)"
    {
        printf 'Types: deb%s\n' "$( [[ "${SYSTEM_APT_DEBIAN_SOURCES:-0}" == 1 ]] && printf ' deb-src' )"
        printf 'URIs: http://security.debian.org/debian-security\nSuites: %s-security\nComponents: %s\nSigned-By: /usr/share/keyrings/debian-archive-keyring.gpg\n\n' "$release" "$components"
        printf 'Types: deb%s\n' "$( [[ "${SYSTEM_APT_DEBIAN_SOURCES:-0}" == 1 ]] && printf ' deb-src' )"
        printf 'URIs: http://deb.debian.org/debian\nSuites: %s\nComponents: %s\nSigned-By: /usr/share/keyrings/debian-archive-keyring.gpg\n' "$release" "$components"
        [[ "${SYSTEM_APT_DEBIAN_UPDATES:-1}" == 1 ]] && printf '\nTypes: deb%s\nURIs: http://deb.debian.org/debian\nSuites: %s-updates\nComponents: %s\nSigned-By: /usr/share/keyrings/debian-archive-keyring.gpg\n' "$( [[ "${SYSTEM_APT_DEBIAN_SOURCES:-0}" == 1 ]] && printf ' deb-src' )" "$release" "$components"
        [[ "${SYSTEM_APT_DEBIAN_BACKPORT:-1}" == 1 ]] && printf '\nTypes: deb%s\nURIs: http://deb.debian.org/debian\nSuites: %s-backports\nComponents: %s\nSigned-By: /usr/share/keyrings/debian-archive-keyring.gpg\n' "$( [[ "${SYSTEM_APT_DEBIAN_SOURCES:-0}" == 1 ]] && printf ' deb-src' )" "$release" "$components"
    } > "${SYSTEM_APT_DEBIAN_SOURCES_FILE}"
}

system_apt_debian_configure_legacy() {
    local release="$1" components line temporary
    components="$(system_apt_debian_components)"
    : > /etc/apt/sources.list
    line="deb http://deb.debian.org/debian ${release} ${components}"
    printf '%s\n' "$line" >> /etc/apt/sources.list
    [[ "${SYSTEM_APT_DEBIAN_UPDATES:-1}" == 1 ]] && printf 'deb http://deb.debian.org/debian %s-updates %s\n' "$release" "$components" >> /etc/apt/sources.list
    printf 'deb http://security.debian.org/debian-security %s-security %s\n' "$release" "$components" >> /etc/apt/sources.list
    [[ "${SYSTEM_APT_DEBIAN_BACKPORT:-1}" == 1 ]] && printf 'deb http://deb.debian.org/debian %s-backports %s\n' "$release" "$components" >> /etc/apt/sources.list
    if [[ "${SYSTEM_APT_DEBIAN_SOURCES:-0}" == 1 ]]; then
        temporary="$(mktemp)"
        sed 's/^deb /deb-src /' /etc/apt/sources.list > "$temporary"
        cat "$temporary" >> /etc/apt/sources.list
        rm -f "$temporary"
    fi
}

system_apt_debian_configure() {
    local release="${SYSTEM_DEBIAN_RELEASE:-}" 
    [[ "$release" =~ ^[a-z][a-z0-9.-]*$ ]] || { print_error "Release Debian invalide."; return 1; }
    install -d -m 0755 /usr/share/keyrings /etc/apt/sources.list.d
    rm -f /etc/apt/sources.list
    if system_apt_debian_is_deb822; then
        system_apt_debian_configure_deb822 "$release"
    else
        rm -f "$SYSTEM_APT_DEBIAN_SOURCES_FILE"
        system_apt_debian_configure_legacy "$release"
    fi
    system_apt_configure_unofficial
}

system_install_prerequisites() {
    local package
    local -a prerequisites=()

    prerequisites=(
        aptitude apache2-utils apt-transport-https bash-completion
        bind9-dnsutils ca-certificates curl dirmngr ethtool extrepo git gnupg
        gpg inetutils-telnet iptables jq lshw lsb-release man-db manpages-fr
        net-tools netcat-traditional nicstat openssl pciutils ripgrep shellcheck
        python3-pytest ripgrep shellcheck sudo tcpdump traceroute tree util-linux wget
    )

    while IFS= read -r package; do
        if ! dpkg-query -W -f='${db:Status-Status}' "$package" 2>/dev/null |
            grep -qx installed; then
            print_info "Installation du prérequis : $package"
            apt-get install -y -- "$package"
        fi
    done < <(printf '%s\n' "${prerequisites[@]}" | LC_ALL=C sort -u)
}

system_apt_regenerate() {
    system_apt_debian_configure
}

system_apt_update() {
    system_apt_regenerate
    echo "🔧 UPDATE & DIST-UPGRADE"
    apt -y update && apt -q -y --allow-downgrades --allow-change-held-packages -f -m --show-progress dist-upgrade
    echo "🔧 CLEAN AND PURGE AND REMOVE"
    apt autoclean -y
    apt autopurge -y
    apt autoremove -y
    system_install_prerequisites
}

system_update() {
    system_apt_update
}

system_apt_repository_variable() {
    case "${1,,}" in
        crowdsec|crodwsec) printf '%s' SYSTEM_APT_CROWDSEC ;;
        docker) printf '%s' SYSTEM_APT_DOCKER ;;
        lemonldap|lemonldap-ng) printf '%s' SYSTEM_APT_LEMONLDAP ;;
        mongodb|mongodb-4|mongodb-5|mongodb-6|mongodb-7|mongodb-8) printf '%s' SYSTEM_APT_MONGODB ;;
        nodejs|node|nodesource) printf '%s' SYSTEM_APT_NODEJS ;;
        nvidia) printf '%s' SYSTEM_APT_NVIDIA ;;
        proxmox) printf '%s' SYSTEM_APT_PROXMOX ;;
        vscode|code) printf '%s' SYSTEM_APT_VSCODE ;;
        wazuh|wazuh-4) printf '%s' SYSTEM_APT_WAZUH ;;
        webmin) printf '%s' SYSTEM_APT_WEBMIN ;;
        *) return 1 ;;
    esac
}

system_apt_set_repository_variable() {
    local repository="$1" value="$2" variable_config_file="/root/diu/config/system.env"
    local current_line
    [[ "$value" =~ ^(0|1|4|5|6|7|8)$ ]] || return 1
    export "${repository}=${value}"
    if [[ -f "$variable_config_file" ]]; then
        sed -i "/^export ${repository}=/d" "$variable_config_file"
    else
        install -d -m 0755 "$(dirname "$variable_config_file")"
    fi
    current_line="export ${repository}=${value}"
    printf '%s\n' "$current_line" >> "$variable_config_file"
}

system_apt_install_repository() {
    local requested="$1" variable value=1
    variable="$(system_apt_repository_variable "$requested")" || {
        print_error "Dépôt APT non supporté : $requested"
        return 2
    }
    if [[ "$requested" =~ ^mongodb-([45678])$ ]]; then
        value="${BASH_REMATCH[1]}"
    elif [[ "$requested" == wazuh-4 ]]; then
        value=4
    fi
    system_apt_set_repository_variable "$variable" "$value"
    system_apt_debian_configure
}

system_apt_remove_repository() {
    local requested="$1" variable
    variable="$(system_apt_repository_variable "$requested")" || {
        print_error "Dépôt APT non supporté : $requested"
        return 2
    }
    system_apt_set_repository_variable "$variable" 0
    system_apt_debian_configure
}

manage_system_action() {
    local action="${1:-}" repository=""
    case "$action" in
        install|remove)
            [[ "${2:-}" == apt && $# -eq 3 ]] || {
                print_error "Usage : diu system ${action} apt <repository>"
                return 2
            }
            repository="$3"
            if [[ "$action" == install ]]; then
                system_apt_install_repository "$repository"
            else
                system_apt_remove_repository "$repository"
            fi
            ;;
        update)
            shift
            if [[ "${1:-}" == apt ]]; then
                shift
            fi
            case "${1:-}" in
                debian)
                    [[ $# -eq 1 ]] || { print_error "Usage : diu system update apt"; return 2; }
                    system_apt_update
                    ;;
                '') system_apt_update ;;
                *) print_error "Usage : diu system update apt [debian]"; return 2 ;;
            esac
            ;;
        apt)
            shift
            [[ "${1:-}" == update && $# -eq 1 ]] || { print_error "Usage : diu system apt update"; return 2; }
            system_apt_update
            ;;
        '') system_update ;;
        *) print_error "Usage : diu system {install|remove} apt <repository> | update [apt [debian]]"; return 2 ;;
    esac
}

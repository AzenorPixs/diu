#!/usr/bin/env bash

SYSTEM_APT_DEBIAN_SOURCES_FILE="/etc/apt/sources.list.d/debian.sources"

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
}

system_apt_debian_update() {
    system_apt_debian_configure
    software_deb update "" 1
}

system_install_prerequisites() {
    local package
    local -a prerequisites=()

    prerequisites=(
        aptitude apache2-utils apt-transport-https bash-completion
        bind9-dnsutils ca-certificates curl dirmngr ethtool extrepo git gnupg
        gpg inetutils-telnet iptables jq lshw lsb-release man-db manpages-fr
        net-tools netcat-traditional nicstat openssl pciutils ripgrep shellcheck
        pytest ripgrep shellcheck sudo tcpdump traceroute tree util-linux wget
    )

    while IFS= read -r package; do
        if ! dpkg-query -W -f='${db:Status-Status}' "$package" 2>/dev/null |
            grep -qx installed; then
            print_info "Installation du prérequis : $package"
            apt-get install -y -- "$package"
        fi
    done < <(printf '%s\n' "${prerequisites[@]}" | LC_ALL=C sort -u)
}

system_apt_update() {
    system_apt_debian_configure
    apt-get update
    apt-get dist-upgrade -y
    system_install_prerequisites
}

system_update() {
    system_apt_update
}

manage_system_action() {
    [[ "${1:-}" == update || "${1:-}" == apt ]] || { print_error "Usage : diu system update [apt [debian]]"; return 2; }
    shift
    if [[ "$1" == update ]]; then
        shift
    fi
    case "${1:-}" in
        apt)
            shift
            if [[ "${1:-}" == debian && $# -eq 1 ]]; then
                system_apt_debian_update
            elif [[ $# -eq 0 ]]; then
                system_apt_update
            else
                print_error "Usage : diu system update apt [debian]"; return 2
            fi
            ;;
        '') system_update ;;
        *) print_error "Usage : diu system update apt [debian]"; return 2 ;;
    esac
}

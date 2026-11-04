#!/usr/bin/env bash

SYSTEM_APT_DEBIAN_SOURCES_FILE="/etc/apt/sources.list.d/debian.sources"
SYSTEM_APT_THIRD_PARTY_DIRECTORY="/etc/apt/sources.list.d"
SYSTEM_APT_THIRD_PARTY_KEYRING_DIRECTORY="/usr/share/keyrings"
SYSTEM_APT_CGPT_KEY_FILE="${BASH_SCRIPT_PATH:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)}/modules/system/apt-keys/chatgpt-archive-keyring.asc"

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
    local legacy_keyring="${SYSTEM_APT_THIRD_PARTY_KEYRING_DIRECTORY}/crowdsec-crowdsec-archive-keyring.gpg"

    [[ "$name" =~ ^[a-z0-9][a-z0-9+._-]*$ ]] || { print_error "Nom de dépôt APT invalide : $name"; return 1; }
    [[ "$type" =~ ^[a-z][a-z0-9-]*$ ]] || { print_error "Type de dépôt APT invalide : $type"; return 1; }
    [[ "$enable" == 0 || "$enable" == 1 ]] || { print_error "Activation de dépôt APT invalide : $name"; return 1; }

    if [[ "$enable" == 0 ]]; then
        rm -f -- "$modern_file" "$legacy_file" "$keyring" || return 1
        return 0
    fi

    [[ -n "$url_gpg_key" && -n "$suites" && -n "$uris" ]] || {
        print_error "Paramètres incomplets pour le dépôt APT : $name"
        return 1
    }
    install -d -m 0755 "$SYSTEM_APT_THIRD_PARTY_DIRECTORY" "$SYSTEM_APT_THIRD_PARTY_KEYRING_DIRECTORY" || return 1
    if [[ ! -f "$keyring" || ! -r "$keyring" || ! -s "$keyring" ]]; then
        if [[ "$name" == crowdsec && -f "$legacy_keyring" && -r "$legacy_keyring" && -s "$legacy_keyring" ]]; then
            if ! install -m 0644 "$legacy_keyring" "$keyring"; then
                print_error "Impossible d'installer la clé GPG historique du dépôt APT : $name"
                return 1
            fi
        elif ! curl -fsSL "$url_gpg_key" | gpg --dearmor --yes --output "$keyring"; then
            print_error "Impossible d'installer la clé GPG du dépôt APT : $name"
            return 1
        fi
    fi
    chmod 0644 "$keyring" || return 1

    if system_apt_is_deb822; then
        rm -f -- "$legacy_file" || return 1
        {
            printf 'Types: %s\n' "$type"
            printf 'URIs: %s\n' "$uris"
            printf 'Suites: %s\n' "$suites"
            [[ -n "$architecture" ]] && printf 'Architectures: %s\n' "$architecture"
            [[ -n "$components" ]] && printf 'Components: %s\n' "$components"
            printf 'Signed-By: %s\n\n' "$keyring"
        } > "$modern_file"
    else
        rm -f -- "$modern_file" || return 1
        local options="signed-by=${keyring}"
        [[ -n "$architecture" ]] && options="arch=${architecture} ${options}"
        printf '%s [%s] %s %s %s\n' "$type" "$options" "$uris" "$suites" "$components" > "$legacy_file"
    fi
}

system_apt_configure_unofficial() {
    local wazuh_enable mongodb_version mongodb_release=bookworm
    case "${SYSTEM_APT_WAZUH:-0}" in
        0) wazuh_enable=0 ;;
        1|4) wazuh_enable=1 ;;
        *) print_error "Activation de dépôt APT invalide : wazuh"; return 1 ;;
    esac
    [[ "${SYSTEM_DEBIAN_RELEASE}" == bullseye ]] && mongodb_release=bullseye
    system_apt_repository_engine "${SOFTWARES_APT_CROWDSEC:-0}" crowdsec \
        https://packagecloud.io/crowdsec/crowdsec/gpgkey deb any "" http://packagecloud.io/crowdsec/crowdsec/any || return 1
    system_apt_repository_engine "${SYSTEM_APT_DOCKER:-0}" docker \
        https://download.docker.com/linux/debian/gpg deb "${SYSTEM_DEBIAN_RELEASE}" "" https://download.docker.com/linux/debian stable || return 1
    system_apt_repository_engine "${SYSTEM_APT_LEMONLDAP:-0}" lemonldap \
        https://lemonldap-ng.org/lemonldap-debian-packages-pub.gpg deb 2.0 amd64 https://lemonldap-ng.org/deb || return 1
    case "${SYSTEM_APT_MONGODB:-0}" in
        4|5|6|7|8)
            mongodb_version="${SYSTEM_APT_MONGODB}.0"
            [[ "$SYSTEM_APT_MONGODB" == 4 ]] && mongodb_version=4.4
            system_apt_repository_engine 1 mongodb \
                "https://www.mongodb.org/static/pgp/server-${mongodb_version}.asc" deb \
                "${mongodb_release}/mongodb-org/${mongodb_version}" amd64 http://repo.mongodb.org/apt/debian || return 1 ;;
        *) system_apt_repository_engine 0 mongodb "" deb "" "" "" || return 1 ;;
    esac
    system_apt_repository_engine "${SYSTEM_APT_NODEJS:-0}" nodesource \
        https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key deb nodistro amd64 https://deb.nodesource.com/node_24.x || return 1
    system_apt_repository_engine "${SYSTEM_APT_NVIDIA:-0}" nvidia \
        https://developer.download.nvidia.com/compute/cuda/repos/debian13/x86_64/8793F200.pub deb / amd64 https://developer.download.nvidia.com/compute/cuda/repos/debian13/x86_64/ "" || return 1
    system_apt_repository_engine "${SYSTEM_APT_NVIDIA:-0}" nvidia-container-toolkit \
        https://nvidia.github.io/libnvidia-container/gpgkey deb / amd64 https://nvidia.github.io/libnvidia-container/stable/deb/amd64/ "" || return 1
    system_apt_repository_engine "${SYSTEM_APT_PROXMOX:-0}" proxmox \
        https://enterprise.proxmox.com/debian/proxmox-release-trixie.gpg deb "${SYSTEM_DEBIAN_RELEASE}" "" http://download.proxmox.com/debian/pve pve-no-subscription || return 1
    system_apt_repository_engine "${SYSTEM_APT_VSCODE:-0}" vscode \
        https://packages.microsoft.com/keys/microsoft.asc deb stable amd64 https://packages.microsoft.com/repos/code || return 1
    system_apt_repository_engine "$wazuh_enable" wazuh \
        https://packages.wazuh.com/key/GPG-KEY-WAZUH deb stable amd64 https://packages.wazuh.com/4.x/apt || return 1
    system_apt_repository_engine "${SYSTEM_APT_WEBMIN:-0}" webmin \
        https://download.webmin.com/jcameron-key.asc deb sarge "" http://download.webmin.com/download/repository contrib || return 1
    if [[ "${SYSTEM_APT_CGPT:-0}" == 1 ]]; then
        system_apt_cgpt_configure || return 1
    else
        rm -f -- "$SYSTEM_APT_THIRD_PARTY_DIRECTORY/chatgpt.sources" "$SYSTEM_APT_THIRD_PARTY_DIRECTORY/chatgpt.list" \
            "$SYSTEM_APT_THIRD_PARTY_KEYRING_DIRECTORY/chatgpt-archive-keyring.gpg"
    fi
}

system_apt_cgpt_configure() {
    local keyring="$SYSTEM_APT_THIRD_PARTY_KEYRING_DIRECTORY/chatgpt-archive-keyring.gpg"
    install -d -m 0755 "$SYSTEM_APT_THIRD_PARTY_DIRECTORY" "$SYSTEM_APT_THIRD_PARTY_KEYRING_DIRECTORY" || return 1
    install -m 0644 "$SYSTEM_APT_CGPT_KEY_FILE" "$keyring" || return 1
    if system_apt_is_deb822; then
        rm -f -- "$SYSTEM_APT_THIRD_PARTY_DIRECTORY/chatgpt.list" || return 1
        cat > "$SYSTEM_APT_THIRD_PARTY_DIRECTORY/chatgpt.sources" <<EOF
### THIS FILE IS MANAGED BY DIU ###
X-Repolib-Name: ChatGPT
Types: deb
URIs: https://persistent.oaistatic.com/codex-app-prod/linux/deb
Suites: stable
Components: main
Architectures: amd64
Signed-By: $keyring
EOF
    else
        rm -f -- "$SYSTEM_APT_THIRD_PARTY_DIRECTORY/chatgpt.sources" || return 1
        printf 'deb [arch=amd64 signed-by=%s] %s stable main\n' "$keyring" \
            https://persistent.oaistatic.com/codex-app-prod/linux/deb > "$SYSTEM_APT_THIRD_PARTY_DIRECTORY/chatgpt.list"
    fi
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
        gpg inetutils-telnet iptables jq libpq5 lshw lsb-release man-db manpages-fr
        net-tools netcat-traditional nicstat openssl pciutils postgresql-client
        python3-pytest ripgrep shellcheck sudo tcpdump traceroute tree util-linux wget
        libsecret-tools
    )

    case "${SYSTEM_DEBIAN_ENVIRONNEMENT:-UNSET}" in
        LXC)
            prerequisites+=(acl)
            ;;
        PHYSICAL)
            prerequisites+=(acl)
            ;;
        VM)
            prerequisites+=(acl)
            ;;
        DOCKER)
            prerequisites+=(acl)
            ;;
        PROXMOX)
            # conntrack évite les erreurs de paramètres netfilter nf_conntrack.
            # glances permet de suivre les ressources de l'hyperviseur.
            prerequisites+=(acl conntrack glances rsync)
            ;;
    esac

    while IFS= read -r package; do
        if ! dpkg-query -W -f='${db:Status-Status}' "$package" 2>/dev/null |
            grep -qx installed; then
            print_info "Installation du prérequis : $package"
            if ! apt-get install -y -- "$package"; then
                print_error "Échec de l'installation du prérequis : $package"
                return 1
            fi
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
    system_apt_update || return $?
    system_flatpak_apply || return $?
    system_network_update
}

system_flatpak_package_state() {
    local status result

    command -v dpkg-query >/dev/null 2>&1 || {
        print_error "La commande dpkg-query est indisponible."
        return 1
    }
    result=0
    status="$(dpkg-query -W -f='${db:Status-Status}' flatpak 2>/dev/null)" || result=$?
    if [[ "$result" -eq 0 ]]; then
        [[ "$status" == installed ]] && printf '%s\n' installed || printf '%s\n' absent
        return 0
    fi
    if [[ "$result" -eq 1 ]]; then
        printf '%s\n' absent
        return 0
    fi
    print_error "Impossible de déterminer l'état du paquet Flatpak."
    return 1
}

system_flatpak_persist_state() {
    local value="$1" variable_config_file="${SYSTEM_FLATPAK_CONFIG_FILE:-/root/diu/config/system.env}"

    [[ "$value" =~ ^(0|1|UNSET)$ ]] || return 1
    install -d -m 0755 "$(dirname "$variable_config_file")"
    [[ -f "$variable_config_file" ]] && sed -i '/^export SYSTEM_FLATPAK=/d' "$variable_config_file"
    printf 'export SYSTEM_FLATPAK=%s\n' "$value" >> "$variable_config_file"
    export SYSTEM_FLATPAK="$value"
}

system_flatpak_ensure_installed() {
    local state

    state="$(system_flatpak_package_state)" || return 1
    if [[ "$state" == absent ]]; then
        apt-get install -y -- flatpak || return 1
    fi
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
}

system_flatpak_ensure_removed() {
    local state

    state="$(system_flatpak_package_state)" || return 1
    if [[ "$state" == absent ]]; then
        print_info "Flatpak est déjà absent."
        return 0
    fi
    apt-get remove -y -- flatpak
}

system_flatpak_apply() {
    case "${SYSTEM_FLATPAK:-UNSET}" in
        1) system_flatpak_ensure_installed ;;
        0) system_flatpak_ensure_removed ;;
        UNSET) print_info "Flatpak : état non défini, aucune action." ;;
        *) print_error "SYSTEM_FLATPAK : valeur invalide : ${SYSTEM_FLATPAK}"; return 2 ;;
    esac
}

system_flatpak_install() {
    system_flatpak_ensure_installed || return 1
    system_flatpak_persist_state 1
}

system_flatpak_remove() {
    system_flatpak_ensure_removed || return 1
    system_flatpak_persist_state 0
}

system_flatpak_update() {
    local state

    state="$(system_flatpak_package_state)" || return 1
    if [[ "$state" == absent ]]; then
        print_info "Flatpak est absent : aucune mise à jour à appliquer."
        return 0
    fi
    apt-get install --only-upgrade -y -- flatpak
}

system_apt_repository_variable() {
    case "${1,,}" in
        crowdsec|crodwsec) printf '%s' SOFTWARES_APT_CROWDSEC ;;
        docker) printf '%s' SYSTEM_APT_DOCKER ;;
        lemonldap|lemonldap-ng) printf '%s' SYSTEM_APT_LEMONLDAP ;;
        mongodb|mongodb-4|mongodb-5|mongodb-6|mongodb-7|mongodb-8) printf '%s' SYSTEM_APT_MONGODB ;;
        nodejs|node|nodesource) printf '%s' SYSTEM_APT_NODEJS ;;
        nvidia) printf '%s' SYSTEM_APT_NVIDIA ;;
        proxmox) printf '%s' SYSTEM_APT_PROXMOX ;;
        vscode|code) printf '%s' SYSTEM_APT_VSCODE ;;
        wazuh|wazuh-4) printf '%s' SYSTEM_APT_WAZUH ;;
        webmin) printf '%s' SYSTEM_APT_WEBMIN ;;
        cgpt|chatgpt|codex|openai) printf '%s' SYSTEM_APT_CGPT ;;
        *) return 1 ;;
    esac
}

system_apt_set_repository_variable() {
    local repository="$1" value="$2" variable_config_file="/root/diu/config/system.env"
    local current_line
    [[ "$repository" == SOFTWARES_APT_CROWDSEC ]] && variable_config_file="/root/diu/config/softwares.env"
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
    elif [[ "$variable" == SYSTEM_APT_MONGODB ]]; then
        case "${SYSTEM_APT_MONGODB:-0}" in
            4|5|6|7|8) value="$SYSTEM_APT_MONGODB" ;;
            *) value=8 ;;
        esac
    elif [[ "$requested" == wazuh-4 ]]; then
        value=4
    fi
    system_apt_set_repository_variable "$variable" "$value" || return 1
    system_apt_debian_configure
}

system_apt_remove_repository() {
    local requested="$1" variable
    variable="$(system_apt_repository_variable "$requested")" || {
        print_error "Dépôt APT non supporté : $requested"
        return 2
    }
    system_apt_set_repository_variable "$variable" 0 || return 1
    if [[ "$variable" == SYSTEM_APT_CGPT ]]; then
        rm -f -- "$SYSTEM_APT_THIRD_PARTY_DIRECTORY/chatgpt.sources" \
            "$SYSTEM_APT_THIRD_PARTY_DIRECTORY/chatgpt.list" \
            "$SYSTEM_APT_THIRD_PARTY_DIRECTORY/openai-codex.sources"
    fi
    system_apt_debian_configure
}

manage_system_action() {
    local action="${1:-}" repository=""
    case "$action" in
        network)
            shift
            if [[ $# -eq 1 && "$1" == update ]]; then
                system_network_update
            elif [[ $# -eq 2 && "$1" == hosts && "$2" == update ]]; then
                system_network_hosts
            else
                print_error 'Usage : rid system network {update|hosts update}'
                return 2
            fi
            ;;
        drivers)
            [[ $# -eq 3 && "${3:-}" == displaylink ]] || {
                print_error 'Usage : rid system drivers {install|remove} displaylink ; voir rid system drivers help'
                return 2
            }
            case "$2" in
                install) system_drivers_install_displaylink ;;
                remove) system_drivers_remove_displaylink ;;
                *) print_error 'Action pilote inconnue ; voir rid system drivers help'; return 2 ;;
            esac
            ;;
        infos)
            [[ $# -le 2 ]] || { print_error 'Usage : rid system infos [debian|drivers|network] ; voir rid system infos help'; return 2; }
            if [[ $# -eq 1 ]]; then
                system_info
                return
            fi
            case "$2" in
                network) system_info_network ;;
                debian) system_info_debian ;;
                drivers) system_info_drivers ;;
                *) print_error 'Information inconnue ; voir rid system infos help'; return 2 ;;
            esac
            ;;
        install|remove)
            if [[ "${2:-}" == flatpak && $# -eq 2 ]]; then
                if [[ "$action" == install ]]; then
                    system_flatpak_install
                else
                    system_flatpak_remove
                fi
                return
            fi
            [[ "${2:-}" == apt && $# -eq 3 ]] || {
                print_error "Usage : diu system ${action} {flatpak|apt <repository>}"
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
            if [[ "${1:-}" == flatpak && $# -eq 1 ]]; then
                system_flatpak_update
                return
            fi
            if [[ "${1:-}" == apt ]]; then
                shift
            fi
            case "${1:-}" in
                debian)
                    [[ $# -eq 1 ]] || { print_error "Usage : diu system update apt"; return 2; }
                    system_apt_update
                    ;;
                '') system_update ;;
                *) print_error "Usage : diu system update {flatpak|apt [debian]}"; return 2 ;;
            esac
            ;;
        apt)
            shift
            [[ "${1:-}" == update && $# -eq 1 ]] || { print_error "Usage : diu system apt update"; return 2; }
            system_apt_update
            ;;
        '') system_update ;;
        *) print_error "Usage : diu system {install|remove} {flatpak|apt <repository>} | update [flatpak|apt [debian]] | network {update|hosts update}"; return 2 ;;
    esac
}

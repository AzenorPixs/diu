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
    local status=0
    system_apt_regenerate || status=1
    echo "🔧 UPDATE & DIST-UPGRADE"
    if [[ "$status" == 0 ]]; then
        apt -y update && apt -q -y --allow-downgrades --allow-change-held-packages -f -m --show-progress dist-upgrade || status=1
    fi
    echo "🔧 CLEAN AND PURGE AND REMOVE"
    apt autoclean -y || status=1
    apt autopurge -y || status=1
    apt autoremove -y || status=1
    system_install_prerequisites || status=1
    return "$status"
}

system_update_package_versions() (
    set -o pipefail
    dpkg-query -W -f='${db:Status-Status}\t${binary:Package}\t${Version}\n' |
        awk -F '\t' '$1 == "installed" { print $2 "\t" $3 }' | LC_ALL=C sort
)

system_update_show_spinner() {
    local pid="$1" i=0 chars='|/-'
    while kill -0 "$pid" 2>/dev/null; do
        printf '\r%s Mise à jour du système Debian…' "${chars:i++%4:1}"
        sleep 0.2
    done
    printf '\r\033[K'
}

system_update_report_apt_softwares() {
    local before="$1" after="$2" directory file name variable packages package previous current found result=0
    directory="${BASH_SCRIPT_PATH:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)}/modules/diu/variables/softwares"
    for file in "$directory"/software_apt_*.sh; do
        [[ -f "$file" ]] || continue
        name="${file##*/software_apt_}"; name="${name%.sh}"
        [[ "$name" == codex_cli ]] && continue
        variable="SOFTWARES_APT_${name^^}"
        [[ "${!variable:-0}" == 1 ]] || continue
        case "$name" in
            chatgpt) packages='chatgpt'; name='ChatGPT' ;;
            crowdsec|crowdsec_agent) packages='crowdsec' ;;
            crowdsec_bouncer) packages='crowdsec-firewall-bouncer-iptables' ;;
            fastfetch) packages='fastfetch neofetch' ;;
            lemonldap) packages='lemonldap-ng' ;;
            mongodb) packages='mongodb-org' ;;
            omada) packages='omada' ;;
            openjdk) packages='openjdk-17-jre-headless openjdk-21-jre-headless' ;;
            openvswitch) packages='openvswitch-switch' ;;
            ssh_server) packages='openssh-server' ;;
            syslog_client|syslog_server) packages='rsyslog' ;;
            wazuh_server) packages='wazuh-manager wazuh-indexer wazuh-dashboard filebeat' ;;
            *) packages="${name//_/-}" ;;
        esac
        found=0
        for package in $packages; do
            current="$(awk -F '\t' -v p="$package" '$1 == p || index($1, p ":") == 1 {print $2; exit}' "$after")"
            [[ -n "$current" ]] || continue
            found=1
            previous="$(awk -F '\t' -v p="$package" '$1 == p || index($1, p ":") == 1 {print $2; exit}' "$before")"
            if [[ -n "$previous" && "$previous" != "$current" ]]; then
                printf '   • %s : %s → %s\n' "$name" "$previous" "$current"
            else
                printf '   • %s : %s\n' "$name" "$current"
            fi
        done
        if (( ! found )); then
            printf '   ⚠️  %s : version installée indisponible.\n' "$name"
            result=1
        fi
    done
    return "$result"
}

system_update_engine() {
    local selected="$1"
    local workdir status=0 apt_status=0 warning=0 version
    local before_codex='' after_codex='' engine label changed
    workdir="$(mktemp -d)" || { print_error 'Impossible de préparer le bilan de mise à jour.'; return 1; }
    version="$(cat /etc/debian_version 2>/dev/null)" || version='inconnue'
    if [[ "$selected" == apt ]] && ! system_update_package_versions > "$workdir/before"; then
        print_error 'Impossible de relever les versions initiales des paquets.'
        rm -rf -- "$workdir"
        return 1
    fi
    if [[ "$selected" == github && "${SOFTWARES_APT_CODEX_CLI:-0}" == 1 ]] && declare -F software_github_codex_cli_version >/dev/null; then
        before_codex="$(software_github_codex_cli_version 2>/dev/null)" || before_codex=''
    fi
    if [[ "$selected" == apt ]]; then
    local spinner_pid=''
    if [[ -t 1 ]]; then
        system_update_show_spinner "$BASHPID" &
        spinner_pid=$!
    else
        printf '%s\n' '⏳ Mise à jour du système Debian…'
    fi
    {
        if [[ "${SYSTEM_APT_ENGINE:-1}" == 1 ]]; then system_engine_ensure_dependencies apt || apt_status=$?; fi
        if (( apt_status == 0 )); then system_apt_update || apt_status=$?; fi
    } > "$workdir/apt.log" 2>&1 < /dev/null
    if [[ -n "$spinner_pid" ]]; then
        kill "$spinner_pid" 2>/dev/null || :
        wait "$spinner_pid" 2>/dev/null || :
        printf '\r\033[K'
    fi
    if ! system_update_package_versions > "$workdir/after"; then
        printf '%s\n' 'Impossible de relever les versions finales des paquets.' >> "$workdir/apt.log"
        apt_status=1
    fi
    if LC_ALL=C awk '
        $0 != "WARNING: apt does not have a stable CLI interface. Use with caution in scripts." &&
        tolower($0) ~ /^(w:|warning:|avertissement[ :])/ { found = 1 }
        END { exit !found }
    ' "$workdir/apt.log"; then warning=1; fi
    changed="$(awk -F '\t' 'NR==FNR {old[$1]=$2; next} ($1 in old) && old[$1] != $2 {printf "   • %s : %s → %s\n", $1, old[$1], $2}' "$workdir/before" "$workdir/after")"
    if (( apt_status != 0 )); then
        if [[ -n "$changed" ]]; then
            printf '⚠️  Système Debian %s : mise à jour partielle (code %s).\n' "$version" "$apt_status"
        else
            printf '❌ Système Debian %s : mise à jour échouée (code %s).\n' "$version" "$apt_status"
        fi
        cat "$workdir/apt.log"
        status=1
    elif (( warning )); then
        printf '⚠️  Système Debian %s : mise à jour avec avertissements.\n' "$version"
        cat "$workdir/apt.log"
        status=1
    else
        printf '✅ Système Debian %s à jour\n' "$version"
    fi
    [[ -z "$changed" ]] || printf '%s\n' "$changed"
    fi
    # Une seule phase, avec les mêmes branches de traitement que le parcours complet.
    # shellcheck disable=SC2066
    for engine in "$selected"; do
        local enabled
        case "$engine" in
            apt) enabled="${SYSTEM_APT_ENGINE:-1}"; label=APT ;;
            github) enabled="${SYSTEM_GITHUB_ENGINE:-0}"; label=GitHub ;;
            flatpak) enabled="${SYSTEM_FLATPAK_ENGINE:-UNSET}"; label=Flatpak ;;
        esac
        case "$enabled" in
            0) printf 'ℹ️  %s : moteur désactivé, dépendances conservées.\n' "$label"; continue ;;
            UNSET) printf 'ℹ️  %s : état non défini, aucune action.\n' "$label"; continue ;;
            1) ;;
            *) printf '❌ %s : état invalide.\n' "$label"; status=1; continue ;;
        esac
        if [[ "$engine" != apt ]] && ! system_engine_ensure_dependencies "$engine"; then
            printf '❌ %s : dépendances indisponibles.\n' "$label"
            if [[ "$engine" == github && "${SOFTWARES_APT_CODEX_CLI:-0}" == 1 ]]; then
                printf '   • Codex CLI : %s\n' "${before_codex:-version indisponible}"
            fi
            status=1
            continue
        fi
        if [[ "$engine" == flatpak ]] && ! flatpak remotes --system --columns=name | grep -Fxq flathub; then
            printf '❌ Flatpak : remote Flathub indisponible.\n'
            status=1
            continue
        fi
        if [[ "$engine" == apt && "$apt_status" != 0 ]]; then
            printf '⚠️  APT : vérification ou mise à jour échouée.\n'
        else
            printf '✅ %s : moteur activé, dépendances satisfaites.\n' "$label"
        fi
        case "$engine" in
            apt)
                system_update_report_apt_softwares "$workdir/before" "$workdir/after" || status=1 ;;
            github)
                if [[ "${SOFTWARES_APT_CODEX_CLI:-0}" == 1 && "${DIU_UPDATE_DEFER_SOFTWARES:-0}" != 1 ]]; then
                    if ! software_github_codex_cli_update > "$workdir/codex.log"; then
                        cat "$workdir/codex.log"
                        printf '%s\n' '   ❌ Codex CLI : mise à jour échouée.'
                        status=1
                    fi
                    after_codex="$(software_github_codex_cli_version 2>/dev/null)" || after_codex=''
                    if [[ -z "$after_codex" ]]; then printf '%s\n' '   ❌ Codex CLI : version indisponible.'; status=1
                    elif [[ -n "$before_codex" && "$before_codex" != "$after_codex" ]]; then printf '   • Codex CLI : %s → %s\n' "$before_codex" "$after_codex"
                    else printf '   • Codex CLI : %s\n' "$after_codex"; fi
                fi ;;
        esac
    done
    rm -rf -- "$workdir"
    return "$status"
}


system_engines_update() {
    local status=0 engine
    for engine in apt github flatpak; do
        system_update_engine "$engine" || status=1
    done
    return "$status"
}

system_update() {
    local status=0
    system_engines_update || status=1
    system_network_update || status=1
    return "$status"
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
    local value="$1" variable_config_file="${SYSTEM_FLATPAK_ENGINE_CONFIG_FILE:-${SYSTEM_FLATPAK_CONFIG_FILE:-/root/diu/config/system.env}}"

    [[ "$value" =~ ^(0|1|UNSET)$ ]] || return 1
    install -d -m 0755 "$(dirname "$variable_config_file")"
    [[ -f "$variable_config_file" ]] && sed -i '/^export SYSTEM_FLATPAK_ENGINE=/d' "$variable_config_file"
    printf 'export SYSTEM_FLATPAK_ENGINE=%s\n' "$value" >> "$variable_config_file"
    export SYSTEM_FLATPAK_ENGINE="$value"
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
    case "${SYSTEM_FLATPAK_ENGINE:-UNSET}" in
        1) system_flatpak_ensure_installed ;;
        0) print_info "Flatpak : moteur désactivé, dépendances conservées." ;;
        UNSET) print_info "Flatpak : état non défini, aucune action." ;;
        *) print_error "SYSTEM_FLATPAK_ENGINE : valeur invalide : ${SYSTEM_FLATPAK_ENGINE}"; return 2 ;;
    esac
}

system_flatpak_install() {
    system_flatpak_ensure_installed || return 1
    system_flatpak_persist_state 1
}

system_flatpak_remove() {
    system_flatpak_persist_state 0
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

system_engine_persist() {
    local variable="$1" value="$2" config_file="${SYSTEM_ENGINE_CONFIG_FILE:-/root/diu/config/system.env}" temporary
    [[ "$variable" =~ ^SYSTEM_(APT|GITHUB|FLATPAK)_ENGINE$ && "$value" =~ ^[01]$ ]] || return 2
    install -d -m 0755 "$(dirname "$config_file")" || return 1
    [[ ! -L "$config_file" ]] || { print_error 'Configuration système symbolique refusée.'; return 1; }
    temporary="$(mktemp "${config_file}.XXXXXX")" || return 1
    if [[ -f "$config_file" ]]; then
        if ! sed "/^export ${variable}=/d" "$config_file" > "$temporary" || ! chmod --reference="$config_file" "$temporary"; then
            rm -f -- "$temporary"; return 1
        fi
    elif ! chmod 0644 "$temporary"; then
        rm -f -- "$temporary"; return 1
    fi
    if ! printf 'export %s=%s\n' "$variable" "$value" >> "$temporary" || ! mv -f -- "$temporary" "$config_file"; then
        rm -f -- "$temporary"; return 1
    fi
    printf -v "$variable" '%s' "$value"
    export "${variable?}"
}

system_engine_ensure_dependencies() {
    local engine="$1" package command_name state
    local -a packages=() commands=()
    case "$engine" in
        apt) packages=(apt apt-transport-https apt-utils dpkg); commands=(apt dpkg-query) ;;
        github) packages=(curl jq tar gzip coreutils); commands=(curl jq tar gzip sha256sum) ;;
        flatpak) system_flatpak_ensure_installed; return $? ;;
        *) print_error "Moteur inconnu : $engine"; return 2 ;;
    esac
    command -v dpkg-query >/dev/null 2>&1 || { print_error 'dpkg-query est nécessaire pour contrôler les dépendances.'; return 1; }
    for package in "${packages[@]}"; do
        local query_result=0
        state="$(dpkg-query -W -f='${db:Status-Status}' "$package" 2>/dev/null)" || query_result=$?
        if (( query_result > 1 )); then
            print_error "Impossible de contrôler la dépendance : $package"
            return 1
        fi
        if [[ "$state" != installed ]]; then
            apt-get install -y -- "$package" || { print_error "Installation impossible : $package"; return 1; }
            if ! state="$(dpkg-query -W -f='${db:Status-Status}' "$package" 2>/dev/null)" || [[ "$state" != installed ]]; then
                print_error "Dépendance non installée après installation : $package"
                return 1
            fi
        fi
    done
    for command_name in "${commands[@]}"; do
        command -v "$command_name" >/dev/null 2>&1 || { print_error "Dépendance indisponible : $command_name"; return 1; }
    done
}

system_engine_action() {
    local action="$1" engine="$2" variable
    case "$engine" in
        apt) variable=SYSTEM_APT_ENGINE ;;
        github) variable=SYSTEM_GITHUB_ENGINE ;;
        flatpak) variable=SYSTEM_FLATPAK_ENGINE ;;
        *) print_error "Moteur inconnu : $engine"; return 2 ;;
    esac
    case "$action" in
        install) system_engine_ensure_dependencies "$engine" || return $?; system_engine_persist "$variable" 1 ;;
        remove) system_engine_persist "$variable" 0 ;;
        *) print_error "Action moteur inconnue : $action"; return 2 ;;
    esac
}

manage_system_action() {
    local action="${1:-}" repository=""
    case "$action" in
        engine)
            case "${2:-}" in
                update)
                    [[ $# -eq 2 ]] || { print_error 'Usage : diu system engine update'; return 2; }
                    system_engines_update ;;
                apt|github|flatpak)
                    [[ $# -eq 3 && "$3" == update ]] || { print_error "Usage : diu system engine $2 update"; return 2; }
                    system_update_engine "$2" ;;
                install|remove)
                    [[ $# -eq 3 ]] || { print_error 'Usage : diu system engine {install|remove} {apt|github|flatpak}'; return 2; }
                    system_engine_action "$2" "$3" ;;
                *) print_error 'Usage : diu system engine {update|apt update|github update|flatpak update|install|remove}'; return 2 ;;
            esac
            ;;
        network)
            shift
            if [[ $# -eq 1 && "$1" == update ]]; then
                system_network_update
            elif [[ "${1:-}" == hosts ]]; then
                shift
                if [[ $# -eq 0 ]]; then
                    cat /etc/hosts
                elif [[ $# -eq 1 && "$1" == update ]]; then
                    system_network_hosts_report
                elif [[ "${1:-}" == add || "${1:-}" == del || "${1:-}" == list ]]; then
                    system_network_manage_hosts "$@"
                else
                    print_error 'Usage : diu system network hosts {update|add IP FQDN|del IP FQDN|del all|list}'
                    return 2
                fi
            else
                print_error 'Usage : diu system network {update|hosts {update|add IP FQDN|del IP FQDN|del all|list}}'
                return 2
            fi
            ;;
        drivers)
            [[ $# -eq 3 && "${3:-}" == displaylink ]] || {
                print_error 'Usage : diu system drivers {install|remove} displaylink ; voir diu system drivers help'
                return 2
            }
            case "$2" in
                install) system_drivers_install_displaylink ;;
                remove) system_drivers_remove_displaylink ;;
                *) print_error 'Action pilote inconnue ; voir diu system drivers help'; return 2 ;;
            esac
            ;;
        infos)
            [[ $# -le 2 ]] || { print_error 'Usage : diu system infos [debian|drivers|network] ; voir diu system infos help'; return 2; }
            if [[ $# -eq 1 ]]; then
                system_info
                return
            fi
            case "$2" in
                network) system_info_network ;;
                debian) system_info_debian ;;
                drivers) system_info_drivers ;;
                *) print_error 'Information inconnue ; voir diu system infos help'; return 2 ;;
            esac
            ;;
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
            [[ $# -eq 1 ]] || { print_error 'Usage : diu system update'; return 2; }
            system_update
            ;;
        '') system_update ;;
        *) print_error "Usage : diu system {update|engine|network update}"; return 2 ;;
    esac
}

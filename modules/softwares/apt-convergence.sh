#!/usr/bin/env bash

# Catalogue volontairement explicite : aucune commande n'est construite depuis la CLI.
software_apt_convergence_package() {
    local release
    case "${1:-}" in
        apache2) printf '%s\n' apache2 ;;
        chatgpt) printf '%s\n' chatgpt ;;
        crowdsec-agent) printf '%s\n' crowdsec ;;
        crowdsec-bouncer) printf '%s\n' crowdsec-firewall-bouncer-iptables ;;
        fastfetch)
            release="$(software_apt_effective_release /etc/os-release)" || return 1
            case "$release" in
                bullseye|bookworm) printf '%s\n' neofetch ;;
                trixie) printf '%s\n' fastfetch ;;
                *) printf '%s\n' 'Version Debian non prise en charge pour Fastfetch.' >&2; return 1 ;;
            esac ;;
        jsvc) printf '%s\n' jsvc ;;
        lemonldap) printf '%s\n' lemonldap-ng ;;
        mongodb) printf '%s\n' mongodb-org ;;
        omada) printf '%s\n' omadac ;;
        openjdk)
            release="$(software_apt_effective_release /etc/os-release)" || return 1
            case "$release" in
                bullseye|bookworm) printf '%s\n' openjdk-17-jre-headless ;;
                trixie) printf '%s\n' openjdk-21-jre-headless ;;
                *) printf '%s\n' 'Version Debian non prise en charge pour OpenJDK.' >&2; return 1 ;;
            esac ;;
        openvswitch) printf '%s\n' openvswitch-switch ;;
        postfix) printf '%s\n' postfix ;;
        postgresql) printf '%s\n' postgresql ;;
        qemu-guest-agent) printf '%s\n' qemu-guest-agent ;;
        ssh-server) printf '%s\n' openssh-server ;;
        syslog-client|syslog-server) printf '%s\n' rsyslog ;;
        syncthing) printf '%s\n' syncthing ;;
        wazuh-agent) printf '%s\n' wazuh-agent ;;
        wazuh-server) printf '%s\n' wazuh-manager ;;
        webmin) printf '%s\n' webmin ;;
        zoom) printf '%s\n' zoom ;;
        zsh) printf '%s\n' zsh ;;
        *) printf 'Logiciel APT non déclaré : %s\n' "${1:-}" >&2; return 1 ;;
    esac
}

software_apt_convergence_variable() {
    case "${1:-}" in
        apache2) printf '%s\n' SOFTWARE_APT_APACHE2 ;;
        chatgpt) printf '%s\n' SOFTWARE_APT_CHATGPT ;;
        crowdsec-agent) printf '%s\n' SOFTWARE_APT_CROWDSEC_AGENT ;;
        crowdsec-bouncer) printf '%s\n' SOFTWARE_APT_CROWDSEC_BOUNCER ;;
        fastfetch) printf '%s\n' SOFTWARE_APT_FASTFETCH ;;
        jsvc) printf '%s\n' SOFTWARE_APT_JSVC ;;
        lemonldap) printf '%s\n' SOFTWARE_APT_LEMONLDAP ;;
        mongodb) printf '%s\n' SOFTWARE_APT_MONGODB ;;
        omada) printf '%s\n' SOFTWARE_APT_OMADA ;;
        openjdk) printf '%s\n' SOFTWARE_APT_OPENJDK ;;
        openvswitch) printf '%s\n' SOFTWARE_APT_OPENVSWITCH ;;
        postfix) printf '%s\n' SOFTWARE_APT_POSTFIX ;;
        postgresql) printf '%s\n' SOFTWARE_APT_POSTGRESQL ;;
        qemu-guest-agent) printf '%s\n' SOFTWARE_APT_QEMU_GUEST_AGENT ;;
        ssh-server) printf '%s\n' SOFTWARE_APT_SSH_SERVER ;;
        syslog-client) printf '%s\n' SOFTWARE_APT_SYSLOG_CLIENT ;;
        syslog-server) printf '%s\n' SOFTWARE_APT_SYSLOG_SERVER ;;
        syncthing) printf '%s\n' SOFTWARE_APT_SYNCTHING ;;
        wazuh-agent) printf '%s\n' SOFTWARE_APT_WAZUH_AGENT ;;
        wazuh-server) printf '%s\n' SOFTWARE_APT_WAZUH_SERVER ;;
        webmin) printf '%s\n' SOFTWARE_APT_WEBMIN ;;
        zoom) printf '%s\n' SOFTWARE_APT_ZOOM ;;
        zsh) printf '%s\n' SOFTWARE_APT_ZSH ;;
        *) printf 'Logiciel APT non déclaré : %s\n' "${1:-}" >&2; return 1 ;;
    esac
}

software_apt_convergence_names() {
    printf '%s\n' apache2 chatgpt crowdsec-agent crowdsec-bouncer fastfetch jsvc lemonldap mongodb omada openjdk openvswitch postfix postgresql qemu-guest-agent ssh-server syncthing syslog-client syslog-server wazuh-agent wazuh-server webmin zoom zsh
}

software_apt_convergence_install_options() {
    case "${1:-}" in
        webmin) printf '%s\n' --install-recommends ;;
        apache2|chatgpt|crowdsec-agent|crowdsec-bouncer|fastfetch|jsvc|lemonldap|mongodb|omada|openjdk|openvswitch|postfix|postgresql|qemu-guest-agent|ssh-server|syncthing|syslog-client|syslog-server|wazuh-agent|wazuh-server|zoom|zsh) printf '\n' ;;
        *) return 1 ;;
    esac
}

software_apt_convergence_remove_action() {
    case "${1:-}" in
        webmin|wazuh-agent) printf '%s\n' purge ;;
        apache2|chatgpt|crowdsec-agent|crowdsec-bouncer|fastfetch|jsvc|lemonldap|mongodb|omada|openjdk|openvswitch|postfix|postgresql|qemu-guest-agent|ssh-server|syncthing|syslog-client|syslog-server|wazuh-server|zoom|zsh) printf '%s\n' remove ;;
        *) return 1 ;;
    esac
}

software_apt_convergence_install_packages() {
    local software="${1:-}" perl_package
    case "$software" in
        apache2)
            case "${SYSTEM_DEBIAN_RELEASE:-}" in
                bullseye) perl_package=perl-modules-5.32 ;;
                bookworm) perl_package=perl-modules-5.36 ;;
                trixie) perl_package=perl-modules-5.40 ;;
                *) printf '%s\n' 'Version Debian non prise en charge pour Apache2.' >&2; return 1 ;;
            esac
            printf '%s\n' apache2 libapache2-mod-perl2 libapache2-mod-fcgid libapache-session-perl "$perl_package" \
                libnet-ldap-perl libcache-cache-perl libdbi-perl libwww-perl libxml-simple-perl libsoap-lite-perl \
                libhtml-template-perl libregexp-assemble-perl libregexp-common-perl libjs-jquery libxml-libxml-perl \
                libcrypt-rijndael-perl libio-string-perl libxml-libxslt-perl libconfig-inifiles-perl libjson-perl \
                libstring-random-perl libemail-date-format-perl libmime-lite-perl libcrypt-openssl-rsa-perl \
                libdigest-hmac-perl libdigest-sha-perl libclone-perl libauthen-sasl-perl libnet-cidr-lite-perl \
                libcrypt-openssl-x509-perl libauthcas-perl libtest-pod-perl libtest-mockobject-perl \
                libauthen-captcha-perl libnet-openid-consumer-perl libnet-openid-server-perl libunicode-string-perl \
                libconvert-pem-perl libmoose-perl libplack-perl libapache-session-browseable-perl libdbd-pg-perl libgssapi-perl
            ;;
        lemonldap) printf '%s\n' lemonldap-ng lemonldap-ng-doc liblasso-perl krb5-user ;;
        crowdsec-agent) printf '%s\n' crowdsec crowdsec-firewall-bouncer-iptables ;;
        syslog-client|syslog-server) printf '%s\n' rsyslog ulogd2 ;;
        wazuh-server) printf '%s\n' debhelper tar curl libcap2-bin wazuh-indexer wazuh-manager filebeat wazuh-dashboard ;;
        zsh) printf '%s\n' zsh zsh-autosuggestions zsh-syntax-highlighting fish fzf tmux zoxide ;;
        *) software_apt_convergence_package "$software" ;;
    esac
}

software_apt_missing_install_packages() {
    local software="${1:-}" packages rows name state base package
    local -A states=()
    packages="$(software_apt_convergence_install_packages "$software")" || return 2
    if ! rows="$(dpkg-query -W -f='${binary:Package}\t${db:Status-Status}\n')"; then
        printf '%s\n' 'État des paquets Debian indisponible.' >&2
        return 2
    fi
    while IFS=$'\t' read -r name state; do
        [[ -n "$name" ]] || continue
        if [[ ! "$name" =~ ^[a-z0-9][a-z0-9+.-]+(:[a-z0-9][a-z0-9-]*)?$ ]]; then
            printf '%s\n' 'Nom de paquet Debian non vérifiable.' >&2
            return 2
        fi
        base="${name%%:*}"
        case "$state" in
            installed) [[ "${states[$base]:-}" == partial ]] || states["$base"]=installed ;;
            not-installed|config-files) ;;
            *) states["$base"]=partial ;;
        esac
    done <<< "$rows"
    while IFS= read -r package; do
        [[ "$package" =~ ^[a-z0-9][a-z0-9+.-]+$ ]] || return 2
        if [[ "${states[$package]:-}" == partial ]]; then
            printf 'État Debian incomplet pour %s.\n' "$package" >&2
            return 2
        fi
        [[ "${states[$package]:-}" == installed ]] || printf '%s\n' "$package"
    done <<< "$packages"
}

software_apt_convergence_repository() {
    local version
    case "${1:-}" in
        chatgpt) printf '%s\n' cgpt ;;
        crowdsec-agent|crowdsec-bouncer) printf '%s\n' crowdsec ;;
        lemonldap) printf '%s\n' lemonldap ;;
        mongodb) version="$(software_apt_mongodb_repository_version)" || return 1; printf 'mongodb-%s\n' "$version" ;;
        wazuh-server) printf '%s\n' wazuh-4 ;;
        webmin) printf '%s\n' webmin ;;
        apache2|fastfetch|jsvc|omada|openjdk|openvswitch|postfix|postgresql|qemu-guest-agent|ssh-server|syncthing|syslog-client|syslog-server|wazuh-agent|zoom|zsh) printf '\n' ;;
        *) printf 'Logiciel APT non déclaré : %s\n' "${1:-}" >&2; return 1 ;;
    esac
}

software_apt_convergence_repository_variable() {
    case "${1:-}" in
        chatgpt) printf '%s\n' SYSTEM_APT_CGPT ;;
        crowdsec-agent|crowdsec-bouncer) printf '%s\n' SOFTWARE_APT_CROWDSEC ;;
        lemonldap) printf '%s\n' SYSTEM_APT_LEMONLDAP ;;
        mongodb) printf '%s\n' SYSTEM_APT_MONGODB ;;
        wazuh-server) printf '%s\n' SYSTEM_APT_WAZUH ;;
        webmin) printf '%s\n' SYSTEM_APT_WEBMIN ;;
        apache2|fastfetch|jsvc|omada|openjdk|openvswitch|postfix|postgresql|qemu-guest-agent|ssh-server|syncthing|syslog-client|syslog-server|wazuh-agent|zoom|zsh) printf '\n' ;;
        *) printf 'Logiciel APT non déclaré : %s\n' "${1:-}" >&2; return 1 ;;
    esac
}

software_apt_mongodb_repository_version() {
    local version="${SYSTEM_APT_MONGODB:-0}"
    case "$version" in
        4|5|6|7|8) ;;
        0)
            version="${MONGODB_VERSION:-}"
            case "$version" in
                4|4.0|4.4|5|5.0|6|6.0|7|7.0|8|8.0) version="${version%%.*}" ;;
                *) printf '%s\n' 'Version de dépôt MongoDB invalide.' >&2; return 1 ;;
            esac ;;
        *) printf '%s\n' 'État du dépôt MongoDB invalide.' >&2; return 1 ;;
    esac
    printf '%s\n' "$version"
}

software_apt_convergence_repository_state_valid() {
    local software="${1:-}" state="${2:-}"
    case "$software" in
        mongodb) [[ "$state" =~ ^(0|4|5|6|7|8)$ ]] ;;
        wazuh-server) [[ "$state" == 0 || "$state" == 4 ]] ;;
        chatgpt|crowdsec-agent|crowdsec-bouncer|lemonldap|webmin) [[ "$state" == 0 || "$state" == 1 ]] ;;
        *) return 1 ;;
    esac
}

software_apt_convergence_repository_expected() {
    case "${1:-}" in
        mongodb) software_apt_mongodb_repository_version ;;
        wazuh-server) printf '4\n' ;;
        chatgpt|crowdsec-agent|crowdsec-bouncer|lemonldap|webmin) printf '1\n' ;;
        apache2|fastfetch|jsvc|omada|openjdk|openvswitch|postfix|postgresql|qemu-guest-agent|ssh-server|syncthing|syslog-client|syslog-server|wazuh-agent|zoom|zsh) printf '\n' ;;
        *) return 1 ;;
    esac
}

software_apt_convergence_remove_repository() {
    case "${1:-}" in
        chatgpt) printf '1\n' ;;
        apache2|crowdsec-agent|crowdsec-bouncer|fastfetch|jsvc|lemonldap|mongodb|omada|openjdk|openvswitch|postfix|postgresql|qemu-guest-agent|ssh-server|syncthing|syslog-client|syslog-server|wazuh-agent|wazuh-server|webmin|zoom|zsh) printf '0\n' ;;
        *) return 1 ;;
    esac
}

software_apt_convergence_detector() {
    case "${1:-}" in
        apache2) printf '%s\n' software_apt_apache2_detect ;;
        chatgpt) printf '%s\n' software_apt_chatgpt_real_state ;;
        crowdsec-agent) printf '%s\n' software_apt_crowdsec_agent_detect ;;
        crowdsec-bouncer) printf '%s\n' software_apt_crowdsec_bouncer_role_detect ;;
        fastfetch) printf '%s\n' software_apt_fastfetch_detect ;;
        jsvc) printf '%s\n' software_apt_jsvc_detect ;;
        lemonldap) printf '%s\n' software_apt_lemonldap_detect ;;
        mongodb) printf '%s\n' software_apt_mongodb_detect ;;
        omada) printf '%s\n' software_apt_omada_detect ;;
        openjdk) printf '%s\n' software_apt_openjdk_detect ;;
        openvswitch) printf '%s\n' software_apt_openvswitch_detect ;;
        postfix) printf '%s\n' software_apt_postfix_detect ;;
        postgresql) printf '%s\n' software_apt_postgresql_detect ;;
        qemu-guest-agent) printf '%s\n' software_apt_qemu_guest_agent_detect ;;
        ssh-server) printf '%s\n' software_apt_ssh_server_detect ;;
        syslog-client) printf '%s\n' software_apt_syslog_client_detect ;;
        syslog-server) printf '%s\n' software_apt_syslog_server_detect ;;
        syncthing) printf '%s\n' software_apt_syncthing_detect ;;
        wazuh-agent) printf '%s\n' software_apt_wazuh_agent_detect ;;
        wazuh-server) printf '%s\n' software_apt_wazuh_server_detect ;;
        webmin) printf '%s\n' software_apt_webmin_detect ;;
        zoom) printf '%s\n' software_apt_zoom_detect ;;
        zsh) printf '%s\n' software_apt_zsh_detect ;;
        *) printf 'Logiciel APT non déclaré : %s\n' "${1:-}" >&2; return 1 ;;
    esac
}

software_apt_convergence_detect() {
    local detector
    detector="$(software_apt_convergence_detector "${1:-}")" || return 1
    if [[ ! "$detector" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] || ! declare -F "$detector" >/dev/null; then
        printf '%s\n' 'Détecteur APT indisponible.' >&2
        return 1
    fi
    "$detector"
}

software_apt_convergence_artifact_url() {
    local version
    case "${1:-}" in
        omada)
            version="${OMADA_VERSION:-}"
            [[ "$version" =~ ^[0-9][A-Za-z0-9._+-]*$ ]] || { printf '%s\n' 'Version Omada invalide.' >&2; return 1; }
            printf 'https://ota-download.tplinkcloud.com/firmware/omada_v%s.deb\n' "$version"
            ;;
        zoom) printf '%s\n' 'https://zoom.us/client/latest/zoom_amd64.deb' ;;
        wazuh-agent)
            version="${WAZUH_CLIENT_VERSION:-}"
            [[ "$version" =~ ^[0-9][A-Za-z0-9.+~-]*$ ]] || { printf '%s\n' 'Version Wazuh agent invalide.' >&2; return 1; }
            printf 'https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_%s_amd64.deb\n' "$version"
            ;;
        apache2|chatgpt|crowdsec-agent|crowdsec-bouncer|fastfetch|jsvc|lemonldap|mongodb|openjdk|openvswitch|postfix|postgresql|qemu-guest-agent|ssh-server|syncthing|syslog-client|syslog-server|wazuh-server|webmin|zsh) printf '\n' ;;
        *) return 1 ;;
    esac
}

software_apt_fetch_artifact() {
    local url="${1:-}" expected="${2:-}" directory="${3:-}" actual architecture system_architecture
    [[ "$url" == https://* && "$expected" =~ ^[a-z0-9][a-z0-9+.-]+$ && -d "$directory" ]] || return 2
    curl --fail --silent --show-error --location "$url" -o "$directory/package.deb" || return 1
    actual="$(dpkg-deb -f "$directory/package.deb" Package)" || return 1
    architecture="$(dpkg-deb -f "$directory/package.deb" Architecture)" || return 1
    system_architecture="$(dpkg --print-architecture)" || return 1
    if [[ "$actual" != "$expected" || ( "$architecture" != all && "$architecture" != "$system_architecture" ) ]]; then
        printf '%s\n' 'Paquet téléchargé incompatible ou inattendu.' >&2
        return 1
    fi
    printf '%s\n' "$directory/package.deb"
}

software_apt_install_artifact() (
    local url="${1:-}" expected="${2:-}" environment_hook="${3:-}" sensitive="${4:-0}" temporary='' artifact
    shift 4
    [[ "$sensitive" == 0 || "$sensitive" == 1 ]] || return 2
    temporary="$(mktemp -d)" || return 1
    [[ -n "$temporary" && -d "$temporary" ]] || return 1
    trap 'rm -rf -- "$temporary"' EXIT
    artifact="$(software_apt_fetch_artifact "$url" "$expected" "$temporary")" || return $?
    if [[ -n "$environment_hook" ]]; then
        if [[ ! "$environment_hook" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] || ! declare -F "$environment_hook" >/dev/null; then return 1; fi
        "$environment_hook" || return 1
    fi
    if [[ "$sensitive" == 1 ]]; then
        if ! apt -y install --no-upgrade "$@" -- "$artifact" >/dev/null 2>&1; then
            printf '%s\n' 'Installation du paquet avec paramètres sensibles échouée.' >&2
            return 1
        fi
    else
        apt -y install --no-upgrade "$@" -- "$artifact"
    fi
)

software_apt_convergence_external_names() {
    printf '%s\n' omada wazuh-agent zoom
}

software_apt_convergence_environment_hook() {
    case "${1:-}" in
        wazuh-agent) printf '%s\n' software_apt_prepare_wazuh_agent_environment ;;
        *) software_apt_convergence_variable "${1:-}" >/dev/null || return 1; printf '\n' ;;
    esac
}

software_apt_convergence_sensitive_install() {
    case "${1:-}" in
        wazuh-agent) printf '1\n' ;;
        *) software_apt_convergence_variable "${1:-}" >/dev/null || return 1; printf '0\n' ;;
    esac
}

software_apt_convergence_pre_install_hook() {
    case "${1:-}" in
        crowdsec-agent|crowdsec-bouncer) printf '%s\n' software_apt_preflight_crowdsec ;;
        syslog-client) printf '%s\n' software_apt_preflight_syslog_client ;;
        syslog-server) printf '%s\n' software_apt_preflight_syslog_server ;;
        openjdk) printf '%s\n' software_apt_preflight_openjdk ;;
        postfix) printf '%s\n' software_apt_preflight_postfix ;;
        ssh-server) printf '%s\n' software_apt_preflight_ssh_server ;;
        zsh) printf '%s\n' software_apt_preflight_zsh ;;
        *) software_apt_convergence_variable "${1:-}" >/dev/null || return 1; printf '\n' ;;
    esac
}

software_apt_install() {
    local package package_list repository repository_variable repository_expected repository_state option option_list artifact_url environment_hook sensitive missing pre_install
    local -a packages=() options=()
    package_list="$(software_apt_convergence_install_packages "${1:-}")" || return 1
    while IFS= read -r package; do
        [[ "$package" =~ ^[a-z0-9][a-z0-9+.-]+$ ]] || return 1
        packages+=("$package")
    done <<< "$package_list"
    (( ${#packages[@]} > 0 )) || return 1
    if [[ "${software_convergence_actual:-0}" == 1 ]]; then
        missing="$(software_apt_missing_install_packages "${1:-}")" || return 1
        if [[ -z "$missing" ]]; then
            software_apt_apply_configuration "${1:-}"
            return $?
        fi
    fi
    option_list="$(software_apt_convergence_install_options "${1:-}")" || return 1
    while IFS= read -r option; do
        [[ -n "$option" ]] || continue
        [[ "$option" == --install-recommends ]] || return 1
        options+=("$option")
    done <<< "$option_list"
    repository="$(software_apt_convergence_repository "${1:-}")" || return 1
    repository_variable="$(software_apt_convergence_repository_variable "${1:-}")" || return 1
    repository_expected="$(software_apt_convergence_repository_expected "${1:-}")" || return 1
    artifact_url="$(software_apt_convergence_artifact_url "${1:-}")" || return 1
    environment_hook="$(software_apt_convergence_environment_hook "${1:-}")" || return 1
    sensitive="$(software_apt_convergence_sensitive_install "${1:-}")" || return 1
    pre_install="$(software_apt_convergence_pre_install_hook "${1:-}")" || return 1
    if [[ -n "$pre_install" ]]; then
        if [[ ! "$pre_install" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] || ! declare -F "$pre_install" >/dev/null; then return 1; fi
        "$pre_install" || return 1
    fi
    if [[ -n "$environment_hook" ]]; then
        if [[ ! "$environment_hook" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] || ! declare -F "$environment_hook" >/dev/null; then return 1; fi
        ( "$environment_hook" ) || return 1
    fi
    if [[ -n "$repository" && -n "$repository_variable" ]]; then
        if [[ -v "$repository_variable" ]]; then repository_state="${!repository_variable}"; else repository_state=0; fi
        if ! software_apt_convergence_repository_state_valid "${1:-}" "$repository_state"; then
            printf '%s\n' 'État du dépôt APT invalide.' >&2
            return 1
        fi
        if [[ "$repository_state" != "$repository_expected" ]]; then
            if ! declare -F system_apt_install_repository >/dev/null; then
                printf '%s\n' 'Moteur de dépôts APT indisponible.' >&2
                return 1
            fi
            system_apt_install_repository "$repository" || return 1
            apt -y update || return 1
        fi
    fi
    if [[ -n "$artifact_url" ]]; then
        [[ "${#packages[@]}" == 1 ]] || return 1
        software_apt_install_artifact "$artifact_url" "${packages[0]}" "$environment_hook" "$sensitive" "${options[@]}" || return 1
    else
        apt -y install --no-upgrade "${options[@]}" -- "${packages[@]}" || return 1
    fi
    software_apt_apply_configuration "${1:-}"
}

software_apt_apply_configuration() {
    local hook
    hook="$(software_apt_convergence_configuration_hook "${1:-}")" || return 1
    if [[ -n "$hook" ]]; then
        if [[ ! "$hook" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] || ! declare -F "$hook" >/dev/null; then
            printf '%s\n' 'Configuration logicielle APT indisponible.' >&2
            return 1
        fi
        "$hook" || return 1
    fi
}

software_apt_convergence_configuration_hook() {
    case "${1:-}" in
        crowdsec-agent) printf '%s\n' software_apt_configure_crowdsec_agent ;;
        crowdsec-bouncer) printf '%s\n' software_apt_configure_crowdsec_bouncer ;;
        fastfetch) printf '%s\n' software_apt_configure_fastfetch ;;
        mongodb) printf '%s\n' software_apt_configure_mongodb ;;
        wazuh-agent) printf '%s\n' software_apt_configure_wazuh_agent ;;
        openjdk) printf '%s\n' software_apt_configure_openjdk ;;
        postfix) printf '%s\n' software_apt_configure_postfix ;;
        ssh-server) printf '%s\n' software_apt_configure_ssh_server ;;
        syslog-client) printf '%s\n' software_apt_configure_syslog_client ;;
        syslog-server) printf '%s\n' software_apt_configure_syslog_server ;;
        zsh) printf '%s\n' software_apt_configure_zsh ;;
        apache2|chatgpt|jsvc|lemonldap|omada|openvswitch|postgresql|qemu-guest-agent|syncthing|wazuh-server|webmin|zoom) printf '\n' ;;
        *) return 1 ;;
    esac
}

software_apt_convergence_configuration_check() {
    case "${1:-}" in
        crowdsec-agent) printf '%s\n' software_apt_check_crowdsec_agent_configuration ;;
        crowdsec-bouncer) printf '%s\n' software_apt_check_crowdsec_bouncer_configuration ;;
        fastfetch) printf '%s\n' software_apt_check_fastfetch_configuration ;;
        mongodb) printf '%s\n' software_apt_check_mongodb_configuration ;;
        wazuh-agent) printf '%s\n' software_apt_check_wazuh_agent_configuration ;;
        openjdk) printf '%s\n' software_apt_check_openjdk_configuration ;;
        postfix) printf '%s\n' software_apt_check_postfix_configuration ;;
        ssh-server) printf '%s\n' software_apt_check_ssh_server_configuration ;;
        syslog-client) printf '%s\n' software_apt_check_syslog_client_configuration ;;
        syslog-server) printf '%s\n' software_apt_check_syslog_server_configuration ;;
        zsh) printf '%s\n' software_apt_check_zsh_configuration ;;
        wazuh-server) printf '%s\n' software_apt_check_wazuh_server_configuration ;;
        apache2|chatgpt|jsvc|lemonldap|omada|openvswitch|postgresql|qemu-guest-agent|syncthing|webmin|zoom) printf '\n' ;;
        *) return 2 ;;
    esac
}

software_apt_configuration_conforms() {
    local software="${1:-}" desired="${2:-}" check missing policy
    [[ "$desired" == 1 ]] || return 0
    policy="$(software_apt_convergence_update_configuration_policy "$software")" || return 2
    if [[ "${software_management_action:-update}" == update && ! -v software_convergence_actual && "$policy" == explicit ]]; then
        return 0
    fi
    missing="$(software_apt_missing_install_packages "$software")" || return 2
    [[ -z "$missing" ]] || return 1
    check="$(software_apt_convergence_configuration_check "$software")" || return 2
    [[ -n "$check" ]] || return 0
    if [[ ! "$check" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] || ! declare -F "$check" >/dev/null; then
        return 2
    fi
    "$check"
}

software_apt_convergence_update_configuration_policy() {
    case "${1:-}" in
        crowdsec-bouncer|wazuh-server) printf 'always\n' ;;
        *) software_apt_convergence_variable "${1:-}" >/dev/null || return 1; printf 'explicit\n' ;;
    esac
}

software_apt_convergence_remove_packages() {
    case "${1:-}" in
        crowdsec-bouncer) software_apt_crowdsec_bouncer_remove_packages ;;
        syslog-client|syslog-server) software_apt_syslog_remove_packages "${1:-}" ;;
        mongodb) software_apt_mongodb_installed_packages ;;
        openjdk) software_apt_openjdk_installed_packages ;;
        postgresql) software_apt_postgresql_installed_packages ;;
        wazuh-server) software_apt_wazuh_server_installed_packages ;;
        *) software_apt_convergence_package "${1:-}" ;;
    esac
}

software_apt_convergence_pre_remove_hook() {
    case "${1:-}" in
        crowdsec-agent) printf '%s\n' software_apt_preflight_crowdsec_agent_remove ;;
        crowdsec-bouncer) printf '%s\n' software_apt_disable_crowdsec_bouncer ;;
        syslog-client) printf '%s\n' software_apt_disable_syslog_client ;;
        syslog-server) printf '%s\n' software_apt_disable_syslog_server ;;
        zsh) printf '%s\n' software_apt_prepare_zsh_removal ;;
        *) software_apt_convergence_variable "${1:-}" >/dev/null || return 1; printf '\n' ;;
    esac
}

software_apt_remove() {
    local package package_list repository remove_action remove_repository simulation line removed candidate matched hook
    # Le callback de rôle sait si le paquet partagé sera retiré.
    # shellcheck disable=SC2034
    local software_remove_packages_present=0
    local -a packages=()
    local -A confirmed=()
    package_list="$(software_apt_convergence_remove_packages "${1:-}")" || return 1
    if [[ -z "$package_list" ]]; then
        hook="$(software_apt_convergence_pre_remove_hook "${1:-}")" || return 1
        if [[ -z "$hook" || ! "$hook" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] || ! declare -F "$hook" >/dev/null; then
            printf '%s\n' 'Retrait du rôle partagé non vérifiable.' >&2
            return 1
        fi
        "$hook"
        return $?
    fi
    while IFS= read -r package; do
        [[ "$package" =~ ^[a-z0-9][a-z0-9+.-]+(:[a-z0-9][a-z0-9-]*)?$ ]] || return 1
        packages+=("$package")
        confirmed["$package"]=0
    done <<< "$package_list"
    (( ${#packages[@]} > 0 )) || return 1
    repository="$(software_apt_convergence_repository "${1:-}")" || return 1
    remove_action="$(software_apt_convergence_remove_action "${1:-}")" || return 1
    remove_repository="$(software_apt_convergence_remove_repository "${1:-}")" || return 1
    [[ "$remove_action" == remove || "$remove_action" == purge ]] || return 1
    if ! simulation="$(LC_ALL=C apt-get --simulate "$remove_action" -- "${packages[@]}")"; then
        printf '%s\n' 'Simulation de désinstallation APT impossible.' >&2
        return 1
    fi
    while IFS= read -r line; do
        if [[ "$line" =~ ^(Remv|Purg)[[:space:]]+([^[:space:]]+) ]]; then
            removed="${BASH_REMATCH[2]}"
            matched=0
            for candidate in "${packages[@]}"; do
                if [[ "$removed" == "$candidate" || "$removed" == "$candidate:"* || "$candidate" == "$removed:"* ]]; then
                    confirmed["$candidate"]=1
                    matched=1
                    break
                fi
            done
            if [[ "$matched" != 1 ]]; then
                printf 'Désinstallation APT refusée : paquet supplémentaire %s.\n' "$removed" >&2
                return 1
            fi
        fi
    done <<< "$simulation"
    for candidate in "${packages[@]}"; do
        if [[ "${confirmed[$candidate]}" != 1 ]]; then
            printf 'Simulation APT sans retrait confirmé : %s.\n' "$candidate" >&2
            return 1
        fi
    done
    # Le callback de rôle lit cette variable locale par portée dynamique Bash.
    # shellcheck disable=SC2034
    software_remove_packages_present=1
    hook="$(software_apt_convergence_pre_remove_hook "${1:-}")" || return 1
    if [[ -n "$hook" ]]; then
        if [[ ! "$hook" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] || ! declare -F "$hook" >/dev/null; then return 1; fi
        "$hook" || return 1
    fi
    apt -y "$remove_action" -- "${packages[@]}" || return 1
    if [[ -n "$repository" && "$remove_repository" == 1 ]]; then
        if ! declare -F system_apt_remove_repository >/dev/null; then
            printf '%s\n' 'Moteur de dépôts APT indisponible.' >&2
            return 1
        fi
        system_apt_remove_repository "$repository" || return 1
        apt -y update || return 1
    fi
}

software_apt_converge() {
    software_converge "${1:-}" "${2:-}" software_apt_convergence_detect software_apt_install software_apt_remove software_apt_configuration_conforms
}

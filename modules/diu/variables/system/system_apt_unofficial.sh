#!/usr/bin/env bash
# Variables statiques des dépôts APT tiers. La valeur initiale reflète l'état
# de la configuration APT au premier chargement, puis reste persistante.
# shellcheck disable=SC2034

config="STATIC"
state="ENABLE"
scope="system"
variable_config_file="/root/diu/config/${scope}.env"

system_apt_unofficial_detect() {
    local variable="$1" version pattern
    case "$variable" in
        SYSTEM_APT_MONGODB)
            for version in 8 7 6 5 4; do
                pattern="${version}\.0"
                [[ "$version" == 4 ]] && pattern='4\.(0|4)'
                if grep -RqsE "mongodb-org/${pattern}|mongodb-${pattern}|server-${pattern}" \
                    /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null; then
                    printf '%s' "$version"
                    return 0
                fi
            done
            printf '0'
            ;;
        SYSTEM_APT_WAZUH)
            grep -Rqs 'packages\.wazuh\.com/4\.x' /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null && printf '4' || printf '0'
            ;;
        *)
            local repository
            case "$variable" in
                SYSTEM_APT_DOCKER) repository='download\.docker\.com' ;;
                SYSTEM_APT_LEMONLDAP) repository='lemonldap-ng' ;;
                SYSTEM_APT_NODEJS) repository='nodesource|deb\.nodesource\.com' ;;
                SYSTEM_APT_NVIDIA) repository='nvidia|developer\.download\.nvidia\.com' ;;
                SYSTEM_APT_PROXMOX) repository='proxmox|download\.proxmox\.com' ;;
                SYSTEM_APT_VSCODE) repository='packages\.microsoft\.com/repos/code' ;;
                SYSTEM_APT_WEBMIN) repository='webmin|download\.webmin\.com' ;;
                SYSTEM_APT_CGPT) repository='openai|chatgpt|codex' ;;
                *) repository="${variable#SYSTEM_APT_}" ;;
            esac
            if grep -RqsE "${repository}|${repository^}" /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null; then
                printf '1'
            else
                printf '0'
            fi
            ;;
    esac
}

system_apt_unofficial_legacy_value() {
    case "$1" in
        SYSTEM_APT_LEMONLDAP)
            [[ "${SOFTWARES_APT_LEMONLDAP:-0}" == 1 ]] && printf '1' || printf '0'
            ;;
        SYSTEM_APT_MONGODB)
            if [[ "${SOFTWARES_APT_MONGODB:-0}" == 1 ]]; then
                case "${MONGODB_VERSION:-}" in
                    4|4.0|4.4) printf '4' ;;
                    5|5.0|6|6.0|7|7.0|8|8.0) printf '%s' "${MONGODB_VERSION%%.*}" ;;
                    *) printf '0' ;;
                esac
            else
                printf '0'
            fi
            ;;
        SYSTEM_APT_WAZUH)
            if [[ "${SOFTWARES_APT_WAZUH_SERVER:-0}" == 1 && "${WAZUH_SERVER_UPGRADE:-0}" == 1 ]]; then
                printf '4'
            else
                printf '0'
            fi
            ;;
        *) printf '0' ;;
    esac
}

system_apt_unofficial_declare() {
    local variable="$1" default_value
    if [[ -z "${!variable+x}" ]]; then
        default_value="$(system_apt_unofficial_detect "$variable")"
        if [[ "$default_value" == 0 ]]; then
            default_value="$(system_apt_unofficial_legacy_value "$variable")"
        fi
        export "${variable}=${default_value}"
        printf 'export %s=%s\n' "$variable" "$default_value" >> "$variable_config_file"
    fi
}

system_apt_unofficial_declare SYSTEM_APT_DOCKER
system_apt_unofficial_declare SYSTEM_APT_LEMONLDAP
system_apt_unofficial_declare SYSTEM_APT_MONGODB
system_apt_unofficial_declare SYSTEM_APT_NODEJS
system_apt_unofficial_declare SYSTEM_APT_NVIDIA
system_apt_unofficial_declare SYSTEM_APT_PROXMOX
system_apt_unofficial_declare SYSTEM_APT_VSCODE
system_apt_unofficial_declare SYSTEM_APT_WAZUH
system_apt_unofficial_declare SYSTEM_APT_WEBMIN
system_apt_unofficial_declare SYSTEM_APT_CGPT

#!/usr/bin/env bash
# Variables statiques des dépôts APT tiers. La valeur initiale reflète l'état
# de la configuration APT au premier chargement, puis reste persistante.
# shellcheck disable=SC2034

config="STATIC"
state="ENABLE"
scope="system"
variable_config_file="/root/diu/config/${scope}.env"

system_apt_unofficial_detect() {
    local variable="$1"
    case "$variable" in
        SYSTEM_APT_MONGODB)
            for version in 8 7 6 5 4; do
                if grep -RqsE "mongodb-org/${version}\.0|mongodb-${version}\.0|server-${version}\.0" \
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
                SYSTEM_APT_CROWDSEC) repository='crowdsec|packagecloud.io/crowdsec' ;;
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

system_apt_unofficial_declare() {
    local variable="$1" default_value
    if [[ -z "${!variable+x}" ]]; then
        default_value="$(system_apt_unofficial_detect "$variable")"
        export "${variable}=${default_value}"
        printf 'export %s=%s\n' "$variable" "$default_value" >> "$variable_config_file"
    fi
}

system_apt_unofficial_declare SYSTEM_APT_CROWDSEC
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

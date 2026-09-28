#!/usr/bin/env bash

system_info_network() {
    local index
    local interface_var
    local state_var
    local type_var
    local ip_var
    local ip_cidr_var
    local gw_var

    echo ""
    echo "=============================================="
    echo " Informations réseau"
    echo "=============================================="
    echo ""

    for index in 1 2; do

        interface_var="INTERFACE_ETHERNET${index}"
        state_var="INTERFACE_ETHERNET${index}_STATE"
        type_var="INTERFACE_ETHERNET${index}_TYPE"
        ip_var="INTERFACE_ETHERNET${index}_IP"
        ip_cidr_var="INTERFACE_ETHERNET${index}_IP_CIDR"
        gw_var="INTERFACE_ETHERNET${index}_GW"

        # ------------------------------------------------------
        # Affichage uniquement si l'interface est UP
        # ------------------------------------------------------

        if [[ "${!state_var-UNSET}" == "UP" ]]; then

            echo "Interface Ethernet ${index}"
            echo "----------------------------------------------"
            echo "Interface  : ${!interface_var-UNSET}"
            echo "État       : ${!state_var-UNSET}"
            echo "Type       : ${!type_var-UNSET}"
            echo "Adresse IP : ${!ip_var-UNSET}"
            echo "IP / CIDR  : ${!ip_cidr_var-UNSET}"
            echo "Passerelle : ${!gw_var-UNSET}"
            echo ""

        fi

    done
}

system_info_debian() {
    printf '\n%s\n %s\n%s\n\n' \
        '==============================================' 'SYSTEM DEBIAN' '=============================================='
    printf '%s=%s\n' 'SYSTEM_DEBIAN_ENVIRONNEMENT' "${SYSTEM_DEBIAN_ENVIRONNEMENT-UNSET}"
    printf '%s=%s\n' 'SYSTEM_DEBIAN_RELEASE' "${SYSTEM_DEBIAN_RELEASE-UNSET}"
    printf '\n%s\n %s\n%s\n\n' \
        '==============================================' 'SYSTEM APT OFFICIAL' '=============================================='
    printf '%s=%s\n' 'SYSTEM_APT_DEBIAN_UPDATES' "${SYSTEM_APT_DEBIAN_UPDATES-UNSET}"
    printf '%s=%s\n' 'SYSTEM_APT_DEBIAN_SOURCES' "${SYSTEM_APT_DEBIAN_SOURCES-UNSET}"
    printf '%s=%s\n' 'SYSTEM_APT_DEBIAN_BACKPORT' "${SYSTEM_APT_DEBIAN_BACKPORT-UNSET}"
    printf '%s=%s\n' 'SYSTEM_APT_DEBIAN_CONTRIB' "${SYSTEM_APT_DEBIAN_CONTRIB-UNSET}"
    printf '%s=%s\n' 'SYSTEM_APT_DEBIAN_NONFRFEE' "${SYSTEM_APT_DEBIAN_NONFRFEE-UNSET}"
    printf '\n%s\n %s\n%s\n\n' \
        '==============================================' 'SYSTEM APT UNOFFICIAL' '=============================================='
    printf '%s=%s\n' 'SYSTEM_APT_CGPT' "${SYSTEM_APT_CGPT-UNSET}"
    printf '%s=%s\n' 'SYSTEM_APT_CROWDSEC' "${SYSTEM_APT_CROWDSEC-UNSET}"
    printf '%s=%s\n' 'SYSTEM_APT_DOCKER' "${SYSTEM_APT_DOCKER-UNSET}"
    printf '%s=%s\n' 'SYSTEM_APT_LEMONLDAP' "${SYSTEM_APT_LEMONLDAP-UNSET}"
    printf '%s=%s\n' 'SYSTEM_APT_MONGODB' "${SYSTEM_APT_MONGODB-UNSET}"
    printf '%s=%s\n' 'SYSTEM_APT_NODEJS' "${SYSTEM_APT_NODEJS-UNSET}"
    printf '%s=%s\n' 'SYSTEM_APT_NVIDIA' "${SYSTEM_APT_NVIDIA-UNSET}"
    printf '%s=%s\n' 'SYSTEM_APT_PROXMOX' "${SYSTEM_APT_PROXMOX-UNSET}"
    printf '%s=%s\n' 'SYSTEM_APT_VSCODE' "${SYSTEM_APT_VSCODE-UNSET}"
    printf '%s=%s\n' 'SYSTEM_APT_WAZUH' "${SYSTEM_APT_WAZUH-UNSET}"
    printf '%s=%s\n' 'SYSTEM_APT_WEBMIN' "${SYSTEM_APT_WEBMIN-UNSET}"
    printf '\n%s\n %s\n%s\n\n' \
        '==============================================' 'SYSTEM FLATPAK' '=============================================='
    printf '%s=%s\n' 'SYSTEM_FLATPAK' "${SYSTEM_FLATPAK-UNSET}"
}

system_info_drivers() {
    local package_info status version
    printf '\n%s\n %s\n%s\n\n' \
        '==============================================' 'SYSTEM DRIVERS' '=============================================='
    printf '%s=%s\n' 'SYSTEM_DRIVERS_DISPLAY_LINK' "${SYSTEM_DRIVERS_DISPLAY_LINK-UNSET}"
    [[ "${SYSTEM_DRIVERS_DISPLAY_LINK-UNSET}" == 1 ]] || return 0

    if package_info=$(dpkg-query -W -f='${db:Status-Status}\t${Version}' displaylink-driver 2>/dev/null); then
        IFS=$'\t' read -r status version <<< "$package_info"
        if [[ "$status" == installed && -n "$version" ]]; then
            printf 'Version DisplayLink : %s\n' "$version"
            return 0
        fi
    fi
    printf 'Version DisplayLink : UNSET\n'
    printf '❌ Impossible de déterminer la version du paquet DisplayLink installé.\n' >&2
    return 1
}

system_info() {
    local status=0
    printf '\n%s\n%s\n%s\n%s\n%s\n\n' \
        '##############' '##############' '### SYSTEM ###' '##############' '##############'
    system_info_debian || status=1
    system_info_drivers || status=1
    system_info_network || status=1
    return "$status"
}

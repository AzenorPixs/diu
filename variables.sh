#!/bin/bash -e



# nano /root/variables.sh

# chmod +x /root/variables.sh

# alias --> nriv

#

# Paquet a supprimer pour les container --> apt purge qemu-guest-agent

# Paquet a supprimer pour les Debian Trixie --> apt purge neofetch



# CERTIFICATION AUTHORITY

CA="-----BEGIN CERTIFICATE-----

MIIC6jCCAnCgAwIBAgIBADAKBggqhkjOPQQDAzCBjjELMAkGA1UEBhMCRlIxETAP

BgNVBAgMCERvcmRvZ25lMRAwDgYDVQQHDAdOb250cm9uMRMwEQYDVQQKDApDSC1O

b250cm9uMQwwCgYDVQQLDANEU0kxKTAnBgkqhkiG9w0BCQEWGmluZm9ybWF0aXF1

ZUBjaC1ub250cm9uLmZyMQwwCgYDVQQDDANDSE4wIBcNMjUxMDI5MDgzMzIzWhgP

MjA3MTAxMDEwODMzMjNaMIGOMQswCQYDVQQGEwJGUjERMA8GA1UECAwIRG9yZG9n

bmUxEDAOBgNVBAcMB05vbnRyb24xEzARBgNVBAoMCkNILU5vbnRyb24xDDAKBgNV

BAsMA0RTSTEpMCcGCSqGSIb3DQEJARYaaW5mb3JtYXRpcXVlQGNoLW5vbnRyb24u

ZnIxDDAKBgNVBAMMA0NITjB2MBAGByqGSM49AgEGBSuBBAAiA2IABKgB+bJ0dcNI

WkG+YKuE1BfteqYUH5m01J0ShGr0Z5dEsqjehtMt7ycLVvk2ReKkLrWvoa7lS8Q8

Xo1ZqSypW8HCB8mCZ94xpELdiQ4YTlpmwbAUBQ8nUAk5+OqsLLYUqqOBnTCBmjA3

BglghkgBhvhCAQ0EKhYoT1BOc2Vuc2UgR2VuZXJhdGVkIENlcnRpZmljYXRlIEF1

dGhvcml0eTAdBgNVHQ4EFgQU5PlxuEHAZowWyDiqnNPzzI6MzHYwHwYDVR0jBBgw

FoAU5PlxuEHAZowWyDiqnNPzzI6MzHYwDwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8B

Af8EBAMCAYYwCgYIKoZIzj0EAwMDaAAwZQIwAVisZbrzcp+H4XmfHT23XbpUDe81

7CMKqVcgUscsBi9GMcoQj9F/Nce/4E4NWpyCAjEA26NOQ8UWp6uwGiNxtVcj7pDr

HirYcUOcq8ENj3Nc/wdVEE9PfxbX+9toalk9wboJ

-----END CERTIFICATE-----"



# VERSIONS

export VERSION=2026.08.12.03.08

export VERSION_ALIAS=16.07.2026

export VERSION_VARIABLES=16.07.2026



# VARIABLES SYSTEM (40)

export ACME=NONE # x.x.x.x/NONE

export ADMIN_NETWORK1=10.2.0.0/16 # x.x.x.x/NONE

export ADMIN_NETWORK2=10.25.28.0/24 # x.x.x.x/NONE

export API_DEEPSEEK_KEY=sk-18673036adb547b88ec77deb1b092b26

export API_GEMINI_KEY=AIzaSyALpRuJ54_glZ0uXIZBMTlRzuRd2CDXWXE

export API_OPENROUTER_KEY=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

export API_PROMPT_SYSTEM="Tu es un assistant utile. Réponse uniquement en français de façon concises mais complètes (1 à 3 phrases), sauf si une explication détaillée est nécessaire."

export DEBIAN_RELEASE="$(. /etc/os-release && echo "$VERSION_CODENAME")"

export DEBIAN_TYPE=PROXMOX # LXC/PHYSICAL/PROXMOX/VM

export DOMAIN=pixs.fr

export DESKTOP=1 # DESKTOP

export DESKTOP_GUI=GNOME # GNOME/KDE

export DISPLAY_LINK=0 # GNOME/KDE/NONE

export DNS_OVH_ENDPOINT=ovh-eu

export DNS_OVH_APPLICATION_KEY=5481e50b4f2c0187

export DNS_OVH_APPLICATION_SECRET=2f6a033ad49706c15fc9c207a0538ae7

export DNS_OVH_CONSUMER_KEY=9c424525e3f87bf3b7e217f43bdf4245

export DNS_OVH_DOMAIN1=pixs.fr

export DRIVERS_LAST=0 # LAST DRIVERS ON GIT.KERNEL.ORG

export DRIVERS_NVIDIA=1 # PROPRIETARY NVIDIA DRIVERS

export FILES2RAM=1

export FSTAB=1 # TUNE FSTAB

export FSTAB_CONFIG1='UUID=3bc47321-b189-4a8e-8211-d952d791336b /               btrfs   relatime,compress=zstd,ssd,subvol=@rootfs 0       0'

export FSTAB_CONFIG2='UUID=B634-1B92  /boot/efi       vfat    umask=0077      0       1'

export FSTAB_CONFIG3='/dev/sr0        /media/cdrom0   udf,iso9660 user,noauto     0       0'

export FSTAB_CONFIG4='/dev/disk/by-uuid/db71fd78-bb50-4b3d-a140-34b0799be35e /mnt/db71fd78-bb50-4b3d-a140-34b0799be35e btrfs relatime,compress=zstd,nosuid,nodev,nofail,x-gvfs-show,x-gvfs-name=SLOW 0 0'

export FSTAB_CONFIG5='/dev/disk/by-uuid/d0afb2d6-8fb6-4469-917a-2f54278ea553 /mnt/d0afb2d6-8fb6-4469-917a-2f54278ea553 btrfs relatime,compress=zstd,ssd,nosuid,nodev,nofail,x-gvfs-show,x-gvfs-name=FAST 0 0'

export FSTAB_CONFIG6='tmpfs                                       /var/log            tmpfs         rw,nosuid,nodev,noatime,nodiratime,mode=1755'

export GATEWAY=192.168.1.1

export GATEWAY_INTERFACE=wlx6c4cbc575618 # eno1/eth0/eth1/vmbr0/NONE

export GRUB_CONFIG=0 # TUNE GRUB

export GRUB_CMDLINE_LINUX_DEFAULT='"quiet intel_iommu=on iommu=pt i915.enable_gvt=1 default_hugepagesz=2M"' 		# quiet/quiet intel_iommu=on iommu=pt i915.enable_gvt=1

export HOSTNAME=hvp1

export HOSTNAME_FQDN=hvp1.pixs.fr

export BRIDGE_ETHERNET1=NONE # eno1/eth1/NONE/vmbr0

export BRIDGE_ETHERNET1_CONFIG_IP=NONE # DHCP/LXC/NONE/PROXMOX/STATIC

export BRIDGE_ETHERNET1_IP=192.168.1.254

export BRIDGE_ETHERNET1_IP_CIDR=192.168.1.254/24

export BRIDGE_ETHERNET2=NONE # eno1/eth1/NONE/vmbr0

export BRIDGE_ETHERNET2_CONFIG_IP=NONE # DHCP/LXC/NONE/PROXMOX/STATIC

export BRIDGE_ETHERNET2_IP=

export BRIDGE_ETHERNET2_IP_CIDR=

export INTERFACE_SERVER=vmbr0 # eno1/eth0/vmbr0/NONE

export IPv6=0

export JOURNALD_MAX_USE=8M

export JOURNALD_KEEP_FREE=4M

export KERNEL_CURRENT=$(uname -r)

export KERNEL_LAST=7.0.14-11-pve

export KEY_SSH_ADMIN="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC+FSHEVC5ZRvwkRiG8zBFRsJ5bRVya0/mp6NR5d8Owl root@pixs.fr"

export KEY_SSH_ACME="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEQrvNHkuQ6UaYMV3sToUNDE9UY+ICWOqH4xwXhMkBA9 root@fw1.pixs.fr"

export LOG_ROTATE=1

export LOG_ROTATE_DAILY=1

export NO_SLEEP=1

export OPEN_22_TCP=0 # SSH

export OPEN_53_TCP=0 # DNS

export OPEN_53_UDP=0 # DNS

export OPEN_80_TCP=0 # HTTP

export OPEN_88_TCP=0 # KERBEROS - KDC

export OPEN_88_UDP=0 # KERBEROS - KDC

export OPEN_123_UDP=0 # NTP

export OPEN_389_TCP=0 # LDAP

export OPEN_443_TCP=0 # HTTPS

export OPEN_443_UDP=0 # HTTPS QUIC

export OPEN_464_TCP=0 # KERBEROS - KPASSWD

export OPEN_464_UDP=0 # KERBEROS - KPASSWD

export OPEN_514_TCP=0 # SYSLOG

export OPEN_514_UDP=0 # SYSLOG

export OPEN_636_TCP=0 # LDAPS

export OPEN_1514_UDP=0 # WAZUH CLIENT REMOTE UPDATE INFO

export OPEN_1515_TCP=0 # WAZUH CLIENT REGISTER

export OPEN_2222_TCP=0 # SSH FORGEJO

export OPEN_3001_TCP=0 # OST

export OPEN_4443_TCP=0 # WAZUH DASHBOARD

export OPEN_4662_TCP=1 # AMULE

export OPEN_4665_UDP=1 # AMULE

export OPEN_4672_UDP=1 # AMULE

export OPEN_7389_TCP=0 # FREEIPA - SEPARATE DOGTAG INSTANCE

export OPEN_7422_TCP=0 # CROWDSEC AGENT APP SECURITY

export OPEN_8006_TCP=0 # PROXMOX

export OPEN_8043_TCP=0 # ?

export OPEN_8080_TCP=0 # CROWDSEC LAPI

export OPEN_8088_TCP=0 # OMADA

export OPEN_8843_TCP=0 # OMADA

export OPEN_9000_TCP=0 # ?

export OPEN_9200_TCP=0 # ELASTICSEARCH

export OPEN_9443_TCP=0 # FREEIPA - DOGTAG CERTIFICATE PKI

export OPEN_9444_TCP=0 # FREEIPA - DOGTAG USERS SSL

export OPEN_9445_TCP=0 # FREEIPA - DOGTAG ADMINISTRATORS

export OPEN_10000_TCP=0 # WEBMIN

export OPEN_50000_TCP=1 # AMULE

export PROXY=0

export PROXY_HTTP_HOST=

export PROXY_HTTP_PORT=

export PROXY_HTTPS_HOST=

export PROXY_HTTPS_PORT=

export PROXY_CA=0

export ROUTE1=0

export ROUTE1_DATA=

export ROUTE2=0

export ROUTE2_DATA=

export ROUTE3=0

export ROUTE3_DATA=

export RCLOCAL=1

export SECURE_BOOT=1

export TIME_ZONE=Europe/Paris



# VARIABLES SOFTWARES (40)

export ACMESH=1

export ACMESH_EMAIL=postmaster@pixs.fr

export ACMESH_HOME=/root/.acme.sh

export AMULE=1

export APACHE2=0

export CROWDSEC_AGENT=0  # ON LAPI cscli lapi register -u  http://10.25.106.1:8080 --machine FW-CHN ; On FW-CHN cscli machines validate SIEM

export CROWDSEC_BOUNCER=0  # cscli bouncers add wxyz on LAPI (REGISTER API KEY AND SAVE IN /etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml)

export CROWDSEC_BOUNCER_API_KEY=8dEbn6qmYS3DvrtkRIJgT4iEXGZygQ9fKtJ7ktrOw3s

export DEVOPS=1

export DEVOPS_USER=devops

export DEVOPS_HUMAN_USER=ade

export DEVOPS_GROUP=labdev

export DEVOPS_PASSWORD=1AQ6HvQSR9HQKM0EqHQBHY

export DEVOPS_PROJECTS_ROOT="/home/${DEVOPS_USER}/datas"

export DOCKER=1

export DOCKER_USER=docker

export DOCKER_PASSWORD=1AQ6HvQSR9HQKM0EqHQBHY

export DOCKER_CLEAN=0

export DOCKER_CONTAINERDIO_FIXED=0

export DOCKER_CONTAINERDIO_FIXED_VERSION=1.7.28-0~debian.13~trixie

export DOCKER_IMAGE_UPDATE_POLICY="check" # never, check ou always

export DOCKER_IMAGE_UPDATED=0 # Cette variable est réinitialisée à 0 à chaque appel. Ca valeur n'a aucune importance

export DOCKER_STACK_DEVOPS=1

export DOCKER_STACK_TRAEFIK_DOCKHAND=1

export DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN=pixs.fr

export DOCKER_STACK_TRAEFIK_DOCKHAND_UPGRADE=0

export DOCKER_STACK_BUNKERWEB=0

export DOCKER_STACK_BUNKERWEB_UPGRADE=0

export DOCKER_STACK_BUNKERWEB_AUTO_UPDATE=0

export DOCKER_STACK_BUNKERWEB_VERSION=0

export DOCKER_PORTAINER_API_KEY=0

export DOCKER_PORTAINER_STACK_ELK=0

export DOCKER_PORTAINER_STACK_ELK_DC_ID=0

export DOCKER_PORTAINER_STACK_ELK_ENDPOINT_ID=0

export DOCKER_PORTAINER_STACK_ELK_UPGRADE=0

export DOCKER_PORTAINER_STACK_NEXTCLOUD=0

export DOCKER_PORTAINER_STACK_NEXTCLOUD_BRANCH=30

export DOCKER_PORTAINER_STACK_NEXTCLOUD_DC_ID=15

export DOCKER_PORTAINER_STACK_NEXTCLOUD_ENDPOINT_ID=2

export DOCKER_PORTAINER_STACK_NEXTCLOUD_UPGRADE=0

export DOCKER_TREE_HOME=0

export FASTFETCH=1

export GO=1

export JSVC=0

export LEMONLDAP=0

export MONGODB=0

export MONGODB_VERSION=7 # 4.4/5/6/7/8

export NODEJS=1

export NODEJS_SERIES="24"

export OMADA=0

export OMADA_VERSION=

export OPENCODE=1

export OPENSPEC=1

export OPENJDK=0

export OPENVSWITCH=1

export POSTGRESQL=0

export POSTFIX=0

export POSTFIX_RELAY_HOST=

export PYTHON=1

export PYTHON_SERIES=3.14

export QEMU_GUEST_AGENT=0

export SYNCTHING=1

export SYSLOG_CLIENT=0

export SYSLOG_CLIENT_SERVER=10.3.0.1

export SYSLOG_SERVER=0

export SYSLOG_SERVER_SKIL_KERNEL=0

export SYSLOG_SERVER_SKIL_OMADA=0

export SYSLOG_SERVER_SKIL_SSO=0

export SYSLOG_SERVER_SKIL_SURICATA=0

export SSH=1

export TGPT=1

export VSCODE=1

export WAZUH_CLIENT=0

export WAZUH_CLIENT_VERSION=4.11.2-1

export WAZUH_SERVER=0

export WAZUH_SERVER_UPGRADE=0

export WEBMIN=0

export ZOOM=0

export ZSH=1


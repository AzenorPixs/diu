#!/usr/bin/env bash
# Vérification et Génération de variable via fichier déclaratif unitaire.

# ============================================================
# Variable déclarative : SYSTEM_DEBIAN_ENVIRONNEMENT
# ============================================================

# Configuration
# STATIC / DYNAMIC
config="DYNAMIC"

# État
# ENABLE / DISABLE
state="ENABLE"

# Scope
scope="system"

# Valeur par défaut
# Environnement indéterminé en cas de détection impossible.
default_value="UNSET"

# Fichier de configuration du scope
variable_config_file="/root/diu/config/${scope}.env"

# echo "🔧 CHECK VARIABLE GLOABAL SYSTEM_DEBIAN_ENVIRONNEMENT"


# ============================================================
# Génération de la variable
# ============================================================

variable_generator() (
    local kind detected status package_status

    if ! command -v systemd-detect-virt > /dev/null 2>&1; then
        printf '%s\n' 'SYSTEM_DEBIAN_ENVIRONNEMENT : systemd-detect-virt indisponible.' >&2
        printf '%s\n' UNSET
        return 0
    fi

    # Le conteneur courant prime sur la virtualisation de son hôte.
    for kind in container vm; do
        if detected="$(systemd-detect-virt "--${kind}" 2>/dev/null)"; then
            case "${kind}:${detected}" in
                container:docker) printf '%s\n' DOCKER; return 0 ;;
                container:lxc|container:lxc-libvirt) printf '%s\n' LXC; return 0 ;;
                vm:kvm|vm:amazon|vm:qemu|vm:bochs|vm:xen|vm:uml|vm:vmware|vm:oracle|\
                vm:microsoft|vm:zvm|vm:parallels|vm:bhyve|vm:qnx|vm:acrn|vm:powervm|\
                vm:apple|vm:sre|vm:google) printf '%s\n' VM; return 0 ;;
                *)
                    printf '%s\n' 'SYSTEM_DEBIAN_ENVIRONNEMENT : environnement inconnu ou non pris en charge.' >&2
                    printf '%s\n' UNSET
                    return 0
                    ;;
            esac
        else
            status=$?
            if [[ "$status" -ne 1 || "$detected" != none ]]; then
                printf '%s\n' 'SYSTEM_DEBIAN_ENVIRONNEMENT : résultat de détection incohérent ou en échec.' >&2
                printf '%s\n' UNSET
                return 0
            fi
        fi
    done

    if ! command -v dpkg-query > /dev/null 2>&1; then
        printf '%s\n' 'SYSTEM_DEBIAN_ENVIRONNEMENT : dpkg-query indisponible.' >&2
        printf '%s\n' UNSET
        return 0
    fi

    if package_status="$(dpkg-query -W -f='${Status}' pve-manager 2>/dev/null)"; then
        case "$package_status" in
            'install ok installed'|'hold ok installed') printf '%s\n' PROXMOX ;;
            *' not-installed'|*' config-files'|*' unpacked'|*' half-configured'|*' half-installed'|*' triggers-awaited'|*' triggers-pending')
                printf '%s\n' PHYSICAL ;;
            *)
                printf '%s\n' 'SYSTEM_DEBIAN_ENVIRONNEMENT : état du paquet Proxmox indéterminé.' >&2
                printf '%s\n' UNSET ;;
        esac
    else
        status=$?
        if [[ "$status" -eq 1 && -z "$package_status" ]]; then
            printf '%s\n' PHYSICAL
        else
            printf '%s\n' 'SYSTEM_DEBIAN_ENVIRONNEMENT : échec de vérification du paquet Proxmox.' >&2
            printf '%s\n' UNSET
        fi
    fi
)


# ============================================================
# Gestion de la variable
# ============================================================

if [[ "${state}" == "ENABLE" ]]; then

    if [[ -z "${SYSTEM_DEBIAN_ENVIRONNEMENT+x}" ]]; then

        if [[ "${config}" == "STATIC" ]]; then

            export SYSTEM_DEBIAN_ENVIRONNEMENT="${default_value}"

            # Enregistrement dans le fichier de configuration
            echo "🔧 INITIALIATION VARIABLE GLOABAL SYSTEM_DEBIAN_ENVIRONNEMENT"
            echo "export SYSTEM_DEBIAN_ENVIRONNEMENT=${default_value}" >> "${variable_config_file}"

        else

            if ! SYSTEM_DEBIAN_ENVIRONNEMENT="$(variable_generator)"; then
                unset SYSTEM_DEBIAN_ENVIRONNEMENT
                return 1
            fi
            export SYSTEM_DEBIAN_ENVIRONNEMENT

        fi

    fi

else

    # Suppression de la variable de l'environnement courant
    unset SYSTEM_DEBIAN_ENVIRONNEMENT

    # Suppression de la déclaration persistante
    if [[ -f "${variable_config_file}" ]]; then

        sed -i \
            '/^export SYSTEM_DEBIAN_ENVIRONNEMENT=/d' \
            "${variable_config_file}"

    fi

fi

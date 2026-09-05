#!/usr/bin/env bash
# Vérification et Génération de variable via fichier déclaratif unitaire.

# ============================================================
# Variable déclarative : SYSTEM_DEBIAN_RELEASE
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
# Aucun nom de release de repli ne peut être déduit.
default_value=""

# Fichier de configuration du scope
variable_config_file="/root/diu/config/${scope}.env"

# echo "🔧 CHECK VARIABLE GLOABAL SYSTEM_DEBIAN_RELEASE"


# ============================================================
# Génération de la variable
# ============================================================

variable_generator() (
    local VERSION_CODENAME="" release

    if [[ ! -r /etc/os-release ]]; then
        printf '%s\n' 'SYSTEM_DEBIAN_RELEASE : /etc/os-release absent ou illisible.' >&2
        return 1
    fi

    # shellcheck disable=SC1091
    if ! source /etc/os-release; then
        printf '%s\n' 'SYSTEM_DEBIAN_RELEASE : échec de lecture de /etc/os-release.' >&2
        return 1
    fi

    release="${VERSION_CODENAME,,}"
    if [[ ! "$release" =~ ^[a-z][a-z0-9._-]*$ ]]; then
        printf '%s\n' 'SYSTEM_DEBIAN_RELEASE : VERSION_CODENAME absent ou invalide.' >&2
        return 1
    fi

    printf '%s\n' "$release"
)


# ============================================================
# Gestion de la variable
# ============================================================

if [[ "${state}" == "ENABLE" ]]; then

    if [[ -z "${SYSTEM_DEBIAN_RELEASE+x}" ]]; then

        if [[ "${config}" == "STATIC" ]]; then

            export SYSTEM_DEBIAN_RELEASE="${default_value}"

            # Enregistrement dans le fichier de configuration
            echo "🔧 INITIALIATION VARIABLE GLOABAL SYSTEM_DEBIAN_RELEASE"
            echo "export SYSTEM_DEBIAN_RELEASE=${default_value}" >> "${variable_config_file}"

        else

            if ! SYSTEM_DEBIAN_RELEASE="$(variable_generator)"; then
                unset SYSTEM_DEBIAN_RELEASE
                return 1
            fi
            export SYSTEM_DEBIAN_RELEASE

        fi

    fi

else

    # Suppression de la variable de l'environnement courant
    unset SYSTEM_DEBIAN_RELEASE

    # Suppression de la déclaration persistante
    if [[ -f "${variable_config_file}" ]]; then

        sed -i \
            '/^export SYSTEM_DEBIAN_RELEASE=/d' \
            "${variable_config_file}"

    fi

fi

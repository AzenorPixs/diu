#!/usr/bin/env bash
# Vérification et Génération de variable via fichier déclaratif unitaire.

# ============================================================
# Variable déclarative : DIU_APT_REPOSITORY_FD
# ============================================================

# Configuration
# STATIC / DYNAMIC
config="STATIC"

# État
# ENABLE / DISABLE
state="ENABLE"

# Scope
scope="diu"

# Valeur par défaut
# Valeur possible 0 | 1
default_value=0

# Fichier de configuration du scope
variable_config_file="/root/diu/config/${scope}.env"

# echo "🔧 CHECK VARIABLE GLOABAL DIU_APT_REPOSITORY_FD"


# ============================================================
# Génération de la variable
# ============================================================

variable_generator() {

    # Génération de la valeur de DIU_APT_REPOSITORY_FD
    echo "${default_value}"
}


# ============================================================
# Gestion de la variable
# ============================================================

if [[ "${state}" == "ENABLE" ]]; then

    if [[ -z "${DIU_APT_REPOSITORY_FD+x}" ]]; then

        if [[ "${config}" == "STATIC" ]]; then

            export DIU_APT_REPOSITORY_FD="${default_value}"

            # Enregistrement dans le fichier de configuration
            echo "🔧 INITIALIATION VARIABLE GLOABAL DIU_APT_REPOSITORY_FD"
            echo "export DIU_APT_REPOSITORY_FD=${default_value}" >> "${variable_config_file}"

        else

            export DIU_APT_REPOSITORY_FD="$(variable_generator)"

        fi

    fi

else

    # Suppression de la variable de l'environnement courant
    unset DIU_APT_REPOSITORY_FD

    # Suppression de la déclaration persistante
    if [[ -f "${variable_config_file}" ]]; then

        sed -i \
            '/^export DIU_APT_REPOSITORY_FD=/d' \
            "${variable_config_file}"

    fi

fi

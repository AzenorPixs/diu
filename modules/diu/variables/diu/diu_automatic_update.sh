#!/usr/bin/env bash
# Vérification et Génération de variable via fichier déclaratif unitaire.

# ============================================================
# Variable déclarative : DIU_AUTOMATIC_UPDATE
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
default_value=1

# Fichier de configuration du scope
variable_config_file="/root/diu/config/${scope}.env"

# echo "🔧 CHECK VARIABLE GLOABAL DIU_AUTOMATIC_UPDATE"


# ============================================================
# Génération de la variable
# ============================================================

variable_generator() {

    # Génération de la valeur de DIU_AUTOMATIC_UPDATE
    echo "${default_value}"
}


# ============================================================
# Gestion de la variable
# ============================================================

if [[ "${state}" == "ENABLE" ]]; then

    if [[ -z "${DIU_AUTOMATIC_UPDATE+x}" ]]; then

        if [[ "${config}" == "STATIC" ]]; then

            export DIU_AUTOMATIC_UPDATE="${default_value}"

            # Enregistrement dans le fichier de configuration
            echo "🔧 INITIALIATION VARIABLE GLOABAL DIU_AUTOMATIC_UPDATE"
            echo "export DIU_AUTOMATIC_UPDATE=${default_value}" >> "${variable_config_file}"

        else

            export DIU_AUTOMATIC_UPDATE="$(variable_generator)"

        fi

    fi

else

    # Suppression de la variable de l'environnement courant
    unset DIU_AUTOMATIC_UPDATE

    # Suppression de la déclaration persistante
    if [[ -f "${variable_config_file}" ]]; then

        sed -i \
            '/^export DIU_AUTOMATIC_UPDATE=/d' \
            "${variable_config_file}"

    fi

fi

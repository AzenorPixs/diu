#!/usr/bin/env bash
# Vérification et Génération de variable via fichier déclaratif unitaire.

# ============================================================
# Variable déclarative : DOCKER_IMAGE_OPENCODE
# ============================================================

# Configuration
# STATIC / DYNAMIC
config="STATIC"

# État
# ENABLE / DISABLE
state="ENABLE"

# Scope
scope="docker"

# Valeur par défaut
# Valeur possible
default_value='"ghcr.io/anomalyco/opencode:latest"'

# Fichier de configuration du scope
variable_config_file="/root/diu/config/${scope}.env"

# echo "🔧 CHECK VARIABLE GLOABAL DOCKER_IMAGE_OPENCODE"


# ============================================================
# Génération de la variable
# ============================================================

variable_generator() {

    # Génération de la valeur de DOCKER_IMAGE_OPENCODE
    echo "${default_value}"
}


# ============================================================
# Gestion de la variable
# ============================================================

if [[ "${state}" == "ENABLE" ]]; then

    if [[ -z "${DOCKER_IMAGE_OPENCODE+x}" ]]; then

        if [[ "${config}" == "STATIC" ]]; then

            export DOCKER_IMAGE_OPENCODE="${default_value}"

            # Enregistrement dans le fichier de configuration
            echo "🔧 INITIALIATION VARIABLE GLOABAL DOCKER_IMAGE_OPENCODE"
            echo "export DOCKER_IMAGE_OPENCODE=${default_value}" >> "${variable_config_file}"

        else

            export DOCKER_IMAGE_OPENCODE="$(variable_generator)"

        fi

    fi

else

    # Suppression de la variable de l'environnement courant
    unset DOCKER_IMAGE_OPENCODE

    # Suppression de la déclaration persistante
    if [[ -f "${variable_config_file}" ]]; then

        sed -i \
            '/^export DOCKER_IMAGE_OPENCODE=/d' \
            "${variable_config_file}"

    fi

fi

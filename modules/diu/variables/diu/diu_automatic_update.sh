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
default_value="1"


# ============================================================
# Génération de la variable
# ============================================================

variable_generator() {

    # Génération de la valeur de DIU_AUTOMATIC_UPDATE
    echo "1"
}


# ============================================================
# Gestion de la variable
# ============================================================

if [[ "${state}" == "ENABLE" ]]; then

    if [[ -z "${DIU_AUTOMATIC_UPDATE+x}" ]]; then

        if [[ "${config}" == "STATIC" ]]; then

            export DIU_AUTOMATIC_UPDATE="${default_value}"

            # Enregistrement dans config/diu.env
            echo "export DIU_AUTOMATIC_UPDATE=${default_value}" \
                >> "config/${scope}.env"

        else

            export DIU_AUTOMATIC_UPDATE="$(variable_generator)"

        fi

    else

        echo "DIU_AUTOMATIC_UPDATE déjà existante"

    fi

else

    # Suppression de la variable de l'environnement courant
    unset DIU_AUTOMATIC_UPDATE

    # Suppression de la déclaration persistante
    # dans le fichier de configuration du scope.
    if [[ -f "config/${scope}.env" ]]; then

        sed -i \
            '/^export DIU_AUTOMATIC_UPDATE=/d' \
            "config/${scope}.env"

    fi

fi

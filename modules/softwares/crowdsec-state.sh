#!/usr/bin/env bash

# Le bouncer peut être une dépendance de l'agent ou un rôle autonome.

# Les détecteurs et hooks propres aux logiciels appartiennent aux déclarations GLOBAL.
# shellcheck disable=SC1091 source=modules/softwares/apt-recipes.sh
. "$(dirname -- "${BASH_SOURCE[0]}")/apt-recipes.sh"
software_apt_load_recipes || return 1

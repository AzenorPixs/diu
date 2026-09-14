#!/usr/bin/env bash

# Gestions des projets géré par le DIU

projects_update() {
    return 0
}

# Met à jour des affectations ciblées sans réécrire les autres variables.
project_env_set_variables() {
    local project_env="${1:-}"
    local project_env_tmp=""
    local key=""
    local value=""
    local line=""
    local index=0

    if [[ -z "${project_env}" || "$#" -lt 3 || $(($# % 2)) -ne 1 ]]; then
        print_error "Usage : project_env_set_variables <fichier> <VARIABLE> <VALEUR>..."
        return 1
    fi

    shift

    local -a keys=()
    local -A replacements=()
    local -A replaced=()

    while [[ "$#" -gt 0 ]]; do
        key="$1"
        value="$2"
        keys[${index}]="${key}"
        replacements["${key}"]="$(printf '%q' "${value}")"
        index=$((index + 1))
        shift 2
    done

    project_env_tmp="${project_env}.tmp.$$"

    if ! {
        if [[ -f "${project_env}" ]]; then
            while IFS= read -r line || [[ -n "${line}" ]]; do
                if [[ "${line}" =~ ^[[:space:]]*(export[[:space:]]+)?([A-Za-z_][A-Za-z0-9_]*)[[:space:]]*= ]]; then
                    key="${BASH_REMATCH[2]}"
                    if [[ "${replacements[${key}]+_}" ]]; then
                        printf '%s=%s\n' "${key}" "${replacements[${key}]}"
                        replaced["${key}"]=1
                        continue
                    fi
                fi

                printf '%s\n' "${line}"
            done < "${project_env}"
        fi

        for key in "${keys[@]}"; do
            if [[ -z "${replaced[${key}]+_}" ]]; then
                if [[ "${index}" -gt 0 && "${key}" == "${keys[0]}" ]]; then
                    printf '\n# Variables du projet ou du dépôt local\n'
                fi
                printf '%s=%s\n' "${key}" "${replacements[${key}]}"
                replaced["${key}"]=1
            fi
        done
    } > "${project_env_tmp}"; then
        rm -f -- "${project_env_tmp}"
        print_error "Impossible de préparer ${project_env}."
        return 1
    fi

    if ! mv -f -- "${project_env_tmp}" "${project_env}"; then
        rm -f -- "${project_env_tmp}"
        print_error "Impossible d'installer ${project_env}."
        return 1
    fi
}

# Génération ou mise à jour des variables générales du <PROJECT_ID>.
update_projects() {
    local project_id="${1:-}"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"
    local project_env="${project_path}/project.env"

    local project_name=""
    local project_type="BASH"
    local project_dockered="No"
    local project_debian_package="No"
    local value=""

    if [[ -z "${project_id}" ]]; then
        print_error "Usage : update_projects <project_id>"
        return 1
    fi

    if [[ ! -d "${project_path}" ]]; then
        print_error "Le répertoire du projet n'existe pas : ${project_path}"
        return 1
    fi

    if [[ -f "${project_env}" ]]; then
        unset \
            PROJECT_ID \
            PROJECT_NAME \
            PROJECT_TYPE \
            PROJECT_DOCKERED \
            PROJECT_DEBIAN_PACKAGE

        # shellcheck disable=SC1090
        source "${project_env}"

        if [[ -n "${PROJECT_ID:-}" && "${PROJECT_ID}" != "${project_id}" ]]; then
            print_error \
                "PROJECT_ID '${PROJECT_ID}' ne correspond pas au projet '${project_id}'."
            return 1
        fi

        project_name="${PROJECT_NAME:-}"
        project_type="${PROJECT_TYPE:-BASH}"
        project_dockered="${PROJECT_DOCKERED:-No}"
        project_debian_package="${PROJECT_DEBIAN_PACKAGE:-No}"
    fi

    print_title "Configuration du projet ${project_id}"

    value=""
    read -r -p "PROJECT_NAME [${project_name}] : " value
    if [[ -n "${value}" ]]; then
        project_name="${value}"
    fi

    while [[ -z "${project_name}" ]]; do
        print_error "PROJECT_NAME ne peut pas être vide."
        read -r -p "PROJECT_NAME : " project_name
    done

    value=""
    read -r -p "PROJECT_TYPE [${project_type}] : " value
    if [[ -n "${value}" ]]; then
        project_type="${value}"
    fi

    value=""
    read -r -p "PROJECT_DOCKERED [${project_dockered}] : " value
    if [[ -n "${value}" ]]; then
        project_dockered="${value}"
    fi

    value=""
    read -r -p "PROJECT_DEBIAN_PACKAGE [${project_debian_package}] : " value
    if [[ -n "${value}" ]]; then
        project_debian_package="${value}"
    fi

    if ! project_env_set_variables \
        "${project_env}" \
        PROJECT_ID "${project_id}" \
        PROJECT_NAME "${project_name}" \
        PROJECT_TYPE "${project_type}" \
        PROJECT_DOCKERED "${project_dockered}" \
        PROJECT_DEBIAN_PACKAGE "${project_debian_package}"; then
        return 1
    fi

    if ! chown "${DEVOPS_USER}:${DEVOPS_GROUP}" "${project_env}" ||
        ! chmod 660 "${project_env}"; then
        print_error "Impossible de définir les droits de ${project_env}."
        return 1
    fi

    print_success "Variables du projet enregistrées : ${project_env}"
    return 0
}

create_project() {
    local project_id="$1"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"
    local project_env="${project_path}/project.env"

    local project_name=""
    local project_type=""

    # Vérification des paramètres
    if [[ -z "${project_id}" ]]; then
        print_error "Usage : create_project <project_id>"
        return 1
    fi

    # Vérification de l'utilisateur DevOps
    if ! check_devops_user; then
        print_error "L'utilisateur DevOps n'est pas disponible."
        return 1
    fi

	# Vérifier que le projet n'existe pas
	if [[ -e "${project_path}" ]]; then
		print_error "Le projet existe déjà : ${project_path}"
		return 1
	fi

	# Créer uniquement le répertoire racine
	if ! install -d \
		-o "${DEVOPS_USER}" \
		-g "${DEVOPS_GROUP}" \
		-m 2770 \
		"${project_path}"; then

		print_error \
			"Impossible de créer le répertoire du projet : ${project_path}"
		return 1
	fi

	# Générer les variables générales du projet.
	if ! update_projects "${project_id}"; then
		print_error \
			"Impossible d'initialiser la configuration du projet."
		return 1
	fi

	# Générer les variables du dépôt Git local.
	if ! git_update "${project_id}"; then
		print_error \
			"Impossible d'initialiser la configuration Git du projet."
		return 1
	fi

    # Vérification de project.env
    if [[ ! -f "${project_env}" ]]; then
        print_error \
            "Le fichier project.env est introuvable : ${project_env}"
        return 1
    fi

    # Chargement de project.env
    unset \
        PROJECT_ID \
        PROJECT_NAME \
        PROJECT_TYPE \
        PROJECT_DOCKERED \
        PROJECT_DEBIAN_PACKAGE \
        LOCAL_DEFAULT_BRANCH \
        GIT_USER_NAME \
        GIT_USER_EMAIL

    # shellcheck disable=SC1090
    source "${project_env}"

    # Vérification de l'identifiant du projet
    if [[ "${PROJECT_ID:-}" != "${project_id}" ]]; then
        print_error \
            "PROJECT_ID '${PROJECT_ID:-}' ne correspond pas au projet '${project_id}'."
        return 1
    fi

    # Vérification des variables nécessaires
    if [[ -z "${PROJECT_NAME:-}" ]]; then
        print_error \
            "PROJECT_NAME n'est pas défini dans project.env."
        return 1
    fi

    if [[ -z "${PROJECT_TYPE:-}" ]]; then
        print_error \
            "PROJECT_TYPE n'est pas défini dans project.env."
        return 1
    fi

    # Affectation locale de la configuration du projet
    project_name="${PROJECT_NAME}"
    project_type="${PROJECT_TYPE}"

    # Suite de create_project...

    echo ""
    echo "=============================================="
    echo " Création du projet ${project_name}"
    echo "=============================================="
    echo ""
    echo "Répertoire cible : $project_path"
    echo ""

    # Création des répertoires et fichiers principaux OpenSpec
    # et OpenCode en vue du premier démarrage.
    install -d -o "${DEVOPS_USER}" -g "${DEVOPS_GROUP}" -m 2770 \
        "$project_path" \
        "$project_path/openspec" \
        "$project_path/.opencode/cache" \
        "$project_path/.opencode/cache/bin" \
        "$project_path/.opencode/cache/npm" \
        "$project_path/.opencode/cache/npm/_cacache" \
        "$project_path/.opencode/cache/npm/_cacache/tmp" \
        "$project_path/.opencode/commands" \
        "$project_path/.opencode/config" \
        "$project_path/.opencode/share" \
        "$project_path/.opencode/share/opencode" \
        "$project_path/.opencode/share/opencode/log" \
        "$project_path/.opencode/share/opencode/repos" \
        "$project_path/.opencode/share/opentui" \
        "$project_path/.opencode/skills" \
        "$project_path/.opencode/state" \
        "$project_path/.opencode/state/locks"

    # Création des fichiers .gitignore et opencode.log
    touch "$project_path/.opencode/.gitignore"
    touch "$project_path/.opencode/config/.gitignore"
    touch "$project_path/.opencode/share/opencode/log/opencode.log"

    # État initial de l'interface OpenCode
    printf '%s\n' '{}' > "$project_path/.opencode/state/kv.json"

    # Droits sur les fichiers précédement créés
    chmod 0660 \
        "$project_path/.opencode/.gitignore" \
        "$project_path/.opencode/config/.gitignore" \
        "$project_path/.opencode/share/opencode/log/opencode.log" \
        "$project_path/.opencode/state/kv.json"

    # Création du fichier d'authentification OpenRouter si une clé API est définie
    if [[ "${API_OPENROUTER_KEY}" != "NONE" ]]; then

      cat > "$project_path/.opencode/share/opencode/auth.json" <<EOF
{
	"openrouter": {
		"type": "api",
		"key": "${API_OPENROUTER_KEY}"
	}
}
EOF
      chmod 0660 "$project_path/.opencode/share/opencode/auth.json"
    fi

    # Initialisation d'OpenSpec
    if su - "$DEVOPS_USER" -c "command -v openspec >/dev/null 2>&1"
    then
      su - "$DEVOPS_USER" -c "cd $project_path && openspec init --tools opencode --profile custom" 2>/dev/null
      su - "$DEVOPS_USER" -c "mkdir -p $project_path/openspec/changes/archive"
      su - "$DEVOPS_USER" -c "touch $project_path/openspec/changes/archive/.gitkeep"
      su - "$DEVOPS_USER" -c "mkdir -p $project_path/openspec/specs"
      su - "$DEVOPS_USER" -c "touch $project_path/openspec/specs/.gitkeep"
    else
      echo "❌ ERREUR : OpenSpec non installé dans /home/$DEVOPS_USER"
      exit 1
    fi

    # Si le projet est DIU lui même
    if [[ "${project_name}" == *DIU* ]]; then

      # Copier les fichiers de référence
      cp /root/root-install-debian.sh ${project_path}/
      cp /root/variables.sh ${project_path}/

      chmod 0660 \
        "$project_path/root-install-debian.sh" \
        "$project_path/variables.sh"

      # Créer le répertoire deb
      mkdir -p ${project_path}/deb
      chmod -R 2770 ${project_path}/deb

    fi

    # Le projet appartient à l'utilisateur ${DEVOPS_USER} et au groupe ${DEVOPS_GROUP}.
    chown -R ${DEVOPS_USER}:${DEVOPS_GROUP} ${project_path}

    echo "✅ Projet ${project_name} créé avec succès."
    echo ""

    if command -v tree >/dev/null 2>&1; then
        tree -a "$project_path"
    else
        find "$project_path" -maxdepth 3 -print
    fi

    exit 0
}

delete_project() {
    local project_id="$1"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"
    local project_env="${project_path}/project.env"

    local project_name=""
    local confirmation=""

    # Vérification des paramètres
    if [[ -z "${project_id}" ]]; then
        print_error "Usage : delete_project <project_id>"
        return 1
    fi

    # Vérification du projet
    if [[ ! -e "${project_path}" ]]; then
        print_error \
            "Le projet n'existe pas : ${project_path}"
        return 1
    fi

    # Valeur de secours
    project_name="${project_id}"

    # Chargement éventuel de project.env
    if [[ -f "${project_env}" ]]; then

        unset \
            PROJECT_ID \
            PROJECT_NAME \
            PROJECT_TYPE \
            PROJECT_DOCKERED \
            LOCAL_DEFAULT_BRANCH \
            GIT_USER_NAME \
            GIT_USER_EMAIL \
            REMOTE_CLONE_GIT_TYPE \
            REMOTE_CLONE_BASE_URL \
            REMOTE_CLONE_OWNER \
            REMOTE_CLONE_REPOSITORY \
            REMOTE_CLONE_NAME \
            REMOTE_CLONE_DEFAULT_BRANCH

        # shellcheck disable=SC1090
        source "${project_env}"

        # Vérification de cohérence du PROJECT_ID
        if [[ -n "${PROJECT_ID:-}" ]] && \
           [[ "${PROJECT_ID}" != "${project_id}" ]]; then

            print_error \
                "PROJECT_ID '${PROJECT_ID}' ne correspond pas au projet '${project_id}'."
            return 1
        fi

        # Récupération du nom du projet
        if [[ -n "${PROJECT_NAME:-}" ]]; then
            project_name="${PROJECT_NAME}"
        fi
    else
        print_info \
            "Aucun fichier project.env trouvé pour le projet ${project_id}."
    fi

    # Résumé
    print_title \
        "Suppression du projet ${project_name}"

    printf '%-24s : %s\n' \
        "PROJECT_ID" "${project_id}"

    printf '%-24s : %s\n' \
        "PROJECT_NAME" "${project_name}"

    printf '%-24s : %s\n' \
        "Répertoire" "${project_path}"

    printf '\n'

    print_info \
        "Cette opération supprimera définitivement : ${project_path}"

    printf '\n'

    # Affichage de l'arborescence
    if command -v tree >/dev/null 2>&1; then
        tree -a -L 2 "${project_path}"
        printf '\n'
    fi

    # Confirmation explicite
    read -r -p \
        "Saisir exactement 'YES' pour confirmer : " confirmation

    if [[ "${confirmation}" != "YES" ]]; then
        printf '\n'

        print_info \
            "Suppression annulée."

        return 0
    fi

    # Vérification de sécurité supplémentaire
    if [[ \
        -z "${project_path}" ||
        "${project_path}" == "/" ||
        "${project_path}" == "${DEVOPS_PROJECTS_ROOT}" \
    ]]; then

        print_error \
            "Chemin de suppression invalide ou dangereux : ${project_path}"
        return 1
    fi

    # Suppression du projet
    if ! rm -rf \
        --one-file-system \
        -- "${project_path}"; then

        print_error \
            "Échec de la suppression du projet ${project_name}."
        return 1
    fi

    # Vérification finale
    if [[ -e "${project_path}" ]]; then
        print_error \
            "Le répertoire existe toujours après suppression : ${project_path}"
        return 1
    fi

    printf '\n'

    print_success \
        "Projet ${project_name} supprimé : ${project_path}"

    return 0
}

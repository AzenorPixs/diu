#!/usr/bin/env bash

# Gestions des projets géré par le DIU

projects_update() {
    if [[ "$#" -ne 0 ]]; then
        print_error 'Usage : rid projects update (sans identifiant pour tous les modèles).'
        return 1
    fi
    projects_template_all_all
}

sync_project_template_is_valid() {
    local template_path="${1:-}"
    local template_file=""

    if [[ ! -d "${template_path}" ]]; then
        print_error "Le modèle de projet est introuvable : ${template_path}"
        return 1
    fi

    for template_file in AGENTS.md .gitignore; do
        if [[ ! -f "${template_path}/${template_file}" ]]; then
            print_error "Le fichier modèle est introuvable : ${template_path}/${template_file}"
            return 1
        fi
    done
}

sync_project() {
    local project_id="${1:-}"
    local project_path="${ENV_DEVOPS_PROJECTS_ROOT}/${project_id}"
    local project_env="${project_path}/project.env"
    local template_path="/home/${ENV_DEVOPS_USER}/datas/template"
    local staging_path=""
    local project_name_sed=""
    local project_id_sed=""
    local markdown_file=""
    local template_file=""
    local project_orchestrated_coding=""
    local -a template_files=(AGENTS.md .gitignore)
    local -a synchronized_files=()

    if [[ -z "${project_id}" ]]; then
        print_error "Usage : sync_project <project_id>"
        return 1
    fi

    if [[ ! -d "${project_path}" ]]; then
        print_error "Le répertoire du projet n'existe pas : ${project_path}"
        return 1
    fi

    if [[ ! -f "${project_env}" ]]; then
        print_error "Le fichier project.env est introuvable : ${project_env}"
        return 1
    fi

    if ! project_orchestrated_coding="$(project_orchestrated_coding_get "${project_env}")"; then
        return 1
    fi

    unset PROJECT_ID PROJECT_NAME
    # shellcheck disable=SC1090
    if ! source "${project_env}"; then
        print_error "Impossible de charger la configuration du projet : ${project_env}"
        return 1
    fi

    if [[ "${PROJECT_ID:-}" != "${project_id}" ]]; then
        print_error "PROJECT_ID '${PROJECT_ID:-}' ne correspond pas au projet '${project_id}'."
        return 1
    fi

    if [[ -z "${PROJECT_NAME:-}" ]]; then
        print_error "PROJECT_NAME n'est pas défini dans project.env."
        return 1
    fi

    if ! sync_project_template_is_valid "${template_path}"; then
        return 1
    fi

    if [[ ! -e "${project_path}/DEVELOPMENT_MAP.md" && ! -L "${project_path}/DEVELOPMENT_MAP.md" ]]; then
        if [[ ! -f "${template_path}/DEVELOPMENT_MAP.md" ]]; then
            print_error 'Le fichier modèle DEVELOPMENT_MAP.md est introuvable ou non régulier.'
            return 1
        fi
        template_files+=(DEVELOPMENT_MAP.md)
    fi

    staging_path="$(mktemp -d)" || {
        print_error "Impossible de préparer la synchronisation du projet."
        return 1
    }

    for template_file in "${template_files[@]}"; do
        if ! cp -a -- "${template_path}/${template_file}" "${staging_path}/"; then
            rm -rf -- "${staging_path}"
            print_error "Impossible de préparer le fichier modèle : ${template_file}"
            return 1
        fi
    done

    project_name_sed="$(printf '%s' "${PROJECT_NAME}" | sed 's/[&|\\]/\\&/g')"
    project_id_sed="$(printf '%s' "${PROJECT_ID}" | sed 's/[&|\\]/\\&/g')"

    while IFS= read -r -d '' markdown_file; do
        if ! sed -i \
            -e "s|Template|${project_name_sed}|g" \
            -e "s|template|${project_id_sed}|g" \
            "${markdown_file}"; then

            rm -rf -- "${staging_path}"
            print_error "Impossible de personnaliser le fichier Markdown : ${markdown_file}"
            return 1
        fi
    done < <(find "${staging_path}" -type f -name '*.md' -print0)

    for template_file in "${template_files[@]}"; do
        if [[ "${template_file}" == DEVELOPMENT_MAP.md ]] &&
            [[ -e "${project_path}/${template_file}" || -L "${project_path}/${template_file}" ]]; then
            continue
        fi
        if ! cp -a -- "${staging_path}/${template_file}" "${project_path}/"; then
            rm -rf -- "${staging_path}"
            print_error "Impossible de synchroniser le fichier : ${template_file}"
            return 1
        fi
        synchronized_files+=("${project_path}/${template_file}")
    done

    if ! chown "${ENV_DEVOPS_USER}:${DEVOPS_GROUP}" \
        "${synchronized_files[@]}"; then

        rm -rf -- "${staging_path}"
        print_error "Impossible de définir le propriétaire des ressources synchronisées."
        return 1
    fi

    rm -rf -- "${staging_path}"
    print_success "Projet ${PROJECT_NAME} synchronisé avec succès : ${project_path}"
}

sync_project_all() {
    local projects_root="/home/${ENV_DEVOPS_USER}/datas"
    local template_path="${projects_root}/template"
    local project_path=""
    local project_id=""
    local failure=0
    local selected=0

    if ! sync_project_template_is_valid "${template_path}"; then
        return 1
    fi

    if [[ ! -d "${projects_root}" ]]; then
        print_error "Le répertoire des projets est introuvable : ${projects_root}"
        return 1
    fi

    for project_path in "${projects_root}"/*; do
        if [[ ! -d "${project_path}" || "${project_path}" == "${template_path}" ]]; then
            continue
        fi

        project_id="$(basename "${project_path}")"

        if [[ ! -f "${project_path}/project.env" ]] || ! (
            unset PROJECT_ID PROJECT_NAME
            # shellcheck disable=SC1090,SC1091
            source "${project_path}/project.env"
            [[ "${PROJECT_ID:-}" == "${project_id}" && -n "${PROJECT_NAME:-}" ]]
        ); then

            continue
        fi

        selected=$((selected + 1))
        if ! sync_project "${project_id}"; then
            failure=1
        fi
    done

    if [[ "${selected}" -eq 0 ]]; then
        print_info "Aucun projet valide à synchroniser dans ${projects_root}."
        return 0
    fi

    return "${failure}"
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
        keys[index]="${key}"
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

clone_project() {
    local source_project_id="${1:-}"
    local destination_project_id="${2:-}"
    local source_project_path="${ENV_DEVOPS_PROJECTS_ROOT}/${source_project_id}"
    local destination_project_path="${ENV_DEVOPS_PROJECTS_ROOT}/${destination_project_id}"
    local source_project_env="${source_project_path}/project.env"
    local staging_path=""
    local project_env_line=""
    local project_env_key=""
    local -a project_env_replacements=(PROJECT_ID "${destination_project_id}")

    if [[ -z "${source_project_id}" || -z "${destination_project_id}" ]]; then
        print_error "Usage : clone_project <ID PROJECT SOURCE> <ID PROJECT DESTINATION>"
        return 1
    fi

    if [[ "${source_project_id}" == */* || "${destination_project_id}" == */* ||
        "${source_project_id}" == . || "${source_project_id}" == .. ||
        "${destination_project_id}" == . || "${destination_project_id}" == .. ]]; then
        print_error "Les identifiants de projet ne doivent pas contenir de chemin."
        return 1
    fi

    if [[ ! -d "${source_project_path}" ]]; then
        print_error "Le projet source est introuvable : ${source_project_path}"
        return 1
    fi

    if [[ ! -f "${source_project_env}" ]]; then
        print_error "Le fichier project.env est introuvable : ${source_project_env}"
        return 1
    fi

    if [[ -e "${destination_project_path}" ]]; then
        print_error "Le projet destination existe déjà : ${destination_project_path}"
        return 1
    fi

    staging_path="$(mktemp -d)" || {
        print_error "Impossible de préparer le clonage du projet."
        return 1
    }

    if ! (
        cd -- "${source_project_path}" &&
            tar \
                --exclude='./.git' \
                --exclude='./.git/*' \
                --exclude='*/.git' \
                --exclude='*/.git/*' \
                -cf - .
    ) | (
        cd -- "${staging_path}" && tar -xf -
    ); then
        rm -rf -- "${staging_path}"
        print_error "Impossible de copier le projet source : ${source_project_path}"
        return 1
    fi

    if [[ ! -f "${staging_path}/project.env" ]]; then
        rm -rf -- "${staging_path}"
        print_error "Le fichier project.env est absent de la copie préparée."
        return 1
    fi

    while IFS= read -r project_env_line || [[ -n "${project_env_line}" ]]; do
        if [[ "${project_env_line}" =~ ^[[:space:]]*(export[[:space:]]+)?([A-Za-z_][A-Za-z0-9_]*)[[:space:]]*= ]]; then
            project_env_key="${BASH_REMATCH[2]}"
            case "${project_env_key}" in
                REMOTE_REPOSITORY|REMOTE_FORGEJO_REPOSITORY|REMOTE_GITLAB_REPOSITORY|REMOTE_GITHUB_REPOSITORY|PG_DATABASE)
                    project_env_replacements+=("${project_env_key}" "${destination_project_id}")
                    ;;
            esac
        fi
    done < "${staging_path}/project.env"

    if ! project_env_set_variables \
        "${staging_path}/project.env" \
        "${project_env_replacements[@]}"; then
        rm -rf -- "${staging_path}"
        return 1
    fi

    if ! chown -R "${ENV_DEVOPS_USER}:${DEVOPS_GROUP}" "${staging_path}"; then
        rm -rf -- "${staging_path}"
        print_error "Impossible de définir le propriétaire du projet cloné."
        return 1
    fi

    if ! mv -- "${staging_path}" "${destination_project_path}"; then
        rm -rf -- "${staging_path}"
        print_error "Impossible d'installer le projet cloné : ${destination_project_path}"
        return 1
    fi

    print_success "Projet cloné avec succès : ${destination_project_path}"
    return 0
}

project_orchestrated_coding_get() {
    local project_env="${1:-}"
    local line="" value="No"
    local assignment_pattern='^[[:space:]]*(export[[:space:]]+)?PROJECT_ORCHESTRATED_CODING[[:space:]]*=(.*)$'
    local literal_pattern="^[[:space:]]*(Yes|No|\"Yes\"|\"No\"|'Yes'|'No'|\"\"|''|)([[:space:]]+#.*)?[[:space:]]*$"

    if [[ -z "${project_env}" ]]; then
        print_error 'Usage : project_orchestrated_coding_get <fichier>' >&2
        return 1
    fi
    if [[ ! -e "${project_env}" && ! -L "${project_env}" ]]; then
        printf 'No\n'
        return 0
    fi
    if [[ ! -f "${project_env}" || ! -r "${project_env}" ]]; then
        print_error 'Impossible de lire le mode de développement du projet.' >&2
        return 1
    fi

    # Ne charger aucune autre variable et ne pas exécuter la configuration.
    while IFS= read -r line || [[ -n "${line}" ]]; do
        if [[ "${line}" =~ ${assignment_pattern} ]]; then
            if [[ ! "${BASH_REMATCH[2]}" =~ ${literal_pattern} ]]; then
                print_error 'PROJECT_ORCHESTRATED_CODING doit valoir Yes ou No.' >&2
                return 1
            fi
            case "${BASH_REMATCH[1]}" in
                Yes|'"Yes"'|"'Yes'") value="Yes" ;;
                *) value="No" ;;
            esac
        fi
    done < "${project_env}"
    printf '%s\n' "${value}"
}

project_orchestrated_coding_prompt() {
    local default_value="${1:-No}" value=""

    case "${default_value}" in
        Yes|No) ;;
        *)
            print_error 'PROJECT_ORCHESTRATED_CODING doit valoir Yes ou No.' >&2
            return 1
            ;;
    esac
    while true; do
        if ! read -r -p "PROJECT_ORCHESTRATED_CODING [${default_value}] (Yes/No) : " value; then
            print_error 'Saisie interrompue pour PROJECT_ORCHESTRATED_CODING.' >&2
            return 1
        fi
        value="${value:-${default_value}}"
        case "${value}" in
            Yes|No) printf '%s\n' "${value}"; return 0 ;;
            *) print_error 'PROJECT_ORCHESTRATED_CODING doit valoir Yes ou No.' >&2 ;;
        esac
    done
}

# Génération ou mise à jour des variables générales du <PROJECT_ID>.
update_projects() {
    # shellcheck disable=SC1091
    . "$(dirname -- "${BASH_SOURCE[0]}")/../../lib/project-version.sh" || return 1
    local project_id="${1:-}"
    local project_path="${ENV_DEVOPS_PROJECTS_ROOT}/${project_id}"
    local project_env="${project_path}/project.env"

    local project_name=""
    local project_type="BASH"
    local project_dockered="No"
    local project_debian_package="No"
    local project_orchestrated_coding="No"
    local project_version=""
    local value=""

    if [[ -z "${project_id}" ]]; then
        print_error "Usage : update_projects <project_id>"
        return 1
    fi

    if [[ ! -d "${project_path}" ]]; then
        print_error "Le répertoire du projet n'existe pas : ${project_path}"
        return 1
    fi

    if ! project_orchestrated_coding="$(project_orchestrated_coding_get "${project_env}")"; then
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

    if ! project_version="$(project_version_get "${project_env}")"; then
        return 1
    fi

    print_title "Configuration du projet ${project_id}"

    value=""
    read -r -p "PROJECT_NAME [${project_name}] : " value || return 1
    if [[ -n "${value}" ]]; then
        project_name="${value}"
    fi

    while [[ -z "${project_name}" ]]; do
        print_error "PROJECT_NAME ne peut pas être vide."
        read -r -p "PROJECT_NAME : " project_name || return 1
    done

    value=""
    read -r -p "PROJECT_TYPE (BASH/GO/JAVASCRIPT/PERL/PYTHON) [${project_type}] : " value || return 1
    if [[ -n "${value}" ]]; then
        project_type="${value}"
    fi

    while true; do
        read -r -p "PROJECT_DOCKERED [${project_dockered}] (Yes/No) : " value || return 1
        value="${value:-${project_dockered}}"
        case "${value}" in
            Yes|No) project_dockered="${value}"; break ;;
            *) print_error 'PROJECT_DOCKERED doit valoir Yes ou No.' ;;
        esac
    done
    while true; do
        read -r -p "PROJECT_DEBIAN_PACKAGE [${project_debian_package}] (Yes/No) : " value || return 1
        value="${value:-${project_debian_package}}"
        case "${value}" in
            Yes|No) project_debian_package="${value}"; break ;;
            *) print_error 'PROJECT_DEBIAN_PACKAGE doit valoir Yes ou No.' ;;
        esac
    done
    if ! project_orchestrated_coding="$(project_orchestrated_coding_prompt "${project_orchestrated_coding}")"; then
        return 1
    fi
    while true; do
        read -r -p "PROJECT_VERSION [${project_version}] (x.y.z) : " value || return 1
        value="${value:-${project_version}}"
        if [[ "${value}" =~ ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$ ]] && (( ${#value} <= 128 )); then
            project_version="${value}"
            break
        fi
        print_error 'PROJECT_VERSION doit respecter le format x.y.z sans zéro initial.'
    done

    if ! project_env_set_variables \
        "${project_env}" \
        PROJECT_ID "${project_id}" \
        PROJECT_NAME "${project_name}" \
        PROJECT_TYPE "${project_type}" \
        PROJECT_DOCKERED "${project_dockered}" \
        PROJECT_DEBIAN_PACKAGE "${project_debian_package}" \
        PROJECT_ORCHESTRATED_CODING "${project_orchestrated_coding}" \
        PROJECT_VERSION "${project_version}"; then
        return 1
    fi

    if ! chown "${ENV_DEVOPS_USER}:${DEVOPS_GROUP}" "${project_env}" ||
        ! chmod 660 "${project_env}"; then
        print_error "Impossible de définir les droits de ${project_env}."
        return 1
    fi

    print_success "Variables du projet enregistrées : ${project_env}"
    return 0
}

create_project() {
    local project_id="${1:-}"
    local project_path="${ENV_DEVOPS_PROJECTS_ROOT}/${project_id}"
    local project_env="${project_path}/project.env"
    local template_path="/home/${ENV_DEVOPS_USER}/datas/template"
    local project_name=""
    local project_name_sed=""
    local project_id_sed=""
    local markdown_file=""
    local -a template_exclusions=(! -name ORCHESTRATED_CODING.md)

    if [[ -z "${project_id}" ]]; then
        print_error "Usage : create_project <project_id>"
        return 1
    fi

    if ! check_devops_user; then
        print_error "L'utilisateur DevOps n'est pas disponible."
        return 1
    fi

    if [[ -e "${project_path}" ]]; then
        print_error "Le projet existe déjà : ${project_path}"
        return 1
    fi

    if [[ ! -d "${template_path}" ]]; then
        print_error "Le modèle de projet est introuvable : ${template_path}"
        return 1
    fi

    if ! install -d \
        -o "${ENV_DEVOPS_USER}" \
        -g "${DEVOPS_GROUP}" \
        -m 2770 \
        "${project_path}"; then

        print_error "Impossible de créer le répertoire du projet : ${project_path}"
        return 1
    fi

    if ! update_projects "${project_id}"; then
        print_error "Impossible d'initialiser la configuration du projet."
        return 1
    fi

    if [[ ! -f "${project_env}" ]]; then
        print_error "Le fichier project.env est introuvable : ${project_env}"
        return 1
    fi

    if ! project_orchestrated_coding_get "${project_env}" >/dev/null; then
        return 1
    fi

    unset PROJECT_ID PROJECT_NAME PROJECT_TYPE

    # shellcheck disable=SC1090
    source "${project_env}"

    if [[ "${PROJECT_ID:-}" != "${project_id}" ]]; then
        print_error "PROJECT_ID '${PROJECT_ID:-}' ne correspond pas au projet '${project_id}'."
        return 1
    fi

    if [[ -z "${PROJECT_NAME:-}" ]]; then
        print_error "PROJECT_NAME n'est pas défini dans project.env."
        return 1
    fi

    project_name="${PROJECT_NAME}"
    project_name_sed="$(printf '%s' "${project_name}" | sed 's/[&|\\]/\\&/g')"
    project_id_sed="$(printf '%s' "${project_id}" | sed 's/[&|\\]/\\&/g')"

    if [[ "${PROJECT_TYPE:-}" != PYTHON ]]; then
        template_exclusions+=(! -name pyproject.toml)
    fi
    if ! find "${template_path}" -mindepth 1 -maxdepth 1 ! -name project.env ! -name .git \
        "${template_exclusions[@]}" \
        -exec cp -a -- {} "${project_path}/" \;; then

        print_error "Impossible de copier le modèle de projet : ${template_path}"
        return 1
    fi

    while IFS= read -r -d '' markdown_file; do
        if ! sed -i \
            -e "s|Template|${project_name_sed}|g" \
            -e "s|template|${project_id_sed}|g" \
            "${markdown_file}"; then

            print_error "Impossible de personnaliser le fichier Markdown : ${markdown_file}"
            return 1
        fi
    done < <(find "${project_path}" -type f -name '*.md' -print0)

    if ! chown -R "${ENV_DEVOPS_USER}:${DEVOPS_GROUP}" "${project_path}"; then
        print_error "Impossible de définir le propriétaire du projet : ${project_path}"
        return 1
    fi

    if ! projects_template_openspec "${project_id}"; then
        print_error "Projet préparé mais initialisation ou mise à jour OpenSpec échouée : ${project_path}"
        return 1
    fi

    if ! projects_template_devops "${project_id}"; then
        print_error "Projet préparé mais génération de DEVOPS.md échouée : ${project_path}"
        return 1
    fi

    print_success "Projet ${project_name} créé avec succès : ${project_path}"
    return 0
}

delete_project() {
    local project_id="$1"
    local project_path="${ENV_DEVOPS_PROJECTS_ROOT}/${project_id}"
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
        "${project_path}" == "${ENV_DEVOPS_PROJECTS_ROOT}" \
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

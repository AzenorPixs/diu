#!/usr/bin/env bash

# Gestion Git au sein des projets géré par le DIU

# Flux CI/CD DIU
cicd_project_diu() {

    local project_id="diu"
    local project_path=""
    local project_name="Debian Installer Unifié"
    local commit_name="${1:-}"
    local commit_tag="${2:-}"

    # ==========================================================
    # Validation des arguments
    # ==========================================================

    if [[ -z "${project_id}" || -z "${project_name}" || -z "${commit_name}" ]]; then
        print_error "Usage : cicd_project <ID Projet> <Nom Projet> <Nom du Commit>"
        return 1
    fi

    # ==========================================================
    # Vérification de l'environnement
    #
    # CI/CD autorisé uniquement dans l'environnement de
    # développement du DIU.
    #
    # Production :
    #   /root/diu
    #
    # Développement :
    #   /home/devops/datas/diu
    # ==========================================================

    if [[ "${DEVOPS_PROJECTS_ROOT}" != "/home/devops/datas" ]]; then
        print_error "La commande CI/CD est interdite dans l'environnement de production."
        print_error "Environnement autorisé : /home/devops/datas/diu"
        print_error "Environnement détecté : ${DEVOPS_PROJECTS_ROOT}/${project_id}"
        return 1
    fi

    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"
    local project_env="${project_path}/project.env"

    if [[ ! -d "${project_path}" ]]; then
        print_error "Projet introuvable : ${project_path}"
        return 1
    fi

    if [[ ! -d "/home/devops/datas/diu" ]]; then
        print_error "L'environnement de développement DIU est introuvable."
        return 1
    fi

    # Sécurité supplémentaire :
    # on vérifie que le projet DIU courant est bien celui
    # attendu par le workflow de développement.

    if [[ "$(realpath "${project_path}")" != "/home/devops/datas/${project_id}" ]]; then
        print_error "Chemin du projet inattendu : ${project_path}"
        return 1
    fi

    # ==========================================================
    # Affichage
    # ==========================================================

    print_title "CI/CD du projet ${project_name}"

    print_info "Projet       : ${project_name}"
    print_info "ID Projet    : ${project_id}"
    print_info "Répertoire   : ${project_path}"
    print_info "Commit       : ${commit_name}"

    # ==========================================================
    # Étape 1 — Commit Git
    # ==========================================================

    print_title "Étape 1/4 — Commit Git"

    if ! git_commit \
        "${project_id}" \
        "${commit_name}" \
        "${commit_tag}"; then

        print_error "Échec du commit Git."
        return 1
    fi

    # ==========================================================
    # Étape 2 — Push Git
    # ==========================================================

    print_title "Étape 2/4 — Push Git"

    if ! forgejo_push \
        "${project_id}"; then

        print_error "Échec du push Git."
        return 1
    fi

    # ==========================================================
    # Étape 3 — Build Debian
    # ==========================================================

    print_title "Étape 3/4 — Build du paquet Debian"

    if ! build_deb_diu ; then

        print_error "Échec de la construction du paquet Debian."
        return 1
    fi

    # ==========================================================
    # Étape 4 — Publication Release Forgejo
    # ==========================================================

    print_title "Étape 4/4 — Publication de la Release Forgejo"

    if ! publish_release_diu ; then

        print_error "Échec de la publication de la Release Forgejo."
        return 1
    fi

    # ==========================================================
    # Succès
    # ==========================================================

    print_success "CI/CD du projet ${project_name} terminé avec succès."

    return 0
}

# Flux CI/CD pour les images Docker des projets géré par le DIU
cicd_project_docker_release() {

    local project_id="${1:-}"
    local commit_name="${2:-}"
    local commit_tag="${3:-}"

    local project_path=""
    local project_env=""
    local project_name=""

    # ==========================================================
    # Validation des arguments
    # ==========================================================

    if [[ \
        -z "${project_id}" ||
        -z "${commit_name}" ||
        -z "${commit_tag}" \
    ]]; then

        print_error \
            "Usage : cicd_project_docker_release <PROJECT_ID> <COMMIT_NAME> <COMMIT_TAG>"
        return 1
    fi

    # ==========================================================
    # Définition des chemins
    # ==========================================================

    project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"
    project_env="${project_path}/project.env"

    # ==========================================================
    # Vérification du projet
    # ==========================================================

    if [[ ! -d "${project_path}" ]]; then
        print_error \
            "Projet introuvable : ${project_path}"
        return 1
    fi

    if [[ ! -f "${project_env}" ]]; then
        print_error \
            "Fichier project.env introuvable : ${project_env}"
        return 1
    fi

    # ==========================================================
    # Chargement de project.env
    # ==========================================================

    unset \
        PROJECT_ID \
        PROJECT_NAME \
        PROJECT_TYPE \
        PROJECT_DOCKERED \
        LOCAL_DEFAULT_BRANCH \
        GIT_USER_NAME \
        GIT_USER_EMAIL

    # shellcheck disable=SC1090
    source "${project_env}"

    # ==========================================================
    # Vérification de la configuration du projet
    # ==========================================================

    if [[ -z "${PROJECT_ID:-}" ]]; then
        print_error \
            "PROJECT_ID n'est pas défini dans project.env."
        return 1
    fi

    if [[ "${PROJECT_ID}" != "${project_id}" ]]; then
        print_error \
            "PROJECT_ID '${PROJECT_ID}' ne correspond pas au projet '${project_id}'."
        return 1
    fi

    if [[ -z "${PROJECT_NAME:-}" ]]; then
        print_error \
            "PROJECT_NAME n'est pas défini dans project.env."
        return 1
    fi

    if [[ "${PROJECT_DOCKERED:-No}" != "Yes" ]]; then
        print_error \
            "Le projet '${project_id}' n'est pas déclaré comme Dockerisé."
        return 1
    fi

    project_name="${PROJECT_NAME}"

    # ==========================================================
    # Affichage
    # ==========================================================

    print_title \
        "CI/CD Docker Release du projet ${project_name}"

    print_info \
        "Projet       : ${project_name}"

    print_info \
        "ID Projet    : ${project_id}"

    print_info \
        "Répertoire   : ${project_path}"

    print_info \
        "Commit       : ${commit_name}"

    print_info \
        "Tag          : ${commit_tag}"

    # ==========================================================
    # Étape 1 — Commit Git
    # ==========================================================

    print_title \
        "Étape 1/4 — Commit Git"

    if ! git_commit \
        "${project_id}" \
        "${commit_name}" \
        "${commit_tag}"; then

        print_error \
            "Échec du commit Git."
        return 1
    fi

    # ==========================================================
    # Étape 2 — Push Git
    # ==========================================================

    print_title \
        "Étape 2/4 — Push Git"

    if ! forgejo_push \
        "${project_id}"; then

        print_error \
            "Échec du push Git."
        return 1
    fi

    # ==========================================================
    # Étape 3 — Build Docker
    # ==========================================================

    print_title \
        "Étape 3/4 — Build de l'image Docker"

    if ! projects_docker_build \
        "${project_id}"; then

        print_error \
            "Échec de la construction de l'image Docker."
        return 1
    fi

    # ==========================================================
    # Étape 4 — Publication Release Docker
    # ==========================================================

    print_title \
        "Étape 4/4 — Publication de la Release Docker"

    if ! projects_forgejo_release \
        "${project_id}"; then

        print_error \
            "Échec de la publication de la Release Docker."
        return 1
    fi

    # ==========================================================
    # Succès
    # ==========================================================

    print_success \
        "CI/CD Docker Release du projet ${project_name} terminé avec succès."

    return 0
}

# Analalyse le dépot le local Git pour le projet <PROJECT ID>
git_analyse() {
    local project_id="$1"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"
    local project_env="${project_path}/project.env"

    local project_name=""

    local git_root=""
    local current_branch=""
    local upstream_branch=""
    local commit_count="0"
    local tracked_count="0"
    local untracked_count="0"
    local ignored_count="0"
    local modified_count="0"
    local staged_count="0"
    local ahead_count="0"
    local behind_count="0"
    local hooks_path=""
    local remote_name=""

    # Vérification des paramètres
    if [[ -z "${project_id}" ]]; then
        print_error "Usage : git_analyse <project_id>"
        return 1
    fi

    # Vérification de l'utilisateur DevOps
    if ! check_devops_user; then
        print_error "L'utilisateur DevOps n'est pas disponible."
        return 1
    fi

    # Vérification du projet
    if [[ ! -d "${project_path}" ]]; then
        print_error "Projet introuvable : ${project_path}"
        return 1
    fi

    # Vérification de Git
    if ! command -v git >/dev/null 2>&1; then
        print_error "La commande Git est introuvable."
        return 1
    fi

    if ! runuser -u "${DEVOPS_USER}" -- \
        git --version >/dev/null 2>&1; then

        print_error \
            "Git n'est pas accessible pour ${DEVOPS_USER}."
        return 1
    fi

    # Chargement de project.env
    if [[ ! -f "${project_env}" ]]; then
        print_info \
            "Le fichier project.env est absent pour le projet ${project_id}."

        if ! update_projects "${project_id}" ||
            ! git_update "${project_id}"; then
            print_error \
                "Impossible d'initialiser la configuration Git du projet."
            return 1
        fi
    fi

    if [[ ! -f "${project_env}" ]]; then
        print_error \
            "Le fichier project.env est toujours absent : ${project_env}"
        return 1
    fi

    # Nettoyage des variables susceptibles d'être déjà présentes
    unset \
        PROJECT_ID \
        PROJECT_NAME \
        PROJECT_TYPE \
        PROJECT_DOCKERED \
        LOCAL_DEFAULT_BRANCH \
        GIT_USER_NAME \
        GIT_USER_EMAIL

    # shellcheck disable=SC1090
    source "${project_env}"

    # Vérification des variables essentielles
    if [[ \
        -z "${PROJECT_ID:-}" ||
        -z "${PROJECT_NAME:-}" \
    ]]; then

        print_info \
            "La configuration du projet est incomplète."

        if ! update_projects "${project_id}" ||
            ! git_update "${project_id}"; then
            print_error \
                "Impossible de mettre à jour la configuration Git du projet."
            return 1
        fi

        # Recharge project.env après git_update
        unset \
            PROJECT_ID \
            PROJECT_NAME \
            PROJECT_TYPE \
            PROJECT_DOCKERED \
            LOCAL_DEFAULT_BRANCH \
            GIT_USER_NAME \
            GIT_USER_EMAIL

        # shellcheck disable=SC1090
        source "${project_env}"
    fi

    # Vérification finale des variables essentielles
    if [[ -z "${PROJECT_ID:-}" ]]; then
        print_error "PROJECT_ID n'est pas défini dans project.env."
        return 1
    fi

    if [[ "${PROJECT_ID}" != "${project_id}" ]]; then
        print_error \
            "PROJECT_ID '${PROJECT_ID}' ne correspond pas au projet '${project_id}'."
        return 1
    fi

    if [[ -z "${PROJECT_NAME:-}" ]]; then
        print_error "PROJECT_NAME n'est pas défini dans project.env."
        return 1
    fi

    # Affectation locale de la configuration du projet
    project_name="${PROJECT_NAME}"

    print_title "Analyse du dépôt Git"

    # Vérification des droits d'accès
    if ! runuser -u "${DEVOPS_USER}" -- \
        test -r "${project_path}"; then

        print_error \
            "${DEVOPS_USER} ne peut pas lire le projet : ${project_path}"
        return 1
    fi

    # Vérification du dépôt Git
    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" rev-parse \
        --is-inside-work-tree >/dev/null 2>&1; then

        print_error \
            "Aucun dépôt Git valide dans : ${project_path}"
        return 1
    fi

    # Informations générales
    git_root="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" rev-parse \
            --show-toplevel 2>/dev/null
    )"

    current_branch="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" branch \
            --show-current 2>/dev/null
    )"

    if [[ -z "${current_branch}" ]]; then
        current_branch="HEAD détachée"
    fi

    upstream_branch=""

    if upstream_branch="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" rev-parse \
            --abbrev-ref \
            --symbolic-full-name \
            '@{upstream}' 2>/dev/null
    )"; then
        :
    fi

    # Calcul des statistiques
    tracked_count="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" ls-files \
            2>/dev/null |
            wc -l |
            tr -d ' '
    )"

    untracked_count="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" ls-files \
            --others \
            --exclude-standard \
            2>/dev/null |
            wc -l |
            tr -d ' '
    )"

    ignored_count="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" ls-files \
            --others \
            --ignored \
            --exclude-standard \
            2>/dev/null |
            wc -l |
            tr -d ' '
    )"

    modified_count="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" diff \
            --name-only \
            2>/dev/null |
            wc -l |
            tr -d ' '
    )"

    staged_count="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" diff \
            --cached \
            --name-only \
            2>/dev/null |
            wc -l |
            tr -d ' '
    )"

    if runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" rev-parse \
        --verify HEAD >/dev/null 2>&1; then

        commit_count="$(
            runuser -u "${DEVOPS_USER}" -- \
                git -C "${project_path}" rev-list \
                --count HEAD 2>/dev/null
        )"
    fi

    # Informations générales
    print_title "Informations générales"

    printf 'Projet             : %s\n' "${project_name}"
    printf 'Identifiant        : %s\n' "${project_id}"
    printf 'Répertoire         : %s\n' "${project_path}"
    printf 'Racine Git         : %s\n' "${git_root}"
    printf 'Utilisateur Git    : %s\n' "${DEVOPS_USER}"

    printf 'Version Git        : %s\n' "$(
        runuser -u "${DEVOPS_USER}" -- git --version
    )"

    printf 'Branche courante   : %s\n' "${current_branch}"

    if [[ -n "${upstream_branch}" ]]; then
        printf 'Branche de suivi   : %s\n' "${upstream_branch}"
    else
        printf 'Branche de suivi   : aucune\n'
    fi

    if runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" rev-parse \
        --is-bare-repository 2>/dev/null |
        grep -qx 'true'; then

        printf 'Type de dépôt      : dépôt nu\n'
    else
        printf 'Type de dépôt      : dépôt de travail\n'
    fi

    if runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" rev-parse \
        --is-shallow-repository >/dev/null 2>&1; then

        printf 'Dépôt superficiel  : %s\n' "$(
            runuser -u "${DEVOPS_USER}" -- \
                git -C "${project_path}" rev-parse \
                --is-shallow-repository
        )"
    fi

    # Résumé du dépôt
    print_title "Résumé du dépôt"

    printf 'Nombre de commits        : %s\n' "${commit_count}"
    printf 'Fichiers suivis          : %s\n' "${tracked_count}"
    printf 'Fichiers modifiés        : %s\n' "${modified_count}"
    printf 'Fichiers indexés         : %s\n' "${staged_count}"
    printf 'Fichiers non suivis      : %s\n' "${untracked_count}"
    printf 'Fichiers ignorés         : %s\n' "${ignored_count}"

    # État du dépôt
    print_title "État du dépôt"

    runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" status \
        --short \
        --branch \
        --untracked-files=all

    if [[ -z "$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" status \
            --porcelain=v1
    )" ]]; then

        printf '\nDépôt propre : aucune modification locale.\n'
    fi

    # Fichiers suivis
    print_title "Fichiers suivis"

    if [[ "${tracked_count}" -gt 0 ]]; then
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" ls-files
    else
        printf 'Aucun fichier suivi.\n'
    fi

    # Modifications non indexées
    print_title "Modifications non indexées"

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" diff --quiet; then

        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" diff --stat

        printf '\n'

        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" diff --name-status
    else
        printf 'Aucune modification non indexée.\n'
    fi

    # Modifications indexées
    print_title "Modifications indexées pour le prochain commit"

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" diff \
        --cached --quiet; then

        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" diff \
            --cached --stat

        printf '\n'

        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" diff \
            --cached --name-status
    else
        printf 'Aucune modification indexée.\n'
    fi

    # Fichiers non suivis
    print_title "Fichiers non suivis"

    if [[ "${untracked_count}" -gt 0 ]]; then
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" ls-files \
            --others \
            --exclude-standard
    else
        printf 'Aucun fichier non suivi.\n'
    fi

    # Configuration Git locale
    print_title "Configuration Git locale"

    if runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" config \
        --local \
        --list \
        --show-origin |
        grep -q .; then

        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" config \
            --local \
            --list \
            --show-origin |
            sed -E \
                's#(https?://)[^/@:]+:[^/@]+@#\1***:***@#g'
    else
        printf 'Aucune configuration locale spécifique.\n'
    fi

    # Configuration Git effective
    print_title "Configuration Git effective"

    runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" config \
        --list \
        --show-origin \
        --show-scope |
        sed -E \
            's#(https?://)[^/@:]+:[^/@]+@#\1***:***@#g'

    # Identité Git
    print_title "Identité Git"

    printf 'Nom   : %s\n' "$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" config \
            user.name 2>/dev/null ||
            printf 'non défini'
    )"

    printf 'Email : %s\n' "$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" config \
            user.email 2>/dev/null ||
            printf 'non défini'
    )"

    # Dépôts distants
    print_title "Dépôts distants"

    if runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" remote |
        grep -q .; then

        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" remote -v |
            sed -E \
                's#(https?://)[^/@:]+:[^/@]+@#\1***:***@#g'

        printf '\nDétails locaux des dépôts distants :\n'

        while IFS= read -r remote_name; do
            [[ -n "${remote_name}" ]] || continue

            printf '\n--- %s ---\n' "${remote_name}"

            if ! runuser -u "${DEVOPS_USER}" -- \
                git -C "${project_path}" remote \
                show -n "${remote_name}" 2>/dev/null; then

                printf \
                    'Informations distantes indisponibles.\n'
            fi

        done < <(
            runuser -u "${DEVOPS_USER}" -- \
                git -C "${project_path}" remote
        )
    else
        printf 'Aucun dépôt distant configuré.\n'
    fi

    # Branches locales
    print_title "Branches locales"

    if runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" branch \
        --list |
        grep -q .; then

        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" branch \
            --verbose \
            --verbose \
            --no-abbrev
    else
        printf 'Aucune branche locale avec commit.\n'
    fi

    # Branches distantes
    print_title "Branches distantes"

    if runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" branch \
        --remotes \
        --list |
        grep -q .; then

        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" branch \
            --remotes \
            --verbose \
            --no-abbrev
    else
        printf 'Aucune branche distante connue.\n'
    fi

    # Synchronisation avec la branche distante
    print_title "Synchronisation avec la branche distante"

    if [[ -n "${upstream_branch}" ]]; then

        ahead_count="0"

        if ahead_count="$(
            runuser -u "${DEVOPS_USER}" -- \
                git -C "${project_path}" rev-list \
                --count \
                "${upstream_branch}..HEAD" 2>/dev/null
        )"; then
            :
        else
            ahead_count="0"
        fi

        behind_count="0"

        if behind_count="$(
            runuser -u "${DEVOPS_USER}" -- \
                git -C "${project_path}" rev-list \
                --count \
                "HEAD..${upstream_branch}" 2>/dev/null
        )"; then
            :
        else
            behind_count="0"
        fi

        printf 'Branche suivie     : %s\n' "${upstream_branch}"
        printf 'Commits en avance  : %s\n' "${ahead_count}"
        printf 'Commits en retard  : %s\n' "${behind_count}"
    else
        printf 'Aucune branche distante suivie.\n'
    fi

    # Tags
    print_title "Tags"

    if runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" tag \
        --list |
        grep -q .; then

        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" tag \
            --list \
            --sort=-creatordate \
            --format='%(refname:short) | %(creatordate:iso8601) | %(subject)'
    else
        printf 'Aucun tag défini.\n'
    fi

    # Historique des commits
    print_title "Historique des commits"

    if runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" rev-parse \
        --verify HEAD >/dev/null 2>&1; then

        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" log \
            --all \
            --date=iso-local \
            --pretty=format:'%h | %ad | %an <%ae> | %d%n    %s%n' \
            --decorate \
            --max-count=50

        printf '\n'
    else
        printf 'Le dépôt ne contient encore aucun commit.\n'
    fi

    # Graphe des commits
    print_title "Graphe des commits"

    if runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" rev-parse \
        --verify HEAD >/dev/null 2>&1; then

        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" log \
            --graph \
            --decorate \
            --oneline \
            --all \
            --max-count=50
    else
        printf 'Aucun historique disponible.\n'
    fi

    # Dernier commit
    print_title "Dernier commit"

    if runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" rev-parse \
        --verify HEAD >/dev/null 2>&1; then

        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" show \
            --stat \
            --summary \
            --date=iso-local \
            --format='
Commit       : %H
Commit court : %h
Auteur       : %an <%ae>
Date auteur  : %ad
Validateur   : %cn <%ce>
Date commit  : %cd
Références   : %D
Objet        : %s
'
    else
        printf 'Aucun commit disponible.\n'
    fi

    # Horodatage du dépôt
    print_title "Horodatage du dépôt"

    if runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" rev-parse \
        --verify HEAD >/dev/null 2>&1; then

        printf 'Premier commit :\n'

        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" log \
            --reverse \
            --max-count=1 \
            --date=iso-local \
            --format='  %H%n  %ad%n  %an <%ae>%n  %s'

        printf '\n\nDernier commit :\n'

        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" log \
            -1 \
            --date=iso-local \
            --format='  %H%n  %ad%n  %an <%ae>%n  %s'

        printf '\n'
    else
        printf 'Aucun horodatage disponible.\n'
    fi

    # Contributions par auteur
    print_title "Contributions par auteur"

    if runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" rev-parse \
        --verify HEAD >/dev/null 2>&1; then

        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" shortlog \
            --summary \
            --numbered \
            --email \
            HEAD
    else
        printf 'Aucune contribution enregistrée.\n'
    fi

    # Taille et objets du dépôt
    print_title "Taille et objets du dépôt"

    runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" count-objects \
        --verbose \
        --human-readable

    # Sous-modules
    print_title "Sous-modules"

    if [[ -f "${project_path}/.gitmodules" ]]; then

        if ! runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" submodule \
            status 2>/dev/null; then

            printf 'Impossible de lire les sous-modules.\n'
        fi
    else
        printf 'Aucun sous-module configuré.\n'
    fi

    # Hooks Git actifs
    print_title "Hooks Git actifs"

    hooks_path=""

    if hooks_path="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" config \
            --path core.hooksPath 2>/dev/null
    )"; then
        :
    fi

    if [[ -z "${hooks_path}" ]]; then
        hooks_path="$(
            runuser -u "${DEVOPS_USER}" -- \
                git -C "${project_path}" rev-parse \
                --git-path hooks
        )"
    elif [[ "${hooks_path}" != /* ]]; then
        hooks_path="${project_path}/${hooks_path}"
    fi

    printf 'Répertoire des hooks : %s\n' "${hooks_path}"

    if runuser -u "${DEVOPS_USER}" -- \
        test -d "${hooks_path}" &&
        runuser -u "${DEVOPS_USER}" -- \
            find "${hooks_path}" \
            -maxdepth 1 \
            -type f \
            -executable \
            ! -name '*.sample' |
            grep -q .; then

        runuser -u "${DEVOPS_USER}" -- \
            find "${hooks_path}" \
            -maxdepth 1 \
            -type f \
            -executable \
            ! -name '*.sample' \
            -printf '%f\n' |
            sort
    else
        printf 'Aucun hook Git actif.\n'
    fi

    # Vérification finale
    print_title "Fin de l'analyse"

    printf 'Analyse Git terminée pour : %s\n' \
        "${project_name}"

    print_success \
        "Dépôt analysé avec l'utilisateur ${DEVOPS_USER}."

    return 0
}

# Commit vers le dépôt local Git le projet <PROJECT ID>
git_commit() {
    local project_id="$1"
    local commit_name="$2"
    local commit_tag="$3"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"
    local project_env="${project_path}/project.env"

    local project_name=""
    local git_user_name=""
    local git_user_email=""
    local -a git_local_command=(env -u GIT_COMMON_DIR git)

    # Vérification des paramètres
    if [[ \
        -z "${project_id}" ||
        -z "${commit_name}" ||
        -z "${commit_tag}" \
    ]]; then

        print_error \
            "Usage : git_commit <project_id> <commit_name> <commit_tag>"
        return 1
    fi

    # Vérification de l'utilisateur DevOps
    if ! check_devops_user; then
        print_error "L'utilisateur DevOps n'existe pas."
        return 1
    fi

    # Vérification du projet
    if [[ ! -d "${project_path}" ]]; then
        print_error "Projet introuvable : ${project_path}"
        return 1
    fi

    # Vérification de Git
    if ! command -v git >/dev/null 2>&1; then
        print_error "Git n'est pas installé."
        return 1
    fi

    if ! runuser -u "${DEVOPS_USER}" -- \
        git --version >/dev/null 2>&1; then

        print_error \
            "Git n'est pas accessible pour ${DEVOPS_USER}."
        return 1
    fi

    # Chargement de project.env
    if [[ ! -f "${project_env}" ]]; then
        print_info \
            "Le fichier project.env est absent pour le projet ${project_id}."

        if ! update_projects "${project_id}" ||
            ! git_update "${project_id}"; then
            print_error \
                "Impossible d'initialiser la configuration du projet."
            return 1
        fi
    fi

    if [[ ! -f "${project_env}" ]]; then
        print_error \
            "Le fichier project.env est toujours absent : ${project_env}"
        return 1
    fi

    # Nettoyage des variables susceptibles d'être déjà présentes
    unset \
        PROJECT_ID \
        PROJECT_NAME \
        PROJECT_TYPE \
        PROJECT_DOCKERED \
        LOCAL_DEFAULT_BRANCH \
        GIT_USER_NAME \
        GIT_USER_EMAIL

    # shellcheck disable=SC1090
    source "${project_env}"

    # Vérification des variables essentielles
    if [[ \
        -z "${PROJECT_ID:-}" ||
        -z "${PROJECT_NAME:-}" ||
        -z "${GIT_USER_NAME:-}" ||
        -z "${GIT_USER_EMAIL:-}" \
    ]]; then

        print_info \
            "La configuration du projet est incomplète."

        if ! update_projects "${project_id}" ||
            ! git_update "${project_id}"; then
            print_error \
                "Impossible de mettre à jour la configuration du projet."
            return 1
        fi

        # Recharge project.env après git_update
        unset \
            PROJECT_ID \
            PROJECT_NAME \
            PROJECT_TYPE \
            PROJECT_DOCKERED \
            LOCAL_DEFAULT_BRANCH \
            GIT_USER_NAME \
            GIT_USER_EMAIL

        # shellcheck disable=SC1090
        source "${project_env}"
    fi

    # Vérification finale des variables essentielles
    if [[ -z "${PROJECT_ID:-}" ]]; then
        print_error "PROJECT_ID n'est pas défini dans project.env."
        return 1
    fi

    if [[ "${PROJECT_ID}" != "${project_id}" ]]; then
        print_error \
            "PROJECT_ID '${PROJECT_ID}' ne correspond pas au projet '${project_id}'."
        return 1
    fi

    if [[ -z "${PROJECT_NAME:-}" ]]; then
        print_error "PROJECT_NAME n'est pas défini dans project.env."
        return 1
    fi

    if [[ -z "${GIT_USER_NAME:-}" ]]; then
        print_error "GIT_USER_NAME n'est pas défini dans project.env."
        return 1
    fi

    if [[ -z "${GIT_USER_EMAIL:-}" ]]; then
        print_error "GIT_USER_EMAIL n'est pas défini dans project.env."
        return 1
    fi

    # Affectation locale de la configuration du projet
    project_name="${PROJECT_NAME}"
    git_user_name="${GIT_USER_NAME}"
    git_user_email="${GIT_USER_EMAIL}"

    print_title "Commit Git ${project_name} : ${project_path}"

    # Vérification du dépôt Git local
    if [[ "$(runuser -u "${DEVOPS_USER}" -- \
        "${git_local_command[@]}" -C "${project_path}" rev-parse \
        --is-inside-work-tree 2>/dev/null)" != "true" ]]; then

        print_info "Aucun dépôt Git initialisé. Initialisation en cours..."

        if ! git_init "${project_id}"; then
            print_error "Impossible d'initialiser le dépôt Git local."
            return 1
        fi

        if [[ "$(runuser -u "${DEVOPS_USER}" -- \
            "${git_local_command[@]}" -C "${project_path}" rev-parse \
            --is-inside-work-tree 2>/dev/null)" != "true" ]]; then

            print_error "Aucun dépôt Git initialisé."
            return 1
        fi
    fi

    # Vérification des droits
    if ! runuser -u "${DEVOPS_USER}" -- \
        test -w "${project_path}"; then

        print_error \
            "${DEVOPS_USER} ne peut pas écrire dans ${project_path}"
        return 1
    fi

    # Configuration de l'identité Git locale du projet
    if ! runuser -u "${DEVOPS_USER}" -- \
        "${git_local_command[@]}" -C "${project_path}" config --local \
        user.name "${git_user_name}"; then

        print_error "Échec de la configuration de user.name."
        return 1
    fi

    if ! runuser -u "${DEVOPS_USER}" -- \
        "${git_local_command[@]}" -C "${project_path}" config --local \
        user.email "${git_user_email}"; then

        print_error "Échec de la configuration de user.email."
        return 1
    fi

    # Ajout des fichiers
    print_info "Ajout des modifications..."

    if ! runuser -u "${DEVOPS_USER}" -- \
        "${git_local_command[@]}" -C "${project_path}" add .; then

        print_error "Échec du git add."
        return 1
    fi

    # Vérification des modifications
    if runuser -u "${DEVOPS_USER}" -- \
        "${git_local_command[@]}" -C "${project_path}" diff \
        --cached --quiet; then

        print_info "Aucune modification à enregistrer."
        return 0
    fi

    # Résumé avant commit
    print_title "Résumé des modifications"

    if ! runuser -u "${DEVOPS_USER}" -- \
        "${git_local_command[@]}" -C "${project_path}" status --short; then

        print_error \
            "Impossible d'afficher le résumé des modifications."
        return 1
    fi

    # Création du commit
    print_title "Création du commit"

    if ! runuser -u "${DEVOPS_USER}" -- \
        "${git_local_command[@]}" -C "${project_path}" commit \
        -m "${commit_name}"; then

        print_error "Échec du commit Git."
        return 1
    fi

    # Création du tag
    print_title "Création du tag Git"

    if ! runuser -u "${DEVOPS_USER}" -- \
        "${git_local_command[@]}" -C "${project_path}" tag \
        -a "${commit_tag}" \
        -m "${commit_name}"; then

        print_error \
            "Échec de la création du tag Git '${commit_tag}'."
        return 1
    fi

    print_success \
        "Tag Git '${commit_tag}' créé avec succès."

    # Vérification finale
    print_title "Historique Git"

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" log \
        --oneline \
        --decorate \
        -5; then

        print_error \
            "Impossible de lire l'historique Git."
        return 1
    fi

    printf '\n'

    print_success "Commit Git créé avec succès."

    return 0
}

# Commit vers les dépôts Git locaux de tous les projets configurés
git_commit_all() {
    local commit_name="${1:-}"
    local commit_tag="${2:-}"
    local project_path=""
    local project_id=""
    local project_env=""
    local failed=0
    local selected=0

    if [[ -z "${commit_name}" || -z "${commit_tag}" ]]; then
        print_error "Usage : git_commit_all <commit_name> <commit_tag>"
        return 1
    fi

    if [[ ! -d "${DEVOPS_PROJECTS_ROOT}" ]]; then
        print_error "Répertoire des projets introuvable : ${DEVOPS_PROJECTS_ROOT}"
        return 1
    fi

    print_title "Commit Git de tous les projets configurés"

    for project_path in "${DEVOPS_PROJECTS_ROOT}"/*; do
        if [[ ! -d "${project_path}" ]]; then
            continue
        fi

        project_id="$(basename -- "${project_path}")"
        project_env="${project_path}/project.env"

        if [[ ! -f "${project_env}" ]]; then
            print_info "Projet ignoré : ${project_id} (project.env absent)."
            continue
        fi

        unset \
            PROJECT_ID \
            PROJECT_NAME \
            PROJECT_TYPE \
            PROJECT_DOCKERED \
            LOCAL_DEFAULT_BRANCH \
            GIT_USER_NAME \
            GIT_USER_EMAIL

        # shellcheck disable=SC1090
        if ! source "${project_env}"; then
            print_error "Projet ignoré : ${project_id} (project.env illisible)."
            continue
        fi

        if [[ \
            -z "${PROJECT_ID:-}" || \
            "${PROJECT_ID}" != "${project_id}" || \
            -z "${PROJECT_NAME:-}" || \
            -z "${GIT_USER_NAME:-}" || \
            -z "${GIT_USER_EMAIL:-}" \
        ]]; then

            print_error "Projet ignoré : ${project_id} (configuration Git incomplète)."
            continue
        fi

        selected=$((selected + 1))

        if ! git_commit "${project_id}" "${commit_name}" "${commit_tag}"; then
            print_error "Échec du commit Git pour le projet ${project_id}."
            failed=1
        fi
    done

    if [[ "${selected}" -eq 0 ]]; then
        print_info "Aucun projet configuré à traiter."
        return 0
    fi

    if [[ "${failed}" -ne 0 ]]; then
        print_error "Au moins un commit Git a échoué."
        return 1
    fi

    print_success "Commit Git terminé pour tous les projets configurés."
    return 0
}

# Initialise un dépôt local Git vierge pour le projet <PROJECT ID>
git_init() {
    local project_id="$1"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"
    local project_env="${project_path}/project.env"

    local project_name=""
    local local_default_branch=""
    local git_user_name=""
    local git_user_email=""
    local -a git_local_command=(env -u GIT_COMMON_DIR git)

    # Vérification des paramètres
    if [[ -z "${project_id}" ]]; then
        print_error "Usage : git_init <project_id>"
        return 1
    fi

    # Vérification de l'utilisateur DevOps
    if ! check_devops_user; then
        print_error "L'utilisateur DevOps n'existe pas."
        return 1
    fi

    # Vérification du projet
    if [[ ! -d "${project_path}" ]]; then
        print_error \
            "Le répertoire du projet n'existe pas : ${project_path}"
        return 1
    fi

    # Vérification de Git
    if ! command -v git >/dev/null 2>&1; then
        print_error "Git n'est pas installé."
        return 1
    fi

    if ! runuser -u "${DEVOPS_USER}" -- \
        git --version >/dev/null 2>&1; then

        print_error \
            "Git n'est pas accessible pour l'utilisateur ${DEVOPS_USER}."
        return 1
    fi

    # Chargement de project.env
    if [[ ! -f "${project_env}" ]]; then
        print_info \
            "Le fichier project.env est absent pour le projet ${project_id}."

        if ! update_projects "${project_id}" ||
            ! git_update "${project_id}"; then
            print_error \
                "Impossible d'initialiser la configuration Git du projet."
            return 1
        fi
    fi

    if [[ ! -f "${project_env}" ]]; then
        print_error \
            "Le fichier project.env est toujours absent : ${project_env}"
        return 1
    fi

    # Nettoyage des variables susceptibles d'être déjà présentes
    unset \
        PROJECT_ID \
        PROJECT_NAME \
        PROJECT_TYPE \
        PROJECT_DOCKERED \
        LOCAL_DEFAULT_BRANCH \
        GIT_USER_NAME \
        GIT_USER_EMAIL

    # shellcheck disable=SC1090
    source "${project_env}"

    # Vérification des variables essentielles
    if [[ \
        -z "${PROJECT_ID:-}" ||
        -z "${PROJECT_NAME:-}" ||
        -z "${LOCAL_DEFAULT_BRANCH:-}" ||
        -z "${GIT_USER_NAME:-}" ||
        -z "${GIT_USER_EMAIL:-}" \
    ]]; then

        print_info \
            "La configuration Git locale du projet est incomplète."

        if ! update_projects "${project_id}" ||
            ! git_update "${project_id}"; then
            print_error \
                "Impossible de mettre à jour la configuration Git du projet."
            return 1
        fi

        # Recharge project.env après git_update
        unset \
            PROJECT_ID \
            PROJECT_NAME \
            PROJECT_TYPE \
            PROJECT_DOCKERED \
            LOCAL_DEFAULT_BRANCH \
            GIT_USER_NAME \
            GIT_USER_EMAIL

        # shellcheck disable=SC1090
        source "${project_env}"
    fi

    # Vérification finale des variables essentielles
    if [[ -z "${PROJECT_ID:-}" ]]; then
        print_error "PROJECT_ID n'est pas défini dans project.env."
        return 1
    fi

    if [[ "${PROJECT_ID}" != "${project_id}" ]]; then
        print_error \
            "PROJECT_ID '${PROJECT_ID}' ne correspond pas au projet '${project_id}'."
        return 1
    fi

    if [[ -z "${PROJECT_NAME:-}" ]]; then
        print_error "PROJECT_NAME n'est pas défini dans project.env."
        return 1
    fi

    if [[ -z "${LOCAL_DEFAULT_BRANCH:-}" ]]; then
        print_error \
            "LOCAL_DEFAULT_BRANCH n'est pas défini dans project.env."
        return 1
    fi

    if [[ -z "${GIT_USER_NAME:-}" ]]; then
        print_error "GIT_USER_NAME n'est pas défini dans project.env."
        return 1
    fi

    if [[ -z "${GIT_USER_EMAIL:-}" ]]; then
        print_error "GIT_USER_EMAIL n'est pas défini dans project.env."
        return 1
    fi

    # Affectation locale de la configuration du projet
    project_name="${PROJECT_NAME}"
    local_default_branch="${LOCAL_DEFAULT_BRANCH}"
    git_user_name="${GIT_USER_NAME}"
    git_user_email="${GIT_USER_EMAIL}"

    # Vérification des droits
    if ! runuser -u "${DEVOPS_USER}" -- \
        test -r "${project_path}"; then

        print_error \
            "${DEVOPS_USER} ne peut pas lire le projet : ${project_path}"
        return 1
    fi

    if ! runuser -u "${DEVOPS_USER}" -- \
        test -w "${project_path}"; then

        print_error \
            "${DEVOPS_USER} ne peut pas écrire dans le projet : ${project_path}"
        return 1
    fi

    # Vérification d'un dépôt Git local existant
    if runuser -u "${DEVOPS_USER}" -- \
        "${git_local_command[@]}" -C "${project_path}" rev-parse \
        --is-inside-work-tree >/dev/null 2>&1; then

        return 0
    fi

    # Initialisation du dépôt Git local
    if ! runuser -u "${DEVOPS_USER}" -- \
        "${git_local_command[@]}" -C "${project_path}" \
        init --quiet -b "${local_default_branch}" >/dev/null 2>&1; then

        print_error \
            "Échec de l'initialisation du dépôt Git."
        return 1
    fi

    # Configuration de user.name
    if ! runuser -u "${DEVOPS_USER}" -- \
        "${git_local_command[@]}" -C "${project_path}" config --local \
        user.name "${git_user_name}"; then

        print_error \
            "Échec de la configuration de user.name."
        return 1
    fi

    # Configuration de user.email
    if ! runuser -u "${DEVOPS_USER}" -- \
        "${git_local_command[@]}" -C "${project_path}" config --local \
        user.email "${git_user_email}"; then

        print_error \
            "Échec de la configuration de user.email."
        return 1
    fi

    # Configuration de core.fileMode
    if ! runuser -u "${DEVOPS_USER}" -- \
        "${git_local_command[@]}" -C "${project_path}" config --local \
        core.fileMode false; then

        print_error \
            "Échec de la configuration de core.fileMode."
        return 1
    fi

    # Configuration de core.autocrlf
    if ! runuser -u "${DEVOPS_USER}" -- \
        "${git_local_command[@]}" -C "${project_path}" config --local \
        core.autocrlf false; then

        print_error \
            "Échec de la configuration de core.autocrlf."
        return 1
    fi

    # Configuration de core.eol
    if ! runuser -u "${DEVOPS_USER}" -- \
        "${git_local_command[@]}" -C "${project_path}" config --local \
        core.eol lf; then

        print_error \
            "Échec de la configuration de core.eol."
        return 1
    fi

    # Configuration de i18n.commitEncoding
    if ! runuser -u "${DEVOPS_USER}" -- \
        "${git_local_command[@]}" -C "${project_path}" config --local \
        i18n.commitEncoding utf-8; then

        print_error \
            "Échec de la configuration de i18n.commitEncoding."
        return 1
    fi

    # Configuration de i18n.logOutputEncoding
    if ! runuser -u "${DEVOPS_USER}" -- \
        "${git_local_command[@]}" -C "${project_path}" config --local \
        i18n.logOutputEncoding utf-8; then

        print_error \
            "Échec de la configuration de i18n.logOutputEncoding."
        return 1
    fi

    # Vérification de l'absence de dépôt distant
    if runuser -u "${DEVOPS_USER}" -- \
        "${git_local_command[@]}" -C "${project_path}" remote |
        grep -q .; then

        print_error \
            "Un dépôt distant est déjà configuré alors que l'initialisation doit rester locale."

        runuser -u "${DEVOPS_USER}" -- \
            "${git_local_command[@]}" -C "${project_path}" remote -v

        return 1
    fi

    if ! runuser -u "${DEVOPS_USER}" -- \
        "${git_local_command[@]}" -C "${project_path}" add .; then

        print_error \
            "Échec de l'ajout des fichiers à l'index Git."
        return 1
    fi

    # Vérification du contenu du premier commit
    if runuser -u "${DEVOPS_USER}" -- \
        "${git_local_command[@]}" -C "${project_path}" diff \
        --cached --quiet; then

        print_error \
            "Aucun fichier versionnable n'est disponible pour le premier commit."
        return 1
    fi

    if ! runuser -u "${DEVOPS_USER}" -- \
        "${git_local_command[@]}" -C "${project_path}" commit \
        --quiet -m "Initialisation du projet ${project_name}" >/dev/null 2>&1; then

        print_error \
            "Échec de la création du premier commit."
        return 1
    fi

    return 0
}

git_get_latest_release() {

    # ===========================================================
    # Récupération du dernier tag d'un dépôt Git public
    #
    # Compatible :
    #   - GitHub
    #   - GitLab
    #   - Forgejo
    #
    # Arguments :
    #   $1 = URL de l'instance
    #   $2 = compte / owner
    #   $3 = dépôt
    #
    # Exemple :
    #   git_get_latest_release \
    #       "https://forgejo.pixs.fr" \
    #       "rootforgejo" \
    #       "diu"
    #
    # Retour :
    #   dernier tag distant sur stdout
    #
    # IMPORTANT :
    #   Le dépôt doit être public.
    #   Aucun credential n'est utilisé.
    # ===========================================================

    local remote_url="${1:-}"
    local owner="${2:-}"
    local repository="${3:-}"

    local remote=""
    local latest_tag=""

    # ----------------------------------------------------------
    # Validation
    # ----------------------------------------------------------

    if [[ -z "${remote_url}" || -z "${owner}" || -z "${repository}" ]]; then
        print_error \
            "Usage : git_get_latest_release <url dépôt> <compte> <dépôt>"
        return 1
    fi

    if ! command -v git >/dev/null 2>&1; then
        print_error "La commande git est indisponible."
        return 1
    fi

    # ----------------------------------------------------------
    # Construction du dépôt
    # ----------------------------------------------------------

    remote="${remote_url%/}/${owner}/${repository}.git"

    # ----------------------------------------------------------
    # Récupération des tags
    #
    # GIT_TERMINAL_PROMPT=0
    #
    # Empêche Git de demander :
    #
    # Username for ...
    #
    # pour un dépôt public.
    #
    # credential.helper=
    #
    # Empêche l'utilisation d'un credential helper configuré
    # localement.
    # ----------------------------------------------------------

    latest_tag="$(
        GIT_TERMINAL_PROMPT=0 \
        git \
            -c credential.helper= \
            ls-remote \
            --tags \
            --sort='-v:refname' \
            "${remote}" 2>/dev/null |
        awk '
            $2 !~ /\^\{\}$/ {
                sub("^refs/tags/", "", $2)
                print $2
                exit
            }
        '
    )"

    if [[ -z "${latest_tag}" ]]; then
        print_error \
            "Impossible de récupérer le dernier tag de ${remote}"
        return 1
    fi

    # ----------------------------------------------------------
    # Résultat
    # ----------------------------------------------------------

    printf '%s\n' "${latest_tag}"

    return 0
}

# Publication vers un fournisseur distant explicite.
git_push_provider() {
    local project_id="$1"
    local requested_remote_type="${2:-}"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"
    local project_env="${project_path}/project.env"

    local project_name=""
    local remote_git_type=""
    local remote_base_url=""
    local remote_owner=""
    local remote_repository=""
    local remote_name=""
    local remote_default_branch=""

    local current_branch=""
    local current_tag=""
    local remote_url=""
    local configured_remote_url=""
    local upstream=""
    local expected_upstream=""
    local push_rc=0
    local remote_type_to_use=""
    local missing_fields="No"
    local forgejo_credential_remote_name=""
    local forgejo_repository_rc=0

    # Vérification des paramètres
    if [[ -z "${project_id}" ]]; then
        print_error "git_push_provider : PROJECT_ID est vide."
        return 1
    fi

    if [[ -n "${requested_remote_type}" ]]; then
        requested_remote_type="${requested_remote_type,,}"
    fi

    print_title "Push Git du projet ${project_id} : ${project_path}"

    # Vérification de l'utilisateur DevOps
    if ! check_devops_user; then
        print_error "L'utilisateur DevOps n'existe pas."
        return 1
    fi

    # Vérification du projet
    if [[ ! -d "${project_path}" ]]; then
        print_error "Projet introuvable : ${project_path}"
        return 1
    fi

    # Vérification de Git
    if ! command -v git >/dev/null 2>&1; then
        print_error "Git n'est pas installé."
        return 1
    fi

    if ! runuser -u "${DEVOPS_USER}" -- \
        git --version >/dev/null 2>&1; then

        print_error \
            "Git n'est pas accessible pour ${DEVOPS_USER}."
        return 1
    fi

    # Chargement de project.env
    if [[ ! -f "${project_env}" ]]; then
        print_info \
            "Le fichier project.env est absent pour le projet ${project_id}."

        if [[ "${requested_remote_type}" == "forgejo" ]]; then
            if ! forgejo_update "${project_id}"; then
                print_error \
                    "Impossible de mettre à jour la configuration Forgejo du projet."
                return 1
            fi
        elif [[ "${requested_remote_type}" == "gitlab" ]]; then
            if ! gitlab_update "${project_id}"; then
                print_error \
                    "Impossible d'initialiser la configuration GitLab du projet."
                return 1
            fi
        elif [[ "${requested_remote_type}" == "github" ]]; then
            if ! github_update "${project_id}"; then
                print_error \
                    "Impossible de mettre à jour la configuration GitHub du projet."
                return 1
            fi
        else
            if ! update_projects "${project_id}" ||
                ! git_update "${project_id}"; then
                print_error \
                    "Impossible d'initialiser la configuration du projet."
                return 1
            fi
        fi
    fi

    if [[ ! -f "${project_env}" ]]; then
        print_error \
            "Le fichier project.env est toujours absent : ${project_env}"
        return 1
    fi

    # Nettoyage des variables susceptibles d'être déjà présentes
    unset \
        PROJECT_ID \
        PROJECT_NAME \
        PROJECT_TYPE \
        PROJECT_DOCKERED \
        LOCAL_DEFAULT_BRANCH \
        REMOTE_GITLAB_BASE_URL \
        REMOTE_GITLAB_OWNER \
        REMOTE_GITLAB_REPOSITORY \
        REMOTE_GITLAB_NAME \
        REMOTE_GITLAB_BRANCH \
        REMOTE_FORGEJO_BASE_URL \
        REMOTE_FORGEJO_OWNER \
        REMOTE_FORGEJO_REPOSITORY \
        REMOTE_FORGEJO_NAME \
        REMOTE_FORGEJO_BRANCH \
        REMOTE_FORGEJO_SSL_VERIFY \
        REMOTE_GITHUB_BASE_URL \
        REMOTE_GITHUB_OWNER \
        REMOTE_GITHUB_REPOSITORY \
        REMOTE_GITHUB_NAME \
        REMOTE_GITHUB_BRANCH

    # shellcheck disable=SC1090
    source "${project_env}"

    # Vérification des variables essentielles
    remote_type_to_use="${requested_remote_type}"

    if [[ -n "${requested_remote_type}" ]]; then
        remote_type_to_use="${requested_remote_type}"
    fi

    if [[ -z "${PROJECT_ID:-}" ||
        -z "${PROJECT_NAME:-}" ||
        -z "${PROJECT_TYPE:-}" ||
        -z "${PROJECT_DOCKERED:-}" ||
        -z "${remote_type_to_use:-}" \
    ]]; then

        missing_fields="Yes"

    elif [[ "${remote_type_to_use}" == "gitlab" ]]; then

        if [[ -z "${REMOTE_GITLAB_BASE_URL:-}" ||
            -z "${REMOTE_GITLAB_OWNER:-}" ||
            -z "${REMOTE_GITLAB_REPOSITORY:-}" ||
            -z "${REMOTE_GITLAB_NAME:-}" ||
            -z "${REMOTE_GITLAB_BRANCH:-}" \
        ]]; then

            missing_fields="Yes"
        fi

    elif [[ "${remote_type_to_use}" == "github" ]]; then

        if [[ -z "${REMOTE_GITHUB_BASE_URL:-}" ||
            -z "${REMOTE_GITHUB_OWNER:-}" ||
            -z "${REMOTE_GITHUB_REPOSITORY:-}" ||
            -z "${REMOTE_GITHUB_NAME:-}" ||
            -z "${REMOTE_GITHUB_BRANCH:-}" \
        ]]; then

            missing_fields="Yes"
        fi

    elif [[ "${remote_type_to_use}" == "forgejo" &&
        "${requested_remote_type}" == "forgejo" ]]; then

        if [[ -z "${REMOTE_FORGEJO_BASE_URL:-}" ||
            -z "${REMOTE_FORGEJO_OWNER:-}" ||
            -z "${REMOTE_FORGEJO_REPOSITORY:-}" ||
            -z "${REMOTE_FORGEJO_NAME:-}" ||
            -z "${REMOTE_FORGEJO_BRANCH:-}" ||
            -z "${REMOTE_FORGEJO_SSL_VERIFY:-}" \
        ]]; then

            missing_fields="Yes"
        fi

    else
        print_error "Type de dépôt Git distant non supporté : ${remote_type_to_use}"
        return 1
    fi

    if [[ "${missing_fields}" == "Yes" ]]; then

        print_info \
            "La configuration Git du projet est incomplète."

        if [[ "${requested_remote_type}" == "forgejo" ]]; then
            if ! forgejo_update "${project_id}"; then
                print_error \
                    "Impossible de mettre à jour la configuration Forgejo du projet."
                return 1
            fi
        elif [[ "${requested_remote_type}" == "gitlab" ]]; then
            if ! gitlab_update "${project_id}"; then
                print_error \
                    "Impossible de mettre à jour la configuration GitLab du projet."
                return 1
            fi
        elif [[ "${requested_remote_type}" == "github" ]]; then
            if ! github_update "${project_id}"; then
                print_error \
                    "Impossible de mettre à jour la configuration GitHub du projet."
                return 1
            fi
        else
            if ! update_projects "${project_id}" ||
                ! git_update "${project_id}"; then
                print_error \
                    "Impossible de mettre à jour la configuration du projet."
                return 1
            fi
        fi

        # Recharge project.env après git_update
        unset \
            PROJECT_ID \
            PROJECT_NAME \
            PROJECT_TYPE \
            PROJECT_DOCKERED \
            LOCAL_DEFAULT_BRANCH \
            REMOTE_GITLAB_BASE_URL \
            REMOTE_GITLAB_OWNER \
        REMOTE_GITLAB_REPOSITORY \
        REMOTE_GITLAB_NAME \
        REMOTE_GITLAB_BRANCH \
        REMOTE_FORGEJO_BASE_URL \
        REMOTE_FORGEJO_OWNER \
        REMOTE_FORGEJO_REPOSITORY \
        REMOTE_FORGEJO_NAME \
        REMOTE_FORGEJO_BRANCH \
        REMOTE_FORGEJO_SSL_VERIFY \
        REMOTE_GITHUB_BASE_URL \
            REMOTE_GITHUB_OWNER \
            REMOTE_GITHUB_REPOSITORY \
            REMOTE_GITHUB_NAME \
            REMOTE_GITHUB_BRANCH

        # shellcheck disable=SC1090
        source "${project_env}"

        remote_type_to_use="${requested_remote_type}"

        if [[ -n "${requested_remote_type}" ]]; then
            remote_type_to_use="${requested_remote_type}"
        fi
    fi

    # Vérification finale des variables essentielles
    if [[ -z "${PROJECT_ID:-}" ]]; then
        print_error "PROJECT_ID n'est pas défini dans project.env."
        return 1
    fi

    if [[ "${PROJECT_ID}" != "${project_id}" ]]; then
        print_error \
            "PROJECT_ID '${PROJECT_ID}' ne correspond pas au projet '${project_id}'."
        return 1
    fi

    if [[ -z "${PROJECT_NAME:-}" ]]; then
        print_error "PROJECT_NAME n'est pas défini dans project.env."
        return 1
    fi

    if [[ -z "${PROJECT_TYPE:-}" ]]; then
        print_error "PROJECT_TYPE n'est pas défini dans project.env."
        return 1
    fi

    if [[ -z "${PROJECT_DOCKERED:-}" ]]; then
        print_error "PROJECT_DOCKERED n'est pas défini dans project.env."
        return 1
    fi

    if [[ "${remote_type_to_use}" == "forgejo" ]]; then

        if [[ -z "${REMOTE_FORGEJO_BASE_URL:-}" ]]; then
            print_error "REMOTE_FORGEJO_BASE_URL n'est pas défini dans project.env."
            return 1
        fi

        if [[ -z "${REMOTE_FORGEJO_OWNER:-}" ]]; then
            print_error "REMOTE_FORGEJO_OWNER n'est pas défini dans project.env."
            return 1
        fi

        if [[ -z "${REMOTE_FORGEJO_REPOSITORY:-}" ]]; then
            print_error "REMOTE_FORGEJO_REPOSITORY n'est pas défini dans project.env."
            return 1
        fi

        if [[ -z "${REMOTE_FORGEJO_NAME:-}" ]]; then
            print_error "REMOTE_FORGEJO_NAME n'est pas défini dans project.env."
            return 1
        fi

        if [[ -z "${REMOTE_FORGEJO_BRANCH:-}" ]]; then
            print_error "REMOTE_FORGEJO_BRANCH n'est pas défini dans project.env."
            return 1
        fi

        if [[ -z "${REMOTE_FORGEJO_SSL_VERIFY:-}" ]]; then
            print_error "REMOTE_FORGEJO_SSL_VERIFY n'est pas défini dans project.env."
            return 1
        fi

    elif [[ "${remote_type_to_use}" == "gitlab" ]]; then

        if [[ -z "${REMOTE_GITLAB_BASE_URL:-}" ]]; then
            print_error "REMOTE_GITLAB_BASE_URL n'est pas défini dans project.env."
            return 1
        fi

        if [[ -z "${REMOTE_GITLAB_OWNER:-}" ]]; then
            print_error "REMOTE_GITLAB_OWNER n'est pas défini dans project.env."
            return 1
        fi

        if [[ -z "${REMOTE_GITLAB_REPOSITORY:-}" ]]; then
            print_error "REMOTE_GITLAB_REPOSITORY n'est pas défini dans project.env."
            return 1
        fi

        if [[ -z "${REMOTE_GITLAB_NAME:-}" ]]; then
            print_error "REMOTE_GITLAB_NAME n'est pas défini dans project.env."
            return 1
        fi

        if [[ -z "${REMOTE_GITLAB_BRANCH:-}" ]]; then
            print_error "REMOTE_GITLAB_BRANCH n'est pas défini dans project.env."
            return 1
        fi

    elif [[ "${remote_type_to_use}" == "github" ]]; then

        if [[ -z "${REMOTE_GITHUB_BASE_URL:-}" ]]; then
            print_error "REMOTE_GITHUB_BASE_URL n'est pas défini dans project.env."
            return 1
        fi

        if [[ -z "${REMOTE_GITHUB_OWNER:-}" ]]; then
            print_error "REMOTE_GITHUB_OWNER n'est pas défini dans project.env."
            return 1
        fi

        if [[ -z "${REMOTE_GITHUB_REPOSITORY:-}" ]]; then
            print_error "REMOTE_GITHUB_REPOSITORY n'est pas défini dans project.env."
            return 1
        fi

        if [[ -z "${REMOTE_GITHUB_NAME:-}" ]]; then
            print_error "REMOTE_GITHUB_NAME n'est pas défini dans project.env."
            return 1
        fi

        if [[ -z "${REMOTE_GITHUB_BRANCH:-}" ]]; then
            print_error "REMOTE_GITHUB_BRANCH n'est pas défini dans project.env."
            return 1
        fi

    else
        print_error "Type de dépôt Git distant non supporté : ${remote_type_to_use}"
        return 1
    fi

    # Affectation locale de la configuration du projet
    project_name="${PROJECT_NAME}"
    remote_git_type="${remote_type_to_use}"

    if [[ "${remote_git_type}" == "gitlab" ]]; then
        remote_base_url="${REMOTE_GITLAB_BASE_URL%/}"
        remote_owner="${REMOTE_GITLAB_OWNER}"
        remote_repository="${REMOTE_GITLAB_REPOSITORY}"
        remote_name="${REMOTE_GITLAB_NAME}"
        remote_default_branch="${REMOTE_GITLAB_BRANCH}"
    elif [[ "${remote_git_type}" == "github" ]]; then
        remote_base_url="${REMOTE_GITHUB_BASE_URL%/}"
        remote_owner="${REMOTE_GITHUB_OWNER}"
        remote_repository="${REMOTE_GITHUB_REPOSITORY}"
        remote_name="${REMOTE_GITHUB_NAME}"
        remote_default_branch="${REMOTE_GITHUB_BRANCH}"
    elif [[ "${remote_git_type}" == "forgejo" ]]; then
        remote_base_url="${REMOTE_FORGEJO_BASE_URL%/}"
        remote_owner="${REMOTE_FORGEJO_OWNER}"
        remote_repository="${REMOTE_FORGEJO_REPOSITORY}"
        remote_name="${REMOTE_FORGEJO_NAME}"
        remote_default_branch="${REMOTE_FORGEJO_BRANCH}"
    fi

    if [[ "${remote_git_type}" == "gitlab" ]]; then
        configured_remote_url="${remote_base_url}/${remote_owner}/${remote_repository}.git"

        if ! gitlab_remote_ensure \
            "${project_path}" \
            "${remote_name}" \
            "${configured_remote_url}"; then
            return 1
        fi
    elif [[ "${remote_git_type}" == "github" ]]; then
        configured_remote_url="${remote_base_url}/${remote_owner}/${remote_repository}.git"

        if ! github_repository_ensure \
            "${project_path}" \
            "${remote_base_url}" \
            "${remote_owner}" \
            "${remote_repository}"; then
            return 1
        fi

        if ! github_remote_ensure \
            "${project_path}" \
            "${remote_name}" \
            "${configured_remote_url}"; then
            return 1
        fi
    elif [[ "${remote_git_type}" == "forgejo" ]]; then
        configured_remote_url="${remote_base_url}/${remote_owner}/${remote_repository}.git"

        if ! forgejo_remote_ensure \
            "${project_path}" \
            "${remote_name}" \
            "${configured_remote_url}"; then
            return 1
        fi
    fi

    # Branche distante attendue pour la publication
    expected_upstream="${remote_name}/${remote_default_branch}"

    # Construction de l'URL déclarative du dépôt distant
    remote_url="${remote_base_url}/${remote_owner}/${remote_repository}.git"

    # Vérification du dépôt Git local
    if ! runuser -u "${ENV_DEVOPS_USER}" -- \
        git -C "${project_path}" \
        rev-parse --is-inside-work-tree >/dev/null 2>&1; then

        print_error \
            "Le projet n'est pas un dépôt Git pour ${ENV_DEVOPS_USER} : ${project_path}"
        return 1
    fi

    # Branche Git locale courante
    current_branch="$(
        runuser -u "${ENV_DEVOPS_USER}" -- \
            git -C "${project_path}" \
            branch --show-current 2>/dev/null
    )"

    if [[ -z "${current_branch}" ]]; then
        print_error \
            "Impossible de déterminer la branche Git locale courante."
        return 1
    fi

    # Tag éventuel du dernier commit
    current_tag="$(
        runuser -u "${ENV_DEVOPS_USER}" -- \
            git -C "${project_path}" \
            tag --points-at HEAD 2>/dev/null |
            head -n 1
    )"

    # Vérification / configuration du remote Git
    configured_remote_url=""

    if configured_remote_url="$(
        runuser -u "${ENV_DEVOPS_USER}" -- \
            git -C "${project_path}" \
            remote get-url "${remote_name}" 2>/dev/null
    )"; then
        :
    fi

    if [[ -z "${configured_remote_url}" ]]; then

        print_info \
            "Aucun dépôt distant '${remote_name}' n'est configuré."

        print_info \
            "Configuration du dépôt distant : ${remote_url}"

        if ! runuser -u "${ENV_DEVOPS_USER}" -- \
            git -C "${project_path}" \
            remote add "${remote_name}" "${remote_url}"; then

            print_error \
                "Impossible de configurer le dépôt distant '${remote_name}'."
            return 1
        fi

        configured_remote_url="${remote_url}"

        print_success \
            "Dépôt distant '${remote_name}' configuré."

    elif [[ "${configured_remote_url}" != "${remote_url}" ]]; then

        print_error \
            "L'URL Git configurée ne correspond pas à project.env."

        printf '%-22s : %s\n' \
            "URL configurée" "${configured_remote_url}"

        printf '%-22s : %s\n' \
            "URL déclarée" "${remote_url}"

        return 1
    fi

    # Informations du projet
    print_title "Dépôt Git"

    printf '%-22s : %s\n' "Projet" "${project_name}"
    printf '%-22s : %s\n' "ID projet" "${project_id}"
    printf '%-22s : %s\n' "Répertoire" "${project_path}"
    printf '%-22s : %s\n' "Utilisateur" "${ENV_DEVOPS_USER}"
    printf '%-22s : %s\n' "Type distant" "${remote_git_type}"
    printf '%-22s : %s\n' "Branche locale" "${current_branch}"
    printf '%-22s : %s\n' "Dépôt distant" "${remote_name}"
    printf '%-22s : %s\n' "URL distante" "${configured_remote_url}"
    printf '%-22s : %s\n' \
        "Branche distante" "${remote_default_branch}"

    if [[ -n "${current_tag}" ]]; then
        printf '%-22s : %s\n' \
            "Tag du commit" "${current_tag}"
    else
        printf '%-22s : %s\n' \
            "Tag du commit" "Aucun"
    fi

    # git status
    print_title "git status"

    if ! runuser -u "${ENV_DEVOPS_USER}" -- \
        git -C "${project_path}" status; then

        print_error "Impossible de lire l'état du dépôt Git."
        return 1
    fi

    # git log
    print_title "git log --oneline"

    if ! runuser -u "${ENV_DEVOPS_USER}" -- \
        git -C "${project_path}" log \
        --oneline \
        --decorate \
        -10; then

        print_error "Impossible de lire l'historique Git."
        return 1
    fi

    # Credentials du fournisseur Git distant
    case "${remote_git_type}" in

        forgejo)
            if [[ "${requested_remote_type}" == "forgejo" ]]; then
                forgejo_credential_remote_name="${remote_name}"
            else
                forgejo_credential_remote_name="origin"
            fi

            if ! _forgejo_ensure_credentials \
                "${project_path}" "${forgejo_credential_remote_name}"; then
                print_error \
                    "Impossible d'initialiser les credentials Forgejo."
                return 1
            fi
            ;;

        gitlab)
            if ! _gitlab_ensure_credentials "${project_path}"; then
                print_error \
                    "Impossible d'initialiser les credentials GitLab."
                return 1
            fi
            ;;

        github)
            if ! _github_ensure_credentials "${project_path}" "${remote_name}"; then
                print_error \
                    "Impossible d'initialiser les credentials GitHub."
                return 1
            fi
            ;;

        *)
            print_error \
                "Type de dépôt Git distant non supporté : ${remote_git_type}"
            return 1
            ;;
    esac

    if [[ "${remote_git_type}" == "forgejo" ]]; then
        forgejo_repository_ensure "${project_path}" "${remote_name}" || forgejo_repository_rc=$?

        case "${forgejo_repository_rc:-0}" in
            0)
                if ! forgejo_git_fetch_named "${project_path}" "${remote_name}"; then
                    print_error \
                        "Impossible de récupérer les références Forgejo distantes."
                    return 1
                fi
                ;;
            2)
                print_info \
                    "Premier push Forgejo : récupération des références ignorée."
                ;;
            *)
            print_error "Impossible d'assurer l'existence du dépôt Forgejo distant."
            return 1
                ;;
        esac
    fi

    # Détermination de l'upstream actuel
    upstream=""

    if runuser -u "${ENV_DEVOPS_USER}" -- \
        git -C "${project_path}" \
        rev-parse --verify \
        "${current_branch}@{upstream}" >/dev/null 2>&1; then

        upstream="$(
            runuser -u "${ENV_DEVOPS_USER}" -- \
                git -C "${project_path}" \
                rev-parse \
                --abbrev-ref \
                --symbolic-full-name \
                "${current_branch}@{upstream}" 2>/dev/null
        )"
    fi

    if [[ -z "${upstream}" ]]; then

        print_info \
            "Aucune branche distante de suivi n'est encore configurée."

    elif [[ "${upstream}" == "${expected_upstream}" ]]; then

        print_info \
            "Branche distante de suivi : ${upstream}"

    else

        print_info \
            "Branche distante de suivi actuelle : ${upstream}"

        print_info \
            "La publication DIU utilisera : ${expected_upstream}"
    fi

    printf '\n'
    print_info "Le dépôt local va être envoyé vers :"
    printf '  %s\n' "${configured_remote_url}"
    printf '\n'
    printf 'Branche locale    : %s\n' "${current_branch}"
    printf 'Branche distante  : %s\n' "${remote_default_branch}"

    if [[ -n "${current_tag}" ]]; then
        printf 'Tag Git            : %s\n' "${current_tag}"
    fi

    # Push
    case "${remote_git_type}" in

        forgejo)

            print_title "Push vers Forgejo"

            if [[ -z "${upstream}" ]]; then
                print_info \
                    "Premier push : création de la branche distante et de son suivi."

            elif [[ "${upstream}" != "${expected_upstream}" ]]; then
                print_info \
                    "La branche ${current_branch} suit actuellement ${upstream}."

                print_info \
                    "Le suivi sera remplacé par ${expected_upstream} après le push."

            else
                print_info \
                    "Push de la branche ${current_branch} vers ${expected_upstream}."
            fi

            #
            # Le push est toujours explicite.
            #
            # Cela évite que Git utilise un upstream hérité d'un dépôt cloné
            # (par exemple upstream/master) comme destination du push.
            #
            # Exemple :
            #
            #   main -> upstream/master
            #
            # devient après publication :
            #
            #   main -> origin/main
            #
            if [[ "${requested_remote_type}" == "forgejo" ]]; then
                forgejo_git_push_named \
                    "${project_path}" \
                    "${remote_name}" \
                    --force-with-lease \
                    --set-upstream \
                    "${remote_name}" \
                    "${current_branch}:${remote_default_branch}" \
                    || push_rc=$?
            else
                forgejo_git_push \
                    "${project_path}" \
                    --set-upstream \
                    "${remote_name}" \
                    "${current_branch}:${remote_default_branch}" \
                    || push_rc=$?
            fi

            # Vérification du push de la branche
            if [[ "${push_rc}" -ne 0 ]]; then
                print_error \
                    "Échec du push Git distant (code ${push_rc})."
                return "${push_rc}"
            fi

            # Push du tag associé au dernier commit
            if [[ -n "${current_tag}" ]]; then

                print_title "Push du tag Git"

                print_info \
                    "Publication du tag '${current_tag}' vers '${remote_name}'."

                if [[ "${requested_remote_type}" == "forgejo" ]]; then
                    forgejo_git_push_named \
                        "${project_path}" \
                        "${remote_name}" \
                        "${remote_name}" \
                        "refs/tags/${current_tag}:refs/tags/${current_tag}" \
                        || push_rc=$?
                else
                    forgejo_git_push \
                        "${project_path}" \
                        "${remote_name}" \
                        "refs/tags/${current_tag}:refs/tags/${current_tag}" \
                        || push_rc=$?
                fi

                if [[ "${push_rc}" -ne 0 ]]; then
                    print_error \
                        "Échec du push du tag Git '${current_tag}' (code ${push_rc})."
                    return "${push_rc}"
                fi

                print_success \
                    "Tag Git '${current_tag}' publié avec succès."

            else

                print_info \
                    "Aucun tag associé au dernier commit : aucun tag à publier."
            fi
            ;;

        gitlab)

            print_title "Push vers GitLab"

            if [[ -z "${upstream}" ]]; then
                print_info \
                    "Premier push : création de la branche distante et de son suivi."

            elif [[ "${upstream}" != "${expected_upstream}" ]]; then
                print_info \
                    "La branche ${current_branch} suit actuellement ${upstream}."

                print_info \
                    "Le suivi sera remplacé par ${expected_upstream} après le push."

            else
                print_info \
                    "Push de la branche ${current_branch} vers ${expected_upstream}."
            fi

            gitlab_git_push \
                "${project_path}" \
                --set-upstream \
                "${remote_name}" \
                "${current_branch}:${remote_default_branch}" \
                || push_rc=$?

            if [[ "${push_rc}" -ne 0 ]]; then
                print_error \
                    "Échec du push Git distant (code ${push_rc})."
                return "${push_rc}"
            fi

            if [[ -n "${current_tag}" ]]; then

                print_title "Push du tag Git"

                print_info \
                    "Publication du tag '${current_tag}' vers '${remote_name}'."

                gitlab_git_push \
                    "${project_path}" \
                    "${remote_name}" \
                    "refs/tags/${current_tag}:refs/tags/${current_tag}" \
                    || push_rc=$?

                if [[ "${push_rc}" -ne 0 ]]; then
                    print_error \
                        "Échec du push du tag Git '${current_tag}' (code ${push_rc})."
                    return "${push_rc}"
                fi

                print_success \
                    "Tag Git '${current_tag}' publié avec succès."

            else

                print_info \
                    "Aucun tag associé au dernier commit : aucun tag à publier."
            fi
            ;;

        github)

            print_title "Push vers GitHub"

            if [[ -z "${upstream}" ]]; then
                print_info \
                    "Premier push : création de la branche distante et de son suivi."

            elif [[ "${upstream}" != "${expected_upstream}" ]]; then
                print_info \
                    "La branche ${current_branch} suit actuellement ${upstream}."

                print_info \
                    "Le suivi sera remplacé par ${expected_upstream} après le push."

            else
                print_info \
                    "Push de la branche ${current_branch} vers ${expected_upstream}."
            fi

            github_git_push \
                "${project_path}" \
                --set-upstream \
                "${remote_name}" \
                "${current_branch}:${remote_default_branch}" \
                || push_rc=$?

            if [[ "${push_rc}" -ne 0 ]]; then
                print_error \
                    "Échec du push Git distant (code ${push_rc})."
                return "${push_rc}"
            fi

            if [[ -n "${current_tag}" ]]; then

                print_title "Push du tag Git"

                print_info \
                    "Publication du tag '${current_tag}' vers '${remote_name}'."

                github_git_push \
                    "${project_path}" \
                    "${remote_name}" \
                    "refs/tags/${current_tag}:refs/tags/${current_tag}" \
                    || push_rc=$?

                if [[ "${push_rc}" -ne 0 ]]; then
                    print_error \
                        "Échec du push du tag Git '${current_tag}' (code ${push_rc})."
                    return "${push_rc}"
                fi

                print_success \
                    "Tag Git '${current_tag}' publié avec succès."

            else
                print_info \
                    "Aucun tag associé au dernier commit : aucun tag à publier."
            fi
            ;;

    esac

    # Résultat
    if [[ "${push_rc}" -ne 0 ]]; then
        print_error \
            "Échec du push Git distant (code ${push_rc})."
        return "${push_rc}"
    fi

    print_success "Push Git terminé avec succès."

    return 0
}

# Vérifie ou crée le remote Forgejo du dépôt local.
forgejo_remote_ensure() {
    local project_path="${1:-}"
    local remote_name="${2:-}"
    local expected_url="${3:-}"
    local configured_url=""

    if [[ -z "${project_path}" || -z "${remote_name}" || -z "${expected_url}" ]]; then
        print_error "Usage : forgejo_remote_ensure <project_path> <remote_name> <url>"
        return 1
    fi

    if ! configured_url="$(runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" remote get-url --push "${remote_name}" 2>/dev/null)"; then
        if runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" remote add "${remote_name}" "${expected_url}"; then
            print_info \
                "Remote Forgejo '${remote_name}' ajouté au dépôt local."
            return 0
        fi

        print_error \
            "Impossible d'ajouter le remote Forgejo '${remote_name}'."
        return 1
    fi

    if [[ "${configured_url}" != "${expected_url}" ]]; then
        print_error "L'URL du remote Forgejo '${remote_name}' ne correspond pas à project.env."
        printf 'URL configurée        : %s\n' "${configured_url}"
        printf 'URL déclarée          : %s\n' "${expected_url}"
        return 1
    fi

    return 0
}

# Vérifie ou crée le remote GitLab du dépôt local.
gitlab_remote_ensure() {
    local project_path="${1:-}"
    local remote_name="${2:-}"
    local expected_url="${3:-}"
    local configured_url=""

    if [[ -z "${project_path}" || -z "${remote_name}" || -z "${expected_url}" ]]; then
        print_error "Usage : gitlab_remote_ensure <project_path> <remote_name> <url>"
        return 1
    fi

    if ! configured_url="$(runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" remote get-url --push "${remote_name}" 2>/dev/null)"; then
        if runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" remote add "${remote_name}" "${expected_url}"; then
            print_info \
                "Remote GitLab '${remote_name}' ajouté au dépôt local."
            return 0
        fi

        print_error \
            "Impossible d'ajouter le remote GitLab '${remote_name}'."
        return 1
    fi

    if [[ "${configured_url}" != "${expected_url}" ]]; then
        print_error "L'URL du remote GitLab '${remote_name}' ne correspond pas à project.env."
        printf 'URL configurée        : %s\n' "${configured_url}"
        printf 'URL déclarée          : %s\n' "${expected_url}"
        return 1
    fi

    return 0
}

# Vérifie ou crée le remote GitHub du dépôt local.
github_remote_ensure() {
    local project_path="${1:-}"
    local remote_name="${2:-}"
    local expected_url="${3:-}"
    local configured_url=""

    if [[ -z "${project_path}" || -z "${remote_name}" || -z "${expected_url}" ]]; then
        print_error "Usage : github_remote_ensure <project_path> <remote_name> <url>"
        return 1
    fi

    if ! configured_url="$(runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" remote get-url --push "${remote_name}" 2>/dev/null)"; then
        if runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" remote add "${remote_name}" "${expected_url}"; then
            print_info \
                "Remote GitHub '${remote_name}' ajouté au dépôt local."
            return 0
        fi

        print_error \
            "Impossible d'ajouter le remote GitHub '${remote_name}'."
        return 1
    fi

    if [[ "${configured_url}" != "${expected_url}" ]]; then
        print_error "L'URL du remote GitHub '${remote_name}' ne correspond pas à project.env."
        printf 'URL configurée        : %s\n' "${configured_url}"
        printf 'URL déclarée          : %s\n' "${expected_url}"
        return 1
    fi

    return 0
}

# Vérifie et complète la configuration générale avant la configuration Forgejo.
forgejo_project_config_ensure() {
    local project_id="${1:-}"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"
    local project_env="${project_path}/project.env"

    if [[ -z "${project_id}" ]]; then
        print_error "Usage : forgejo_project_config_ensure <project_id>"
        return 1
    fi

    if [[ ! -d "${project_path}" || ! -f "${project_env}" ]]; then
        return 1
    fi

    unset PROJECT_ID PROJECT_NAME PROJECT_TYPE PROJECT_DOCKERED

    # shellcheck disable=SC1090
    source "${project_env}"

    if [[ -z "${PROJECT_ID:-}" ||
        "${PROJECT_ID}" != "${project_id}" ||
        -z "${PROJECT_NAME:-}" ||
        -z "${PROJECT_TYPE:-}" ||
        -z "${PROJECT_DOCKERED:-}" \
    ]]; then
        return 1
    fi

    return 0
}

# Complète uniquement le différentiel de configuration propre à Forgejo.
forgejo_update() {
    local project_id="${1:-}"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"
    local project_env="${project_path}/project.env"
    local project_env_tmp="${project_env}.forgejo.tmp"
    local remote_forgejo_base_url=""
    local remote_forgejo_owner=""
    local remote_forgejo_repository="${project_id}"
    local remote_forgejo_name="origin"
    local remote_forgejo_branch="main"
    local remote_forgejo_ssl_verify="No"
    local value=""

    if [[ -z "${project_id}" ]]; then
        print_error "Usage : forgejo_update <project_id>"
        return 1
    fi

    if [[ ! -d "${project_path}" ]]; then
        print_error "Le répertoire du projet n'existe pas : ${project_path}"
        return 1
    fi

    if ! forgejo_project_config_ensure "${project_id}"; then
        print_info \
            "La configuration générale du projet est absente ou incomplète."

        if ! update_projects "${project_id}"; then
            print_error \
                "Impossible de compléter la configuration générale du projet."
            return 1
        fi
    fi

    if ! forgejo_project_config_ensure "${project_id}"; then
        print_error \
            "La configuration générale du projet reste non conforme."
        return 1
    fi

    unset \
        REMOTE_FORGEJO_BASE_URL \
        REMOTE_FORGEJO_OWNER \
        REMOTE_FORGEJO_REPOSITORY \
        REMOTE_FORGEJO_NAME \
        REMOTE_FORGEJO_BRANCH \
        REMOTE_FORGEJO_SSL_VERIFY

    # shellcheck disable=SC1090
    source "${project_env}"

    remote_forgejo_base_url="${REMOTE_FORGEJO_BASE_URL:-}"
    remote_forgejo_owner="${REMOTE_FORGEJO_OWNER:-}"
    remote_forgejo_repository="${REMOTE_FORGEJO_REPOSITORY:-${project_id}}"
    remote_forgejo_name="${REMOTE_FORGEJO_NAME:-origin}"
    remote_forgejo_branch="${REMOTE_FORGEJO_BRANCH:-main}"
    remote_forgejo_ssl_verify="${REMOTE_FORGEJO_SSL_VERIFY:-No}"

    print_title "Configuration Forgejo du projet ${project_id}"

    value=""
    read -r -p \
        "REMOTE_FORGEJO_BASE_URL [${remote_forgejo_base_url}] : " value
    if [[ -n "${value}" ]]; then
        remote_forgejo_base_url="${value}"
    fi
    remote_forgejo_base_url="${remote_forgejo_base_url%/}"
    while [[ -z "${remote_forgejo_base_url}" ]]; do
        print_error "REMOTE_FORGEJO_BASE_URL ne peut pas être vide."
        read -r -p "REMOTE_FORGEJO_BASE_URL : " remote_forgejo_base_url
        remote_forgejo_base_url="${remote_forgejo_base_url%/}"
    done

    if [[ ! "${remote_forgejo_base_url}" =~ ^https://[^/@]+$ ]]; then
        print_error \
            "REMOTE_FORGEJO_BASE_URL doit être une URL HTTPS sans identifiants."
        return 1
    fi

    value=""
    read -r -p \
        "REMOTE_FORGEJO_OWNER [${remote_forgejo_owner}] : " value
    if [[ -n "${value}" ]]; then
        remote_forgejo_owner="${value}"
    fi
    while [[ -z "${remote_forgejo_owner}" ]]; do
        print_error "REMOTE_FORGEJO_OWNER ne peut pas être vide."
        read -r -p "REMOTE_FORGEJO_OWNER : " remote_forgejo_owner
    done

    value=""
    read -r -p \
        "REMOTE_FORGEJO_REPOSITORY [${remote_forgejo_repository}] : " value
    if [[ -n "${value}" ]]; then
        remote_forgejo_repository="${value}"
    fi
    remote_forgejo_repository="${remote_forgejo_repository:-${project_id}}"

    value=""
    read -r -p \
        "REMOTE_FORGEJO_NAME [${remote_forgejo_name}] : " value
    if [[ -n "${value}" ]]; then
        remote_forgejo_name="${value}"
    fi
    remote_forgejo_name="${remote_forgejo_name:-origin}"

    value=""
    read -r -p \
        "REMOTE_FORGEJO_BRANCH [${remote_forgejo_branch}] : " value
    if [[ -n "${value}" ]]; then
        remote_forgejo_branch="${value}"
    fi
    remote_forgejo_branch="${remote_forgejo_branch:-main}"

    value=""
    read -r -p \
        "REMOTE_FORGEJO_SSL_VERIFY [${remote_forgejo_ssl_verify}] : " value
    if [[ -n "${value}" ]]; then
        remote_forgejo_ssl_verify="${value}"
    fi
    case "${remote_forgejo_ssl_verify}" in
        Yes|yes|oui|OUI|true|TRUE|1)
            remote_forgejo_ssl_verify="Yes"
            ;;
        No|no|non|NON|false|FALSE|0)
            remote_forgejo_ssl_verify="No"
            ;;
        *)
            print_error "REMOTE_FORGEJO_SSL_VERIFY doit valoir Yes ou No."
            return 1
            ;;
    esac

    if ! awk '
        !/^REMOTE_FORGEJO_BASE_URL=/ &&
        !/^REMOTE_FORGEJO_OWNER=/ &&
        !/^REMOTE_FORGEJO_REPOSITORY=/ &&
        !/^REMOTE_FORGEJO_NAME=/ &&
        !/^REMOTE_FORGEJO_BRANCH=/ &&
        !/^REMOTE_FORGEJO_SSL_VERIFY=/ &&
        !/^# Forgejo distant$/ { print }
    ' "${project_env}" > "${project_env_tmp}"; then
        rm -f "${project_env_tmp}"
        print_error "Impossible de préparer project.env pour Forgejo."
        return 1
    fi

    if ! {
        printf '\n# Forgejo distant\n'
        printf 'REMOTE_FORGEJO_BASE_URL=%q\n' "${remote_forgejo_base_url}"
        printf 'REMOTE_FORGEJO_OWNER=%q\n' "${remote_forgejo_owner}"
        printf 'REMOTE_FORGEJO_REPOSITORY=%q\n' "${remote_forgejo_repository}"
        printf 'REMOTE_FORGEJO_NAME=%q\n' "${remote_forgejo_name}"
        printf 'REMOTE_FORGEJO_BRANCH=%q\n' "${remote_forgejo_branch}"
        printf 'REMOTE_FORGEJO_SSL_VERIFY=%q\n' "${remote_forgejo_ssl_verify}"
    } >> "${project_env_tmp}"; then
        rm -f "${project_env_tmp}"
        print_error "Impossible d'ajouter la configuration Forgejo."
        return 1
    fi

    if ! mv -f "${project_env_tmp}" "${project_env}"; then
        rm -f "${project_env_tmp}"
        print_error "Impossible d'installer la configuration Forgejo."
        return 1
    fi

    if ! chown "${DEVOPS_USER}:${DEVOPS_GROUP}" "${project_env}" ||
        ! chmod 660 "${project_env}"; then
        print_error \
            "Impossible de préserver les droits de project.env."
        return 1
    fi

    print_success \
        "Configuration Forgejo enregistrée sans modifier les autres fournisseurs."
    return 0
}

# Vérifie et complète la configuration générale avant la configuration GitLab.
gitlab_project_config_ensure() {
    local project_id="${1:-}"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"
    local project_env="${project_path}/project.env"

    if [[ -z "${project_id}" ]]; then
        print_error "Usage : gitlab_project_config_ensure <project_id>"
        return 1
    fi

    if [[ ! -d "${project_path}" ]]; then
        print_error "Le répertoire du projet n'existe pas : ${project_path}"
        return 1
    fi

    if [[ ! -f "${project_env}" ]]; then
        return 1
    fi

    unset PROJECT_ID PROJECT_NAME PROJECT_TYPE PROJECT_DOCKERED

    # shellcheck disable=SC1090
    source "${project_env}"

    if [[ -z "${PROJECT_ID:-}" ||
        "${PROJECT_ID}" != "${project_id}" ||
        -z "${PROJECT_NAME:-}" ||
        -z "${PROJECT_TYPE:-}" ||
        -z "${PROJECT_DOCKERED:-}" \
    ]]; then
        return 1
    fi

    return 0
}

_gitlab_registry_is_valid() {
    local registry="${1:-}"

    [[ -n "${registry}" &&
        "${registry}" != http://* &&
        "${registry}" != https://* &&
        "${registry}" != */* &&
        "${registry}" != *[[:space:]]* ]]
}

# Complète uniquement le différentiel de configuration propre à GitLab.
gitlab_update() {
    local project_id="${1:-}"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"
    local project_env="${project_path}/project.env"
    local project_env_tmp="${project_env}.gitlab.tmp"
    local remote_gitlab_base_url=""
    local remote_gitlab_registry=""
    local remote_gitlab_owner=""
    local remote_gitlab_repository="${project_id}"
    local remote_gitlab_name="origin"
    local remote_gitlab_branch="main"
    local remote_gitlab_ssl_verify="No"
    local value=""

    if [[ -z "${project_id}" ]]; then
        print_error "Usage : gitlab_update <project_id>"
        return 1
    fi

    if [[ -f "${project_env}" ]]; then
        unset \
            REMOTE_GITLAB_BASE_URL \
            REMOTE_GITLAB_REGISTRY \
            REMOTE_GITLAB_OWNER \
            REMOTE_GITLAB_REPOSITORY \
            REMOTE_GITLAB_NAME \
            REMOTE_GITLAB_BRANCH \
            REMOTE_GITLAB_SSL_VERIFY

        # shellcheck disable=SC1090
        source "${project_env}"

        remote_gitlab_base_url="${REMOTE_GITLAB_BASE_URL:-${remote_gitlab_base_url}}"
        remote_gitlab_registry="${REMOTE_GITLAB_REGISTRY:-${remote_gitlab_registry}}"
        remote_gitlab_owner="${REMOTE_GITLAB_OWNER:-${remote_gitlab_owner}}"
        remote_gitlab_repository="${REMOTE_GITLAB_REPOSITORY:-${remote_gitlab_repository}}"
        remote_gitlab_name="${REMOTE_GITLAB_NAME:-${remote_gitlab_name}}"
        remote_gitlab_branch="${REMOTE_GITLAB_BRANCH:-${remote_gitlab_branch}}"
    fi

    if ! gitlab_project_config_ensure "${project_id}"; then
        print_info \
            "La configuration générale du projet est absente ou incomplète."

        if ! update_projects "${project_id}"; then
            print_error \
                "Impossible de compléter la configuration générale du projet."
            return 1
        fi
    fi

    if ! gitlab_project_config_ensure "${project_id}"; then
        print_error \
            "La configuration générale du projet reste non conforme."
        return 1
    fi

    unset \
        REMOTE_GITLAB_BASE_URL \
        REMOTE_GITLAB_REGISTRY \
        REMOTE_GITLAB_OWNER \
        REMOTE_GITLAB_REPOSITORY \
        REMOTE_GITLAB_NAME \
        REMOTE_GITLAB_BRANCH

    # shellcheck disable=SC1090
    source "${project_env}"

    remote_gitlab_base_url="${REMOTE_GITLAB_BASE_URL:-${remote_gitlab_base_url}}"
    remote_gitlab_registry="${REMOTE_GITLAB_REGISTRY:-${remote_gitlab_registry}}"
    remote_gitlab_owner="${REMOTE_GITLAB_OWNER:-${remote_gitlab_owner}}"
    remote_gitlab_repository="${REMOTE_GITLAB_REPOSITORY:-${remote_gitlab_repository}}"
    remote_gitlab_name="${REMOTE_GITLAB_NAME:-${remote_gitlab_name}}"
    remote_gitlab_branch="${REMOTE_GITLAB_BRANCH:-${remote_gitlab_branch}}"
    remote_gitlab_ssl_verify="${REMOTE_GITLAB_SSL_VERIFY:-${remote_gitlab_ssl_verify}}"

    print_title "Configuration GitLab du projet ${project_id}"

    value=""
    read -r -p \
        "REMOTE_GITLAB_BASE_URL [${remote_gitlab_base_url}] : " value
    if [[ -n "${value}" ]]; then
        remote_gitlab_base_url="${value}"
    fi
    remote_gitlab_base_url="${remote_gitlab_base_url%/}"
    while [[ -z "${remote_gitlab_base_url}" ]]; do
        print_error "REMOTE_GITLAB_BASE_URL ne peut pas être vide."
        read -r -p "REMOTE_GITLAB_BASE_URL : " remote_gitlab_base_url
        remote_gitlab_base_url="${remote_gitlab_base_url%/}"
    done

    value=""
    read -r -p \
        "REMOTE_GITLAB_REGISTRY [${remote_gitlab_registry}] : " value
    if [[ -n "${value}" ]]; then
        remote_gitlab_registry="${value}"
    fi
    while [[ -z "${remote_gitlab_registry}" ]]; do
        print_error "REMOTE_GITLAB_REGISTRY ne peut pas être vide."
        read -r -p "REMOTE_GITLAB_REGISTRY : " remote_gitlab_registry
    done
    while ! _gitlab_registry_is_valid "${remote_gitlab_registry}"; do
        print_error \
            "REMOTE_GITLAB_REGISTRY doit être une adresse sans protocole ni chemin."
        read -r -p "REMOTE_GITLAB_REGISTRY : " remote_gitlab_registry
    done

    value=""
    read -r -p \
        "REMOTE_GITLAB_OWNER [${remote_gitlab_owner}] : " value
    if [[ -n "${value}" ]]; then
        remote_gitlab_owner="${value}"
    fi
    while [[ -z "${remote_gitlab_owner}" ]]; do
        print_error "REMOTE_GITLAB_OWNER ne peut pas être vide."
        read -r -p "REMOTE_GITLAB_OWNER : " remote_gitlab_owner
    done

    value=""
    read -r -p \
        "REMOTE_GITLAB_REPOSITORY [${remote_gitlab_repository}] : " value
    if [[ -n "${value}" ]]; then
        remote_gitlab_repository="${value}"
    fi
    remote_gitlab_repository="${remote_gitlab_repository:-${project_id}}"

    value=""
    read -r -p \
        "REMOTE_GITLAB_NAME [${remote_gitlab_name}] : " value
    if [[ -n "${value}" ]]; then
        remote_gitlab_name="${value}"
    fi
    remote_gitlab_name="${remote_gitlab_name:-origin}"

    value=""
    read -r -p \
        "REMOTE_GITLAB_BRANCH [${remote_gitlab_branch}] : " value
    if [[ -n "${value}" ]]; then
        remote_gitlab_branch="${value}"
    fi
    remote_gitlab_branch="${remote_gitlab_branch:-main}"

    value=""
    read -r -p \
        "REMOTE_GITLAB_SSL_VERIFY [${remote_gitlab_ssl_verify}] : " value
    if [[ -n "${value}" ]]; then
        remote_gitlab_ssl_verify="${value}"
    fi
    case "${remote_gitlab_ssl_verify}" in
        Yes|yes|oui|OUI|true|TRUE|1)
            remote_gitlab_ssl_verify="Yes"
            ;;
        No|no|non|NON|false|FALSE|0)
            remote_gitlab_ssl_verify="No"
            ;;
        *)
            print_error "REMOTE_GITLAB_SSL_VERIFY doit valoir Yes ou No."
            return 1
            ;;
    esac

    if ! awk '
        !/^REMOTE_GITLAB_BASE_URL=/ &&
        !/^REMOTE_GITLAB_REGISTRY=/ &&
        !/^REMOTE_GITLAB_OWNER=/ &&
        !/^REMOTE_GITLAB_REPOSITORY=/ &&
        !/^REMOTE_GITLAB_NAME=/ &&
        !/^REMOTE_GITLAB_BRANCH=/ &&
        !/^REMOTE_GITLAB_SSL_VERIFY=/ &&
        !/^# GitLab distant$/ { print }
    ' "${project_env}" > "${project_env_tmp}"; then
        rm -f "${project_env_tmp}"
        print_error "Impossible de préparer project.env pour GitLab."
        return 1
    fi

    if ! {
        printf '\n# GitLab distant\n'
        printf 'REMOTE_GITLAB_BASE_URL=%q\n' "${remote_gitlab_base_url}"
        printf 'REMOTE_GITLAB_REGISTRY=%q\n' "${remote_gitlab_registry}"
        printf 'REMOTE_GITLAB_OWNER=%q\n' "${remote_gitlab_owner}"
        printf 'REMOTE_GITLAB_REPOSITORY=%q\n' "${remote_gitlab_repository}"
        printf 'REMOTE_GITLAB_NAME=%q\n' "${remote_gitlab_name}"
        printf 'REMOTE_GITLAB_BRANCH=%q\n' "${remote_gitlab_branch}"
        printf 'REMOTE_GITLAB_SSL_VERIFY=%q\n' "${remote_gitlab_ssl_verify}"
    } >> "${project_env_tmp}"; then
        rm -f "${project_env_tmp}"
        print_error "Impossible d'ajouter la configuration GitLab."
        return 1
    fi

    if ! mv -f "${project_env_tmp}" "${project_env}"; then
        rm -f "${project_env_tmp}"
        print_error "Impossible d'installer la configuration GitLab."
        return 1
    fi

    if ! chown "${DEVOPS_USER}:${DEVOPS_GROUP}" "${project_env}" ||
        ! chmod 660 "${project_env}"; then
        print_error \
            "Impossible de préserver les droits de project.env."
        return 1
    fi

    print_success \
        "Configuration GitLab enregistrée sans modifier la configuration générale."
    return 0
}

# Vérifie et complète la configuration générale avant la configuration GitHub.
github_project_config_ensure() {
    local project_id="${1:-}"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"
    local project_env="${project_path}/project.env"

    if [[ -z "${project_id}" ]]; then
        print_error "Usage : github_project_config_ensure <project_id>"
        return 1
    fi

    if [[ ! -d "${project_path}" || ! -f "${project_env}" ]]; then
        return 1
    fi

    unset PROJECT_ID PROJECT_NAME PROJECT_TYPE PROJECT_DOCKERED

    # shellcheck disable=SC1090
    source "${project_env}"

    if [[ -z "${PROJECT_ID:-}" ||
        "${PROJECT_ID}" != "${project_id}" ||
        -z "${PROJECT_NAME:-}" ||
        -z "${PROJECT_TYPE:-}" ||
        -z "${PROJECT_DOCKERED:-}" \
    ]]; then
        return 1
    fi

    return 0
}

# Complète uniquement le différentiel de configuration propre à GitHub.
github_update() {
    local project_id="${1:-}"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"
    local project_env="${project_path}/project.env"
    local project_env_tmp="${project_env}.github.tmp"
    local remote_github_base_url=""
    local remote_github_owner=""
    local remote_github_repository="${project_id}"
    local remote_github_name="origin"
    local remote_github_branch="main"
    local value=""

    if [[ -z "${project_id}" ]]; then
        print_error "Usage : github_update <project_id>"
        return 1
    fi

    if [[ ! -d "${project_path}" ]]; then
        print_error "Le répertoire du projet n'existe pas : ${project_path}"
        return 1
    fi

    if ! github_project_config_ensure "${project_id}"; then
        print_info \
            "La configuration générale du projet est absente ou incomplète."

        if ! update_projects "${project_id}"; then
            print_error \
                "Impossible de compléter la configuration générale du projet."
            return 1
        fi
    fi

    if ! github_project_config_ensure "${project_id}"; then
        print_error \
            "La configuration générale du projet reste non conforme."
        return 1
    fi

    unset \
        REMOTE_GITHUB_BASE_URL \
        REMOTE_GITHUB_OWNER \
        REMOTE_GITHUB_REPOSITORY \
        REMOTE_GITHUB_NAME \
        REMOTE_GITHUB_BRANCH

    # shellcheck disable=SC1090
    source "${project_env}"

    remote_github_base_url="${REMOTE_GITHUB_BASE_URL:-}"
    remote_github_owner="${REMOTE_GITHUB_OWNER:-}"
    remote_github_repository="${REMOTE_GITHUB_REPOSITORY:-${project_id}}"
    remote_github_name="${REMOTE_GITHUB_NAME:-origin}"
    remote_github_branch="${REMOTE_GITHUB_BRANCH:-main}"

    print_title "Configuration GitHub du projet ${project_id}"

    value=""
    read -r -p \
        "REMOTE_GITHUB_BASE_URL [${remote_github_base_url}] : " value
    if [[ -n "${value}" ]]; then
        remote_github_base_url="${value}"
    fi
    remote_github_base_url="${remote_github_base_url%/}"
    while [[ -z "${remote_github_base_url}" ]]; do
        print_error "REMOTE_GITHUB_BASE_URL ne peut pas être vide."
        read -r -p "REMOTE_GITHUB_BASE_URL : " remote_github_base_url
        remote_github_base_url="${remote_github_base_url%/}"
    done

    value=""
    read -r -p \
        "REMOTE_GITHUB_OWNER [${remote_github_owner}] : " value
    if [[ -n "${value}" ]]; then
        remote_github_owner="${value}"
    fi
    while [[ -z "${remote_github_owner}" ]]; do
        print_error "REMOTE_GITHUB_OWNER ne peut pas être vide."
        read -r -p "REMOTE_GITHUB_OWNER : " remote_github_owner
    done

    value=""
    read -r -p \
        "REMOTE_GITHUB_REPOSITORY [${remote_github_repository}] : " value
    if [[ -n "${value}" ]]; then
        remote_github_repository="${value}"
    fi
    remote_github_repository="${remote_github_repository:-${project_id}}"

    value=""
    read -r -p \
        "REMOTE_GITHUB_NAME [${remote_github_name}] : " value
    if [[ -n "${value}" ]]; then
        remote_github_name="${value}"
    fi
    remote_github_name="${remote_github_name:-origin}"

    value=""
    read -r -p \
        "REMOTE_GITHUB_BRANCH [${remote_github_branch}] : " value
    if [[ -n "${value}" ]]; then
        remote_github_branch="${value}"
    fi
    remote_github_branch="${remote_github_branch:-main}"

    if ! awk '
        !/^REMOTE_GITHUB_BASE_URL=/ &&
        !/^REMOTE_GITHUB_OWNER=/ &&
        !/^REMOTE_GITHUB_REPOSITORY=/ &&
        !/^REMOTE_GITHUB_NAME=/ &&
        !/^REMOTE_GITHUB_BRANCH=/ &&
        !/^# GitHub distant$/ { print }
    ' "${project_env}" > "${project_env_tmp}"; then
        rm -f "${project_env_tmp}"
        print_error "Impossible de préparer project.env pour GitHub."
        return 1
    fi

    if ! {
        printf '\n# GitHub distant\n'
        printf 'REMOTE_GITHUB_BASE_URL=%q\n' "${remote_github_base_url}"
        printf 'REMOTE_GITHUB_OWNER=%q\n' "${remote_github_owner}"
        printf 'REMOTE_GITHUB_REPOSITORY=%q\n' "${remote_github_repository}"
        printf 'REMOTE_GITHUB_NAME=%q\n' "${remote_github_name}"
        printf 'REMOTE_GITHUB_BRANCH=%q\n' "${remote_github_branch}"
    } >> "${project_env_tmp}"; then
        rm -f "${project_env_tmp}"
        print_error "Impossible d'ajouter la configuration GitHub."
        return 1
    fi

    if ! mv -f "${project_env_tmp}" "${project_env}"; then
        rm -f "${project_env_tmp}"
        print_error "Impossible d'installer la configuration GitHub."
        return 1
    fi

    if ! chown "${DEVOPS_USER}:${DEVOPS_GROUP}" "${project_env}" ||
        ! chmod 660 "${project_env}"; then
        print_error \
            "Impossible de préserver les droits de project.env."
        return 1
    fi

    print_success \
        "Configuration GitHub enregistrée sans modifier la configuration générale."
    return 0
}

# Push vers le dépôt distant Forgejo du projet <PROJECT ID>
forgejo_push() {
    local project_id="${1:-}"

    if [[ -z "${project_id}" ]]; then
        print_error "forgejo_push : PROJECT_ID est vide."
        return 1
    fi

    git_push_provider "${project_id}" "forgejo"
}

# Push vers Forgejo de tous les projets configurés.
forgejo_push_all() {
    local projects_root="${DEVOPS_PROJECTS_ROOT:-/home/${DEVOPS_USER}/datas}"
    local project_path=""
    local project_id=""
    local project_env=""
    local failed=0
    local selected=0

    if [[ ! -d "${projects_root}" ]]; then
        print_error "Répertoire des projets introuvable : ${projects_root}"
        return 1
    fi

    print_title "Push Forgejo de tous les projets configurés"

    for project_path in "${projects_root}"/*; do
        if [[ ! -d "${project_path}" ]]; then
            continue
        fi

        project_id="$(basename -- "${project_path}")"
        project_env="${project_path}/project.env"

        if [[ ! -f "${project_env}" ]]; then
            print_info "Projet ignoré : ${project_id} (project.env absent)."
            continue
        fi

        unset \
            PROJECT_ID \
            PROJECT_NAME \
            PROJECT_TYPE \
            PROJECT_DOCKERED \
            REMOTE_FORGEJO_BASE_URL \
            REMOTE_FORGEJO_OWNER \
            REMOTE_FORGEJO_REPOSITORY \
            REMOTE_FORGEJO_NAME \
            REMOTE_FORGEJO_BRANCH \
            REMOTE_FORGEJO_SSL_VERIFY

        # shellcheck disable=SC1090
        if ! source "${project_env}"; then
            print_error "Projet ignoré : ${project_id} (project.env illisible)."
            continue
        fi

        if [[ \
            -z "${PROJECT_ID:-}" || \
            "${PROJECT_ID}" != "${project_id}" || \
            -z "${PROJECT_NAME:-}" || \
            -z "${PROJECT_TYPE:-}" || \
            -z "${PROJECT_DOCKERED:-}" || \
            -z "${REMOTE_FORGEJO_BASE_URL:-}" || \
            -z "${REMOTE_FORGEJO_OWNER:-}" || \
            -z "${REMOTE_FORGEJO_REPOSITORY:-}" || \
            -z "${REMOTE_FORGEJO_NAME:-}" || \
            -z "${REMOTE_FORGEJO_BRANCH:-}" || \
            -z "${REMOTE_FORGEJO_SSL_VERIFY:-}" \
        ]]; then
            print_error "Projet ignoré : ${project_id} (configuration Forgejo incomplète)."
            continue
        fi

        selected=$((selected + 1))

        if ! forgejo_push "${project_id}"; then
            print_error "Échec du push Forgejo pour le projet ${project_id}."
            failed=1
        fi
    done

    if [[ "${selected}" -eq 0 ]]; then
        print_info "Aucun projet Forgejo configuré à traiter."
        return 0
    fi

    if [[ "${failed}" -ne 0 ]]; then
        print_error "Au moins un push Forgejo a échoué."
        return 1
    fi

    print_success "Push Forgejo terminé pour tous les projets configurés."
    return 0
}

# Push vers le dépôt distant GitLab du projet <PROJECT ID>
gitlab_push() {

    local project_id="${1:-}"

    if [[ -z "${project_id}" ]]; then
        print_error "gitlab_push : PROJECT_ID est vide."
        return 1
    fi

    git_push_provider "${project_id}" "gitlab"
}

# Crée un projet depuis le modèle puis fusionne son dépôt GitLab distant.
gitlab_clone() {
    local project_id="${1:-}"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"
    local project_env="${project_path}/project.env"
    local clone_root=""
    local clone_path=""
    local merge_path=""
    local backup_path=""
    local remote_url=""

    if [[ -z "${project_id}" ]]; then
        print_error "Usage : gitlab_clone <ID PROJECT>"
        return 1
    fi

    if ! create_project "${project_id}"; then
        return 1
    fi

    if ! gitlab_update "${project_id}"; then
        print_error "Impossible de configurer GitLab pour le projet ${project_id}."
        return 1
    fi

    unset REMOTE_GITLAB_BASE_URL REMOTE_GITLAB_OWNER REMOTE_GITLAB_REPOSITORY \
        REMOTE_GITLAB_BRANCH REMOTE_GITLAB_SSL_VERIFY
    # shellcheck disable=SC1090
    source "${project_env}"

    if [[ -z "${REMOTE_GITLAB_BASE_URL:-}" ||
        -z "${REMOTE_GITLAB_OWNER:-}" ||
        -z "${REMOTE_GITLAB_REPOSITORY:-}" ||
        -z "${REMOTE_GITLAB_BRANCH:-}" ]]; then
        print_error "La configuration GitLab est incomplète."
        return 1
    fi

    remote_url="${REMOTE_GITLAB_BASE_URL%/}/${REMOTE_GITLAB_OWNER}/${REMOTE_GITLAB_REPOSITORY}.git"
    if ! clone_root="$(runuser -u "${DEVOPS_USER}" -- mktemp -d)"; then
        print_error "Impossible de créer le répertoire temporaire de clonage."
        return 1
    fi
    clone_path="${clone_root}/repository"

    if ! gitlab_git_clone "${project_path}" "${remote_url}" \
        "${REMOTE_GITLAB_BRANCH}" "${clone_path}"; then
        rm -rf -- "${clone_root}"
        print_error "Échec du clonage du dépôt GitLab distant."
        return 1
    fi

    if ! merge_path="$(mktemp -d "${DEVOPS_PROJECTS_ROOT}/.${project_id}.gitlab-merge.XXXXXX")"; then
        rm -rf -- "${clone_root}"
        print_error "Impossible de préparer la fusion GitLab."
        return 1
    fi

    if ! cp -a "${project_path}/." "${merge_path}/" ||
        ! cp -a --remove-destination "${clone_path}/." "${merge_path}/" ||
        ! find "${merge_path}" -name .git -prune -exec rm -rf -- {} + ||
        ! chown -R "${DEVOPS_USER}:${DEVOPS_GROUP}" "${merge_path}"; then
        rm -rf -- "${clone_root}" "${merge_path}"
        print_error "Échec de la préparation de la fusion GitLab."
        return 1
    fi
    rm -rf -- "${clone_root}"

    backup_path="${DEVOPS_PROJECTS_ROOT}/.${project_id}.gitlab-backup.$$"
    if [[ -e "${backup_path}" ]] || ! mv "${project_path}" "${backup_path}"; then
        rm -rf -- "${merge_path}"
        print_error "Impossible de préparer le remplacement du projet."
        return 1
    fi
    if ! mv "${merge_path}" "${project_path}"; then
        if ! mv "${backup_path}" "${project_path}"; then
            print_error "Impossible de restaurer le projet après l'échec de la fusion GitLab."
        fi
        rm -rf -- "${merge_path}"
        print_error "Impossible d'installer la fusion GitLab."
        return 1
    fi
    rm -rf -- "${backup_path}"

    print_success "Projet GitLab cloné et fusionné : ${project_path}"
    return 0
}

# Push vers le dépôt distant GitHub du projet <PROJECT ID>
github_push() {
    local project_id="${1:-}"

    if [[ -z "${project_id}" ]]; then
        print_error "github_push : PROJECT_ID est vide."
        return 1
    fi

    git_push_provider "${project_id}" "github"
}

# Crée un projet depuis le modèle puis fusionne son dépôt GitHub distant.
github_clone() {
    local project_id="${1:-}"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"
    local project_env="${project_path}/project.env"
    local clone_root=""
    local clone_path=""
    local merge_path=""
    local backup_path=""
    local remote_url=""

    if [[ -z "${project_id}" ]]; then
        print_error "Usage : github_clone <ID PROJECT>"
        return 1
    fi

    if ! create_project "${project_id}"; then
        return 1
    fi

    if ! github_update "${project_id}"; then
        print_error "Impossible de configurer GitHub pour le projet ${project_id}."
        return 1
    fi

    unset REMOTE_GITHUB_BASE_URL REMOTE_GITHUB_OWNER REMOTE_GITHUB_REPOSITORY \
        REMOTE_GITHUB_BRANCH
    # shellcheck disable=SC1090
    source "${project_env}"

    if [[ -z "${REMOTE_GITHUB_BASE_URL:-}" ||
        -z "${REMOTE_GITHUB_OWNER:-}" ||
        -z "${REMOTE_GITHUB_REPOSITORY:-}" ||
        -z "${REMOTE_GITHUB_BRANCH:-}" ]]; then
        print_error "La configuration GitHub est incomplète."
        return 1
    fi

    remote_url="${REMOTE_GITHUB_BASE_URL%/}/${REMOTE_GITHUB_OWNER}/${REMOTE_GITHUB_REPOSITORY}.git"
    if ! clone_root="$(runuser -u "${DEVOPS_USER}" -- mktemp -d)"; then
        print_error "Impossible de créer le répertoire temporaire de clonage."
        return 1
    fi
    clone_path="${clone_root}/repository"

    if ! github_git_clone "${project_path}" "${remote_url}" \
        "${REMOTE_GITHUB_BRANCH}" "${clone_path}"; then
        rm -rf -- "${clone_root}"
        print_error "Échec du clonage du dépôt GitHub distant."
        return 1
    fi

    if ! merge_path="$(mktemp -d "${DEVOPS_PROJECTS_ROOT}/.${project_id}.github-merge.XXXXXX")"; then
        rm -rf -- "${clone_root}"
        print_error "Impossible de préparer la fusion GitHub."
        return 1
    fi

    if ! cp -a "${project_path}/." "${merge_path}/" ||
        ! cp -a --remove-destination "${clone_path}/." "${merge_path}/" ||
        ! find "${merge_path}" -name .git -prune -exec rm -rf -- {} + ||
        ! chown -R "${DEVOPS_USER}:${DEVOPS_GROUP}" "${merge_path}"; then
        rm -rf -- "${clone_root}" "${merge_path}"
        print_error "Échec de la préparation de la fusion GitHub."
        return 1
    fi
    rm -rf -- "${clone_root}"

    backup_path="${DEVOPS_PROJECTS_ROOT}/.${project_id}.github-backup.$$"
    if [[ -e "${backup_path}" ]] || ! mv "${project_path}" "${backup_path}"; then
        rm -rf -- "${merge_path}"
        print_error "Impossible de préparer le remplacement du projet."
        return 1
    fi
    if ! mv "${merge_path}" "${project_path}"; then
        if ! mv "${backup_path}" "${project_path}"; then
            print_error "Impossible de restaurer le projet après l'échec de la fusion GitHub."
        fi
        rm -rf -- "${merge_path}"
        print_error "Impossible d'installer la fusion GitHub."
        return 1
    fi
    rm -rf -- "${backup_path}"

    print_success "Projet GitHub cloné et fusionné : ${project_path}"
    return 0
}

# Publie vers Forgejo les artefacts activés du projet <PROJECT ID>.
projects_forgejo_release() {
    local project_id="${1:-}"
    local project_path=""
    local project_env=""
    local docker_enabled="No"
    local debian_enabled="No"
    local debian_file=""
    local -a debian_files=()

    if [[ -z "${project_id}" ]]; then
        print_error "Usage : projects_forgejo_release <project_id>"
        return 1
    fi

    project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"
    project_env="${project_path}/project.env"

    if [[ ! -d "${project_path}" ]]; then
        print_error "Projet introuvable : ${project_path}"
        return 1
    fi

    if [[ ! -f "${project_env}" ]]; then
        print_info "Configuration générale absente ; initialisation du projet."
        if ! update_projects "${project_id}"; then
            print_error "Impossible d'initialiser la configuration du projet."
            return 1
        fi
    fi

    unset \
        PROJECT_ID \
        PROJECT_NAME \
        PROJECT_TYPE \
        PROJECT_DOCKERED \
        PROJECT_DEBIAN_PACKAGE \
        REMOTE_FORGEJO_BASE_URL \
        REMOTE_FORGEJO_OWNER \
        REMOTE_FORGEJO_REPOSITORY \
        REMOTE_FORGEJO_NAME \
        REMOTE_FORGEJO_BRANCH \
        REMOTE_FORGEJO_SSL_VERIFY

    # shellcheck disable=SC1090
    source "${project_env}"

    if [[ -z "${PROJECT_ID:-}" ||
        "${PROJECT_ID}" != "${project_id}" ||
        -z "${PROJECT_NAME:-}" ||
        -z "${PROJECT_TYPE:-}" ||
        -z "${PROJECT_DOCKERED:-}" ||
        -z "${PROJECT_DEBIAN_PACKAGE:-}" ]]; then
        print_info "Configuration générale incomplète ; mise à jour du projet."
        if ! update_projects "${project_id}"; then
            print_error "Impossible de compléter la configuration du projet."
            return 1
        fi
        unset \
            PROJECT_ID \
            PROJECT_NAME \
            PROJECT_TYPE \
            PROJECT_DOCKERED \
            PROJECT_DEBIAN_PACKAGE \
            REMOTE_FORGEJO_BASE_URL \
            REMOTE_FORGEJO_OWNER \
            REMOTE_FORGEJO_REPOSITORY \
            REMOTE_FORGEJO_NAME \
            REMOTE_FORGEJO_BRANCH \
            REMOTE_FORGEJO_SSL_VERIFY
        # shellcheck disable=SC1090
        source "${project_env}"
    fi

    if [[ -z "${REMOTE_FORGEJO_BASE_URL:-}" ||
        -z "${REMOTE_FORGEJO_OWNER:-}" ||
        -z "${REMOTE_FORGEJO_REPOSITORY:-}" ||
        -z "${REMOTE_FORGEJO_NAME:-}" ||
        -z "${REMOTE_FORGEJO_BRANCH:-}" ||
        -z "${REMOTE_FORGEJO_SSL_VERIFY:-}" ]]; then
        print_info "Configuration Forgejo incomplète ; mise à jour Forgejo."
        if ! forgejo_update "${project_id}"; then
            print_error "Impossible de compléter la configuration Forgejo."
            return 1
        fi
        unset \
            PROJECT_ID \
            PROJECT_NAME \
            PROJECT_TYPE \
            PROJECT_DOCKERED \
            PROJECT_DEBIAN_PACKAGE \
            REMOTE_FORGEJO_BASE_URL \
            REMOTE_FORGEJO_OWNER \
            REMOTE_FORGEJO_REPOSITORY \
            REMOTE_FORGEJO_NAME \
            REMOTE_FORGEJO_BRANCH \
            REMOTE_FORGEJO_SSL_VERIFY
        # shellcheck disable=SC1090
        source "${project_env}"
    fi

    if [[ "${PROJECT_ID:-}" != "${project_id}" ||
        -z "${PROJECT_NAME:-}" ||
        -z "${PROJECT_TYPE:-}" ||
        -z "${PROJECT_DOCKERED:-}" ||
        -z "${PROJECT_DEBIAN_PACKAGE:-}" ]]; then
        print_error "Configuration générale invalide après mise à jour."
        return 1
    fi

    if [[ -z "${REMOTE_FORGEJO_BASE_URL:-}" ||
        -z "${REMOTE_FORGEJO_OWNER:-}" ||
        -z "${REMOTE_FORGEJO_REPOSITORY:-}" ||
        -z "${REMOTE_FORGEJO_NAME:-}" ||
        -z "${REMOTE_FORGEJO_BRANCH:-}" ||
        -z "${REMOTE_FORGEJO_SSL_VERIFY:-}" ]]; then
        print_error "Configuration Forgejo invalide après mise à jour."
        return 1
    fi

    docker_enabled="${PROJECT_DOCKERED}"
    debian_enabled="${PROJECT_DEBIAN_PACKAGE}"

    case "${docker_enabled}" in
        Yes|YES|1)
            docker_enabled="Yes"
            ;;
        *)
            docker_enabled="No"
            ;;
    esac

    case "${debian_enabled}" in
        Yes|YES|1)
            debian_enabled="Yes"
            ;;
        *)
            debian_enabled="No"
            ;;
    esac

    if [[ "${docker_enabled}" == "No" && "${debian_enabled}" == "No" ]]; then
        print_error "Aucun artefact Docker ou Debian n'est activé pour ${project_id}."
        return 1
    fi

    if [[ "${docker_enabled}" == "Yes" ]]; then
        if ! runuser -u "${DEVOPS_USER}" -- \
            docker image inspect "${PROJECT_ID}:latest" >/dev/null 2>&1; then
            print_error "Image Docker locale introuvable : ${PROJECT_ID}:latest"
            return 1
        fi
    fi

    if [[ "${debian_enabled}" == "Yes" ]]; then
        if [[ ! -d "${project_path}/dist" ]]; then
            print_error "Répertoire dist/ introuvable : ${project_path}/dist"
            return 1
        fi

        while IFS= read -r -d '' debian_file; do
            debian_files+=("${debian_file}")
        done < <(
            find "${project_path}/dist" \
                -maxdepth 1 \
                -type f \
                -name '*.deb' \
                -print0 \
                2>/dev/null
        )

        if [[ ${#debian_files[@]} -eq 0 ]]; then
            print_error "Aucun paquet Debian trouvé dans ${project_path}/dist/"
            return 1
        fi

        if [[ ${#debian_files[@]} -gt 1 ]]; then
            print_error "Plusieurs paquets Debian sont présents dans dist/ :"
            for debian_file in "${debian_files[@]}"; do
                printf '  %s\n' "$(basename "${debian_file}")"
            done
            return 1
        fi
    fi

    if [[ "${docker_enabled}" == "Yes" ]]; then
        if ! projects_forgejo_release_docker "${project_id}"; then
            return 1
        fi
    fi

    if [[ "${debian_enabled}" == "Yes" ]]; then
        if ! publish_release_debian "${project_id}"; then
            return 1
        fi
    fi

    print_success "Release Forgejo du projet ${project_id} terminée."
    return 0
}

# Publication vers GitLab des artefacts du projet <PROJECT_ID>.
projects_gitlab_release() {
    local project_id="${1:-}"
    local project_path=""
    local project_env=""
    local docker_enabled="No"
    local debian_enabled="No"
    local gitlab_registry_valid="No"
    local debian_file=""
    local -a debian_files=()

    if [[ -z "${project_id}" ]]; then
        print_error "Usage : projects_gitlab_release <project_id>"
        return 1
    fi

    project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"
    project_env="${project_path}/project.env"

    if [[ ! -d "${project_path}" ]]; then
        print_error "Projet introuvable : ${project_path}"
        return 1
    fi

    if [[ ! -f "${project_env}" ]]; then
        print_info "Configuration générale absente ; initialisation du projet."
        if ! update_projects "${project_id}"; then
            print_error "Impossible d'initialiser la configuration du projet."
            return 1
        fi
    fi

    unset \
        PROJECT_ID \
        PROJECT_NAME \
        PROJECT_TYPE \
        PROJECT_DOCKERED \
        PROJECT_DEBIAN_PACKAGE \
        REMOTE_GITLAB_BASE_URL \
        REMOTE_GITLAB_REGISTRY \
        REMOTE_GITLAB_OWNER \
        REMOTE_GITLAB_REPOSITORY \
        REMOTE_GITLAB_NAME \
        REMOTE_GITLAB_BRANCH \
        REMOTE_GITLAB_SSL_VERIFY

    # shellcheck disable=SC1090
    source "${project_env}"

    if _gitlab_registry_is_valid "${REMOTE_GITLAB_REGISTRY:-}"; then
        gitlab_registry_valid="Yes"
    fi

    if [[ -z "${PROJECT_ID:-}" ||
        "${PROJECT_ID}" != "${project_id}" ||
        -z "${PROJECT_NAME:-}" ||
        -z "${PROJECT_TYPE:-}" ||
        -z "${PROJECT_DOCKERED:-}" ||
        -z "${PROJECT_DEBIAN_PACKAGE:-}" ]]; then

        print_info "Configuration générale incomplète ; mise à jour du projet."
        if ! update_projects "${project_id}"; then
            print_error "Impossible de compléter la configuration du projet."
            return 1
        fi

        unset \
            PROJECT_ID \
            PROJECT_NAME \
            PROJECT_TYPE \
            PROJECT_DOCKERED \
            PROJECT_DEBIAN_PACKAGE \
            REMOTE_GITLAB_BASE_URL \
            REMOTE_GITLAB_REGISTRY \
            REMOTE_GITLAB_OWNER \
            REMOTE_GITLAB_REPOSITORY \
            REMOTE_GITLAB_NAME \
            REMOTE_GITLAB_BRANCH \
            REMOTE_GITLAB_SSL_VERIFY
        # shellcheck disable=SC1090
        source "${project_env}"

        gitlab_registry_valid="No"
        if _gitlab_registry_is_valid "${REMOTE_GITLAB_REGISTRY:-}"; then
            gitlab_registry_valid="Yes"
        fi
    fi

    if [[ -z "${REMOTE_GITLAB_BASE_URL:-}" ||
        -z "${REMOTE_GITLAB_REGISTRY:-}" ||
        "${gitlab_registry_valid}" != "Yes" ||
        -z "${REMOTE_GITLAB_OWNER:-}" ||
        -z "${REMOTE_GITLAB_REPOSITORY:-}" ||
        -z "${REMOTE_GITLAB_NAME:-}" ||
        -z "${REMOTE_GITLAB_BRANCH:-}" ||
        -z "${REMOTE_GITLAB_SSL_VERIFY:-}" ]]; then

        print_info "Configuration GitLab incomplète ; mise à jour GitLab."
        if ! gitlab_update "${project_id}"; then
            print_error "Impossible de compléter la configuration GitLab."
            return 1
        fi

        unset \
            PROJECT_ID \
            PROJECT_NAME \
            PROJECT_TYPE \
            PROJECT_DOCKERED \
            PROJECT_DEBIAN_PACKAGE \
            REMOTE_GITLAB_BASE_URL \
            REMOTE_GITLAB_REGISTRY \
            REMOTE_GITLAB_OWNER \
            REMOTE_GITLAB_REPOSITORY \
            REMOTE_GITLAB_NAME \
            REMOTE_GITLAB_BRANCH \
            REMOTE_GITLAB_SSL_VERIFY
        # shellcheck disable=SC1090
        source "${project_env}"

        gitlab_registry_valid="No"
        if _gitlab_registry_is_valid "${REMOTE_GITLAB_REGISTRY:-}"; then
            gitlab_registry_valid="Yes"
        fi
    fi

    if [[ "${PROJECT_ID:-}" != "${project_id}" ||
        -z "${PROJECT_NAME:-}" ||
        -z "${PROJECT_TYPE:-}" ||
        -z "${PROJECT_DOCKERED:-}" ||
        -z "${PROJECT_DEBIAN_PACKAGE:-}" ]]; then
        print_error "Configuration générale invalide après mise à jour."
        return 1
    fi

    if [[ -z "${REMOTE_GITLAB_BASE_URL:-}" ||
        -z "${REMOTE_GITLAB_REGISTRY:-}" ||
        "${gitlab_registry_valid}" != "Yes" ||
        -z "${REMOTE_GITLAB_OWNER:-}" ||
        -z "${REMOTE_GITLAB_REPOSITORY:-}" ||
        -z "${REMOTE_GITLAB_NAME:-}" ||
        -z "${REMOTE_GITLAB_BRANCH:-}" ||
        -z "${REMOTE_GITLAB_SSL_VERIFY:-}" ]]; then
        print_error "Configuration GitLab invalide après mise à jour."
        return 1
    fi

    docker_enabled="${PROJECT_DOCKERED}"
    debian_enabled="${PROJECT_DEBIAN_PACKAGE}"

    case "${docker_enabled}" in
        Yes|YES|1)
            docker_enabled="Yes"
            ;;
        *)
            docker_enabled="No"
            ;;
    esac

    case "${debian_enabled}" in
        Yes|YES|1)
            debian_enabled="Yes"
            ;;
        *)
            debian_enabled="No"
            ;;
    esac

    if [[ "${docker_enabled}" == "No" && "${debian_enabled}" == "No" ]]; then
        print_error "Aucun artefact Docker ou Debian n'est activé pour ${project_id}."
        return 1
    fi

    if [[ "${docker_enabled}" == "Yes" ]]; then
        if ! runuser -u "${DEVOPS_USER}" -- \
            docker image inspect "${PROJECT_ID}:latest" >/dev/null 2>&1; then
            print_error "Image Docker locale introuvable : ${PROJECT_ID}:latest"
            return 1
        fi
    fi

    if [[ "${debian_enabled}" == "Yes" ]]; then
        if [[ ! -d "${project_path}/dist" ]]; then
            print_error "Répertoire dist/ introuvable : ${project_path}/dist"
            return 1
        fi

        while IFS= read -r -d '' debian_file; do
            debian_files+=("${debian_file}")
        done < <(
            find "${project_path}/dist" \
                -maxdepth 1 \
                -type f \
                -name '*.deb' \
                -print0 \
                2>/dev/null
        )

        if [[ ${#debian_files[@]} -eq 0 ]]; then
            print_error "Aucun paquet Debian trouvé dans ${project_path}/dist/"
            return 1
        fi

        if [[ ${#debian_files[@]} -gt 1 ]]; then
            print_error "Plusieurs paquets Debian sont présents dans dist/ :"
            for debian_file in "${debian_files[@]}"; do
                printf '  %s\n' "$(basename "${debian_file}")"
            done
            return 1
        fi
    fi

    if [[ "${docker_enabled}" == "Yes" ]]; then
        if ! projects_gitlab_release_docker "${project_id}"; then
            return 1
        fi
    fi

    if [[ "${debian_enabled}" == "Yes" ]]; then
        if ! projects_gitlab_release_debian "${project_id}"; then
            return 1
        fi
    fi

    print_success "Release GitLab du projet ${project_id} terminée."
    return 0
}

# Publication de l'image Docker d'un projet vers GitLab.
projects_gitlab_release_docker() {
    local project_id="${1:-}"

    local project_dir=""
    local project_env=""

    local git_tag=""
    local git_tags_count=0
    local docker_version=""

    local local_image=""
    local remote_registry=""
    local remote_image_version=""
    local remote_image_latest=""
    local docker_publish_rc=0
    local docker_config=""

    local remote_gitlab_base_url=""
    local remote_gitlab_owner=""
    local remote_gitlab_repository=""
    local remote_gitlab_name=""
    local remote_gitlab_branch=""
    local gitlab_registry_valid="No"

    local gitlab_username=""
    local gitlab_token=""

    if [[ -z "${project_id}" ]]; then
        print_error \
            "Usage : projects_gitlab_release_docker <project_id>"
        return 1
    fi

    project_dir="${DEVOPS_PROJECTS_ROOT}/${project_id}"
    project_env="${project_dir}/project.env"

    if [[ ! -d "${project_dir}" ]]; then
        print_error \
            "Projet introuvable : ${project_dir}"
        return 1
    fi

    if [[ ! -f "${project_env}" ]]; then
        print_error \
            "Fichier project.env introuvable : ${project_env}"
        return 1
    fi

    # shellcheck disable=SC1090
    source "${project_env}"

    case "${PROJECT_DOCKERED:-No}" in
        Yes|YES|1)
            ;;
        *)
            print_error \
                "Le projet '${project_id}' n'est pas déclaré comme Dockerisé."
            return 1
            ;;
    esac

    remote_gitlab_base_url="${REMOTE_GITLAB_BASE_URL:-}"
    remote_registry="${REMOTE_GITLAB_REGISTRY:-}"
    remote_gitlab_owner="${REMOTE_GITLAB_OWNER:-}"
    remote_gitlab_repository="${REMOTE_GITLAB_REPOSITORY:-${project_id}}"
    remote_gitlab_name="${REMOTE_GITLAB_NAME:-origin}"
    remote_gitlab_branch="${REMOTE_GITLAB_BRANCH:-main}"

    if _gitlab_registry_is_valid "${remote_registry}"; then
        gitlab_registry_valid="Yes"
    fi

    if [[ -z "${remote_gitlab_base_url}" ||
        -z "${remote_registry}" ||
        "${gitlab_registry_valid}" != "Yes" ||
        -z "${remote_gitlab_owner}" ||
        -z "${remote_gitlab_repository}" ||
        -z "${remote_gitlab_name}" ||
        -z "${remote_gitlab_branch}" ]]; then
        print_error "Configuration GitLab incomplète."
        return 1
    fi

    # Vérification du dépôt Git
    if ! command -v git >/dev/null 2>&1; then
        print_error "Git n'est pas installé."
        return 1
    fi

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_dir}" \
        rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        print_error "Le projet n'est pas un dépôt Git valide : ${project_dir}"
        return 1
    fi

    git_tags_count="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_dir}" \
            tag --points-at HEAD 2>/dev/null |
            sed '/^[[:space:]]*$/d' |
            wc -l
    )"

    if [[ "${git_tags_count}" -eq 0 ]]; then
        print_error "Aucun tag Git associé au dernier commit."
        return 1
    fi

    if [[ "${git_tags_count}" -gt 1 ]]; then
        print_error "Plusieurs tags Git sont associés au dernier commit."
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_dir}" \
            tag --points-at HEAD
        return 1
    fi

    git_tag="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_dir}" \
            tag --points-at HEAD 2>/dev/null |
            head -n 1
    )"

    if [[ -z "${git_tag}" ]]; then
        print_error "Impossible de déterminer le tag Git du dernier commit."
        return 1
    fi

    docker_version="${git_tag#v}"

    if [[ -z "${docker_version}" ]]; then
        print_error "Version Docker invalide déduite du tag Git '${git_tag}'."
        return 1
    fi

    local_image="${PROJECT_ID:-${project_id}}:latest"
    remote_image_version="${remote_registry}/${remote_gitlab_owner}/${remote_gitlab_repository}:${docker_version}"
    remote_image_latest="${remote_registry}/${remote_gitlab_owner}/${remote_gitlab_repository}:latest"

    if ! runuser -u "${DEVOPS_USER}" -- \
        docker image inspect "${local_image}" >/dev/null 2>&1; then
        print_error "Image Docker locale introuvable : ${local_image}"
        return 1
    fi

    if ! _gitlab_read_username "${project_dir}"; then
        print_error "Impossible de lire le nom d'utilisateur GitLab."
        return 1
    fi

    if ! _gitlab_read_token "${project_dir}"; then
        print_error "Impossible de lire le token GitLab."
        return 1
    fi

    if [[ -z "${gitlab_username}" ]]; then
        print_error "Nom d'utilisateur GitLab vide."
        return 1
    fi

    if [[ -z "${gitlab_token}" ]]; then
        print_error "Token GitLab vide."
        return 1
    fi

    if ! command -v docker >/dev/null 2>&1; then
        print_error "Docker n'est pas installé."
        unset gitlab_token
        return 1
    fi

    if ! runuser -u "${DEVOPS_USER}" -- \
        docker tag \
            "${local_image}" \
            "${remote_image_version}"; then
        print_error "Échec du tag Docker versionné."
        unset gitlab_token
        return 1
    fi

    if ! runuser -u "${DEVOPS_USER}" -- \
        docker tag \
            "${local_image}" \
            "${remote_image_latest}"; then
        print_error "Échec du tag Docker latest."
        unset gitlab_token
        return 1
    fi

    docker_config="$(runuser -u "${DEVOPS_USER}" -- mktemp -d)" || {
        print_error "Impossible de créer le DOCKER_CONFIG temporaire."
        unset gitlab_token
        return 1
    }

    if [[ -z "${docker_config}" ]] || [[ ! -d "${docker_config}" ]]; then
        print_error "DOCKER_CONFIG temporaire invalide."
        rm -rf "${docker_config}"
        unset gitlab_token
        return 1
    fi

    if ! chmod 700 "${docker_config}"; then
        print_error "Impossible de sécuriser ${docker_config}"
        rm -rf "${docker_config}"
        unset gitlab_token
        return 1
    fi

    docker_publish_rc=0

    (
        trap 'rm -rf "${docker_config}"' EXIT

        if ! printf '%s' "${gitlab_token}" | \
            runuser -u "${DEVOPS_USER}" -- \
                env "DOCKER_CONFIG=${docker_config}" \
                docker login \
                    "${remote_registry}" \
                    --username "${gitlab_username}" \
                    --password-stdin; then
            print_error \
                "Échec de l'authentification Docker auprès de ${remote_registry}."
            exit 1
        fi

        if ! runuser -u "${DEVOPS_USER}" -- \
            env "DOCKER_CONFIG=${docker_config}" \
            docker push "${remote_image_version}"; then
            print_error \
                "Échec de la publication de ${remote_image_version}."
            exit 1
        fi

        if ! runuser -u "${DEVOPS_USER}" -- \
            env "DOCKER_CONFIG=${docker_config}" \
            docker push "${remote_image_latest}"; then
            print_error \
                "Échec de la publication de ${remote_image_latest}."
            exit 1
        fi

        exit 0
    ) || docker_publish_rc=$?

    unset gitlab_token

    if [[ "${docker_publish_rc}" -ne 0 ]]; then
        print_error "Échec de la publication de la Release Docker GitLab."
        return "${docker_publish_rc}"
    fi

    print_success \
        "Release Docker publiée avec succès vers GitLab."
    return 0
}

# Publication du paquet Debian d'un projet via une release GitLab.
projects_gitlab_release_debian() {
    local project_id="${1:-}"
    local project_path=""
    local project_env=""
    local project_name=""
    local deb_file=""
    local deb_filename=""
    local remote_api_base=""
    local remote_project=""
    local remote_project_encoded=""
    local git_tag=""
    local git_tags_count=0
    local release_payload=""
    local upload_body=""
    local upload_response=""
    local upload_url=""
    local link_payload=""
    local release_body=""
    local release_http_code=""
    local upload_http_code=""
    local link_http_code=""
    local gitlab_username=""
    local gitlab_token=""
    local local_api_url=""
    local asset_url=""
    local missing_fields=()

    if [[ -z "${project_id}" ]]; then
        print_error "Usage : projects_gitlab_release_debian <project_id>"
        return 1
    fi

    project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"
    project_env="${project_path}/project.env"
    if [[ ! -d "${project_path}" ]]; then
        print_error "Projet introuvable : ${project_path}"
        return 1
    fi

    if [[ ! -f "${project_env}" ]]; then
        print_error "Fichier project.env introuvable : ${project_env}"
        return 1
    fi

    unset \
        PROJECT_DOCKERED \
        PROJECT_DEBIAN_PACKAGE \
        PROJECT_ID \
        PROJECT_NAME \
        PROJECT_TYPE \
        REMOTE_GITLAB_BASE_URL \
        REMOTE_GITLAB_OWNER \
        REMOTE_GITLAB_REPOSITORY \
        REMOTE_GITLAB_NAME \
        REMOTE_GITLAB_BRANCH \
        REMOTE_GITLAB_SSL_VERIFY
    # shellcheck disable=SC1090
    source "${project_env}"

    project_name="${PROJECT_NAME:-}"

    if [[ -z "${project_name}" ||
        -z "${PROJECT_ID:-}" ||
        -z "${PROJECT_TYPE:-}" ||
        -z "${PROJECT_DOCKERED:-}" ||
        -z "${PROJECT_DEBIAN_PACKAGE:-}" ]]; then
        print_error "Configuration générale incomplète."
        return 1
    fi

    if [[ -z "${REMOTE_GITLAB_BASE_URL:-}" ||
        -z "${REMOTE_GITLAB_OWNER:-}" ||
        -z "${REMOTE_GITLAB_REPOSITORY:-}" ||
        -z "${REMOTE_GITLAB_NAME:-}" ||
        -z "${REMOTE_GITLAB_BRANCH:-}" ||
        -z "${REMOTE_GITLAB_SSL_VERIFY:-}" ]]; then
        print_error "Configuration GitLab incomplète."
        return 1
    fi

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" \
        tag --points-at HEAD >/dev/null 2>&1; then
        print_error "Impossible de lire les tags Git du projet."
        return 1
    fi

    git_tags_count="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" \
            tag --points-at HEAD 2>/dev/null |
            sed '/^[[:space:]]*$/d' |
            wc -l
    )"

    if [[ "${git_tags_count}" -eq 0 ]]; then
        print_error "Aucun tag Git associé au dernier commit."
        return 1
    fi

    if [[ "${git_tags_count}" -gt 1 ]]; then
        print_error "Plusieurs tags Git sont associés au dernier commit."
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" \
            tag --points-at HEAD
        return 1
    fi

    git_tag="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" \
            tag --points-at HEAD 2>/dev/null |
            head -n 1
    )"

    if [[ -z "${git_tag}" ]]; then
        print_error "Impossible de déterminer le tag Git du dernier commit."
        return 1
    fi

    local debian_file_path
    debian_file_path="$(find "${project_path}/dist" -maxdepth 1 -type f -name '*.deb' -print -quit 2>/dev/null || true)"

    if [[ -z "${debian_file_path}" ]]; then
        print_error "Aucun paquet Debian trouvé dans dist/"
        return 1
    fi

    if [[ -n "$(
        find "${project_path}/dist" \
            -maxdepth 1 \
            -type f \
            -name '*.deb' \
            | tail -n +2 \
            | sed -n '1p'
    )" ]]; then
        print_error "Plusieurs paquets Debian sont présents dans dist/."
        return 1
    fi

    deb_file="${debian_file_path}"
    deb_filename="$(basename "${deb_file}")"

    case "${PROJECT_DEBIAN_PACKAGE:-No}" in
        Yes|YES|1)
            ;;
        *)
            print_error "Le projet '${project_id}' n'est pas déclaré comme paquet Debian."
            return 1
            ;;
    esac

    if ! command -v dpkg-deb >/dev/null 2>&1; then
        print_error "dpkg-deb n'est pas installé."
        return 1
    fi

    if ! command -v jq >/dev/null 2>&1; then
        print_error "jq n'est pas installé."
        return 1
    fi

    if ! _gitlab_ensure_credentials "${project_path}" "${REMOTE_GITLAB_NAME:-origin}"; then
        print_error "Impossible d'obtenir les identifiants GitLab."
        return 1
    fi
    _gitlab_read_username "${project_path}" || return 1
    _gitlab_read_token "${project_path}" || return 1

    if [[ -z "${gitlab_username}" || -z "${gitlab_token}" ]]; then
        print_error "Identifiants GitLab incomplets."
        return 1
    fi

    remote_api_base="${REMOTE_GITLAB_BASE_URL%/}/api/v4/projects"
    remote_project="${REMOTE_GITLAB_OWNER}/${REMOTE_GITLAB_REPOSITORY}"
    remote_project_encoded="$(printf '%s' "${remote_project}" | sed 's|%|%25|g; s|/|%2F|g')"

    local_api_url="${remote_api_base}/${remote_project_encoded}"

    _gitlab_release_api() {
        local method="${1:-GET}"
        local url="${2:-}"
        local payload="${3:-}"
        local form_file="${4:-}"
        local response=""
        local curl_rc=0

        if [[ -z "${url}" ]]; then
            print_error "_gitlab_release_api : URL vide."
            return 1
        fi

        if [[ -n "${payload}" ]]; then
            if response="$(
                curl \
                    --silent \
                    --show-error \
                    --write-out '\n%{http_code}' \
                    --header "PRIVATE-TOKEN: ${gitlab_token}" \
                    --header "Content-Type: application/json" \
                    -X "${method}" \
                    -d "${payload}" \
                    "${url}" \
                    2>/dev/null
            )"; then
                curl_rc=0
            else
                curl_rc=$?
            fi
        elif [[ -n "${form_file}" ]]; then
            if response="$(
                curl \
                    --silent \
                    --show-error \
                    --write-out '\n%{http_code}' \
                    --header "PRIVATE-TOKEN: ${gitlab_token}" \
                    -X "${method}" \
                    --form "file=@${form_file}" \
                    "${url}" \
                    2>/dev/null
            )"; then
                curl_rc=0
            else
                curl_rc=$?
            fi
        else
            if response="$(
                curl \
                    --silent \
                    --show-error \
                    --write-out '\n%{http_code}' \
                    --header "PRIVATE-TOKEN: ${gitlab_token}" \
                    -X "${method}" \
                    "${url}" \
                    2>/dev/null
            )"; then
                curl_rc=0
            else
                curl_rc=$?
            fi
        fi

        if [[ "${curl_rc}" -ne 0 ]]; then
            print_error "_gitlab_release_api : erreur réseau (curl=${curl_rc})."
            return 1
        fi

        printf '%s' "${response}"
        return 0
    }

    release_body="$(_gitlab_release_api GET "${local_api_url}/releases/${git_tag}")"
    release_http_code="$(printf '%s' "${release_body##*$'\n'}")"

    if [[ "${release_http_code}" == "200" ]]; then
        print_info "Release GitLab '${git_tag}' existante détectée."
    else
        release_payload="$(
            jq -n \
                --arg tag_name "${git_tag}" \
                --arg name "Release ${git_tag}" \
                --arg description "Release du projet ${project_name} (${git_tag})." \
                --arg ref "${git_tag}" \
                '{tag_name:$tag_name,name:$name,description:$description,ref:$ref}'
        )"

        release_body="$(_gitlab_release_api POST "${local_api_url}/releases" "${release_payload}")"
        release_http_code="$(printf '%s' "${release_body##*$'\n'}")"

        if [[ "${release_http_code}" -ne 201 && "${release_http_code}" -ne 200 ]]; then
            print_error "Échec de création/validation de la release GitLab."
            print_error "${release_body%$'\n'*}"
            return 1
        fi
    fi

    upload_response="$(_gitlab_release_api POST "${local_api_url}/uploads" "" "${deb_file}")"
    upload_http_code="$(printf '%s' "${upload_response##*$'\n'}")"

    if [[ "${upload_http_code}" -ne 201 ]]; then
        print_error "Échec de l'upload du paquet Debian."
        print_error "${upload_response%$'\n'*}"
        return 1
    fi

    upload_body="${upload_response%$'\n'*}"
    upload_url="$(jq -r '.url // empty' <<< "${upload_body}")"

    if [[ -z "${upload_url}" ]]; then
        print_error "Réponse d'upload GitLab invalide."
        return 1
    fi

    asset_url="${REMOTE_GITLAB_BASE_URL%/}${upload_url}"
    link_payload="$(
        jq -n \
            --arg name "${deb_filename}" \
            --arg url "${asset_url}" \
            --arg link_type "package" \
            '{name:$name,url:$url,link_type:$link_type}'
    )"

    _gitlab_release_api POST "${local_api_url}/releases/${git_tag}/assets/links" "${link_payload}" >/dev/null || {
        local_api_url="${local_api_url}"
        print_error "Échec de création du lien d'asset GitLab."
        return 1
    }

    print_success "Paquet Debian publié sur la Release GitLab ${git_tag}."
    return 0
}

# Publication de l'image Docker d'un projet vers Forgejo.
projects_forgejo_release_docker() {

    local project_id="${1:-}"

    local project_dir=""
    local project_env=""

    local git_tag=""
    local git_tags_count=0
    local docker_version=""

    local local_image=""
    local remote_registry=""
    local remote_image_version=""
    local remote_image_latest=""

    local forgejo_username=""
    local forgejo_token=""

    local forgejo_api_base=""
    local forgejo_repository_api=""
    local forgejo_repository_http_code=""

    local docker_config=""
    local docker_publish_rc=0

    # --------------------------------------------------------
    # Vérification des arguments
    # --------------------------------------------------------

    if [[ -z "${project_id}" ]]; then
        print_error \
            "Usage : projects_forgejo_release_docker <project_id>"
        return 1
    fi

    # --------------------------------------------------------
    # Définition des chemins
    # --------------------------------------------------------

    project_dir="${DEVOPS_PROJECTS_ROOT}/${project_id}"
    project_env="${project_dir}/project.env"

    # --------------------------------------------------------
    # Vérification du projet
    # --------------------------------------------------------

    if [[ ! -d "${project_dir}" ]]; then
        print_error \
            "Projet introuvable : ${project_dir}"
        return 1
    fi

    if [[ ! -f "${project_env}" ]]; then
        print_error \
            "Fichier project.env introuvable : ${project_env}"
        return 1
    fi

    # --------------------------------------------------------
    # Chargement de project.env
    # --------------------------------------------------------

    # shellcheck disable=SC1090
    source "${project_env}"

    # --------------------------------------------------------
    # Vérification projet Docker
    # --------------------------------------------------------

    case "${PROJECT_DOCKERED:-No}" in
        Yes|YES|1)
            ;;
        *)
            print_error \
                "Le projet '${project_id}' n'est pas déclaré comme Dockerisé."
            return 1
            ;;
    esac

    # --------------------------------------------------------
    # Vérification configuration distante
    # --------------------------------------------------------

    if [[ \
        -z "${REMOTE_FORGEJO_BASE_URL:-}" ||
        -z "${REMOTE_FORGEJO_OWNER:-}" ||
        -z "${REMOTE_FORGEJO_REPOSITORY:-}" \
    ]]; then

        print_error \
            "Configuration distante incomplète dans project.env."
        return 1
    fi

    # --------------------------------------------------------
    # Vérification de Git
    # --------------------------------------------------------

    if ! runuser -u "${DEVOPS_USER}" -- \
        git --version >/dev/null 2>&1; then

        print_error \
            "Git n'est pas accessible pour ${DEVOPS_USER}."
        return 1
    fi

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_dir}" \
        rev-parse --is-inside-work-tree >/dev/null 2>&1; then

        print_error \
            "Le projet n'est pas un dépôt Git valide : ${project_dir}"
        return 1
    fi

    # --------------------------------------------------------
    # Détermination du tag associé au dernier commit Git
    # --------------------------------------------------------

    git_tags_count="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_dir}" \
            tag --points-at HEAD 2>/dev/null |
            sed '/^[[:space:]]*$/d' |
            wc -l
    )"

    if [[ "${git_tags_count}" -eq 0 ]]; then
        print_error \
            "Aucun tag Git associé au dernier commit."
        return 1
    fi

    if [[ "${git_tags_count}" -gt 1 ]]; then
        print_error \
            "Plusieurs tags Git sont associés au dernier commit."

        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_dir}" \
            tag --points-at HEAD

        return 1
    fi

    git_tag="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_dir}" \
            tag --points-at HEAD 2>/dev/null |
            head -n 1
    )"

    if [[ -z "${git_tag}" ]]; then
        print_error \
            "Impossible de déterminer le tag Git du dernier commit."
        return 1
    fi

    # --------------------------------------------------------
    # Détermination de la version Docker
    # --------------------------------------------------------

    docker_version="${git_tag#v}"

    if [[ -z "${docker_version}" ]]; then
        print_error \
            "Version Docker invalide déduite du tag Git '${git_tag}'."
        return 1
    fi

    # --------------------------------------------------------
    # Détermination des images Docker
    # --------------------------------------------------------

    local_image="${PROJECT_ID:-${project_id}}:latest"

    remote_registry="${REMOTE_FORGEJO_BASE_URL#https://}"
    remote_registry="${remote_registry#http://}"
    remote_registry="${remote_registry%/}"

    remote_image_version="${remote_registry}/${REMOTE_FORGEJO_OWNER}/${REMOTE_FORGEJO_REPOSITORY}:${docker_version}"
    remote_image_latest="${remote_registry}/${REMOTE_FORGEJO_OWNER}/${REMOTE_FORGEJO_REPOSITORY}:latest"

    # --------------------------------------------------------
    # Vérification de l'image locale
    # --------------------------------------------------------

    if ! runuser -u "${DEVOPS_USER}" -- \
        docker image inspect "${local_image}" >/dev/null 2>&1; then

        print_error \
            "Image Docker locale introuvable : ${local_image}"
        return 1
    fi

    # --------------------------------------------------------
    # Lecture unique des credentials Forgejo
    # --------------------------------------------------------

    if ! _forgejo_read_username "${project_dir}"; then
        print_error \
            "Impossible de lire le nom d'utilisateur Forgejo."
        return 1
    fi

    if ! _forgejo_read_token "${project_dir}"; then
        print_error \
            "Impossible de lire le token Forgejo."
        return 1
    fi

    if [[ -z "${forgejo_username}" ]]; then
        print_error \
            "Nom d'utilisateur Forgejo vide."
        return 1
    fi

    if [[ -z "${forgejo_token}" ]]; then
        print_error \
            "Token Forgejo vide."
        return 1
    fi

    # --------------------------------------------------------
    # Vérification de curl
    # --------------------------------------------------------

    if ! command -v curl >/dev/null 2>&1; then
        print_error \
            "curl n'est pas installé."
        unset forgejo_token
        return 1
    fi

    # --------------------------------------------------------
    # Vérification du dépôt Forgejo cible
    #
    # IMPORTANT :
    #
    # Forgejo ne tente l'association automatique d'un package
    # Container à un dépôt que lors de la création initiale
    # du package.
    #
    # Le dépôt doit donc exister AVANT le premier docker push.
    # --------------------------------------------------------

    forgejo_api_base="${REMOTE_FORGEJO_BASE_URL%/}/api/v1"
    forgejo_repository_api="${forgejo_api_base}/repos/${REMOTE_FORGEJO_OWNER}/${REMOTE_FORGEJO_REPOSITORY}"

    print_title "Vérification du dépôt Forgejo"

    printf '%-22s : %s\n' \
        "Owner" "${REMOTE_FORGEJO_OWNER}"

    printf '%-22s : %s\n' \
        "Dépôt" "${REMOTE_FORGEJO_REPOSITORY}"

    forgejo_repository_http_code="$(
        curl \
            --silent \
            --show-error \
            --output /dev/null \
            --write-out '%{http_code}' \
            --header "Authorization: token ${forgejo_token}" \
            "${forgejo_repository_api}"
    )"

    case "${forgejo_repository_http_code}" in

        200)
            print_success \
                "Dépôt Forgejo ${REMOTE_FORGEJO_OWNER}/${REMOTE_FORGEJO_REPOSITORY} disponible."
            ;;

        404)
            print_error \
                "Le dépôt Forgejo ${REMOTE_FORGEJO_OWNER}/${REMOTE_FORGEJO_REPOSITORY} n'existe pas."

            print_error \
                "Publication Docker refusée afin d'éviter la création d'un package non lié."

            print_info \
                "Publiez d'abord le dépôt Git avec projects forgejo push."

            unset forgejo_token
            return 1
            ;;

        401|403)
            print_error \
                "Accès refusé au dépôt Forgejo ${REMOTE_FORGEJO_OWNER}/${REMOTE_FORGEJO_REPOSITORY}."

            print_error \
                "Code HTTP Forgejo : ${forgejo_repository_http_code}"

            unset forgejo_token
            return 1
            ;;

        *)
            print_error \
                "Impossible de vérifier le dépôt Forgejo."

            print_error \
                "Code HTTP Forgejo : ${forgejo_repository_http_code}"

            unset forgejo_token
            return 1
            ;;
    esac

    # --------------------------------------------------------
    # Affichage
    # --------------------------------------------------------

    print_title "Publication Release Docker"

    printf '%-22s : %s\n' \
        "Projet" "${PROJECT_NAME:-${project_id}}"

    printf '%-22s : %s\n' \
        "Tag Git" "${git_tag}"

    printf '%-22s : %s\n' \
        "Version Docker" "${docker_version}"

    printf '%-22s : %s\n' \
        "Image locale" "${local_image}"

    printf '%-22s : %s\n' \
        "Release" "${remote_image_version}"

    printf '%-22s : %s\n' \
        "Latest" "${remote_image_latest}"

    printf '%-22s : %s\n' \
        "Utilisateur Forgejo" "${forgejo_username}"

    printf '%-22s : %s\n' \
        "Owner cible" "${REMOTE_FORGEJO_OWNER}"

    printf '%-22s : %s\n' \
        "Dépôt associé" "${REMOTE_FORGEJO_OWNER}/${REMOTE_FORGEJO_REPOSITORY}"

    # --------------------------------------------------------
    # Création du tag Docker versionné
    # --------------------------------------------------------

    print_info \
        "Création du tag Docker versionné."

    if ! runuser -u "${DEVOPS_USER}" -- \
        docker tag \
            "${local_image}" \
            "${remote_image_version}"; then

        print_error \
            "Échec du tag Docker versionné."

        unset forgejo_token
        return 1
    fi

    # --------------------------------------------------------
    # Création du tag Docker latest
    # --------------------------------------------------------

    print_info \
        "Création du tag Docker latest."

    if ! runuser -u "${DEVOPS_USER}" -- \
        docker tag \
            "${local_image}" \
            "${remote_image_latest}"; then

        print_error \
            "Échec du tag Docker latest."

        unset forgejo_token
        return 1
    fi

    # --------------------------------------------------------
    # Création du DOCKER_CONFIG temporaire
    # --------------------------------------------------------

    docker_config="$(mktemp -d)" || {
        print_error \
            "Impossible de créer le DOCKER_CONFIG temporaire."

        unset forgejo_token
        return 1
    }

    if [[ -z "${docker_config}" ]] ||
       [[ ! -d "${docker_config}" ]]; then

        print_error \
            "DOCKER_CONFIG temporaire invalide."

        unset forgejo_token
        return 1
    fi

    if ! chmod 700 "${docker_config}"; then
        print_error \
            "Impossible de sécuriser ${docker_config}"

        rm -rf "${docker_config}"
        unset forgejo_token
        return 1
    fi

    if ! chown \
        "${DEVOPS_USER}:${DEVOPS_GROUP}" \
        "${docker_config}"; then

        print_error \
            "Impossible d'attribuer ${docker_config} à ${DEVOPS_USER}."

        rm -rf "${docker_config}"
        unset forgejo_token
        return 1
    fi

    # --------------------------------------------------------
    # Authentification et publication
    #
    # Sous-shell :
    # - trap local
    # - DOCKER_CONFIG temporaire
    # - nettoyage garanti sur succès ou erreur
    # --------------------------------------------------------

    docker_publish_rc=0

    (
        trap 'rm -rf "${docker_config}"' EXIT

        # ----------------------------------------------------
        # Authentification Docker Forgejo
        # ----------------------------------------------------

        print_title "Authentification Docker Forgejo"

        if ! printf '%s' "${forgejo_token}" | \
            runuser -u "${DEVOPS_USER}" -- \
                env "DOCKER_CONFIG=${docker_config}" \
                docker login \
                    "${remote_registry}" \
                    --username "${forgejo_username}" \
                    --password-stdin; then

            print_error \
                "Échec de l'authentification Docker auprès de ${remote_registry}."

            exit 1
        fi

        print_success \
            "Authentification Docker Forgejo réussie."

        # ----------------------------------------------------
        # Publication de la version
        # ----------------------------------------------------

        print_title \
            "Publication Docker ${docker_version}"

        if ! runuser -u "${DEVOPS_USER}" -- \
            env "DOCKER_CONFIG=${docker_config}" \
            docker push "${remote_image_version}"; then

            print_error \
                "Échec de la publication de ${remote_image_version}."

            exit 1
        fi

        print_success \
            "Image Docker versionnée publiée."

        # ----------------------------------------------------
        # Publication latest
        # ----------------------------------------------------

        print_title \
            "Publication Docker latest"

        if ! runuser -u "${DEVOPS_USER}" -- \
            env "DOCKER_CONFIG=${docker_config}" \
            docker push "${remote_image_latest}"; then

            print_error \
                "Échec de la publication de ${remote_image_latest}."

            exit 1
        fi

        print_success \
            "Image Docker latest publiée."

        exit 0

    ) || docker_publish_rc=$?

    # --------------------------------------------------------
    # Nettoyage de la variable contenant le token
    # --------------------------------------------------------

    unset forgejo_token

    # --------------------------------------------------------
    # Vérification du résultat de publication
    # --------------------------------------------------------

    if [[ "${docker_publish_rc}" -ne 0 ]]; then
        print_error \
            "Échec de la publication de la Release Docker."
        return "${docker_publish_rc}"
    fi

    # --------------------------------------------------------
    # Résultat
    # --------------------------------------------------------

    print_success \
        "Release Docker publiée avec succès."

    printf '\n'

    printf '%-22s : %s\n' \
        "Version" "${remote_image_version}"

    printf '%-22s : %s\n' \
        "Latest" "${remote_image_latest}"

    printf '%-22s : %s\n' \
        "Dépôt Forgejo" "${REMOTE_FORGEJO_OWNER}/${REMOTE_FORGEJO_REPOSITORY}"

    return 0
}

# Donne le status du dépot local Git pour le projet <PROJECT_ID>
git_status() {
    local project_id="$1"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"
    local project_env="${project_path}/project.env"

    local project_name=""

    local current_branch=""
    local upstream_branch=""
    local status_output=""
    local tracked_count="0"
    local modified_count="0"
    local staged_count="0"
    local untracked_count="0"

    # Vérification des paramètres
    if [[ -z "${project_id}" ]]; then
        print_error "Usage : git_status <project_id>"
        return 1
    fi

    # Vérification de l'utilisateur DevOps
    if ! check_devops_user; then
        print_error "L'utilisateur DevOps n'est pas disponible."
        return 1
    fi

    # Vérification du projet
    if [[ ! -d "${project_path}" ]]; then
        print_error "Projet introuvable : ${project_path}"
        return 1
    fi

    # Vérification de Git
    if ! command -v git >/dev/null 2>&1; then
        print_error "Git n'est pas installé."
        return 1
    fi

    if ! runuser -u "${DEVOPS_USER}" -- \
        git --version >/dev/null 2>&1; then

        print_error \
            "Git n'est pas accessible pour ${DEVOPS_USER}."
        return 1
    fi

    # Chargement de project.env
    if [[ ! -f "${project_env}" ]]; then
        print_info \
            "Le fichier project.env est absent pour le projet ${project_id}."

        if ! update_projects "${project_id}" ||
            ! git_update "${project_id}"; then
            print_error \
                "Impossible d'initialiser la configuration Git du projet."
            return 1
        fi
    fi

    if [[ ! -f "${project_env}" ]]; then
        print_error \
            "Le fichier project.env est toujours absent : ${project_env}"
        return 1
    fi

    # Nettoyage des variables susceptibles d'être déjà présentes
    unset \
        PROJECT_ID \
        PROJECT_NAME \
        PROJECT_TYPE \
        PROJECT_DOCKERED \
        LOCAL_DEFAULT_BRANCH \
        GIT_USER_NAME \
        GIT_USER_EMAIL

    # shellcheck disable=SC1090
    source "${project_env}"

    # Vérification des variables essentielles
    if [[ \
        -z "${PROJECT_ID:-}" ||
        -z "${PROJECT_NAME:-}" \
    ]]; then

        print_info \
            "La configuration du projet est incomplète."

        if ! update_projects "${project_id}" ||
            ! git_update "${project_id}"; then
            print_error \
                "Impossible de mettre à jour la configuration Git du projet."
            return 1
        fi

        # Recharge project.env après git_update
        unset \
            PROJECT_ID \
            PROJECT_NAME \
            PROJECT_TYPE \
            PROJECT_DOCKERED \
            LOCAL_DEFAULT_BRANCH \
            GIT_USER_NAME \
            GIT_USER_EMAIL

        # shellcheck disable=SC1090
        source "${project_env}"
    fi

    # Vérification finale des variables essentielles
    if [[ -z "${PROJECT_ID:-}" ]]; then
        print_error "PROJECT_ID n'est pas défini dans project.env."
        return 1
    fi

    if [[ "${PROJECT_ID}" != "${project_id}" ]]; then
        print_error \
            "PROJECT_ID '${PROJECT_ID}' ne correspond pas au projet '${project_id}'."
        return 1
    fi

    if [[ -z "${PROJECT_NAME:-}" ]]; then
        print_error "PROJECT_NAME n'est pas défini dans project.env."
        return 1
    fi

    # Affectation locale de la configuration du projet
    project_name="${PROJECT_NAME}"

    print_title "État du dépôt Git"

    # Vérification du dépôt Git
    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" rev-parse \
        --is-inside-work-tree >/dev/null 2>&1; then

        print_error \
            "Aucun dépôt Git valide dans : ${project_path}"
        return 1
    fi

    # Récupération de la branche locale courante
    current_branch="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" \
            branch --show-current 2>/dev/null
    )"

    if [[ -z "${current_branch}" ]]; then
        current_branch="HEAD détachée"
    fi

    # Récupération de la branche distante de suivi
    upstream_branch=""

    if upstream_branch="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" \
            rev-parse \
            --abbrev-ref \
            --symbolic-full-name \
            '@{upstream}' 2>/dev/null
    )"; then
        :
    fi

    # Récupération de l'état des fichiers
    if ! status_output="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" \
            status \
            --short \
            --untracked-files=all
    )"; then

        print_error \
            "Impossible de récupérer l'état du dépôt Git."
        return 1
    fi

    # Nombre de fichiers suivis
    tracked_count="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" \
            ls-files |
            wc -l |
            tr -d ' '
    )"

    # Nombre de fichiers modifiés
    modified_count="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" \
            diff \
            --name-only |
            wc -l |
            tr -d ' '
    )"

    # Nombre de fichiers indexés
    staged_count="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" \
            diff \
            --cached \
            --name-only |
            wc -l |
            tr -d ' '
    )"

    # Nombre de fichiers non suivis
    untracked_count="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" \
            ls-files \
            --others \
            --exclude-standard |
            wc -l |
            tr -d ' '
    )"

    # Résumé du dépôt
    printf '%-22s : %s\n' "Projet" "${project_name}"
    printf '%-22s : %s\n' "ID projet" "${project_id}"
    printf '%-22s : %s\n' "Répertoire" "${project_path}"
    printf '%-22s : %s\n' "Utilisateur Git" "${DEVOPS_USER}"
    printf '%-22s : %s\n' "Branche courante" "${current_branch}"

    if [[ -n "${upstream_branch}" ]]; then
        printf '%-22s : %s\n' \
            "Branche distante" "${upstream_branch}"
    else
        printf '%-22s : %s\n' \
            "Branche distante" "aucune"
    fi

    printf '\n'

    printf '%-22s : %s\n' \
        "Fichiers suivis" "${tracked_count}"
    printf '%-22s : %s\n' \
        "Fichiers modifiés" "${modified_count}"
    printf '%-22s : %s\n' \
        "Fichiers indexés" "${staged_count}"
    printf '%-22s : %s\n' \
        "Fichiers non suivis" "${untracked_count}"

    # État des fichiers
    print_title "Modifications locales"

    if [[ -n "${status_output}" ]]; then
        printf '%s\n' "${status_output}"
    else
        print_success "Le dépôt est propre."
    fi

    # Dernier commit
    print_title "Dernier commit"

    if runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" rev-parse \
        --verify HEAD >/dev/null 2>&1; then

        if ! runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" log \
            -1 \
            --date=iso-local \
            --format='Commit  : %h%nDate    : %ad%nAuteur  : %an <%ae>%nMessage : %s'; then

            print_error \
                "Impossible d'afficher le dernier commit."
            return 1
        fi

        printf '\n'

        # Historique récent
        print_title "Historique récent"

        if ! runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" log \
            --oneline \
            --decorate \
            --max-count=5; then

            print_error \
                "Impossible d'afficher l'historique Git."
            return 1
        fi

    else
        print_info \
            "Le dépôt ne contient encore aucun commit."
    fi

    printf '\n'

    print_success \
        "État Git affiché pour ${project_name}."

    return 0
}

# Compatibilité interne pour les modes historiques de configuration.
git_update_legacy() {
    local project_id="${1:-}"
    local update_mode="${2:-local}"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"
    local project_env="${project_path}/project.env"

    local project_name=""
    local project_type="BASH"
    local project_dockered="No"
    local project_debian_package="No"

    local local_default_branch="main"
    local git_user_name=""
    local git_user_email=""

    local legacy_remote_base_url=""
    local legacy_remote_owner=""
    local legacy_remote_repository=""
    local legacy_remote_name=""
    local legacy_remote_default_branch=""
    local remote_gitlab_base_url=""
    local remote_gitlab_owner=""
    local remote_gitlab_repository=""
    local remote_gitlab_name="origin"
    local remote_gitlab_branch="main"
    local gitlab_mode="No"
    local gitlab_config_present="No"
    local remote_forgejo_base_url=""
    local remote_forgejo_owner=""
    local remote_forgejo_repository=""
    local remote_forgejo_name="origin"
    local remote_forgejo_branch="main"
    local remote_forgejo_ssl_verify="No"
    local forgejo_config_present="No"
    local remote_github_base_url=""
    local remote_github_owner=""
    local remote_github_repository=""
    local remote_github_name="origin"
    local remote_github_branch="main"
    local github_config_present="No"

    local remote_clone_git_type="github"
    local remote_clone_base_url="https://github.com"
    local remote_clone_owner=""
    local remote_clone_repository=""
    local remote_clone_name="upstream"
    local remote_clone_default_branch="main"
    local clone_config_present="No"

    local value=""
    local project_env_tmp=""

    # Vérification des paramètres
    if [[ -z "${project_id}" ]]; then
        print_error "Usage : git_update <project_id> [local|clone|gitlab]"
        return 1
    fi

    if [[ "${update_mode}" == "gitlab" ]]; then
        gitlab_mode="Yes"
    fi

    case "${update_mode}" in
        local|clone|gitlab)
            ;;
        *)
            print_error \
                "Mode git_update invalide : ${update_mode} (attendu : local, clone ou gitlab)."
            return 1
            ;;
    esac

    # Vérification du projet
    if [[ ! -d "${project_path}" ]]; then
        print_error \
            "Le répertoire du projet n'existe pas : ${project_path}"
        return 1
    fi

    # Chargement des valeurs existantes
    if [[ -f "${project_env}" ]]; then

        print_info \
            "Configuration existante détectée : ${project_env}"

        unset \
            PROJECT_ID \
            PROJECT_NAME \
            PROJECT_TYPE \
            PROJECT_DOCKERED \
            PROJECT_DEBIAN_PACKAGE \
            LOCAL_DEFAULT_BRANCH \
            GIT_USER_NAME \
            GIT_USER_EMAIL \
            REMOTE_GIT_TYPE \
            REMOTE_BASE_URL \
            REMOTE_OWNER \
            REMOTE_REPOSITORY \
            REMOTE_NAME \
            REMOTE_DEFAULT_BRANCH \
            REMOTE_GITLAB_BASE_URL \
            REMOTE_GITLAB_OWNER \
            REMOTE_GITLAB_REPOSITORY \
            REMOTE_GITLAB_NAME \
            REMOTE_GITLAB_BRANCH \
            REMOTE_FORGEJO_BASE_URL \
            REMOTE_FORGEJO_OWNER \
            REMOTE_FORGEJO_REPOSITORY \
            REMOTE_FORGEJO_NAME \
            REMOTE_FORGEJO_BRANCH \
            REMOTE_FORGEJO_SSL_VERIFY \
            REMOTE_GITHUB_BASE_URL \
            REMOTE_GITHUB_OWNER \
            REMOTE_GITHUB_REPOSITORY \
            REMOTE_GITHUB_NAME \
            REMOTE_GITHUB_BRANCH \
            REMOTE_CLONE_GIT_TYPE \
            REMOTE_CLONE_BASE_URL \
            REMOTE_CLONE_OWNER \
            REMOTE_CLONE_REPOSITORY \
            REMOTE_CLONE_NAME \
            REMOTE_CLONE_DEFAULT_BRANCH

        # shellcheck disable=SC1090
        source "${project_env}"

        project_name="${PROJECT_NAME:-}"
        project_type="${PROJECT_TYPE:-BASH}"
        project_dockered="${PROJECT_DOCKERED:-No}"
        project_debian_package="${PROJECT_DEBIAN_PACKAGE:-No}"

        local_default_branch="${LOCAL_DEFAULT_BRANCH:-main}"
        git_user_name="${GIT_USER_NAME:-}"
        git_user_email="${GIT_USER_EMAIL:-}"

        legacy_remote_base_url="${REMOTE_BASE_URL:-}"
        legacy_remote_owner="${REMOTE_OWNER:-}"
        legacy_remote_repository="${REMOTE_REPOSITORY:-}"
        legacy_remote_name="${REMOTE_NAME:-}"
        legacy_remote_default_branch="${REMOTE_DEFAULT_BRANCH:-}"
        remote_gitlab_base_url="${REMOTE_GITLAB_BASE_URL:-}"
        remote_gitlab_owner="${REMOTE_GITLAB_OWNER:-}"
        remote_gitlab_repository="${REMOTE_GITLAB_REPOSITORY:-${project_id}}"
        remote_gitlab_name="${REMOTE_GITLAB_NAME:-origin}"
        remote_gitlab_branch="${REMOTE_GITLAB_BRANCH:-main}"
        remote_forgejo_base_url="${REMOTE_FORGEJO_BASE_URL:-${legacy_remote_base_url}}"
        remote_forgejo_owner="${REMOTE_FORGEJO_OWNER:-${legacy_remote_owner}}"
        remote_forgejo_repository="${REMOTE_FORGEJO_REPOSITORY:-${legacy_remote_repository:-${project_id}}}"
        remote_forgejo_name="${REMOTE_FORGEJO_NAME:-${legacy_remote_name:-origin}}"
        remote_forgejo_branch="${REMOTE_FORGEJO_BRANCH:-${legacy_remote_default_branch:-main}}"
        remote_forgejo_ssl_verify="${REMOTE_FORGEJO_SSL_VERIFY:-No}"
        remote_github_base_url="${REMOTE_GITHUB_BASE_URL:-}"
        remote_github_owner="${REMOTE_GITHUB_OWNER:-}"
        remote_github_repository="${REMOTE_GITHUB_REPOSITORY:-${project_id}}"
        remote_github_name="${REMOTE_GITHUB_NAME:-origin}"
        remote_github_branch="${REMOTE_GITHUB_BRANCH:-main}"

        if [[ \
            -n "${REMOTE_GITLAB_BASE_URL+x}" ||
            -n "${REMOTE_GITLAB_OWNER+x}" ||
            -n "${REMOTE_GITLAB_REPOSITORY+x}" ||
            -n "${REMOTE_GITLAB_NAME+x}" ||
            -n "${REMOTE_GITLAB_BRANCH+x}" \
        ]]; then
            gitlab_config_present="Yes"
        fi

        if [[ \
            -n "${REMOTE_GIT_TYPE+x}" ||
            -n "${REMOTE_BASE_URL+x}" ||
            -n "${REMOTE_OWNER+x}" ||
            -n "${REMOTE_REPOSITORY+x}" ||
            -n "${REMOTE_NAME+x}" ||
            -n "${REMOTE_DEFAULT_BRANCH+x}" ||
            -n "${REMOTE_FORGEJO_BASE_URL+x}" ||
            -n "${REMOTE_FORGEJO_OWNER+x}" ||
            -n "${REMOTE_FORGEJO_REPOSITORY+x}" ||
            -n "${REMOTE_FORGEJO_NAME+x}" ||
            -n "${REMOTE_FORGEJO_BRANCH+x}" ||
            -n "${REMOTE_FORGEJO_SSL_VERIFY+x}" \
        ]]; then
            forgejo_config_present="Yes"
        fi

        if [[ \
            -n "${REMOTE_GITHUB_BASE_URL+x}" ||
            -n "${REMOTE_GITHUB_OWNER+x}" ||
            -n "${REMOTE_GITHUB_REPOSITORY+x}" ||
            -n "${REMOTE_GITHUB_NAME+x}" ||
            -n "${REMOTE_GITHUB_BRANCH+x}" \
        ]]; then
            github_config_present="Yes"
        fi

        if [[ \
            -n "${REMOTE_CLONE_GIT_TYPE+x}" ||
            -n "${REMOTE_CLONE_BASE_URL+x}" ||
            -n "${REMOTE_CLONE_OWNER+x}" ||
            -n "${REMOTE_CLONE_REPOSITORY+x}" ||
            -n "${REMOTE_CLONE_NAME+x}" ||
            -n "${REMOTE_CLONE_DEFAULT_BRANCH+x}" \
        ]]; then
            clone_config_present="Yes"
        fi

        remote_clone_git_type="${REMOTE_CLONE_GIT_TYPE:-github}"
        remote_clone_base_url="${REMOTE_CLONE_BASE_URL:-https://github.com}"
        remote_clone_owner="${REMOTE_CLONE_OWNER:-}"
        remote_clone_repository="${REMOTE_CLONE_REPOSITORY:-}"
        remote_clone_name="${REMOTE_CLONE_NAME:-upstream}"
        remote_clone_default_branch="${REMOTE_CLONE_DEFAULT_BRANCH:-main}"
    fi

    if [[ "${update_mode}" == "clone" ]]; then
        clone_config_present="Yes"
    fi

    print_title "Configuration du projet ${project_id}"

    printf '%-24s : %s\n' "PROJECT_ID" "${project_id}"

    # PROJECT_NAME
    value=""
    read -r -p \
        "PROJECT_NAME [${project_name}] : " value

    if [[ -n "${value}" ]]; then
        project_name="${value}"
    fi

    while [[ -z "${project_name}" ]]; do
        print_error "PROJECT_NAME ne peut pas être vide."

        read -r -p \
            "PROJECT_NAME : " project_name
    done

    # PROJECT_TYPE
    value=""
    read -r -p \
        "PROJECT_TYPE [${project_type}] : " value

    if [[ -n "${value}" ]]; then
        project_type="${value}"
    fi

    # PROJECT_DOCKERED
    value=""
    read -r -p \
        "PROJECT_DOCKERED [${project_dockered}] : " value

    if [[ -n "${value}" ]]; then
        project_dockered="${value}"
    fi

    # LOCAL_DEFAULT_BRANCH
    value=""
    read -r -p \
        "LOCAL_DEFAULT_BRANCH [${local_default_branch}] : " value

    if [[ -n "${value}" ]]; then
        local_default_branch="${value}"
    fi

    # GIT_USER_NAME
    value=""
    read -r -p \
        "GIT_USER_NAME [${git_user_name}] : " value

    if [[ -n "${value}" ]]; then
        git_user_name="${value}"
    fi

    while [[ -z "${git_user_name}" ]]; do
        print_error "GIT_USER_NAME ne peut pas être vide."

        read -r -p \
            "GIT_USER_NAME : " git_user_name
    done

    # GIT_USER_EMAIL
    value=""
    read -r -p \
        "GIT_USER_EMAIL [${git_user_email}] : " value

    if [[ -n "${value}" ]]; then
        git_user_email="${value}"
    fi

    while [[ -z "${git_user_email}" ]]; do
        print_error "GIT_USER_EMAIL ne peut pas être vide."

        read -r -p \
            "GIT_USER_EMAIL : " git_user_email
    done

    if [[ "${gitlab_mode}" == "Yes" || "${gitlab_config_present}" == "Yes" ]]; then
        print_title "Configuration du dépôt distant GitLab"

        value=""
        read -r -p \
            "REMOTE_GITLAB_BASE_URL [${remote_gitlab_base_url}] : " value
        if [[ -n "${value}" ]]; then
            remote_gitlab_base_url="${value}"
        fi
        remote_gitlab_base_url="${remote_gitlab_base_url%/}"
        while [[ -z "${remote_gitlab_base_url}" ]]; do
            print_error "REMOTE_GITLAB_BASE_URL ne peut pas être vide."
            read -r -p \
                "REMOTE_GITLAB_BASE_URL : " remote_gitlab_base_url
            remote_gitlab_base_url="${remote_gitlab_base_url%/}"
        done

        value=""
        read -r -p \
            "REMOTE_GITLAB_OWNER [${remote_gitlab_owner}] : " value
        if [[ -n "${value}" ]]; then
            remote_gitlab_owner="${value}"
        fi
        while [[ -z "${remote_gitlab_owner}" ]]; do
            print_error "REMOTE_GITLAB_OWNER ne peut pas être vide."
            read -r -p \
                "REMOTE_GITLAB_OWNER : " remote_gitlab_owner
        done

        value=""
        read -r -p \
            "REMOTE_GITLAB_REPOSITORY [${remote_gitlab_repository:-${project_id}}] : " value
        if [[ -n "${value}" ]]; then
            remote_gitlab_repository="${value}"
        fi
        remote_gitlab_repository="${remote_gitlab_repository:-${project_id}}"
        while [[ -z "${remote_gitlab_repository}" ]]; do
            print_error "REMOTE_GITLAB_REPOSITORY ne peut pas être vide."
            read -r -p \
                "REMOTE_GITLAB_REPOSITORY [${project_id}] : " remote_gitlab_repository
            remote_gitlab_repository="${remote_gitlab_repository:-${project_id}}"
        done

        value=""
        read -r -p \
            "REMOTE_GITLAB_NAME [${remote_gitlab_name}] : " value
        if [[ -n "${value}" ]]; then
            remote_gitlab_name="${value}"
        fi
        remote_gitlab_name="${remote_gitlab_name:-origin}"

        value=""
        read -r -p \
            "REMOTE_GITLAB_BRANCH [${remote_gitlab_branch}] : " value
        if [[ -n "${value}" ]]; then
            remote_gitlab_branch="${value}"
        fi
        remote_gitlab_branch="${remote_gitlab_branch:-main}"
    fi

    if [[ "${gitlab_mode}" != "Yes" ]]; then
        print_title "Configuration du dépôt distant Forgejo"

        # REMOTE_FORGEJO_BASE_URL
        value=""
        read -r -p \
            "REMOTE_FORGEJO_BASE_URL [${remote_forgejo_base_url}] : " value

        if [[ -n "${value}" ]]; then
            remote_forgejo_base_url="${value}"
        fi

        remote_forgejo_base_url="${remote_forgejo_base_url%/}"

        value=""
        read -r -p \
            "REMOTE_FORGEJO_OWNER [${remote_forgejo_owner}] : " value

        if [[ -n "${value}" ]]; then
            remote_forgejo_owner="${value}"
        fi

        value=""
        read -r -p \
            "REMOTE_FORGEJO_REPOSITORY [${remote_forgejo_repository}] : " value

        if [[ -n "${value}" ]]; then
            remote_forgejo_repository="${value}"
        fi

        value=""
        read -r -p \
            "REMOTE_FORGEJO_NAME [${remote_forgejo_name}] : " value

        if [[ -n "${value}" ]]; then
            remote_forgejo_name="${value}"
        fi

        value=""
        read -r -p \
            "REMOTE_FORGEJO_BRANCH [${remote_forgejo_branch}] : " value

        if [[ -n "${value}" ]]; then
            remote_forgejo_branch="${value}"
        fi
    fi

    # Configuration du dépôt source uniquement en mode clone
    if [[ "${update_mode}" == "clone" ]]; then
        printf '\n'

        print_title "Configuration du dépôt distant source"

        # REMOTE_CLONE_GIT_TYPE
        value=""
        read -r -p \
            "REMOTE_CLONE_GIT_TYPE [${remote_clone_git_type}] : " value

        if [[ -n "${value}" ]]; then
            remote_clone_git_type="${value}"
        fi

        # REMOTE_CLONE_BASE_URL
        value=""
        read -r -p \
            "REMOTE_CLONE_BASE_URL [${remote_clone_base_url}] : " value

        if [[ -n "${value}" ]]; then
            remote_clone_base_url="${value}"
        fi

        remote_clone_base_url="${remote_clone_base_url%/}"

        while [[ -z "${remote_clone_base_url}" ]]; do
            print_error "REMOTE_CLONE_BASE_URL ne peut pas être vide."

            read -r -p \
                "REMOTE_CLONE_BASE_URL : " remote_clone_base_url

            remote_clone_base_url="${remote_clone_base_url%/}"
        done

        # REMOTE_CLONE_OWNER
        value=""
        read -r -p \
            "REMOTE_CLONE_OWNER [${remote_clone_owner}] : " value

        if [[ -n "${value}" ]]; then
            remote_clone_owner="${value}"
        fi

        while [[ -z "${remote_clone_owner}" ]]; do
            print_error "REMOTE_CLONE_OWNER ne peut pas être vide."

            read -r -p \
                "REMOTE_CLONE_OWNER : " remote_clone_owner
        done

        # REMOTE_CLONE_REPOSITORY
        value=""
        read -r -p \
            "REMOTE_CLONE_REPOSITORY [${remote_clone_repository}] : " value

        if [[ -n "${value}" ]]; then
            remote_clone_repository="${value}"
        fi

        while [[ -z "${remote_clone_repository}" ]]; do
            print_error "REMOTE_CLONE_REPOSITORY ne peut pas être vide."

            read -r -p \
                "REMOTE_CLONE_REPOSITORY : " remote_clone_repository
        done

        # REMOTE_CLONE_NAME
        value=""
        read -r -p \
            "REMOTE_CLONE_NAME [${remote_clone_name}] : " value

        if [[ -n "${value}" ]]; then
            remote_clone_name="${value}"
        fi

        while [[ -z "${remote_clone_name}" ]]; do
            print_error "REMOTE_CLONE_NAME ne peut pas être vide."

            read -r -p \
                "REMOTE_CLONE_NAME : " remote_clone_name
        done

        # REMOTE_CLONE_DEFAULT_BRANCH
        value=""
        read -r -p \
            "REMOTE_CLONE_DEFAULT_BRANCH [${remote_clone_default_branch}] : " value

        if [[ -n "${value}" ]]; then
            remote_clone_default_branch="${value}"
        fi

        while [[ -z "${remote_clone_default_branch}" ]]; do
            print_error \
                "REMOTE_CLONE_DEFAULT_BRANCH ne peut pas être vide."

            read -r -p \
                "REMOTE_CLONE_DEFAULT_BRANCH : " \
                remote_clone_default_branch
        done

        if [[ \
            -n "${remote_forgejo_name}" &&
            "${remote_forgejo_name}" == "${remote_clone_name}" \
        ]]; then
            print_error \
                "REMOTE_FORGEJO_NAME et REMOTE_CLONE_NAME doivent être différents."
            return 1
        fi
    fi

    # Résumé
    print_title "Configuration du projet"

    printf '%-30s : %s\n' "PROJECT_ID" "${project_id}"
    printf '%-30s : %s\n' "PROJECT_NAME" "${project_name}"
    printf '%-30s : %s\n' "PROJECT_TYPE" "${project_type}"
    printf '%-30s : %s\n' "PROJECT_DOCKERED" "${project_dockered}"
    printf '%-30s : %s\n' \
        "PROJECT_DEBIAN_PACKAGE" "${project_debian_package}"

    printf '\n'

    printf '%-30s : %s\n' \
        "LOCAL_DEFAULT_BRANCH" "${local_default_branch}"
    printf '%-30s : %s\n' \
        "GIT_USER_NAME" "${git_user_name}"
    printf '%-30s : %s\n' \
        "GIT_USER_EMAIL" "${git_user_email}"

    printf '\n'

    if [[ "${gitlab_mode}" == "Yes" ]]; then
        printf '%-30s : %s\n' \
            "REMOTE_GITLAB_BASE_URL" "${remote_gitlab_base_url}"
        printf '%-30s : %s\n' \
            "REMOTE_GITLAB_OWNER" "${remote_gitlab_owner}"
        printf '%-30s : %s\n' \
            "REMOTE_GITLAB_REPOSITORY" "${remote_gitlab_repository}"
        printf '%-30s : %s\n' \
            "REMOTE_GITLAB_NAME" "${remote_gitlab_name}"
        printf '%-30s : %s\n' \
            "REMOTE_GITLAB_BRANCH" "${remote_gitlab_branch}"
    fi

    if [[ "${gitlab_mode}" != "Yes" || "${forgejo_config_present}" == "Yes" ]]; then
        printf '\n'
        print_title "Configuration du dépôt distant Forgejo"
        printf '%-30s : %s\n' \
            "REMOTE_FORGEJO_BASE_URL" "${remote_forgejo_base_url}"
        printf '%-30s : %s\n' \
            "REMOTE_FORGEJO_OWNER" "${remote_forgejo_owner}"
        printf '%-30s : %s\n' \
            "REMOTE_FORGEJO_REPOSITORY" "${remote_forgejo_repository}"
        printf '%-30s : %s\n' \
            "REMOTE_FORGEJO_NAME" "${remote_forgejo_name}"
        printf '%-30s : %s\n' \
            "REMOTE_FORGEJO_BRANCH" "${remote_forgejo_branch}"
        printf '%-30s : %s\n' \
            "REMOTE_FORGEJO_SSL_VERIFY" "${remote_forgejo_ssl_verify}"
    fi

    if [[ "${clone_config_present}" == "Yes" ]]; then
        printf '\n'

        printf '%-30s : %s\n' \
            "REMOTE_CLONE_GIT_TYPE" "${remote_clone_git_type}"
        printf '%-30s : %s\n' \
            "REMOTE_CLONE_BASE_URL" "${remote_clone_base_url}"
        printf '%-30s : %s\n' \
            "REMOTE_CLONE_OWNER" "${remote_clone_owner}"
        printf '%-30s : %s\n' \
            "REMOTE_CLONE_REPOSITORY" "${remote_clone_repository}"
        printf '%-30s : %s\n' \
            "REMOTE_CLONE_NAME" "${remote_clone_name}"
        printf '%-30s : %s\n' \
            "REMOTE_CLONE_DEFAULT_BRANCH" \
            "${remote_clone_default_branch}"
    fi

    # Création du fichier temporaire
    project_env_tmp="${project_env}.tmp"

    if ! {
        printf '# Projet\n'
        printf 'PROJECT_ID=%q\n' "${project_id}"
        printf 'PROJECT_NAME=%q\n' "${project_name}"
        printf 'PROJECT_TYPE=%q\n' "${project_type}"
        printf 'PROJECT_DOCKERED=%q\n' "${project_dockered}"
        printf 'PROJECT_DEBIAN_PACKAGE=%q\n' \
            "${project_debian_package}"

        printf '\n'
        printf '# Git local\n'
        printf 'LOCAL_DEFAULT_BRANCH=%q\n' \
            "${local_default_branch}"
        printf 'GIT_USER_NAME=%q\n' \
            "${git_user_name}"
        printf 'GIT_USER_EMAIL=%q\n' \
            "${git_user_email}"

        if [[ "${gitlab_mode}" == "Yes" || "${gitlab_config_present}" == "Yes" ]]; then
            printf '\n'
            printf '# GitLab distant\n'
            printf 'REMOTE_GITLAB_BASE_URL=%q\n' \
                "${remote_gitlab_base_url}"
            printf 'REMOTE_GITLAB_OWNER=%q\n' \
                "${remote_gitlab_owner}"
            printf 'REMOTE_GITLAB_REPOSITORY=%q\n' \
                "${remote_gitlab_repository}"
            printf 'REMOTE_GITLAB_NAME=%q\n' \
                "${remote_gitlab_name}"
            printf 'REMOTE_GITLAB_BRANCH=%q\n' \
                "${remote_gitlab_branch}"
        fi

        if [[ "${gitlab_mode}" != "Yes" || "${forgejo_config_present}" == "Yes" ]]; then
            printf '\n'
            printf '# Forgejo distant\n'
            printf 'REMOTE_FORGEJO_BASE_URL=%q\n' \
                "${remote_forgejo_base_url}"
            printf 'REMOTE_FORGEJO_OWNER=%q\n' \
                "${remote_forgejo_owner}"
            printf 'REMOTE_FORGEJO_REPOSITORY=%q\n' \
                "${remote_forgejo_repository}"
            printf 'REMOTE_FORGEJO_NAME=%q\n' \
                "${remote_forgejo_name}"
            printf 'REMOTE_FORGEJO_BRANCH=%q\n' \
                "${remote_forgejo_branch}"
            printf 'REMOTE_FORGEJO_SSL_VERIFY=%q\n' \
                "${remote_forgejo_ssl_verify}"
        fi

        if [[ "${github_config_present}" == "Yes" ]]; then
            printf '\n'
            printf '# GitHub distant\n'
            printf 'REMOTE_GITHUB_BASE_URL=%q\n' \
                "${remote_github_base_url}"
            printf 'REMOTE_GITHUB_OWNER=%q\n' \
                "${remote_github_owner}"
            printf 'REMOTE_GITHUB_REPOSITORY=%q\n' \
                "${remote_github_repository}"
            printf 'REMOTE_GITHUB_NAME=%q\n' \
                "${remote_github_name}"
            printf 'REMOTE_GITHUB_BRANCH=%q\n' \
                "${remote_github_branch}"
        fi

        if [[ "${clone_config_present}" == "Yes" ]]; then
            printf '\n'
            printf '# Git distant source du clone\n'
            printf 'REMOTE_CLONE_GIT_TYPE=%q\n' \
                "${remote_clone_git_type}"
            printf 'REMOTE_CLONE_BASE_URL=%q\n' \
                "${remote_clone_base_url}"
            printf 'REMOTE_CLONE_OWNER=%q\n' \
                "${remote_clone_owner}"
            printf 'REMOTE_CLONE_REPOSITORY=%q\n' \
                "${remote_clone_repository}"
            printf 'REMOTE_CLONE_NAME=%q\n' \
                "${remote_clone_name}"
            printf 'REMOTE_CLONE_DEFAULT_BRANCH=%q\n' \
                "${remote_clone_default_branch}"
        fi
    } > "${project_env_tmp}"; then

        rm -f "${project_env_tmp}"

        print_error \
            "Impossible de générer le fichier project.env."
        return 1
    fi

    # Installation de project.env
    if ! mv -f \
        "${project_env_tmp}" \
        "${project_env}"; then

        rm -f "${project_env_tmp}"

        print_error \
            "Impossible d'installer le fichier project.env."
        return 1
    fi

    # Attribution des droits
    if ! chown \
        "${DEVOPS_USER}:${DEVOPS_GROUP}" \
        "${project_env}"; then

        print_error \
            "Impossible d'attribuer project.env à ${DEVOPS_USER}:${DEVOPS_GROUP}."
        return 1
    fi

    if ! chmod 660 "${project_env}"; then
        print_error \
            "Impossible de définir les permissions de project.env."
        return 1
    fi

    print_success \
        "Configuration du projet enregistrée : ${project_env}"

    return 0
}

# Génération ou mise à jour des variables du dépôt Git local.
git_update_local() {
    local project_id="${1:-}"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"
    local project_env="${project_path}/project.env"

    local local_default_branch="main"
    local git_user_name=""
    local git_user_email=""
    local value=""

    if [[ -z "${project_id}" ]]; then
        print_error "Usage : git_update <project_id>"
        return 1
    fi

    if [[ ! -d "${project_path}" ]]; then
        print_error "Le répertoire du projet n'existe pas : ${project_path}"
        return 1
    fi

    unset \
        LOCAL_DEFAULT_BRANCH \
        GIT_USER_NAME \
        GIT_USER_EMAIL

    if [[ -f "${project_env}" ]]; then
        # shellcheck disable=SC1090
        source "${project_env}"
    fi

    local_default_branch="${LOCAL_DEFAULT_BRANCH:-main}"
    git_user_name="${GIT_USER_NAME:-}"
    git_user_email="${GIT_USER_EMAIL:-}"

    print_title "Configuration Git local du projet ${project_id}"

    value=""
    read -r -p \
        "LOCAL_DEFAULT_BRANCH [${local_default_branch}] : " value
    if [[ -n "${value}" ]]; then
        local_default_branch="${value}"
    fi

    while [[ -z "${local_default_branch}" ]]; do
        print_error "LOCAL_DEFAULT_BRANCH ne peut pas être vide."
        read -r -p "LOCAL_DEFAULT_BRANCH : " local_default_branch
    done

    value=""
    read -r -p "GIT_USER_NAME [${git_user_name}] : " value
    if [[ -n "${value}" ]]; then
        git_user_name="${value}"
    fi

    while [[ -z "${git_user_name}" ]]; do
        print_error "GIT_USER_NAME ne peut pas être vide."
        read -r -p "GIT_USER_NAME : " git_user_name
    done

    value=""
    read -r -p "GIT_USER_EMAIL [${git_user_email}] : " value
    if [[ -n "${value}" ]]; then
        git_user_email="${value}"
    fi

    while [[ -z "${git_user_email}" ]]; do
        print_error "GIT_USER_EMAIL ne peut pas être vide."
        read -r -p "GIT_USER_EMAIL : " git_user_email
    done

    if ! project_env_set_variables \
        "${project_env}" \
        LOCAL_DEFAULT_BRANCH "${local_default_branch}" \
        GIT_USER_NAME "${git_user_name}" \
        GIT_USER_EMAIL "${git_user_email}"; then
        return 1
    fi

    if ! chown "${DEVOPS_USER}:${DEVOPS_GROUP}" "${project_env}" ||
        ! chmod 660 "${project_env}"; then
        print_error "Impossible de définir les droits de ${project_env}."
        return 1
    fi

    print_success "Variables Git local enregistrées : ${project_env}"
    return 0
}

# Point d'entrée public limité à la configuration Git locale.
git_update() {
    local project_id="${1:-}"

    git_update_local "${project_id}"
}

# Initialise un dépôt local Git pour le projet <PROJECT ID> à partir d'un clone distant.
git_init_clone() {
    local project_id="$1"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"
    local project_env="${project_path}/project.env"

    local clone_tmp="${DEVOPS_PROJECTS_ROOT}/.${project_id}.clone.$$"
    local project_env_backup="${DEVOPS_PROJECTS_ROOT}/.${project_id}.project.env.$$"

    local project_name=""
    local local_default_branch=""
    local git_user_name=""
    local git_user_email=""

    local remote_name=""

    local remote_clone_git_type=""
    local remote_clone_base_url=""
    local remote_clone_owner=""
    local remote_clone_repository=""
    local remote_clone_name=""
    local remote_clone_default_branch=""
    local remote_clone_url=""

    local current_branch=""
    local confirmation=""

    # Crée le dissier du projet
    mkdir -p ${project_path}

    # Vérification des paramètres
    if [[ -z "${project_id}" ]]; then
        print_error "Usage : git_init_clone <project_id>"
        return 1
    fi

    # Vérification de l'utilisateur DevOps
    if ! check_devops_user; then
        print_error \
            "L'utilisateur DevOps n'existe pas."
        return 1
    fi

    # Vérification du projet
    if [[ ! -d "${project_path}" ]]; then
        print_error \
            "Le répertoire du projet n'existe pas : ${project_path}"
        return 1
    fi

    # Vérification de Git
    if ! command -v git >/dev/null 2>&1; then
        print_error \
            "Git n'est pas installé."
        return 1
    fi

    if ! runuser -u "${DEVOPS_USER}" -- \
        git --version >/dev/null 2>&1; then

        print_error \
            "Git n'est pas accessible pour l'utilisateur ${DEVOPS_USER}."
        return 1
    fi

    # Vérification immédiate d'un dépôt Git local existant
    if runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" rev-parse \
        --is-inside-work-tree >/dev/null 2>&1; then

        print_info \
            "ATTENTION : un dépôt Git local existe déjà pour le projet ${project_id}."

        return 0
    fi

    # Vérification des droits sur le projet
    if ! runuser -u "${DEVOPS_USER}" -- \
        test -r "${project_path}"; then

        print_error \
            "${DEVOPS_USER} ne peut pas lire le projet : ${project_path}"
        return 1
    fi

    if ! runuser -u "${DEVOPS_USER}" -- \
        test -w "${project_path}"; then

        print_error \
            "${DEVOPS_USER} ne peut pas écrire dans le projet : ${project_path}"
        return 1
    fi

    # Vérification des droits sur la racine des projets
    if ! runuser -u "${DEVOPS_USER}" -- \
        test -w "${DEVOPS_PROJECTS_ROOT}"; then

        print_error \
            "${DEVOPS_USER} ne peut pas écrire dans ${DEVOPS_PROJECTS_ROOT}."
        return 1
    fi

    # Chargement / création de project.env avec les variables de clonage
    if [[ ! -f "${project_env}" ]]; then

        print_info \
            "Le fichier project.env est absent pour le projet ${project_id}."

        if ! git_update_legacy "${project_id}" clone; then

            print_error \
                "Impossible d'initialiser la configuration Git du projet cloné."
            return 1
        fi
    fi

    # Vérification de project.env
    if [[ ! -f "${project_env}" ]]; then

        print_error \
            "Le fichier project.env est toujours absent : ${project_env}"
        return 1
    fi

    # Nettoyage des variables susceptibles d'être déjà présentes
    unset \
        PROJECT_ID \
        PROJECT_NAME \
        PROJECT_TYPE \
        PROJECT_DOCKERED \
        LOCAL_DEFAULT_BRANCH \
        GIT_USER_NAME \
        GIT_USER_EMAIL \
        REMOTE_FORGEJO_BASE_URL \
        REMOTE_FORGEJO_OWNER \
        REMOTE_FORGEJO_REPOSITORY \
        REMOTE_FORGEJO_NAME \
        REMOTE_FORGEJO_BRANCH \
        REMOTE_CLONE_GIT_TYPE \
        REMOTE_CLONE_BASE_URL \
        REMOTE_CLONE_OWNER \
        REMOTE_CLONE_REPOSITORY \
        REMOTE_CLONE_NAME \
        REMOTE_CLONE_DEFAULT_BRANCH

    # Chargement de project.env
    # shellcheck disable=SC1090
    source "${project_env}"

    # Vérification de la configuration nécessaire au clonage
    if [[ \
        -z "${PROJECT_ID:-}" ||
        -z "${PROJECT_NAME:-}" ||
        -z "${LOCAL_DEFAULT_BRANCH:-}" ||
        -z "${GIT_USER_NAME:-}" ||
        -z "${GIT_USER_EMAIL:-}" ||
        -z "${REMOTE_CLONE_GIT_TYPE:-}" ||
        -z "${REMOTE_CLONE_BASE_URL:-}" ||
        -z "${REMOTE_CLONE_OWNER:-}" ||
        -z "${REMOTE_CLONE_REPOSITORY:-}" ||
        -z "${REMOTE_CLONE_NAME:-}" ||
        -z "${REMOTE_CLONE_DEFAULT_BRANCH:-}" \
    ]]; then

        print_info \
            "La configuration du projet cloné est incomplète."

        if ! git_update_legacy "${project_id}" clone; then

            print_error \
                "Impossible de mettre à jour la configuration du projet cloné."
            return 1
        fi

        # Nettoyage avant rechargement
        unset \
            PROJECT_ID \
            PROJECT_NAME \
            PROJECT_TYPE \
            PROJECT_DOCKERED \
            LOCAL_DEFAULT_BRANCH \
            GIT_USER_NAME \
            GIT_USER_EMAIL \
            REMOTE_FORGEJO_BASE_URL \
            REMOTE_FORGEJO_OWNER \
            REMOTE_FORGEJO_REPOSITORY \
            REMOTE_FORGEJO_NAME \
            REMOTE_FORGEJO_BRANCH \
            REMOTE_CLONE_GIT_TYPE \
            REMOTE_CLONE_BASE_URL \
            REMOTE_CLONE_OWNER \
            REMOTE_CLONE_REPOSITORY \
            REMOTE_CLONE_NAME \
            REMOTE_CLONE_DEFAULT_BRANCH

        # Recharge project.env
        # shellcheck disable=SC1090
        source "${project_env}"
    fi

    # Vérification de PROJECT_ID
    if [[ "${PROJECT_ID:-}" != "${project_id}" ]]; then

        print_error \
            "PROJECT_ID '${PROJECT_ID:-}' ne correspond pas au projet '${project_id}'."
        return 1
    fi

    # Vérification de PROJECT_NAME
    if [[ -z "${PROJECT_NAME:-}" ]]; then
        print_error \
            "PROJECT_NAME n'est pas défini dans project.env."
        return 1
    fi

    # Vérification de LOCAL_DEFAULT_BRANCH
    if [[ -z "${LOCAL_DEFAULT_BRANCH:-}" ]]; then
        print_error \
            "LOCAL_DEFAULT_BRANCH n'est pas défini dans project.env."
        return 1
    fi

    # Vérification de GIT_USER_NAME
    if [[ -z "${GIT_USER_NAME:-}" ]]; then
        print_error \
            "GIT_USER_NAME n'est pas défini dans project.env."
        return 1
    fi

    # Vérification de GIT_USER_EMAIL
    if [[ -z "${GIT_USER_EMAIL:-}" ]]; then
        print_error \
            "GIT_USER_EMAIL n'est pas défini dans project.env."
        return 1
    fi

    # Vérification de REMOTE_CLONE_GIT_TYPE
    if [[ -z "${REMOTE_CLONE_GIT_TYPE:-}" ]]; then
        print_error \
            "REMOTE_CLONE_GIT_TYPE n'est pas défini dans project.env."
        return 1
    fi

    # Vérification de REMOTE_CLONE_BASE_URL
    if [[ -z "${REMOTE_CLONE_BASE_URL:-}" ]]; then
        print_error \
            "REMOTE_CLONE_BASE_URL n'est pas défini dans project.env."
        return 1
    fi

    # Vérification de REMOTE_CLONE_OWNER
    if [[ -z "${REMOTE_CLONE_OWNER:-}" ]]; then
        print_error \
            "REMOTE_CLONE_OWNER n'est pas défini dans project.env."
        return 1
    fi

    # Vérification de REMOTE_CLONE_REPOSITORY
    if [[ -z "${REMOTE_CLONE_REPOSITORY:-}" ]]; then
        print_error \
            "REMOTE_CLONE_REPOSITORY n'est pas défini dans project.env."
        return 1
    fi

    # Vérification de REMOTE_CLONE_NAME
    if [[ -z "${REMOTE_CLONE_NAME:-}" ]]; then
        print_error \
            "REMOTE_CLONE_NAME n'est pas défini dans project.env."
        return 1
    fi

    # Vérification de REMOTE_CLONE_DEFAULT_BRANCH
    if [[ -z "${REMOTE_CLONE_DEFAULT_BRANCH:-}" ]]; then
        print_error \
            "REMOTE_CLONE_DEFAULT_BRANCH n'est pas défini dans project.env."
        return 1
    fi

    # Vérification des noms des remotes
    if [[ \
        -n "${REMOTE_FORGEJO_NAME:-}" &&
        "${REMOTE_FORGEJO_NAME}" == "${REMOTE_CLONE_NAME}" \
    ]]; then

        print_error \
            "REMOTE_FORGEJO_NAME et REMOTE_CLONE_NAME doivent être différents."
        return 1
    fi

    # Affectation locale de la configuration
    project_name="${PROJECT_NAME}"
    local_default_branch="${LOCAL_DEFAULT_BRANCH}"
    git_user_name="${GIT_USER_NAME}"
    git_user_email="${GIT_USER_EMAIL}"

    remote_name="${REMOTE_FORGEJO_NAME:-origin}"

    remote_clone_git_type="${REMOTE_CLONE_GIT_TYPE}"
    remote_clone_base_url="${REMOTE_CLONE_BASE_URL%/}"
    remote_clone_owner="${REMOTE_CLONE_OWNER}"
    remote_clone_repository="${REMOTE_CLONE_REPOSITORY}"
    remote_clone_name="${REMOTE_CLONE_NAME}"
    remote_clone_default_branch="${REMOTE_CLONE_DEFAULT_BRANCH}"

    # Construction de l'URL de clonage
    remote_clone_url="${remote_clone_base_url}/${remote_clone_owner}/${remote_clone_repository}.git"

    print_title \
        "Clonage Git du projet ${project_name} : ${project_path}"

    # Résumé de la configuration
    print_title "Configuration du clonage Git"

    printf '%-30s : %s\n' \
        "Projet" "${project_name}"

    printf '%-30s : %s\n' \
        "ID projet" "${project_id}"

    printf '%-30s : %s\n' \
        "Répertoire" "${project_path}"

    printf '%-30s : %s\n' \
        "Utilisateur Linux" "${DEVOPS_USER}"

    printf '%-30s : %s\n' \
        "Utilisateur Git" "${git_user_name}"

    printf '%-30s : %s\n' \
        "Email Git" "${git_user_email}"

    printf '%-30s : %s\n' \
        "Branche locale" "${local_default_branch}"

    printf '\n'

    printf '%-30s : %s\n' \
        "Type source" "${remote_clone_git_type}"

    printf '%-30s : %s\n' \
        "URL source" "${remote_clone_url}"

    printf '%-30s : %s\n' \
        "Remote source" "${remote_clone_name}"

    printf '%-30s : %s\n' \
        "Branche source" "${remote_clone_default_branch}"

    printf '\n'

    printf '%-30s : %s\n' \
        "Remote publication réservé" "${remote_name}"

    printf '\n'

    print_info \
        "Les fichiers du dépôt distant remplaceront les fichiers locaux portant le même nom."

    print_info \
        "Les fichiers locaux absents du dépôt distant seront conservés."

    print_info \
        "Le fichier project.env du DIU sera conservé."

    # Confirmation
    printf '\n'

    read -r -p \
        "Cloner et fusionner le dépôt distant ? [o/N] : " confirmation

    case "${confirmation}" in
        o|O|oui|OUI|y|Y|yes|YES)
            ;;
        *)
            print_info \
                "Clonage annulé."
            return 0
            ;;
    esac

    # Vérification du répertoire temporaire
    if [[ -e "${clone_tmp}" ]]; then

        print_error \
            "Le répertoire temporaire existe déjà : ${clone_tmp}"
        return 1
    fi

    # Vérification du fichier de sauvegarde temporaire
    if [[ -e "${project_env_backup}" ]]; then

        print_error \
            "Le fichier temporaire existe déjà : ${project_env_backup}"
        return 1
    fi

    # Sauvegarde de project.env
    if ! cp -a \
        "${project_env}" \
        "${project_env_backup}"; then

        print_error \
            "Impossible de sauvegarder project.env."
        return 1
    fi

    # Clonage dans un répertoire temporaire
    print_title \
        "Clonage du dépôt Git distant"

    if ! runuser -u "${DEVOPS_USER}" -- \
        git clone \
        --origin "${remote_clone_name}" \
        --branch "${remote_clone_default_branch}" \
        --single-branch \
        "${remote_clone_url}" \
        "${clone_tmp}"; then

        rm -rf -- "${clone_tmp}"
        rm -f -- "${project_env_backup}"

        print_error \
            "Échec du clonage du dépôt distant."
        return 1
    fi

    # Fusion du clone dans le projet.
    #
    # Les fichiers provenant du clone sont prioritaires :
    # lorsqu'un fichier existe déjà dans le projet,
    # il est remplacé par celui provenant du dépôt distant.
    #
    # Les fichiers locaux qui n'existent pas dans le clone
    # restent présents.
    print_title \
        "Fusion du dépôt cloné dans le projet"

    if ! cp -a \
        --remove-destination \
        "${clone_tmp}/." \
        "${project_path}/"; then

        rm -rf -- "${clone_tmp}"

        # Restauration de project.env
        if [[ -f "${project_env_backup}" ]]; then
            cp -a \
                "${project_env_backup}" \
                "${project_env}"
        fi

        rm -f -- "${project_env_backup}"

        print_error \
            "Impossible de fusionner le dépôt cloné dans ${project_path}."
        return 1
    fi

    # Restauration obligatoire du project.env DIU
    if ! cp -a \
        "${project_env_backup}" \
        "${project_env}"; then

        rm -rf -- "${clone_tmp}"
        rm -f -- "${project_env_backup}"

        print_error \
            "Impossible de restaurer le fichier project.env du DIU."
        return 1
    fi

    # Suppression des éléments temporaires
    rm -rf -- "${clone_tmp}"
    rm -f -- "${project_env_backup}"

    # Attribution des droits sur project.env
    if ! chown \
        "${DEVOPS_USER}:${DEVOPS_GROUP}" \
        "${project_env}"; then

        print_error \
            "Impossible d'attribuer project.env à ${DEVOPS_USER}:${DEVOPS_GROUP}."
        return 1
    fi

    if ! chmod 660 \
        "${project_env}"; then

        print_error \
            "Impossible de définir les permissions de project.env."
        return 1
    fi

    # Vérification du dépôt cloné
    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" rev-parse \
        --is-inside-work-tree >/dev/null 2>&1; then

        print_error \
            "Le dépôt cloné n'est pas exploitable dans ${project_path}."
        return 1
    fi

    # Détermination de la branche locale
    current_branch="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" branch --show-current
    )"

    if [[ -z "${current_branch}" ]]; then

        print_error \
            "Impossible de déterminer la branche Git locale."
        return 1
    fi

    # Renommage éventuel de la branche locale
    if [[ "${current_branch}" != "${local_default_branch}" ]]; then

        if ! runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" branch \
            -m "${local_default_branch}"; then

            print_error \
                "Impossible de renommer la branche locale en ${local_default_branch}."
            return 1
        fi
    fi

    # Configuration de user.name
    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" config --local \
        user.name "${git_user_name}"; then

        print_error \
            "Échec de la configuration de user.name."
        return 1
    fi

    # Configuration de user.email
    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" config --local \
        user.email "${git_user_email}"; then

        print_error \
            "Échec de la configuration de user.email."
        return 1
    fi

    # Configuration de core.fileMode
    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" config --local \
        core.fileMode false; then

        print_error \
            "Échec de la configuration de core.fileMode."
        return 1
    fi

    # Configuration de core.autocrlf
    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" config --local \
        core.autocrlf false; then

        print_error \
            "Échec de la configuration de core.autocrlf."
        return 1
    fi

    # Configuration de core.eol
    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" config --local \
        core.eol lf; then

        print_error \
            "Échec de la configuration de core.eol."
        return 1
    fi

    # Configuration de i18n.commitEncoding
    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" config --local \
        i18n.commitEncoding utf-8; then

        print_error \
            "Échec de la configuration de i18n.commitEncoding."
        return 1
    fi

    # Configuration de i18n.logOutputEncoding
    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" config --local \
        i18n.logOutputEncoding utf-8; then

        print_error \
            "Échec de la configuration de i18n.logOutputEncoding."
        return 1
    fi

    # Vérification du remote source
    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" remote get-url \
        "${remote_clone_name}" >/dev/null 2>&1; then

        print_error \
            "Le remote source '${remote_clone_name}' n'est pas configuré."
        return 1
    fi

    # Le remote de publication reste volontairement libre
    if [[ -n "${remote_name}" ]] && \
        runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" remote get-url \
        "${remote_name}" >/dev/null 2>&1; then

        print_error \
            "Le remote de publication '${remote_name}' existe déjà après le clonage."
        return 1
    fi

    # Configuration Git locale
    print_title \
        "Configuration Git locale"

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" config \
        --list --local; then

        print_error \
            "Impossible d'afficher la configuration Git locale."
        return 1
    fi

    # Dépôts distants
    print_title \
        "Dépôts Git distants"

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" remote -v; then

        print_error \
            "Impossible d'afficher les dépôts Git distants."
        return 1
    fi

    # Branches
    print_title \
        "Branches Git"

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" branch -vv; then

        print_error \
            "Impossible d'afficher les branches Git."
        return 1
    fi

    # Historique
    print_title \
        "Historique Git"

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" log \
        --oneline \
        --decorate \
        -5; then

        print_error \
            "Impossible d'afficher l'historique Git."
        return 1
    fi

    # État du dépôt
    print_title \
        "État du dépôt Git"

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" status --short; then

        print_error \
            "Impossible d'afficher l'état du dépôt Git."
        return 1
    fi

    printf '\n'

    print_success \
        "Dépôt Git cloné et fusionné avec succès par ${DEVOPS_USER}."

    return 0
}


git_with_token() {

    # Exécute une commande Git authentifiée via un token HTTPS temporaire.
    #
    # Signature :
    #   git_with_token <project_path> <git_username> <token> <git_args...>
    #
    # Retourne le code de sortie de la commande Git.
    # En cas de paramètres manquants ou token vide, retourne 1 sans exécuter Git.

    local project_path="${1:-}"
    local git_username="${2:-}"
    local token="${3:-}"
    shift 3 2>/dev/null || {
        print_error "git_with_token : paramètres manquants (project_path, git_username, token, git_args...)"
        return 1
    }
    local git_args=("${@}")

    # ----------------------------------------------------------
    # Validation des paramètres
    # ----------------------------------------------------------

    if [[ -z "${project_path}" ]]; then
        print_error "git_with_token : project_path est vide."
        return 1
    fi

    if [[ -z "${git_username}" ]]; then
        print_error "git_with_token : git_username est vide."
        return 1
    fi

    if [[ -z "${token}" ]]; then
        print_error "git_with_token : token est vide."
        return 1
    fi

    if [[ ${#git_args[@]} -eq 0 ]]; then
        print_error "git_with_token : aucun argument Git fourni."
        return 1
    fi

    # ----------------------------------------------------------
    # Exécution dans un subshell avec cleanup garanti
    # ----------------------------------------------------------

    (
        local tmp_dir=""

        tmp_dir="$(mktemp -d)" || {
            print_error "git_with_token : impossible de créer le répertoire temporaire."
            exit 1
        }

        chmod 700 "${tmp_dir}"

        trap 'rm -rf "${tmp_dir}"' EXIT

        # ----------------------------------------------------------
        # Création du fichier credentials (mode 600)
        # ----------------------------------------------------------

        local credentials_file="${tmp_dir}/credentials"

        printf '%s\n%s\n' "${git_username}" "${token}" > "${credentials_file}"
        chmod 600 "${credentials_file}"

        # Transférer la propriété à DEVOPS_USER si exécuté en root
        if [[ "$(id -u)" -eq 0 ]] && id "${DEVOPS_USER}" >/dev/null 2>&1; then
            chown "${DEVOPS_USER}:${DEVOPS_GROUP}" "${tmp_dir}" "${credentials_file}"
        fi

        # ----------------------------------------------------------
        # Création du script askpass.sh (mode 700, sans secret)
        # ----------------------------------------------------------

        local askpass_file="${tmp_dir}/askpass.sh"

        cat > "${askpass_file}" <<'ASKPASS_EOF'
#!/usr/bin/env bash
# Script ASKPASS temporaire — ne contient aucun secret.
# Lit le fichier credentials situé dans le même répertoire.

script_dir="$(cd "$(dirname "$0")" && pwd)"
credentials_file="${script_dir}/credentials"

prompt="${1:-}"

if [[ "${prompt}" == *"Username"* ]]; then
    IFS= read -r username < "${credentials_file}"
    printf '%s\n' "${username}"
elif [[ "${prompt}" == *"Password"* ]]; then
    {
        IFS= read -r _username
        IFS= read -r password
    } < "${credentials_file}"
    printf '%s\n' "${password}"
else
    exit 1
fi
ASKPASS_EOF

        chmod 700 "${askpass_file}"

        if [[ "$(id -u)" -eq 0 ]] && id "${DEVOPS_USER}" >/dev/null 2>&1; then
            chown "${DEVOPS_USER}:${DEVOPS_GROUP}" "${askpass_file}"
        fi

        # ----------------------------------------------------------
        # Exécution de la commande Git sous DEVOPS_USER
        # ----------------------------------------------------------

        local git_rc=0

        runuser -u "${DEVOPS_USER}" -- \
            env "LC_ALL=C" \
                "GIT_ASKPASS=${askpass_file}" \
                "GIT_TERMINAL_PROMPT=0" \
                "HOME=$(eval echo "~${DEVOPS_USER}")" \
            git -C "${project_path}" "${git_args[@]}" || git_rc=$?

        if [[ "${git_rc}" -ne 0 ]]; then
            print_error "git_with_token : commande Git échouée (code ${git_rc})."
        fi

        exit "${git_rc}"
    )

    return $?
}

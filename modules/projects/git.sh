#!/usr/bin/env bash

# Gestion Git du DIU

# Flux DIU CI/CD 

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

    if ! git_push \
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
        GIT_USER_EMAIL \
        REMOTE_GIT_TYPE \
        REMOTE_BASE_URL \
        REMOTE_OWNER \
        REMOTE_REPOSITORY \
        REMOTE_NAME \
        REMOTE_DEFAULT_BRANCH

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

    if ! git_push \
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

    if ! proj_docker_build \
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

    if ! git_push_docker_release \
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

        if ! git_update "${project_id}"; then
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
        GIT_USER_EMAIL \
        REMOTE_GIT_TYPE \
        REMOTE_BASE_URL \
        REMOTE_OWNER \
        REMOTE_REPOSITORY \
        REMOTE_NAME \
        REMOTE_DEFAULT_BRANCH

    # shellcheck disable=SC1090
    source "${project_env}"

    # Vérification des variables essentielles
    if [[ \
        -z "${PROJECT_ID:-}" ||
        -z "${PROJECT_NAME:-}" \
    ]]; then

        print_info \
            "La configuration du projet est incomplète."

        if ! git_update "${project_id}"; then
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
            GIT_USER_EMAIL \
            REMOTE_GIT_TYPE \
            REMOTE_BASE_URL \
            REMOTE_OWNER \
            REMOTE_REPOSITORY \
            REMOTE_NAME \
            REMOTE_DEFAULT_BRANCH

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

git_commit() {
    local project_id="$1"
    local commit_name="$2"
    local commit_tag="$3"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"
    local project_env="${project_path}/project.env"

    local project_name=""

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

        if ! project_update "${project_id}"; then
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
        REMOTE_GIT_TYPE \
        REMOTE_BASE_URL \
        REMOTE_OWNER \
        REMOTE_REPOSITORY \
        REMOTE_NAME \
        REMOTE_DEFAULT_BRANCH

    # shellcheck disable=SC1090
    source "${project_env}"

    # Vérification des variables essentielles
    if [[ \
        -z "${PROJECT_ID:-}" ||
        -z "${PROJECT_NAME:-}" \
    ]]; then

        print_info \
            "La configuration du projet est incomplète."

        if ! project_update "${project_id}"; then
            print_error \
                "Impossible de mettre à jour la configuration du projet."
            return 1
        fi

        # Recharge project.env après project_update
        unset \
            PROJECT_ID \
            PROJECT_NAME \
            PROJECT_TYPE \
            PROJECT_DOCKERED \
            LOCAL_DEFAULT_BRANCH \
            REMOTE_GIT_TYPE \
            REMOTE_BASE_URL \
            REMOTE_OWNER \
            REMOTE_REPOSITORY \
            REMOTE_NAME \
            REMOTE_DEFAULT_BRANCH

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

    print_title "Commit Git ${project_name} : ${project_path}"

    # Vérification du dépôt Git local
    if [[ "$(runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" rev-parse \
        --is-inside-work-tree 2>/dev/null)" != "true" ]]; then

        print_error "Aucun dépôt Git initialisé."
        return 1
    fi

    # Vérification des droits
    if ! runuser -u "${DEVOPS_USER}" -- \
        test -w "${project_path}"; then

        print_error \
            "${DEVOPS_USER} ne peut pas écrire dans ${project_path}"
        return 1
    fi

    # Ajout des fichiers
    print_info "Ajout des modifications..."

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" add .; then

        print_error "Échec du git add."
        return 1
    fi

    # Vérification des modifications
    if runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" diff \
        --cached --quiet; then

        print_info "Aucune modification à enregistrer."
        return 0
    fi

    # Résumé avant commit
    print_title "Résumé des modifications"

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" status --short; then

        print_error \
            "Impossible d'afficher le résumé des modifications."
        return 1
    fi

    # Création du commit
    print_title "Création du commit"

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" commit \
        -m "${commit_name}"; then

        print_error "Échec du commit Git."
        return 1
    fi

    # Création du tag
    print_title "Création du tag Git"

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" tag \
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

git_init() {
    local project_id="$1"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"
    local project_env="${project_path}/project.env"

    local project_name=""
    local local_default_branch=""
    local git_user_name=""
    local git_user_email=""
    local confirmation=""

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

        if ! git_update "${project_id}"; then
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
        GIT_USER_EMAIL \
        REMOTE_GIT_TYPE \
        REMOTE_BASE_URL \
        REMOTE_OWNER \
        REMOTE_REPOSITORY \
        REMOTE_NAME \
        REMOTE_DEFAULT_BRANCH

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

        if ! git_update "${project_id}"; then
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
            GIT_USER_EMAIL \
            REMOTE_GIT_TYPE \
            REMOTE_BASE_URL \
            REMOTE_OWNER \
            REMOTE_REPOSITORY \
            REMOTE_NAME \
            REMOTE_DEFAULT_BRANCH

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

    print_title \
        "Initialisation Git du projet ${project_name} : ${project_path}"

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
        git -C "${project_path}" rev-parse \
        --is-inside-work-tree >/dev/null 2>&1; then

        print_info "Le dépôt Git est déjà initialisé."
        return 0
    fi

    # Résumé de la configuration
    print_title "Configuration du dépôt Git local"

    printf '%-22s : %s\n' "Projet" "${project_name}"
    printf '%-22s : %s\n' "ID projet" "${project_id}"
    printf '%-22s : %s\n' "Répertoire" "${project_path}"
    printf '%-22s : %s\n' "Utilisateur Linux" "${DEVOPS_USER}"
    printf '%-22s : %s\n' "Utilisateur Git" "${git_user_name}"
    printf '%-22s : %s\n' "Email Git" "${git_user_email}"
    printf '%-22s : %s\n' \
        "Branche par défaut" "${local_default_branch}"

    # Confirmation
    printf '\n'
    read -r -p "Initialiser Git localement ? [o/N] : " confirmation

    case "${confirmation}" in
        o|O|oui|OUI|y|Y|yes|YES)
            ;;
        *)
            print_info "Initialisation annulée."
            return 0
            ;;
    esac

    # Initialisation du dépôt Git local
    print_title "Initialisation du dépôt Git local"

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" \
        init -b "${local_default_branch}"; then

        print_error \
            "Échec de l'initialisation du dépôt Git."
        return 1
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

    # Vérification de la configuration Git locale
    print_title "Configuration Git locale"

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" config \
        --list --local; then

        print_error \
            "Impossible d'afficher la configuration Git locale."
        return 1
    fi

    # Vérification de l'absence de dépôt distant
    if runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" remote |
        grep -q .; then

        print_error \
            "Un dépôt distant est déjà configuré alors que l'initialisation doit rester locale."

        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" remote -v

        return 1
    fi

    # Ajout des fichiers au dépôt local
    print_title "Ajout des fichiers au dépôt Git local"

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" add .; then

        print_error \
            "Échec de l'ajout des fichiers à l'index Git."
        return 1
    fi

    # État du dépôt
    print_title "État du dépôt Git"

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" status --short; then

        print_error \
            "Impossible d'afficher l'état du dépôt Git."
        return 1
    fi

    # Fichiers suivis
    print_title "Fichiers suivis"

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" ls-files; then

        print_error \
            "Impossible d'afficher les fichiers du dépôt Git."
        return 1
    fi

    print_info \
        "Aucun dépôt distant n'est configuré."

    # Vérification du contenu du premier commit
    if runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" diff \
        --cached --quiet; then

        print_error \
            "Aucun fichier versionnable n'est disponible pour le premier commit."
        return 1
    fi

    # Création du premier commit
    print_title "Création du premier commit"

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" commit \
        -m "Initialisation du projet ${project_name}"; then

        print_error \
            "Échec de la création du premier commit."
        return 1
    fi

    # Historique du premier commit
    print_title "Historique Git"

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" log \
        --oneline \
        --decorate \
        -5; then

        print_error \
            "Impossible d'afficher l'historique du premier commit Git."
        return 1
    fi

    # Contenu du premier commit
    print_title "Contenu du premier commit"

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" show \
        --stat \
        --summary \
        HEAD; then

        print_error \
            "Impossible d'afficher le contenu du premier commit Git."
        return 1
    fi

    # Fichiers ignorés et non suivis
    print_title "Éléments ignorés et non suivis"

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" \
        status --ignored --short; then

        print_error \
            "Impossible d'afficher les fichiers ignorés du dépôt Git."
        return 1
    fi

    printf '\n'

    print_success \
        "Dépôt Git local initialisé avec succès par ${DEVOPS_USER}."

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

git_push() {
    local project_id="$1"
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
    local confirmation=""
    local push_rc=0

    # Vérification des paramètres
    if [[ -z "${project_id}" ]]; then
        print_error "git_push : PROJECT_ID est vide."
        return 1
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

        if ! project_update "${project_id}"; then
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
        REMOTE_GIT_TYPE \
        REMOTE_BASE_URL \
        REMOTE_OWNER \
        REMOTE_REPOSITORY \
        REMOTE_NAME \
        REMOTE_DEFAULT_BRANCH

    # shellcheck disable=SC1090
    source "${project_env}"

    # Vérification des variables essentielles
    if [[ \
        -z "${PROJECT_ID:-}" ||
        -z "${PROJECT_NAME:-}" ||
        -z "${REMOTE_GIT_TYPE:-}" ||
        -z "${REMOTE_BASE_URL:-}" ||
        -z "${REMOTE_OWNER:-}" ||
        -z "${REMOTE_REPOSITORY:-}" ||
        -z "${REMOTE_NAME:-}" ||
        -z "${REMOTE_DEFAULT_BRANCH:-}" \
    ]]; then

        print_info \
            "La configuration Git du projet est incomplète."

        if ! project_update "${project_id}"; then
            print_error \
                "Impossible de mettre à jour la configuration du projet."
            return 1
        fi

        # Recharge project.env après project_update
        unset \
            PROJECT_ID \
            PROJECT_NAME \
            PROJECT_TYPE \
            PROJECT_DOCKERED \
            LOCAL_DEFAULT_BRANCH \
            REMOTE_GIT_TYPE \
            REMOTE_BASE_URL \
            REMOTE_OWNER \
            REMOTE_REPOSITORY \
            REMOTE_NAME \
            REMOTE_DEFAULT_BRANCH

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

    if [[ -z "${REMOTE_GIT_TYPE:-}" ]]; then
        print_error "REMOTE_GIT_TYPE n'est pas défini dans project.env."
        return 1
    fi

    if [[ -z "${REMOTE_BASE_URL:-}" ]]; then
        print_error "REMOTE_BASE_URL n'est pas défini dans project.env."
        return 1
    fi

    if [[ -z "${REMOTE_OWNER:-}" ]]; then
        print_error "REMOTE_OWNER n'est pas défini dans project.env."
        return 1
    fi

    if [[ -z "${REMOTE_REPOSITORY:-}" ]]; then
        print_error "REMOTE_REPOSITORY n'est pas défini dans project.env."
        return 1
    fi

    if [[ -z "${REMOTE_NAME:-}" ]]; then
        print_error "REMOTE_NAME n'est pas défini dans project.env."
        return 1
    fi

    if [[ -z "${REMOTE_DEFAULT_BRANCH:-}" ]]; then
        print_error \
            "REMOTE_DEFAULT_BRANCH n'est pas défini dans project.env."
        return 1
    fi

    # Affectation locale de la configuration du projet
    project_name="${PROJECT_NAME}"
    remote_git_type="${REMOTE_GIT_TYPE}"
    remote_base_url="${REMOTE_BASE_URL%/}"
    remote_owner="${REMOTE_OWNER}"
    remote_repository="${REMOTE_REPOSITORY}"
    remote_name="${REMOTE_NAME}"
    remote_default_branch="${REMOTE_DEFAULT_BRANCH}"

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
            if ! _forgejo_ensure_credentials "${project_path}"; then
                print_error \
                    "Impossible d'initialiser les credentials Forgejo."
                return 1
            fi
            ;;

        *)
            print_error \
                "Type de dépôt Git distant non supporté : ${remote_git_type}"
            return 1
            ;;
    esac

    # Détermination de l'upstream
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

        printf '\n'
        print_info "Le dépôt local va être envoyé vers :"
        printf '  %s\n' "${configured_remote_url}"
        printf '\n'
        printf 'Branche locale    : %s\n' "${current_branch}"
        printf 'Branche distante  : %s\n' "${remote_default_branch}"

    else

        print_info \
            "Branche distante de suivi : ${upstream}"
    fi

    if [[ -n "${current_tag}" ]]; then
        printf 'Tag Git            : %s\n' "${current_tag}"
    fi

    # Confirmation
    printf '\n'
    read -r -p "Effectuer le push ? [o/N] : " confirmation

    case "${confirmation}" in
        o|O|oui|OUI|y|Y|yes|YES)
            ;;
        *)
            print_info "Push annulé."
            return 0
            ;;
    esac

    # Push
    case "${remote_git_type}" in

        forgejo)

            print_title "Push vers Forgejo"

            if [[ -z "${upstream}" ]]; then

                print_info \
                    "Premier push : création de la branche distante et de son suivi."

                forgejo_git_push \
                    "${project_path}" \
                    -u "${remote_name}" \
                    "${current_branch}:${remote_default_branch}" \
                    || push_rc=$?

            else

                print_info \
                    "Push de la branche ${current_branch} vers ${upstream}."

                forgejo_git_push \
                    "${project_path}" \
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

                forgejo_git_push \
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

git_push_docker_release() {

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

    local docker_config=""
    local docker_publish_rc=0

    # --------------------------------------------------------
    # Vérification des arguments
    # --------------------------------------------------------

    if [[ -z "${project_id}" ]]; then
        print_error \
            "Usage : git_push_docker_release <project_id>"
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

    if [[ "${PROJECT_DOCKERED:-No}" != "Yes" ]]; then
        print_error \
            "Le projet '${project_id}' n'est pas déclaré comme Dockerisé."
        return 1
    fi

    # --------------------------------------------------------
    # Vérification configuration distante
    # --------------------------------------------------------

    if [[ \
        -z "${REMOTE_BASE_URL:-}" ||
        -z "${REMOTE_OWNER:-}" ||
        -z "${REMOTE_REPOSITORY:-}" \
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

    remote_registry="${REMOTE_BASE_URL#https://}"
    remote_registry="${remote_registry#http://}"
    remote_registry="${remote_registry%/}"

    remote_image_version="${remote_registry}/${REMOTE_OWNER}/${REMOTE_REPOSITORY}:${docker_version}"
    remote_image_latest="${remote_registry}/${REMOTE_OWNER}/${REMOTE_REPOSITORY}:latest"

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
        "Owner cible" "${REMOTE_OWNER}"

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
        return 1
    fi

    # --------------------------------------------------------
    # Création du DOCKER_CONFIG temporaire
    # --------------------------------------------------------

    docker_config="$(mktemp -d)" || {
        print_error \
            "Impossible de créer le DOCKER_CONFIG temporaire."
        return 1
    }

    if [[ -z "${docker_config}" ]] ||
       [[ ! -d "${docker_config}" ]]; then

        print_error \
            "DOCKER_CONFIG temporaire invalide."
        return 1
    fi

    if ! chmod 700 "${docker_config}"; then
        print_error \
            "Impossible de sécuriser ${docker_config}."
        rm -rf "${docker_config}"
        return 1
    fi

    if ! chown \
        "${DEVOPS_USER}:${DEVOPS_GROUP}" \
        "${docker_config}"; then

        print_error \
            "Impossible d'attribuer ${docker_config} à ${DEVOPS_USER}."

        rm -rf "${docker_config}"
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

    return 0
}

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

        if ! git_update "${project_id}"; then
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
        GIT_USER_EMAIL \
        REMOTE_GIT_TYPE \
        REMOTE_BASE_URL \
        REMOTE_OWNER \
        REMOTE_REPOSITORY \
        REMOTE_NAME \
        REMOTE_DEFAULT_BRANCH

    # shellcheck disable=SC1090
    source "${project_env}"

    # Vérification des variables essentielles
    if [[ \
        -z "${PROJECT_ID:-}" ||
        -z "${PROJECT_NAME:-}" \
    ]]; then

        print_info \
            "La configuration du projet est incomplète."

        if ! git_update "${project_id}"; then
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
            GIT_USER_EMAIL \
            REMOTE_GIT_TYPE \
            REMOTE_BASE_URL \
            REMOTE_OWNER \
            REMOTE_REPOSITORY \
            REMOTE_NAME \
            REMOTE_DEFAULT_BRANCH

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

git_update() {
    local project_id="$1"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"
    local project_env="${project_path}/project.env"

    local project_name=""
    local project_type="BASH"
    local project_dockered="No"

    local local_default_branch="main"
    local git_user_name=""
    local git_user_email=""

    local remote_git_type=""
    local remote_base_url=""
    local remote_owner=""
    local remote_repository=""
    local remote_name="origin"
    local remote_default_branch="main"

    local value=""
    local project_env_tmp=""

    # Vérification des paramètres
    if [[ -z "${project_id}" ]]; then
        print_error "Usage : git_update <project_id>"
        return 1
    fi

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
            LOCAL_DEFAULT_BRANCH \
            GIT_USER_NAME \
            GIT_USER_EMAIL \
            REMOTE_GIT_TYPE \
            REMOTE_BASE_URL \
            REMOTE_OWNER \
            REMOTE_REPOSITORY \
            REMOTE_NAME \
            REMOTE_DEFAULT_BRANCH

        # shellcheck disable=SC1090
        source "${project_env}"

        project_name="${PROJECT_NAME:-}"
        project_type="${PROJECT_TYPE:-BASH}"
        project_dockered="${PROJECT_DOCKERED:-No}"

        local_default_branch="${LOCAL_DEFAULT_BRANCH:-main}"
        git_user_name="${GIT_USER_NAME:-}"
        git_user_email="${GIT_USER_EMAIL:-}"

        remote_git_type="${REMOTE_GIT_TYPE:-}"
        remote_base_url="${REMOTE_BASE_URL:-}"
        remote_owner="${REMOTE_OWNER:-}"
        remote_repository="${REMOTE_REPOSITORY:-}"
        remote_name="${REMOTE_NAME:-origin}"
        remote_default_branch="${REMOTE_DEFAULT_BRANCH:-main}"
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

    # REMOTE_GIT_TYPE
    value=""
    read -r -p \
        "REMOTE_GIT_TYPE [${remote_git_type}] : " value

    if [[ -n "${value}" ]]; then
        remote_git_type="${value}"
    fi

    # REMOTE_BASE_URL
    value=""
    read -r -p \
        "REMOTE_BASE_URL [${remote_base_url}] : " value

    if [[ -n "${value}" ]]; then
        remote_base_url="${value}"
    fi

    # Suppression du / final éventuel
    remote_base_url="${remote_base_url%/}"

    # REMOTE_OWNER
    value=""
    read -r -p \
        "REMOTE_OWNER [${remote_owner}] : " value

    if [[ -n "${value}" ]]; then
        remote_owner="${value}"
    fi

    # REMOTE_REPOSITORY
    value=""
    read -r -p \
        "REMOTE_REPOSITORY [${remote_repository}] : " value

    if [[ -n "${value}" ]]; then
        remote_repository="${value}"
    fi

    # REMOTE_NAME
    value=""
    read -r -p \
        "REMOTE_NAME [${remote_name}] : " value

    if [[ -n "${value}" ]]; then
        remote_name="${value}"
    fi

    # REMOTE_DEFAULT_BRANCH
    value=""
    read -r -p \
        "REMOTE_DEFAULT_BRANCH [${remote_default_branch}] : " value

    if [[ -n "${value}" ]]; then
        remote_default_branch="${value}"
    fi

    # Résumé
    print_title "Configuration du projet"

    printf '%-24s : %s\n' "PROJECT_ID" "${project_id}"
    printf '%-24s : %s\n' "PROJECT_NAME" "${project_name}"
    printf '%-24s : %s\n' "PROJECT_TYPE" "${project_type}"
    printf '%-24s : %s\n' "PROJECT_DOCKERED" "${project_dockered}"

    printf '\n'

    printf '%-24s : %s\n' \
        "LOCAL_DEFAULT_BRANCH" "${local_default_branch}"
    printf '%-24s : %s\n' \
        "GIT_USER_NAME" "${git_user_name}"
    printf '%-24s : %s\n' \
        "GIT_USER_EMAIL" "${git_user_email}"

    printf '\n'

    printf '%-24s : %s\n' \
        "REMOTE_GIT_TYPE" "${remote_git_type}"
    printf '%-24s : %s\n' \
        "REMOTE_BASE_URL" "${remote_base_url}"
    printf '%-24s : %s\n' \
        "REMOTE_OWNER" "${remote_owner}"
    printf '%-24s : %s\n' \
        "REMOTE_REPOSITORY" "${remote_repository}"
    printf '%-24s : %s\n' \
        "REMOTE_NAME" "${remote_name}"
    printf '%-24s : %s\n' \
        "REMOTE_DEFAULT_BRANCH" "${remote_default_branch}"

    # Création du fichier temporaire
    project_env_tmp="${project_env}.tmp"

    if ! {
        printf '# Projet\n'
        printf 'PROJECT_ID=%q\n' "${project_id}"
        printf 'PROJECT_NAME=%q\n' "${project_name}"
        printf 'PROJECT_TYPE=%q\n' "${project_type}"
        printf 'PROJECT_DOCKERED=%q\n' "${project_dockered}"

        printf '\n'
        printf '# Git local\n'
        printf 'LOCAL_DEFAULT_BRANCH=%q\n' \
            "${local_default_branch}"
        printf 'GIT_USER_NAME=%q\n' \
            "${git_user_name}"
        printf 'GIT_USER_EMAIL=%q\n' \
            "${git_user_email}"

        printf '\n'
        printf '# Git distant\n'
        printf 'REMOTE_GIT_TYPE=%q\n' \
            "${remote_git_type}"
        printf 'REMOTE_BASE_URL=%q\n' \
            "${remote_base_url}"
        printf 'REMOTE_OWNER=%q\n' \
            "${remote_owner}"
        printf 'REMOTE_REPOSITORY=%q\n' \
            "${remote_repository}"
        printf 'REMOTE_NAME=%q\n' \
            "${remote_name}"
        printf 'REMOTE_DEFAULT_BRANCH=%q\n' \
            "${remote_default_branch}"
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


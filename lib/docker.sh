#!/usr/bin/env bash
# Fonctions génériques Docker

ensure_docker_image() {

	# Vérifie qu'une image Docker est disponible selon une politique
	# de mise à jour donnée.
	#
	# Paramètres :
	#   $1 : image Docker complète à vérifier.
	#        Exemple :
	#        ghcr.io/anomalyco/opencode:latest
	#
	#   $2 : politique de mise à jour facultative.
	#        Valeurs autorisées :
	#
	#        never
	#            Utilise l'image locale sans consulter le registre distant.
	#            Si l'image n'existe pas localement, elle est téléchargée.
	#
	#        check
	#            Compare le digest de l'image locale avec le digest publié
	#            dans le registre distant.
	#            L'image est téléchargée uniquement si les digests diffèrent.
	#
	#        always
	#            Exécute systématiquement docker pull.
	#            Docker ne télécharge que les couches absentes ou modifiées.
	#
	# Politique par défaut :
	#   Si le deuxième argument n'est pas fourni, la politique "check" est
	#   utilisée. Les appelants doivent fournir leur variable de politique.
	#
	#   Si cette variable globale est absente ou vide, la politique "check"
	#   est utilisée par défaut.
	#
	# Priorité de sélection de la politique :
	#   1. Deuxième argument passé à la fonction ;
	#   2. Valeur par défaut "check".
	#
	# Exemples :
	#
	#   Utilisation de la politique globale :
	#       ensure_docker_image "${DOCKER_IMAGE_OPENCODE}"
	#
	#   Utilisation forcée de la politique "always" :
	#       ensure_docker_image "${DOCKER_IMAGE_OPENCODE}" "always"
	#
	#   Utilisation forcée de la politique "never" :
	#       ensure_docker_image "${DOCKER_IMAGE_OPENCODE}" "never"
	#
	# Valeurs de retour :
	#   0 : image Docker disponible et utilisable ;
	#   1 : paramètre invalide, image indisponible ou erreur bloquante.

    local docker_image="${1:-}"
    local requested_policy="${2:-}"
    local update_policy=""
    local local_digest=""
    local remote_digest=""

    if [[ -z "${docker_image}" ]]; then
        echo "❌ Aucune image Docker n'a été indiquée."
        return 1
    fi

    # Le deuxième argument est prioritaire.
    # Si aucune politique n'est fournie, la valeur "check" est appliquée.
    update_policy="${requested_policy:-check}"

    case "${update_policy}" in
        never|check|always)
            ;;
        *)
            echo "❌ Politique de mise à jour Docker invalide :"
            echo "   ${update_policy}"
            echo
            echo "Valeurs autorisées : never, check, always"
            return 1
            ;;
    esac

    echo
    echo "=============================================="
    echo " Vérification de l'image Docker"
    echo "=============================================="
    echo
    echo "Image     : ${docker_image}"
    echo "Politique : ${update_policy}"

    # Vérifie si l'image est déjà présente localement.
    if ! su - "${ENV_DEVOPS_USER}" -c \
        "docker image inspect '${docker_image}' >/dev/null 2>&1"
    then
        echo
        echo "ℹ️ L'image n'est pas présente localement."
        echo "📥 Téléchargement de l'image..."

        if ! su - "${ENV_DEVOPS_USER}" -c \
            "docker pull '${docker_image}'"
        then
            echo
            echo "❌ Impossible de télécharger l'image :"
            echo "   ${docker_image}"
            return 1
        fi

        echo
        echo "✅ Image téléchargée avec succès."
        return 0
    fi

    case "${update_policy}" in
        never)
            echo
            echo "ℹ️ Vérification distante désactivée."
            echo "✅ Utilisation de l'image locale."
            return 0
            ;;

        always)
            echo
            echo "📥 Vérification et téléchargement de l'image..."

            if ! su - "${ENV_DEVOPS_USER}" -c \
                "docker pull '${docker_image}'"
            then
                echo
                echo "❌ Impossible de vérifier ou mettre à jour l'image."
                return 1
            fi

            echo
            echo "✅ Image Docker disponible et à jour."
            return 0
            ;;

        check)
            ;;
    esac

    # Récupère le premier digest associé à l'image locale.
    local_digest="$(
        su - "${ENV_DEVOPS_USER}" -c \
            "docker image inspect '${docker_image}' \
                --format '{{range .RepoDigests}}{{println .}}{{end}}'" \
            2>/dev/null |
        awk -F '@' 'NF == 2 { print $2; exit }'
    )"

    # Récupère le digest actuellement publié dans le registre distant.
    inspect_output=""

    if ! inspect_output="$(
        su - "${ENV_DEVOPS_USER}" -c \
            "docker buildx imagetools inspect '${docker_image}'"
    )"; then
        echo "⚠️ Impossible de vérifier l'image distante : ${docker_image}"
        return 1
    fi

    remote_digest="$(
        printf '%s\n' "${inspect_output}" |
            awk '/^Digest:/ { print $2; exit }'
    )"

    if [[ -z "${remote_digest}" ]]; then
        echo "⚠️ Digest distant introuvable : ${docker_image}"
        return 1
    fi

    echo
    echo "Digest local   : ${local_digest:-indisponible}"
    echo "Digest distant : ${remote_digest:-indisponible}"

    # Si le registre distant est inaccessible, l'image locale existante
    # reste utilisable.
    if [[ -z "${remote_digest}" ]]; then
        echo
        echo "⚠️ Impossible de vérifier le registre distant."
        echo "ℹ️ Utilisation de l'image locale existante."
        return 0
    fi

    # Aucun téléchargement n'est nécessaire lorsque les digests
    # local et distant sont identiques.
    if [[ -n "${local_digest}" ]] &&
       [[ "${local_digest}" == "${remote_digest}" ]]
    then
        echo
        echo "✅ L'image Docker locale est à jour."
        return 0
    fi

    echo
    echo "📥 Une nouvelle version de l'image est disponible."
    echo "   Mise à jour en cours..."

    if ! su - "${ENV_DEVOPS_USER}" -c \
        "docker pull '${docker_image}'"
    then
        echo
        echo "❌ La mise à jour de l'image Docker a échoué."
        return 1
    fi

    echo
    echo "✅ Image Docker mise à jour avec succès."

    return 0
}

docker_root_check_containers() {
    local containers
    local container
    local name
    local pid
    local uid
    local gid
    local config_user
    local process_users
    local image
    local status
    local health
    local restart_policy
    local privileged
    local readonly_rootfs
    local ip
    local cpu
    local memory
    local mounts_rw
    local mounts_ro

    local mount_type
    local mount_source
    local mount_destination
    local mount_rw
    local mount_uid
    local mount_gid
    local mount_owner
    local mount_mode
    local mount_user
    local mount_group
    local mount_status

    local container_count=0
    local root_pid1_count=0
    local root_only_count=0
    local mixed_root_count=0
    local non_root_count=0
    local privileged_count=0
    local socket_count=0
    local bind_count=0
    local bind_rw_count=0
    local bind_ro_count=0
    local bind_match_count=0
    local bind_check_count=0
    local bind_missing_count=0

    echo
    echo "=========================================================="
    echo " Analyse des conteneurs Docker"
    echo "=========================================================="
    echo

    # ----------------------------------------------------------
    # Vérification de Docker
    # ----------------------------------------------------------

    if ! command -v docker >/dev/null 2>&1; then
        echo "❌ Docker n'est pas installé."
        return 1
    fi

    if ! docker info >/dev/null 2>&1; then
        echo "❌ Le démon Docker n'est pas accessible."
        return 1
    fi

    # ----------------------------------------------------------
    # Recherche des conteneurs actifs
    # ----------------------------------------------------------

    containers="$(docker ps --quiet)"

    if [ -z "$containers" ]; then
        echo "ℹ️ Aucun conteneur Docker en cours d'exécution."
        return 0
    fi

    container_count="$(printf "%s\n" "$containers" | wc -l)"

    echo "Conteneurs actifs : $container_count"
    echo

    # ----------------------------------------------------------
    # Tableau principal
    # ----------------------------------------------------------

    printf "%-18s %-24s %-15s %-12s %-12s %-24s %-9s %-12s\n" \
        "CONTENEUR" \
        "IMAGE" \
        "ÉTAT" \
        "USER" \
        "PID1" \
        "UID:GID PROCESSUS" \
        "CPU" \
        "MÉMOIRE"

    printf "%-18s %-24s %-15s %-12s %-12s %-24s %-9s %-12s\n" \
        "------------------" \
        "------------------------" \
        "---------------" \
        "------------" \
        "------------" \
        "------------------------" \
        "---------" \
        "------------"

    for container in $containers; do

        # ------------------------------------------------------
        # Informations générales
        # ------------------------------------------------------

        name="$(
            docker inspect \
                --format '{{.Name}}' \
                "$container" 2>/dev/null |
            sed 's#^/##'
        )"

        image="$(
            docker inspect \
                --format '{{.Config.Image}}' \
                "$container" 2>/dev/null
        )"

        status="$(
            docker inspect \
                --format '{{.State.Status}}' \
                "$container" 2>/dev/null
        )"

        health="$(
            docker inspect \
                --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' \
                "$container" 2>/dev/null
        )"

        config_user="$(
            docker inspect \
                --format '{{.Config.User}}' \
                "$container" 2>/dev/null
        )"

        if [ -z "$config_user" ]; then
            config_user="default"
        fi

        # ------------------------------------------------------
        # PID 1
        # ------------------------------------------------------

        pid="$(
            docker inspect \
                --format '{{.State.Pid}}' \
                "$container" 2>/dev/null
        )"

        uid="?"
        gid="?"

        if [ -n "$pid" ] && \
           [ "$pid" != "0" ] && \
           [ -r "/proc/$pid/status" ]; then

            uid="$(
                awk '/^Uid:/ {print $2}' \
                    "/proc/$pid/status"
            )"

            gid="$(
                awk '/^Gid:/ {print $2}' \
                    "/proc/$pid/status"
            )"
        fi

        # ------------------------------------------------------
        # UID:GID de tous les processus
        # ------------------------------------------------------

        process_users="$(
            info_docker_analyse_container "$container"
        )"

        # ------------------------------------------------------
        # CPU
        # ------------------------------------------------------

        cpu="$(
            docker stats \
                --no-stream \
                --format '{{.CPUPerc}}' \
                "$container" 2>/dev/null
        )"

        if [ -z "$cpu" ]; then
            cpu="-"
        fi

        # ------------------------------------------------------
        # Mémoire
        # ------------------------------------------------------

        memory="$(
            docker stats \
                --no-stream \
                --format '{{.MemUsage}}' \
                "$container" 2>/dev/null |
            awk -F' / ' '{print $1}'
        )"

        if [ -z "$memory" ]; then
            memory="-"
        fi

        # ------------------------------------------------------
        # État + Healthcheck
        # ------------------------------------------------------

        if [ "$health" != "none" ]; then
            status="${status}/${health}"
        fi

        # ------------------------------------------------------
        # Affichage
        # ------------------------------------------------------

        printf "%-18s %-24.24s %-15s %-12s %-12s %-24s %-9s %-12s\n" \
            "$name" \
            "$image" \
            "$status" \
            "$config_user" \
            "${uid}:${gid}" \
            "$process_users" \
            "$cpu" \
            "$memory"
    done

    # ----------------------------------------------------------
    # Analyse détaillée
    # ----------------------------------------------------------

    echo
    echo "=========================================================="
    echo " Détails des conteneurs"
    echo "=========================================================="

    for container in $containers; do

        name="$(
            docker inspect \
                --format '{{.Name}}' \
                "$container" |
            sed 's#^/##'
        )"

        image="$(
            docker inspect \
                --format '{{.Config.Image}}' \
                "$container"
        )"

        pid="$(
            docker inspect \
                --format '{{.State.Pid}}' \
                "$container"
        )"

        config_user="$(
            docker inspect \
                --format '{{.Config.User}}' \
                "$container"
        )"

        if [ -z "$config_user" ]; then
            config_user="non défini"
        fi

        uid="?"
        gid="?"

        if [ "$pid" != "0" ] && \
           [ -r "/proc/$pid/status" ]; then

            uid="$(
                awk '/^Uid:/ {print $2}' \
                    "/proc/$pid/status"
            )"

            gid="$(
                awk '/^Gid:/ {print $2}' \
                    "/proc/$pid/status"
            )"
        fi

        process_users="$(
            info_docker_analyse_container "$container"
        )"

        restart_policy="$(
            docker inspect \
                --format '{{.HostConfig.RestartPolicy.Name}}' \
                "$container"
        )"

        privileged="$(
            docker inspect \
                --format '{{.HostConfig.Privileged}}' \
                "$container"
        )"

        readonly_rootfs="$(
            docker inspect \
                --format '{{.HostConfig.ReadonlyRootfs}}' \
                "$container"
        )"

        ip="$(
            docker inspect \
                --format '{{range .NetworkSettings.Networks}}{{.IPAddress}} {{end}}' \
                "$container"
        )"

        mounts_rw="$(
            docker inspect \
                --format '{{range .Mounts}}{{if .RW}}1 {{end}}{{end}}' \
                "$container" |
            wc -w
        )"

        mounts_ro="$(
            docker inspect \
                --format '{{range .Mounts}}{{if not .RW}}1 {{end}}{{end}}' \
                "$container" |
            wc -w
        )"

        echo
        echo "----------------------------------------------------------"
        echo " $name"
        echo "----------------------------------------------------------"

        echo "Image                 : $image"
        echo "PID hôte              : $pid"
        echo "Utilisateur Docker    : $config_user"
        echo "UID:GID PID 1         : ${uid}:${gid}"
        echo "UID:GID processus     : $process_users"
        echo "Adresse(s) IP         : ${ip:-aucune}"
        echo "Restart policy        : ${restart_policy:-none}"
        echo "Privileged            : $privileged"
        echo "RootFS read-only      : $readonly_rootfs"
        echo "Volumes RW            : $mounts_rw"
        echo "Volumes RO            : $mounts_ro"

        # ------------------------------------------------------
        # Analyse UID / GID
        # ------------------------------------------------------

        if [ "$uid" = "0" ]; then
            root_pid1_count=$((root_pid1_count + 1))

            if [ "$process_users" = "0:0" ]; then
                echo
                echo "⚠️ Tous les processus détectés fonctionnent en root."

                root_only_count=$((root_only_count + 1))

            elif printf "%s\n" "$process_users" |
                 grep -Eq '(^|,)0:0(,|$)'; then

                echo
                echo "ℹ️ PID 1 en root avec processus non-root."
                echo "   Utilisateurs détectés : $process_users"

                mixed_root_count=$((mixed_root_count + 1))

            else
                echo
                echo "ℹ️ PID 1 en root."
                echo "   Utilisateurs détectés : $process_users"

                mixed_root_count=$((mixed_root_count + 1))
            fi

        else
            non_root_count=$((non_root_count + 1))
        fi

        # ------------------------------------------------------
        # Analyse privileged
        # ------------------------------------------------------

        if [ "$privileged" = "true" ]; then
            echo
            echo "⚠️ Conteneur exécuté en mode privileged."

            privileged_count=$((privileged_count + 1))
        fi

        # ------------------------------------------------------
        # Analyse Docker Socket
        # ------------------------------------------------------

        if docker inspect \
            --format '{{range .Mounts}}{{println .Source}}{{end}}' \
            "$container" |
            grep -qx '/var/run/docker.sock'; then

            echo
            echo "⚠️ Accès direct au socket Docker détecté."

            socket_count=$((socket_count + 1))
        fi

        # ------------------------------------------------------
        # Montages
        # ------------------------------------------------------

        echo
        echo "Montages :"

        docker inspect \
            --format '{{range .Mounts}}{{printf "  %-6s %-45s -> %-35s RW=%v\n" .Type .Source .Destination .RW}}{{end}}' \
            "$container"

        # ------------------------------------------------------
        # Inspection des bind mounts sur l'hôte
        # ------------------------------------------------------

        echo
        echo "Bind mounts - propriétaires sur l'hôte :"

        while IFS='|' read -r \
            mount_type \
            mount_source \
            mount_destination \
            mount_rw
        do

        if [ "$mount_type" != "bind" ]; then
            continue
        fi

        bind_count=$((bind_count + 1))

        if [ "$mount_rw" = "true" ]; then
            bind_rw_count=$((bind_rw_count + 1))
        else
            bind_ro_count=$((bind_ro_count + 1))
        fi

        echo
        echo "  Source      : $mount_source"
        echo "  Destination : $mount_destination"
        echo "  Lecture/écr.: $mount_rw"

        if [ ! -e "$mount_source" ]; then
            echo "  Propriétaire: introuvable"
            echo "  État        : ⚠️ chemin absent sur l'hôte"

            bind_missing_count=$((bind_missing_count + 1))
            continue
        fi

        mount_uid="$(stat -c '%u' "$mount_source" 2>/dev/null)"
        mount_gid="$(stat -c '%g' "$mount_source" 2>/dev/null)"
        mount_user="$(stat -c '%U' "$mount_source" 2>/dev/null)"
        mount_group="$(stat -c '%G' "$mount_source" 2>/dev/null)"
        mount_mode="$(stat -c '%a' "$mount_source" 2>/dev/null)"

        mount_owner="${mount_uid}:${mount_gid}"

        echo "  UID:GID hôte: $mount_owner"
        echo "  User:Group  : ${mount_user}:${mount_group}"
        echo "  Permissions : $mount_mode"

        # --------------------------------------------------
        # Comparaison avec les processus du conteneur
        # --------------------------------------------------
        if printf "%s\n" "$process_users" |
           grep -Eq "(^|,)${mount_uid}:${mount_gid}(,|$)"; then

            mount_status="OK"

            echo "  État        : ✅ UID:GID présent dans le conteneur"

            bind_match_count=$((bind_match_count + 1))

        elif printf "%s\n" "$process_users" |
             grep -Eq '(^|,)0:0(,|$)'; then

            mount_status="ROOT"

            echo "  État        : ℹ️ processus root - UID:GID hôte différent accepté"
            echo "                Processus : $process_users"

        elif [ "$mount_rw" = "true" ]; then

            mount_status="CHECK"

            echo "  État        : ⚠️ propriétaire différent des UID:GID détectés"
            echo "                Processus : $process_users"

            bind_check_count=$((bind_check_count + 1))

        else

            mount_status="RO"

            echo "  État        : ℹ️ montage en lecture seule"
            echo "                Correspondance UID:GID non requise"
        fi

        done < <(
            docker inspect \
                --format '{{range .Mounts}}{{printf "%s|%s|%s|%v\n" .Type .Source .Destination .RW}}{{end}}' \
                "$container"
        )

        # ------------------------------------------------------
        # Ports
        # ------------------------------------------------------

        echo
        echo "Ports :"

        docker port "$container" 2>/dev/null |
            sed 's/^/  /'
    done

    # ----------------------------------------------------------
    # Résumé
    # ----------------------------------------------------------

    echo
    echo "=========================================================="
    echo " Résumé"
    echo "=========================================================="
    echo

    echo "Conteneurs actifs                 : $container_count"
    echo "PID 1 exécutés en UID 0           : $root_pid1_count"
    echo "Uniquement processus root         : $root_only_count"
    echo "Root + processus non-root         : $mixed_root_count"
    echo "PID 1 non-root                    : $non_root_count"
    echo "Conteneurs privileged             : $privileged_count"
    echo "Accès direct au socket Docker     : $socket_count"

    echo
    echo "Bind mounts                       : $bind_count"
    echo "Bind mounts RW                    : $bind_rw_count"
    echo "Bind mounts RO                    : $bind_ro_count"
    echo "UID:GID correspondant             : $bind_match_count"
    echo "Bind mounts RW à vérifier         : $bind_check_count"
    echo "Chemins hôte absents              : $bind_missing_count"

    echo
    echo "✅ Analyse Docker terminée."
    echo
}

docker_root_diag() {

    ###############################################################################
    # ANALYSE DOCKER ROOT
    #
    # Diagnostic complet de Docker Rootful pour un utilisateur.
    #
    # Usage :
    #   analyse_docker_root <USERNAME>
    #
    # Cette fonction :
    #   - ne modifie pas la configuration ;
    #   - ne démarre / arrête pas Docker ;
    #   - détecte d'abord si Docker Rootful est disponible ;
    #   - inspecte l'identité UNIX ;
    #   - inspecte le groupe docker ;
    #   - inspecte le socket Docker ;
    #   - inspecte le service Docker système ;
    #   - inspecte la configuration systemd ;
    #   - inspecte le contexte Docker ;
    #   - inspecte DOCKER_HOST ;
    #   - inspecte docker version ;
    #   - inspecte docker info ;
    #   - inspecte le mode Rootful ;
    #   - inspecte le Docker Root Dir ;
    #   - inspecte les processus ;
    #   - inspecte les cgroups ;
    #   - inspecte le réseau ;
    #   - réalise des tests fonctionnels ;
    #   - affiche les journaux utiles en cas d'anomalie.
    #
    # IMPORTANT :
    #   Cette fonction est purement diagnostique.
    #   Une commande en échec ne doit jamais interrompre l'analyse.
    #
    # Résultats :
    #   0 = non disponible ou opérationnel
    #   1 = anomalies détectées
    #   2 = paramètre ou utilisateur invalide
    ###############################################################################

    local username="${1:-}"

    local uid=""
    local gid=""
    local groups=""
    local home=""
    local shell=""

    local docker_socket="/run/docker.sock"
    local docker_host="unix://${docker_socket}"

    local service_state=""
    local service_enabled=""

    local docker_context=""
    local docker_version=""
    local docker_info=""
    local docker_root=""

    local errors=0
    local warnings=0

    # -------------------------------------------------------------------------
    # Paramètre
    # -------------------------------------------------------------------------

    if [[ -z "$username" ]]; then
        echo "❌ Utilisateur manquant."
        echo "Usage : analyse_docker_root <USERNAME>"
        return 2
    fi

    # -------------------------------------------------------------------------
    # Utilisateur
    # -------------------------------------------------------------------------

    if ! id "$username" >/dev/null 2>&1; then
        echo "❌ Utilisateur inexistant : $username"
        return 2
    fi

    uid="$(id -u "$username" 2>/dev/null || true)"
    gid="$(id -g "$username" 2>/dev/null || true)"
    groups="$(id -Gn "$username" 2>/dev/null || true)"
    home="$(getent passwd "$username" | cut -d: -f6)"
    shell="$(getent passwd "$username" | cut -d: -f7)"

    # -------------------------------------------------------------------------
    # Détection préalable Docker Rootful
    # -------------------------------------------------------------------------
    #
    # Docker Rootful est un daemon système.
    #
    # Le socket système constitue ici l'indicateur principal de présence
    # du daemon Docker Rootful.
    # -------------------------------------------------------------------------

    if [[ ! -S "$docker_socket" ]]; then

        echo
        echo "=============================================================="
        echo " Docker Root"
        echo "=============================================================="
        echo
        echo "Utilisateur : $username"
        echo
        echo "Docker Root non disponible sur le système."
        echo

        return 0
    fi

    # -------------------------------------------------------------------------
    # En-tête
    # -------------------------------------------------------------------------

    echo
    echo "=============================================================="
    echo " Analyse Docker Root"
    echo "=============================================================="
    echo
    echo "USER        : $username"
    echo "UID         : $uid"
    echo "GID         : $gid"
    echo "GROUPES     : $groups"
    echo "HOME        : $home"
    echo "SHELL       : $shell"
    echo "DOCKER HOST : $docker_host"
    echo

    # -------------------------------------------------------------------------
    # Identité UNIX
    # -------------------------------------------------------------------------

    echo "▶ Identité UNIX"

    local home_uid=""
    local home_gid=""

    home_uid="$(stat -c '%u' "$home" 2>/dev/null || true)"
    home_gid="$(stat -c '%g' "$home" 2>/dev/null || true)"

    if [[ "$home_uid" == "$uid" ]]; then
        echo "✓ HOME owner UID : $home_uid"
    else
        echo "❌ HOME owner UID incorrect : ${home_uid:-inconnu}"
        errors=$((errors + 1))
    fi

    if [[ "$home_gid" == "$gid" ]]; then
        echo "✓ HOME owner GID : $home_gid"
    else
        echo "⚠ HOME owner GID : ${home_gid:-inconnu}"
        warnings=$((warnings + 1))
    fi

    echo "  UID     : $uid"
    echo "  GID     : $gid"
    echo "  Groupes : $groups"

    # -------------------------------------------------------------------------
    # Groupe Docker
    # -------------------------------------------------------------------------

    echo
    echo "▶ Groupe Docker"

    if id -nG "$username" 2>/dev/null \
        | tr ' ' '\n' \
        | grep -qx 'docker'
    then
        echo "✓ Utilisateur membre du groupe docker"
    else
        echo "❌ Utilisateur absent du groupe docker"
        errors=$((errors + 1))
    fi

    # -------------------------------------------------------------------------
    # Docker service
    # -------------------------------------------------------------------------

    echo
    echo "▶ Docker service"

    service_state="$(
        systemctl is-active docker.service 2>/dev/null || true
    )"

    service_enabled="$(
        systemctl is-enabled docker.service 2>/dev/null || true
    )"

    if [[ "$service_state" == "active" ]]; then
        echo "✓ docker.service active"
    else
        echo "❌ docker.service : ${service_state:-unknown}"
        errors=$((errors + 1))
    fi

    if [[ "$service_enabled" == "enabled" ]]; then
        echo "✓ docker.service enabled"
    else
        echo "⚠ docker.service : ${service_enabled:-unknown}"
        warnings=$((warnings + 1))
    fi

    # -------------------------------------------------------------------------
    # Configuration systemd Docker
    # -------------------------------------------------------------------------

    echo
    echo "▶ Configuration systemd Docker"

    systemctl show docker.service \
        -p FragmentPath \
        -p DropInPaths \
        -p ExecStart \
        -p Type \
        -p NotifyAccess \
        -p User \
        -p Group \
        -p SupplementaryGroups \
        -p Delegate \
        -p TasksMax \
        -p LimitNOFILE \
        2>/dev/null || true

    # -------------------------------------------------------------------------
    # Docker socket
    # -------------------------------------------------------------------------

    echo
    echo "▶ Docker socket"

    if [[ -S "$docker_socket" ]]; then

        echo "✓ Socket présent"

        stat -c \
            '  %n : %u:%g %a %A' \
            "$docker_socket" \
            2>/dev/null || true

    else

        echo "❌ Socket absent : $docker_socket"
        errors=$((errors + 1))

    fi

    # -------------------------------------------------------------------------
    # Docker CLI / contexte
    # -------------------------------------------------------------------------

    echo
    echo "▶ Docker CLI"

    docker_context="$(
        runuser -u "$username" -- \
            env \
                DOCKER_HOST="$docker_host" \
            docker context show \
            2>/dev/null || true
    )"

    if [[ -n "$docker_context" ]]; then
        echo "Context : $docker_context"
    else
        echo "❌ Impossible de déterminer le contexte Docker"
        errors=$((errors + 1))
    fi

    echo
    echo "DOCKER_HOST : $docker_host"

    # -------------------------------------------------------------------------
    # Docker version
    # -------------------------------------------------------------------------

    echo
    echo "▶ Docker version"

    docker_version="$(
        runuser -u "$username" -- \
            env \
                DOCKER_HOST="$docker_host" \
            docker version \
            2>&1 || true
    )"

    if [[ -n "$docker_version" ]]; then
        echo "$docker_version"
    else
        echo "❌ docker version : aucune réponse"
        errors=$((errors + 1))
    fi

    # -------------------------------------------------------------------------
    # Docker info
    # -------------------------------------------------------------------------

    echo
    echo "▶ Docker info"

    docker_info="$(
        runuser -u "$username" -- \
            env \
                DOCKER_HOST="$docker_host" \
            docker info \
            2>&1 || true
    )"

    if [[ -n "$docker_info" ]]; then
        echo "$docker_info"
    else
        echo "❌ docker info : aucune réponse"
        errors=$((errors + 1))
    fi

    # -------------------------------------------------------------------------
    # Rootful validation
    # -------------------------------------------------------------------------

    echo
    echo "▶ Rootful validation"

    if grep -qE '^[[:space:]]*rootless$' <<< "$docker_info"; then

        echo "❌ Docker Rootless détecté"
        errors=$((errors + 1))

    elif [[ -n "$docker_info" ]]; then

        echo "✓ Docker Rootful actif"

    else

        echo "❌ Mode Docker indéterminé"
        errors=$((errors + 1))

    fi

    # -------------------------------------------------------------------------
    # Docker Root Dir
    # -------------------------------------------------------------------------

    echo
    echo "▶ Docker Root Dir"

    docker_root="$(
        sed -n 's/^ Docker Root Dir: //p' <<< "$docker_info"
    )"

    if [[ -n "$docker_root" ]]; then

        echo "Docker Root Dir : $docker_root"

        if [[ "$docker_root" == "/var/lib/docker" ]]; then
            echo "✓ Docker Root Dir standard"
        else
            echo "⚠ Docker Root Dir personnalisé"
            warnings=$((warnings + 1))
        fi

    else

        echo "❌ Docker Root Dir indéterminé"
        errors=$((errors + 1))

    fi

    # -------------------------------------------------------------------------
    # Processus Docker
    # -------------------------------------------------------------------------

    echo
    echo "▶ Processus Docker"

    ps -eo \
        user,pid,ppid,stat,etime,cmd \
        2>/dev/null \
        | grep -E \
            "(dockerd|containerd)" \
        | grep -v grep \
        || true

    # -------------------------------------------------------------------------
    # Cgroups
    # -------------------------------------------------------------------------

    echo
    echo "▶ Cgroups"

    if [[ -n "$docker_info" ]]; then

        grep -E \
            "Cgroup Driver|Cgroup Version|Security Options" \
            <<< "$docker_info" \
            || true

    else

        echo "❌ Informations Cgroup indisponibles"
        warnings=$((warnings + 1))

    fi

    # -------------------------------------------------------------------------
    # Réseau Docker
    # -------------------------------------------------------------------------

    echo
    echo "▶ Réseau Docker"

    echo
    echo "Interfaces :"

    ip addr 2>/dev/null \
        | sed -n '1,80p' \
        || true

    echo
    echo "Routes :"

    ip route 2>/dev/null || true

    # -------------------------------------------------------------------------
    # Test fonctionnel Docker
    # -------------------------------------------------------------------------

    echo
    echo "▶ Test fonctionnel Docker"

    if runuser -u "$username" -- \
        env \
            DOCKER_HOST="$docker_host" \
        docker run --rm hello-world \
        >/dev/null 2>&1
    then

        echo "✓ docker run hello-world"

    else

        echo "❌ docker run hello-world"
        errors=$((errors + 1))

    fi

    # -------------------------------------------------------------------------
    # Test réseau conteneur
    # -------------------------------------------------------------------------

    echo
    echo "▶ Test réseau conteneur"

    if runuser -u "$username" -- \
        env \
            DOCKER_HOST="$docker_host" \
        docker run --rm busybox \
            sh -c 'wget -qO- https://example.com >/dev/null' \
        >/dev/null 2>&1
    then

        echo "✓ Réseau conteneur opérationnel"

    else

        echo "⚠ Test réseau conteneur échoué"
        warnings=$((warnings + 1))

    fi

    # -------------------------------------------------------------------------
    # Diagnostic journal
    # -------------------------------------------------------------------------

    echo
    echo "▶ Journal Docker Root"

    journalctl \
        -u docker.service \
        -n 30 \
        --no-pager \
        -o cat \
        2>/dev/null \
        || true

    # -------------------------------------------------------------------------
    # Résultat
    # -------------------------------------------------------------------------

    echo
    echo "=============================================================="
    echo " Résultat"
    echo "=============================================================="

    echo
    echo "Utilisateur : $username"
    echo "Erreurs     : $errors"
    echo "Warnings    : $warnings"

    if (( errors == 0 )); then

        echo
        echo "DOCKER ROOT ${username} : OPÉRATIONNEL ✅"

        if (( warnings > 0 )); then
            echo "⚠ ${warnings} warning(s) détecté(s)."
        fi

        return 0

    fi

    echo
    echo "DOCKER ROOT ${username} : ANOMALIES DÉTECTÉES ❌"

    return 1
}

docker_root_test() {

    ###############################################################################
    # TEST DOCKER ROOT
    #
    # Test fonctionnel de Docker Rootful pour un utilisateur.
    #
    # Usage :
    #   test_docker_root <USERNAME>
    #
    # Cette fonction :
    #   - ne modifie pas la configuration ;
    #   - ne démarre / arrête pas Docker ;
    #   - vérifie que Docker système est disponible ;
    #   - vérifie l'accès de l'utilisateur au socket Docker ;
    #   - vérifie le mode Rootful ;
    #   - réalise un test fonctionnel docker run ;
    #
    # Résultats :
    #   0 = test réussi ou Docker Root non configuré pour cet utilisateur
    #   1 = test échoué
    #   2 = paramètre ou utilisateur invalide
    ###############################################################################

    local username="${1:-}"

    local uid=""
    local gid=""
    local groups=""
    local home=""
    local docker_socket="/run/docker.sock"
    local docker_host="unix://${docker_socket}"
    local docker_info=""

    # -------------------------------------------------------------------------
    # Paramètre
    # -------------------------------------------------------------------------

    if [[ -z "$username" ]]; then
        echo "❌ Utilisateur manquant."
        echo "Usage : test_docker_root <USERNAME>"
        return 2
    fi

    # -------------------------------------------------------------------------
    # Utilisateur
    # -------------------------------------------------------------------------

    if ! id "$username" >/dev/null 2>&1; then
        echo "❌ Utilisateur inexistant : $username"
        return 2
    fi

    uid="$(id -u "$username" 2>/dev/null || true)"
    gid="$(id -g "$username" 2>/dev/null || true)"
    groups="$(id -Gn "$username" 2>/dev/null || true)"
    home="$(getent passwd "$username" | cut -d: -f6)"

    # -------------------------------------------------------------------------
    # Détection Docker Rootful
    # -------------------------------------------------------------------------

    if [[ ! -S "$docker_socket" ]]; then

        echo
        echo "=============================================================="
        echo " Docker Root"
        echo "=============================================================="
        echo
        echo "Utilisateur : $username"
        echo
        echo "Docker Root non disponible sur le système."
        echo

        return 0
    fi

    # -------------------------------------------------------------------------
    # En-tête
    # -------------------------------------------------------------------------

    echo
    echo "=============================================================="
    echo " Test Docker Root"
    echo "=============================================================="
    echo
    echo "Utilisateur : $username"
    echo "UID         : $uid"
    echo "GID         : $gid"
    echo "Groupes     : $groups"
    echo "HOME        : $home"
    echo "DOCKER HOST : $docker_host"
    echo

    # -------------------------------------------------------------------------
    # Groupe Docker
    # -------------------------------------------------------------------------

    echo "▶ Accès Docker"

    if id -nG "$username" 2>/dev/null \
        | tr ' ' '\n' \
        | grep -qx 'docker'
    then
        echo "✓ Groupe docker"
    else
        echo "❌ Utilisateur absent du groupe docker"
        return 1
    fi

    # -------------------------------------------------------------------------
    # Socket
    # -------------------------------------------------------------------------

    if [[ -S "$docker_socket" ]]; then
        echo "✓ Socket Docker présent"
    else
        echo "❌ Socket Docker absent"
        return 1
    fi

    # -------------------------------------------------------------------------
    # Docker info
    # -------------------------------------------------------------------------

    echo
    echo "▶ Docker"

    docker_info="$(
        runuser -u "$username" -- \
            env \
                DOCKER_HOST="$docker_host" \
            docker info 2>&1 || true
    )"

    if [[ -z "$docker_info" ]]; then
        echo "❌ Docker inaccessible"
        return 1
    fi

    if grep -qE '^[[:space:]]*rootless$' <<< "$docker_info"; then
        echo "❌ Docker est Rootless"
        return 1
    fi

    echo "✓ Docker Rootful accessible"

    # -------------------------------------------------------------------------
    # Test fonctionnel
    # -------------------------------------------------------------------------

    echo
    echo "▶ Test fonctionnel"

    if runuser -u "$username" -- \
        env \
            DOCKER_HOST="$docker_host" \
        docker run --rm hello-world \
        >/dev/null 2>&1
    then
        echo "✓ docker run hello-world"
    else
        echo "❌ docker run hello-world"
        return 1
    fi

    echo
    echo "DOCKER ROOT ${username} : OPÉRATIONNEL ✅"

    return 0
}

docker_rootless_diag() {

    ###############################################################################
    # ANALYSE DOCKER ROOTLESS
    #
    # Diagnostic complet de Docker Rootless pour un utilisateur.
    #
    # Usage :
    #   analyse_docker_rootless <USERNAME>
    #
    # Cette fonction :
    #   - ne modifie pas la configuration ;
    #   - ne démarre / arrête pas Docker ;
    #   - détecte d'abord si Docker Rootless est configuré ;
    #   - inspecte l'identité UNIX ;
    #   - inspecte SUBUID/SUBGID ;
    #   - inspecte les outils Rootless ;
    #   - inspecte systemd user ;
    #   - inspecte le lingering ;
    #   - inspecte XDG_RUNTIME_DIR ;
    #   - inspecte les permissions ;
    #   - inspecte le socket Docker ;
    #   - inspecte le service Docker ;
    #   - inspecte le contexte Docker ;
    #   - inspecte DOCKER_HOST ;
    #   - inspecte docker version ;
    #   - inspecte docker info ;
    #   - inspecte le mode Rootless ;
    #   - inspecte le Docker Root Dir ;
    #   - inspecte les processus ;
    #   - inspecte les cgroups ;
    #   - inspecte le réseau ;
    #   - réalise des tests fonctionnels ;
    #   - affiche les journaux utiles en cas d'anomalie.
    #
    # IMPORTANT :
    #   Cette fonction est purement diagnostique.
    #   Une commande en échec ne doit jamais interrompre l'analyse.
    #
    # Résultats :
    #   0 = non configuré ou opérationnel
    #   1 = anomalies détectées
    #   2 = paramètre ou utilisateur invalide
    ###############################################################################

    local username="${1:-}"

    local uid=""
    local gid=""
    local groups=""
    local home=""
    local shell=""
    local runtime_dir=""
    local docker_host=""
    local docker_socket=""
    local rootless_service=""

    local linger=""
    local user_manager=""
    local service_state=""
    local service_enabled=""

    local subuid=""
    local subgid=""

    local docker_context=""
    local docker_version=""
    local docker_info=""
    local docker_root=""

    local rootlesskit_version=""
    local newuidmap_version=""
    local newgidmap_version=""

    local errors=0
    local warnings=0

    # -------------------------------------------------------------------------
    # Paramètre
    # -------------------------------------------------------------------------

    if [[ -z "$username" ]]; then
        echo "❌ Utilisateur manquant."
        echo "Usage : analyse_docker_rootless <USERNAME>"
        return 2
    fi

    # -------------------------------------------------------------------------
    # Utilisateur
    # -------------------------------------------------------------------------

    if ! id "$username" >/dev/null 2>&1; then
        echo "❌ Utilisateur inexistant : $username"
        return 2
    fi

    uid="$(id -u "$username" 2>/dev/null || true)"
    gid="$(id -g "$username" 2>/dev/null || true)"
    groups="$(id -Gn "$username" 2>/dev/null || true)"
    home="$(getent passwd "$username" | cut -d: -f6)"
    shell="$(getent passwd "$username" | cut -d: -f7)"

    runtime_dir="/run/user/$uid"
    docker_socket="${runtime_dir}/docker.sock"
    docker_host="unix://${docker_socket}"

    # -------------------------------------------------------------------------
    # Détection préalable Docker Rootless
    # -------------------------------------------------------------------------
    #
    # Les outils rootless et les SUBUID/SUBGID sont des prérequis système
    # et ne permettent pas de déterminer si Docker Rootless est configuré
    # pour cet utilisateur.
    #
    # La présence du service systemd utilisateur Docker constitue ici
    # l'indicateur de configuration Rootless.
    # -------------------------------------------------------------------------

    rootless_service="${home}/.config/systemd/user/docker.service"

    if [[ ! -f "$rootless_service" ]]; then

        echo
        echo "=============================================================="
        echo " Docker Rootless"
        echo "=============================================================="
        echo
        echo "Utilisateur : $username"
        echo
        echo "Docker Rootless non configuré pour cet utilisateur."
        echo

        return 0
    fi

    # -------------------------------------------------------------------------
    # En-tête
    # -------------------------------------------------------------------------

    echo
    echo "=============================================================="
    echo " Analyse Docker Rootless"
    echo "=============================================================="
    echo
    echo "USER       : $username"
    echo "UID        : $uid"
    echo "GID        : $gid"
    echo "GROUPES    : $groups"
    echo "HOME       : $home"
    echo "SHELL      : $shell"
    echo "RUNTIME    : $runtime_dir"
    echo "DOCKER HOST : $docker_host"
    echo

    # -------------------------------------------------------------------------
    # Identité UNIX
    # -------------------------------------------------------------------------

    echo "▶ Identité UNIX"

    local home_uid=""
    local home_gid=""

    home_uid="$(stat -c '%u' "$home" 2>/dev/null || true)"
    home_gid="$(stat -c '%g' "$home" 2>/dev/null || true)"

    if [[ "$home_uid" == "$uid" ]]; then
        echo "✓ HOME owner UID : $home_uid"
    else
        echo "❌ HOME owner UID incorrect : ${home_uid:-inconnu}"
        errors=$((errors + 1))
    fi

    if [[ "$home_gid" == "$gid" ]]; then
        echo "✓ HOME owner GID : $home_gid"
    else
        echo "⚠ HOME owner GID : ${home_gid:-inconnu}"
        warnings=$((warnings + 1))
    fi

    echo "  UID     : $uid"
    echo "  GID     : $gid"
    echo "  Groupes : $groups"

    # -------------------------------------------------------------------------
    # SUBUID / SUBGID
    # -------------------------------------------------------------------------

    echo
    echo "▶ SUBUID / SUBGID"

    subuid="$(grep -E "^${username}:" /etc/subuid 2>/dev/null || true)"
    subgid="$(grep -E "^${username}:" /etc/subgid 2>/dev/null || true)"

    if [[ -n "$subuid" ]]; then
        echo "✓ SUBUID : $subuid"
    else
        echo "❌ SUBUID absent"
        errors=$((errors + 1))
    fi

    if [[ -n "$subgid" ]]; then
        echo "✓ SUBGID : $subgid"
    else
        echo "❌ SUBGID absent"
        errors=$((errors + 1))
    fi

    # -------------------------------------------------------------------------
    # Rootless tools
    # -------------------------------------------------------------------------

    echo
    echo "▶ Rootless tools"

    if command -v rootlesskit >/dev/null 2>&1; then

        rootlesskit_version="$(
            rootlesskit --version 2>&1 || true
        )"

        rootlesskit_version="${rootlesskit_version%%$'\n'*}"

        echo "✓ rootlesskit : ${rootlesskit_version:-version inconnue}"

    else

        echo "❌ rootlesskit absent"
        errors=$((errors + 1))

    fi

    if command -v newuidmap >/dev/null 2>&1; then

        newuidmap_version="$(
            newuidmap --version 2>&1 || true
        )"

        newuidmap_version="${newuidmap_version%%$'\n'*}"

        echo "✓ newuidmap : ${newuidmap_version:-version inconnue}"

    else

        echo "❌ newuidmap absent"
        errors=$((errors + 1))

    fi

    if command -v newgidmap >/dev/null 2>&1; then

        newgidmap_version="$(
            newgidmap --version 2>&1 || true
        )"

        newgidmap_version="${newgidmap_version%%$'\n'*}"

        echo "✓ newgidmap : ${newgidmap_version:-version inconnue}"

    else

        echo "❌ newgidmap absent"
        errors=$((errors + 1))

    fi

    if command -v dockerd-rootless.sh >/dev/null 2>&1; then
        echo "✓ dockerd-rootless.sh : $(command -v dockerd-rootless.sh)"
    else
        echo "❌ dockerd-rootless.sh absent"
        errors=$((errors + 1))
    fi

    # -------------------------------------------------------------------------
    # Systemd lingering
    # -------------------------------------------------------------------------

    echo
    echo "▶ Systemd lingering"

    linger="$(
        loginctl show-user "$username" -p Linger --value 2>/dev/null || true
    )"

    if [[ "$linger" == "yes" ]]; then
        echo "✓ Linger=yes"
    else
        echo "❌ Linger=${linger:-unknown}"
        errors=$((errors + 1))
    fi

    # -------------------------------------------------------------------------
    # User Manager
    # -------------------------------------------------------------------------

    echo
    echo "▶ User Manager"

    user_manager="$(
        systemctl is-active "user@${uid}.service" 2>/dev/null || true
    )"

    if [[ "$user_manager" == "active" ]]; then
        echo "✓ user@${uid}.service active"
    else
        echo "❌ user@${uid}.service : ${user_manager:-unknown}"
        errors=$((errors + 1))
    fi

    # -------------------------------------------------------------------------
    # Runtime utilisateur
    # -------------------------------------------------------------------------

    echo
    echo "▶ Runtime utilisateur"

    if [[ -d "$runtime_dir" ]]; then

        echo "✓ Runtime présent : $runtime_dir"

        stat -c \
            '  %n : %u:%g %a %A' \
            "$runtime_dir" \
            2>/dev/null || true

    else

        echo "❌ Runtime absent : $runtime_dir"
        errors=$((errors + 1))

    fi

    # -------------------------------------------------------------------------
    # Docker service
    # -------------------------------------------------------------------------

    echo
    echo "▶ Docker service"

    service_state="$(
        runuser -u "$username" -- \
            env \
                XDG_RUNTIME_DIR="$runtime_dir" \
                DBUS_SESSION_BUS_ADDRESS="unix:path=${runtime_dir}/bus" \
            systemctl --user is-active docker.service \
            2>/dev/null || true
    )"

    service_enabled="$(
        runuser -u "$username" -- \
            env \
                XDG_RUNTIME_DIR="$runtime_dir" \
                DBUS_SESSION_BUS_ADDRESS="unix:path=${runtime_dir}/bus" \
            systemctl --user is-enabled docker.service \
            2>/dev/null || true
    )"

    if [[ "$service_state" == "active" ]]; then
        echo "✓ docker.service active"
    else
        echo "❌ docker.service : ${service_state:-unknown}"
        errors=$((errors + 1))
    fi

    if [[ "$service_enabled" == "enabled" ]]; then
        echo "✓ docker.service enabled"
    else
        echo "⚠ docker.service : ${service_enabled:-unknown}"
        warnings=$((warnings + 1))
    fi

    # -------------------------------------------------------------------------
    # Service details
    # -------------------------------------------------------------------------

    echo
    echo "▶ Configuration systemd Docker"

    runuser -u "$username" -- \
        env \
            XDG_RUNTIME_DIR="$runtime_dir" \
            DBUS_SESSION_BUS_ADDRESS="unix:path=${runtime_dir}/bus" \
        systemctl --user show docker.service \
            -p FragmentPath \
            -p DropInPaths \
            -p ExecStart \
            -p Type \
            -p NotifyAccess \
            -p User \
            -p Group \
            -p SupplementaryGroups \
            -p Delegate \
            -p TasksMax \
            -p LimitNOFILE \
        2>/dev/null || true

    # -------------------------------------------------------------------------
    # Socket Docker
    # -------------------------------------------------------------------------

    echo
    echo "▶ Docker socket"

    if [[ -S "$docker_socket" ]]; then

        echo "✓ Socket présent"

        stat -c \
            '  %n : %u:%g %a %A' \
            "$docker_socket" \
            2>/dev/null || true

    else

        echo "❌ Socket absent : $docker_socket"
        errors=$((errors + 1))

    fi

    # -------------------------------------------------------------------------
    # Runtime Docker
    # -------------------------------------------------------------------------

    echo
    echo "▶ Docker runtime tree"

    if [[ -d "${runtime_dir}/docker" ]]; then

        find "${runtime_dir}/docker" \
            -maxdepth 2 \
            -printf '%M %u:%g %p\n' \
            2>/dev/null \
            | sed -n '1,100p' \
            || true

    else

        echo "❌ ${runtime_dir}/docker absent"
        errors=$((errors + 1))

    fi

    # -------------------------------------------------------------------------
    # Docker CLI / contexte
    # -------------------------------------------------------------------------

    echo
    echo "▶ Docker CLI"

    docker_context="$(
        runuser -u "$username" -- \
            env \
                XDG_RUNTIME_DIR="$runtime_dir" \
                DOCKER_HOST="$docker_host" \
            docker context show \
            2>/dev/null || true
    )"

    if [[ -n "$docker_context" ]]; then
        echo "Context : $docker_context"
    else
        echo "❌ Impossible de déterminer le contexte Docker"
        errors=$((errors + 1))
    fi

    echo
    echo "DOCKER_HOST : $docker_host"

    # -------------------------------------------------------------------------
    # Docker version
    # -------------------------------------------------------------------------

    echo
    echo "▶ Docker version"

    docker_version="$(
        runuser -u "$username" -- \
            env \
                XDG_RUNTIME_DIR="$runtime_dir" \
                DOCKER_HOST="$docker_host" \
            docker version \
            2>&1 || true
    )"

    if [[ -n "$docker_version" ]]; then
        echo "$docker_version"
    else
        echo "❌ docker version : aucune réponse"
        errors=$((errors + 1))
    fi

    # -------------------------------------------------------------------------
    # Docker info
    # -------------------------------------------------------------------------

    echo
    echo "▶ Docker info"

    docker_info="$(
        runuser -u "$username" -- \
            env \
                XDG_RUNTIME_DIR="$runtime_dir" \
                DOCKER_HOST="$docker_host" \
            docker info \
            2>&1 || true
    )"

    if [[ -n "$docker_info" ]]; then
        echo "$docker_info"
    else
        echo "❌ docker info : aucune réponse"
        errors=$((errors + 1))
    fi

    # -------------------------------------------------------------------------
    # Rootless validation
    # -------------------------------------------------------------------------

    echo
    echo "▶ Rootless validation"

    if grep -qE '^[[:space:]]*rootless$' <<< "$docker_info"; then

        echo "✓ Docker Rootless actif"

    else

        echo "❌ Docker Rootless non détecté"
        errors=$((errors + 1))

    fi

    # -------------------------------------------------------------------------
    # Docker Root Dir
    # -------------------------------------------------------------------------

    echo
    echo "▶ Docker Root Dir"

    docker_root="$(
        sed -n 's/^ Docker Root Dir: //p' <<< "$docker_info"
    )"

    if [[ -n "$docker_root" ]]; then

        echo "Docker Root Dir : $docker_root"

        if [[ "$docker_root" == "$home/"* ]]; then
            echo "✓ Docker Root Dir dans HOME"
        else
            echo "⚠ Docker Root Dir hors HOME"
            warnings=$((warnings + 1))
        fi

    else

        echo "❌ Docker Root Dir indéterminé"
        errors=$((errors + 1))

    fi

    # -------------------------------------------------------------------------
    # Processus Docker
    # -------------------------------------------------------------------------

    echo
    echo "▶ Processus Docker"

    ps -eo \
        user,pid,ppid,stat,etime,cmd \
        2>/dev/null \
        | grep -E \
            "(dockerd|containerd|rootlesskit)" \
        | grep -v grep \
        | grep -E \
            "(${username}|rootlesskit)" \
        || true

    # -------------------------------------------------------------------------
    # Cgroups
    # -------------------------------------------------------------------------

    echo
    echo "▶ Cgroups"

    if [[ -n "$docker_info" ]]; then

        grep -E \
            "Cgroup Driver|Cgroup Version|Security Options" \
            <<< "$docker_info" \
            || true

    else

        echo "❌ Informations Cgroup indisponibles"
        warnings=$((warnings + 1))

    fi

    # -------------------------------------------------------------------------
    # Réseau Rootless
    # -------------------------------------------------------------------------

    echo
    echo "▶ Réseau Rootless"

    echo
    echo "Interfaces :"

    runuser -u "$username" -- \
        env \
            XDG_RUNTIME_DIR="$runtime_dir" \
        ip addr \
        2>/dev/null \
        | sed -n '1,80p' \
        || true

    echo
    echo "Routes :"

    runuser -u "$username" -- \
        env \
            XDG_RUNTIME_DIR="$runtime_dir" \
        ip route \
        2>/dev/null \
        || true

    # -------------------------------------------------------------------------
    # Test fonctionnel Docker
    # -------------------------------------------------------------------------

    echo
    echo "▶ Test fonctionnel Docker"

    if runuser -u "$username" -- \
        env \
            XDG_RUNTIME_DIR="$runtime_dir" \
            DOCKER_HOST="$docker_host" \
        docker run --rm hello-world \
        >/dev/null 2>&1
    then

        echo "✓ docker run hello-world"

    else

        echo "❌ docker run hello-world"
        errors=$((errors + 1))

    fi

    # -------------------------------------------------------------------------
    # Test réseau conteneur
    # -------------------------------------------------------------------------

    echo
    echo "▶ Test réseau conteneur"

    if runuser -u "$username" -- \
        env \
            XDG_RUNTIME_DIR="$runtime_dir" \
            DOCKER_HOST="$docker_host" \
        docker run --rm busybox \
            sh -c 'wget -qO- https://example.com >/dev/null' \
        >/dev/null 2>&1
    then

        echo "✓ Réseau conteneur opérationnel"

    else

        echo "⚠ Test réseau conteneur échoué"
        warnings=$((warnings + 1))

    fi

    # -------------------------------------------------------------------------
    # Diagnostic journal
    # -------------------------------------------------------------------------

    echo
    echo "▶ Journal Docker Rootless"

    runuser -u "$username" -- \
        env \
            XDG_RUNTIME_DIR="$runtime_dir" \
            DBUS_SESSION_BUS_ADDRESS="unix:path=${runtime_dir}/bus" \
        journalctl --user \
            -u docker.service \
            -n 30 \
            --no-pager \
            -o cat \
        2>/dev/null \
        || true

    # -------------------------------------------------------------------------
    # Résultat
    # -------------------------------------------------------------------------

    echo
    echo "=============================================================="
    echo " Résultat"
    echo "=============================================================="

    echo
    echo "Utilisateur : $username"
    echo "Erreurs     : $errors"
    echo "Warnings    : $warnings"

    if (( errors == 0 )); then

        echo
        echo "DOCKER ROOTLESS ${username} : OPÉRATIONNEL ✅"

        if (( warnings > 0 )); then
            echo "⚠ ${warnings} warning(s) détecté(s)."
        fi

        return 0

    fi

    echo
    echo "DOCKER ROOTLESS ${username} : ANOMALIES DÉTECTÉES ❌"

    return 1
}

docker_rootless_exec() {
    local docker_user="$1"
    local container="$2"

    shift 2

    local docker_runtime_dir="/run/user/$(id -u "${docker_user}")"
    local docker_host="unix://${docker_runtime_dir}/docker.sock"

    if [[ -z "${container}" ]]; then
        echo "❌ Nom du conteneur manquant."
        return 1
    fi

    if [[ $# -eq 0 ]]; then
        echo "❌ Commande manquante pour docker exec."
        echo
        echo "Usage :"
        echo "   docker_exec_rootless <utilisateur> <conteneur> <commande> [arguments...]"
        return 1
    fi

    if ! runuser -u "${docker_user}" -- \
        env \
        XDG_RUNTIME_DIR="${docker_runtime_dir}" \
        DOCKER_HOST="${docker_host}" \
        docker container inspect "${container}" >/dev/null 2>&1
    then
        echo "❌ Le conteneur n'existe pas :"
        echo
        echo "   ${container}"
        echo
        echo "Conteneurs disponibles :"

        runuser -u "${docker_user}" -- \
            env \
            XDG_RUNTIME_DIR="${docker_runtime_dir}" \
            DOCKER_HOST="${docker_host}" \
            docker ps \
            --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}'

        return 1
    fi

    runuser -u "${docker_user}" -- \
        env \
        XDG_RUNTIME_DIR="${docker_runtime_dir}" \
        DOCKER_HOST="${docker_host}" \
        docker exec "${container}" "$@"
}

docker_rootless_inspect() {

    local docker_user="${1:-}"
    local container="${2:-}"

    local docker_uid=""
    local docker_runtime_dir=""
    local docker_host=""


    # ==========================================================
    # Validation
    # ==========================================================

    if [[ -z "${docker_user}" ]]; then

        echo "❌ Aucun utilisateur Docker Rootless indiqué."
        echo
        echo "Utilisation :"
        echo "  docker_inspect_rootless USER CONTAINER"

        return 1
    fi


    if [[ -z "${container}" ]]; then

        echo "❌ Aucun conteneur indiqué."
        echo
        echo "Utilisation :"
        echo "  docker_inspect_rootless USER CONTAINER"

        return 1
    fi


    if ! id -u "${docker_user}" >/dev/null 2>&1; then

        echo "❌ L'utilisateur n'existe pas :"
        echo "   ${docker_user}"

        return 1
    fi


    # ==========================================================
    # Configuration Docker Rootless
    # ==========================================================

    docker_uid="$(id -u "${docker_user}")"
    docker_runtime_dir="/run/user/${docker_uid}"
    docker_host="unix://${docker_runtime_dir}/docker.sock"


    # ==========================================================
    # Vérification du socket
    # ==========================================================

    if [[ ! -S "${docker_runtime_dir}/docker.sock" ]]; then

        echo "❌ Le socket Docker Rootless est introuvable :"
        echo "   ${docker_runtime_dir}/docker.sock"
        echo "   Utilisateur : ${docker_user}"

        return 1
    fi


    # ==========================================================
    # Vérification du conteneur
    # ==========================================================

    if ! runuser -u "${docker_user}" -- \
        env \
        XDG_RUNTIME_DIR="${docker_runtime_dir}" \
        DOCKER_HOST="${docker_host}" \
        docker inspect "${container}" >/dev/null 2>&1
    then

        echo
        echo "❌ Le conteneur n'existe pas :"
        echo "   ${container}"

        echo
        echo "Conteneurs disponibles :"

        runuser -u "${docker_user}" -- \
            env \
            XDG_RUNTIME_DIR="${docker_runtime_dir}" \
            DOCKER_HOST="${docker_host}" \
            docker ps -a \
            --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}'

        return 0
    fi


    # ==========================================================
    # Docker inspect
    # ==========================================================

    runuser -u "${docker_user}" -- \
        env \
        XDG_RUNTIME_DIR="${docker_runtime_dir}" \
        DOCKER_HOST="${docker_host}" \
        docker inspect "${container}"

}

docker_rootless_log() {

    local docker_user="${1:-}"
    local container="${2:-}"

    local docker_uid=""
    local docker_runtime_dir=""
    local docker_host=""


    # ==========================================================
    # Validation
    # ==========================================================

    if [[ -z "${docker_user}" ]]; then

        echo "❌ Aucun utilisateur Docker Rootless indiqué."
        echo
        echo "Utilisation :"
        echo "  docker_logs_rootless USER CONTAINER"

        return 1
    fi


    if [[ -z "${container}" ]]; then

        echo "❌ Aucun conteneur indiqué."
        echo
        echo "Utilisation :"
        echo "  docker_logs_rootless USER CONTAINER"

        return 1
    fi


    if ! id -u "${docker_user}" >/dev/null 2>&1; then

        echo "❌ L'utilisateur n'existe pas :"
        echo "   ${docker_user}"

        return 1
    fi


    # ==========================================================
    # Configuration Docker Rootless
    # ==========================================================

    docker_uid="$(id -u "${docker_user}")"
    docker_runtime_dir="/run/user/${docker_uid}"
    docker_host="unix://${docker_runtime_dir}/docker.sock"


    # ==========================================================
    # Vérification du socket
    # ==========================================================

    if [[ ! -S "${docker_runtime_dir}/docker.sock" ]]; then

        echo "❌ Le socket Docker Rootless est introuvable :"
        echo "   ${docker_runtime_dir}/docker.sock"
        echo "   Utilisateur : ${docker_user}"

        return 1
    fi


    # ==========================================================
    # Vérification du conteneur
    # ==========================================================

    if ! runuser -u "${docker_user}" -- \
        env \
        XDG_RUNTIME_DIR="${docker_runtime_dir}" \
        DOCKER_HOST="${docker_host}" \
        docker inspect "${container}" >/dev/null 2>&1
    then

        echo
        echo "❌ Le conteneur n'existe pas :"
        echo "   ${container}"

        echo
        echo "Conteneurs disponibles :"

        runuser -u "${docker_user}" -- \
            env \
            XDG_RUNTIME_DIR="${docker_runtime_dir}" \
            DOCKER_HOST="${docker_host}" \
            docker ps -a \
            --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}'

        return 0
    fi


    # ==========================================================
    # Docker logs
    # ==========================================================

    runuser -u "${docker_user}" -- \
        env \
        XDG_RUNTIME_DIR="${docker_runtime_dir}" \
        DOCKER_HOST="${docker_host}" \
        docker logs "${container}"

    return 0

}

docker_rootless_ps() {

    local docker_user="${1:-}"
    local docker_uid=""
    local docker_runtime_dir=""
    local docker_host=""


    # ==========================================================
    # Validation
    # ==========================================================

    if [[ -z "${docker_user}" ]]; then

        echo "❌ Aucun utilisateur Docker Rootless indiqué."
        echo
        echo "Utilisation :"
        echo "  docker_ps_rootless USER"

        return 1
    fi


    if ! id -u "${docker_user}" >/dev/null 2>&1; then

        echo "❌ L'utilisateur n'existe pas :"
        echo "   ${docker_user}"

        return 1
    fi


    # ==========================================================
    # Configuration Docker Rootless
    # ==========================================================

    docker_uid="$(id -u "${docker_user}")"
    docker_runtime_dir="/run/user/${docker_uid}"
    docker_host="unix://${docker_runtime_dir}/docker.sock"


    # ==========================================================
    # Vérification du socket
    # ==========================================================

    if [[ ! -S "${docker_runtime_dir}/docker.sock" ]]; then

        echo "❌ Le socket Docker Rootless est introuvable :"
        echo "   ${docker_runtime_dir}/docker.sock"
        echo "   Utilisateur : ${docker_user}"

        return 1
    fi


    # ==========================================================
    # Docker PS
    # ==========================================================

    runuser -u "${docker_user}" -- \
        env \
        XDG_RUNTIME_DIR="${docker_runtime_dir}" \
        DOCKER_HOST="${docker_host}" \
        docker ps

}

docker_rootless_env() {
    local docker_user="${1:-}"

    if [[ -z "${docker_user}" ]]; then
        print_error "Aucun utilisateur Docker Rootless indiqué."
        return 1
    fi

    local docker_uid
    docker_uid="$(id -u "${docker_user}")" || return 1

    export XDG_RUNTIME_DIR="/run/user/${docker_uid}"
    export DOCKER_HOST="unix://${XDG_RUNTIME_DIR}/docker.sock"
}

docker_test_rootless() {

    ###############################################################################
    # TEST DOCKER ROOTLESS
    #
    # Vérifie que Docker Rootless est opérationnel pour un utilisateur donné.
    #
    # Usage :
    #   test_docker_rootless <USERNAME>
    #
    # Retour :
    #   0 : Test effectué
    #   2 : Paramètre / utilisateur invalide
    #
    # Le résultat du test est affiché par la fonction :
    #   DOCKER ROOTLESS <USERNAME> : OK
    #   DOCKER ROOTLESS <USERNAME> : KO
    #   DOCKER ROOTLESS <USERNAME> : NON ACTIF
    #
    # Un résultat négatif n'est pas considéré comme une erreur DIU.
    ###############################################################################

    local username="${1:-}"

    local uid=""
    local gid=""
    local home=""
    local runtime_dir=""
    local docker_host=""
    local docker_context=""
    local service_state=""
    local service_enabled=""
    local linger=""
    local user_manager=""
    local docker_socket=""
    local docker_version=""
    local docker_info=""

    local errors=0

    # -------------------------------------------------------------------------
    # Paramètre
    # -------------------------------------------------------------------------

    if [[ -z "$username" ]]; then
        echo "❌ Utilisateur manquant."
        echo "Usage : test_docker_rootless <USERNAME>"
        return 2
    fi

    # -------------------------------------------------------------------------
    # Utilisateur
    # -------------------------------------------------------------------------

    if ! id "$username" >/dev/null 2>&1; then
        echo "❌ Utilisateur inexistant : $username"
        return 2
    fi

    uid="$(id -u "$username")"
    gid="$(id -g "$username")"
    home="$(getent passwd "$username" | cut -d: -f6)"

    if [[ -z "$uid" || -z "$gid" || -z "$home" ]]; then
        echo "❌ Impossible de déterminer l'identité de $username"
        return 2
    fi

    runtime_dir="/run/user/$uid"
    docker_host="unix://${runtime_dir}/docker.sock"

    # -------------------------------------------------------------------------
    # Détection Docker Rootless
    #
    # Cette étape détermine si Docker Rootless est actuellement actif
    # pour le compte demandé.
    #
    # La batterie complète n'est exécutée que si le service est actif.
    # -------------------------------------------------------------------------

    if [[ ! -d "$runtime_dir" ]]; then
        echo
        echo "DOCKER ROOTLESS ${username} : NON ACTIF ⚠️"
        echo
        echo "ℹ️  Le runtime utilisateur n'existe pas : ${runtime_dir}"
        echo
        return 0
    fi

    service_state="$(
        runuser -u "$username" -- \
            env \
                XDG_RUNTIME_DIR="$runtime_dir" \
                DBUS_SESSION_BUS_ADDRESS="unix:path=${runtime_dir}/bus" \
            systemctl --user is-active docker.service 2>/dev/null
    )"

    if [[ "$service_state" != "active" ]]; then
        echo
        echo "DOCKER ROOTLESS ${username} : NON ACTIF ⚠️"
        echo
        echo "État du service docker.service : ${service_state:-inactif}"
        echo
        echo "ℹ️  La batterie de tests Rootless n'est pas exécutée."
        echo
        return 0
    fi

    # -------------------------------------------------------------------------
    # SUBUID / SUBGID
    # -------------------------------------------------------------------------

    if ! grep -qE "^${username}:" /etc/subuid 2>/dev/null; then
        errors=$((errors + 1))
    fi

    if ! grep -qE "^${username}:" /etc/subgid 2>/dev/null; then
        errors=$((errors + 1))
    fi

    # -------------------------------------------------------------------------
    # Outils Rootless
    # -------------------------------------------------------------------------

    command -v rootlesskit >/dev/null 2>&1 || errors=$((errors + 1))
    command -v newuidmap >/dev/null 2>&1 || errors=$((errors + 1))
    command -v newgidmap >/dev/null 2>&1 || errors=$((errors + 1))
    command -v dockerd-rootless.sh >/dev/null 2>&1 || errors=$((errors + 1))

    # -------------------------------------------------------------------------
    # Runtime utilisateur
    # -------------------------------------------------------------------------

    if [[ ! -d "$runtime_dir" ]]; then
        errors=$((errors + 1))
    fi

    # -------------------------------------------------------------------------
    # Lingering
    # -------------------------------------------------------------------------

    linger="$(loginctl show-user "$username" -p Linger --value 2>/dev/null)"

    if [[ "$linger" != "yes" ]]; then
        errors=$((errors + 1))
    fi

    # -------------------------------------------------------------------------
    # User Manager
    # -------------------------------------------------------------------------

    user_manager="$(
        systemctl is-active "user@${uid}.service" 2>/dev/null
    )"

    if [[ "$user_manager" != "active" ]]; then
        errors=$((errors + 1))
    fi

    # -------------------------------------------------------------------------
    # Service Docker Rootless
    #
    # Le service est déjà vérifié comme actif dans la phase de détection.
    # Ici, on vérifie qu'il est également activé dans le User Manager.
    # -------------------------------------------------------------------------

    service_enabled="$(
        runuser -u "$username" -- \
            env \
                XDG_RUNTIME_DIR="$runtime_dir" \
                DBUS_SESSION_BUS_ADDRESS="unix:path=${runtime_dir}/bus" \
            systemctl --user is-enabled docker.service 2>/dev/null
    )"

    if [[ "$service_enabled" != "enabled" ]]; then
        errors=$((errors + 1))
    fi

    # -------------------------------------------------------------------------
    # Socket Docker
    # -------------------------------------------------------------------------

    docker_socket="${runtime_dir}/docker.sock"

    if [[ ! -S "$docker_socket" ]]; then
        errors=$((errors + 1))
    fi

    # -------------------------------------------------------------------------
    # Docker version
    # -------------------------------------------------------------------------

    if ! docker_version="$(
        runuser -u "$username" -- \
            env \
                XDG_RUNTIME_DIR="$runtime_dir" \
                DOCKER_HOST="$docker_host" \
            docker version --format '{{.Server.Version}}' 2>/dev/null
    )"; then
        errors=$((errors + 1))
    fi

    if [[ -z "$docker_version" ]]; then
        errors=$((errors + 1))
    fi

    # -------------------------------------------------------------------------
    # Docker info
    # -------------------------------------------------------------------------

    if ! docker_info="$(
        runuser -u "$username" -- \
            env \
                XDG_RUNTIME_DIR="$runtime_dir" \
                DOCKER_HOST="$docker_host" \
            docker info 2>/dev/null
    )"; then
        errors=$((errors + 1))
    fi

    # -------------------------------------------------------------------------
    # Vérification Rootless
    # -------------------------------------------------------------------------

    if ! grep -qE '^[[:space:]]*rootless$' <<< "$docker_info"; then
        errors=$((errors + 1))
    fi

    # -------------------------------------------------------------------------
    # Test fonctionnel réel
    #
    # Utilise hello-world et supprime immédiatement le conteneur.
    # -------------------------------------------------------------------------

    if ! runuser -u "$username" -- \
        env \
            XDG_RUNTIME_DIR="$runtime_dir" \
            DOCKER_HOST="$docker_host" \
        docker run --rm hello-world >/dev/null 2>&1
    then
        errors=$((errors + 1))
    fi

    # -------------------------------------------------------------------------
    # Résultat
    # -------------------------------------------------------------------------

    if (( errors == 0 )); then
        echo
        echo "DOCKER ROOTLESS ${username} : OK ✅"
        echo
        return 0
    fi

    echo
    echo "DOCKER ROOTLESS ${username} : KO ❌"
    echo
    echo "Erreurs détectées : ${errors}"
    echo

    return 0
}

docker_rootless_analyse() {

    ###############################################################################
    # ANALYSE DOCKER ROOTLESS
    #
    # Analyse indépendante de l'état Docker Rootless d'un utilisateur.
    #
    # Cette fonction est purement diagnostique :
    #   - elle ne modifie aucun état ;
    #   - elle ne configure rien ;
    #   - elle ne déconfigure rien ;
    #   - elle peut être exécutée indépendamment.
    #
    # Retour :
    #   0 = analyse effectuée
    #   1 = erreur d'analyse
    #   2 = argument/utilisateur invalide
    ###############################################################################

    local user="${1:-}"

    local uid=""
    local gid=""
    local home=""
    local runtime_dir=""

    local primary_group=""
    local groups=""

    local subuid=""
    local subgid=""

    local linger=""

    local docker_context=""
    local docker_host=""

    local service_state=""
    local socket_state="absent"
    local process_state="absent"
    local data_state="absent"
    local config_state="absent"

    local state_file=""
    local state_saved="no"

    local docker_info=""

    # -------------------------------------------------------------------------
    # Validation
    # -------------------------------------------------------------------------

    if [[ -z "$user" ]]; then
        echo "❌ Utilisateur obligatoire."
        return 2
    fi

    if ! id "$user" >/dev/null 2>&1; then
        echo "❌ Utilisateur inexistant : $user"
        return 2
    fi

    # -------------------------------------------------------------------------
    # Informations utilisateur
    # -------------------------------------------------------------------------

    uid="$(id -u "$user" 2>/dev/null || true)"
    gid="$(id -g "$user" 2>/dev/null || true)"
    home="$(getent passwd "$user" | cut -d: -f6)"

    if [[ -z "$uid" || -z "$gid" || -z "$home" ]]; then
        echo "❌ Impossible de déterminer les informations utilisateur."
        return 1
    fi

    runtime_dir="/run/user/${uid}"

    primary_group="$(id -gn "$user" 2>/dev/null || true)"
    groups="$(id -nG "$user" 2>/dev/null || true)"

    # -------------------------------------------------------------------------
    # SUBUID / SUBGID
    # -------------------------------------------------------------------------

    subuid="$(
        grep "^${user}:" /etc/subuid 2>/dev/null \
            | head -n1 \
            || true
    )"

    subgid="$(
        grep "^${user}:" /etc/subgid 2>/dev/null \
            | head -n1 \
            || true
    )"

    [[ -n "$subuid" ]] || subuid="absent"
    [[ -n "$subgid" ]] || subgid="absent"

    # -------------------------------------------------------------------------
    # Linger
    #
    # loginctl peut retourner une erreur lorsque l'utilisateur n'est
    # ni connecté ni en lingering. Dans ce cas l'état réel est "no".
    # -------------------------------------------------------------------------

    linger="$(
        loginctl show-user "$user" -p Linger --value \
            2>/dev/null \
            || true
    )"

    [[ "$linger" == "yes" ]] || linger="no"

    # -------------------------------------------------------------------------
    # Contexte Docker
    # -------------------------------------------------------------------------

    docker_context="$(
        runuser -u "$user" -- \
            env -u DOCKER_HOST \
            docker context show \
            2>/dev/null \
            || true
    )"

    [[ -n "$docker_context" ]] || docker_context="default"

    # -------------------------------------------------------------------------
    # DOCKER_HOST
    #
    # On inspecte l'environnement utilisateur sans considérer son absence
    # comme une anomalie : le contexte Docker peut suffire.
    # -------------------------------------------------------------------------

    docker_host="$(
        runuser -u "$user" -- \
            sh -c 'printf "%s" "${DOCKER_HOST:-}"' \
            2>/dev/null \
            || true
    )"

    [[ -n "$docker_host" ]] || docker_host="absent"

    # -------------------------------------------------------------------------
    # Service systemd Rootless
    # -------------------------------------------------------------------------

    service_state="$(
        runuser -u "$user" -- \
            env \
                XDG_RUNTIME_DIR="$runtime_dir" \
                DBUS_SESSION_BUS_ADDRESS="unix:path=${runtime_dir}/bus" \
            systemctl --user is-active docker.service \
            2>/dev/null \
            || true
    )"

    [[ "$service_state" == "active" ]] || service_state="inactive"

    # -------------------------------------------------------------------------
    # Socket Rootless
    # -------------------------------------------------------------------------

    if [[ -S "${runtime_dir}/docker.sock" ]]; then
        socket_state="present"
    fi

    # -------------------------------------------------------------------------
    # Processus Rootless
    #
    # On recherche les processus appartenant à l'utilisateur.
    # -------------------------------------------------------------------------

    if runuser -u "$user" -- \
        pgrep -u "$user" -f \
        'rootlesskit|dockerd-rootless|dockerd|containerd' \
        >/dev/null 2>&1
    then
        process_state="present"
    fi

    # -------------------------------------------------------------------------
    # Données Rootless
    # -------------------------------------------------------------------------

    if [[ -d "${home}/.local/share/docker" ]]; then
        data_state="present"
    fi

    # -------------------------------------------------------------------------
    # Configuration Rootless
    #
    # La configuration Rootless est matérialisée par le service systemd
    # utilisateur créé par dockerd-rootless-setuptool.sh.
    #
    # ~/.config/docker/daemon.json n'est PAS obligatoire.
    # -------------------------------------------------------------------------

    if [[ -f "${home}/.config/systemd/user/docker.service" ]]; then

        config_state="present"

    elif [[ -L "${home}/.config/systemd/user/default.target.wants/docker.service" ]]; then

        config_state="present"

    fi

    # -------------------------------------------------------------------------
    # État sauvegardé
    # -------------------------------------------------------------------------

    state_file="${DIU_ROOT:-/root/diu}/config/states/${user}/docker_rootless.state"

    if [[ -f "$state_file" ]]; then
        state_saved="yes"
    fi

    # -------------------------------------------------------------------------
    # Affichage
    # -------------------------------------------------------------------------

    echo
    echo "=============================================================="
    echo " Analyse Docker Rootless"
    echo "=============================================================="
    echo

    printf "%-20s : %s\n" "USER" "$user"
    printf "%-20s : %s\n" "UID" "$uid"
    printf "%-20s : %s\n" "GID" "$gid"
    printf "%-20s : %s\n" "HOME" "$home"
    printf "%-20s : %s\n" "RUNTIME" "$runtime_dir"
    echo

    printf "%-20s : %s\n" "PRIMARY GROUP" "$primary_group"
    printf "%-20s : %s\n" "GROUPS" "$groups"
    echo

    printf "%-20s : %s\n" "SUBUID" "$subuid"
    printf "%-20s : %s\n" "SUBGID" "$subgid"
    echo

    printf "%-20s : %s\n" "LINGER" "$linger"
    echo

    printf "%-20s : %s\n" "DOCKER CONTEXT" "$docker_context"
    printf "%-20s : %s\n" "DOCKER HOST" "$docker_host"
    echo

    printf "%-20s : %s\n" "ROOTLESS SERVICE" "$service_state"
    printf "%-20s : %s\n" "ROOTLESS SOCKET" "$socket_state"
    printf "%-20s : %s\n" "ROOTLESS PROCESS" "$process_state"
    printf "%-20s : %s\n" "ROOTLESS DATA" "$data_state"
    printf "%-20s : %s\n" "ROOTLESS CONFIG" "$config_state"
    echo

    printf "%-20s : %s\n" "STATE SAVED" "$state_saved"

    if [[ "$state_saved" == "yes" ]]; then
        printf "%-20s : %s\n" "STATE FILE" "$state_file"
    fi

    echo

    # -------------------------------------------------------------------------
    # Vérification Docker Rootful
    # -------------------------------------------------------------------------

    docker_info="$(
        runuser -u "$user" -- \
            env \
                -u DOCKER_HOST \
                -u DOCKER_CONTEXT \
            docker info \
            2>&1 \
            || true
    )"

    if grep -qE 'Server Version:' <<< "$docker_info"; then
          printf "%-20s : %s\n" "DOCKER ROOTFUL" "accessible"
    else
          printf "%-20s : %s\n" "DOCKER ROOTFUL" "inaccessible"
    fi

    echo
    echo "=============================================================="
    echo " Fin de l'analyse"
    echo "=============================================================="

    return 0
}

docker_rootless_delete_state() {

    ###############################################################################
    # SUPPRESSION DE L'ÉTAT DOCKER ROOTLESS
    #
    # Supprime uniquement :
    #
    #   config/states/<USER>/docker_rootless.state
    #
    # Idempotente.
    ###############################################################################

    local user="${1:-}"

    local state_dir=""
    local state_file=""

    if [[ -z "$user" ]]; then
        echo "❌ Utilisateur obligatoire."
        return 2
    fi

    state_dir="${DIU_ROOT:-/root/diu}/config/states/${user}"
    state_file="${state_dir}/docker_rootless.state"

    if [[ ! -e "$state_file" ]]; then
        echo "✓ Aucun état à supprimer pour $user"
        return 0
    fi

    rm -f "$state_file" || {
        echo "❌ Impossible de supprimer : $state_file"
        return 1
    }

    if [[ -e "$state_file" ]]; then
        echo "❌ État encore présent : $state_file"
        return 1
    fi

    echo "✓ État Docker Rootless supprimé"

    return 0
}

docker_rootless_save_state() {

    ###############################################################################
    # SAUVEGARDE DE L'ÉTAT DOCKER ROOTLESS
    #
    # Stockage :
    #
    #   ${DIU_ROOT}/config/states/<USER>/docker_rootless.state
    #
    # La sauvegarde est volontairement idempotente :
    #
    #   - si l'état existe déjà : aucune modification ;
    #   - sinon : capture de l'état actuel ;
    #
    # IMPORTANT :
    #   Cette fonction doit être appelée AVANT toute modification de
    #   l'environnement utilisateur lors d'une configuration Rootless.
    ###############################################################################

    local user="${1:-}"

    local state_dir=""
    local state_file=""
    local tmp_file=""

    local uid=""
    local gid=""
    local home=""
    local primary_group=""
    local groups=""
    local subuid=""
    local subgid=""
    local linger=""
    local docker_context=""
    local docker_host=""

    # -------------------------------------------------------------------------
    # Validation
    # -------------------------------------------------------------------------

    if [[ -z "$user" ]]; then
        echo "❌ Utilisateur obligatoire."
        return 2
    fi

    if ! id "$user" >/dev/null 2>&1; then
        echo "❌ Utilisateur inexistant : $user"
        return 2
    fi

    # -------------------------------------------------------------------------
    # Localisation de l'état
    # -------------------------------------------------------------------------

    state_dir="${DIU_ROOT:-/root/diu}/config/states/${user}"
    state_file="${state_dir}/docker_rootless.state"

    # -------------------------------------------------------------------------
    # Idempotence
    #
    # Ne jamais écraser un état existant.
    # -------------------------------------------------------------------------

    if [[ -f "$state_file" ]]; then

        echo "✓ État Docker Rootless déjà sauvegardé :"
        echo "  $state_file"

        return 0
    fi

    # -------------------------------------------------------------------------
    # Création du répertoire d'état
    # -------------------------------------------------------------------------

    mkdir -p "$state_dir" || {
        echo "❌ Impossible de créer : $state_dir"
        return 1
    }

    # -------------------------------------------------------------------------
    # Capture identité utilisateur
    # -------------------------------------------------------------------------

    uid="$(id -u "$user")"
    gid="$(id -g "$user")"
    home="$(getent passwd "$user" | cut -d: -f6)"
    primary_group="$(id -gn "$user" 2>/dev/null || true)"
    groups="$(id -nG "$user" 2>/dev/null || true)"

    if [[ -z "$home" ]]; then
        echo "❌ HOME utilisateur introuvable."
        return 1
    fi

    # -------------------------------------------------------------------------
    # SUBUID / SUBGID
    #
    # Une seule entrée utilisateur est mémorisée.
    # -------------------------------------------------------------------------

    subuid="$(
        grep "^${user}:" /etc/subuid 2>/dev/null \
            | head -n1 \
            || true
    )"

    subgid="$(
        grep "^${user}:" /etc/subgid 2>/dev/null \
            | head -n1 \
            || true
    )"

    # -------------------------------------------------------------------------
    # Systemd lingering
    # -------------------------------------------------------------------------

    linger="$(
        loginctl show-user "$user" -p Linger --value \
            2>/dev/null \
            || true
    )"

    [[ "$linger" == "yes" ]] || linger="no"

    # -------------------------------------------------------------------------
    # Contexte Docker
    #
    # On neutralise les variables d'environnement susceptibles de forcer
    # un contexte Rootless afin de mémoriser le contexte Docker réel.
    # -------------------------------------------------------------------------

    docker_context="$(
        runuser -u "$user" -- \
            env -u DOCKER_HOST -u DOCKER_CONTEXT \
            docker context show \
            2>/dev/null \
            || true
    )"

    [[ -n "$docker_context" ]] || docker_context="default"

    # -------------------------------------------------------------------------
    # DOCKER_HOST
    #
    # Capture de la variable présente dans l'environnement du processus.
    # -------------------------------------------------------------------------

    docker_host="$(
        runuser -u "$user" -- \
            env \
            | sed -n 's/^DOCKER_HOST=//p' \
            | head -n1 \
            || true
    )"

    # -------------------------------------------------------------------------
    # Fichier temporaire
    # -------------------------------------------------------------------------

    tmp_file="${state_file}.tmp.$$"

    # -------------------------------------------------------------------------
    # Génération de l'état
    #
    # printf '%q' permet de générer des valeurs sûres pour un futur `source`.
    # -------------------------------------------------------------------------

    {
        echo '# =============================================================================='
        echo '# DIU — ÉTAT DOCKER ROOTLESS'
        echo '# =============================================================================='
        echo

        printf 'DOCKER_ROOTLESS_STATE_VERSION=%q\n' "1"
        echo

        printf 'DOCKER_ROOTLESS_USER=%q\n' "$user"
        printf 'DOCKER_ROOTLESS_UID=%q\n' "$uid"
        printf 'DOCKER_ROOTLESS_GID=%q\n' "$gid"
        printf 'DOCKER_ROOTLESS_HOME=%q\n' "$home"
        echo

        printf 'DOCKER_ROOTLESS_PRIMARY_GROUP=%q\n' "$primary_group"
        printf 'DOCKER_ROOTLESS_GROUPS=%q\n' "$groups"
        echo

        printf 'DOCKER_ROOTLESS_SUBUID=%q\n' "$subuid"
        printf 'DOCKER_ROOTLESS_SUBGID=%q\n' "$subgid"
        echo

        printf 'DOCKER_ROOTLESS_LINGER=%q\n' "$linger"
        echo

        printf 'DOCKER_ROOTLESS_CONTEXT=%q\n' "$docker_context"
        printf 'DOCKER_ROOTLESS_HOST=%q\n' "$docker_host"
    } > "$tmp_file" || {

        rm -f "$tmp_file" 2>/dev/null || true

        echo "❌ Impossible de générer l'état."
        return 1
    }

    # -------------------------------------------------------------------------
    # Permissions
    # -------------------------------------------------------------------------

    chmod 0660 "$tmp_file" || {

        rm -f "$tmp_file" 2>/dev/null || true

        echo "❌ Impossible de positionner les permissions de l'état."
        return 1
    }

    # -------------------------------------------------------------------------
    # Écriture atomique
    # -------------------------------------------------------------------------

    if ! mv "$tmp_file" "$state_file"; then

        rm -f "$tmp_file" 2>/dev/null || true

        echo "❌ Impossible d'enregistrer l'état."
        return 1
    fi

    # -------------------------------------------------------------------------
    # Vérification finale
    # -------------------------------------------------------------------------

    if [[ ! -f "$state_file" ]]; then

        echo "❌ État non créé : $state_file"
        return 1
    fi

    echo
    echo "✓ État Docker Rootless sauvegardé :"
    echo "  $state_file"

    return 0
}

docker_rootless_prepare_subuid() {

    ###############################################################################
    # PRÉPARATION SUBUID / SUBGID POUR DOCKER ROOTLESS
    #
    # Prépare une plage de 65536 identifiants pour un utilisateur.
    #
    # Comportement :
    #   - si SUBUID + SUBGID existent : ne rien modifier ;
    #   - si aucun des deux n'existe : allouer une nouvelle plage ;
    #   - si un seul des deux existe : erreur ;
    #   - ne modifie jamais les mappings des autres utilisateurs ;
    #   - idempotente.
    ###############################################################################

    local user="${1:-}"

    local range_size="65536"

    local subuid_entry=""
    local subgid_entry=""

    local subuid_start=""
    local subgid_start=""

    local max_end=0
    local start=0
    local end=0

    local file=""
    local entry=""
    local entry_start=""
    local entry_count=""

    # -------------------------------------------------------------------------
    # Validation
    # -------------------------------------------------------------------------

    if [[ -z "$user" ]]; then
        echo "❌ Utilisateur obligatoire."
        return 2
    fi

    if ! id "$user" >/dev/null 2>&1; then
        echo "❌ Utilisateur inexistant : $user"
        return 2
    fi

    if [[ ! -f /etc/subuid ]]; then
        echo "❌ /etc/subuid inexistant."
        return 1
    fi

    if [[ ! -f /etc/subgid ]]; then
        echo "❌ /etc/subgid inexistant."
        return 1
    fi

    # -------------------------------------------------------------------------
    # État actuel
    # -------------------------------------------------------------------------

    subuid_entry="$(
        grep "^${user}:" /etc/subuid 2>/dev/null \
            | head -n1 \
            || true
    )"

    subgid_entry="$(
        grep "^${user}:" /etc/subgid 2>/dev/null \
            | head -n1 \
            || true
    )"

    # -------------------------------------------------------------------------
    # Déjà configuré
    # -------------------------------------------------------------------------

    if [[ -n "$subuid_entry" && -n "$subgid_entry" ]]; then

        subuid_start="$(cut -d: -f2 <<< "$subuid_entry")"
        subgid_start="$(cut -d: -f2 <<< "$subgid_entry")"

        if [[ "$subuid_start" == "$subgid_start" ]]; then
            echo "✓ SUBUID/SUBGID déjà configurés pour $user"
            echo "  SUBUID : $subuid_entry"
            echo "  SUBGID : $subgid_entry"
            return 0
        fi

        echo "❌ SUBUID et SUBGID de $user utilisent des plages différentes."
        echo "  SUBUID : $subuid_entry"
        echo "  SUBGID : $subgid_entry"

        return 1
    fi

    # -------------------------------------------------------------------------
    # Configuration partielle interdite
    # -------------------------------------------------------------------------

    if [[ -n "$subuid_entry" && -z "$subgid_entry" ]]; then

        echo "❌ SUBUID présent mais SUBGID absent pour $user"
        echo "  SUBUID : $subuid_entry"

        return 1
    fi

    if [[ -z "$subuid_entry" && -n "$subgid_entry" ]]; then

        echo "❌ SUBGID présent mais SUBUID absent pour $user"
        echo "  SUBGID : $subgid_entry"

        return 1
    fi

    # -------------------------------------------------------------------------
    # Recherche de la première plage libre
    #
    # On commence à 100000.
    #
    # Pour chaque entrée :
    #
    #   start = début de plage
    #   end   = début + nombre d'identifiants
    #
    # max_end permet de trouver une plage située après toutes les plages
    # existantes.
    # -------------------------------------------------------------------------

    max_end=100000

    for file in /etc/subuid /etc/subgid; do

        while IFS=: read -r entry entry_start entry_count _; do

            [[ -n "$entry_start" ]] || continue
            [[ "$entry_start" =~ ^[0-9]+$ ]] || continue
            [[ "$entry_count" =~ ^[0-9]+$ ]] || continue

            end=$((entry_start + entry_count))

            if (( end > max_end )); then
                max_end=$end
            fi

        done < "$file"

    done

    start="$max_end"

    # -------------------------------------------------------------------------
    # Vérification de sécurité
    #
    # On vérifie explicitement que la nouvelle plage n'entre pas en collision
    # avec une plage existante.
    # -------------------------------------------------------------------------

    while true; do

        end=$((start + range_size))

        local collision=0

        for file in /etc/subuid /etc/subgid; do

            while IFS=: read -r entry entry_start entry_count _; do

                [[ -n "$entry_start" ]] || continue
                [[ "$entry_start" =~ ^[0-9]+$ ]] || continue
                [[ "$entry_count" =~ ^[0-9]+$ ]] || continue

                local existing_end=$((entry_start + entry_count))

                if (( start < existing_end && end > entry_start )); then
                    collision=1
                    break
                fi

            done < "$file"

            (( collision == 1 )) && break

        done

        if (( collision == 0 )); then
            break
        fi

        start="$end"

    done

    # -------------------------------------------------------------------------
    # Ajout atomique logique
    # -------------------------------------------------------------------------

    if ! printf '%s:%s:%s\n' \
        "$user" "$start" "$range_size" >> /etc/subuid
    then

        echo "❌ Impossible d'ajouter le SUBUID pour $user"
        return 1
    fi

    if ! printf '%s:%s:%s\n' \
        "$user" "$start" "$range_size" >> /etc/subgid
    then

        echo "❌ Impossible d'ajouter le SUBGID pour $user"

        # Rollback du SUBUID ajouté précédemment.
        sed -i "/^${user}:${start}:${range_size}$/d" /etc/subuid 2>/dev/null || true

        return 1
    fi

    # -------------------------------------------------------------------------
    # Vérification
    # -------------------------------------------------------------------------

    subuid_entry="$(
        grep "^${user}:${start}:${range_size}$" /etc/subuid \
            2>/dev/null \
            || true
    )"

    subgid_entry="$(
        grep "^${user}:${start}:${range_size}$" /etc/subgid \
            2>/dev/null \
            || true
    )"

    if [[ -z "$subuid_entry" || -z "$subgid_entry" ]]; then

        echo "❌ Vérification SUBUID/SUBGID échouée pour $user"

        sed -i "/^${user}:${start}:${range_size}$/d" /etc/subuid 2>/dev/null || true
        sed -i "/^${user}:${start}:${range_size}$/d" /etc/subgid 2>/dev/null || true

        return 1
    fi

    echo "✓ SUBUID configuré pour $user :"
    echo "  $subuid_entry"

    echo "✓ SUBGID configuré pour $user :"
    echo "  $subgid_entry"

    return 0
}

docker_rootless_restore_state() {

    ###############################################################################
    # RESTAURATION DE L'ÉTAT DOCKER ROOTLESS
    #
    # Relit :
    #
    #   config/states/<USER>/docker_rootless.state
    #
    # et restaure l'état système mémorisé avant la configuration Rootless.
    #
    # Cette fonction :
    #   - restaure le groupe primaire ;
    #   - restaure les groupes secondaires ;
    #   - restaure SUBUID ;
    #   - restaure SUBGID ;
    #   - restaure le lingering ;
    #   - restaure le contexte Docker.
    #
    # Elle ne :
    #   - démarre pas Docker Rootless ;
    #   - n'installe pas Docker Rootless ;
    #   - ne supprime pas les données Rootless ;
    #   - ne supprime pas l'état sauvegardé.
    #
    # Idempotence :
    #   Oui.
    ###############################################################################

    local user="${1:-}"

    local state_dir=""
    local state_file=""

    local state_version=""

    local saved_primary_group=""
    local saved_groups=""
    local saved_linger=""
    local saved_subuid=""
    local saved_subgid=""
    local saved_context=""

    local current_groups=""
    local group=""
    local group_found=""

    local -a saved_group_array=()

    # -------------------------------------------------------------------------
    # Validation
    # -------------------------------------------------------------------------

    if [[ -z "$user" ]]; then
        echo "❌ Utilisateur obligatoire."
        return 2
    fi

    if ! id "$user" >/dev/null 2>&1; then
        echo "❌ Utilisateur inexistant : $user"
        return 2
    fi

    # -------------------------------------------------------------------------
    # Localisation de l'état
    # -------------------------------------------------------------------------

    state_dir="${DIU_ROOT:-/root/diu}/config/states/${user}"
    state_file="${state_dir}/docker_rootless.state"

    if [[ ! -f "$state_file" ]]; then
        echo "⚠ Aucun état Docker Rootless pour $user"
        echo "  $state_file"
        return 1
    fi

    # -------------------------------------------------------------------------
    # Chargement de l'état
    # -------------------------------------------------------------------------

    unset \
        DOCKER_ROOTLESS_STATE_VERSION \
        DOCKER_ROOTLESS_USER \
        DOCKER_ROOTLESS_UID \
        DOCKER_ROOTLESS_GID \
        DOCKER_ROOTLESS_HOME \
        DOCKER_ROOTLESS_PRIMARY_GROUP \
        DOCKER_ROOTLESS_GROUPS \
        DOCKER_ROOTLESS_SUBUID \
        DOCKER_ROOTLESS_SUBGID \
        DOCKER_ROOTLESS_LINGER \
        DOCKER_ROOTLESS_CONTEXT \
        DOCKER_ROOTLESS_HOST \
        DOCKER_ROOTLESS_CONFIGURED

    # shellcheck disable=SC1090
    source "$state_file" || {
        echo "❌ Impossible de charger l'état : $state_file"
        return 1
    }

    state_version="${DOCKER_ROOTLESS_STATE_VERSION:-}"

    if [[ "$state_version" != "1" ]]; then
        echo "❌ Version d'état Docker Rootless inconnue : ${state_version:-absente}"
        return 1
    fi

    # -------------------------------------------------------------------------
    # Vérification cohérence utilisateur
    # -------------------------------------------------------------------------

    if [[ "${DOCKER_ROOTLESS_USER:-}" != "$user" ]]; then
        echo "❌ L'état ne correspond pas à l'utilisateur $user"
        return 1
    fi

    # -------------------------------------------------------------------------
    # Chargement des valeurs mémorisées
    # -------------------------------------------------------------------------

    saved_primary_group="${DOCKER_ROOTLESS_PRIMARY_GROUP:-}"
    saved_groups="${DOCKER_ROOTLESS_GROUPS:-}"
    saved_linger="${DOCKER_ROOTLESS_LINGER:-no}"
    saved_subuid="${DOCKER_ROOTLESS_SUBUID:-}"
    saved_subgid="${DOCKER_ROOTLESS_SUBGID:-}"
    saved_context="${DOCKER_ROOTLESS_CONTEXT:-default}"

    echo
    echo "=============================================================="
    echo " Restauration état Docker Rootless"
    echo "=============================================================="
    echo
    echo "Utilisateur : $user"
    echo "État        : $state_file"
    echo

    # -------------------------------------------------------------------------
    # Groupe primaire
    # -------------------------------------------------------------------------

    echo "▶ Groupe primaire"

    if [[ -n "$saved_primary_group" ]]; then

        if getent group "$saved_primary_group" >/dev/null 2>&1; then

            if [[ "$(id -gn "$user")" == "$saved_primary_group" ]]; then

                echo "✓ Groupe primaire déjà correct : $saved_primary_group"

            else

                usermod -g "$saved_primary_group" "$user" || {
                    echo "❌ Impossible de restaurer le groupe primaire"
                    return 1
                }

                echo "✓ Groupe primaire restauré : $saved_primary_group"

            fi

        else

            echo "❌ Groupe primaire inexistant : $saved_primary_group"
            return 1

        fi

    else

        echo "⚠ Aucun groupe primaire mémorisé"

    fi

    # -------------------------------------------------------------------------
    # Groupes secondaires
    #
    # DOCKER_ROOTLESS_GROUPS contient la liste complète des groupes de l'époque,
    # groupe primaire compris.
    #
    # On reconstruit donc la liste des groupes secondaires en excluant le groupe
    # primaire mémorisé.
    # -------------------------------------------------------------------------

    echo
    echo "▶ Groupes secondaires"

    current_groups="$(id -nG "$user" 2>/dev/null || true)"

    IFS=' ' read -r -a saved_group_array <<< "$saved_groups"

    # -------------------------------------------------------------------------
    # Suppression des groupes secondaires qui n'existaient pas dans l'état
    # sauvegardé.
    # -------------------------------------------------------------------------

    for group in $current_groups; do

        [[ -n "$group" ]] || continue

        # Le groupe primaire n'est pas un groupe secondaire.
        if [[ "$group" == "$saved_primary_group" ]]; then
            continue
        fi

        group_found=0

        for saved_group in "${saved_group_array[@]}"; do

            if [[ "$group" == "$saved_group" ]]; then
                group_found=1
                break
            fi

        done

        if (( group_found == 0 )); then

            echo "▶ Suppression du groupe non mémorisé : $group"

            gpasswd -d "$user" "$group" \
                >/dev/null 2>&1 \
                || true

        fi

    done

    # -------------------------------------------------------------------------
    # Ajout des groupes secondaires mémorisés.
    # -------------------------------------------------------------------------

    for group in "${saved_group_array[@]}"; do

        [[ -n "$group" ]] || continue

        # Le groupe primaire est déjà traité ci-dessus.
        if [[ "$group" == "$saved_primary_group" ]]; then
            continue
        fi

        if ! getent group "$group" >/dev/null 2>&1; then
            echo "⚠ Groupe mémorisé inexistant : $group"
            continue
        fi

        if id -nG "$user" 2>/dev/null \
            | tr ' ' '\n' \
            | grep -Fxq "$group"
        then

            echo "✓ Groupe déjà présent : $group"

        else

            usermod -aG "$group" "$user" || {
                echo "❌ Impossible d'ajouter le groupe : $group"
                return 1
            }

            echo "✓ Groupe restauré : $group"

        fi

    done

    # -------------------------------------------------------------------------
    # SUBUID
    # -------------------------------------------------------------------------

    echo
    echo "▶ SUBUID"

    sed -i "/^${user}:/d" /etc/subuid || {
        echo "❌ Impossible de nettoyer SUBUID pour $user"
        return 1
    }

    if [[ -n "$saved_subuid" ]]; then

        echo "$saved_subuid" >> /etc/subuid || {
            echo "❌ Impossible de restaurer SUBUID"
            return 1
        }

        echo "✓ SUBUID restauré"

    else

        echo "✓ Aucun SUBUID mémorisé"

    fi

    # -------------------------------------------------------------------------
    # SUBGID
    # -------------------------------------------------------------------------

    echo
    echo "▶ SUBGID"

    sed -i "/^${user}:/d" /etc/subgid || {
        echo "❌ Impossible de nettoyer SUBGID pour $user"
        return 1
    }

    if [[ -n "$saved_subgid" ]]; then

        echo "$saved_subgid" >> /etc/subgid || {
            echo "❌ Impossible de restaurer SUBGID"
            return 1
        }

        echo "✓ SUBGID restauré"

    else

        echo "✓ Aucun SUBGID mémorisé"

    fi

    # -------------------------------------------------------------------------
    # Linger
    # -------------------------------------------------------------------------

    echo
    echo "▶ Systemd lingering"

    if [[ "$saved_linger" == "yes" ]]; then

        loginctl enable-linger "$user" || {
            echo "❌ Impossible d'activer le lingering"
            return 1
        }

        echo "✓ Linger activé"

    else

        loginctl disable-linger "$user" \
            >/dev/null 2>&1 \
            || true

        echo "✓ Linger désactivé"

    fi

    # -------------------------------------------------------------------------
    # Contexte Docker
    # -------------------------------------------------------------------------

    echo
    echo "▶ Contexte Docker"

    if [[ -n "$saved_context" ]]; then

        if runuser -u "$user" -- \
            env -u DOCKER_HOST -u DOCKER_CONTEXT \
            docker context inspect "$saved_context" \
            >/dev/null 2>&1
        then

            runuser -u "$user" -- \
                env -u DOCKER_HOST -u DOCKER_CONTEXT \
                docker context use "$saved_context" \
                >/dev/null 2>&1 \
                || {
                    echo "❌ Impossible de restaurer le contexte Docker"
                    return 1
                }

            echo "✓ Contexte Docker restauré : $saved_context"

        else

            echo "⚠ Contexte Docker absent : $saved_context"

        fi

    else

        echo "✓ Aucun contexte Docker mémorisé"

    fi

    # -------------------------------------------------------------------------
    # Résultat
    # -------------------------------------------------------------------------

    echo
    echo "=============================================================="
    echo " État Docker Rootless restauré"
    echo "=============================================================="
    echo

    return 0
}

docker_rootless_unconfigure() {

    ###############################################################################
    # DÉCONFIGURATION DOCKER ROOTLESS
    #
    # Règle DIU :
    #   Rootless configuré     => USER ∉ groupe docker
    #   Rootless non configuré => USER ∈ groupe docker
    #
    # Le state ne décide JAMAIS de l'appartenance au groupe docker.
    #
    # Après suppression de Rootless :
    #   - le compte DOIT être membre de docker ;
    #   - le contexte DOIT être default ;
    #   - Docker Rootful DOIT être accessible ;
    #   - le state est supprimé uniquement si tout est validé.
    ###############################################################################

    local user="${1:-}"
    local uid=""
    local gid=""
    local home=""
    local runtime_dir=""

    local docker_service=""
    local docker_rootless_data=""
    local docker_rootless_config=""
    local systemd_user_dir=""
    local systemd_wants_dir=""
    local state_file=""

    local errors=0
    local warnings=0

    local service_state=""
    local current_context=""
    local docker_info=""

    # -------------------------------------------------------------------------
    # Validation
    # -------------------------------------------------------------------------

    if [[ -z "$user" ]]; then
        echo "❌ Le nom d'utilisateur est obligatoire."
        return 2
    fi

    if ! id "$user" >/dev/null 2>&1; then
        echo "❌ Utilisateur inexistant : $user"
        return 2
    fi

    uid="$(id -u "$user" 2>/dev/null || true)"
    gid="$(id -g "$user" 2>/dev/null || true)"
    home="$(getent passwd "$user" | cut -d: -f6)"

    if [[ -z "$home" || ! -d "$home" ]]; then
        echo "❌ HOME utilisateur introuvable : $home"
        return 1
    fi

    runtime_dir="/run/user/$uid"

    docker_service="${home}/.config/systemd/user/docker.service"
    systemd_user_dir="${home}/.config/systemd/user"
    systemd_wants_dir="${systemd_user_dir}/default.target.wants"

    docker_rootless_data="${home}/.local/share/docker"
    docker_rootless_config="${home}/.config/docker"

    state_file="/root/diu/config/states/${user}/docker_rootless.state"

    echo
    echo "=============================================================="
    echo " Déconfiguration Docker Rootless"
    echo "=============================================================="
    echo
    echo "USER       : $user"
    echo "UID        : $uid"
    echo "GID        : $gid"
    echo "HOME       : $home"
    echo "RUNTIME    : $runtime_dir"
    echo

    # -------------------------------------------------------------------------
    # Vérification state
    # -------------------------------------------------------------------------

    echo "▶ Vérification de l'état sauvegardé"

    if [[ -f "$state_file" ]]; then

        echo "✓ State trouvé :"
        echo "  $state_file"

    else

        echo "⚠ Aucun state trouvé"
        warnings=$((warnings + 1))

    fi

    # -------------------------------------------------------------------------
    # Arrêt Docker Rootless
    # -------------------------------------------------------------------------

    echo
    echo "▶ Arrêt Docker Rootless"

    runuser -u "$user" -- \
        env \
            XDG_RUNTIME_DIR="$runtime_dir" \
            DBUS_SESSION_BUS_ADDRESS="unix:path=${runtime_dir}/bus" \
        systemctl --user stop docker.service \
        >/dev/null 2>&1 \
        || true

    echo "✓ Service Docker Rootless arrêté"

    # -------------------------------------------------------------------------
    # Désinstallation officielle
    # -------------------------------------------------------------------------

    echo
    echo "▶ Suppression du service Docker Rootless"

    if command -v dockerd-rootless-setuptool.sh >/dev/null 2>&1; then

        runuser -u "$user" -- \
            env \
                XDG_RUNTIME_DIR="$runtime_dir" \
                DBUS_SESSION_BUS_ADDRESS="unix:path=${runtime_dir}/bus" \
            dockerd-rootless-setuptool.sh uninstall \
            >/dev/null 2>&1 \
            || true

        echo "✓ Désinstallation Rootless effectuée"

    else

        echo "⚠ Outil uninstall indisponible"
        warnings=$((warnings + 1))

    fi

    # -------------------------------------------------------------------------
    # Nettoyage systemd
    # -------------------------------------------------------------------------

    echo
    echo "▶ Nettoyage systemd user"

    rm -f "$docker_service" 2>/dev/null || true

    rm -f \
        "${systemd_wants_dir}/docker.service" \
        2>/dev/null || true

    runuser -u "$user" -- \
        env \
            XDG_RUNTIME_DIR="$runtime_dir" \
            DBUS_SESSION_BUS_ADDRESS="unix:path=${runtime_dir}/bus" \
        systemctl --user daemon-reload \
        >/dev/null 2>&1 \
        || true

    echo "✓ Résidus systemd Docker nettoyés"

    # -------------------------------------------------------------------------
    # Nettoyage contexte Rootless
    # -------------------------------------------------------------------------

    echo
    echo "▶ Nettoyage contexte Docker Rootless"

    runuser -u "$user" -- \
        docker context rm -f rootless \
        >/dev/null 2>&1 \
        || true

    echo "✓ Contexte 'rootless' absent"

    # -------------------------------------------------------------------------
    # Nettoyage données Rootless
    # -------------------------------------------------------------------------

    echo
    echo "▶ Nettoyage données Docker Rootless"

    if [[ -d "$docker_rootless_data" ]]; then

        echo "  Suppression : $docker_rootless_data"

        rm -rf "$docker_rootless_data" 2>/dev/null || true

        if [[ ! -e "$docker_rootless_data" ]]; then

            echo "✓ Données Rootless supprimées"

        else

            echo "⚠ Données Rootless encore présentes"
            warnings=$((warnings + 1))

        fi

    else

        echo "✓ Données Rootless absentes"

    fi

    # -------------------------------------------------------------------------
    # Nettoyage runtime
    # -------------------------------------------------------------------------

    echo
    echo "▶ Nettoyage runtime Rootless"

    rm -rf \
        "${runtime_dir}/docker" \
        "${runtime_dir}/dockerd-rootless" \
        2>/dev/null \
        || true

    if [[ ! -e "${runtime_dir}/docker" ]] \
        && [[ ! -e "${runtime_dir}/dockerd-rootless" ]]
    then

        echo "✓ Runtime Docker supprimé"

    else

        echo "⚠ Runtime Docker encore présent"
        warnings=$((warnings + 1))

    fi

    # -------------------------------------------------------------------------
    # Nettoyage configuration
    # -------------------------------------------------------------------------

    echo
    echo "▶ Nettoyage configuration Docker Rootless"

    if [[ -d "$docker_rootless_config" ]]; then

        rm -rf \
            "${docker_rootless_config}/contexts" \
            2>/dev/null \
            || true

        rm -f \
            "${docker_rootless_config}/daemon.json" \
            2>/dev/null \
            || true

        echo "✓ Configuration Rootless nettoyée"

    else

        echo "✓ Configuration Rootless absente"

    fi

    # -------------------------------------------------------------------------
    # Restauration état historique
    #
    # Le restore peut restaurer SUBUID/SUBGID, linger et contexte.
    # L'appartenance au groupe docker est volontairement IGNORÉE.
    # -------------------------------------------------------------------------

    echo
    echo "▶ Restauration de l'état initial"

    if [[ -f "$state_file" ]]; then

        if docker_rootless_restore_state "$user"; then

            echo "✓ État initial restauré"

        else

            echo "❌ Échec restauration état initial"
            errors=$((errors + 1))

        fi

    else

        echo "⚠ Aucun state à restaurer"

    fi

    # -------------------------------------------------------------------------
    # INVARIANT DIU :
    #
    # Rootless n'existe plus => USER DOIT être membre de docker.
    #
    # On ne regarde PAS ce que contenait le state.
    # -------------------------------------------------------------------------

    echo
    echo "▶ Garantie groupe Docker rootful"

    if ! getent group docker >/dev/null 2>&1; then

        echo "❌ Groupe docker inexistant"
        errors=$((errors + 1))

    elif id -nG "$user" 2>/dev/null \
        | tr ' ' '\n' \
        | grep -Fxq 'docker'
    then

        echo "✓ $user est membre du groupe docker"

    else

        echo "▶ Ajout de $user au groupe docker"

        if usermod -aG docker "$user" 2>/dev/null; then

            echo "✓ $user ajouté au groupe docker"

        else

            echo "❌ Impossible d'ajouter $user au groupe docker"
            errors=$((errors + 1))

        fi

    fi

    # -------------------------------------------------------------------------
    # Contexte Docker
    # -------------------------------------------------------------------------

    echo
    echo "▶ Vérification contexte Docker"

    runuser -u "$user" -- \
        docker context use default \
        >/dev/null 2>&1 \
        || true

    current_context="$(
        runuser -u "$user" -- \
            docker context show \
            2>/dev/null \
            || true
    )"

    if [[ "$current_context" == "default" ]]; then

        echo "✓ Contexte Docker : default"

    else

        echo "❌ Contexte Docker incorrect : ${current_context:-inconnu}"
        errors=$((errors + 1))

    fi

    # -------------------------------------------------------------------------
    # Vérification service Rootless
    # -------------------------------------------------------------------------

    echo
    echo "▶ Vérification Docker Rootless"

    service_state="$(
        runuser -u "$user" -- \
            env \
                XDG_RUNTIME_DIR="$runtime_dir" \
                DBUS_SESSION_BUS_ADDRESS="unix:path=${runtime_dir}/bus" \
            systemctl --user is-active docker.service \
            2>/dev/null \
            || true
    )"

    if [[ "$service_state" == "active" ]]; then

        echo "❌ docker.service Rootless encore actif"
        errors=$((errors + 1))

    else

        echo "✓ docker.service Rootless inactif"

    fi

    # -------------------------------------------------------------------------
    # Vérification socket
    # -------------------------------------------------------------------------

    echo
    echo "▶ Vérification socket Rootless"

    if [[ -S "${runtime_dir}/docker.sock" ]]; then

        echo "❌ Socket Rootless encore présent"
        errors=$((errors + 1))

    else

        echo "✓ Socket Rootless supprimé"

    fi

    # -------------------------------------------------------------------------
    # Vérification groupe docker
    # -------------------------------------------------------------------------

    echo
    echo "▶ Vérification groupe Docker"

    if id -nG "$user" 2>/dev/null \
        | tr ' ' '\n' \
        | grep -Fxq 'docker'
    then

        echo "✓ $user est membre du groupe docker"

    else

        echo "❌ $user n'est pas membre du groupe docker"
        errors=$((errors + 1))

    fi

    # -------------------------------------------------------------------------
    # Vérification Docker Rootful
    # -------------------------------------------------------------------------

    echo
    echo "▶ Vérification Docker Rootful"

    docker_info="$(
        runuser -u "$user" -- \
            env -u DOCKER_HOST \
            docker info \
            2>&1 \
            || true
    )"

    if grep -qE 'Server Version:' <<< "$docker_info"; then

        echo "✓ Docker Rootful accessible"

    else

        echo "❌ Docker Rootful inaccessible"
        errors=$((errors + 1))

    fi

    # -------------------------------------------------------------------------
    # Suppression du state UNIQUEMENT après succès complet
    # -------------------------------------------------------------------------

    if (( errors == 0 )); then

        if [[ -f "$state_file" ]]; then

            echo
            echo "▶ Suppression de l'état sauvegardé"

            if rm -f "$state_file" 2>/dev/null \
                && [[ ! -e "$state_file" ]]
            then

                echo "✓ State supprimé"

            else

                echo "⚠ Impossible de supprimer le state"
                warnings=$((warnings + 1))

            fi

        fi

    else

        echo
        echo "⚠ State conservé afin de permettre une nouvelle restauration."
        echo "  $state_file"

    fi

    # -------------------------------------------------------------------------
    # Résultat
    # -------------------------------------------------------------------------

    echo
    echo "=============================================================="
    echo " Résultat"
    echo "=============================================================="
    echo
    echo "Utilisateur : $user"
    echo "Erreurs     : $errors"
    echo "Warnings    : $warnings"

    if (( errors == 0 )); then

        echo
        echo "DOCKER ROOTLESS ${user} : DÉCONFIGURÉ ✅"
        echo "DOCKER ROOTFUL ${user} : ENVIRONNEMENT RESTAURÉ ✅"

        if (( warnings > 0 )); then
            echo "⚠ ${warnings} warning(s) détecté(s)."
        fi

        return 0

    fi

    echo
    echo "DOCKER ROOTLESS ${user} : DÉCONFIGURATION INCOMPLÈTE ❌"

    return 1
}

is_docker_rootless_configured() {

    local user="${1:-}"
    local uid=""
    local runtime_dir=""

    if [[ -z "$user" ]]; then
        return 1
    fi

    if ! id "$user" >/dev/null 2>&1; then
        return 1
    fi

    uid="$(id -u "$user" 2>/dev/null || true)"

    if [[ -z "$uid" ]]; then
        return 1
    fi

    runtime_dir="/run/user/${uid}"

    # -------------------------------------------------------------------------
    # Service systemd Rootless
    # -------------------------------------------------------------------------

    if ! runuser -u "$user" -- \
        env \
            XDG_RUNTIME_DIR="$runtime_dir" \
            DBUS_SESSION_BUS_ADDRESS="unix:path=${runtime_dir}/bus" \
        systemctl --user is-active --quiet docker.service
    then
        return 1
    fi

    # -------------------------------------------------------------------------
    # Socket Docker Rootless
    # -------------------------------------------------------------------------

    if [[ ! -S "${runtime_dir}/docker.sock" ]]; then
        return 1
    fi

    # -------------------------------------------------------------------------
    # Docker daemon Rootless
    #
    # On force explicitement DOCKER_HOST afin de ne dépendre ni du
    # contexte courant ni de l'environnement utilisateur.
    # -------------------------------------------------------------------------

    if ! runuser -u "$user" -- \
        env \
            DOCKER_HOST="unix://${runtime_dir}/docker.sock" \
            docker info \
            >/dev/null 2>&1
    then
        return 1
    fi

    return 0
}

docker_rootless_configure() {

    ###############################################################################
    # CONFIGURATION DOCKER ROOTLESS
    #
    # État par défaut d'un compte de service :
    #   - membre du groupe docker ;
    #   - Docker Rootful accessible ;
    #   - Docker Rootless absent ;
    #   - contexte Docker default ;
    #   - aucun state.
    #
    # État Rootless :
    #   - NON membre du groupe docker ;
    #   - Docker Rootful inaccessible ;
    #   - Docker Rootless actif ;
    #   - contexte Docker rootless ;
    #   - state sauvegardé.
    #
    # Le state est conservé tant que la configuration Rootless n'est pas
    # complètement validée.
    ###############################################################################

    local user="${1:-}"

    local uid=""
    local gid=""
    local home=""
    local runtime_dir=""
    local state_file=""

    local subuid_entry=""
    local subgid_entry=""
    local subuid_start="362144"
    local subgid_start="362144"
    local subuid_count="65536"
    local subgid_count="65536"
    local subuid_end=""
    local subgid_end=""

    local docker_info=""
    local service_state=""
    local current_context=""

    local errors=0
    local warnings=0

    # -------------------------------------------------------------------------
    # Validation
    # -------------------------------------------------------------------------

    if [[ -z "$user" ]]; then
        echo "❌ Le nom d'utilisateur est obligatoire."
        return 2
    fi

    if ! id "$user" >/dev/null 2>&1; then
        echo "❌ Utilisateur inexistant : $user"
        return 2
    fi

    uid="$(id -u "$user" 2>/dev/null || true)"
    gid="$(id -g "$user" 2>/dev/null || true)"
    home="$(getent passwd "$user" | cut -d: -f6)"

    if [[ -z "$home" || ! -d "$home" ]]; then
        echo "❌ HOME utilisateur introuvable : $home"
        return 1
    fi

    runtime_dir="/run/user/$uid"
    state_file="/root/diu/config/states/${user}/docker_rootless.state"

    # Calcul de la dernière plage SUBUID/SUBGID.
    subuid_end=$((subuid_start + subuid_count - 1))
    subgid_end=$((subgid_start + subgid_count - 1))

    # -------------------------------------------------------------------------
    # Informations
    # -------------------------------------------------------------------------

    echo
    echo "=============================================================="
    echo " Configuration Docker Rootless"
    echo "=============================================================="
    echo
    echo "USER       : $user"
    echo "UID        : $uid"
    echo "HOME       : $home"
    echo "RUNTIME    : $runtime_dir"
    echo

    # -------------------------------------------------------------------------
    # Prérequis
    # -------------------------------------------------------------------------

    echo "▶ Vérification des prérequis"

    if command -v dockerd-rootless-setuptool.sh >/dev/null 2>&1; then
        echo "✓ dockerd-rootless-setuptool.sh"
    else
        echo "❌ dockerd-rootless-setuptool.sh absent"
        errors=$((errors + 1))
    fi

    if command -v dockerd-rootless.sh >/dev/null 2>&1; then
        echo "✓ dockerd-rootless.sh"
    else
        echo "❌ dockerd-rootless.sh absent"
        errors=$((errors + 1))
    fi

    if command -v newuidmap >/dev/null 2>&1; then
        echo "✓ newuidmap"
    else
        echo "❌ newuidmap absent"
        errors=$((errors + 1))
    fi

    if command -v newgidmap >/dev/null 2>&1; then
        echo "✓ newgidmap"
    else
        echo "❌ newgidmap absent"
        errors=$((errors + 1))
    fi

    if command -v loginctl >/dev/null 2>&1; then
        echo "✓ loginctl"
    else
        echo "❌ loginctl absent"
        errors=$((errors + 1))
    fi

    if (( errors > 0 )); then
        return 1
    fi

    # -------------------------------------------------------------------------
    # Détection Rootless déjà configuré
    # -------------------------------------------------------------------------

    service_state="$(
        runuser -u "$user" -- \
            env \
                XDG_RUNTIME_DIR="$runtime_dir" \
                DBUS_SESSION_BUS_ADDRESS="unix:path=${runtime_dir}/bus" \
            systemctl --user is-active docker.service \
            2>/dev/null \
            || true
    )"

    current_context="$(
        runuser -u "$user" -- \
            docker context show \
            2>/dev/null \
            || true
    )"

    if [[ "$service_state" == "active" ]] \
        && [[ -S "${runtime_dir}/docker.sock" ]] \
        && [[ "$current_context" == "rootless" ]]
    then

        echo
        echo "✓ DOCKER ROOTLESS FOR $user ALREADY CONFIGURED"

        return 0

    fi

    # -------------------------------------------------------------------------
    # Préparation accès Docker Rootful
    #
    # Le groupe docker est toujours l'état par défaut.
    # On garantit donc sa présence avant la sauvegarde.
    # -------------------------------------------------------------------------

    echo
    echo "▶ Préparation accès Docker Rootful"

    if ! getent group docker >/dev/null 2>&1; then
        echo "❌ Groupe docker inexistant"
        return 1
    fi

    if id -nG "$user" 2>/dev/null \
        | tr ' ' '\n' \
        | grep -Fxq 'docker'
    then

        echo "✓ $user est membre du groupe docker"

    else

        echo "▶ Ajout de $user au groupe docker"

        if usermod -aG docker "$user" >/dev/null 2>&1; then
            echo "✓ $user ajouté au groupe docker"
        else
            echo "❌ Impossible d'ajouter $user au groupe docker"
            return 1
        fi

    fi

    # -------------------------------------------------------------------------
    # Sauvegarde de l'état initial
    #
    # UNE SEULE SAUVEGARDE.
    # -------------------------------------------------------------------------

    echo
    echo "▶ Sauvegarde de l'état actuel"

    mkdir -p \
        "/root/diu/config/states/${user}" \
        2>/dev/null \
        || true

    if [[ -f "$state_file" ]]; then

        echo "✓ État Docker Rootless déjà sauvegardé :"
        echo "  $state_file"

    else

        if declare -F docker_rootless_save_state >/dev/null 2>&1; then

            if docker_rootless_save_state "$user"; then

                echo "✓ État Docker Rootless sauvegardé :"
                echo "  $state_file"

            else

                echo "❌ Échec de la sauvegarde de l'état Docker Rootless"
                return 1

            fi

        else

            echo "❌ Fonction docker_rootless_save_state indisponible"
            return 1

        fi

    fi

    # -------------------------------------------------------------------------
    # Retrait temporaire du groupe docker
    # -------------------------------------------------------------------------

    echo
    echo "▶ Retrait temporaire du groupe docker"

    if id -nG "$user" 2>/dev/null \
        | tr ' ' '\n' \
        | grep -Fxq 'docker'
    then

        if gpasswd -d "$user" docker >/dev/null 2>&1; then
            echo "✓ $user retiré temporairement du groupe docker"
        else
            echo "❌ Impossible de retirer $user du groupe docker"
            return 1
        fi

    else

        echo "✓ $user n'est pas membre du groupe docker"

    fi

    # -------------------------------------------------------------------------
    # Vérification Docker Rootful
    # -------------------------------------------------------------------------

    echo
    echo "▶ Vérification Docker Rootful"

    docker_info="$(
        runuser -u "$user" -- \
            env -u DOCKER_HOST \
            docker info \
            2>&1 \
            || true
    )"

    if grep -qE 'Server Version:' <<< "$docker_info"; then

        echo "❌ Docker Rootful reste accessible pour $user."
        echo
        echo "Docker Rootless ne peut pas être installé tant que Docker"
        echo "Rootful est accessible."
        echo
        echo "⚠ Le state est conservé afin de permettre une restauration."
        echo "  $state_file"

        return 1

    fi

    echo "✓ Docker Rootful inaccessible"

    # -------------------------------------------------------------------------
    # Préparation SUBUID / SUBGID
    # -------------------------------------------------------------------------

    echo
    echo "▶ Préparation SUBUID/SUBGID"

    subuid_entry="$(
        grep -E "^${user}:" /etc/subuid 2>/dev/null \
            | head -n1 \
            || true
    )"

    subgid_entry="$(
        grep -E "^${user}:" /etc/subgid 2>/dev/null \
            | head -n1 \
            || true
    )"

    # -------------------------------------------------------------------------
    # SUBUID
    # -------------------------------------------------------------------------

    if [[ -z "$subuid_entry" ]]; then

        if usermod \
            --add-subuids "${subuid_start}-${subuid_end}" \
            "$user" \
            >/dev/null 2>&1
        then

            echo "✓ SUBUID configuré pour $user :"
            echo "  ${user}:${subuid_start}:${subuid_count}"

        else

            echo "❌ Impossible de configurer SUBUID pour $user"
            echo
            echo "⚠ Le state est conservé afin de permettre une restauration."
            echo "  $state_file"

            return 1

        fi

    else

        echo "✓ SUBUID déjà configuré pour $user"
        echo "  $subuid_entry"

    fi

    # -------------------------------------------------------------------------
    # SUBGID
    # -------------------------------------------------------------------------

    if [[ -z "$subgid_entry" ]]; then

        if usermod \
            --add-subgids "${subgid_start}-${subgid_end}" \
            "$user" \
            >/dev/null 2>&1
        then

            echo "✓ SUBGID configuré pour $user :"
            echo "  ${user}:${subgid_start}:${subgid_count}"

        else

            echo "❌ Impossible de configurer SUBGID pour $user"
            echo
            echo "⚠ Le state est conservé afin de permettre une restauration."
            echo "  $state_file"

            return 1

        fi

    else

        echo "✓ SUBGID déjà configuré pour $user"
        echo "  $subgid_entry"

    fi

    echo "✓ SUBUID/SUBGID configurés pour $user"

    # -------------------------------------------------------------------------
    # Systemd lingering
    # -------------------------------------------------------------------------

    echo
    echo "▶ Configuration systemd lingering"

    if [[ "$(loginctl show-user "$user" -p Linger --value 2>/dev/null || true)" == "yes" ]]; then

        echo "✓ Linger déjà activé"

    else

        if loginctl enable-linger "$user" >/dev/null 2>&1; then
            echo "✓ Linger activé"
        else
            echo "❌ Impossible d'activer le linger"
            echo
            echo "⚠ Le state est conservé afin de permettre une restauration."
            echo "  $state_file"
            return 1
        fi

    fi

    # -------------------------------------------------------------------------
    # User Manager
    # -------------------------------------------------------------------------

    echo
    echo "▶ Activation du User Manager"

    if systemctl start "user@${uid}.service" >/dev/null 2>&1; then

        echo "✓ user@${uid}.service actif"

    else

        echo "❌ Impossible d'activer user@${uid}.service"
        echo
        echo "⚠ Le state est conservé afin de permettre une restauration."
        echo "  $state_file"

        return 1

    fi

    # -------------------------------------------------------------------------
    # Installation Docker Rootless
    # -------------------------------------------------------------------------

    echo
    echo "▶ Installation Docker Rootless"

    if ! runuser -u "$user" -- \
        env \
            XDG_RUNTIME_DIR="$runtime_dir" \
            DBUS_SESSION_BUS_ADDRESS="unix:path=${runtime_dir}/bus" \
        dockerd-rootless-setuptool.sh install
    then

        echo "❌ Échec de l'installation Docker Rootless"
        echo
        echo "⚠ Le state est conservé afin de permettre une restauration."
        echo "  $state_file"

        return 1

    fi

    # -------------------------------------------------------------------------
    # Configuration du contexte Docker
    # -------------------------------------------------------------------------

    echo
    echo "▶ Configuration contexte Docker"

    if runuser -u "$user" -- \
        docker context use rootless \
        >/dev/null 2>&1
    then

        echo "✓ Contexte Docker : rootless"

    else

        echo "❌ Impossible de sélectionner le contexte Docker rootless"
        echo
        echo "⚠ Le state est conservé afin de permettre une restauration."
        echo "  $state_file"

        return 1

    fi

    # -------------------------------------------------------------------------
    # Vérification finale
    # -------------------------------------------------------------------------

    echo
    echo "▶ Vérification finale"

    if declare -F docker_rootless_analyse >/dev/null 2>&1; then

        if ! docker_rootless_analyse "$user"; then

            echo
            echo "❌ Vérification finale Docker Rootless échouée"
            echo
            echo "⚠ Le state est conservé afin de permettre une restauration."
            echo "  $state_file"

            return 1

        fi

    else

        echo "⚠ Fonction docker_rootless_analyse indisponible"
        warnings=$((warnings + 1))

    fi

    # -------------------------------------------------------------------------
    # Résultat
    # -------------------------------------------------------------------------

    echo
    echo "=============================================================="
    echo " Docker Rootless configuré"
    echo "=============================================================="
    echo
    echo "Utilisateur : $user"
    echo "✓ Configuration Docker Rootless terminée avec succès."

    if (( warnings > 0 )); then
        echo "⚠ ${warnings} warning(s) détecté(s)."
    fi

    return 0
}

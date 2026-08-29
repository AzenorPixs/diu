#!/usr/bin/env bash

# Fonctions de gestion de Hermes Agent
#
# Hermes fonctionne ici avec Docker ROOTFUL.
#
# Principe :
#   - Docker daemon rootful
#   - docker compose exécuté directement
#   - conteneur Hermes exécuté en root (UID/GID 0)
#   - aucun socket Docker Rootless
#   - aucun XDG_RUNTIME_DIR spécifique à l'utilisateur IA
#
# Les fichiers de configuration du projet Hermes restent possédés
# par ENV_IA_USER:ENV_IA_GROUP côté hôte.
#
# Les fichiers créés par Hermes dans ./data peuvent appartenir à root
# puisque Hermes fonctionne en root dans le conteneur.


# ==========================================================
# HERMES AGENT
# ==========================================================

# ----------------------------------------------------------
# Variables attendues depuis VARIABLES.sh
# ----------------------------------------------------------
#
# ENV_IA_USER
# ENV_IA_GROUP
# ENV_IA_HERMES
# DOCKER_IMAGE_HERMES
#
# ENV_IA_HERMES_API_ENABLED
# ENV_IA_HERMES_API_HOST
# ENV_IA_HERMES_API_PORT
# ENV_IA_HERMES_MODEL
#
# ENV_IA_HERMES_DASHBOARD
# ENV_IA_HERMES_DASHBOARD_HOST
# ENV_IA_HERMES_DASHBOARD_PORT
#
# ENV_IA_HERMES_YOLO
# ENV_IA_HERMES_REDACT_SECRETS
# ENV_IA_HERMES_WRITE_SAFE_ROOT
#
# ENV_IA_HERMES_MAX_ITERATIONS
# ENV_IA_HERMES_TIMEZONE
#
# ----------------------------------------------------------


# ==========================================================
# HERMES - OUTILS INTERNES
# ==========================================================

_hermes_dir() {
    echo "/home/${ENV_IA_USER}/hermes"
}

_hermes_dir_data_cont_initd() {
    echo "/home/${ENV_IA_USER}/hermes/data/cont-init.d"
}

_hermes_env_file() {
    echo "$(_hermes_dir)/.env"
}


_hermes_compose_file() {
    echo "$(_hermes_dir)/compose.yml"
}

_10_tune_hermes() {
    echo "$(_hermes_dir)/data/cont-init.d/10_tune_hermes"
}


_hermes_data_dir() {
    echo "$(_hermes_dir)/data"
}


# ==========================================================
# DOCKER ROOTFUL
# ==========================================================

# ------------------10_tune_hermes----------------------------------------
# Vérification de Docker Rootful
# ----------------------------------------------------------
#
# Hermes utilise le daemon Docker rootful.
#
# Le socket Docker attendu est :
#
#   /var/run/docker.sock
#
# Aucun contexte Docker Rootless n'est nécessaire.
# ----------------------------------------------------------

_hermes_check_docker() {

    if ! command -v docker >/dev/null 2>&1; then
        echo "❌ Docker n'est pas installé." >&2
        return 1
    fi

    if [ ! -S "/var/run/docker.sock" ]; then
        echo "❌ Socket Docker rootful introuvable : /var/run/docker.sock" >&2
        return 1
    fi

    if ! docker info >/dev/null 2>&1; then
        echo "❌ Le daemon Docker rootful n'est pas accessible." >&2
        return 1
    fi

    return 0
}


# ----------------------------------------------------------
# docker compose Hermes
# ----------------------------------------------------------
#
# Exécution directe dans le contexte rootful.
# ----------------------------------------------------------

_hermes_compose() {

    local dir

    dir="$(_hermes_dir)"

    if [ ! -d "$dir" ]; then
        echo "❌ Répertoire Hermes introuvable : $dir" >&2
        return 1
    fi

    cd "$dir" || return 1

    docker compose -f compose.yml "$@"
}

# ==========================================================
# DETECTION INSTALLATION
# ==========================================================

is_agent_hermes_installed() {

    local dir

    dir="$(_hermes_dir)"

    [ -f "$dir/compose.yml" ] &&
    [ -f "$dir/.env" ] &&
    _hermes_check_docker &&
    _hermes_compose ps --status running 2>/dev/null |
        grep -q hermes
}

# ==========================================================
# GENERATION .ENV
# ==========================================================

_hermes_generate_env() {

    local env_file
    local openai_key=""
    local openai_url=""
    local deepseek_key=""
    local deepseek_url=""
    local openrouter_key=""
    local openrouter_url=""
    local opengo_key=""
    local opengo_url=""

    local api_server_key=""

    local hermes_webui_password=""

    local hermes_dashboard_basic_auth_username=""
    local hermes_dashboard_basic_auth_password=""
    local hermes_dashboard_basic_auth_secret=""

    local default_openai_url="https://api.openai.com/v1"
    local default_deepseek_url="https://api.deepseek.com"
    local default_openrouter_url="https://openrouter.ai/api/v1"
    local default_opengo_url="https://opencode.ai/zen/go/v1"

    local prompt


    env_file="$(_hermes_env_file)"


    # ======================================================
    # Lecture contrôlée du .env existant
    # ======================================================

    if [ -f "$env_file" ]; then

        echo ""
        echo "▶ Lecture de la configuration existante..."

        openai_key="$(
            sed -n 's/^OPENAI_API_KEY="\([^"]*\)"$/\1/p' "$env_file" |
            head -n1
        )"

        openai_url="$(
            sed -n 's/^OPENAI_BASE_URL="\([^"]*\)"$/\1/p' "$env_file" |
            head -n1
        )"

        deepseek_key="$(
            sed -n 's/^DEEPSEEK_API_KEY="\([^"]*\)"$/\1/p' "$env_file" |
            head -n1
        )"

        deepseek_url="$(
            sed -n 's/^DEEPSEEK_BASE_URL="\([^"]*\)"$/\1/p' "$env_file" |
            head -n1
        )"

        openrouter_key="$(
            sed -n 's/^OPENROUTER_API_KEY="\([^"]*\)"$/\1/p' "$env_file" |
            head -n1
        )"

        openrouter_url="$(
            sed -n 's/^OPENROUTER_BASE_URL="\([^"]*\)"$/\1/p' "$env_file" |
            head -n1
        )"

        opengo_key="$(
            sed -n 's/^OPENCODE_GO_API_KEY="\([^"]*\)"$/\1/p' "$env_file" |
            head -n1
        )"

        opengo_url="$(
            sed -n 's/^OPENCODE_GO_BASE_URL="\([^"]*\)"$/\1/p' "$env_file" |
            head -n1
        )"


        api_server_key="$(
            sed -n 's/^API_SERVER_KEY="\([^"]*\)"$/\1/p' "$env_file" |
            head -n1
        )"

        hermes_webui_password="$(
            sed -n 's/^HERMES_WEBUI_PASSWORD="\([^"]*\)"$/\1/p' "$env_file" |
            head -n1
        )"

        hermes_dashboard_basic_auth_username="$(
            sed -n 's/^HERMES_DASHBOARD_BASIC_AUTH_USERNAME="\([^"]*\)"$/\1/p' "$env_file" |
            head -n1
        )"

        hermes_dashboard_basic_auth_password="$(
            sed -n 's/^HERMES_DASHBOARD_BASIC_AUTH_PASSWORD="\([^"]*\)"$/\1/p' "$env_file" |
            head -n1
        )"

        hermes_dashboard_basic_auth_secret="$(
            sed -n 's/^HERMES_DASHBOARD_BASIC_AUTH_SECRET="\([^"]*\)"$/\1/p' "$env_file" |
            head -n1
        )"

        echo "✓ Configuration existante chargée"
    fi


    # ======================================================
    # Valeurs par défaut des Base URL
    # ======================================================

    openai_url="${openai_url:-$default_openai_url}"
    deepseek_url="${deepseek_url:-$default_deepseek_url}"
    openrouter_url="${openrouter_url:-$default_openrouter_url}"
    opengo_url="${opengo_url:-$default_opengo_url}"


    # ======================================================
    # OpenAI
    # ======================================================

    echo ""
    echo "▶ OpenAI"

    if [ -n "$openai_key" ]; then
        printf 'API KEY [********%s] : ' "${openai_key: -4}"
    else
        printf 'API KEY : '
    fi

    read -r -s prompt
    echo ""

    if [ -n "$prompt" ]; then
        openai_key="$prompt"
    fi

    read -r -p "BASE URL [${openai_url}] : " prompt

    if [ -n "$prompt" ]; then
        openai_url="$prompt"
    fi


    # ======================================================
    # DeepSeek
    # ======================================================

    echo ""
    echo "▶ DeepSeek"

    if [ -n "$deepseek_key" ]; then
        printf 'API KEY [********%s] : ' "${deepseek_key: -4}"
    else
        printf 'API KEY : '
    fi

    read -r -s prompt
    echo ""

    if [ -n "$prompt" ]; then
        deepseek_key="$prompt"
    fi

    read -r -p "BASE URL [${deepseek_url}] : " prompt

    if [ -n "$prompt" ]; then
        deepseek_url="$prompt"
    fi


    # ======================================================
    # OpenRouter
    # ======================================================

    echo ""
    echo "▶ OpenRouter"

    if [ -n "$openrouter_key" ]; then
        printf 'API KEY [********%s] : ' "${openrouter_key: -4}"
    else
        printf 'API KEY : '
    fi

    read -r -s prompt
    echo ""

    if [ -n "$prompt" ]; then
        openrouter_key="$prompt"
    fi

    read -r -p "BASE URL [${openrouter_url}] : " prompt

    if [ -n "$prompt" ]; then
        openrouter_url="$prompt"
    fi


    # ======================================================
    # OpenCode Go
    # ======================================================

    echo ""
    echo "▶ OpenCode Go"

    if [ -n "$opengo_key" ]; then
        printf 'API KEY [********%s] : ' "${opengo_key: -4}"
    else
        printf 'API KEY : '
    fi

    read -r -s prompt
    echo ""

    if [ -n "$prompt" ]; then
        opengo_key="$prompt"
    fi

    read -r -p "BASE URL [${opengo_url}] : " prompt

    if [ -n "$prompt" ]; then
        opengo_url="$prompt"
    fi


    # ======================================================
    # API SERVER KEY
    # ======================================================

    if [ -z "$api_server_key" ]; then

        api_server_key="$(openssl rand -hex 32)"

        echo ""
        echo "▶ Génération de la clé API Hermes..."
        echo "✓ API_SERVER_KEY générée"

    fi


    # ======================================================
    # HERMES WEBUI PASSWORD
    # ======================================================

    echo ""
    echo "▶ Hermes WebUI"

    if [ -n "$hermes_webui_password" ]; then
        printf 'HERMES WEBUI PASSWORD [********%s] : ' \
            "${hermes_webui_password: -4}"
    else
        printf 'HERMES WEBUI PASSWORD : '
    fi

    read -r -s prompt
    echo ""

    if [ -n "$prompt" ]; then
        hermes_webui_password="$prompt"
    fi


    # ======================================================
    # HERMES DASHBOARD BASIC AUTH
    # ======================================================

    echo ""
    echo "▶ Hermes Dashboard - Basic Auth"

    # ------------------------------------------------------
    # Username
    # ------------------------------------------------------

    if [ -n "$hermes_dashboard_basic_auth_username" ]; then

        printf 'USERNAME [%s] : ' \
            "$hermes_dashboard_basic_auth_username"

    else

        printf 'USERNAME [admin] : '

    fi

    read -r prompt

    if [ -n "$prompt" ]; then

        hermes_dashboard_basic_auth_username="$prompt"

    elif [ -z "$hermes_dashboard_basic_auth_username" ]; then

        hermes_dashboard_basic_auth_username="admin"

    fi


    # ------------------------------------------------------
    # Password
    # ------------------------------------------------------

    if [ -n "$hermes_dashboard_basic_auth_password" ]; then

        printf 'PASSWORD [********%s] : ' \
            "${hermes_dashboard_basic_auth_password: -4}"

    else

        printf 'PASSWORD : '

    fi

    read -r -s prompt
    echo ""

    if [ -n "$prompt" ]; then

        hermes_dashboard_basic_auth_password="$prompt"

    fi


    # ------------------------------------------------------
    # Secret
    # ------------------------------------------------------

    if [ -z "$hermes_dashboard_basic_auth_secret" ]; then

        hermes_dashboard_basic_auth_secret="$(openssl rand -hex 32)"

        echo ""
        echo "▶ Génération du secret Dashboard Hermes..."
        echo "✓ HERMES_DASHBOARD_BASIC_AUTH_SECRET généré"

    fi


    # ======================================================
    # Génération du .env
    # ======================================================

    echo ""
    echo "▶ Génération du .env..."

    umask 077

    cat > "$env_file" <<EOF
# ==========================================================
# HERMES - PROVIDERS
# ==========================================================

OPENAI_API_KEY="${openai_key}"
OPENAI_BASE_URL="${openai_url}"

DEEPSEEK_API_KEY="${deepseek_key}"
DEEPSEEK_BASE_URL="${deepseek_url}"

OPENROUTER_API_KEY="${openrouter_key}"
OPENROUTER_BASE_URL="${openrouter_url}"

OPENCODE_GO_API_KEY="${opengo_url}"
OPENCODE_GO_BASE_URL="${openrouter_url}"

# ==========================================================
# HERMES - API SERVER
# ==========================================================

API_SERVER_KEY="${api_server_key}"

# ==========================================================
# HERMES - WEBUI PASSWORD
# ==========================================================

HERMES_WEBUI_PASSWORD="${hermes_webui_password}"

# ==========================================================
# HERMES - DASHBOARD BASIC AUTH
# ==========================================================

HERMES_DASHBOARD_BASIC_AUTH_USERNAME="${hermes_dashboard_basic_auth_username}"
HERMES_DASHBOARD_BASIC_AUTH_PASSWORD="${hermes_dashboard_basic_auth_password}"
HERMES_DASHBOARD_BASIC_AUTH_SECRET="${hermes_dashboard_basic_auth_secret}"
EOF

    chown "${ENV_IA_USER}:${ENV_IA_GROUP}" "$env_file"
    chmod 0660 "$env_file"


    # ======================================================
    # Nettoyage
    # ======================================================

    unset openai_key
    unset deepseek_key
    unset openrouter_key
    unset api_server_key
    unset hermes_webui_password

    unset hermes_dashboard_basic_auth_username
    unset hermes_dashboard_basic_auth_password
    unset hermes_dashboard_basic_auth_secret

    unset prompt

    echo "✓ .env généré"
}

# ==========================================================
# GENERATION COMPOSE / 
# ==========================================================

_hermes_generate_compose() {

    local compose_file
    local dir
    local uid
    local gid

    dir="$(_hermes_dir)"
    compose_file="$(_hermes_compose_file)"

    uid="$(id -u "${ENV_IA_USER:-}")" || return 1
    gid="$(id -g "${ENV_IA_USER:-}")" || return 1

    echo ""
    echo "▶ Génération du compose.yml..."
    echo "   Docker : ROOTFUL"
    echo "   Hermes : utilisateur Docker de l'hôte"
    echo "   UID    : ${uid}"
    echo "   GID    : ${gid}"
    echo "   Socket : /var/run/docker.sock"

    cat > "$compose_file" <<EOF
services:

  hermes:

    image: ${DOCKER_IMAGE_HERMES}

    container_name: hermes
    hostname: hermes

    command:
      - gateway
      - run

    restart: unless-stopped

    group_add:
      - "1001"

    env_file:
      - .env

    environment:

      # ------------------------------------------------------
      # Hermes
      # ------------------------------------------------------

      HERMES_HOME: /opt/data

      # ------------------------------------------------------
      # Hermes Docker identity
      # ------------------------------------------------------

      HERMES_UID: "$uid"
      HERMES_GID: "$gid"

      # ------------------------------------------------------
      # Docker rootful
      # ------------------------------------------------------

      DOCKER_HOST: unix:///var/run/docker.sock

      # ------------------------------------------------------
      # API Server + Dashboard
      # ------------------------------------------------------

      API_SERVER_ENABLED: "${ENV_IA_HERMES_API_ENABLED}"
      API_SERVER_HOST: "${ENV_IA_HERMES_API_HOST}"
      API_SERVER_PORT: "${ENV_IA_HERMES_API_PORT}"

      HERMES_DASHBOARD: "${ENV_IA_HERMES_DASHBOARD}"
      HERMES_DASHBOARD_HOST: "${ENV_IA_HERMES_DASHBOARD_HOST}"

      # ------------------------------------------------------
      # Dashboard Basic Auth
      # ------------------------------------------------------

      HERMES_DASHBOARD_BASIC_AUTH_USERNAME: "\${HERMES_DASHBOARD_BASIC_AUTH_USERNAME}"
      HERMES_DASHBOARD_BASIC_AUTH_PASSWORD: "\${HERMES_DASHBOARD_BASIC_AUTH_PASSWORD}"
      HERMES_DASHBOARD_BASIC_AUTH_SECRET: "\${HERMES_DASHBOARD_BASIC_AUTH_SECRET}"

      # ------------------------------------------------------
      # API Server
      # ------------------------------------------------------

      API_SERVER_KEY: "\${API_SERVER_KEY}"

      # ------------------------------------------------------
      # Providers
      # ------------------------------------------------------

      OPENAI_API_KEY: "\${OPENAI_API_KEY}"
      OPENAI_BASE_URL: "\${OPENAI_BASE_URL}"

      DEEPSEEK_API_KEY: "\${DEEPSEEK_API_KEY}"
      DEEPSEEK_BASE_URL: "\${DEEPSEEK_BASE_URL}"

      OPENROUTER_API_KEY: "\${OPENROUTER_API_KEY}"
      OPENROUTER_BASE_URL: "\${OPENROUTER_BASE_URL}"

      OPENCODE_GO_API_KEY: "\${OPENCODE_GO_API_KEY}"
      OPENCODE_GO_BASE_URL: "\${OPENCODE_GO_BASE_URL}"

      # ------------------------------------------------------
      # Agent
      # ------------------------------------------------------

      HERMES_MAX_ITERATIONS: "${ENV_IA_HERMES_MAX_ITERATIONS}"
      HERMES_TIMEZONE: "${ENV_IA_HERMES_TIMEZONE}"

      # ------------------------------------------------------
      # Sécurité
      # ------------------------------------------------------

      HERMES_YOLO_MODE: "${ENV_IA_HERMES_YOLO}"
      HERMES_REDACT_SECRETS: "${ENV_IA_HERMES_REDACT_SECRETS}"
      HERMES_WRITE_SAFE_ROOT: "${ENV_IA_HERMES_WRITE_SAFE_ROOT}"

    volumes:

      - /home/${ENV_IA_USER}/hermes/data:/opt/data
      - /home/${ENV_IA_USER}/hermes/data/cont-init.d/10_tune_hermes:/etc/cont-init.d/10_tune_hermes:ro
      - /home/${ENV_IA_USER}/download:/opt/download
      - /home/${ENV_IA_USER}/tools:/opt/tools
      - /home/${ENV_DEVOPS_USER}/datas:/opt/devops:ro
      - /var/run/docker.sock:/var/run/docker.sock

    ports:

      - "${ENV_IA_HERMES_API_PORT}:${ENV_IA_HERMES_API_PORT}"
      - "${ENV_IA_HERMES_DASHBOARD_PORT}:${ENV_IA_HERMES_DASHBOARD_PORT}"

    tmpfs:

      - /tmp:size=512m,mode=1777
      - /var/tmp:size=256m,mode=1777

    security_opt:

      - no-new-privileges:true

    cpus: 4.0
    mem_limit: 12g
    pids_limit: 256

    healthcheck:

      test:
        - CMD-SHELL
        - >
          python -c
          "import urllib.request;
          r=urllib.request.urlopen(
          'http://127.0.0.1:${ENV_IA_HERMES_API_PORT}/health',
          timeout=5);
          raise SystemExit(0 if r.status == 200 else 1)"

      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 30s

    networks:
      - internal
      - proxy

networks:
  proxy:
    name: proxy
    driver: bridge
    ipam:
      config:
        - subnet: 192.168.100.0/24
  internal:
    name: internal
    internal: true
EOF

    chown "${ENV_IA_USER}:${ENV_IA_GROUP}" "$compose_file"
    chmod 0660 "$compose_file"

    echo "✓ compose.yml généré"
}

_hermes_generate_10_tune() {
          tune_file="$(_10_tune_hermes)"
          # dossier parent créé si absent (idempotent)
          mkdir -p "$(_hermes_dir_data_cont_initd)"
          # écrit le script seulement s'il n'existe pas encore
          if [ ! -f "$tune_file" ]; then
              cat > "$tune_file" <<'EOF'
#!/bin/sh
# 10_tune_hermes — Exécuté à chaque démarrage du conteneur Hermes
command -v tmux >/dev/null 2>&1 || {
    apt-get update >/dev/null 2>&1
    apt-get install -y nano tmux >/dev/null 2>&1
}
EOF
    fi
          # bit exécutable forcé à chaque appel (idempotent)
          chmod +x "$tune_file"
}

# ==========================================================
# CONFIGURE
# ==========================================================

configure_agent_hermes() {

    local dir
    local env_file
    local regenerate="Y"

    dir="$(_hermes_dir)"
    env_file="$(_hermes_env_file)"

    echo ""
    echo "=============================================="
    echo " CONFIGURATION HERMES"
    echo "=============================================="
    echo ""
    echo "MODE    : Docker rootful"
    echo "USER    : ${ENV_IA_USER}"
    echo "HOME    : /home/${ENV_IA_USER}"
    echo "HERMES  : ${dir}"
    echo "UID     : 0"
    echo "GID     : 0"
    echo ""

    install -d \
        -o "${ENV_IA_USER}" \
        -g "${ENV_IA_GROUP}" \
        -m 2770 \
        "$dir"

    install -d \
        -o "${ENV_IA_USER}" \
        -g "${ENV_IA_GROUP}" \
        -m 2770 \
        "$(_hermes_data_dir)"


    # ------------------------------------------------------
    # .env
    # ------------------------------------------------------

    if [ -f "$env_file" ]; then

        echo "⚠️  Le fichier .env existe déjà."
        echo ""

        read -r -p \
            "Voulez-vous régénérer le .env ? [y/N] : " \
            regenerate

        case "$regenerate" in

            [Yy]|[Yy][Ee][Ss])

                _hermes_generate_env
                ;;

            *)

                echo "✓ .env conservé"
                ;;
        esac

    else

        echo "ℹ️  Aucun .env trouvé."
        echo "▶ Création du .env..."

        _hermes_generate_env
    fi


    # ------------------------------------------------------
    # Compose TOUJOURS régénéré
    # ------------------------------------------------------

    _hermes_generate_compose

    _hermes_generate_10_tune

    echo ""
    echo "✓ CONFIGURATION HERMES TERMINÉE"
}

# ==========================================================
# INSTALL
# ==========================================================

install_agent_hermes() {

    echo ""
    echo "=============================================="
    echo " INSTALLATION HERMES"
    echo "=============================================="
    echo ""

    if [ "${ENV_IA_HERMES:-0}" -ne 1 ]; then

        echo "❌ ENV_IA_HERMES n'est pas activé."
        return 1
    fi

    install -d \
        -o "$ENV_IA_USER" \
        -g "$ENV_IA_GROUP" \
        -m 2770 \
        "/home/$ENV_IA_USER/hermes"

    echo "USER   : ${ENV_IA_USER}"
    echo "GROUP  : ${ENV_IA_GROUP}"
    echo "IMAGE  : ${DOCKER_IMAGE_HERMES}"
    echo "MODE   : Docker rootful"
    echo "UID    : 0"
    echo "GID    : 0"
    echo ""


    # ------------------------------------------------------
    # Docker Rootful
    # ------------------------------------------------------

    echo "▶ Vérification Docker rootful..."

    if ! _hermes_check_docker; then

        echo "❌ Docker rootful indisponible."
        return 1
    fi

    echo "✓ Docker rootful"


    # ------------------------------------------------------
    # Configuration
    # ------------------------------------------------------

    configure_agent_hermes || return 1


    # ------------------------------------------------------
    # Pull
    # ------------------------------------------------------

    echo ""
    echo "▶ Téléchargement de l'image Hermes..."

    _hermes_compose pull || return 1


    # ------------------------------------------------------
    # Start
    # ------------------------------------------------------

    echo ""
    echo "▶ Démarrage Hermes..."

    _hermes_compose up -d || return 1


    echo ""
    echo "▶ Vérification du conteneur..."

    _hermes_compose ps


    echo ""
    echo "✓ HERMES INSTALLÉ"
}


# ==========================================================
# START
# ==========================================================

start_agent_hermes() {

    echo ""
    echo "▶ DÉMARRAGE HERMES"

    _hermes_check_docker || {

        echo "❌ Docker rootful indisponible."
        return 1
    }

    _hermes_compose up -d || return 1

    echo ""
    echo "✓ HERMES DÉMARRÉ"
}


# ==========================================================
# STOP
# ==========================================================

stop_agent_hermes() {

    echo ""
    echo "▶ ARRÊT HERMES"

    _hermes_compose stop || return 1

    echo ""
    echo "✓ HERMES ARRÊTÉ"
}


# ==========================================================
# UPDATE
# ==========================================================

update_agent_hermes() {

    local was_running=0

    if docker inspect hermes \
        --format '{{.State.Running}}' 2>/dev/null |
        grep -q '^true$'
    then
        was_running=1
    fi

    if ! ensure_docker_image \
        "${DOCKER_IMAGE_HERMES}" \
        "${DOCKER_IMAGE_HERMES_UPDATE_POLICY}" \
        "${ENV_IA_USER}"
    then
        return 1
    fi

    if [[ "${DOCKER_IMAGE_UPDATED}" -eq 1 ]] &&
       [[ "${was_running}" -eq 1 ]]
    then

        echo
        echo "▶ Redémarrage Hermes..."

        if ! start_agent_hermes; then
            return 1
        fi
    fi

    return 0
}


# ==========================================================
# UNINSTALL
# ==========================================================

uninstall_agent_hermes() {

    local dir
    local remove_data

    dir="$(_hermes_dir)"

    echo ""
    echo "=============================================="
    echo " DÉSINSTALLATION HERMES"
    echo "=============================================="
    echo ""

    if [ ! -d "$dir" ]; then

        echo "ℹ️  Hermes n'est pas installé."
        return 0
    fi


    # ------------------------------------------------------
    # Confirmation données
    # ------------------------------------------------------

    echo "⚠️  Les données persistantes Hermes sont présentes dans :"
    echo ""
    echo "    $(_hermes_data_dir)"
    echo ""

    read -r -p \
        "Supprimer également les données persistantes ? [YES/NO] : " \
        remove_data


    case "$remove_data" in

        YES)
            ;;

        NO)
            ;;

        *)
            echo ""
            echo "❌ Réponse invalide."
            echo "   Veuillez taper exactement YES ou NO."
            return 1
            ;;
    esac


    # ------------------------------------------------------
    # Stop / down
    # ------------------------------------------------------

    echo ""
    echo "▶ Suppression du conteneur..."

    _hermes_compose down --remove-orphans 2>/dev/null || true


    # ------------------------------------------------------
    # Suppression image
    # ------------------------------------------------------

    echo "▶ Suppression de l'image..."

    docker image rm \
        "${DOCKER_IMAGE_HERMES}" \
        2>/dev/null || true


    # ------------------------------------------------------
    # Données
    # ------------------------------------------------------

    if [ "$remove_data" = "YES" ]; then

        echo "▶ Suppression des données persistantes..."

        rm -rf "$dir"

        echo ""
        echo "✓ HERMES ET SES DONNÉES SUPPRIMÉS"

    else

        echo "✓ Données persistantes conservées."

        rm -f "$(_hermes_compose_file)"
        rm -f "$(_hermes_env_file)"

        echo ""
        echo "✓ HERMES SUPPRIMÉ"
        echo "✓ DONNÉES PERSISTANTES CONSERVÉES"
    fi
}

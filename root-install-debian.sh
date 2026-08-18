#!/usr/bin/env bash

set -Eeuo pipefail

# nano /root/root-install.sh
# chmod +x /root/root-install.sh
# alias --> nri
# alias --> ri
#
# Paquet a supprimer pour les container --> qemu-guest-agent
# Paquet a supprimer pour les Debian Trixie --> neofetch

# Le chemin où je me trouve est
BASH_SCRIPT_PATH=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
. "/root/diu/variables.sh"
. "$BASH_SCRIPT_PATH/lib/logging.sh"
. "$BASH_SCRIPT_PATH/lib/git-auth.sh"
. "$BASH_SCRIPT_PATH/lib/docker.sh"
. "$BASH_SCRIPT_PATH/lib/forgejo-auth.sh"
. "$BASH_SCRIPT_PATH/lib/git.sh"
. "$BASH_SCRIPT_PATH/modules/ia/hermes.sh"
. "$BASH_SCRIPT_PATH/modules/diu/config.sh"
. "$BASH_SCRIPT_PATH/modules/diu/update.sh"
. "$BASH_SCRIPT_PATH/modules/projects/cicd.sh"
. "$BASH_SCRIPT_PATH/modules/projects/forgejo-release.sh"
. "$BASH_SCRIPT_PATH/modules/projects/packaging.sh"

# Creer l'arborescence.
mkdir -p "$BASH_SCRIPT_PATH/config"
mkdir -p "$BASH_SCRIPT_PATH/deb"

# Chargement de la configuration
load_config

# Génération de la configuration


# Vérifier qu'on est root
if [ "$EUID" -ne 0 ]; then
    echo "Ce script doit être exécuté en root"
    exit 1
fi

###########################################
###### GESTION DES FONCTIONS DU DIU #######
###########################################

check_devops_user() {
    if ! id "$DEVOPS_USER" >/dev/null 2>&1; then
        echo "❌ L'utilisateur '$DEVOPS_USER' n'existe pas."
        exit 1
    fi

    if ! getent group "$DEVOPS_GROUP" >/dev/null 2>&1; then
        echo "❌ Le groupe '$DEVOPS_GROUP' n'existe pas."
        exit 1
    fi
}

config_host () {

  local hosts_ip=""

  if [[ "${INTERFACE_ETHERNET1_STATE}" == "UP" ]] \
      && [[ "${INTERFACE_ETHERNET1_IP}" != "NONE" ]] \
      && [[ "${INTERFACE_ETHERNET1_IP}" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then

      hosts_ip="${INTERFACE_ETHERNET1_IP}"

  elif [[ "${INTERFACE_ETHERNET2_STATE}" == "UP" ]] \
      && [[ "${INTERFACE_ETHERNET2_IP}" != "NONE" ]] \
      && [[ "${INTERFACE_ETHERNET2_IP}" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then

      hosts_ip="${INTERFACE_ETHERNET2_IP}"
  fi

  cat > /etc/hosts <<EOF
127.0.0.1       localhost
EOF

  if [[ -n "${hosts_ip}" ]]; then
      printf '%s\t%s\t%s\n' \
          "${hosts_ip}" \
          "${HOSTNAME_FQDN}" \
          "${HOSTNAME}" >> /etc/hosts
  fi

  cat >> /etc/hosts <<'EOF'

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF

  # Ajout des domaines de la Stack Docker Traefik / Dockhand
  if [[ "${DOCKER_STACK_TRAEFIK_DOCKHAND}" == "1" ]]; then
      {
          printf '\n'
          printf '# Stack Docker Traefik / Dockhand\n'
          printf '127.0.0.1\t%s\n' "dockhand.${DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN}"
          printf '127.0.0.1\t%s\n' "dozzle.${DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN}"
          printf '127.0.0.1\t%s\n' "hawser.${DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN}"
          printf '127.0.0.1\t%s\n' "librespeed.${DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN}"
          printf '127.0.0.1\t%s\n' "myspeed.${DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN}"
          printf '127.0.0.1\t%s\n' "traefik.${DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN}"
          printf '127.0.0.1\t%s\n' "traefik-manager.${DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN}"
          printf '127.0.0.1\t%s\n' "whoami.${DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN}"
      } >> /etc/hosts
  fi

  # Ajout des domaines de la Stack Docker DevOps
  if [[ "${DOCKER_STACK_DEVOPS}" == "1" ]]; then
      {
          printf '\n'
          printf '# Stack Docker DevOps\n'
          printf '127.0.0.1\t%s\n' "forgejo.${DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN}"
          printf '127.0.0.1\t%s\n' "g4f.${DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN}"
          printf '127.0.0.1\t%s\n' "pgadmin.${DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN}"
      } >> /etc/hosts
  fi

}

create_project_bash() {
    local project_id="$1"
    local project_name="$2"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"

    check_devops_user

    echo ""
    echo "=============================================="
    echo " Création du projet ${project_name}"
    echo "=============================================="
    echo ""
    echo "Répertoire cible : $project_path"
    echo ""

    if [[ -e "$project_path" ]]; then
        echo "❌ Le projet existe déjà :"
        echo "   $project_path"
        echo ""
        echo "Aucune modification n'a été effectuée."
        exit 1
    fi

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

    # Création du fichier .gitignore initial.
    cat > "$project_path/.gitignore" <<EOF
# ==========================================================
# Debian Installer Unifié (DIU)
# Git Ignore
# Fichiers à ne pas versionner
# ==========================================================

# ----------------------------------------------------------
# Archives générées localement
# ----------------------------------------------------------
*.7z
*.tar
*.tar.gz
*.tgz
*.xz
*.zip

# ----------------------------------------------------------
# Paquets Debian
# ----------------------------------------------------------
*.deb

# ----------------------------------------------------------
# Fichiers de crashs
# ----------------------------------------------------------
*.core
core

# ----------------------------------------------------------
# Fichiers de sauvegardes
# ----------------------------------------------------------
*~
*.bak
*.save
*.orig
*.rej

# ----------------------------------------------------------
# Fichiers de sorties
# ----------------------------------------------------------
output/
reports/

# ----------------------------------------------------------
# Fichiers système
# ----------------------------------------------------------
.DS_Store
Thumbs.db

# ----------------------------------------------------------
# Fichiers temporaires
# ----------------------------------------------------------
.cache/
*.err
*.log
*.out
*.pid
*.tmp
*.temp
*.trace
logs/
tmp/

# ----------------------------------------------------------
# Fichiers de verrouillages temporaires
# ----------------------------------------------------------
*.lock
!package-lock.json
!poetry.lock
!Cargo.lock

# ----------------------------------------------------------
# Bash
# ----------------------------------------------------------
*.sh~
*.bash_history
*.bash_logout~
*.bash_sessions
*.coverage
*.history

# ----------------------------------------------------------
# Docker
# ----------------------------------------------------------
*.cid
*.json.log
*compose*.log

# ----------------------------------------------------------
# Geany
# ----------------------------------------------------------
*.geany

# ----------------------------------------------------------
# Git
# ----------------------------------------------------------
*.LOCAL.*
*.REMOTE.*
*.BASE.*
*.BACKUP.*
*.diff
*.merge_file_*
*.orig
*.patch

# ----------------------------------------------------------
# Node.js
# ----------------------------------------------------------
.npm/
.pnpm-store
.npmrc.local
node_modules/

# ----------------------------------------------------------
# OpenCode
# ----------------------------------------------------------
.opencode/**
!.opencode/
!.opencode/commands/
!.opencode/commands/**
!.opencode/config/
!.opencode/config/opencode.json
!.opencode/skills/
!.opencode/skills/**

# ----------------------------------------------------------
# OpenSpec
# ----------------------------------------------------------
openspec/**
!openspec/changes/
!openspec/changes/**
!openspec/specs/
!openspec/specs/**
!openspec/AGENTS.md
!openspec/config.yaml

# ----------------------------------------------------------
# PyCharm
# ----------------------------------------------------------
.idea/

# ----------------------------------------------------------
# Python
# ----------------------------------------------------------
env/
__pycache__/
.mypy_cache/
*.py[cod]
.pytest_cache/
.ruff_cache/
.venv/
.python-version
venv/

# ----------------------------------------------------------
# SQLite
# ----------------------------------------------------------
*.sqlite
*.sqlite3
*.db

# ----------------------------------------------------------
# Syncthing
# ----------------------------------------------------------
.stfolder/
.stignore

# ----------------------------------------------------------
# Vim
# ----------------------------------------------------------
*.swp
*.swo

# ----------------------------------------------------------
# Visual Studio Code
# ----------------------------------------------------------
.vscode/

# ----------------------------------------------------------
# Configuration DIU locale
# ----------------------------------------------------------
/config/

# ----------------------------------------------------------
# Variables et secrets locaux
# ----------------------------------------------------------
*.crt
*.cer
*.der
*.env
*.env.*
*.key
*.pem
*.p12
*.pfx
*.token
*.username
credentials.json
credentials.yaml
id_rsa
id_ed25519
secrets.json
secrets.yaml
EOF

    # Création du fichier opencode.json initial.
    cat > "$project_path/.opencode/config/opencode.json" <<'EOF'
{
	"$schema": "https://opencode.ai/config.json",
	"provider": {
		"openrouter": {
			"models": {
				"~deepseek/deepseek-v4-flash": {},
				"~deepseek/deepseek-v4-pro": {},
				"~google/gemini-3-flash-preview": {},
				"~minimax/minimax-m3": {},
				"~moonshotai/kimi-k3": {},
				"~nvidia/nemotron-3-ultra-550b-a55b:free": {},
				"~qwen/qwen3.7-plus": {},
				"~xiaomi/mimo-v2.5-pro": {},
				"~xiaomi/mimo-v2.5": {},
				"~z-ai/glm-5.2": {}
			}
		}
	},
	"default_agent": "plan",
	"agent": {
		"build": {
		  "mode": "primary",
		  "model": "openrouter/xiaomi/mimo-v2.5"
		},
		"plan": {
		  "mode": "primary",
		  "model": "openrouter/xiaomi/mimo-v2.5-pro"
		},
		"code-reviewer": {
		  "mode": "subagent",
		  "model": "openrouter/deepseek/deepseek-v4-pro"
		}
	},
	"share": "disabled",
	"snapshot": false,
	"autoupdate": false,
	"permission": {
		"*": "ask",
		"bash": {
			"*": "deny",
			"awk": "ask",
			"awk *": "ask",
      "bash /tmp/opencode/*": "ask",
      "bash -n *": "allow",
      "cat": "allow",
      "cat *": "allow",
      "chmod": "ask",
      "chmod *": "ask",
      "command -v": "allow",
      "command -v *": "allow",
      "cp": "ask",
      "cp *": "ask",
      "diff": "allow",
      "diff *": "allow",
			"find *": "ask",
			"file *": "ask",
			"git add": "ask",
			"git add *": "ask",
			"git branch": "allow",
			"git branch *": "ask",
			"git clean": "deny",
			"git clean *": "deny",
			"git checkout": "ask",
			"git checkout *": "ask",
			"git commit": "ask",
			"git commit *": "ask",
			"git config": "ask",
			"git config *": "ask",
			"git diff": "allow",
			"git diff *": "allow",
			"git log": "allow",
			"git log *": "allow",
			"git merge": "ask",
			"git merge *": "ask",
			"git push": "ask",
			"git push *": "ask",
			"git rebase": "deny",
			"git rebase *": "deny",
			"git remote": "ask",
			"git remote *": "ask",
			"git reset": "deny",
			"git reset *": "deny",
			"git restore": "ask",
			"git restore *": "ask",
			"git show": "allow",
			"git show *": "allow",
			"git stash": "ask",
			"git stash *": "ask",
			"git status": "allow",
			"git status *": "allow",
			"git tag": "ask",
			"git tag *": "ask",
			"git switch": "ask",
			"git switch *": "ask",
			"git worktree": "ask",
			"git worktree *": "ask",
			"grep": "allow",
			"grep *": "allow",
			"glob": "allow",
      "head": "allow",
      "head *": "allow",
			"ls": "allow",
			"ls *": "allow",
			"lsp": "allow",
      "mkdir": "allow",
      "mkdir *": "allow",
      "mv": "ask",
      "mv *": "ask",
      "openspec": "ask",
      "openspec *": "ask",
      "openspec archive *": "ask",
      "openspec status *": "allow",
      "openspec instructions *": "ask",
      "openspec instructions apply *": "allow",
      "openspec instructions design *": "allow",
      "openspec instructions proposal *": "allow",
      "openspec instructions specs *": "allow",
      "openspec instructions tasks *": "allow",
      "openspec list": "allow",
      "openspec list *": "allow",
      "openspec show": "allow",
      "openspec show *": "allow",
      "openspec status": "allow",
      "openspec status *": "allow",
      "openspec view": "allow",
      "openspec view *": "allow",
      "openspec validate": "allow",
      "openspec validate *": "allow",
			"pwd": "allow",
			"rm": "ask",
			"rm *": "ask",
			"sed": "ask",
			"sed *": "ask",
			"shellcheck": "allow",
			"shellcheck *": "allow",
      "tail": "allow",
      "tail *": "allow",
      "touch": "ask",
      "touch *": "ask",
			"tree": "ask",
			"tree *": "ask",
      "wc": "allow",
      "wc *": "allow",
      "which": "allow",
      "which *": "allow"
		},
		"edit": {
			"*": "ask",
			"__pycache__/**": "deny",
			"**/__pycache__/**": "deny",
			"**/*.crt": "deny",
			"**/*.cer": "deny",
			"**/*.der": "deny",
			"**/*.env": "deny",
			"**/*.env.*": "deny",
			"**/*.key": "deny",
			"**/*.pem": "deny",
			"**/*.p12": "deny",
			"**/*.pfx": "deny",
			"**/*.token,": "deny",
			"**/credentials.json": "deny",
			"**/credentials.yaml": "deny",
			"**/id_rsa": "deny",
			"**/id_ed25519": "deny",
			"**/secrets.json": "deny",
			"**/secrets.yaml": "deny",
			".cache/**": "deny",
			".git/**": "deny",
			".gitignore": "ask",
			".idea/**": "deny",
			".mypy_cache/**": "deny",
			".npm/**": "deny",
			".opencode/**": "deny",
			".opencode/commands/**": "ask",
			".opencode/config/opencode.json": "ask",
			".opencode/skills/**": "ask",
			".pytest_cache/**": "deny",
			".python-version": "deny",
			".ruff_cache/**": "deny",
			".stfolder/**": "deny",
			".stignore": "deny",
			".venv/**": "deny",
			".vscode/**": "deny",
			"AGENTS.md": "ask",
			"env/**": "deny",
			"LICENSE": "ask",
			"logs/**": "deny",
			"node_modules/**": "deny",
			"openspec/**": "deny",
			"openspec/AGENTS.md": "ask",
			"openspec/config.yaml": "ask",
			"openspec/changes/**": "ask",
			"openspec/specs/**": "ask",
			"output/**": "ask",
			"README.md": "ask",
			"reports/**": "ask",
			"tmp/**": "deny",
			"venv/**": "deny"
		},
    "external_directory": {
      "*": "deny",
      "/tmp/opencode/**": "allow"
    },
		"glob": "allow",
		"grep": "allow",
		"lsp": "allow",	
		"question": "allow",
		"read": {
			"*": "allow",
			"__pycache__/**": "deny",
			"**/__pycache__/**": "deny",
			"**/*.crt": "deny",
			"**/*.cer": "deny",
			"**/*.der": "deny",
			"**/*.env": "deny",
			"**/*.env.*": "deny",
			"**/*.key": "deny",
			"**/*.pem": "deny",
			"**/*.p12": "deny",
			"**/*.pfx": "deny",
			"**/*.token,": "deny",
			"**/credentials.json": "deny",
			"**/credentials.yaml": "deny",
			"**/id_rsa": "deny",
			"**/id_ed25519": "deny",
			"**/secrets.json": "deny",
			"**/secrets.yaml": "deny",
			".cache/**": "deny",
			".git/**": "deny",
			".gitignore": "allow",
			".idea/**": "deny",
			".mypy_cache/**": "deny",
			".npm/**": "deny",
			".opencode/**": "deny",
			".opencode/commands/**": "allow",
			".opencode/config/opencode.json": "allow",
			".opencode/skills/**": "allow",
			".pytest_cache/**": "deny",
			".python-version": "deny",
			".ruff_cache/**": "deny",
			".stfolder/**": "deny",
			".stignore": "deny",
			".venv/**": "deny",
			".vscode/**": "deny",
			"AGENTS.md": "allow",
			"env/**": "deny",
			"LICENSE": "allow",
			"logs/**": "deny",
			"node_modules/**": "deny",
			"openspec/**": "ask",
			"openspec/AGENTS.md": "allow",
			"openspec/config.yaml": "allow",
			"openspec/changes": "allow",
			"openspec/changes/**": "allow",
			"openspec/specs": "allow",
			"openspec/specs/**": "allow",
			"output/**": "allow",
			"README.md": "allow",
			"reports/**": "allow",
			"tmp/**": "deny",
			"venv/**": "deny"
		},
		"todowrite": "allow",
		"webfetch": "ask",
		"websearch": "ask"
	},
	"watcher": {
		"ignore": [
			"__pycache__/**",
			"**/__pycache__/**",
			"**/*.crt",
			"**/*.cer",
			"**/*.der",
			"**/*.env",
			"**/*.env.*",
			"**/*.err",
			"**/*.key",
			"**/*.log",
			"**/*.out",
			"**/*.p12",
			"**/*.pem",
			"**/*.pfx",
			"**/*.pid",
			"**/*.tmp",
			"**/*.temp",
			"**/*.token,",
			"**/*.trace",
			"**/credentials.json",
			"**/credentials.yaml",
			"**/id_rsa",
			"**/id_ed25519",
			"**/secrets.json",
			"**/secrets.yaml",
			".cache/**",
			".git/**",
			".idea/**",
			".mypy_cache/**",
			".npm/**",
			".opencode/.gitignore",
			".opencode/cache/**",
			".opencode/share/**",
			".opencode/state/**",
			".pytest_cache/**",
			".ruff_cache/**",
			".stfolder/**",
			".stignore",
			".venv/**",
			".vscode/**",
			"env/**",
			"venv/**",
			"node_modules/**",
			"logs/**",
			"tmp/**",
			"openspec/.cache/**",
			"openspec/.generated/**",
			"openspec/.history/**",
			"openspec/.output/**",
			"openspec/.tmp/**",
			"openspec/build/**",
			"openspec/dist/**",
			"openspec/logs/**"
		]
	}
}
EOF

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

    # Création initiale du fichier AGENTS.md initial. 
    cat > "$project_path/AGENTS.md" <<EOF
AGENTS.md
${project_name}

Ce fichier est généré à l'initialisation du projet par le DIU.

## Variables utilisées :

${project_name} : nom du projet ;
/workspace : chemin racine du projet.

## Préambule

Ce document définit les règles que doivent respecter les agents de codage intervenant sur ce projet.

Les agents doivent privilégier :

la stabilité ;
la reproductibilité ;
la simplicité ;
la lisibilité ;
la maintenabilité ;
la sécurité ;
la traçabilité des modifications.

Les agents doivent toujours privilégier les modifications les plus petites possibles.

Une évolution complexe doit être découpée en plusieurs modifications indépendantes afin de faciliter :

la relecture ;
les tests ;
la validation ;
les retours arrière.

Les agents ne doivent jamais profiter d'une modification pour corriger, reformater, renommer ou réorganiser des éléments sans rapport avec la demande.

Toute amélioration non demandée doit être proposée séparément.

## Objectif

L'objectif du projet est de produire un installeur Debian unifié :

reproductible ;
maintenable ;
documenté ;
spécifié avec OpenSpec ;
versionné avec Git ;
assisté par OpenCode.

Toutes les décisions doivent privilégier ces objectifs.

## Rôle du projet

Le projet ${project_name} est développé selon une approche progressive, documentée et reproductible.

Les agents de codage doivent préserver le comportement existant tout en respectant les spécifications validées.

## Portée

AGENTS.md ;
les spécifications présentes dans openspec/ ;
les conventions du projet ;
Les règles définies dans ce fichier s'appliquent à l'ensemble du projet.

Un fichier AGENTS.md situé dans un sous-répertoire peut être utilisé lorsque OpenCode est lancé depuis ce sous-répertoire,
ou lorsqu’il est explicitement chargé dans les instructions.

Il ne doit pas être considéré comme complétant automatiquement le fichier AGENTS.md racine.

Il doit reprendre explicitement toutes les règles générales qui doivent continuer à s’appliquer.

En cas de conflit, le fichier AGENTS.md le plus proche du fichier modifié prévaut, sauf demande explicite du développeur.

## Emplacement du projet

La racine du projet est située dans :

/workspace

Toutes les opérations doivent être réalisées relativement à cette racine.

Les agents ne doivent créer, modifier ou supprimer des fichiers que sous :

/workspace

Toute écriture en dehors de cette arborescence nécessite une validation explicite.

## Ordre de lecture

Avant toute intervention, les agents doivent lire dans l'ordre :

AGENTS.md ;
les spécifications présentes dans openspec/ ;
les conventions du projet ;
le code et la documentation concernés.

## Méthode de travail

Avant toute modification, les agents doivent :

comprendre la demande ;
consulter les spécifications OpenSpec applicables ;
identifier les fichiers concernés ;
proposer les modifications ;
réaliser uniquement les modifications validées ;
vérifier la syntaxe et la cohérence ;
expliquer les impacts.

Les évolutions doivent être :

progressives ;
limitées à un objectif clairement défini ;
documentées ;
vérifiables ;
facilement réversibles.

Chaque proposition doit préciser :

l'objectif ;
les fichiers concernés ;
les modifications envisagées ;
les impacts éventuels ;
les vérifications à effectuer.

## Règles permanentes de Développements

Privilégier une architecture modulaire
Préserver la compatibilité
Pas de changement fonctionnel non spécifié

## Périmètre des modifications

Les agents doivent limiter leurs modifications aux fichiers strictement nécessaires à l'objectif demandé.

Ils ne doivent jamais :

modifier plusieurs fonctionnalités simultanément ;
effectuer des optimisations non demandées ;
reformater massivement les fichiers ;
effectuer des modifications de style sans rapport avec la demande ;
renommer des variables uniquement pour des raisons esthétiques ;
déplacer des fichiers ou modifier l'arborescence sans validation explicite ;
modifier une convention existante sans validation explicite.

En cas de doute, l'agent doit proposer une solution sans modifier le fonctionnement existant de sa propre initiative.

## Modifications fonctionnelles

Aucune modification du comportement fonctionnel ne doit être réalisée sans spécification explicite ou validation explicite du développeur.

Toute évolution fonctionnelle doit être précédée ou accompagnée de la création ou de la mise à jour de la spécification OpenSpec correspondante.

Les agents ne doivent jamais implémenter une fonctionnalité absente d'une spécification validée.

## OpenSpec

Les spécifications OpenSpec constituent la source de vérité fonctionnelle et technique du projet.

Avant toute modification du code, les agents doivent vérifier qu'une spécification correspondante existe ou qu'une validation explicite a été obtenue.

Lorsqu'une spécification validée est en contradiction avec le code existant, la spécification prévaut.

Les spécifications doivent rester cohérentes entre elles.

Les agents ne doivent créer ou modifier une spécification OpenSpec que lorsque :

la demande concerne explicitement une évolution fonctionnelle ;
la demande concerne explicitement un travail de spécification ;
une validation explicite du développeur a été obtenue ;
une commande OpenSpec autorisant cette opération a été demandée.

La demande explicite d'utiliser une commande OpenSpec nécessitant une écriture,
notamment :

/opsx-propose ;
/opsx-new ;
/opsx-continue ;
/opsx-update ;
/opsx-sync ;
/opsx-archive ;

constitue l'autorisation de modifier les fichiers OpenSpec nécessaires
à l'exécution de cette commande.

Les agents ne doivent pas créer une nouvelle évolution OpenSpec de leur propre initiative.

## Sources de spécifications faisant autorité

Les éléments suivants constituent les sources de spécifications et de configuration faisant autorité pour le projet :

openspec/config.yaml
openspec/changes/
openspec/specs/

Ils doivent être consultés avant toute évolution fonctionnelle.

Leur création, modification, suppression ou régénération nécessite une demande ou une validation explicite.

## OpenCode

OpenCode doit être considéré comme un composant technique du projet.

Les fichiers présents dans les répertoires suivants sont générés par OpenSpec et ne doivent pas être modifiés manuellement sans demande explicite :

.opencode/commands/
.opencode/skills/

Les modifications de la configuration OpenCode nécessitent une validation explicite portant sur OpenCode ou sur son intégration avec OpenSpec.

## Arborescence

Les agents doivent respecter l'organisation actuelle du projet.

Les renommages, déplacements ou suppressions de fichiers et de répertoires sont considérés comme des modifications majeures et nécessitent une validation explicite.

Lorsqu'un fichier semble inutilisé, l'agent doit le signaler avant toute suppression.

## Suppressions

Les suppressions de code existant doivent être limitées au strict nécessaire.

Tout bloc supprimé doit être justifié.

La suppression d'un fichier ou d'un répertoire nécessite une validation explicite.

## Fichiers générés

Les fichiers temporaires ou les artefacts de construction explicitement identifiés comme régénérables peuvent être supprimés puis recréés.

Cette règle ne s'applique pas aux fichiers générés et versionnés suivants :

.gitignore
AGENTS.md
LICENSE
README.md
.opencode/commands/
.opencode/skills/
.opencode/config/opencode.json
openspec/config.yaml
openspec/changes/
openspec/specs/

Toute suppression ou régénération de ces éléments nécessite une validation explicite.

## Sources du projet

Tous les fichiers et répertoires situés dans le projet et qui ne sont pas explicitement exclus peuvent être utilisés comme sources :

de code ;
de documentation ;
d'informations techniques ;
d'informations fonctionnelles.

Les éléments explicitement exclus ne doivent pas être lus, analysés, indexés ou utilisés comme sources du projet.

## Sources exclues du projet

Les agents ne doivent jamais lire, analyser, indexer ou utiliser les éléments suivants comme sources de code, de documentation ou de spécifications fonctionnelles :

__pycache__/
**/*.crt
**/*.cer
**/*.der
**/*.env
**/*.env.*
**/*.key
**/*.pem
**/*.p12
**/*.pfx
**/credentials.json
**/credentials.yaml
**/id_rsa
**/id_ed25519
**/secrets.json
**/secrets.yaml
.cache/
.git/
.idea/
.mypy_cache/
.npm/
.opencode/.gitignore
.opencode/cache/
.opencode/config/
.opencode/share/
.opencode/state/
.pytest_cache/
.ruff_cache/
.venv/
.python-version
.stfolder/
.stignore
.vscode/
credentials.json
credentials.yaml
id_rsa
id_ed25519
env/
logs/
node_modules/
openspec/.cache/
openspec/.env
openspec/.env.*
openspec/.generated/
openspec/.history/
openspec/.output/
openspec/.tmp/
openspec/build/
openspec/dist/
openspec/logs/
secrets.json
secrets.yaml
tmp/
venv/

## Sources incluses et protégées

Lorsqu'un fichier correspond à la fois à une règle d'exclusion générale et à une inclusion explicite dans cette section, l'inclusion explicite prévaut.

Les agents peuvent consulter les éléments suivants pour les besoins techniques liés à OpenCode, OpenSpec ou Git :

.gitignore
AGENTS.md
LICENSE
README.md
.opencode/commands/
.opencode/config/opencode.json
.opencode/skills/
openspec/AGENTS.md
openspec/config.yaml
openspec/changes/
openspec/specs/
output/
reports/

Ces éléments ne constituent pas nécessairement une source de vérité fonctionnelle.

Leur modification nécessite une demande ou une validation explicite portant sur :

OpenCode ;
OpenSpec ;
Git ;
la production de rapports techniques.

Les répertoires output/ et reports/ :

ne doivent pas être versionnés dans Git ;
peuvent contenir des résultats ou rapports temporaires ;
peuvent être lus ;
ne constituent pas une source de vérité du projet ;
ne doivent être créés, modifiés ou supprimés que dans le cadre d'une demande explicite.

## Secrets

Aucun secret ne doit être :

ajouté au dépôt Git ;
transmis au modèle ;
affiché dans les journaux ;
analysé ;
indexé.

Les fichiers identifiés comme sensibles ne doivent pas être ouverts.

L'agent peut uniquement signaler leur présence à partir de leur nom ou de leur chemin.

Les données sensibles interdites comprennent notamment :

les mots de passe ;
les clés privées ;
les clés SSH ;
les jetons d'API ;
les certificats ;
les identifiants de connexion.

Les secrets doivent être externalisés des fichiers versionnés et des sources accessibles aux agents.

Ils peuvent être stockés dans un emplacement local non versionné explicitement prévu à cet effet, notamment .opencode/share/,
à condition que cet emplacement soit exclu de Git, de la lecture par les agents et de l’indexation.

## Sécurité

Les agents doivent privilégier :

le principe du moindre privilège ;
la validation des entrées ;
l'absence de données sensibles dans les journaux ;
des permissions minimales sur les fichiers créés ;
une gestion explicite des erreurs.

## Docker

Les agents ne doivent jamais supposer qu'ils disposent d'un accès à l'ensemble de la machine hôte.

Ils ne doivent jamais modifier sans validation explicite :

les montages Docker ;
les volumes ;
les droits d'accès du conteneur ;
les utilisateurs du conteneur ;
les permissions accordées au conteneur.

## Git

Les agents ne doivent jamais :

modifier le contenu du répertoire .git/ ;
réécrire l'historique Git ;
supprimer des commits ;
effectuer un push sans validation explicite ;
modifier la configuration Git du dépôt sans validation explicite ;
créer, modifier ou supprimer des branches sans validation explicite ;
modifier les sous-modules sans validation explicite ;
créer ou modifier des hooks Git sans validation explicite.

## Commit

Les commits doivent rester atomiques.

Chaque commit doit correspondre à une seule modification clairement identifiable.

Un commit ne doit pas mélanger :

une correction ;
un refactoring ;
une évolution fonctionnelle ;
une mise à jour documentaire indépendante.
Avant un commit

Avant toute proposition de commit, les agents doivent :

vérifier la syntaxe ;
examiner les fichiers modifiés ;
vérifier que seuls les fichiers attendus sont modifiés ;
vérifier qu'aucun secret n'a été ajouté ;
exécuter les vérifications disponibles ;
expliquer clairement le contenu du commit.

## Bash et scripts Shell

Les scripts doivent rester compatibles avec la version de Bash installée par défaut sur les versions Debian supportées par le projet.

Les constructions POSIX doivent être privilégiées lorsqu'elles permettent d'obtenir le même résultat simplement.

Les fonctionnalités spécifiques à une version récente de Bash ne doivent être utilisées qu'en cas de nécessité clairement justifiée.

Les scripts doivent pouvoir être analysés avec :

bash -n

et, lorsque l'outil est disponible :

shellcheck

Les scripts doivent être robustes.

Les variables doivent être protégées par des guillemets lorsque nécessaire.

Les commandes dont l'échec est attendu doivent être explicitement gérées.

Les erreurs doivent être :

détectées ;
traitées ;
signalées clairement.

Les erreurs ne doivent jamais être ignorées silencieusement.

## Variables

Les variables de configuration doivent rester cohérentes avec les spécifications du projet.

Les noms existants doivent être conservés lorsqu'ils sont suffisamment explicites.

Les renommages purement esthétiques sont interdits.

Les valeurs codées en dur doivent être évitées.

Une nouvelle variable ne doit pas être ajoutée lorsqu'une variable existante répond déjà au besoin.

Toute nouvelle variable de configuration doit être documentée dans les spécifications OpenSpec.

Les variables à portée globale seront notées en MAJUSCULE.

Les variables à portée locale seront notées en minuscule.

Le sepérateur entre deux mots dans une variable sera toujours le caractères _ (underscore).

Les nouvelles variables seront exprimées en anglais.

## Chemins

Les chemins absolus ne doivent être utilisés que lorsqu'ils sont imposés par le projet.

Les scripts doivent privilégier des chemins relatifs au projet lorsqu'ils permettent de conserver la portabilité.

Compatibilité et portabilité

Toute modification doit préserver la compatibilité avec les installations existantes.

Les comportements attendus ne doivent pas être modifiés sans spécification validée.

Les changements incompatibles doivent être explicitement signalés.

Le projet doit rester compatible avec les versions stables de Debian supportées par le projet.

Toute dépendance spécifique à une distribution ou à une version particulière doit être explicitement documentée.

## Idempotence

Les scripts d'installation doivent être idempotents lorsque cela est raisonnablement possible.

Une seconde exécution ne doit pas provoquer d'effets de bord inattendus.

## Dépendances et outils externes

Les agents doivent privilégier les outils présents dans une installation Debian standard.

Aucune nouvelle dépendance ne doit être ajoutée sans justification et validation explicite.

Toute nouvelle dépendance doit être documentée.

Une dépendance existante doit être privilégiée lorsqu'elle répond déjà au besoin.

## Conventions et style du projet

Les conventions existantes de nommage, d'organisation, de formatage et d'architecture doivent être respectées.

Une convention existante ne doit pas être modifiée sans validation explicite.

En cas d'ambiguïté, l'agent doit privilégier la cohérence avec le code et les conventions existantes.

Le style de codage actuel doit être conservé autant que possible.

## Lisibilité

Les agents doivent privilégier :

des fonctions courtes ;
des noms explicites ;
une indentation homogène ;
des commentaires utiles ;
des traitements simples.

La simplicité doit être privilégiée à l'optimisation prématurée.

## Principe KISS

Les agents doivent privilégier la solution la plus simple répondant correctement au besoin.

Toute complexité inutile doit être évitée.

## Commentaires

Les commentaires existants doivent être conservés lorsqu'ils restent exacts.

Les nouveaux commentaires doivent apporter une information utile et ne pas simplement répéter le code.

Les agents ne doivent pas introduire de commentaires TODO, FIXME ou HACK sans validation explicite.

Une tâche incomplète doit être décrite dans OpenSpec plutôt que laissée dans le code.

## Documentation

Toute évolution importante doit être accompagnée, lorsque nécessaire, de la mise à jour :

des spécifications ;
de la documentation ;
des commentaires concernés.

La documentation ne doit pas être modifiée pour des éléments sans rapport avec la demande en cours.

## Encodage

Tous les fichiers texte doivent utiliser :

l'encodage UTF-8 ;
les fins de ligne Unix LF.

Les fins de ligne Windows CRLF sont interdites.

## Journalisation et messages

Les messages affichés par les scripts doivent être :

explicites ;
cohérents ;
utiles au suivi de l'avancement ;
utiles au diagnostic des erreurs.

Les messages ne doivent jamais :

masquer un échec ;
ignorer silencieusement une erreur ;
afficher des données sensibles ;
modifier le comportement fonctionnel attendu.

## Robustesse

Les agents doivent privilégier :

une gestion explicite des erreurs ;
des messages d'erreur compréhensibles ;
des codes de retour explicites ;
des traitements idempotents lorsque cela est possible ;
la validation des entrées.

## Lecture minimale

Les agents doivent limiter la lecture des fichiers au strict nécessaire.

Ils ne doivent pas parcourir récursivement l'ensemble du dépôt lorsqu'une lecture ciblée permet de répondre à la demande.

Ils doivent privilégier :

les recherches ciblées ;
les ouvertures partielles de fichiers ;
les lectures incrémentales ;
les répertoires directement concernés.

## Tests et vérifications

Lorsqu'un mécanisme de test existe, les agents doivent l'exécuter avant toute proposition de validation.

Pour les scripts Bash, les vérifications minimales sont :

bash -n

et, lorsque disponible :

shellcheck

Avant toute proposition de validation, les agents doivent vérifier :

la syntaxe des langages utilisés ;
l'absence d'erreur évidente ;
la cohérence des fichiers modifiés ;
la conformité avec les spécifications ;
l'absence de modification hors périmètre.

## Licences

Les en-têtes de licence existants doivent être conservés.

Aucune licence ne doit être modifiée sans validation explicite.

## Priorité

En cas de contradiction, l'ordre de priorité suivant s'applique :

les demandes explicites du développeur ;
les spécifications OpenSpec validées ;
les règles de sécurité et de travail définies dans AGENTS.md ;
la documentation officielle du projet ;
le code existant.

Le code existant ne constitue pas une référence lorsqu'il contredit une spécification validée.

En cas de conflit entre l'optimisation du code et la stabilité du projet, la stabilité du projet est prioritaire.

## Validation du développeur

Une validation explicite correspond à une demande ou une confirmation claire du développeur autorisant l'action concernée.

En l'absence d'une telle validation, l'agent doit limiter son intervention à des propositions ou des analyses.
EOF

    # Création initiale du fichier LICENCE initial. 
    cat > "$project_path/LICENSE" <<EOF
DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
Version 2, December 2004

Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>

Everyone is permitted to copy and distribute verbatim or modified copies of this license document, and changing it is allowed as long as the name is changed.

DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

  0. You just DO WHAT THE FUCK YOU WANT TO.
EOF

    # Création initiale du fichier README.md initial. 
    cat > "$project_path/README.md" <<EOF
# ${project_name}
EOF

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
    local project_name="$2"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"
    local confirmation

    echo ""
    echo "=============================================="
    echo " Suppression du projet ${project_name}"
    echo "=============================================="
    echo ""

    if [[ ! -e "$project_path" ]]; then
        echo "❌ Le projet n'existe pas :"
        echo "   $project_path"
        exit 1
    fi

    echo "⚠️  Cette opération supprimera définitivement :"
    echo ""
    echo "   $project_path"
    echo ""

    if command -v tree >/dev/null 2>&1; then
        tree -a -L 2 "$project_path"
        echo ""
    fi

    read -r -p "Saisir exactement 'YES' pour confirmer : " confirmation

    if [[ "$confirmation" != "YES" ]]; then
        echo ""
        echo "Suppression annulée."
        exit 0
    fi

    rm -rf --one-file-system -- "$project_path"

    echo ""
    echo "✅ Projet ${project_name} supprimé :"
    echo "   $project_path"
}

devops_info () {

    su - "${DEVOPS_USER}" -c '

        # ==============================================
        # Récupération des versions
        # ==============================================

        PYTHON_VERSION="$(python3 --version 2>/dev/null | awk "{print \$2}")"
        GO_VERSION="$(go version 2>/dev/null | awk "{print \$3}" | sed "s/^go//")"
        NODE_VERSION="$(node --version 2>/dev/null | sed "s/^v//")"
        NPM_VERSION="$(npm --version 2>/dev/null)"
        OPENCODE_VERSION="$(opencode --version 2>/dev/null)"
        OPENSPEC_VERSION="$(openspec --version 2>/dev/null)"

        echo "# =============================================="
        echo "# === PYTHON ${PYTHON_VERSION}                          ==="
        echo "# =============================================="
        command -v python3
        readlink -f "$(command -v python3)"

        echo "# =============================================="
        echo "# === GO ${GO_VERSION}                              ==="
        echo "# =============================================="
        command -v go
        readlink -f "$(command -v go)"

        echo "# =============================================="
        echo "# === NODE.JS ${NODE_VERSION}                       ===="
        echo "# =============================================="
        command -v node
        readlink -f "$(command -v node)"

        echo "# =============================================="
        echo "# === NPM ${NPM_VERSION}                           ===="
        echo "# =============================================="
        command -v npm
        readlink -f "$(command -v npm)"
        echo "Prefix : $(npm config get prefix)"

        echo "# =============================================="
        echo "# === OPENCODE ${OPENCODE_VERSION}                       ==="
        echo "# =============================================="
        command -v opencode
        readlink -f "$(command -v opencode)"

        echo "# =============================================="
        echo "# === OPENSPEC ${OPENSPEC_VERSION}                         ==="
        echo "# =============================================="
        command -v openspec
        readlink -f "$(command -v openspec)"

        echo "# =============================================="
        echo "# === PATH                                   ==="
        echo "# =============================================="
        echo "$PATH"
        echo

    '

}

dispatch_arguments() {

    local argument_class="${1:-}"

    # Aucun argument : poursuite normale du DIU.
    if [[ "$#" -eq 0 ]]; then
        return 0
    fi

    case "$argument_class" in

        devops)
            shift
            manage_devops_action "$@"
            ;;

        docker)
            shift
            manage_docker_action "$@"
            ;;

        ia)
            shift
            manage_ia_action "$@"
            ;;

        os)
            shift
            manage_openspec_action "$@"
            ;;

        proj)
            shift
            manage_project_action "$@"
            ;;

        update)
            update_diu
            ;;

        version)
            diu_version
            ;;

        help|--help|-h)
            display_usage
            ;;

        *)
            echo "❌ Classe d'actions inconnue : $argument_class"
            display_usage
            exit 2
            ;;

    esac

    # Une action avec arguments ne doit pas poursuivre
    # l'installation Debian linéaire.
    exit 0
}

display_usage() {
    cat <<'EOF'

Utilisation :

  rid																→  Exécute normalement l'installation Debian.

  rid ia configure hm                                               →  Configure Agent Hermès
  rid ia install hm                                                 →  Install Agent Hermes
  rid ia docker ps                                                  →  Execute un docker PS dans l'environnement IA (rootless)                                                         
  rit ia start hm                                                   →  Start Agent Hermes
  rid ia stop hm                                                    →  Stop Agent Hermes
  rid ia update hm                                                  →  Mise à jour Agent Hermes
  rid ia uninstall hm                                               →  Uninstall Agent Hermes
  rid proj ocro <ID Projet>											→  Démarre un Docker OpenCode en lecture seul dans le projet /home/devops/datas/"ID Projet".
  rid proj ocrw <ID Projet>											→  Démarre un Docker OpenCode en écriture dans le projet /home/devops/datas/"ID Projet".

  rid docker root check-containers                                  →   Vérification des containers Docker Up
  rid docker root diag <USER>                                       →   Diagnostic Docker pour <USER>  
  rid docker root test <USER>                                       →   Teste l'état Docker pour <USER>
  rid docker rootless analyse <USER>                                →   Analyse l'état Docker Rootless pour <USER>
  rid docker rootless configure <USER>                              →   Configure Docker Rootless pour <USER>
  rid docker rootless diag <USER>                                   →   Diagnostic Docker Rootless pour <USER>
  rid docker rootless exec <USER> <CONTAINER>                       →   Exécute une commande Docker Rootless pour <USER> dans <CONTAINER>
  rid docker rootless inspect <USER> <CONTAINER>                    →   Inspecte le containers <CONTAINER> Docker Rootless pour <USER>
  rid docker rootless log <USER> <CONTAINER>                        →   Journaux du container <CONTAINER> Docker Rootless pour <USER>
  rid docker rootless ps <USER>                                     →   Liste des des container Up Docker Rootless pour <USER>
  rid docker rootless test <USER>                                   →   Teste Docker Rootless pour <USER>
  rid docker rootless unconfigure <USER>                            →   Déconfigure Docker Rootless pour <USER> et restaure l'état initial

  rid os validate <ID Projet> <Spec>								→  Valide la <Spec> validate pour le <Projet>.
  rid proj deb <ID Projet>                                          →  Construit le paquet Debian pour le <Projet> et le met dans dist/.
  rid proj bash <ID Projet> <Nom du Projet>                         →  Crée projet BASH <Nom du Projet> dans /home/<DEVOPS USER>/datas/<ID Projet>
  rid proj del <ID Projet>                                          →  Supprime le projet dans /home/<DEVOPS USER>/datas/<ID Projet>
  rid proj gita <ID Projet> <Nom du Projet>                         →  Analyse le dépôt Git local dans /home/<DEVOPS USER>/datas/<ID Projet>
  rid proj gitc <ID Projet> <Nom du Projet> <Nom du Commit>         →  Commit vers le dépôt Git local pour projet /home/devops/datas/"<ID Projet>
  rid proj giti <ID Projet> <Nom du Projet>                         →  Initialisation du dépôt Git local dans le projet /home/devops/datas/<ID Projet>.
  rid proj gitp <ID Projet> <Nom du Projet>                         →  Push vers le dépôt Git distant le dépôt Git local pour le projet /home/devops/datas/<ID Projet>.
  rid proj gits <ID Projet> <Nom du Projet>                         →  Statut du dépôt Git local pour le projet /home/devops/datas/<ID Projet>.
  rid proj rel <ID Projet>											→  Publie la Release sur le dépôt Git distant à partir du paquet Debian dans dist/.

  rid update														→  Mise à jour totale
  rid update diu												    →  Mise à jour du DIU

  ridt proj cicd <ID Projet> <Nom du Projet> <Nom du Commit>		→  Flux CI/CD Git local --> Git Distant --> Deb --> Publication

Structure générale :

  rid <classe> <action> <subaction> <variable>

Classe actuellement disponibles :

  Classe :  ia | docker | proj | update

EOF
}

display_infos() {
    local index
    local interface_var
    local state_var
    local type_var
    local ip_var
    local ip_cidr_var
    local gw_var

    echo ""
    echo "=============================================="
    echo " Informations réseau"
    echo "=============================================="
    echo ""

    for index in 1 2; do

        interface_var="INTERFACE_ETHERNET${index}"
        state_var="INTERFACE_ETHERNET${index}_STATE"
        type_var="INTERFACE_ETHERNET${index}_TYPE"
        ip_var="INTERFACE_ETHERNET${index}_IP"
        ip_cidr_var="INTERFACE_ETHERNET${index}_IP_CIDR"
        gw_var="INTERFACE_ETHERNET${index}_GW"

        # ------------------------------------------------------
        # Affichage uniquement si l'interface est UP
        # ------------------------------------------------------

        if [[ "${!state_var}" == "UP" ]]; then

            echo "Interface Ethernet ${index}"
            echo "----------------------------------------------"
            echo "Interface  : ${!interface_var}"
            echo "État       : ${!state_var}"
            echo "Type       : ${!type_var}"
            echo "Adresse IP : ${!ip_var}"
            echo "IP / CIDR  : ${!ip_cidr_var}"
            echo "Passerelle : ${!gw_var}"
            echo ""

        fi

    done
}

error_handler() {
    local exit_code=$?
    local line_number="${BASH_LINENO[0]}"
    local command="${BASH_COMMAND}"

    echo "" >&2
    echo "==============================================" >&2
    echo " ❌ ERREUR DIU" >&2
    echo "==============================================" >&2
    echo "Code     : ${exit_code}" >&2
    echo "Ligne    : ${line_number}" >&2
    echo "Commande : ${command}" >&2
    echo "==============================================" >&2
    echo "" >&2
}

git_analyse() {
    local project_id="$1"
    local project_name="$2"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"

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

    print_title "Analyse du dépôt Git"

    # ----------------------------------------------------------
    # Vérification des paramètres
    # ----------------------------------------------------------

    if [[ -z "${project_id}" ]]; then
        print_error "Usage : git_analyse <project_id> <project_name>"
        return 1
    fi

    # ----------------------------------------------------------
    # Vérification de l'utilisateur DevOps
    # ----------------------------------------------------------

    if ! check_devops_user; then
        print_error "L'utilisateur DevOps n'est pas disponible."
        return 1
    fi

    # ----------------------------------------------------------
    # Vérification du répertoire du projet
    # ----------------------------------------------------------

    if [[ ! -d "${project_path}" ]]; then
        print_error "Projet introuvable : ${project_path}"
        return 1
    fi

    # ----------------------------------------------------------
    # Vérification de Git
    # ----------------------------------------------------------

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

    # ----------------------------------------------------------
    # Vérification des droits d'accès
    # ----------------------------------------------------------

    if ! runuser -u "${DEVOPS_USER}" -- \
        test -r "${project_path}"; then

        print_error \
            "${DEVOPS_USER} ne peut pas lire le projet : ${project_path}"
        return 1
    fi

    # ----------------------------------------------------------
    # Vérification du dépôt Git
    # ----------------------------------------------------------

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" rev-parse \
        --is-inside-work-tree >/dev/null 2>&1; then

        print_error "Aucun dépôt Git valide dans : ${project_path}"
        return 1
    fi

    # ----------------------------------------------------------
    # Informations générales
    # ----------------------------------------------------------

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

    upstream_branch="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" rev-parse \
            --abbrev-ref \
            --symbolic-full-name \
            '@{upstream}' \
            2>/dev/null || true
    )"

    # ----------------------------------------------------------
    # Calcul des statistiques
    # ----------------------------------------------------------

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

    # ==========================================================
    # Informations générales
    # ==========================================================

    printf '\n'
    printf '%s\n' \
        "=========================================================="
    printf '%s\n' \
        " INFORMATIONS GÉNÉRALES"
    printf '%s\n' \
        "=========================================================="

    printf 'Projet             : %s\n' \
        "${project_name:-${project_id}}"
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

    # ==========================================================
    # Résumé chiffré
    # ==========================================================

    printf '\n'
    printf '%s\n' \
        "=========================================================="
    printf '%s\n' \
        " RÉSUMÉ DU DÉPÔT"
    printf '%s\n' \
        "=========================================================="

    printf 'Nombre de commits        : %s\n' "${commit_count}"
    printf 'Fichiers suivis          : %s\n' "${tracked_count}"
    printf 'Fichiers modifiés        : %s\n' "${modified_count}"
    printf 'Fichiers indexés         : %s\n' "${staged_count}"
    printf 'Fichiers non suivis      : %s\n' "${untracked_count}"
    printf 'Fichiers ignorés         : %s\n' "${ignored_count}"

    # ==========================================================
    # État du dépôt
    # ==========================================================

    printf '\n'
    printf '%s\n' \
        "=========================================================="
    printf '%s\n' \
        " ÉTAT DU DÉPÔT"
    printf '%s\n' \
        "=========================================================="

    runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" status \
        --short \
        --branch \
        --untracked-files=all

    if [[ -z "$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" status --porcelain=v1
    )" ]]; then

        printf '\nDépôt propre : aucune modification locale.\n'
    fi

    # ==========================================================
    # Fichiers suivis
    # ==========================================================

    printf '\n'
    printf '%s\n' \
        "=========================================================="
    printf '%s\n' \
        " FICHIERS SUIVIS"
    printf '%s\n' \
        "=========================================================="

    if [[ "${tracked_count}" -gt 0 ]]; then
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" ls-files
    else
        printf 'Aucun fichier suivi.\n'
    fi

    # ==========================================================
    # Modifications non indexées
    # ==========================================================

    printf '\n'
    printf '%s\n' \
        "=========================================================="
    printf '%s\n' \
        " MODIFICATIONS NON INDEXÉES"
    printf '%s\n' \
        "=========================================================="

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

    # ==========================================================
    # Modifications indexées
    # ==========================================================

    printf '\n'
    printf '%s\n' \
        "=========================================================="
    printf '%s\n' \
        " MODIFICATIONS INDEXÉES POUR LE PROCHAIN COMMIT"
    printf '%s\n' \
        "=========================================================="

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

    # ==========================================================
    # Fichiers non suivis
    # ==========================================================

    printf '\n'
    printf '%s\n' \
        "=========================================================="
    printf '%s\n' \
        " FICHIERS NON SUIVIS"
    printf '%s\n' \
        "=========================================================="

    if [[ "${untracked_count}" -gt 0 ]]; then
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" ls-files \
            --others \
            --exclude-standard
    else
        printf 'Aucun fichier non suivi.\n'
    fi

    # ==========================================================
    # Fichiers ignorés
    # ==========================================================

    # printf '\n'
    # printf '%s\n' \
        # "=========================================================="
    # printf '%s\n' \
        # " FICHIERS ET RÉPERTOIRES IGNORÉS"
    # printf '%s\n' \
        # "=========================================================="

    # if [[ "${ignored_count}" -gt 0 ]]; then
        # runuser -u "${DEVOPS_USER}" -- \
            # git -C "${project_path}" ls-files \
            # --others \
            # --ignored \
            # --exclude-standard
    # else
        # printf 'Aucun élément ignoré détecté.\n'
    # fi

    # ==========================================================
    # Configuration locale
    # ==========================================================

    printf '\n'
    printf '%s\n' \
        "=========================================================="
    printf '%s\n' \
        " CONFIGURATION GIT LOCALE"
    printf '%s\n' \
        "=========================================================="

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

    # ==========================================================
    # Configuration effective
    # ==========================================================

    printf '\n'
    printf '%s\n' \
        "=========================================================="
    printf '%s\n' \
        " CONFIGURATION GIT EFFECTIVE"
    printf '%s\n' \
        "=========================================================="

    runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" config \
        --list \
        --show-origin \
        --show-scope |
        sed -E \
            's#(https?://)[^/@:]+:[^/@]+@#\1***:***@#g'

    # ==========================================================
    # Identité Git
    # ==========================================================

    printf '\n'
    printf '%s\n' \
        "=========================================================="
    printf '%s\n' \
        " IDENTITÉ GIT"
    printf '%s\n' \
        "=========================================================="

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

    # ==========================================================
    # Dépôts distants
    # ==========================================================

    printf '\n'
    printf '%s\n' \
        "=========================================================="
    printf '%s\n' \
        " DÉPÔTS DISTANTS"
    printf '%s\n' \
        "=========================================================="

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

            runuser -u "${DEVOPS_USER}" -- \
                git -C "${project_path}" remote \
                show -n "${remote_name}" 2>/dev/null ||
                printf \
                    'Informations distantes indisponibles.\n'

        done < <(
            runuser -u "${DEVOPS_USER}" -- \
                git -C "${project_path}" remote
        )
    else
        printf 'Aucun dépôt distant configuré.\n'
    fi

    # ==========================================================
    # Branches locales
    # ==========================================================

    printf '\n'
    printf '%s\n' \
        "=========================================================="
    printf '%s\n' \
        " BRANCHES LOCALES"
    printf '%s\n' \
        "=========================================================="

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

    # ==========================================================
    # Branches distantes
    # ==========================================================

    printf '\n'
    printf '%s\n' \
        "=========================================================="
    printf '%s\n' \
        " BRANCHES DISTANTES"
    printf '%s\n' \
        "=========================================================="

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

    # ==========================================================
    # Synchronisation avec la branche distante
    # ==========================================================

    printf '\n'
    printf '%s\n' \
        "=========================================================="
    printf '%s\n' \
        " SYNCHRONISATION AVEC LA BRANCHE DISTANTE"
    printf '%s\n' \
        "=========================================================="

    if [[ -n "${upstream_branch}" ]]; then
        ahead_count="$(
            runuser -u "${DEVOPS_USER}" -- \
                git -C "${project_path}" rev-list \
                --count \
                "${upstream_branch}..HEAD" \
                2>/dev/null || printf '0'
        )"

        behind_count="$(
            runuser -u "${DEVOPS_USER}" -- \
                git -C "${project_path}" rev-list \
                --count \
                "HEAD..${upstream_branch}" \
                2>/dev/null || printf '0'
        )"

        printf 'Branche suivie     : %s\n' "${upstream_branch}"
        printf 'Commits en avance  : %s\n' "${ahead_count}"
        printf 'Commits en retard  : %s\n' "${behind_count}"
    else
        printf 'Aucune branche distante suivie.\n'
    fi

    # ==========================================================
    # Tags
    # ==========================================================

    printf '\n'
    printf '%s\n' \
        "=========================================================="
    printf '%s\n' \
        " TAGS"
    printf '%s\n' \
        "=========================================================="

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

    # ==========================================================
    # Historique des commits
    # ==========================================================

    printf '\n'
    printf '%s\n' \
        "=========================================================="
    printf '%s\n' \
        " HISTORIQUE DES COMMITS"
    printf '%s\n' \
        "=========================================================="

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

    # ==========================================================
    # Graphe de l'historique
    # ==========================================================

    printf '\n'
    printf '%s\n' \
        "=========================================================="
    printf '%s\n' \
        " GRAPHE DES COMMITS"
    printf '%s\n' \
        "=========================================================="

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

    # ==========================================================
    # Dernier commit
    # ==========================================================

    printf '\n'
    printf '%s\n' \
        "=========================================================="
    printf '%s\n' \
        " DERNIER COMMIT"
    printf '%s\n' \
        "=========================================================="

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

    # ==========================================================
    # Horodatage du dépôt
    # ==========================================================

    printf '\n'
    printf '%s\n' \
        "=========================================================="
    printf '%s\n' \
        " HORODATAGE DU DÉPÔT"
    printf '%s\n' \
        "=========================================================="

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

    # ==========================================================
    # Contributions par auteur
    # ==========================================================

    printf '\n'
    printf '%s\n' \
        "=========================================================="
    printf '%s\n' \
        " CONTRIBUTIONS PAR AUTEUR"
    printf '%s\n' \
        "=========================================================="

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

    # ==========================================================
    # Taille et objets du dépôt
    # ==========================================================

    printf '\n'
    printf '%s\n' \
        "=========================================================="
    printf '%s\n' \
        " TAILLE ET OBJETS DU DÉPÔT"
    printf '%s\n' \
        "=========================================================="

    runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" count-objects \
        --verbose \
        --human-readable

    # ==========================================================
    # Sous-modules
    # ==========================================================

    printf '\n'
    printf '%s\n' \
        "=========================================================="
    printf '%s\n' \
        " SOUS-MODULES"
    printf '%s\n' \
        "=========================================================="

    if [[ -f "${project_path}/.gitmodules" ]]; then
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" submodule \
            status 2>/dev/null ||
            printf 'Impossible de lire les sous-modules.\n'
    else
        printf 'Aucun sous-module configuré.\n'
    fi

    # ==========================================================
    # Hooks Git actifs
    # ==========================================================

    printf '\n'
    printf '%s\n' \
        "=========================================================="
    printf '%s\n' \
        " HOOKS GIT ACTIFS"
    printf '%s\n' \
        "=========================================================="

    hooks_path="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" config \
            --path core.hooksPath 2>/dev/null || true
    )"

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

    # ==========================================================
    # Configuration des exclusions
    # ==========================================================

    # printf '\n'
    # printf '%s\n' \
        # "=========================================================="
    # printf '%s\n' \
        # " CONFIGURATION DES EXCLUSIONS"
    # printf '%s\n' \
        # "=========================================================="

    # if [[ -f "${project_path}/.gitignore" ]]; then
        # printf 'Fichier .gitignore présent.\n\n'

        # runuser -u "${DEVOPS_USER}" -- \
            # cat "${project_path}/.gitignore"
    # else
        # printf 'Aucun fichier .gitignore à la racine du projet.\n'
    # fi

    # ==========================================================
    # Vérification finale
    # ==========================================================

    printf '\n'
    printf '%s\n' \
        "=========================================================="
    printf '%s\n' \
        " FIN DE L'ANALYSE"
    printf '%s\n' \
        "=========================================================="

    printf 'Analyse Git terminée pour : %s\n' \
        "${project_name:-${project_id}}"

    print_success \
        "Dépôt analysé avec l'utilisateur ${DEVOPS_USER}."
}

git_commit() {
    local project_id="$1"
    local project_name="$2"
    local commit_message="$3"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"

    print_title "Commit Git"

    # ----------------------------------------------------------
    # Vérification des paramètres
    # ----------------------------------------------------------

    if [[ -z "${project_id}" || -z "${commit_message}" ]]; then
        print_error \
            "Usage : git_commit <project_id> <project_name> <message>"
        return 1
    fi

    # ----------------------------------------------------------
    # Vérification de l'utilisateur DevOps
    # ----------------------------------------------------------

    if ! check_devops_user; then
        print_error "L'utilisateur DevOps n'est pas disponible."
        return 1
    fi

    # ----------------------------------------------------------
    # Vérification du projet
    # ----------------------------------------------------------

    if [[ ! -d "${project_path}" ]]; then
        print_error "Projet introuvable : ${project_path}"
        return 1
    fi

    # ----------------------------------------------------------
    # Vérification de Git
    # ----------------------------------------------------------

    if ! command -v git >/dev/null 2>&1; then
        print_error "Git n'est pas installé."
        return 1
    fi

    if ! runuser -u "${DEVOPS_USER}" -- git --version >/dev/null 2>&1; then
        print_error \
            "Git n'est pas accessible pour ${DEVOPS_USER}."
        return 1
    fi

    # ----------------------------------------------------------
    # Vérification du dépôt Git
    # ----------------------------------------------------------

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" rev-parse \
        --is-inside-work-tree >/dev/null 2>&1; then

        print_error "Aucun dépôt Git initialisé."
        return 1
    fi

    # ----------------------------------------------------------
    # Vérification des droits
    # ----------------------------------------------------------

    if ! runuser -u "${DEVOPS_USER}" -- test -w "${project_path}"; then
        print_error \
            "${DEVOPS_USER} ne peut pas écrire dans ${project_path}"
        return 1
    fi

    # ----------------------------------------------------------
    # Ajout des fichiers
    # ----------------------------------------------------------

    print_info "Ajout des modifications..."

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" add .; then

        print_error "Échec du git add."
        return 1
    fi

    # ----------------------------------------------------------
    # Vérification des modifications
    # ----------------------------------------------------------

    if runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" diff \
        --cached --quiet; then

        print_info "Aucune modification à enregistrer."
        return 0
    fi

    # ----------------------------------------------------------
    # Résumé avant commit
    # ----------------------------------------------------------

    print_title "Résumé des modifications"

    runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" status --short

    # ----------------------------------------------------------
    # Création du commit
    # ----------------------------------------------------------

    print_title "Création du commit"

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" commit \
        -m "${commit_message}"; then

        print_error "Échec du commit Git."
        return 1
    fi

    # ----------------------------------------------------------
    # Vérification finale
    # ----------------------------------------------------------

    print_title "Historique Git"

    runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" log \
        --oneline \
        --decorate \
        -5

    echo ""

    print_success "Commit Git créé avec succès."
}

git_init() {
    local project_id="$1"
    local project_name="$2"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"

    local confirmation=""
    local git_user_name=""
    local git_user_email=""

    echo ""
    echo "=============================================="
    echo " Initialisation GIT du projet ${project_name}"
    echo "=============================================="
    echo ""

    print_title "# ----------------------------------------------------------"
    print_title "# Vérification des paramètres."
    print_title "# ----------------------------------------------------------"

    if [[ -z "${project_id}" || -z "${project_name}" ]]; then
        print_error "Usage : git_init <project_id> <project_name>"
        return 1
    fi

    echo ""
    print_info \
        "Les paramètre du projets sont OK."

    print_title "# ----------------------------------------------------------"
    print_title "# Vérification de l'utilisateur DevOps."
    print_title "# ----------------------------------------------------------"

    check_devops_user

    echo ""
    print_info \
        "L'utilisateur DevOps est OK."

    print_title "# ----------------------------------------------------------"
    print_title "# La Vérification du répertoire du projet."
    print_title "# ----------------------------------------------------------"

    if [[ ! -d "${project_path}" ]]; then
        print_error \
            "Le répertoire du projet n'existe pas : ${project_path}"
        return 1
    fi

    echo ""
    print_info \
        "Le répertoire du projet est OK."

    print_title "# ----------------------------------------------------------"
    print_title "# Vérification de la commande Git"
    print_title "# ----------------------------------------------------------"

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

    echo ""
    print_info \
        "La commande Git est OK."

    print_title "# ----------------------------------------------------------"
    print_title "# Vérification des droits"
    print_title "# ----------------------------------------------------------"

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

    echo ""
    print_info \
        "Tests lecture / écriture dans le répertoire du projet OK."

    print_title "# ----------------------------------------------------------"
    print_title "# Vérification d'un dépôt Git local."
    print_title "# git rev-parse --is-inside-work-tree"
    print_title "# ----------------------------------------------------------"

    if runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" rev-parse \
        --is-inside-work-tree >/dev/null 2>&1; then

        print_info "Le dépôt Git est déjà initialisé."
        return 0
    fi

    echo ""
    print_info \
        "Absence d'un dépôt local OK."

    print_title "# ----------------------------------------------------------"
    print_title "# Confirmation de l'initialisation du dépot Git local."
    print_title "# ----------------------------------------------------------"

    read -r -p "Initialiser Git localement ? [o/N] : " confirmation

    case "${confirmation}" in
        o|O|oui|OUI|y|Y|yes|YES)
            ;;
        *)
            print_info "Initialisation annulée."
            return 0
            ;;
    esac

    print_title "# ----------------------------------------------------------"
    print_title "# Récupération des informations pour le dépôt Git local."
    print_title "# ----------------------------------------------------------"

    while [[ -z "${git_user_name}" ]]; do
        read -r -p "Utilisateur Git : " git_user_name

        if [[ -z "${git_user_name}" ]]; then
            print_error \
                "L'utilisateur Git ne peut pas être vide."
        fi
    done

    while [[ -z "${git_user_email}" ]]; do
        read -r -p "Email Git : " git_user_email

        if [[ -z "${git_user_email}" ]]; then
            print_error \
                "L'adresse email Git ne peut pas être vide."
        fi
    done

    print_title "# ----------------------------------------------------------"
    print_title "# Résumé de la configuration du dếpot Git locale saisi par l'utilisateur."
    print_title "# ----------------------------------------------------------"

    echo ""
    echo "Projet: ${project_name}"
    echo "Répertoire: ${project_path}"
    echo "Utilisateur Linux: ${DEVOPS_USER}"
    echo ""
    echo "  Utilisateur Git: ${git_user_name}"
    echo "  Email Git: ${git_user_email}"
    echo ""

    print_title "# ----------------------------------------------------------"
    print_title "# Initialisation du dépôt Git local."
    print_title "# git init -b main"
    print_title "# ----------------------------------------------------------"

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" init -b main; then

        print_error \
            "Échec de l'initialisation du dépôt Git."
        return 1
    fi

    print_title "# ----------------------------------------------------------"
    print_title "# Configuration locale du dépôt Git."
    print_title "# git config --local x.y"
    print_title "# ----------------------------------------------------------"
    print_title "Configuration de user.name."

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" config --local \
        user.name "${git_user_name}"; then

        print_error \
            "Échec de la configuration de user.name."
        return 1
    fi

    print_title "Configuration de user.email."

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" config --local \
        user.email "${git_user_email}"; then

        print_error \
            "Échec de la configuration de user.email."
        return 1
    fi

    print_title "Configuration de core.fileMode."

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" config --local \
        core.fileMode false; then

        print_error \
            "Échec de la configuration de core.fileMode."
        return 1
    fi

    print_title "Configuration de core.autocrlf."

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" config --local \
        core.autocrlf false; then

        print_error \
            "Échec de la configuration de core.autocrlf."
        return 1
    fi

    print_title "Configuration de core.eol."

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" config --local \
        core.eol lf; then

        print_error \
            "Échec de la configuration de core.eol."
        return 1
    fi

    print_title "Configuration de i18n.commitEncoding."

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" config --local \
        i18n.commitEncoding utf-8; then

        print_error \
            "Échec de la configuration de i18n.commitEncoding."
        return 1
    fi

    print_title "Configuration de i18n.logOutputEncoding."

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" config --local \
        i18n.logOutputEncoding utf-8; then

        print_error \
            "Échec de la configuration de i18n.logOutputEncoding."
        return 1
    fi

    print_title "# ----------------------------------------------------------"
    print_title "# Vérification de la configuration du dépôt Git locale."
    print_title "# git config --list --local"
    print_title "# ----------------------------------------------------------"

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" config \
        --list --local; then

        print_error \
            "Impossible d'afficher la configuration Git locale."
        return 1
    fi

    print_title "# ----------------------------------------------------------"
    print_title "# Vérification de l'absence de dépôt distant."
    print_title "# git remote | grep -q ."
    print_title "# ----------------------------------------------------------"

    if runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" remote |
        grep -q .; then

        print_error \
            "Un dépôt distant est déjà configuré alors que l'initialisation doit rester locale."

        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" remote -v

        return 1
    fi

    print_title "# ----------------------------------------------------------"
    print_title "# Ajout des fichiers au dépôt local."
    print_title "# git add ."
    print_title "# ----------------------------------------------------------"

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" add .; then

        print_error \
            "Échec de l'ajout des fichiers à l'index Git."
        return 1
    fi

    print_title "# ----------------------------------------------------------"
    print_title "# État du dépôt"
    print_title "# git status --short"
    print_title "# ----------------------------------------------------------"

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" status --short; then

        print_error \
            "Impossible d'afficher l'état du dépôt Git."
        return 1
    fi

    print_title "# ----------------------------------------------------------"
    print_title "# Fichiers réellement suivis dans le dépôt Git local."
    print_title "# git ls-files"
    print_title "# ----------------------------------------------------------"

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}"  ls-files; then

        print_error \
            "Impossible d'afficher les fichiers du dépôt Git."
        return 1
    fi

    echo ""
    print_info \
        "Aucun dépôt distant n'est configuré."

    print_title "# ----------------------------------------------------------"
    print_title "# Initialistion du premier commit."
    print_title "# git commit -m Initialisation du projet ${project_name}"
    print_title "# ----------------------------------------------------------"

    if runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" diff \
        --cached --quiet; then

        print_error \
            "Aucun fichier versionnable n'est disponible pour le premier commit."
        return 1
    fi

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" commit \
        -m "Initialisation du projet ${project_name}"; then

        print_error \
            "Échec de la création du premier commit."
        return 1
    fi

    print_title "# ----------------------------------------------------------"
    print_title "# Historique du premier commit."
    print_title "# git log --oneline"
    print_title "# ----------------------------------------------------------"

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" log \
        --oneline \
        --decorate \
        -5; then

        print_error \
            "Impossible d'afficher l'historique du premier commit Git."
        return 1
    fi

    print_title "# ----------------------------------------------------------"
    print_title "# Contenu du premier Commit."
    print_title "# git show --stat --summary HEAD"
    print_title "# ----------------------------------------------------------"

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" show \
        --stat \
        --summary \
        HEAD; then

        print_error \
            "Impossible d'afficher l'historique Git."
        return 1
    fi

    print_title "# ----------------------------------------------------------"
    print_title "# Présence éventuelle d'éléments non suivis dans le dépôt Git local."
    print_title "# git status --ignored --short"
    print_title "# ----------------------------------------------------------"

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" status --ignored --short; then

        print_error \
            "Impossible d'afficher les fichiers ignorés du dépôt Git."
        return 1
    fi

    echo ""
    print_success \
        "DEPOT GIT LOCAL INITIALISE AVEC SUCCES PAR L'UTILISATEUR ${DEVOPS_USER}."
}

git_push() {
    local project_path="${BASH_SCRIPT_PATH}"
    local current_branch=""
    local remote_name="origin"
    local remote_url=""
    local upstream=""
    local confirmation=""
    local push_rc=0

    print_title "Push Git du projet ${PROJECT_NAME:-DIU}"

    # ==========================================================
    # Vérification du projet
    # ==========================================================

    if [[ -z "${project_path}" ]]; then
        print_error "git_push : BASH_SCRIPT_PATH est vide."
        return 1
    fi

    if [[ ! -d "${project_path}" ]]; then
        print_error "Le projet n'existe pas : ${project_path}"
        return 1
    fi

    if [[ -z "${ENV_DEVOPS_USER}" ]]; then
        print_error "git_push : ENV_DEVOPS_USER est vide."
        return 1
    fi

    if ! id "${ENV_DEVOPS_USER}" >/dev/null 2>&1; then
        print_error \
            "L'utilisateur Git '${ENV_DEVOPS_USER}' n'existe pas."
        return 1
    fi

    # ==========================================================
    # Vérification dépôt Git
    # ==========================================================

    if ! sudo -u "${ENV_DEVOPS_USER}" \
        git -C "${project_path}" rev-parse --git-dir >/dev/null 2>&1; then

        print_error \
            "Le projet n'est pas un dépôt Git pour ${ENV_DEVOPS_USER} : ${project_path}"
        return 1
    fi

    # ==========================================================
    # Dépôt Git
    # ==========================================================

    print_title "Dépôt Git"

    current_branch="$(
        sudo -u "${ENV_DEVOPS_USER}" \
            git -C "${project_path}" branch --show-current 2>/dev/null
    )"

    if [[ -z "${current_branch}" ]]; then
        print_error "Impossible de déterminer la branche Git courante."
        return 1
    fi

    remote_url="$(
        sudo -u "${ENV_DEVOPS_USER}" \
            git -C "${project_path}" remote get-url "${remote_name}" 2>/dev/null
    )"

    if [[ -z "${remote_url}" ]]; then
        print_error "Le remote '${remote_name}' n'est pas configuré."
        return 1
    fi

    printf '%-18s : %s\n' "Projet" "${PROJECT_NAME:-DIU}"
    printf '%-18s : %s\n' "Répertoire" "${project_path}"
    printf '%-18s : %s\n' "Utilisateur" "${ENV_DEVOPS_USER}"
    printf '%-18s : %s\n' "Branche locale" "${current_branch}"
    printf '%-18s : %s\n' "Remote" "${remote_name}"
    printf '%-18s : %s\n' "URL distante" "${remote_url}"

    # ==========================================================
    # git status
    # ==========================================================

    print_title "git status"

    if ! sudo -u "${ENV_DEVOPS_USER}" \
        git -C "${project_path}" status; then

        print_error "Impossible d'obtenir l'état Git du projet."
        return 1
    fi

    # ==========================================================
    # git log
    # ==========================================================

    print_title "git log --oneline"

    if ! sudo -u "${ENV_DEVOPS_USER}" \
        git -C "${project_path}" log --oneline -10; then

        print_error "Impossible de lire l'historique Git."
        return 1
    fi

    # ==========================================================
    # Credentials Forgejo
    # ==========================================================

    if ! _forgejo_ensure_credentials "${project_path}"; then
        print_error "Impossible d'initialiser les credentials Forgejo."
        return 1
    fi

    # ==========================================================
    # Branche distante de suivi
    # ==========================================================

	upstream=""

	if sudo -u "${ENV_DEVOPS_USER}" \
		git -C "${project_path}" \
		rev-parse --verify \
		"${current_branch}@{upstream}" >/dev/null 2>&1; then

		upstream="$(
			sudo -u "${ENV_DEVOPS_USER}" \
				git -C "${project_path}" \
				rev-parse --abbrev-ref \
				--symbolic-full-name "${current_branch}@{upstream}" \
				2>/dev/null
		)"
	fi

    if [[ -z "${upstream}" ]]; then
        print_info "Aucune branche distante de suivi n'est encore configurée."

        printf '\n'
        print_info "Le dépôt local va être envoyé vers :"
        printf '  %s\n' "${remote_url}"
        printf '\n'
        printf 'Branche : %s\n' "${current_branch}"
    else
        print_info "Branche distante de suivi : ${upstream}"
    fi

    # ==========================================================
    # Confirmation
    # ==========================================================

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

    # ==========================================================
    # Push vers Forgejo
    # ==========================================================

    print_title "Push vers Forgejo"

    if [[ -z "${upstream}" ]]; then

        print_info \
            "Premier push : création de la branche distante et de son suivi."

        forgejo_git_push \
            "${project_path}" \
            -u "${remote_name}" "${current_branch}" || push_rc=$?

    else

        print_info \
            "Push de la branche ${current_branch} vers ${upstream}."

        forgejo_git_push \
            "${project_path}" || push_rc=$?

    fi

    if [[ "${push_rc}" -ne 0 ]]; then
        print_error \
            "Échec du push vers Forgejo (code ${push_rc})."
        return "${push_rc}"
    fi

    print_success "Push Git terminé avec succès."

    return 0
}

git_status() {
    local project_id="$1"
    local project_name="$2"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"

    local current_branch=""
    local upstream_branch=""
    local status_output=""
    local tracked_count="0"
    local modified_count="0"
    local staged_count="0"
    local untracked_count="0"

    print_title "État du dépôt Git"

    # ----------------------------------------------------------
    # Vérification des paramètres
    # ----------------------------------------------------------

    if [[ -z "${project_id}" ]]; then
        print_error "Usage : git_status <project_id> <project_name>"
        return 1
    fi

    # ----------------------------------------------------------
    # Vérification de l'utilisateur DevOps
    # ----------------------------------------------------------

    if ! check_devops_user; then
        print_error "L'utilisateur DevOps n'est pas disponible."
        return 1
    fi

    # ----------------------------------------------------------
    # Vérification du projet
    # ----------------------------------------------------------

    if [[ ! -d "${project_path}" ]]; then
        print_error "Projet introuvable : ${project_path}"
        return 1
    fi

    # ----------------------------------------------------------
    # Vérification de Git
    # ----------------------------------------------------------

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

    # ----------------------------------------------------------
    # Vérification du dépôt Git
    # ----------------------------------------------------------

    if ! runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" rev-parse \
        --is-inside-work-tree >/dev/null 2>&1; then

        print_error "Aucun dépôt Git valide dans : ${project_path}"
        return 1
    fi

    # ----------------------------------------------------------
    # Récupération des informations principales
    # ----------------------------------------------------------

    current_branch="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" branch \
            --show-current 2>/dev/null
    )"

    if [[ -z "${current_branch}" ]]; then
        current_branch="HEAD détachée"
    fi

    upstream_branch="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" rev-parse \
            --abbrev-ref \
            --symbolic-full-name \
            '@{upstream}' \
            2>/dev/null || true
    )"

    status_output="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" status \
            --short \
            --untracked-files=all
    )"

    tracked_count="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" ls-files |
            wc -l |
            tr -d ' '
    )"

    modified_count="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" diff \
            --name-only |
            wc -l |
            tr -d ' '
    )"

    staged_count="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" diff \
            --cached \
            --name-only |
            wc -l |
            tr -d ' '
    )"

    untracked_count="$(
        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" ls-files \
            --others \
            --exclude-standard |
            wc -l |
            tr -d ' '
    )"

    # ----------------------------------------------------------
    # Résumé du dépôt
    # ----------------------------------------------------------

    echo "Projet             : ${project_name:-${project_id}}"
    echo "Répertoire         : ${project_path}"
    echo "Utilisateur Git    : ${DEVOPS_USER}"
    echo "Branche courante   : ${current_branch}"

    if [[ -n "${upstream_branch}" ]]; then
        echo "Branche distante   : ${upstream_branch}"
    else
        echo "Branche distante   : aucune"
    fi

    echo ""
    echo "Fichiers suivis    : ${tracked_count}"
    echo "Fichiers modifiés  : ${modified_count}"
    echo "Fichiers indexés   : ${staged_count}"
    echo "Fichiers non suivis: ${untracked_count}"

    # ----------------------------------------------------------
    # État des fichiers
    # ----------------------------------------------------------

    print_title "Modifications locales"

    if [[ -n "${status_output}" ]]; then
        printf '%s\n' "${status_output}"
    else
        print_success "Le dépôt est propre."
    fi

    # ----------------------------------------------------------
    # Dernier commit
    # ----------------------------------------------------------

    print_title "Dernier commit"

    if runuser -u "${DEVOPS_USER}" -- \
        git -C "${project_path}" rev-parse \
        --verify HEAD >/dev/null 2>&1; then

        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" log \
            -1 \
            --date=iso-local \
            --format='Commit  : %h%nDate    : %ad%nAuteur  : %an <%ae>%nMessage : %s'

        echo ""

        # ------------------------------------------------------
        # Historique récent
        # ------------------------------------------------------

        print_title "Historique récent"

        runuser -u "${DEVOPS_USER}" -- \
            git -C "${project_path}" log \
            --oneline \
            --decorate \
            --max-count=5
    else
        print_info "Le dépôt ne contient encore aucun commit."
    fi

    echo ""
    print_success \
        "État Git affiché pour ${project_name:-${project_id}}."
}

info_docker_analyse_container() {
    local container="$1"
    local pids
    local pid
    local uid
    local gid
    local users

    # ----------------------------------------------------------
    # Vérification du paramètre
    # ----------------------------------------------------------

    if [ -z "$container" ]; then
        printf "?\n"
        return 1
    fi

    # ----------------------------------------------------------
    # Vérification du conteneur
    # ----------------------------------------------------------

    if ! docker inspect "$container" >/dev/null 2>&1; then
        printf "?\n"
        return 1
    fi

    # ----------------------------------------------------------
    # Récupération des PID des processus du conteneur
    # ----------------------------------------------------------

    pids="$(
        docker top "$container" -eo pid 2>/dev/null |
        awk 'NR > 1 {print $1}'
    )"

    if [ -z "$pids" ]; then
        printf "?\n"
        return 0
    fi

    # ----------------------------------------------------------
    # Récupération des UID:GID de chaque processus
    # ----------------------------------------------------------

    users="$(
        for pid in $pids; do

            if [ -r "/proc/$pid/status" ]; then

                uid="$(
                    awk '/^Uid:/ {print $2}' \
                        "/proc/$pid/status"
                )"

                gid="$(
                    awk '/^Gid:/ {print $2}' \
                        "/proc/$pid/status"
                )"

                if [ -n "$uid" ] && [ -n "$gid" ]; then
                    printf "%s:%s\n" "$uid" "$gid"
                fi

            fi

        done |
        sort -u |
        paste -sd ',' -
    )"

    # ----------------------------------------------------------
    # Résultat
    # ----------------------------------------------------------

    if [ -n "$users" ]; then
        printf "%s\n" "$users"
    else
        printf "?\n"
    fi
}

info_network_detect_interfaces() {
    local -a physical_interfaces=()
    local iface=""
    local index=0
    local ip_cidr=""
    local ip_addr=""
    local gateway=""
    local state=""
    local type=""
    local master=""
    local operstate=""

    # ==========================================================
    # Valeurs par défaut
    # ==========================================================

    export INTERFACE_ETHERNET1="NONE"
    export INTERFACE_ETHERNET1_STATE="DOWN"
    export INTERFACE_ETHERNET1_TYPE="NONE"
    export INTERFACE_ETHERNET1_IP="NONE"
    export INTERFACE_ETHERNET1_IP_CIDR="NONE"
    export INTERFACE_ETHERNET1_GW="NONE"

    export INTERFACE_ETHERNET2="NONE"
    export INTERFACE_ETHERNET2_STATE="DOWN"
    export INTERFACE_ETHERNET2_TYPE="NONE"
    export INTERFACE_ETHERNET2_IP="NONE"
    export INTERFACE_ETHERNET2_IP_CIDR="NONE"
    export INTERFACE_ETHERNET2_GW="NONE"

    # ==========================================================
    # Recherche des interfaces réseau physiques
    #
    # /sys/class/net/<interface>/device permet d'exclure
    # les interfaces virtuelles telles que :
    #
    #   lo
    #   docker0
    #   br-xxxxxxxxxxxx
    #   vmbrX
    #   vethXXXX
    #   ovs-system
    #
    # et de conserver les interfaces physiques :
    #
    #   eno1
    #   enpXsY
    #   ethX
    #   wlanX
    #   wlpXsY
    #   wlxXXXXXXXXXXXX
    # ==========================================================

    while IFS= read -r iface; do

        [[ "${iface}" == "lo" ]] && continue

        if [[ -e "/sys/class/net/${iface}/device" ]]; then
            physical_interfaces+=("${iface}")
        fi

    done < <(
        ip -o link show |
        awk -F': ' '{print $2}' |
        cut -d'@' -f1
    )

    # ==========================================================
    # Analyse des interfaces physiques
    #
    # Maximum : deux interfaces
    # ==========================================================

    for iface in "${physical_interfaces[@]:0:2}"; do

        index=$((index + 1))

        ip_cidr="NONE"
        ip_addr="NONE"
        gateway="NONE"
        state="DOWN"
        type="NONE"
        master="NONE"
        operstate=""

        # ------------------------------------------------------
        # Etat physique de l'interface
        #
        # STATE ne peut avoir que deux valeurs :
        #
        #   UP
        #   DOWN
        # ------------------------------------------------------

        if [[ -r "/sys/class/net/${iface}/operstate" ]]; then
            operstate="$(<"/sys/class/net/${iface}/operstate")"
        fi

        if [[ "${operstate}" == "up" ]]; then
            state="UP"
        else
            state="DOWN"
        fi

        # ------------------------------------------------------
        # Adresse IPv4
        # ------------------------------------------------------

        ip_cidr="$(
            ip -o -4 addr show dev "${iface}" scope global 2>/dev/null |
            awk 'NR == 1 {print $4}'
        )"

        if [[ -n "${ip_cidr}" ]]; then
            ip_addr="${ip_cidr%/*}"
        else
            ip_cidr="NONE"
            ip_addr="NONE"
        fi

        # ------------------------------------------------------
        # Passerelle IPv4
        #
        # Recherche de la route par défaut utilisant
        # directement cette interface.
        # ------------------------------------------------------

        gateway="$(
            ip -4 route show default dev "${iface}" 2>/dev/null |
            awk '
                NR == 1 {
                    for (i = 1; i <= NF; i++) {
                        if ($i == "via") {
                            print $(i + 1)
                            exit
                        }
                    }
                }
            '
        )"

        if [[ -z "${gateway}" ]]; then
            gateway="NONE"
        fi

        # ------------------------------------------------------
        # Recherche du master réseau
        #
        # Exemple :
        #
        #   eno1 master vmbr0
        #
        # Cela permet notamment de déterminer si l'interface
        # physique est rattachée à un bridge Proxmox.
        # ------------------------------------------------------

        master="$(
            ip -o link show dev "${iface}" 2>/dev/null |
            sed -n 's/.* master \([^ ]*\).*/\1/p'
        )"

        if [[ -z "${master}" ]]; then
            master="NONE"
        fi

        # ------------------------------------------------------
        # Détermination du type de configuration
        #
        # TYPE peut avoir les valeurs :
        #
        #   NONE
        #   DHCP
        #   STATIC
        #   PROXMOX
        #   LXC
        # ------------------------------------------------------

        if [[ "${master}" == vmbr* ]]; then

            type="PROXMOX"

        elif [[ "${master}" == lxcbr* ]]; then

            type="LXC"

        elif [[ "${ip_addr}" == "NONE" ]]; then

            type="NONE"

        elif ip -4 addr show dev "${iface}" 2>/dev/null |
             grep -qE '\bdynamic\b'; then

            type="DHCP"

        else

            type="STATIC"

        fi

        # ------------------------------------------------------
        # Création des variables globales
        # ------------------------------------------------------

        printf -v "INTERFACE_ETHERNET${index}" \
            '%s' "${iface}"

        printf -v "INTERFACE_ETHERNET${index}_STATE" \
            '%s' "${state}"

        printf -v "INTERFACE_ETHERNET${index}_TYPE" \
            '%s' "${type}"

        printf -v "INTERFACE_ETHERNET${index}_IP" \
            '%s' "${ip_addr}"

        printf -v "INTERFACE_ETHERNET${index}_IP_CIDR" \
            '%s' "${ip_cidr}"

        printf -v "INTERFACE_ETHERNET${index}_GW" \
            '%s' "${gateway}"

        # ------------------------------------------------------
        # Export des variables
        # ------------------------------------------------------

        export "INTERFACE_ETHERNET${index}"
        export "INTERFACE_ETHERNET${index}_STATE"
        export "INTERFACE_ETHERNET${index}_TYPE"
        export "INTERFACE_ETHERNET${index}_IP"
        export "INTERFACE_ETHERNET${index}_IP_CIDR"
        export "INTERFACE_ETHERNET${index}_GW"

    done
}

launch_oc_shell() {

	local project_id="$1"
    local project_name="$2"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"
    local confirmation
	su - ${DEVOPS_USER} -c "docker exec -it ${project_id}-opencode sh"
}

launch_ocro() {

    local project_id="$1"
    local project_name="$2"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"
    local confirmation

    if [[ ! -e "$project_path/.opencode/share" ]]; then
        echo "❌ Le projet n'existe pas :"
        echo "   $project_path/.opencode/share"
        exit 1
    fi

    ensure_docker_image \
        "${ENV_DOCKER_IMAGE_OPENCODE}" \
        "${ENV_DOCKER_IMAGE_OPENCODE_UPDATE_POLICY}"  || return 1

    su - "${ENV_DEVOPS_USER}" -c "docker run --rm -it \
      --hostname ${project_id}-opencode \
      --name ${project_id}-opencode \
      --workdir /workspace \
      --tmpfs /tmp:rw,exec,nosuid,nodev,size=256m,mode=1777 \
      --security-opt no-new-privileges:true \
      --pids-limit 256 \
      --memory 2g \
      --cpus 2 \
      -e OPENCODE_UID=$(id -u "${ENV_DEVOPS_USER}") \
      -e OPENCODE_GID=$(id -g "${ENV_DEVOPS_USER}") \
      -e HOME=/home/opencode \
      -e XDG_CACHE_HOME=/home/opencode/.cache \
      -e XDG_CONFIG_HOME=/home/opencode/.config \
      -e XDG_DATA_HOME=/home/opencode/.local/share \
      -e XDG_STATE_HOME=/home/opencode/.local/state \
      -e NPM_CONFIG_CACHE=/home/opencode/.cache/opencode/npm \
      -e OPENCODE_CONFIG=/home/opencode/.config/opencode/opencode.json \
      -e OPENCODE_DISABLE_AUTOUPDATE=true \
      -e OPENCODE_DISABLE_DEFAULT_PLUGINS=false \
      -e OPENCODE_DISABLE_LSP_DOWNLOAD=false \
      -e PATH='/opt/devops/npm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' \
      -v /home/devops/datas/${project_id}:/workspace:ro \
      -v /home/devops/datas/${project_id}/.opencode/cache:/home/opencode/.cache/opencode:rw \
      -v /home/devops/datas/${project_id}/.opencode/config:/home/opencode/.config/opencode:rw \
      -v /home/devops/datas/${project_id}/.opencode/share:/home/opencode/.local/share:rw \
      -v /home/devops/datas/${project_id}/.opencode/state:/home/opencode/.local/state/opencode:rw \
      -v /home/devops/.local/npm:/opt/devops/npm:ro \
      --entrypoint /bin/sh \
      ghcr.io/anomalyco/opencode \
      -c 'apk add --no-cache bash git nodejs npm shellcheck su-exec && \
          exec su-exec \"\$OPENCODE_UID:\$OPENCODE_GID\" opencode --hostname 0.0.0.0 --port 4096'"
}

launch_ocrw() {
    local project_id="$1"
    local project_name="$2"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"
    local confirmation

    if [[ ! -e "$project_path/.opencode/share" ]]; then
        echo "❌ Le projet n'existe pas :"
        echo "   $project_path/.opencode/share"
        exit 1
    fi

    ensure_docker_image \
        "${ENV_DOCKER_IMAGE_OPENCODE}" \
        "${ENV_DOCKER_IMAGE_OPENCODE_UPDATE_POLICY}"  || return 1

    su - "${ENV_DEVOPS_USER}" -c "docker run --rm -it \
      --hostname ${project_id}-opencode \
      --name ${project_id}-opencode \
      --workdir /workspace \
      --tmpfs /tmp:rw,exec,nosuid,nodev,size=256m,mode=1777 \
      --security-opt no-new-privileges:true \
      --pids-limit 256 \
      --memory 2g \
      --cpus 2 \
      -e OPENCODE_UID=$(id -u "${ENV_DEVOPS_USER}") \
      -e OPENCODE_GID=$(id -g "${ENV_DEVOPS_USER}") \
      -e HOME=/home/opencode \
      -e XDG_CACHE_HOME=/home/opencode/.cache \
      -e XDG_CONFIG_HOME=/home/opencode/.config \
      -e XDG_DATA_HOME=/home/opencode/.local/share \
      -e XDG_STATE_HOME=/home/opencode/.local/state \
      -e NPM_CONFIG_CACHE=/home/opencode/.cache/opencode/npm \
      -e OPENCODE_CONFIG=/home/opencode/.config/opencode/opencode.json \
      -e OPENCODE_DISABLE_AUTOUPDATE=true \
      -e OPENCODE_DISABLE_DEFAULT_PLUGINS=false \
      -e OPENCODE_DISABLE_LSP_DOWNLOAD=false \
      -e PATH='/opt/devops/npm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' \
      -v /home/devops/datas/${project_id}:/workspace:rw \
      -v /home/devops/datas/${project_id}/.opencode/cache:/home/opencode/.cache/opencode:rw \
      -v /home/devops/datas/${project_id}/.opencode/config:/home/opencode/.config/opencode:rw \
      -v /home/devops/datas/${project_id}/.opencode/share:/home/opencode/.local/share:rw \
      -v /home/devops/datas/${project_id}/.opencode/state:/home/opencode/.local/state/opencode:rw \
      -v /home/devops/.local/npm:/opt/devops/npm:ro \
      --entrypoint /bin/sh \
      ghcr.io/anomalyco/opencode \
      -c 'apk add --no-cache bash git nodejs npm shellcheck su-exec &&
          exec su-exec \"\$OPENCODE_UID:\$OPENCODE_GID\" opencode --hostname 0.0.0.0 --port 4096'"
}

manage_devops_action() {

    local action_1="${1:-}"
    local project_id="${2:-}"
    local action_2="${3:-}"
    local value="${4:-}"

    case "$action_1" in

        info)
            devops_info
            ;;

        os)
            manage_devops_openspec_action \
                "$action_2" \
                "$project_id" \
                "$value"
            ;;

        *)
            echo "❌ Action inconnue pour la classe 'devops' : ${action_1}"
            display_usage
            exit 2
            ;;

    esac
}

manage_devops_openspec_action() {
    local action_2="$1"
    local project_id="$2"
    local spec_name="$3"

    case "$action_2" in
        list)
            devops_openspec_list "$project_id"
            ;;
        show)
            devops_openspec_show "$project_id"
            ;;
        vc)
            devops_openspec_validate_change "$project_id" "$spec_name"
            ;;
        vs)
            devops_openspec_validate_spec "$project_id" "$spec_name"
            ;;
        view)
            devops_openspec_view "$project_id"
            ;;
        *)
            echo "❌ Action inconnue pour la classe 'openspec' : $action"
            display_usage
            exit 2
            ;;
    esac
}

manage_docker_action() {

    local action="${1:-}"
    local subaction="${2:-}"
    local username="${3:-}"
    shift 3 2>/dev/null || true

    case "$action" in

        root)

            case "$subaction" in

                check-containers)
                    docker_root_check_containers
                    ;;

                test)

                    if [[ -z "$username" ]]; then
                        echo "❌ Le nom d'utilisateur est obligatoire."
                        display_usage
                        exit 2
                    fi

                    docker_root_test "$username"
                    ;;

                diag)

                    if [[ -z "$username" ]]; then
                        echo "❌ Le nom d'utilisateur est obligatoire."
                        display_usage
                        exit 2
                    fi

                    docker_root_diag "$username"
                    ;;

                *)

                    echo "❌ Action root inconnue : ${subaction}"
                    display_usage
                    exit 2
                    ;;

            esac
            ;;

        rootless)

            case "$subaction" in

                analyse)

                    if [[ -z "$username" ]]; then
                        echo "❌ Le nom d'utilisateur est obligatoire."
                        display_usage
                        exit 2
                    fi

                    docker_rootless_analyse "$username"
                    ;;

                configure)

                    if [[ -z "$username" ]]; then
                        echo "❌ Le nom d'utilisateur est obligatoire."
                        display_usage
                        exit 2
                    fi

                    docker_rootless_configure "$username"
                    ;;

                delete-state)

                    if [[ -z "$username" ]]; then
                        echo "❌ Le nom d'utilisateur est obligatoire."
                        display_usage
                        exit 2
                    fi

                    docker_rootless_delete_state "$username"
                    ;;

                diag)

                    if [[ -z "$username" ]]; then
                        echo "❌ Le nom d'utilisateur est obligatoire."
                        display_usage
                        exit 2
                    fi

                    docker_rootless_diag "$username"
                    ;;

                exec)

                    if [[ -z "$username" ]]; then
                        echo "❌ Le nom d'utilisateur est obligatoire."
                        display_usage
                        exit 2
                    fi

                    docker_rootless_exec "$username" "$@"
                    ;;

                inspect)

                    if [[ -z "$username" ]]; then
                        echo "❌ Le nom d'utilisateur est obligatoire."
                        display_usage
                        exit 2
                    fi

                    docker_rootless_inspect "$username" "$value4"
                    ;;

                log)

                    if [[ -z "$username" ]]; then
                        echo "❌ Le nom d'utilisateur est obligatoire."
                        display_usage
                        exit 2
                    fi

                    docker_rootless_log "$username" "$@"
                    ;;

                ps)

                    if [[ -z "$username" ]]; then
                        echo "❌ Le nom d'utilisateur est obligatoire."
                        display_usage
                        exit 2
                    fi

                    docker_rootless_ps "$username"
                    ;;

                unconfigure)

                    if [[ -z "$username" ]]; then
                        echo "❌ Le nom d'utilisateur est obligatoire."
                        display_usage
                        exit 2
                    fi

                    docker_rootless_unconfigure "$username"
                    ;;

                restore-state)

                    if [[ -z "$username" ]]; then
                        echo "❌ Le nom d'utilisateur est obligatoire."
                        display_usage
                        exit 2
                    fi

                    docker_rootless_restore_state "$username"
                    ;;

                save-state)

                    if [[ -z "$username" ]]; then
                        echo "❌ Le nom d'utilisateur est obligatoire."
                        display_usage
                        exit 2
                    fi

                    docker_rootless_save_state "$username"
                    ;;

                test)

                    if [[ -z "$username" ]]; then
                        echo "❌ Le nom d'utilisateur est obligatoire."
                        display_usage
                        exit 2
                    fi

                    docker_test_rootless "$username"
                    ;;

                *)

                    echo "❌ Action rootless inconnue : ${subaction}"
                    display_usage
                    exit 2
                    ;;

            esac
            ;;

        *)

            echo "❌ Action inconnue pour la classe 'docker' : ${action}"
            display_usage
            exit 2
            ;;

    esac
}

manage_ia_action() {

    local action="${1:-}"
    local value2="${2:-}"
    local value3="${3:-}"
    shift 3 2>/dev/null || true

    case "$action" in

        configure)
            case "$value2" in
                hm)
                    configure_agent_hermes
                    ;;
                *)
                    echo "❌ Agent (${value2}) inconnu pour l'action (${action})."
                    display_usage
                    exit 2
                    ;;
            esac
            ;;

        install)
            case "$value2" in
                hm)
                    install_agent_hermes
                    ;;
                *)
                    echo "❌ Agent (${value2}) inconnu pour l'action (${action})."
                    display_usage
                    exit 2
                    ;;
            esac
            ;;

        start)
            case "$value2" in
                hm)
                    start_agent_hermes
                    ;;
                *)
                    echo "❌ Agent (${value2}) inconnu pour l'action (${action})."
                    display_usage
                    exit 2
                    ;;
            esac
            ;;

        stop)
            case "$value2" in
                hm)
                    stop_agent_hermes
                    ;;
                *)
                    echo "❌ Agent (${value2}) inconnu pour l'action (${action})."
                    display_usage
                    exit 2
                    ;;
            esac
            ;;

        update)
            case "$value2" in
                hm)
                    update_agent_hermes
                    ;;
                *)
                    echo "❌ Agent (${value2}) inconnu pour l'action (${action})."
                    display_usage
                    exit 2
                    ;;
            esac
            ;;

        uninstall)
            case "$value2" in
                hm)
                    uninstall_agent_hermes
                    ;;
                *)
                    echo "❌ Agent (${value2}) inconnu pour l'action (${action})."
                    display_usage
                    exit 2
                    ;;
            esac
            ;;

        *)
            echo "❌ Action (${action}) inconnue pour la classe 'ia'."
            display_usage
            exit 2
            ;;

    esac
}

manage_project_action() {

    local action="${1:-}"
    local project_id="${2:-}"
    local project_name="${3:-}"
    local commit_name="${4:-}"

    case "$action" in

        cicd)
            cicd_project \
                "$project_id" \
                "$project_name" \
                "$commit_name"
            ;;

        del)
            delete_project \
                "$project_id" \
                "$project_name"
            ;;

        bash)
            create_project_bash \
                "$project_id" \
                "$project_name"
            ;;

        gita)
            git_analyse \
                "$project_id" \
                "$project_name"
            ;;

        gitc)
            git_commit \
                "$project_id" \
                "$project_name" \
                "$commit_name"
            ;;

        giti)
            git_init \
                "$project_id" \
                "$project_name"
            ;;

        gitp)
            git_push \
                "$project_id" \
                "$project_name"
            ;;

        gits)
            git_status \
                "$project_id" \
                "$project_name"
            ;;

        ocro)
            launch_ocro \
                "$project_id" \
                "$project_name"
            ;;

        ocrw)
            launch_ocrw \
                "$project_id" \
                "$project_name"
            ;;

        ocsh)
            launch_oc_shell \
                "$project_id" \
                "$project_name"
            ;;

        deb)
            build_deb \
                "$project_id"
            ;;

        rel)
            publish_release \
                "$project_id"
            ;;

        *)
            echo "❌ Action inconnue pour la classe 'proj' : ${action}"
            display_usage
            exit 2
            ;;

    esac
}

devops_openspec_list() {
    local project_id="$1"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"

    su - "$DEVOPS_USER" -c "cd '$project_path' && openspec list"

    exit 0
}

devops_openspec_show() {
    local project_id="$1"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"

    su - "$DEVOPS_USER" -c "cd '$project_path' && openspec show"

    exit 0
}

devops_openspec_validate_change() {
    local project_id="$1"
    local spec_name="$2"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"

    su - "$DEVOPS_USER" -c "cd '$project_path' && openspec validate '$spec_name' --type change --strict"

    exit 0
}

devops_openspec_validate_spec() {
    local project_id="$1"
    local spec_name="$2"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"

    su - "$DEVOPS_USER" -c "cd '$project_path' && openspec validate '$spec_name' --type spec --strict"

    exit 0
}

devops_openspec_view() {
    local project_id="$1"
    local project_path="${DEVOPS_PROJECTS_ROOT}/${project_id}"

    su - "$DEVOPS_USER" -c "cd '$project_path' && openspec view"

    exit 0
}

# Affichage des erreurs
trap 'error_handler' ERR

# Analyse des Interfaces Physique
info_network_detect_interfaces

# Analyse des arguments transmis au DIU.
dispatch_arguments "$@"

######################
###### ROOT MODE #####
######################

###  PROXY ###

if [ $PROXY_CA -eq 1 ]
then

	echo "🔧 Configure CA"
	echo "$CA" > /usr/local/share/ca-certificates/CHN.crt
	update-ca-certificates
	ls /etc/ssl/certs/ | grep -i CHN
	openssl x509 -in /etc/ssl/certs/CHN.pem -text -noout

fi

if [ $PROXY -eq 1 ]
then

	echo "🔧 CONFIGURE PROXY HTTP FOR APT"
	echo "Acquire::http::Proxy \"http://$PROXY_HTTP_HOST:$PROXY_HTTP_PORT\";" > /etc/apt/apt.conf.d/91proxyhttp

	echo "CONFIGURE PROXY HTTP FOR SYSTEM VIA PROFILE.D"
	echo "export http_proxy=http://$PROXY_HTTP_HOST:$PROXY_HTTP_PORT" > /etc/profile.d/proxy.sh
	echo "export https_proxy=http://$PROXY_HTTPS_HOST:$PROXY_HTTPS_PORT" >> /etc/profile.d/proxy.sh
	echo "export HTTP_PROXY=http://$PROXY_HTTP_HOST:$PROXY_HTTP_PORT" >> /etc/profile.d/proxy.sh
	echo "export HTTPS_PROXY=http://$PROXY_HTTPS_HOST:$PROXY_HTTPS_PORT" >> /etc/profile.d/proxy.sh
	echo "export no_proxy=localhost,127.0.0.1,127.0.1.1,.ch-nontron.fr,.hl-nontron.fr" >> /etc/profile.d/proxy.sh
	echo "export NO_PROXY=localhost,127.0.0.1,127.0.1.1,.ch-nontron.fr,.hl-nontron.fr" >> /etc/profile.d/proxy.sh

	echo "CONFIGURE PROXY HTTP FOR SYSTEM VIA ENVIRONMENT"
	echo "http_proxy=http://$PROXY_HTTP_HOST:$PROXY_HTTP_PORT" > /etc/environment
	echo "https_proxy=http://$PROXY_HTTPS_HOST:$PROXY_HTTPS_PORT" >> /etc/environment
	echo "HTTP_PROXY=http://$PROXY_HTTP_HOST:$PROXY_HTTP_PORT" >> /etc/environment
	echo "HTTPS_PROXY=http://$PROXY_HTTPS_HOST:$PROXY_HTTPS_PORT" >> /etc/environment
	echo "no_proxy=localhost,127.0.0.1,127.0.1.1,.ch-nontron.fr,.hl-nontron.fr" >> /etc/environment
	echo "NO_PROXY=localhost,127.0.0.1,127.0.1.1,.ch-nontron.fr,.hl-nontron.fr" >> /etc/environment

	# mkdir -p /etc/environment.d/
	# echo "http_proxy=http://$PROXY_HTTP_HOST" > /etc/environment.d/proxy.conf
	# echo "https_proxy=http://$PROXY_HTTPS_HOST" > /etc/environment.d/proxy.conf
	# echo "HTTP_PROXY=http://$PROXY_HTTP_HOST" >> /etc/environment.d/proxy.conf
	# echo "HTTPS_PROXY=http://$PROXY_HTTPS_HOST" >> /etc/environment.d/proxy.conf
	# echo "no_proxy=localhost,127.0.0.1,127.0.1.1,.ch-nontron.fr,.hl-nontron.fr" >> /etc/environment.d/proxy.conf
	# echo "NO_PROXY=localhost,127.0.0.1,127.0.1.1,.ch-nontron.fr,.hl-nontron.fr" >> /etc/environment.d/proxy.conf

	echo "CONFIGURE PROXY HTTP FOR WGET"
	sed -i "s%.*http_proxy.*%http_proxy = $PROXY_HTTP_HOST:$PROXY_HTTP_PORT%" /etc/wgetrc
	sed -i "s%.*https_proxy.*%http_proxy = $PROXY_HTTPS_HOST:$PROXY_HTTPS_PORT%" /etc/wgetrc

	echo "CHECK PROXY HTTP ON DEBIAN.ORG"
	curl -I http://debian.org
	echo "CHECK PROXY HTTPS ON DEBIAN.ORG"
	curl -I https://debian.org

	if [ $DOCKER -eq 1 ]
	then

		mkdir -p /etc/systemd/system/docker.service.d
		echo "CONFIGURE PROXY HTTP FOR DOCKER"
		echo "[Service]" > /etc/systemd/system/docker.service.d/http-proxy.conf
		echo "Environment='HTTP_PROXY'='http://$PROXY_HTTP_HOST:$PROXY_HTTP_PORT'" >> /etc/systemd/system/docker.service.d/http-proxy.conf
		echo "Environment='NO_PROXY'='localhost,127.0.0.1,127.0.1.1,.ch-nontron.fr,.hl-nontron.fr'" >> /etc/systemd/system/docker.service.d/http-proxy.conf

		echo "CONFIGURE PROXY HTTPS FOR DOCKER"
		echo "[Service]" > /etc/systemd/system/docker.service.d/https-proxy.conf
		echo "Environment='HTTPS_PROXY'='http://$PROXY_HTTPS_HOST:$PROXY_HTTPS_PORT'" >> /etc/systemd/system/docker.service.d/https-proxy.conf
		echo "Environment='NO_PROXY'='localhost,127.0.0.1,127.0.1.1,.ch-nontron.fr,.hl-nontron.fr'" >> /etc/systemd/system/docker.service.d/https-proxy.conf

	fi

else

	if [ -f /etc/apt/apt.conf.d/91proxyhttp ]
	then

		rm -f /etc/apt/apt.conf.d/91proxyhttp

	fi

	if [ -f /etc/profile.d/proxy.sh ]
	then

		rm -f /etc/profile.d/proxy.sh

	fi

	if [ -f /etc/environment ]
	then

		rm -f /etc/environment

	fi

	if [ -f /etc/environment.d/proxy.conf ]
	then

		rm -f /etc/environment.d/proxy.conf

	fi

	sed -i "s%.*http_proxy=.*%#http_proxy = http://proxy.yoyodyne.com:18023/%" /etc/wgetrc

fi


### PREREQUISITES ###

if [ $DEBIAN_TYPE = "LXC" ]
then

	if dpkg -s aptitude &>/dev/null
	then

		echo ""
		echo "PREREQUISITES OK ✅"

	else

		echo ""
		echo "🔧 INSTALL PREQUISITES"
		apt install acl aptitude apache2-utils apt-transport-https bash-completion bind9-dnsutils ca-certificates curl dirmngr ethtool extrepo git gnupg gpg inetutils-telnet iptables jq lshw lsb-release man-db manpages-fr net-tools netcat-traditional nicstat openssl pciutils sudo tcpdump traceroute tree util-linux wget -y

	fi

fi

if [ $DEBIAN_TYPE = "PHYSICAL" ]
then

	if dpkg -s aptitude &>/dev/null
	then

		echo ""
		echo "PREREQUISITES OK ✅"

	else

		echo ""
		echo "🔧 INSTALL PREQUISITES"
		apt install acl aptitude apache2-utils apt-transport-https bash-completion bind9-dnsutils ca-certificates curl dirmngr ethtool extrepo git gnupg gpg inetutils-telnet iptables jq lshw lsb-release man-db manpages-fr net-tools netcat-traditional nicstat openssl pciutils sudo tcpdump traceroute tree util-linux wget -y

	fi

	if [ $DISPLAY_LINK = "1" ]
	then

		if dpkg -s evdi-dkms &>/dev/null
		then

			echo ""
			echo "DISPLAY LINK OK ✅"

		else

			echo ""
			echo "🔧 INSTALL DISPLAY LINK"
			apt install evdi-dkms dkms linux-headers-$(uname -r) displaylink-driver -y

		fi
		
	fi

fi

if [ $DEBIAN_TYPE = "VM" ]
then

	if dpkg -s aptitude &>/dev/null
	then

		echo ""
		echo "PREREQUISITES OK ✅"

	else

		echo ""
		echo "🔧 INSTALL PREQUISITES"
		apt install acl aptitude apache2-utils apache2-utils apt-transport-https bash-completion bind9-dnsutils ca-certificates curl dirmngr ethtool extrepo git gnupg gpg inetutils-telnet iptables jq lshw lsb-release man-db manpages-fr net-tools netcat-traditional nicstat openssl pciutils sudo tcpdump traceroute tree util-linux wget -y

	fi

fi

if [ $DEBIAN_TYPE = "PROXMOX" ]
then

	if dpkg -s aptitude &>/dev/null
	then

		echo ""
		echo "PREREQUISITES OK ✅"

	else

		# contrack pour éviter des erreurs de type --> Couldn't write 'x' to 'net/netfilter/nf_conntrack_tcp_timeout_fin_wait', ignoring: No such file or directory
		# glances pour suivre avec précisions l'état des ressources de l'hyperviseur
		echo ""
		echo "🔧 INSTALL PREQUISITES"
		apt install acl aptitude apache2-utils apt-transport-https bash-completion bind9-dnsutils ca-certificates conntrack curl dirmngr ethtool extrepo git glances gnupg gpg inetutils-telnet iptables jq lshw lsb-release man-db manpages-fr net-tools netcat-traditional nicstat openssl pciutils rsync sudo tcpdump traceroute tree util-linux wget -y

	fi

fi

### APT ###

if [ $DEBIAN_RELEASE = "trixie" ]
then

	### TiME ZONE ###
	echo "🔧 CONFIGURE TIME ZONE FOR DEBIAN TRIXIE"
	timedatectl set-timezone $TIME_ZONE
	# unlink /etc/localtime
	# ln -s /usr/share/timezone/$TIME_ZONE /etc/localtime

	if [ -f /etc/apt/sources.list ]
	then

		rm -f /etc/apt/sources.list

	fi

	echo "🔧 CONFIGURE APT SOURCES FOR DEBIAN TRIXIE"
	echo '' > /etc/apt/sources.list.d/debian.sources
	echo 'Types: deb' >> /etc/apt/sources.list.d/debian.sources
	echo 'URIs: http://security.debian.org' >> /etc/apt/sources.list.d/debian.sources
	echo 'Suites: trixie-security' >> /etc/apt/sources.list.d/debian.sources
	echo 'Components: main contrib non-free-firmware non-free' >> /etc/apt/sources.list.d/debian.sources
	echo 'Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg' >> /etc/apt/sources.list.d/debian.sources
	echo '' >> /etc/apt/sources.list.d/debian.sources
	echo 'Types: deb' >> /etc/apt/sources.list.d/debian.sources
	echo 'URIs: http://deb.debian.org/debian' >> /etc/apt/sources.list.d/debian.sources
	echo 'Suites: trixie trixie-updates' >> /etc/apt/sources.list.d/debian.sources
	echo 'Components: main contrib non-free-firmware non-free' >> /etc/apt/sources.list.d/debian.sources
	echo 'Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg' >> /etc/apt/sources.list.d/debian.sources
	echo '' >> /etc/apt/sources.list.d/debian.sources
	echo 'Types: deb' >> /etc/apt/sources.list.d/debian.sources
	echo 'URIs: http://deb.debian.org/debian' >> /etc/apt/sources.list.d/debian.sources
	echo 'Suites: trixie-backports' >> /etc/apt/sources.list.d/debian.sources
	echo 'Components: main contrib non-free-firmware non-free' >> /etc/apt/sources.list.d/debian.sources
	echo 'Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg' >> /etc/apt/sources.list.d/debian.sources
	echo '' >> /etc/apt/sources.list.d/debian.sources

	install -d -m 0755 /usr/share/keyrings

	if [ $CROWDSEC_BOUNCER == "1" ]
	then

		if [ -f /etc/apt/sources.list.d/crowdsec.list ]
		then

			rm -f /etc/apt/sources.list.d/crowdsec.list

		fi

		echo "🔧 CONFIGURE APT CROWDSEC SOURCES FOR DEBIAN TRIXIE"
		curl -fsSL https://packagecloud.io/crowdsec/crowdsec/gpgkey | gpg --dearmor > /usr/share/keyrings/crowdsec-crowdsec-archive-keyring.gpg
		echo '' > /etc/apt/sources.list.d/crowdsec.sources
		echo 'Types: deb' >> /etc/apt/sources.list.d/crowdsec.sources
		echo 'URIs: http://packagecloud.io/crowdsec/crowdsec/any' >> /etc/apt/sources.list.d/crowdsec.sources
		echo 'Suites: any' >> /etc/apt/sources.list.d/crowdsec.sources
		echo 'Components: main' >> /etc/apt/sources.list.d/crowdsec.sources
		echo 'Signed-By: /usr/share/keyrings/crowdsec-crowdsec-archive-keyring.gpg' >> /etc/apt/sources.list.d/crowdsec.sources
		echo '' >> /etc/apt/sources.list.d/crowdsec.sources

	fi

	if [ $DEBIAN_TYPE == "PROXMOX" ]
	then

		if [ -f /etc/apt/sources.list.d/pve-enterprise.sources ]
		then

			rm -f /etc/apt/sources.list.d/pve-enterprise.sources

		fi

		echo "🔧 CONFIGURE APT PROXMOX SOURCES FOR DEBIAN TRIXIE"
		curl -fsSL https://enterprise.proxmox.com/debian/proxmox-release-trixie.gpg | gpg --dearmor > /usr/share/keyrings/proxmox-archive-keyring.gpg
		echo '' > /etc/apt/sources.list.d/proxmox.sources
		echo 'Types: deb' >> /etc/apt/sources.list.d/proxmox.sources
		echo 'URIs: http://download.proxmox.com/debian/pve' >> /etc/apt/sources.list.d/proxmox.sources
		echo 'Suites: trixie' >> /etc/apt/sources.list.d/proxmox.sources
		echo 'Components: pve-no-subscription' >> /etc/apt/sources.list.d/proxmox.sources
		echo 'Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpg' >> /etc/apt/sources.list.d/proxmox.sources
		echo '' >> /etc/apt/sources.list.d/proxmox.sources

	fi

	if [ "$DOCKER" = "1" ]
	then
		rm -f /etc/apt/sources.list.d/docker.list

		echo "🔧 CONFIGURE APT DOCKER SOURCES FOR DEBIAN TRIXIE"
		install -d -m 0755 /usr/share/keyrings
		curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor --yes --output /usr/share/keyrings/docker-archive-keyring.gpg

		cat > /etc/apt/sources.list.d/docker.sources <<'EOF'
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: trixie
Components: stable
Signed-By: /usr/share/keyrings/docker-archive-keyring.gpg
EOF
	fi

	if [ $DRIVERS_NVIDIA == "1" ]
	then

		echo "🔧 CONFIGURE APT PROPRIETARY NVIDIA DRIVERS FOR DEBIAN TRIXIE"
		curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/debian13/x86_64/8793F200.pub | gpg --dearmor > /usr/share/keyrings/nvidia-archive-keyring.gpg
		echo '' > /etc/apt/sources.list.d/nvidia.sources
		echo 'Types: deb' >> /etc/apt/sources.list.d/nvidia.sources
		echo 'Suites: /' >> /etc/apt/sources.list.d/nvidia.sources
		echo 'Architectures: amd64' >> /etc/apt/sources.list.d/nvidia.sources
		echo 'Uris: https://developer.download.nvidia.com/compute/cuda/repos/debian13/x86_64/' >> /etc/apt/sources.list.d/nvidia.sources
		echo 'Signed-By: /usr/share/keyrings/nvidia-archive-keyring.gpg' >> /etc/apt/sources.list.d/nvidia.sources
		echo '' >> /etc/apt/sources.list.d/nvidia.sources

		echo "🔧 CONFIGURE APT PROPRIETARY NVIDIA CONTAINER TOOLKIT SOURCES FOR DEBIAN TRIXIE"
		curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor > /usr/share/keyrings/nvidia-container-toolkit-archive-keyring.gpg
		echo '' > /etc/apt/sources.list.d/nvidia-container-toolkit.sources
		echo 'Types: deb' >> /etc/apt/sources.list.d/nvidia-container-toolkit.sources
		echo 'Suites: /' >> /etc/apt/sources.list.d/nvidia-container-toolkit.sources
		echo 'Architectures: amd64' >> /etc/apt/sources.list.d/nvidia-container-toolkit.sources
		echo 'URIs: https://nvidia.github.io/libnvidia-container/stable/deb/amd64/' >> /etc/apt/sources.list.d/nvidia-container-toolkit.sources
		echo 'Signed-By: /usr/share/keyrings/nvidia-container-toolkit-archive-keyring.gpg' >> /etc/apt/sources.list.d/nvidia-container-toolkit.sources
		echo '' >> /etc/apt/sources.list.d/nvidia-container-toolkit.sources

	fi

	if [ $LEMONLDAP == "1" ]
	then

		if [ -f /etc/apt/sources.list.d/lemonldap.list ]
		then

			rm -f /etc/apt/sources.list.d/lemonldap.list

		fi

		echo "🔧 CONFIGURE APT LEMONLDAP SOURCES FOR DEBIAN TRIXIE"
		curl -fsSL https://lemonldap-ng.org/lemonldap-debian-packages-pub.gpg | gpg --dearmor > /usr/share/keyrings/lemonldap-archive-keyring.gpg
		echo '' > /etc/apt/sources.list.d/lemonldap.sources
		echo 'Types: deb' >> /etc/apt/sources.list.d/lemonldap.sources
		echo 'URIs: https://lemonldap-ng.org/deb' >> /etc/apt/sources.list.d/lemonldap.sources
		echo 'Suites: 2.0' >> /etc/apt/sources.list.d/lemonldap.sources
		echo 'Components: main' >> /etc/apt/sources.list.d/lemonldap.sources
		echo 'Signed-By: /usr/share/keyrings/lemonldap-archive-keyring.gpg' >> /etc/apt/sources.list.d/lemonldap.sources
		echo '' >> /etc/apt/sources.list.d/lemonldap.sources

	fi

	if [ $MONGODB == "1" ]
	then

		if [ $MONGODB_VERSION == "7" ]
		then

			if [ -f /etc/apt/sources.list.d/mongodb.list ]
			then

				rm -f /etc/apt/sources.list.d/mongodb.list

			fi

			echo "🔧 CONFIGURE APT MONGODB 7 SOURCES FOR DEBIAN TRIXIE"
			curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | gpg --dearmor > /usr/share/keyrings/mongodb-archive-keyring.gpg
			echo '' > /etc/apt/sources.list.d/mongodb.sources
			echo 'Types: deb' >> /etc/apt/sources.list.d/mongodb.sources
			echo 'URIs: http://repo.mongodb.org/apt/debian' >> /etc/apt/sources.list.d/mongodb.sources
			echo 'Suites: bookworm/mongodb-org/7.0' >> /etc/apt/sources.list.d/mongodb.sources
			echo 'Components: main' >> /etc/apt/sources.list.d/mongodb.sources
			echo 'Signed-By: /usr/share/keyrings/mongodb-archive-keyring.gpg' >> /etc/apt/sources.list.d/mongodb.sources
			echo '' >> /etc/apt/sources.list.d/mongodb.sources

		fi

		if [ $MONGODB_VERSION == "8" ]
		then

			if [ -f /etc/apt/sources.list.d/mongodb.list ]
			then

				rm -f /etc/apt/sources.list.d/mongodb.list

			fi

			echo "🔧 CONFIGURE APT MONGODB 8 SOURCES FOR DEBIAN TRIXIE"
			curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | gpg --dearmor > /usr/share/keyrings/mongodb-archive-keyring.gpg
			echo '' > /etc/apt/sources.list.d/mongodb.sources
			echo 'Types: deb' >> /etc/apt/sources.list.d/mongodb.sources
			echo 'URIs: http://repo.mongodb.org/apt/debian' >> /etc/apt/sources.list.d/mongodb.sources
			echo 'Suites: bookworm/mongodb-org/8.0' >> /etc/apt/sources.list.d/mongodb.sources
			echo 'Components: main' >> /etc/apt/sources.list.d/mongodb.sources
			echo 'Signed-By: /usr/share/keyrings/mongodb-archive-keyring.gpg' >> /etc/apt/sources.list.d/mongodb.sources
			echo '' >> /etc/apt/sources.list.d/mongodb.sources

		fi

	fi

	if [ $DEVOPS == "1" ]
	then

		if [ -f /etc/apt/sources.list.d/nodesource.list ]
		then

			rm -f /etc/apt/sources.list.d/nodesource.list

		fi

		echo "🔧 CONFIGURE APT NODE.JS SOURCES FOR DEBIAN TRIXIE"
		curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor > /usr/share/keyrings/nodesource-archive-keyring.gpg
		echo '' > /etc/apt/sources.list.d/nodesource.sources
		echo 'Types: deb' >> /etc/apt/sources.list.d/nodesource.sources
		echo 'URIs: https://deb.nodesource.com/node_24.x' >> /etc/apt/sources.list.d/nodesource.sources
		echo 'Suites: nodistro' >> /etc/apt/sources.list.d/nodesource.sources
		echo 'Components: main' >> /etc/apt/sources.list.d/nodesource.sources
		echo 'Architectures: amd64' >> /etc/apt/sources.list.d/nodesource.sources
		echo 'Signed-By: /usr/share/keyrings/nodesource-archive-keyring.gpg' >> /etc/apt/sources.list.d/nodesource.sources
		echo '' >> /etc/apt/sources.list.d/nodesource.sources

	fi

	if [ $VSCODE == "1" ]
	then

		if [ -f /etc/apt/sources.list.d/vscode.list ]
		then

			rm -f /etc/apt/sources.list.d/vscode.list

		fi

		echo "🔧 CONFIGURE APT VISUAL STUDIO CODE SOURCES FOR DEBIAN TRIXIE"
		curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /usr/share/keyrings/vscode-archive-keyring.gpg
		echo '' > /etc/apt/sources.list.d/vscode.sources
		echo 'Types: deb' >> /etc/apt/sources.list.d/vscode.sources
		echo 'URIs: https://packages.microsoft.com/repos/code' >> /etc/apt/sources.list.d/vscode.sources
		echo 'Suites: stable' >> /etc/apt/sources.list.d/vscode.sources
		echo 'Components: main' >> /etc/apt/sources.list.d/vscode.sources
		echo 'Architectures: amd64' >> /etc/apt/sources.list.d/vscode.sources
		echo 'Signed-By: /usr/share/keyrings/vscode-archive-keyring.gpg' >> /etc/apt/sources.list.d/vscode.sources
		echo '' >> /etc/apt/sources.list.d/vscode.sources

	fi

	if [ $WEBMIN == "1" ]
	then

		echo "🔧 CONFIGURE APT WEBMIN SOURCES FOR DEBIAN TRIXIE"
		curl -fsSL https://download.webmin.com/jcameron-key.asc | gpg --dearmor > /usr/share/keyrings/webmin-archive-keyring.gpg
		echo '' > /etc/apt/sources.list.d/webmin.sources
		echo 'Types: deb' >> /etc/apt/sources.list.d/webmin.sources
		echo 'URIs: http://download.webmin.com/download/repository' >> /etc/apt/sources.list.d/webmin.sources
		echo 'Suites: sarge' >> /etc/apt/sources.list.d/webmin.sources
		echo 'Components: contrib' >> /etc/apt/sources.list.d/webmin.sources
		echo 'Signed-By: /usr/share/keyrings/webmin-archive-keyring.gpg' >> /etc/apt/sources.list.d/webmin.sources
		#echo 'Signed-By: /usr/share/keyrings/debian-webmin-developers.gpg' >> /etc/apt/sources.list.d/webmin.sources
		echo '' >> /etc/apt/sources.list.d/webmin.sources

	fi

	if [ $WAZUH_SERVER == "1" ]
	then

		if [ -f /etc/apt/sources.list.d/wazuh.list ]
		then

			rm -f /etc/apt/sources.list.d/wazuh.list

		fi

		if [ $WAZUH_SERVER_UPGRADE == "1" ]
		then

			echo "🔧 CONFIGURE APT WAZUH SOURCES FOR DEBIAN TRIXIE"
			echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/wazuh-archive-keyring.gpg] https://packages.wazuh.com/4.x/apt/ stable main' > /etc/apt/sources.list.d/wazuh.list
			curl -fsSL https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --dearmor > /usr/share/keyrings/wazuh-archive-keyring.gpg

			echo "CONFIGURE APT WAZUH SOURCES FOR DEBIAN TRIXIE"
			curl -fsSL https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --dearmor > /usr/share/keyrings/wazuh-archive-keyring.gpg
			echo '' > /etc/apt/sources.list.d/wazuh.sources
			echo 'Types: deb' >> /etc/apt/sources.list.d/wazuh.sources
			echo 'URIs: https://packages.wazuh.com/4.x/apt' >> /etc/apt/sources.list.d/wazuh.sources
			echo 'Suites: stable' >> /etc/apt/sources.list.d/wazuh.sources
			echo 'Components: main' >> /etc/apt/sources.list.d/wazuh.sources
			echo 'Signed-By: /usr/share/keyrings/wazuh-archive-keyring.gpg' >> /etc/apt/sources.list.d/wazuh.sources
			echo '' >> /etc/apt/sources.list.d/wazuh.sources

		else

			if [ -f /etc/apt/sources.list.d/wazuh.list ]
			then

				rm -f /etc/apt/sources.list.d/wazuh.list

			fi

			if [ -f /etc/apt/sources.list.d/wazuh.sources ]
			then

				rm -f /etc/apt/sources.list.d/wazuh.sources

			fi

		fi

	else

		if [ -f /etc/apt/sources.list.d/wazuh.list ]
		then

			rm -f /etc/apt/sources.list.d/wazuh.list

		fi

		if [ -f /etc/apt/sources.list.d/wazuh.sources ]
		then

			rm -f /etc/apt/sources.list.d/wazuh.sources

		fi

	fi

	# Force IPv4.
	echo 'Acquire::ForceIPv4 "true";' > /etc/apt/apt.conf.d/99force-ipv4

	mkdir -p /etc/crypto-policies/back-ends
	echo '[hash_algorithms]' > /etc/crypto-policies/back-ends/sequoia.config
	echo 'sha1 = "always"' >> /etc/crypto-policies/back-ends/sequoia.config
	echo '' >> /etc/crypto-policies/back-ends/sequoia.config
	echo '[asymmetric_algorithms]' >> /etc/crypto-policies/back-ends/sequoia.config
	echo 'dsa1024 = "always"' >> /etc/crypto-policies/back-ends/sequoia.config

	echo "🔧 CLEAN AND PURGE AND REMOVE"
	apt autoclean -y
	apt autopurge -y
	apt autoremove -y

	echo "🔧 UPDATE & DIST-UPGRADE"
	apt -y update && apt -q -y --allow-downgrades --allow-change-held-packages -f -m --show-progress dist-upgrade

	echo "🔧 CLEAN AND PURGE AND REMOVE"
	apt autoclean -y
	apt autopurge -y
	apt autoremove -y
	echo ""

	if dpkg -s flatpak &>/dev/null
	then

		echo "🔧 UPDATE FLATPAK"
		flatpak update -y

	fi

fi

if [ $DEBIAN_RELEASE = "bookworm" ]
then

	echo "🔧 CONFIGURE APT SOURCES FOR DEBIAN BOOKWORM"
	echo '' > /etc/apt/sources.list
	echo 'deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware' >> /etc/apt/sources.list
	echo '' >> /etc/apt/sources.list
	echo 'deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware' >> /etc/apt/sources.list
	echo '' >> /etc/apt/sources.list
	echo 'deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware' >> /etc/apt/sources.list
	echo '' >> /etc/apt/sources.list
	echo 'deb http://deb.debian.org/debian bookworm-backports main contrib non-free non-free-firmware' >> /etc/apt/sources.list
	echo '' >> /etc/apt/sources.list

	if [ $CROWDSEC_BOUNCER == "1" ]
	then

		echo "🔧 CONFIGURE APT CROWDSEC SOURCES FOR DEBIAN BOOKWORM"
		echo 'deb [signed-by=/usr/share/keyrings/crowdsec-crowdsec-archive-keyring.gpg] http://packagecloud.io/crowdsec/crowdsec/debian/ bookworm main' > /etc/apt/sources.list.d/crowdsec.list
		curl -fsSL https://packagecloud.io/crowdsec/crowdsec/gpgkey | gpg --dearmor > /usr/share/keyrings/crowdsec-crowdsec-archive-keyring.gpg

	fi

	if [ $DOCKER == "1" ]
	then

		echo "🔧 CONFIGURE APT DOCKER SOURCES FOR DEBIAN BOOKWORM"
		echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] http://download.docker.com/linux/debian bookworm stable' > /etc/apt/sources.list.d/docker.list
		curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor > /usr/share/keyrings/docker-archive-keyring.gpg

	fi

	if [ $LEMONLDAP == "1" ]
	then

		echo "🔧 CONFIGURE APT LEMONLDAP SOURCES FOR DEBIAN BOOKWMORM"
		echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/lemonldap-archive-keyring.gpg] https://lemonldap-ng.org/deb 2.0 main' > /etc/apt/sources.list.d/lemonldap.list
		curl -fsSL https://lemonldap-ng.org/lemonldap-debian-packages-pub.gpg | gpg --dearmor > /usr/share/keyrings/lemonldap-archive-keyring.gpg

	fi

	if [ $MONGODB == "1" ]
	then

		if [ $MONGODB_VERSION == "4.4" ]
		then
			echo "🔧 CONFIGURE APT MONGODB 4.4 SOURCES FOR DEBIAN BOOKWORM"
			echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/mongodb-archive-keyring.gpg] http://repo.mongodb.org/apt/debian bookworm/mongodb-org/4.4 main' > /etc/apt/sources.list.d/mongodb.list
			curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc | gpg --dearmor > /usr/share/keyrings/mongodb-archive-keyring.gpg
		fi

		if [ $MONGODB_VERSION == "5" ]
		then
			echo "🔧 CONFIGURE APT MONGODB 5 SOURCES FOR DEBIAN BOOKWORM"
			echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/mongodb-archive-keyring.gpg] http://repo.mongodb.org/apt/debian bookworm/mongodb-org/5.0 main' > /etc/apt/sources.list.d/mongodb.list
			curl -fsSL https://www.mongodb.org/static/pgp/server-5.0.asc | gpg --dearmor > /usr/share/keyrings/mongodb-archive-keyring.gpg
		fi

		if [ $MONGODB_VERSION == "6" ]
		then
			echo "🔧 CONFIGURE APT MONGODB 6 SOURCES FOR DEBIAN BOOKWORM"
			echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/mongodb-archive-keyring.gpg] http://repo.mongodb.org/apt/debian bookworm/mongodb-org/6.0 main' > /etc/apt/sources.list.d/mongodb.list
			curl -fsSL https://www.mongodb.org/static/pgp/server-6.0.asc | gpg --dearmor > /usr/share/keyrings/mongodb-archive-keyring.gpg
		fi

		if [ $MONGODB_VERSION == "7" ]
		then
			echo "🔧 CONFIGURE APT MONGODB 7 SOURCES FOR DEBIAN BOOKWORM"
			echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/mongodb-archive-keyring.gpg] http://repo.mongodb.org/apt/debian bookworm/mongodb-org/7.0 main' > /etc/apt/sources.list.d/mongodb.list
			curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | gpg --dearmor > /usr/share/keyrings/mongodb-archive-keyring.gpg
		fi

		if [ $MONGODB_VERSION == "8" ]
		then
			echo "🔧 CONFIGURE APT MONGODB 8 SOURCES FOR DEBIAN BOOKWORM"
			echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/mongodb-archive-keyring.gpg] http://repo.mongodb.org/apt/debian bookworm/mongodb-org/8.0 main' > /etc/apt/sources.list.d/mongodb.list
			curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | gpg --dearmor > /usr/share/keyrings/mongodb-archive-keyring.gpg
		fi

	fi

	if [ $WAZUH_SERVER == "1" ]
	then

		if [ $WAZUH_SERVER_UPGRADE == "1" ]
		then

			echo "🔧 CONFIGURE APT WAZUH SOURCES FOR DEBIAN BOOKWMORM"
			echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/wazuh-archive-keyring.gpg] https://packages.wazuh.com/4.x/apt/ stable main' > /etc/apt/sources.list.d/wazuh.list
			curl -fsSL https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --dearmor > /usr/share/keyrings/wazuh-archive-keyring.gpg

		else

			if [ -f /etc/apt/sources.list.d/wazuh.list ]
			then

				rm -f /etc/apt/sources.list.d/wazuh.list

			fi

		fi

	else

		if [ -f /etc/apt/sources.list.d/wazuh.list ]
		then

			rm -f /etc/apt/sources.list.d/wazuh.list

		fi

	fi

	echo ""
	echo "🔧 CLEAN AND PURGE AND REMOVE"
	apt autoclean -y
	apt autopurge -y
	apt autoremove -y

	echo ""
	echo "🔧 UPDATE & DIST-UPGRADE"
	apt -y update && apt -q -y --allow-downgrades --allow-change-held-packages -f -m --show-progress dist-upgrade

	echo ""
	echo "🔧 CLEAN AND PURGE AND REMOVE"
	apt autoclean -y
	apt autopurge -y
	apt autoremove -y

	echo "🔧 TMP MOUNT"
	if [ -e /usr/share/systemd/tmp.mount ]
	then
		mv -f /usr/share/systemd/tmp.mount /etc/systemd/system
		systemctl enable tmp.mount
	fi

fi

if [ $DEBIAN_RELEASE = "bullseye" ]
then

	echo "🔧 CONFIGURE APT SOURCES FOR DEBIAN BULLSEYE"
	echo '' > /etc/apt/sources.list
	echo 'deb http://deb.debian.org/debian bullseye main contrib non-free' >> /etc/apt/sources.list
	echo '' >> /etc/apt/sources.list
	echo 'deb http://security.debian.org/debian-security bullseye-security main contrib non-free' >> /etc/apt/sources.list
	echo '' >> /etc/apt/sources.list
	echo 'deb http://deb.debian.org/debian bullseye-updates main contrib non-free' >> /etc/apt/sources.list
	echo '' >> /etc/apt/sources.list
	# echo 'deb http://deb.debian.org/debian bullseye-backports main contrib non-free' >> /etc/apt/sources.list
	# echo '' >> /etc/apt/sources.list

	if [ $CROWDSEC_BOUNCER == "1" ]
	then

		echo "🔧 CONFIGURE APT CROWDSEC SOURCES FOR DEBIAN BULLSEYE"
		echo 'deb [signed-by=/usr/share/keyrings/crowdsec-crowdsec-archive-keyring.gpg] http://packagecloud.io/crowdsec/crowdsec/debian/ bullseye main' > /etc/apt/sources.list.d/crowdsec.list
		curl -fsSL https://packagecloud.io/crowdsec/crowdsec/gpgkey | gpg --dearmor > /usr/share/keyrings/crowdsec-crowdsec-archive-keyring.gpg

	fi

	if [ $DOCKER == "1" ]
	then

		echo "🔧 CONFIGURE APT DOCKER SOURCES FOR DEBIAN BULLSEYE"
		echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] http://download.docker.com/linux/debian bullseye stable' > /etc/apt/sources.list.d/docker.list
		curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor > /usr/share/keyrings/docker-archive-keyring.gpg

	fi

	if [ $LEMONLDAP == "1" ]
	then

		echo "🔧 CONFIGURE APT LEMONLDAP SOURCES FOR DEBIAN BULLSEYE"
		echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/lemonldap-archive-keyring.gpg] https://lemonldap-ng.org/deb 2.0 main' > /etc/apt/sources.list.d/lemonldap.list
		curl -fsSL https://lemonldap-ng.org/lemonldap-debian-packages-pub.gpg | gpg --dearmor > /usr/share/keyrings/lemonldap-archive-keyring.gpg

	fi

	if [ $MONGODB == "1" ]
	then

		if [ $MONGODB_VERSION == "4.4" ]
		then
			echo "🔧 CONFIGURE APT MONGODB 4.4 SOURCES FOR DEBIAN BULLSEYE"
			echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/mongodb-archive-keyring.gpg] http://repo.mongodb.org/apt/debian bullseye/mongodb-org/4.4 main' > /etc/apt/sources.list.d/mongodb.list
			curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc | gpg --dearmor > /usr/share/keyrings/mongodb-archive-keyring.gpg
		fi

		if [ $MONGODB_VERSION == "5" ]
		then
			echo "🔧 CONFIGURE APT MONGODB 5 SOURCES FOR DEBIAN BULLSEYE"
			echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/mongodb-archive-keyring.gpg] http://repo.mongodb.org/apt/debian bullseye/mongodb-org/5.0 main' > /etc/apt/sources.list.d/mongodb.list
			curl -fsSL https://www.mongodb.org/static/pgp/server-5.0.asc | gpg --dearmor > /usr/share/keyrings/mongodb-archive-keyring.gpg
		fi

		if [ $MONGODB_VERSION == "6" ]
		then
			echo "🔧 CONFIGURE APT MONGODB 6 SOURCES FOR DEBIAN BULLSEYE"
			echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/mongodb-archive-keyring.gpg] http://repo.mongodb.org/apt/debian bullseye/mongodb-org/6.0 main' > /etc/apt/sources.list.d/mongodb.list
			curl -fsSL https://www.mongodb.org/static/pgp/server-6.0.asc | gpg --dearmor > /usr/share/keyrings/mongodb-archive-keyring.gpg
		fi

		if [ $MONGODB_VERSION == "7" ]
		then
			echo "🔧 CONFIGURE APT MONGODB 7 SOURCES FOR DEBIAN BULLSEYE"
			echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/mongodb-archive-keyring.gpg] http://repo.mongodb.org/apt/debian bullseye/mongodb-org/7.0 main' > /etc/apt/sources.list.d/mongodb.list
			curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | gpg --dearmor > /usr/share/keyrings/mongodb-archive-keyring.gpg
		fi

		if [ $MONGODB_VERSION == "8" ]
		then
			echo "🔧 CONFIGURE APT MONGODB 8 SOURCES FOR DEBIAN BULLSEYE"
			echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/mongodb-archive-keyring.gpg] http://repo.mongodb.org/apt/debian bullseye/mongodb-org/8.0 main' > /etc/apt/sources.list.d/mongodb.list
			curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | gpg --dearmor > /usr/share/keyrings/mongodb-archive-keyring.gpg
		fi

	fi

	echo ""
	echo "🔧 CLEAN AND PURGE AND REMOVE"
	apt autoclean -y
	apt autopurge -y
	apt autoremove -y

	echo ""
	echo "🔧 UPDATE & DIST-UPGRADE"
	apt -y update && apt -q -y --allow-downgrades --allow-change-held-packages -f -m --show-progress dist-upgrade

	echo ""
	echo "🔧 CLEAN AND PURGE AND REMOVE"
	apt autoclean -y
	apt autopurge -y
	apt autoremove -y

	echo "🔧 TMP MOUNT"
	if [ -e /usr/share/systemd/tmp.mount ]
	then
		mv -f /usr/share/systemd/tmp.mount /etc/systemd/system
		systemctl enable tmp.mount
	fi

fi


### DRIVERS ###

if [ $DRIVERS_NVIDIA -eq 1 ]
then

	# https://wiki.debian.org/NvidiaGraphicsDrivers
	# https://github.com/NVIDIA/cuda-repo-management
	# https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#debian-installation
	# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html
	# https://nvidia.github.io/libnvidia-container/stable/deb/

	if [ $DEBIAN_TYPE == "PROXMOX" ]
	then

		if dpkg -s pve-headers &>/dev/null
		then

			echo ""
			echo "PREQUISITES FOR NVIDIA DRIVERS FOR PROXMOX OK"

		else

			echo ""
			echo "INSTALL PREQUISITES FOR NVIDIA DRIVERS FOR PROXMOX"
			apt install dkms pve-headers pve-headers-$(uname -r) proxmox-default-headers build-essential make mdevctl -y
			echo ""

		fi

	else

		if dpkg -s linux-headers-amd64 &>/dev/null
		then

			echo ""
			echo "PREQUISITES FOR NVIDIA DRIVERS OK"

		else

			echo ""
			echo "INSTALL PREQUISITES FOR NVIDIA DRIVERS"
			apt install dkms linux-headers-amd64 build-essential make mdevctl -y
			echo ""

		fi

	fi

	if [ $SECURE_BOOT == "1" ]
	then

		if test -f /var/lib/dkms/mok.key
		then

			echo "SECURE BOOT IS ALREADY UP TO DATE FOR NVIDIA DRIVERS"		

		else

			echo "CONFIGURE SECURE BOOT FOR NVIDIA DRIVERS"

			if [ $DEBIAN_TYPE == "PROXMOX" ]
			then

				apt install shim-signed grub-efi-amd64-signed mokutil
				dkms generate_mok
				mokutil --import /var/lib/dkms/mok.pub # prompts for one-time password
				mokutil --list-new # recheck your key will be prompted on next boot
				echo "RESTART COMPUTER NOW..."
				exit

			else

				apt install shim-signed grub-efi-amd64-signed mokutil
				dkms generate_mok
				mokutil --import /var/lib/dkms/mok.pub # prompts for one-time password
				mokutil --list-new # recheck your key will be prompted on next boot
				echo "RESTART COMPUTER NOW..."
				exit

			fi

		fi

	fi

	if [ $DEBIAN_TYPE == "PROXMOX" ]
	then

		if dpkg -s pve-nvidia-vgpu-helper &>/dev/null
		then

			if [ $SECURE_BOOT == "1" ]
			then

				if dpkg -s nvidia-driver &>/dev/null
				then

					echo "NVIDIA DRIVERS FOR PROXMOX WITH SECURE BOOT OK"

				else

					echo "INSTALL NVIDIA DRIVERS FOR PROXMOX WITH SECURE BOOT"
					apt install nvidia-driver cuda nvidia-settings nvtop nvidia-container-toolkit -y
					# chmod +x /root/$DRIVERS_NVIDIA_SETUP
					# /root/$DRIVERS_NVIDIA_SETUP --accept-license --dkms --skip-module-load --sanity
					# dkms build -m nvidia -v $DRIVERS_NVIDIA_VERSION --force
					# dkms install -m nvidia -v $DRIVERS_NVIDIA_VERSION --force

					dkms status
					lspci -d 10de: -nnk
					nvidia-smi
					lsmod | grep nv
					ls -al /dev/nvidia*

					systemctl enable --now pve-nvidia-sriov@ALL.service

					echo "RESTART COMPUTER NOW..."
					exit

				fi

			else

				if dpkg -s nvidia-driver &>/dev/null
				then

					echo "NVIDIA DRIVERS FOR PROXMOX OK"

				else

					echo "INSTALL NVIDIA DRIVERS FOR PROXMOX"
					apt install nvidia-driver cuda nvidia-settings nvtop nvidia-container-toolkit -y
					# chmod +x /root/$DRIVERS_NVIDIA_SETUP
					# /root/$DRIVERS_NVIDIA_SETUP --accept-license --dkms --sanity
					# /root/$DRIVERS_NVIDIA_SETUP --accept-license --dkms --sanity

					dkms status
					lspci -d 10de: -nnk
					nvidia-smi
					lsmod | grep nv
					ls -al /dev/nvidia*

					systemctl enable --now pve-nvidia-sriov@ALL.service

					echo "RESTART COMPUTER NOW..."
					exit
					
				fi

			fi

		else

			echo "PREINSTALL NVIDIA DRIVERS FOR PROXMOX"
			apt install pve-nvidia-vgpu-helper -y
			pve-nvidia-vgpu-helper setup
			echo "RESTART COMPUTER NOW..."
			exit

		fi

	else

		if dpkg -l nvidia-driver &>/dev/null
		then

			echo "NVIDIA DRIVERS OK"

		else

			echo "INSTALL NVIDIA DRIVERS"
			apt install nvidia-driver cuda nvidia-settings nvtop -y
			dkms status
			lspci -d 10de: -nnk
			nvidia-smi
			lsmod | grep nv

			systemctl enable --now pve-nvidia-sriov@ALL.service
			
		fi

	fi

fi


### FSTAB ###

if [ $FSTAB -eq 1 ]
then

	echo ""
	echo "🔧 CONFIGURATION FSTAB"
	if [ "$FSTAB_CONFIG1" != "NONE" ]
	then

		echo "${FSTAB_CONFIG1}" > /etc/fstab

	fi

	if [ "$FSTAB_CONFIG2" != "NONE" ]
	then

		echo "${FSTAB_CONFIG2}" >> /etc/fstab

	fi

	if [ "$FSTAB_CONFIG3" != "NONE" ]
	then

		echo "${FSTAB_CONFIG3}" >> /etc/fstab

	fi

	if [ "$FSTAB_CONFIG4" != "NONE" ]
	then

		echo "${FSTAB_CONFIG4}" >> /etc/fstab

	fi

	if [ "$FSTAB_CONFIG5" != "NONE" ]
	then

		echo "${FSTAB_CONFIG5}" >> /etc/fstab

	fi

fi


### FILE2RAM ###

if [ $FILES2RAM -eq 1 ]
then

	echo ""
	echo "🔧 CONFIGURATION FILES2RAM"

	if [ ! -f /etc/tmpfiles.d/var2log.conf ]
	then

		rm -r -d -f --interactive=never /var/log/*

	fi

	# DIRECTORY
	# echo "D /var/log  0755 root root" > /etc/tmpfiles.d/var2log.conf
	echo "D /var/log/apt  0755 root root" > /etc/tmpfiles.d/var2log.conf
	echo "D /var/log/chrony  0755 root root" >> /etc/tmpfiles.d/var2log.conf
	echo "D /var/log/exim4  0755 root root" >> /etc/tmpfiles.d/var2log.conf
	echo "D /var/log/frr  0755 root root" >> /etc/tmpfiles.d/var2log.conf
	echo "D /var/log/ifupdown2  0755 root root" >> /etc/tmpfiles.d/var2log.conf
	echo "D /var/log/installer  0755 root root" >> /etc/tmpfiles.d/var2log.conf
	echo "D /var/log/installer/cdebconf  0755 root root" >> /etc/tmpfiles.d/var2log.conf
	echo "D /var/log/journal  0755 root root" >> /etc/tmpfiles.d/var2log.conf
	# echo "D /var/log/private  0755 root root" >> /etc/tmpfiles.d/var2log.conf
	echo "D /var/log/runit  0755 root root" >> /etc/tmpfiles.d/var2log.conf
	echo "D /var/log/runit/ssh  0755 root root" >> /etc/tmpfiles.d/var2log.conf

	# FILES
	echo "F /var/log/FILES2RAM_OK  0755 root root" >> /etc/tmpfiles.d/var2log.conf
	echo "F /var/log/alternatives.log  0755 root root" >> /etc/tmpfiles.d/var2log.conf
	echo "F /var/log/boot.log  0755 root root" >> /etc/tmpfiles.d/var2log.conf
	echo "F /var/log/daemon.log  0755 root root" >> /etc/tmpfiles.d/var2log.conf
	echo "F /var/log/dpkg.log  0755 root root" >> /etc/tmpfiles.d/var2log.conf
	# echo "F /var/log/exim4/mainlog  0755 Debian-exim adm" >> /etc/tmpfiles.d/var2log.conf
	# echo "F /var/log/exim4/paniclog  0755 Debian-exim adm" >> /etc/tmpfiles.d/var2log.conf
	echo "F /var/log/popularity-contest  0755 root root" >> /etc/tmpfiles.d/var2log.conf
	echo "F /var/log/popularity-contest.gpg  0755 root root" >> /etc/tmpfiles.d/var2log.conf

	if [ $DEBIAN_TYPE == "PROXMOX" ]
	then

		echo "D /var/log/ceph  0755 root root" >> /etc/tmpfiles.d/var2log.conf
		echo "D /var/log/corosync  0755 root root" >> /etc/tmpfiles.d/var2log.conf
		echo "D /var/log/lxc  0755 root root" >> /etc/tmpfiles.d/var2log.conf
		echo "D /var/log/pve  0755 root root" >> /etc/tmpfiles.d/var2log.conf
		echo "D /var/log/pve/tasks  0755 root root" >> /etc/tmpfiles.d/var2log.conf
		echo "D /var/log/pveproxy  0755 www-data www-data" >> /etc/tmpfiles.d/var2log.conf
		echo "F /var/log/pveam.log 0755 root root" >> /etc/tmpfiles.d/var2log.conf
		echo "F /var/log/pve-firewall.log 0755 root root" >> /etc/tmpfiles.d/var2log.conf

	fi

	if [ $DESKTOP -eq 1 ]
	then

		if [ $DESKTOP_GUI == "GNOME" ]
		then

			echo "D /var/log/cups  0755 root root" >> /etc/tmpfiles.d/var2log.conf
			echo "D /var/log/gdm3  0755 root Debian-gdm" >> /etc/tmpfiles.d/var2log.conf
			echo "D /var/log/samba  0755 root adm" >> /etc/tmpfiles.d/var2log.conf
			echo "D /var/log/speech-dispatcher  0755 speech-dispatcher root" >> /etc/tmpfiles.d/var2log.conf
			echo "F /var/log/fontconfig.log  0755 root root" >> /etc/tmpfiles.d/var2log.conf
			echo "F /var/log/Xorg.0.log 0755 root root" >> /etc/tmpfiles.d/var2log.conf

		fi

	fi

	if [ $DRIVERS_NVIDIA -eq 1 ]
	then

		echo "D /var/log/nvidia-mps  0755 root root" >> /etc/tmpfiles.d/var2log.conf
		echo "D /var/log/nvtopps  0755 root root" >> /etc/tmpfiles.d/var2log.conf

	fi

	# Apply now
	systemd-tmpfiles --create

	# systemctl enable systemd-tmpfiles-setup.service
	systemctl start systemd-tmpfiles-setup.service

	if  [ $DEBIAN_TYPE == "PHYSICAL" ]
	then

		echo "🔧 CONFIGURATION FSTAB"
		if [ "$FSTAB_CONFIG1" = "NONE" ]
		then

			# echo "tmpfs			/var/log			tmpfs			rw,nosuid,nodev,noexec,noatime,nodiratime,mode=1755				0 0" > /etc/fstab
			echo "❌ FSTAB DEVRAIT ETRE CONFIGURER PAR ROOT-INSTALL.SH SUR UNE DEBIAN PHYSICAL"

		else

			# echo "tmpfs			/var/log			tmpfs			rw,nosuid,nodev,noexec,noatime,nodiratime,mode=1755				0 0" >> /etc/fstab
			echo "tmpfs			/var/log			tmpfs			rw,nosuid,nodev,noexec,noatime,nodiratime			0 0" >> /etc/fstab

		fi

	else

					echo "🔧 CONFIGURATION FSTAB"
		if [ "$FSTAB_CONFIG1" = "NONE" ]
		then

			# echo "tmpfs			/var/log			tmpfs			rw,nosuid,nodev,noexec,noatime,nodiratime,mode=1755				0 0" > /etc/fstab
			echo "tmpfs			/var/log			tmpfs			rw,nosuid,nodev,noexec,noatime,nodiratime			0 0" > /etc/fstab

		else

			# echo "tmpfs			/var/log			tmpfs			rw,nosuid,nodev,noexec,noatime,nodiratime,mode=1755				0 0" >> /etc/fstab
			echo "tmpfs			/var/log			tmpfs			rw,nosuid,nodev,noexec,noatime,nodiratime			0 0" >> /etc/fstab

		fi


	fi

fi


### GRUB ###

if [ $GRUB_CONFIG -eq 1 ]
then

	echo ""
	echo "🔧 CONFIGURATION GRUB"
	sed -i "s#GRUB_CMDLINE_LINUX_DEFAULT.*#GRUB_CMDLINE_LINUX_DEFAULT=$GRUB_CMDLINE_LINUX_DEFAULT#" q
	update-grub

fi


### KERNEL ###

echo "🔧 CONFIGURE SYSCTL (KERNEL)"
if [ $IPv6 -eq 1 ]
then

	if [ -e /etc/sysctl.d/70-disable-ipv6.conf ]
	then

		rm -f /etc/sysctl.d/70-disable-ipv6.conf

	fi

else

	echo "net.ipv6.conf.all.disable_ipv6 = 1" > /etc/sysctl.d/70-disable-ipv6.conf
	echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.d/70-disable-ipv6.conf
	/usr/sbin/sysctl -p -f /etc/sysctl.d/70-disable-ipv6.conf

fi

if [ $DEBIAN_TYPE == "LXC" ]
then

	echo "net.ipv4.conf.all.accept_redirects = 1" > /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.all.accept_source_route = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.all.secure_redirects = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.all.log_martians = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.all.rp_filter = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.default.accept_redirects = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.default.accept_source_route = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.default.secure_redirects = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.default.send_redirects = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.default.log_martians = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.default.rp_filter = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.icmp_ignore_bogus_error_responses = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.ip_local_port_range = 1025    65535" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.ip_no_pmtu_disc = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.ipfrag_high_thresh=8388608" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.ipfrag_low_thresh=196608" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.route.min_pmtu = 536" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_adv_win_scale = 14" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_base_mss = 1460" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_challenge_ack_limit = 9999" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_congestion_control = htcp" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_ecn = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_fastopen=3" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_fin_timeout = 10" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_keepalive_time = 600" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_keepalive_intvl = 15" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_keepalive_probes = 5" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_limit_output_bytes = 65536" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_sack = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_mtu_probing = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_rfc1337 = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_slow_start_after_idle = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_no_metrics_save = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_syncookies = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_syn_retries = 2" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_synack_retries = 2" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_orphan_retries = 2" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_max_syn_backlog = 40000" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_max_tw_buckets = 2000000" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_wmem = 4096        524288   67108864" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_rmem = 4096        524288   67108864" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_timestamps = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_tw_reuse = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_window_scaling = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.udp_rmem_min = 8192" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.udp_wmem_min = 8192" >> /etc/sysctl.d/tune.conf
	echo "net.unix.max_dgram_qlen = 4096" >> /etc/sysctl.d/tune.conf
	echo "net.ipv6.conf.all.autoconf = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv6.conf.all.forwarding = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv6.conf.default.autoconf = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv6.ip6frag_high_thresh=8388608" >> /etc/sysctl.d/tune.conf
	echo "net.ipv6.ip6frag_low_thresh=196608" >> /etc/sysctl.d/tune.conf
	echo "net.core.optmem_max = 4194304" >> /etc/sysctl.d/tune.conf
	echo "net.core.somaxconn = 256000" >> /etc/sysctl.d/tune.conf
	/usr/sbin/sysctl -p -f /etc/sysctl.d/tune.conf

fi

if [ $DEBIAN_TYPE == "PHYSICAL" ]
then

	echo "kernel.panic = 90" > /etc/sysctl.d/tune.conf
	echo "kernel.panic_on_oops = 1" >> /etc/sysctl.d/tune.conf
	echo "kernel.sched_autogroup_enabled = 0" >> /etc/sysctl.d/tune.conf
	echo "kernel.unprivileged_bpf_disabled=1" >> /etc/sysctl.d/tune.conf
	echo "kernel.sysrq = 1" >> /etc/sysctl.d/tune.conf
	echo "fs.inotify.max_user_instances = 16777216" >> /etc/sysctl.d/tune.conf
	echo "fs.inotify.max_queued_events = 8388608" >> /etc/sysctl.d/tune.conf
	echo "fs.inotify.max_user_watches = 4194304" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.all.accept_redirects = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.all.accept_source_route = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.all.secure_redirects = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.all.log_martians = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.all.rp_filter = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.default.accept_redirects = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.default.accept_source_route = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.default.secure_redirects = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.default.send_redirects = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.default.log_martians = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.default.rp_filter = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.icmp_ignore_bogus_error_responses = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.ip_local_port_range = 1025    65535" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.ip_no_pmtu_disc = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.ipfrag_high_thresh=8388608" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.ipfrag_low_thresh=196608" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.neigh.default.gc_thresh1 = 1024" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.neigh.default.gc_thresh2 = 2048" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.neigh.default.gc_thresh3 = 4096" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.route.min_pmtu = 536" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_adv_win_scale = 14" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_base_mss = 1460" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_challenge_ack_limit = 9999" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_congestion_control = htcp" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_ecn = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_fastopen=3" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_fin_timeout = 10" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_keepalive_time = 600" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_keepalive_intvl = 15" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_keepalive_probes = 5" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_limit_output_bytes = 65536" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_low_latency = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_sack = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_mtu_probing = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_rfc1337 = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_slow_start_after_idle = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_no_metrics_save = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_syncookies = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_syn_retries = 2" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_synack_retries = 2" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_orphan_retries = 2" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_max_syn_backlog = 40000" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_max_tw_buckets = 2000000" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_mem = 386916		515889	773832" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_wmem = 4096        524288   67108864" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_rmem = 4096        524288   67108864" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_timestamps = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_tw_reuse = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_window_scaling = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.udp_mem = 756918	1009225	1513836" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.udp_rmem_min = 8192" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.udp_wmem_min = 8192" >> /etc/sysctl.d/tune.conf
	echo "net.unix.max_dgram_qlen = 4096" >> /etc/sysctl.d/tune.conf
	echo "net.ipv6.conf.all.autoconf = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv6.conf.all.forwarding = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv6.conf.default.autoconf = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv6.ip6frag_high_thresh=8388608" >> /etc/sysctl.d/tune.conf
	echo "net.ipv6.ip6frag_low_thresh=196608" >> /etc/sysctl.d/tune.conf
	echo "net.core.default_qdisc = fq_codel" >> /etc/sysctl.d/tune.conf
	echo "net.core.netdev_budget = 600" >> /etc/sysctl.d/tune.conf
	# echo "net.core.netdev_budget_usecs = 4000" >> /etc/sysctl.d/tune.conf
	echo "net.core.netdev_max_backlog = 250000" >> /etc/sysctl.d/tune.conf
	echo "net.core.rmem_default = 33554432" >> /etc/sysctl.d/tune.conf
	echo "net.core.wmem_default = 33554432" >> /etc/sysctl.d/tune.conf
	echo "net.core.rmem_max = 134217728" >> /etc/sysctl.d/tune.conf
	echo "net.core.wmem_max = 134217728" >> /etc/sysctl.d/tune.conf
	echo "net.core.optmem_max = 4194304" >> /etc/sysctl.d/tune.conf
	echo "net.core.somaxconn = 256000" >> /etc/sysctl.d/tune.conf
	# echo "net.netfilter.nf_conntrack_max = 1048576" >> /etc/sysctl.d/tune.conf
	# echo "net.nf_conntrack_max = 1048576" >> /etc/sysctl.d/tune.conf
	# echo "net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 5" >> /etc/sysctl.d/tune.conf
	if [ -f /proc/sys/vm/compaction_proactiveness ]; then
	  echo "vm.compaction_proactiveness = 20" >> /etc/sysctl.d/tune.conf
	fi
	echo "vm.dirty_background_ratio = 10" >> /etc/sysctl.d/tune.conf
	echo "vm.dirty_ratio = 40" >> /etc/sysctl.d/tune.conf
	echo "vm.dirty_expire_centisecs = 42000" >> /etc/sysctl.d/tune.conf
	echo "vm.dirty_writeback_centisecs = 7000" >> /etc/sysctl.d/tune.conf
	echo "vm.drop_caches = 3" >> /etc/sysctl.d/tune.conf
	echo "vm.max_map_count = 262144" >> /etc/sysctl.d/tune.conf
	echo "vm.nr_hugepages = 4096" >> /etc/sysctl.d/tune.conf
	echo "vm.overcommit_memory = 1" >> /etc/sysctl.d/tune.conf
	echo "vm.swappiness = 1" >> /etc/sysctl.d/tune.conf
	echo "vm.vfs_cache_pressure = 50" >> /etc/sysctl.d/tune.conf
	/usr/sbin/sysctl -p -f /etc/sysctl.d/tune.conf

	echo "htcp" > /etc/modules-load.d/promox.conf
	echo "kvmgt" >> /etc/modules-load.d/promox.conf
	echo "vfio" >> /etc/modules-load.d/promox.conf
	echo "vfio_iommu_type1" >> /etc/modules-load.d/promox.conf
	echo "vfio_pci" >> /etc/modules-load.d/promox.conf
	echo "vfio_pci_core" >> /etc/modules-load.d/promox.conf
	echo "vfio_virqfd" >> /etc/modules-load.d/promox.conf

	if [ $DRIVERS_NVIDIA == "1" ]
	then

		echo "nvidia" >> /etc/modules-load.d/promox.conf
		echo "nvidia_drm" >> /etc/modules-load.d/promox.conf
		echo "nvidia_modeset" >> /etc/modules-load.d/promox.conf
		echo "nvidia_uvm" >> /etc/modules-load.d/promox.conf

		echo "blacklist nouveau" > /etc/modprobe.d/blacklist.conf

	fi

	if [ $DRIVERS_LAST == "1" ]
	then

		cd /tmp
		git clone https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
		cd linux-firmware
		make install

	fi

	if [ "$KERNEL_CURRENT" != "$KERNEL_LAST" ]; then
		
		echo "🔧 CONFIGURATION INITRAMFS ($KERNEL_CURRENT vs $KERNEL_LAST"
		update-initramfs -u -k all
	fi

fi

if [ $DEBIAN_TYPE == "VM" ]
then

	echo "kernel.panic = 90" > /etc/sysctl.d/tune.conf
	echo "kernel.panic_on_oops = 1" >> /etc/sysctl.d/tune.conf
	echo "kernel.sched_autogroup_enabled = 0" >> /etc/sysctl.d/tune.conf
	echo "kernel.unprivileged_bpf_disabled=1" >> /etc/sysctl.d/tune.conf
	echo "kernel.sysrq = 1" >> /etc/sysctl.d/tune.conf
	echo "fs.inotify.max_user_instances = 16777216" >> /etc/sysctl.d/tune.conf
	echo "fs.inotify.max_queued_events = 8388608" >> /etc/sysctl.d/tune.conf
	echo "fs.inotify.max_user_watches = 4194304" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.all.accept_redirects = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.all.accept_source_route = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.all.secure_redirects = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.all.log_martians = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.all.rp_filter = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.default.accept_redirects = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.default.accept_source_route = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.default.secure_redirects = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.default.send_redirects = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.default.log_martians = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.default.rp_filter = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.icmp_ignore_bogus_error_responses = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.ip_local_port_range = 1025    65535" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.ip_no_pmtu_disc = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.ipfrag_high_thresh=8388608" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.ipfrag_low_thresh=196608" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.neigh.default.gc_thresh1 = 1024" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.neigh.default.gc_thresh2 = 2048" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.neigh.default.gc_thresh3 = 4096" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.route.min_pmtu = 536" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_adv_win_scale = 14" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_base_mss = 1460" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_challenge_ack_limit = 9999" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_congestion_control = htcp" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_ecn = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_fastopen=3" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_fin_timeout = 10" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_keepalive_time = 600" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_keepalive_intvl = 15" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_keepalive_probes = 5" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_limit_output_bytes = 65536" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_low_latency = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_sack = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_mtu_probing = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_rfc1337 = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_slow_start_after_idle = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_no_metrics_save = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_syncookies = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_syn_retries = 2" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_synack_retries = 2" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_orphan_retries = 2" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_max_syn_backlog = 40000" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_max_tw_buckets = 2000000" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_mem = 386916		515889	773832" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_wmem = 4096        524288   67108864" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_rmem = 4096        524288   67108864" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_timestamps = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_tw_reuse = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_window_scaling = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.udp_mem = 756918	1009225	1513836" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.udp_rmem_min = 8192" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.udp_wmem_min = 8192" >> /etc/sysctl.d/tune.conf
	echo "net.unix.max_dgram_qlen = 4096" >> /etc/sysctl.d/tune.conf
	echo "net.ipv6.conf.all.autoconf = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv6.conf.all.forwarding = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv6.conf.default.autoconf = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv6.ip6frag_high_thresh=8388608" >> /etc/sysctl.d/tune.conf
	echo "net.ipv6.ip6frag_low_thresh=196608" >> /etc/sysctl.d/tune.conf
	echo "net.core.default_qdisc = fq_codel" >> /etc/sysctl.d/tune.conf
	echo "net.core.netdev_budget = 600" >> /etc/sysctl.d/tune.conf
	echo "net.core.netdev_budget_usecs = 4000" >> /etc/sysctl.d/tune.conf
	echo "net.core.netdev_max_backlog = 250000" >> /etc/sysctl.d/tune.conf
	echo "net.core.rmem_default = 33554432" >> /etc/sysctl.d/tune.conf
	echo "net.core.wmem_default = 33554432" >> /etc/sysctl.d/tune.conf
	echo "net.core.rmem_max = 134217728" >> /etc/sysctl.d/tune.conf
	echo "net.core.wmem_max = 134217728" >> /etc/sysctl.d/tune.conf
	echo "net.core.optmem_max = 4194304" >> /etc/sysctl.d/tune.conf
	echo "net.core.somaxconn = 256000" >> /etc/sysctl.d/tune.conf
	echo "net.netfilter.nf_conntrack_max = 1048576" >> /etc/sysctl.d/tune.conf
	echo "net.nf_conntrack_max = 1048576" >> /etc/sysctl.d/tune.conf
	echo "net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 5" >> /etc/sysctl.d/tune.conf
	if [ -f /proc/sys/vm/compaction_proactiveness ]; then
	  echo "vm.compaction_proactiveness = 20" >> /etc/sysctl.d/tune.conf
	fi
	echo "vm.dirty_background_ratio = 10" >> /etc/sysctl.d/tune.conf
	echo "vm.dirty_ratio = 40" >> /etc/sysctl.d/tune.conf
	echo "vm.dirty_expire_centisecs = 42000" >> /etc/sysctl.d/tune.conf
	echo "vm.dirty_writeback_centisecs = 7000" >> /etc/sysctl.d/tune.conf
	echo "vm.drop_caches = 3" >> /etc/sysctl.d/tune.conf
	echo "vm.max_map_count = 262144" >> /etc/sysctl.d/tune.conf
	echo "vm.nr_hugepages = 4096" >> /etc/sysctl.d/tune.conf
	echo "vm.overcommit_memory = 1" >> /etc/sysctl.d/tune.conf
	echo "vm.swappiness = 0" >> /etc/sysctl.d/tune.conf
	echo "vm.vfs_cache_pressure = 50" >> /etc/sysctl.d/tune.conf
	/usr/sbin/sysctl -p -f /etc/sysctl.d/tune.conf

	echo "htcp" > /etc/modules-load.d/promox.conf
	echo "kvmgt" >> /etc/modules-load.d/promox.conf
	echo "vfio" >> /etc/modules-load.d/promox.conf
	echo "vfio_iommu_type1" >> /etc/modules-load.d/promox.conf
	echo "vfio_pci" >> /etc/modules-load.d/promox.conf
	echo "vfio_pci_core" >> /etc/modules-load.d/promox.conf
	echo "vfio_virqfd" >> /etc/modules-load.d/promox.conf

	if [ $DRIVERS_NVIDIA == "1" ]
	then

		echo "nvidia" >> /etc/modules-load.d/promox.conf
		echo "nvidia_drm" >> /etc/modules-load.d/promox.conf
		echo "nvidia_modeset" >> /etc/modules-load.d/promox.conf
		echo "nvidia_uvm" >> /etc/modules-load.d/promox.conf

		echo "blacklist nouveau" > /etc/modprobe.d/blacklist.conf

	fi

	if [ "$KERNEL_CURRENT" != "$KERNEL_LAST" ]; then
		
		echo "🔧 CONFIGURATION INITRAMFS ($KERNEL_CURRENT vs $KERNEL_LAST"
		update-initramfs -u -k all
	fi

fi

if [ $DEBIAN_TYPE == "PROXMOX" ]
then

	echo "kernel.panic = 90" > /etc/sysctl.d/tune.conf
	echo "kernel.panic_on_oops = 1" >> /etc/sysctl.d/tune.conf
	echo "kernel.sched_autogroup_enabled = 0" >> /etc/sysctl.d/tune.conf
	echo "kernel.unprivileged_bpf_disabled=1" >> /etc/sysctl.d/tune.conf
	echo "kernel.sysrq = 1" >> /etc/sysctl.d/tune.conf
	echo "fs.inotify.max_user_instances = 16777216" >> /etc/sysctl.d/tune.conf
	echo "fs.inotify.max_queued_events = 8388608" >> /etc/sysctl.d/tune.conf
	echo "fs.inotify.max_user_watches = 4194304" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.all.accept_redirects = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.all.accept_source_route = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.all.secure_redirects = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.all.log_martians = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.all.rp_filter = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.default.accept_redirects = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.default.accept_source_route = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.default.secure_redirects = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.default.send_redirects = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.default.log_martians = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.conf.default.rp_filter = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.icmp_ignore_bogus_error_responses = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.ip_local_port_range = 1025    65535" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.ip_no_pmtu_disc = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.ipfrag_high_thresh=8388608" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.ipfrag_low_thresh=196608" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.neigh.default.gc_thresh1 = 1024" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.neigh.default.gc_thresh2 = 2048" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.neigh.default.gc_thresh3 = 4096" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.route.min_pmtu = 536" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_adv_win_scale = 14" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_base_mss = 1460" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_challenge_ack_limit = 9999" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_congestion_control = htcp" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_ecn = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_fastopen=3" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_fin_timeout = 10" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_keepalive_time = 600" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_keepalive_intvl = 15" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_keepalive_probes = 5" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_limit_output_bytes = 65536" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_low_latency = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_sack = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_mtu_probing = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_rfc1337 = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_slow_start_after_idle = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_no_metrics_save = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_syncookies = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_syn_retries = 2" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_synack_retries = 2" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_orphan_retries = 2" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_max_syn_backlog = 40000" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_max_tw_buckets = 2000000" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_mem = 386916		515889	773832" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_wmem = 4096        524288    67108864" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_rmem = 4096        524288    67108864" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_timestamps = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_tw_reuse = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.tcp_window_scaling = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.udp_mem = 756918	1009225	1513836" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.udp_rmem_min = 8192" >> /etc/sysctl.d/tune.conf
	echo "net.ipv4.udp_wmem_min = 8192" >> /etc/sysctl.d/tune.conf
	echo "net.unix.max_dgram_qlen = 4096" >> /etc/sysctl.d/tune.conf
	echo "net.ipv6.conf.all.autoconf = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv6.conf.all.forwarding = 1" >> /etc/sysctl.d/tune.conf
	echo "net.ipv6.conf.default.autoconf = 0" >> /etc/sysctl.d/tune.conf
	echo "net.ipv6.ip6frag_high_thresh=8388608" >> /etc/sysctl.d/tune.conf
	echo "net.ipv6.ip6frag_low_thresh=196608" >> /etc/sysctl.d/tune.conf
	echo "net.core.default_qdisc = fq_codel" >> /etc/sysctl.d/tune.conf
	echo "net.core.netdev_budget = 600" >> /etc/sysctl.d/tune.conf
	echo "net.core.netdev_budget_usecs = 4000" >> /etc/sysctl.d/tune.conf
	echo "net.core.netdev_max_backlog = 250000" >> /etc/sysctl.d/tune.conf
	echo "net.core.rmem_default = 33554432" >> /etc/sysctl.d/tune.conf
	echo "net.core.wmem_default = 33554432" >> /etc/sysctl.d/tune.conf
	echo "net.core.rmem_max = 134217728" >> /etc/sysctl.d/tune.conf
	echo "net.core.wmem_max = 134217728" >> /etc/sysctl.d/tune.conf
	echo "net.core.optmem_max = 4194304" >> /etc/sysctl.d/tune.conf
	echo "net.core.somaxconn = 256000" >> /etc/sysctl.d/tune.conf
	echo "net.netfilter.nf_conntrack_max = 1048576" >> /etc/sysctl.d/tune.conf
	echo "net.nf_conntrack_max = 1048576" >> /etc/sysctl.d/tune.conf
	echo "net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 5" >> /etc/sysctl.d/tune.conf
	if [ -f /proc/sys/vm/compaction_proactiveness ]; then
	  echo "vm.compaction_proactiveness = 20" >> /etc/sysctl.d/tune.conf
	fi
	echo "vm.dirty_background_ratio = 10" >> /etc/sysctl.d/tune.conf
	echo "vm.dirty_ratio = 40" >> /etc/sysctl.d/tune.conf
	echo "vm.dirty_expire_centisecs = 42000" >> /etc/sysctl.d/tune.conf
	echo "vm.dirty_writeback_centisecs = 7000" >> /etc/sysctl.d/tune.conf
	echo "vm.drop_caches = 3" >> /etc/sysctl.d/tune.conf
	echo "vm.max_map_count = 262144" >> /etc/sysctl.d/tune.conf
	echo "vm.nr_hugepages = 4096" >> /etc/sysctl.d/tune.conf
	echo "vm.overcommit_memory = 1" >> /etc/sysctl.d/tune.conf
	echo "vm.swappiness = 1" >> /etc/sysctl.d/tune.conf
	echo "vm.vfs_cache_pressure = 50" >> /etc/sysctl.d/tune.conf
	/usr/sbin/sysctl -p -f /etc/sysctl.d/tune.conf

	echo "htcp" > /etc/modules-load.d/promox.conf
	echo "kvmgt" >> /etc/modules-load.d/promox.conf
	echo "vfio" >> /etc/modules-load.d/promox.conf
	echo "vfio_iommu_type1" >> /etc/modules-load.d/promox.conf
	echo "vfio_pci" >> /etc/modules-load.d/promox.conf
	echo "vfio_pci_core" >> /etc/modules-load.d/promox.conf
	echo "vfio_virqfd" >> /etc/modules-load.d/promox.conf

	if [ $DRIVERS_NVIDIA == "1" ]
	then

		echo "nvidia" >> /etc/modules-load.d/promox.conf
		echo "nvidia_drm" >> /etc/modules-load.d/promox.conf
		echo "nvidia_modeset" >> /etc/modules-load.d/promox.conf
		echo "nvidia_uvm" >> /etc/modules-load.d/promox.conf

		echo "blacklist nouveau" > /etc/modprobe.d/blacklist.conf

	fi
  
  if [ $DRIVERS_LAST == "1" ]
	then

		cd /tmp
		git clone https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
		cd linux-firmware
		make install

	fi

	if [ "$KERNEL_CURRENT" != "$KERNEL_LAST" ]; then
		
		echo "🔧 CONFIGURATION INITRAMFS ($KERNEL_CURRENT vs $KERNEL_LAST"
		update-initramfs -u -k all
	fi

	# KSM
	systemctl enable ksmtuned
	systemctl start ksmtuned
	echo "CHECK KSM..."
	cat /sys/kernel/mm/ksm/pages_shared
	cat /sys/kernel/mm/ksm/pages_sharing
	cat /proc/meminfo | grep Huge

	# Limits
 	echo "* soft nofile 4194304" | tee /etc/security/limits.d/99-limits.conf
	ulimit -n

  if dpkg -s proxmox-default-kernel &>/dev/null
  then

    if dpkg -s proxmox-ve &>/dev/null
    then

      if dpkg -s os-prober &>/dev/null
      then

        echo "🔧 CLEANING POST-INSTALLATION PROXMOX"
        apt remove linux-image-amd64 'linux-image-6*' os-prober -y				

      else

        echo "PROXMOX OK ✅"

      fi			

    else

      echo "PROXMOX OK ✅"
      apt install -y proxmox-ve ksm-control-daemon locales-all chrony libguestfs-tools -y

    fi

  else

    apt install proxmox-default-headers proxmox-default-kernel -y
    echo "🔧 RESTART COMPUTER NOW..."
    exit

  fi

fi


### LOGROTATE ###

if [ $LOG_ROTATE -eq 1 ]
then

	echo "🔧 CONFIGURE LOGOROTATE"

cat > /etc/logrotate.conf <<EOF

daily
rotate ${LOG_ROTATE_DAILY}
create
compress
delaycompress
dateext
missingok
notifempty
sharedscripts

include /etc/logrotate.d

/var/log/wtmp {
    missingok
    monthly
    create 0664 root utmp
    rotate 1
}

/var/log/btmp {
    missingok
    monthly
    create 0660 root utmp
    rotate 1
}
EOF

fi


### NETWORK ###

config_host


### SYSTEMD ###

echo "🔧 CONFIGURE SYSTEMD"
sed -i 's%.*Compress=.*%Compress=yes%' /etc/systemd/journald.conf
sed -i 's%.*Storage=.*%Storage=volatile%' /etc/systemd/journald.conf
sed -i -E "s|^[#[:space:]]*SystemMaxUse=.*|SystemMaxUse=${JOURNALD_MAX_USE}|" /etc/systemd/journald.conf
sed -i -E "s|^[#[:space:]]*SystemKeepFree=.*|SystemKeepFree=${JOURNALD_KEEP_FREE}|" /etc/systemd/journald.conf
sed -i -E "s|^[#[:space:]]*RuntimeMaxUse=.*|RuntimeMaxUse=${JOURNALD_MAX_USE}|" /etc/systemd/journald.conf
sed -i -E "s|^[#[:space:]]*RuntimeKeepFree=.*|RuntimeKeepFree=${JOURNALD_KEEP_FREE}|" /etc/systemd/journald.conf
systemctl restart systemd-journald

if [ $NO_SLEEP -eq 1 ]
then
	echo "🔧 CONFIGURE NO SLEEP"
	mkdir -p /etc/systemd/sleep.conf.d
	echo "[Sleep]" > /etc/systemd/sleep.conf.d/nosleep.conf
	echo "AllowSuspend=no" >> /etc/systemd/sleep.conf.d/nosleep.conf
	echo "AllowHibernation=no" >> /etc/systemd/sleep.conf.d/nosleep.conf
	echo "AllowSuspendThenHibernate=no" >> /etc/systemd/sleep.conf.d/nosleep.conf
	echo "AllowHybridSleep=no" >> /etc/systemd/sleep.conf.d/nosleep.conf
fi

#### SOFTWARES ####

if [ "${ACMESH:-0}" -eq 1 ]; then

    ACMESH_HOME="${ACMESH_HOME:-/root/.acme.sh}"
    ACMESH_BIN="${ACMESH_HOME}/acme.sh"
    ACMESH_REPOSITORY="https://github.com/acmesh-official/acme.sh.git"
    ACMESH_EMAIL="${ACMESH_EMAIL:-}"

    # Vérification de tous les prérequis, et pas seulement de coreutils.
    ACMESH_MISSING_PACKAGES=""

    for ACMESH_PACKAGE in cron coreutils curl git grep sed wget; do
        if ! dpkg-query -W -f='${Status}' "${ACMESH_PACKAGE}" 2>/dev/null |
            grep -q '^install ok installed$'
        then
            ACMESH_MISSING_PACKAGES="${ACMESH_MISSING_PACKAGES} ${ACMESH_PACKAGE}"
        fi
    done

    if [ -n "${ACMESH_MISSING_PACKAGES}" ]; then
        echo "🔧 INSTALL PREREQUISITES FOR ACME.SH"

        apt-get update
        apt-get install -y ${ACMESH_MISSING_PACKAGES}
    fi

	systemctl enable --now cron

    ACMESH_REMOTE_VERSION="$(
        git ls-remote \
            --tags \
            --refs \
            "${ACMESH_REPOSITORY}" 2>/dev/null |
        awk -F'refs/tags/' 'NF == 2 { print $2 }' |
        sed 's/^v//' |
        grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' |
        sort -V |
        tail -n 1
    )"

    if [ -z "${ACMESH_REMOTE_VERSION}" ]; then
        echo "[ERREUR] Impossible de déterminer la dernière version de acme.sh."
        exit 1
    fi

	if [ ! -x "${ACMESH_BIN}" ]; then

		echo "🔧 INSTALL ACME.SH (${ACMESH_REMOTE_VERSION})"

		ACMESH_TMP_DIR="$(mktemp -d)"

		cleanup_acmesh_tmp() {
			rm -rf "${ACMESH_TMP_DIR}"
		}

		trap cleanup_acmesh_tmp EXIT

		if ! git \
			-c advice.detachedHead=false \
			clone \
			--quiet \
			--depth 1 \
			--branch "${ACMESH_REMOTE_VERSION}" \
			"${ACMESH_REPOSITORY}" \
			"${ACMESH_TMP_DIR}/acme.sh"
		then
			echo "[ERREUR] Impossible de télécharger acme.sh ${ACMESH_REMOTE_VERSION}."
			exit 1
		fi

		if [ -n "${ACMESH_EMAIL}" ]; then

			if ! (
				cd "${ACMESH_TMP_DIR}/acme.sh" &&
				./acme.sh \
					--install \
					--home "${ACMESH_HOME}" \
					--accountemail "${ACMESH_EMAIL}"
			); then
				echo "[ERREUR] L'installation de acme.sh a échoué."
				exit 1
			fi

		else

			echo "[AVERTISSEMENT] ACMESH_EMAIL n'est pas défini."

			if ! (
				cd "${ACMESH_TMP_DIR}/acme.sh" &&
				./acme.sh \
					--install \
					--home "${ACMESH_HOME}"
			); then
				echo "[ERREUR] L'installation de acme.sh a échoué."
				exit 1
			fi

		fi

		if [ ! -x "${ACMESH_BIN}" ]; then
			echo "[ERREUR] acme.sh est introuvable après l'installation :"
			echo "         ${ACMESH_BIN}"
			exit 1
		fi

		cleanup_acmesh_tmp
		trap - EXIT

		echo "ACME.SH IS OK ✅ (${ACMESH_REMOTE_VERSION})"

    else

        ACMESH_LOCAL_VERSION="$(
            "${ACMESH_BIN}" --version 2>/dev/null |
            grep -Eo 'v?[0-9]+\.[0-9]+\.[0-9]+' |
            head -n 1 |
            sed 's/^v//'
        )"

        if [ -z "${ACMESH_LOCAL_VERSION}" ]; then
            echo "[ERREUR] Impossible de déterminer la version locale de acme.sh."
            exit 1
        fi

        if [ "${ACMESH_LOCAL_VERSION}" != "${ACMESH_REMOTE_VERSION}" ]; then

            echo "🔧 UPDATE ACME.SH (${ACMESH_LOCAL_VERSION} TO ${ACMESH_REMOTE_VERSION})"

            if ! "${ACMESH_BIN}" \
                --upgrade \
                --home "${ACMESH_HOME}"
            then
                echo "[ERREUR] La mise à jour de acme.sh a échoué."
                exit 1
            fi

            ACMESH_UPDATED_VERSION="$(
                "${ACMESH_BIN}" --version 2>/dev/null |
                grep -Eo 'v?[0-9]+\.[0-9]+\.[0-9]+' |
                head -n 1 |
                sed 's/^v//'
            )"

			if [ "${ACMESH_UPDATED_VERSION}" != "${ACMESH_REMOTE_VERSION}" ]; then
				echo "[ERREUR] Version obtenue après mise à jour : ${ACMESH_UPDATED_VERSION:-inconnue}"
				echo "[ERREUR] Version attendue : ${ACMESH_REMOTE_VERSION}"
				exit 1
			fi

			echo "ACME.SH IS OK ✅ (${ACMESH_UPDATED_VERSION})"

        else
            echo "ACME.SH IS OK ✅ (${ACMESH_LOCAL_VERSION})"
        fi
    fi

    export PATH="${ACMESH_HOME}:${PATH}"

	ACMESH_CRON_MARKER="# DIU MANAGED ACME.SH RENEWAL"
	ACMESH_CRON_ENTRY="0 12 1,15 * * \"${ACMESH_BIN}\" --cron --home \"${ACMESH_HOME}\" > /dev/null 2>&1"

	ACMESH_CRON_TMP="$(mktemp)"

	crontab -l 2>/dev/null > "${ACMESH_CRON_TMP}" || true

	sed -i \
		-e '\|# DIU MANAGED ACME\.SH RENEWAL|d' \
		-e '\|[/.]acme\.sh.*--cron.*--home|d' \
		"${ACMESH_CRON_TMP}"

	sed -i ':a;/^[[:space:]]*$/{$d;N;ba;}' "${ACMESH_CRON_TMP}"

	{
		if [ -s "${ACMESH_CRON_TMP}" ]; then
			echo
		fi

		echo "${ACMESH_CRON_MARKER}"
		echo "${ACMESH_CRON_ENTRY}"
	} >> "${ACMESH_CRON_TMP}"

	ACMESH_CURRENT_CRON="$(crontab -l 2>/dev/null || true)"
	ACMESH_NEW_CRON="$(cat "${ACMESH_CRON_TMP}")"

	if [ "${ACMESH_CURRENT_CRON}" != "${ACMESH_NEW_CRON}" ]; then

		if ! crontab "${ACMESH_CRON_TMP}"; then
			echo "[ERREUR] Impossible de configurer le renouvellement ACME.SH."
			rm -f "${ACMESH_CRON_TMP}"
			exit 1
		fi

		echo "🔧 CONFIGURE ACME.SH RENEWAL CRON"
		echo "ACME.SH RENEWAL CRON IS OK ✅ (1st AND 15th AT 12:00)"

	else
		echo "ACME.SH RENEWAL CRON IS OK ✅ (1st AND 15th AT 12:00)"
	fi

	rm -f "${ACMESH_CRON_TMP}"

	for ACMESH_REQUIRED_VAR in \
		DNS_OVH_ENDPOINT \
		DNS_OVH_APPLICATION_KEY \
		DNS_OVH_APPLICATION_SECRET \
		DNS_OVH_CONSUMER_KEY \
		DNS_OVH_DOMAIN1
	do
		if [ -z "${!ACMESH_REQUIRED_VAR:-}" ]; then
			echo "[ERREUR] La variable ${ACMESH_REQUIRED_VAR} n'est pas définie."
			exit 1
		fi
	done

    export OVH_END_POINT="${DNS_OVH_ENDPOINT}"
    export OVH_AK="${DNS_OVH_APPLICATION_KEY}"
    export OVH_AS="${DNS_OVH_APPLICATION_SECRET}"
    export OVH_CK="${DNS_OVH_CONSUMER_KEY}"

    ACMESH_DOMAIN="${DNS_OVH_DOMAIN1}"
    ACMESH_CERT_DIR="${ACMESH_HOME}/${ACMESH_DOMAIN}_ecc"
    ACMESH_CERT_FILE="${ACMESH_CERT_DIR}/${ACMESH_DOMAIN}.cer"

	ACMESH_CERT_EXISTS=0
	ACMESH_CERT_VALID=0
	ACMESH_CERT_EXPIRED=0

	if [ -s "${ACMESH_CERT_FILE}" ]; then
		ACMESH_CERT_EXISTS=1

		if openssl x509 \
			-in "${ACMESH_CERT_FILE}" \
			-noout \
			-checkend 86400 >/dev/null 2>&1
		then
			ACMESH_CERT_VALID=1
		fi

		# Vérifie si le certificat est déjà expiré.
		if ! openssl x509 \
			-in "${ACMESH_CERT_FILE}" \
			-noout \
			-checkend 0 >/dev/null 2>&1
		then
			ACMESH_CERT_EXPIRED=1
		fi
	fi

	if [ "${ACMESH_CERT_EXISTS}" -eq 0 ]; then

		echo "🔧 REQUEST ACME CERTIFICATE FOR ${ACMESH_DOMAIN}"

		if ! "${ACMESH_BIN}" \
			--issue \
			--home "${ACMESH_HOME}" \
			--server letsencrypt \
			--dns dns_ovh \
			--keylength ec-384 \
			-d "${ACMESH_DOMAIN}" \
			-d "*.${ACMESH_DOMAIN}"
		then
			echo "[ERREUR] Échec de la demande du certificat pour ${ACMESH_DOMAIN}."
			exit 1
		fi

		echo "ACME CERTIFICATE IS OK ✅ (${ACMESH_DOMAIN} + *.${ACMESH_DOMAIN})"

	elif [ "${ACMESH_CERT_EXPIRED}" -eq 1 ]; then

		echo "❌ ACME CERTIFICATE IS EXPIRED (${ACMESH_DOMAIN})"
		echo "🔧 FORCE ACME CERTIFICATE RENEWAL FOR ${ACMESH_DOMAIN}"

		if ! "${ACMESH_BIN}" \
			--renew \
			--home "${ACMESH_HOME}" \
			--server letsencrypt \
			-d "${ACMESH_DOMAIN}" \
			--ecc \
			--force
		then
			echo "[ERREUR] Échec du renouvellement forcé du certificat pour ${ACMESH_DOMAIN}."
			exit 1
		fi

		echo "ACME CERTIFICATE RENEWAL IS OK ✅ (${ACMESH_DOMAIN})"

	elif [ "${ACMESH_CERT_VALID}" -eq 0 ]; then

		echo "⚠️ ACME CERTIFICATE EXPIRES IN LESS THAN 24 HOURS (${ACMESH_DOMAIN})"
		echo "🔧 FORCE ACME CERTIFICATE RENEWAL FOR ${ACMESH_DOMAIN}"

		if ! "${ACMESH_BIN}" \
			--renew \
			--home "${ACMESH_HOME}" \
			--server letsencrypt \
			-d "${ACMESH_DOMAIN}" \
			--ecc \
			--force
		then
			echo "[ERREUR] Échec du renouvellement forcé du certificat pour ${ACMESH_DOMAIN}."
			exit 1
		fi

		echo "ACME CERTIFICATE RENEWAL IS OK ✅ (${ACMESH_DOMAIN})"

	else

		ACMESH_CERT_EXPIRY="$(
			openssl x509 \
				-in "${ACMESH_CERT_FILE}" \
				-noout \
				-enddate |
			cut -d= -f2
		)"

		ACMESH_EXPIRY_DATE="$(
			date -d "${ACMESH_CERT_EXPIRY}" +%Y-%m-%d
		)"

		ACMESH_EXPIRY_TIMESTAMP="$(
			date -d "${ACMESH_CERT_EXPIRY}" +%s
		)"

		ACMESH_NOW_TIMESTAMP="$(date +%s)"

		ACMESH_REMAINING_SECONDS="$(
			echo $(( ACMESH_EXPIRY_TIMESTAMP - ACMESH_NOW_TIMESTAMP ))
		)"

		# Arrondi au supérieur pour éviter d'afficher 89 jours
		# lorsqu'il reste en réalité 89 jours et plusieurs heures.
		ACMESH_REMAINING_DAYS="$(
			echo $(( (ACMESH_REMAINING_SECONDS + 86399) / 86400 ))
		)"

		if [ "${ACMESH_REMAINING_DAYS}" -gt 30 ]; then
			ACMESH_STATUS="OK"
		elif [ "${ACMESH_REMAINING_DAYS}" -gt 7 ]; then
			ACMESH_STATUS="WARNING"
		else
			ACMESH_STATUS="CRITICAL"
		fi

		case "${ACMESH_STATUS}" in
			OK)
				ACMESH_ICON="✅"
				;;
			WARNING)
				ACMESH_ICON="⚠️"
				;;
			CRITICAL)
				ACMESH_ICON="❌"
				;;
		esac

		echo "	CERTIFICATE ${ACMESH_DOMAIN}"
		echo "	Expires  : ${ACMESH_EXPIRY_DATE}"
		echo "	Remaining: ${ACMESH_REMAINING_DAYS} days"
		echo "	Status   : ${ACMESH_STATUS} ${ACMESH_ICON}"

	fi

fi

if [ $APACHE2 -eq 1 ]
then

	if [ $DEBIAN_RELEASE = "trixie" ]
	then

		echo ""
		echo "INSTALL APACHE2"
		apt install apache2 libapache2-mod-perl2 libapache2-mod-fcgid libapache-session-perl perl-modules-5.40 libnet-ldap-perl libcache-cache-perl libdbi-perl libwww-perl libxml-simple-perl libsoap-lite-perl libhtml-template-perl libregexp-assemble-perl libregexp-common-perl libjs-jquery libxml-libxml-perl libcrypt-rijndael-perl libio-string-perl libxml-libxslt-perl libconfig-inifiles-perl libjson-perl libstring-random-perl libemail-date-format-perl libmime-lite-perl libcrypt-openssl-rsa-perl libdigest-hmac-perl libdigest-sha-perl libclone-perl libauthen-sasl-perl libnet-cidr-lite-perl libcrypt-openssl-x509-perl libauthcas-perl libtest-pod-perl libtest-mockobject-perl libauthen-captcha-perl libnet-openid-consumer-perl libnet-openid-server-perl libunicode-string-perl libconvert-pem-perl libmoose-perl libplack-perl libapache-session-browseable-perl libdbd-pg-perl libgssapi-perl -y

	fi

	if [ $DEBIAN_RELEASE = "bookworm" ]
	then

		echo ""
		echo "INSTALL APACHE2"
		apt install apache2 libapache2-mod-perl2 libapache2-mod-fcgid libapache-session-perl perl-modules-5.36 libnet-ldap-perl libcache-cache-perl libdbi-perl libwww-perl libxml-simple-perl libsoap-lite-perl libhtml-template-perl libregexp-assemble-perl libregexp-common-perl libjs-jquery libxml-libxml-perl libcrypt-rijndael-perl libio-string-perl libxml-libxslt-perl libconfig-inifiles-perl libjson-perl libstring-random-perl libemail-date-format-perl libmime-lite-perl libcrypt-openssl-rsa-perl libdigest-hmac-perl libdigest-sha-perl libclone-perl libauthen-sasl-perl libnet-cidr-lite-perl libcrypt-openssl-x509-perl libauthcas-perl libtest-pod-perl libtest-mockobject-perl libauthen-captcha-perl libnet-openid-consumer-perl libnet-openid-server-perl libunicode-string-perl libconvert-pem-perl libmoose-perl libplack-perl libapache-session-browseable-perl libdbd-pg-perl libgssapi-perl -y

	fi

	if [ $DEBIAN_RELEASE = "bullseye" ]
	then

		echo ""
		echo "INSTALL APACHE2"
		apt install apache2 libapache2-mod-perl2 libapache2-mod-fcgid libapache-session-perl perl-modules-5.32 libnet-ldap-perl libcache-cache-perl libdbi-perl libwww-perl libxml-simple-perl libsoap-lite-perl libhtml-template-perl libregexp-assemble-perl libregexp-common-perl libjs-jquery libxml-libxml-perl libcrypt-rijndael-perl libio-string-perl libxml-libxslt-perl libconfig-inifiles-perl libjson-perl libstring-random-perl libemail-date-format-perl libmime-lite-perl libcrypt-openssl-rsa-perl libdigest-hmac-perl libdigest-sha-perl libclone-perl libauthen-sasl-perl libnet-cidr-lite-perl libcrypt-openssl-x509-perl libauthcas-perl libtest-pod-perl libtest-mockobject-perl libauthen-captcha-perl libnet-openid-consumer-perl libnet-openid-server-perl libunicode-string-perl libconvert-pem-perl libmoose-perl libplack-perl libapache-session-browseable-perl libdbd-pg-perl libgssapi-perl -y

	fi

fi

if [ $CROWDSEC_AGENT -eq 1 ]
then

	echo ""
	echo "INSTALL CROWDSEC AGENT (LAPI)"
	apt install crowdsec -y

	# Tune CONFIG.YAML for disable LAPI
	sed -i 's%.*log_dir:.*%  log_dir: /var/log/machines/siem%' /etc/crowdsec/config.yaml
	sed -i 's%.*listen_uri:.*%    listen_uri: 0.0.0.0:8080%' /etc/crowdsec/config.yaml
	# Tune CROWDSEC.SERVICE for diasable LAPI
	sed -i 's%.*ExecStart=/usr/bin/crowdsec -c /etc/crowdsec/config.yaml.*%ExecStart=/usr/bin/crowdsec -c /etc/crowdsec/config.yaml%' /lib/systemd/system/crowdsec.service

	echo "RESTART CROWDSEC AGENT (LAPI)"
	systemctl daemon-reload
	systemctl enable crowdsec.service
	systemctl restart crowdsec.service

	echo "HUB CROWDSEC AGENT UPDATE"
	cscli hub update
	cscli hub upgrade

	echo "CROWDSEC AGENT INSTALL COLLECTIONS"
	cscli collections install crowdsecurity/linux
	cscli collections install crowdsecurity/sshd
	cscli collections install crowdsecurity/iptables

	echo ""
	echo "INSTALL CROWDSEC BOUNCER IPTABLES"
	apt install crowdsec-firewall-bouncer-iptables -y

	echo "CROWDSEC BOUNCER IPTABLES CONFIGURATION"
	sed -i 's%.*log_dir.*%log_dir: /var/log/machines/siem%' /etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml
	sed -i 's%.*api_url.*%api_url: http://127.0.0.1:8080/%' /etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml
	sed -i "s%.*api_key.*%api_key: $CROWDSEC_BOUNCER_API_KEY%" /etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml
	sed -i 's%.*disable_ipv6.*%disable_ipv6: false%' /etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml
	systemctl disable crowdsec-firewall-bouncer.service
	service crowdsec-firewall-bouncer restart

fi

if [ $CROWDSEC_BOUNCER -eq 1 ]
then

	echo ""
	echo "INSTALL CROWDSEC BOUNCER IPTABLES"
	apt install crowdsec-firewall-bouncer-iptables -y

	echo "CONFIGURE CROWDSEC BOUNCER IPTABLES CONFIGURATION"
	sed -i 's%.*api_url.*%api_url: http://siem.ch-nontron.fr:8080/%' /etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml
	sed -i "s%.*api_key.*%api_key: $CROWDSEC_BOUNCER_API_KEY%" /etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml
	sed -i 's%.*log_mode.*%log_mode: stdout%' /etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml
	systemctl disable crowdsec-firewall-bouncer.service
	service crowdsec-firewall-bouncer restart

fi

if [ $DESKTOP -eq 1 ]; then

	if dpkg -s mesa-utils &>/dev/null
	then

		echo "PREREQUISITES DESKTOP IS OK ✅"

	else

		echo "🔧 INSTALL PREREQUISITES DESKTOP"
		apt install input-remapper mesa-utils vlc -y

	fi

	if dpkg -s chromium &>/dev/null
	then
		echo "CHROMIUM IS OK ✅"
		tee /etc/chromium.d/hardware-acceleration >/dev/null <<EOF
CHROMIUM_FLAGS="\$CHROMIUM_FLAGS \
--ignore-gpu-blocklist \
--enable-accelerated-video-decode"
EOF
	else
		echo "🔧 INSTALL CHRIMIUM"
		apt install chromium chromium-l10n chromium-driver intel-media-va-driver-non-free libva-drm2 libva-x11-2 -y
		tee /etc/chromium.d/hardware-acceleration >/dev/null <<EOF
CHROMIUM_FLAGS="\$CHROMIUM_FLAGS \
--ignore-gpu-blocklist \
--enable-accelerated-video-decode"
EOF
	fi

	if dpkg -s firefox-esr &>/dev/null
	then

		echo "FIREFOX IS OK ✅"

		echo "🔧 Scan des utilisateurs dans /home..."

		### CONFIGURATION UTILISATEURS DE FIREFOX ###

		# Fonction pour définir ou mettre à jour une préférence
		set_pref () {
			local file="$1"
			local name="$2"
			local value="$3"

			if grep -q "user_pref(\"$name\"" "$file" 2>/dev/null; then
				sed -i "s|user_pref(\"$name\".*|user_pref(\"$name\", $value);|" "$file"
			else
				echo "user_pref(\"$name\", $value);" >> "$file"
			fi
		}

		# Vérifier que Firefox n'est pas lancé
		if pgrep -x firefox > /dev/null; then
			echo "⚠ FIREFOX EST EN COURS D'EXECUTION. MERCI DE LE FERMER AVANT."
			exit 1
		fi

		# Parcours des utilisateurs
		for USER_HOME in /home/*; do

			[ -d "$USER_HOME" ] || continue

			USERNAME=$(basename "$USER_HOME")
			FIREFOX_DIR="$USER_HOME/.mozilla/firefox"

			if [ ! -d "$FIREFOX_DIR" ]; then
				echo "ℹ️ PAS DE PROFIL FIREFOX POUR $USERNAME"
				continue
			fi

			echo "🔧 UTILISATEUR : $USERNAME"

			# Parcours des profils Firefox
			find "$FIREFOX_DIR" -maxdepth 1 -type d | while read -r PROFILE; do

				# Exclure dossiers inutiles
				case "$PROFILE" in
					*Crash\ Reports*|*Pending\ Pings*)
						continue
						;;
				esac

				# Vérifier que c'est bien un profil (présence prefs.js)
				if [ -f "$PROFILE/prefs.js" ]; then

					echo "🔧 Profil : $PROFILE"

					USERJS="$PROFILE/user.js"

					# Créer user.js avec les bons droits
					touch "$USERJS"
					chown "$USERNAME":"$USERNAME" "$USERJS"

					# Appliquer les préférences
					set_pref "$USERJS" "browser.tabs.loadBookmarksInTabs" "true"
					set_pref "$USERJS" "browser.search.openintab" "true"

					# Remettre les droits au propre
					chown "$USERNAME":"$USERNAME" "$USERJS"

				fi

			done

		done

		echo "✅ CONFIGURATION FIREFOX APPLIQUEE A TOUS LES UTILISATEURS"

		### CONFIGURATION SYSTEME DE FIREFOX ###

		FILE="/usr/lib/firefox-esr/distribution/policies.json"

		# Créer le dossier si nécessaire
		mkdir -p "$(dirname "$FILE")"

		# Si le fichier n'existe pas, on le crée proprement
		if [ ! -f "$FILE" ]; then
			cat <<EOF > "$FILE"
{
  "policies": {
    "Preferences": {}
  }
}
EOF
		fi

		# Vérifier que jq est installé
		if ! command -v jq >/dev/null 2>&1; then
			echo "❌ jq est requis. Installe-le avec : apt install jq"
			exit 1
		fi

		TMP=$(mktemp)

		# Mise à jour du JSON proprement avec jq
		jq '
		.policies = (.policies // {}) |
		.policies.Preferences = (.policies.Preferences // {}) |

		.policies.Preferences["browser.tabs.loadBookmarksInTabs"] = {
		  "Value": true,
		  "Status": "locked"
		} |

		.policies.Preferences["browser.search.openintab"] = {
		  "Value": true,
		  "Status": "locked"
		}
		' "$FILE" > "$TMP"

		# Remplacer proprement
		mv "$TMP" "$FILE"

		# Permissions
		chown root:root "$FILE"
		chmod 644 "$FILE"

		echo "✅ Policies Firefox ESR mises à jour avec succès"

	else

		echo "🔧 INSTALL FIREFOX"
		apt install firefox-esr firefox-esr-l10n-fr -y

	fi

	if dpkg -s geany &>/dev/null
	then

		echo ""
		echo "GEANY IS OK ✅"

	else

		echo "🔧 INSTALL GEANY"
		apt install geany geany-plugin-addons -y

	fi

	if dpkg -s flatpak &>/dev/null
	then
		echo "FLATPAK IS OK ✅"
		if flatpak info com.github.dail8859.NotepadNext &>/dev/null
		then
			echo "NOTEPADNEXT IS OK ✅"
		else
			echo "🔧 INSTALL NOTEPADNEXT"
			flatpak install flathub com.github.dail8859.NotepadNext -y
		fi
	else
		echo "🔧 INSTALL FLATPAK"
		apt install flatpak -y
		flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
	fi

	if command -v guake >/dev/null 2>&1; then
		echo "GUAKE OK ✅"
		GUAKE_BIN="$(command -v guake)"
		if update-alternatives --list x-terminal-emulator 2>/dev/null | grep -qx "$GUAKE_BIN"; then
			update-alternatives --set x-terminal-emulator "$GUAKE_BIN"
		else
			update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$GUAKE_BIN" 60
			update-alternatives --set x-terminal-emulator "$GUAKE_BIN"
		fi
	else
		echo "🔧 INSTALL GUAKE"
		apt install -y guake
	fi

	if command -v kitty >/dev/null 2>&1; then
		echo "KITTY OK ✅"
		KITTY_BIN="$(command -v kitty)"
		if update-alternatives --list x-terminal-emulator 2>/dev/null | grep -qx "$KITTY_BIN"; then
			update-alternatives --set x-terminal-emulator "$KITTY_BIN"
		else
			update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$KITTY_BIN" 60
			update-alternatives --set x-terminal-emulator "$KITTY_BIN"
		fi
	else
		echo "🔧 INSTALL KITTY"
		apt install -y kitty

	fi

	if dpkg -s nextcloud-desktop &>/dev/null
	then
		echo "NEXTCLOUD DESKTOP IS OK ✅"
	else
		echo "🔧 INSTALL NEXTCLOUD DESKTOP"
		apt install nextcloud-desktop nextcloud-desktop-doc nextcloud-desktop-l10n -y
	fi

	if dpkg -s remmina-plugin-rdp &>/dev/null
	then

		echo "REMMINA DESKTOP IS OK ✅"

	else

		echo "🔧 INSTALL REMMINA"
		apt install remmina-plugin-rdp -y

	fi

	TABBY_VERSION=$(git -c 'versionsort.suffix=-' \
    ls-remote --tags --sort='v:refname' https://github.com/Eugeny/tabby.git \
    | awk '!/\^\{\}$/ {sub(/^.*refs\/tags\/v/, ""); print}' \
    | tail -n1)
	if test -f /root/tabby-${TABBY_VERSION}-linux-x64.deb; then

		echo "TABBY_VERSION($TABBY_VERSION) IS OK ✅"		

	else

		echo "🔧 INSTALL TABBY ($TABBY_VERSION)"
		curl -fOL "https://github.com/Eugeny/tabby/releases/download/v${TABBY_VERSION}/tabby-${TABBY_VERSION}-linux-x64.deb"
		dpkg -i /root/tabby-${TABBY_VERSION}-linux-x64.deb

	fi

	if command -v tabby >/dev/null 2>&1; then
		TABBY_BIN="$(command -v tabby)"
		
		# Vérifie si Tabby est déjà enregistré comme alternative
		if update-alternatives --list x-terminal-emulator 2>/dev/null | grep -qx "$TABBY_BIN"; then
			update-alternatives --set x-terminal-emulator "$TABBY_BIN"
		else
			update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$TABBY_BIN" 70
			update-alternatives --set x-terminal-emulator "$TABBY_BIN"
		fi

	fi

	if [ $AMULE -eq 1 ]; then

		if dpkg -s amule-utils-gui &>/dev/null
		then

			echo "AMULE OK ✅"

		else

			echo "🔧 INSTALL AMULE"
			apt install amule amule-utils-gui -y

		fi

  fi

	if [ $VSCODE -eq 1 ]; then

		if dpkg -s code &>/dev/null
		then

			echo "VISUAL STUDIO CODE OK ✅"

		else

			echo "🔧 INSTALL VISUAL STUDIO CODE"
			apt install code -y

		fi

		if command -v code >/dev/null 2>&1; then
			CODE_BIN="$(command -v code)"

			# Vérifie si VS Code est déjà enregistré comme alternative
			if update-alternatives --list editor 2>/dev/null | grep -qx "$CODE_BIN"; then
				update-alternatives --set editor "$CODE_BIN"
				xdg-mime default code.desktop text/plain
			else
				update-alternatives --install /usr/bin/editor editor "$CODE_BIN" 70
				update-alternatives --set editor "$CODE_BIN"
				xdg-mime default code.desktop text/plain
			fi

		fi

	fi

	if [ $DESKTOP_GUI == "GNOME" ]
	then

		if dpkg -s smbclient &>/dev/null
		then

			echo "SAMBA CLIENT IS OK ✅"

		else

			echo "🔧 INSTALL SAMBA CLIENT"
			apt install cifs-utils smbclient -y

		fi

		if dpkg -s gnome-software-plugin-flatpak &>/dev/null
		then

			echo "GNOME SOFTWARE PLUGIN FLATPAK IS OK ✅"

		else

			echo "🔧 INSTALL GNOME SOFTWARE PLUGIN FLATPAK"
			apt install gnome-software-plugin-flatpak -y

		fi

		if dpkg -s gparted &>/dev/null
		then

			echo "GPARTED IS OK ✅"

		else

			echo "🔧 INSTALL GPARTED"
			apt install gparted -y

		fi

		if dpkg -s nautilus-nextcloud &>/dev/null
		then

			echo "NEXTCLOUD FOR NAUTILUS IS OK ✅"

		else

			echo "🔧 INSTALL NEXTCLOUD FOR NAUTILUS"
			apt install nautilus-nextcloud -y

		fi

		if dpkg -s wmctrl &>/dev/null
		then

			echo "WMCTRL IS OK ✅"

		else

			echo "🔧 INSTALL WMCTRL"
			apt install wmctrl -y

		fi

		if dpkg -s x11-utils &>/dev/null
		then

			echo "X11-UTILS IS OK ✅"

		else

			echo "🔧 INSTALL X11-UTILS"
			apt install x11-utils -y

		fi

		if dpkg -s xdotool &>/dev/null
		then

			echo "XDOTOOL IS OK ✅"

		else

			echo "🔧 INSTALL XDOTOOL"
			apt install xdotool -y

		fi

    if [ $AMULE -eq 1 ]; then

      if dpkg -s amule-gnome-support &>/dev/null
      then

        echo "AMULE OK ✅"

      else

        echo "🔧 INSTALL AMULE"
        apt install amule-gnome-support -y

      fi

    fi

	fi

fi

if [ $ENV_DEVOPS -eq 1 ]
then

	echo ""
	groupadd -f $ENV_DEVOPS_GROUP

	if id -u $ENV_DEVOPS_USER> /dev/null 2>&1 
	then
	  echo "USER FOR DEVOPS $ENV_DEVOPS_USER IS OK ✅"
	  echo "$ENV_DEVOPS_USER:$ENV_DEVOPS_PASSWORD" | chpasswd
	else
	  useradd -m $ENV_DEVOPS_USER --gid $ENV_DEVOPS_GROUP -s /bin/bash
	  echo "$ENV_DEVOPS_USER:$ENV_DEVOPS_PASSWORD" | chpasswd
	fi

	usermod -aG $ENV_DEVOPS_GROUP $ENV_DEVOPS_USER
	usermod -aG $ENV_DEVOPS_GROUP $ENV_HUMAN_USER

  if [[ "${ENV_DEVOPS_DOCKER_ROOTLESS:-0}" == "1" ]]; then
      # Rootless : l'utilisateur ENV_DEVOPS_USER NE doit PAS être dans le groupe docker
      if id -nG "$ENV_DEVOPS_USER" | grep -qw docker; then
          gpasswd -d "$ENV_DEVOPS_USER" docker
      fi
  else
      # Rootful : l'utilisateur ENV_DEVOPS_USER doit être dans le groupe docker
      if ! id -nG "$ENV_DEVOPS_USER" | grep -qw docker; then
          usermod -aG docker "$ENV_DEVOPS_USER"
      fi
  fi

  if [[ "${ENV_IA:-0}" == "0" ]]; then
      # l'utilisateur ENV_IA_USER NE doit pas être dans le groupe $ENV_DEVOPS_GROUP
      if id -nG "$ENV_IA_USER" | grep -qw "$ENV_DEVOPS_GROUP"; then
          gpasswd -d "$ENV_IA_USER" "$ENV_DEVOPS_GROUP"
      fi
  else
      # L'utilisateur ENV_IA_USER doit être dans le groupe ENV_DEVOPS_GROUP
      if ! id -nG "$ENV_IA_USER" | grep -qw "$ENV_DEVOPS_GROUP"; then
          usermod -aG "$ENV_DEVOPS_GROUP" "$ENV_IA_USER"
      fi
  fi

	echo "🔧 CONFIGURE /home/$ENV_DEVOPS_USER"
	if [ ! -d "/home/$ENV_DEVOPS_USER" ]; then
		mkhomedir_helper "$ENV_DEVOPS_USER"
	fi

	install -d -o "$ENV_DEVOPS_USER" -g "$ENV_DEVOPS_GROUP" -m 2770 "/home/$ENV_DEVOPS_USER/.local/npm" "/home/$ENV_DEVOPS_USER/.local/npm/bin" "/home/$ENV_DEVOPS_USER/.opencode/bin" "/home/$ENV_DEVOPS_USER/datas" "/home/$ENV_DEVOPS_USER/syncthing"

  if [ "${SYNCTHING}" = "1" ]; then
      cat > /home/devops/datas/.stignore <<'EOF'
# Dépôts Git
**/.git/

# Données OpenCode
**/.opencode/

# Cache OpenSpec
**/openspec/.cache/

# Journaux
**/*.log

# Fichiers temporaires
**/*.tmp
**/*~
**/.DS_Store
EOF
  fi

	if dpkg -s direnv &>/dev/null
	then

		echo "PREREQUISITES FOR DEVOPS IS OK ✅"

	else

		echo "🔧 INSTALL PREREQUISITES FOR DEVOPS"
		apt install build-essential curl direnv wget -y

	fi

	if [ "$GO" -eq 1 ]
	then

		GO_BASE="/home/$DEVOPS_USER/go"
		INSTALL_DIR="$GO_BASE/versions"
		CURRENT_LINK="$GO_BASE/current"
		GO_LATEST=$(git ls-remote --tags https://github.com/golang/go.git | awk -F/ '{print $3}' | sed 's/^go//' | grep -E '^[0-9]+\.[0-9]+(\.[0-9]+)?$' | sort -V | tail -1)
		
		mkdir -p "$INSTALL_DIR"

		if [ -L "$CURRENT_LINK" ]; then
			GO_CURRENT=$(basename "$(readlink -f "$CURRENT_LINK")")
			GO_CURRENT=${GO_CURRENT#go}
		else
			GO_CURRENT="none"
		fi

		TARGET_DIR="$INSTALL_DIR/go$GO_LATEST"

		if [ "$GO_CURRENT" != "$GO_LATEST" ]; then

			echo "🔧 INSTALL / UPDATE GO ($GO_LATEST vs $GO_CURRENT)"

			cd /tmp || exit 1

			ARCH="linux-amd64"
			FILE="go${GO_LATEST}.${ARCH}.tar.gz"
			URL="https://go.dev/dl/$FILE"

			rm -f "$FILE"

			if ! wget -q "$URL" -O "$FILE"; then
				echo "❌ Échec du téléchargement de $URL"
				rm -f "$FILE"
				exit 1
			fi

			if [ ! -s "$FILE" ]; then
				echo "❌ Le fichier téléchargé est vide"
				rm -f "$FILE"
				exit 1
        fi

			rm -rf "$TARGET_DIR"
			mkdir -p "$TARGET_DIR"

			if ! tar -C "$TARGET_DIR" --strip-components=1 -xzf "$FILE"; then
				echo "❌ Échec de l'extraction de Go"
				rm -rf "$TARGET_DIR"
				rm -f "$FILE"
				exit 1
			fi

			rm -f "$FILE"

			ln -sfn "$TARGET_DIR" "$CURRENT_LINK"

			chown -R "$DEVOPS_USER:$DEVOPS_GROUP" "$GO_BASE"

		else

			echo "GO OK ✅ ($GO_CURRENT)"

		fi

		cat > /etc/profile.d/go.sh <<'EOF'
# Go environment (managed by DIU)
export GOPATH="$HOME/go"
EOF

    chmod 644 /etc/profile.d/go.sh

    if [ "$TGPT" -eq 1 ]
    then

        REPO="https://github.com/aandrew-me/tgpt.git"
        BINARY="/home/$DEVOPS_USER/go/bin/tgpt"
        GO_BIN="/home/$DEVOPS_USER/go/current/bin/go"

        LATEST=$(
            git ls-remote --tags --refs "$REPO" |
            awk -F/ '{print $3}' |
            grep -E '^v?[0-9]+\.[0-9]+' |
            sort -V |
            tail -n 1 |
            sed -e 's/v//'
        )

        if [ -x "$BINARY" ]; then
            LOCAL=$("$BINARY" --version 2>/dev/null | awk '{print $NF}')
        else
            LOCAL="none"
        fi

        if [ "$LOCAL" != "$LATEST" ]; then

            echo "🔧 INSTALL / UPDATE TGPT"

            apt install libx11-dev libxmu-dev libxtst-dev -y

            if su - "$DEVOPS_USER" -c \
                "\"$GO_BIN\" install github.com/aandrew-me/tgpt/v2@latest"
            then
                echo "✅ TGPT mis à jour avec succès ($LATEST)"
            else
                echo "❌ Erreur lors de la mise à jour"
            fi

        else

            echo "TGPT OK ✅ ($LATEST)"

        fi

    fi

	fi

  if [ "$NODEJS" -eq 1 ]
  then

    NODE_BASE="/home/$DEVOPS_USER/node"
    INSTALL_DIR="$NODE_BASE/versions"
    CURRENT_LINK="$NODE_BASE/current"

    #
    # Recherche de la dernière version Node.js disponible
    # dans la série définie par NODEJS_SERIES.
    #
    # Exemple :
    # NODEJS_SERIES="24"
    #

    NODE_INDEX="https://nodejs.org/dist/index.tab"

    NODE_LATEST="$(
        curl -fsSL "$NODE_INDEX" |
        awk -v series="v${NODEJS_SERIES}." '
            NR > 1 && index($1, series) == 1 {
                version=$1
                sub(/^v/, "", version)
                print version
            }
        ' |
        sort -V |
        tail -n 1
    )"

    if [ -z "$NODE_LATEST" ]
    then

        echo "❌ Impossible de déterminer la dernière version Node.js ${NODEJS_SERIES}.x"
        exit 1

    fi

    mkdir -p "$INSTALL_DIR"

    #
    # Détection de la version DevOps actuellement active
    #

    if [ -x "$CURRENT_LINK/bin/node" ]
    then

        NODE_CURRENT="$(
            "$CURRENT_LINK/bin/node" --version 2>/dev/null |
            sed 's/^v//'
        )"

    else

        NODE_CURRENT="none"

    fi

    TARGET_DIR="$INSTALL_DIR/node-v${NODE_LATEST}"

    #
    # Installation / mise à jour
    #

    if [ "$NODE_CURRENT" != "$NODE_LATEST" ]
    then

        echo "🔧 INSTALL / UPDATE NODE.JS ($NODE_LATEST vs $NODE_CURRENT)"

        cd /tmp || exit 1

        ARCH="linux-x64"
        FILE="node-v${NODE_LATEST}-${ARCH}.tar.xz"
        URL="https://nodejs.org/dist/v${NODE_LATEST}/${FILE}"

        rm -f "$FILE"

        if ! wget -q "$URL" -O "$FILE"
        then

            echo "❌ Échec du téléchargement de $URL"
            rm -f "$FILE"
            exit 1

        fi

        if [ ! -s "$FILE" ]
        then

            echo "❌ Le fichier téléchargé est vide"
            rm -f "$FILE"
            exit 1

        fi

        rm -rf "$TARGET_DIR"
        mkdir -p "$TARGET_DIR"

        if ! tar \
            -C "$TARGET_DIR" \
            --strip-components=1 \
            -xJf "$FILE"
        then

            echo "❌ Échec de l'extraction de Node.js"
            rm -rf "$TARGET_DIR"
            rm -f "$FILE"
            exit 1

        fi

        rm -f "$FILE"

        ln -sfn "$TARGET_DIR" "$CURRENT_LINK"

        chown -R "$DEVOPS_USER:$DEVOPS_GROUP" "$NODE_BASE"

    else

        echo "NODE.JS OK ✅ ($NODE_CURRENT)"

    fi

    #
    # Binaires Node.js / npm DevOps
    #

    NODE_BIN="$CURRENT_LINK/bin/node"
    NPM_BIN="$CURRENT_LINK/bin/npm"
    NPX_BIN="$CURRENT_LINK/bin/npx"

    if [ ! -x "$NODE_BIN" ]
    then

        echo "❌ ERREUR : Node.js DevOps est introuvable ($NODE_BIN)"
        exit 1

    fi

    if [ ! -x "$NPM_BIN" ]
    then

        echo "❌ ERREUR : npm DevOps est introuvable ($NPM_BIN)"
        exit 1

    fi

    #
    # Configuration du préfixe npm propre à devops
    #

    install -d \
        -o "$DEVOPS_USER" \
        -g "$DEVOPS_GROUP" \
        -m 2770 \
        "/home/$DEVOPS_USER/.local/npm" \
        "/home/$DEVOPS_USER/.local/npm/bin"

    if ! su - "$DEVOPS_USER" -c \
        "PATH=\"/home/$DEVOPS_USER/node/current/bin:\$PATH\" \
        \"$NPM_BIN\" config set prefix \"\$HOME/.local/npm\" --location=user"
    then

        echo "❌ ERREUR : configuration du préfixe npm échouée"
        exit 1

    fi

    #
    # Configuration npm
    #

      cat > /etc/profile.d/npm.sh <<'EOF'
# NPM environment (managed by DIU)
export NPM_CONFIG_PREFIX="$HOME/.local/npm"
EOF

      chmod 644 /etc/profile.d/npm.sh

      #
      # Vérification finale
      #

      NODE_VERSION="$("$NODE_BIN" --version)"
      NPM_VERSION="$("$NPM_BIN" --version)"
      NPM_PREFIX="$(
          su - "$DEVOPS_USER" -c \
          "PATH=\"/home/$DEVOPS_USER/node/current/bin:\$PATH\" \
          \"$NPM_BIN\" config get prefix"
      )"

      echo "NODE.JS OK ✅ ($NODE_VERSION)"
      echo "NPM OK ✅ ($NPM_VERSION)"
      echo "NPM PREFIX OK ✅ ($NPM_PREFIX)"

  fi

	if [ "$OPENCODE" -eq 1 ]
	then

		OPENCODE_USER=$DEVOPS_USER
		INSTALL_DIR="/home/${OPENCODE_USER}/.opencode/bin"
		API="https://api.github.com/repos/anomalyco/opencode/releases/latest"
		INSTALLER="https://opencode.ai/install"

		# Version installée
		if [ -x "${INSTALL_DIR}/opencode" ]; then
			INSTALLED=$("${INSTALL_DIR}/opencode" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
		else
			INSTALLED=""
		fi

		# Récupération de la dernière version disponible
		LATEST=$(curl -fsSL "$API" | sed -n 's/.*"tag_name": *"v\([^"]*\)".*/\1/p')

		if [[ "$INSTALLED" != "$LATEST" ]]; then

			echo "🔧 INSTALL/UPGRADE OPENCODE"
			su - "${OPENCODE_USER}" -c "curl -fsSL ${INSTALLER} | bash -s -- --no-modify-path"
			chmod +x "${INSTALL_DIR}/opencode"

		else

			echo "OPENCODE OK ✅ ($LATEST)"

		fi

    # Nettoyage de l'ancien PATH
    rm -f /etc/profile.d/opencode.sh

	fi

  if [ "$OPENSPEC" -eq 1 ]
  then

      OPENSPEC_PACKAGE="@fission-ai/openspec"
      OPENSPEC_BIN="/home/$DEVOPS_USER/.local/npm/bin/openspec"

      # Vérification de npm
      NPM_BIN="/home/$DEVOPS_USER/node/current/bin/npm"

      if [ -z "$NPM_BIN" ] || [ ! -x "$NPM_BIN" ]
      then

          echo "❌ ERREUR : npm est introuvable pour l'utilisateur $DEVOPS_USER"
          exit 1

      fi

      # Recherche de la dernière version disponible d'OpenSpec
      OPENSPEC_LATEST="$(
          su - "$DEVOPS_USER" -c \
          "PATH=\"/home/$DEVOPS_USER/node/current/bin:\$PATH\" \
          \"$NPM_BIN\" view '$OPENSPEC_PACKAGE' version" 2>/dev/null
      )"

      if [ -z "$OPENSPEC_LATEST" ]
      then

        echo "❌ ERREUR : impossible de récupérer la dernière version d'OpenSpec"
        exit 1

      fi

      # Détection de la version actuellement installée
      if [ -x "$OPENSPEC_BIN" ]
      then

        OPENSPEC_CURRENT="$(
            PATH="/home/$DEVOPS_USER/node/current/bin:$PATH" \
            "$OPENSPEC_BIN" --version 2>/dev/null |
            grep -oE '[0-9]+\.[0-9]+\.[0-9]+' |
            head -n 1
        )"

      else

        OPENSPEC_CURRENT="none"

      fi

      # Installation / mise à jour
      if [ "$OPENSPEC_CURRENT" != "$OPENSPEC_LATEST" ]
      then

        echo "🔧 INSTALL/UPDATE OPENSPEC ($OPENSPEC_CURRENT → $OPENSPEC_LATEST)"

        if ! su - "$DEVOPS_USER" -c \
            "PATH=\"/home/$DEVOPS_USER/node/current/bin:\$PATH\" \
            \"$NPM_BIN\" install -g '$OPENSPEC_PACKAGE@$OPENSPEC_LATEST' \
            --allow-scripts='$OPENSPEC_PACKAGE' \
            --no-fund \
            --no-audit"
        then
            echo "❌ ERREUR : installation d'OpenSpec échouée"
            exit 1
        fi

      fi

      # Vérification finale d'OpenSpec
      if [ -x "$OPENSPEC_BIN" ]
      then

          # Création de la configuration OpenSpec
          su - "$DEVOPS_USER" -c \
              "mkdir -p /home/$DEVOPS_USER/.config/openspec"

          cat > "/home/$DEVOPS_USER/.config/openspec/config.json" <<'EOF'
{
  "featureFlags": {},
  "profile": "custom",
  "delivery": "both",
  "telemetry": {
    "enabled": true,
    "noticeSeen": true
  },
  "workflows": [
    "explore",
    "propose",
    "new",
    "continue",
    "apply",
    "verify",
    "update",
    "sync",
    "archive"
  ]
}
EOF

          chown "$DEVOPS_USER:$DEVOPS_GROUP" \
              "/home/$DEVOPS_USER/.config/openspec/config.json"

          chmod 660 \
              "/home/$DEVOPS_USER/.config/openspec/config.json"

          OPENSPEC_VERSION="$(
              PATH="/home/$DEVOPS_USER/node/current/bin:$PATH" \
              "$OPENSPEC_BIN" --version
          )"

          echo "OPENSPEC OK ✅ ($OPENSPEC_VERSION)"

      else

          echo "❌ ERREUR : commande openspec introuvable"
          exit 1

      fi

  fi

	if [ "$PYTHON" -eq 1 ]
	then

		if ! command -v /usr/bin/python3 >/dev/null 2>&1; then
			echo "🔧 INSTALL PYTHON 3 SYSTEM"
			sudo apt update
			sudo apt install -y python3 python3-pip python3-venv
		else
			PYTHON_SYSTEM_VERSION=$(/usr/bin/python3 --version | awk '{print $2}')
			echo "PYTHON 3 SYSTEM OK ✅ ($PYTHON_SYSTEM_VERSION)"
		fi

		INSTALL_PYTHON_ROOT="/home/$DEVOPS_USER/python"
		BUILD_DIR="/usr/local/src/python-build"

		mkdir -p "$INSTALL_PYTHON_ROOT" "$BUILD_DIR"

		#
		# Recherche de la dernière version de la série demandée.
		# Exemple : PYTHON_SERIES=3.14
		# https://www.python.org/downloads/
		#
		PYTHON_SERIES_REGEX="${PYTHON_SERIES//./\\.}"
		PYTHON_LATEST="$(curl -fsSL "https://www.python.org/ftp/python/" | grep -oE "${PYTHON_SERIES_REGEX}\.[0-9]+/" |	tr -d '/' |	sort -V | tail -n 1)"

		if [ -z "$PYTHON_LATEST" ]; then
			echo "❌ Impossible de déterminer la dernière version Python ${PYTHON_SERIES}.x"
			exit 1
		fi

		PY_SHORT="$(printf '%s' "$PYTHON_LATEST" | cut -d. -f1,2)"
		PYTHON_CURRENT=""

		if [ -x "$INSTALL_PYTHON_ROOT/current/bin/python3" ]; then
			PYTHON_CURRENT="$(
				"$INSTALL_PYTHON_ROOT/current/bin/python3" --version |
				awk '{print $2}'
			)"
		fi


		if [ "$PYTHON_CURRENT" != "$PYTHON_LATEST" ]; then

			echo "🔧 INSTALL/UPDATE PYTHON 3 DEV ($PYTHON_LATEST vs $PYTHON_CURRENT)"

			apt install -y build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libncurses-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

			cd "$BUILD_DIR"

			rm -rf "Python-${PYTHON_LATEST}"*
			wget -q "https://www.python.org/ftp/python/${PYTHON_LATEST}/Python-${PYTHON_LATEST}.tgz"

			tar -xf "Python-${PYTHON_LATEST}.tgz"
			cd "Python-${PYTHON_LATEST}"

			./configure --prefix="${INSTALL_PYTHON_ROOT}/${PYTHON_LATEST}" --enable-optimizations --with-ensurepip=install

			make -j"$(nproc)"

			env PATH="${INSTALL_PYTHON_ROOT}/${PYTHON_LATEST}/bin:${PATH}" PIP_ROOT_USER_ACTION=ignore make altinstall

			ln -sfn "${INSTALL_PYTHON_ROOT}/${PYTHON_LATEST}" "${INSTALL_PYTHON_ROOT}/current"

			rm -rf "$BUILD_DIR/Python-${PYTHON_LATEST}"

		else

			echo "PYTHON 3 DEV OK ✅ ($PYTHON_CURRENT)"

		fi

		ln -sf "${INSTALL_PYTHON_ROOT}/current/bin/python${PY_SHORT}" "${INSTALL_PYTHON_ROOT}/current/bin/python3"
		ln -sf "${INSTALL_PYTHON_ROOT}/current/bin/pip${PY_SHORT}" "${INSTALL_PYTHON_ROOT}/current/bin/pip3"

    cat > /etc/profile.d/python-dev.sh <<EOF
# Python Dev environment (managed by DIU)
export PYTHON_DEV_HOME="${INSTALL_PYTHON_ROOT}/current"
export PIP_ROOT_USER_ACTION=ignore
EOF

    chmod 644 /etc/profile.d/python-dev.sh

	fi

  chown -R $ENV_DEVOPS_USER:$ENV_DEVOPS_GROUP /home/$ENV_DEVOPS_USER
  find /home/$ENV_DEVOPS_USER -mindepth 1 -type d -exec chmod 2770 {} +
  find /home/$ENV_DEVOPS_USER -type f ! -name '.env*' ! -name '*.token' ! -name '*.username' -exec chmod 0770 {} +
  find /home/$ENV_DEVOPS_USER -type f \( -name '.env*' -o -name '*.token' -o -name '*.username' \) -exec chmod 0600 {} +

  ############################################################
  # DEVOPS PATH
  ############################################################

  DEVOPS_PROFILE="/etc/profile.d/zz-devops-path.sh"

  cat > "$DEVOPS_PROFILE" <<EOF
# DevOps environment PATH
# Managed by DIU

if [ "\$USER" = "$DEVOPS_USER" ]; then

    DEVOPS_PATH=""

EOF

  if [ "${PYTHON:-0}" -eq 1 ]; then
      cat >> "$DEVOPS_PROFILE" <<'EOF'
  DEVOPS_PATH="$HOME/python/current/bin"
EOF
  fi

  if [ "${GO:-0}" -eq 1 ]; then
      cat >> "$DEVOPS_PROFILE" <<'EOF'
  export GOPATH="$HOME/go"

  if [ -n "$DEVOPS_PATH" ]; then
      DEVOPS_PATH="$DEVOPS_PATH:$HOME/go/current/bin"
  else
      DEVOPS_PATH="$HOME/go/current/bin"
  fi
EOF
  fi

  if [ "${NODEJS:-0}" -eq 1 ]; then
      cat >> "$DEVOPS_PROFILE" <<'EOF'
  if [ -n "$DEVOPS_PATH" ]; then
      DEVOPS_PATH="$DEVOPS_PATH:$HOME/node/current/bin"
  else
      DEVOPS_PATH="$HOME/node/current/bin"
  fi
EOF
  fi

  cat >> "$DEVOPS_PROFILE" <<'EOF'

  # Outils communs DevOps
  if [ -n "$DEVOPS_PATH" ]; then
      DEVOPS_PATH="$DEVOPS_PATH:$HOME/.opencode/bin:$HOME/.local/npm/bin"
  else
      DEVOPS_PATH="$HOME/.opencode/bin:$HOME/.local/npm/bin"
  fi

  # PATH système
  export PATH="$DEVOPS_PATH:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games"
EOF

  if [ "${GO:-0}" -eq 1 ]; then
      cat >> "$DEVOPS_PROFILE" <<'EOF'

  # Binaires installés avec "go install"
  export PATH="$PATH:$GOPATH/bin"
EOF
  fi

  cat >> "$DEVOPS_PROFILE" <<'EOF'

  unset DEVOPS_PATH

fi
EOF

  chmod 644 "$DEVOPS_PROFILE"

fi

if [ $ENV_DOCKER -eq 1 ]
then

  echo ""
  groupadd -f $ENV_DOCKER_GROUP

  if id -u $ENV_DOCKER_USER> /dev/null 2>&1 
  then
    echo "USER FOR DOCKER $ENV_DOCKER_USER IS OK ✅"
    echo "$ENV_DOCKER_USER:$ENV_DOCKER_PASSWORD" | chpasswd
  else
    useradd -m $ENV_DOCKER_USER --gid $ENV_DOCKER_GROUP -s /bin/bash
    echo "$ENV_DOCKER_USER:$ENV_DOCKER_PASSWORD" | chpasswd
  fi

  usermod -aG $ENV_DOCKER_GROUP $ENV_DOCKER_USER
  usermod -aG $ENV_DOCKER_GROUP $ENV_HUMAN_USER

  if [[ "${ENV_DOCKER_DOCKER_ROOTLESS:-0}" == "1" ]]; then
      # Rootless : l'utilisateur ENV_DOCKER_USER NE doit PAS être dans le groupe docker
      if id -nG "$ENV_DOCKER_USER" | grep -qw docker; then
          gpasswd -d "$ENV_DOCKER_USER" docker
      fi
  else
      # Rootful : l'utilisateur ENV_DOCKER_USER DOIT être dans le groupe docker
      if ! id -nG "$ENV_DOCKER_USER" | grep -qw docker; then
          usermod -aG docker "$ENV_DOCKER_USER"
      fi
  fi

  echo "🔧 CONFIGURE /home/$ENV_DOCKER_USER"
  if [ ! -d "/home/$ENV_DOCKER_USER" ]; then
    mkhomedir_helper "$ENV_DOCKER_USER"
  fi

  install -d -o "$ENV_DOCKER_USER" -g "$ENV_DOCKER_GROUP" -m 2770 "/home/$ENV_DOCKER_USER/datas" "/home/$ENV_DOCKER_USER/proxy"

  su -c "mkdir -p proxy/dockhand-data" - $ENV_DOCKER_USER
  su -c "mkdir -p proxy/hawser-data" - $ENV_DOCKER_USER
  su -c "mkdir -p proxy/librespeed-data" - $ENV_DOCKER_USER
  su -c "mkdir -p proxy/myspeed-data" - $ENV_DOCKER_USER
  su -c "mkdir -p proxy/traefik-data/configurations" - $ENV_DOCKER_USER
  su -c "mkdir -p proxy/traefik-manager/backups" - $ENV_DOCKER_USER

  su -c "mkdir -p datas" - $ENV_DOCKER_USER
  su -c "mkdir -p datas/forgejo" - $ENV_DOCKER_USER
  su -c "mkdir -p datas/g4f-cookies" - $ENV_DOCKER_USER
  su -c "mkdir -p datas/g4f-medias" - $ENV_DOCKER_USER
  su -c "mkdir -p datas/meilisearch" - $ENV_DOCKER_USER
  su -c "mkdir -p datas/pgadmin" - $ENV_DOCKER_USER
  su -c "mkdir -p datas/postgres" - $ENV_DOCKER_USER
  su -c "mkdir -p datas/redis" - $ENV_DOCKER_USER
  su -c "mkdir -p inits/postgres" - $ENV_DOCKER_USER
  su -c "mkdir -p proxy/letsencrypt" - $ENV_DOCKER_USER
  su -c "touch proxy/.env" - $ENV_DOCKER_USER
  su -c "touch proxy/letsencrypt/acme.json" - $ENV_DOCKER_USER

  chown -R $ENV_DOCKER_USER:$ENV_DOCKER_GROUP /home/$ENV_DOCKER_USER
  find /home/$ENV_DOCKER_USER -mindepth 1 -type d -exec chmod 2770 {} +
  find /home/$ENV_DOCKER_USER -type f ! -name '.env*' ! -name '*.token' ! -name '*.username' -exec chmod 0770 {} +
  find /home/$ENV_DOCKER_USER -type f \( -name '.env*' -o -name '*.token' -o -name '*.username' \) -exec chmod 0660 {} +

  chown -R 1000:$ENV_DOCKER_GROUP /home/$ENV_DOCKER_USER/proxy/librespeed-data
  chmod 2770 /home/$ENV_DOCKER_USER
  chmod 2770 /home/$ENV_DOCKER_USER/datas
  chmod 2770 /home/$ENV_DOCKER_USER/proxy
  chmod 2770 /home/$ENV_DOCKER_USER/proxy/letsencrypt
  chmod 600 /home/$ENV_DOCKER_USER/proxy/.env
  chmod 600 /home/$ENV_DOCKER_USER/proxy/letsencrypt/acme.json
  chown -R 0:$ENV_DOCKER_GROUP /home/$ENV_DOCKER_USER/datas/meilisearch
  chown -R 999:$ENV_DOCKER_GROUP /home/$ENV_DOCKER_USER/datas/redis
  chown -R 999:$ENV_DOCKER_GROUP /home/$ENV_DOCKER_USER/datas/postgres
  chown -R 999:$ENV_DOCKER_GROUP /home/$ENV_DOCKER_USER/inits/postgres
  chown -R 1000:$ENV_DOCKER_GROUP /home/$ENV_DOCKER_USER/datas/forgejo
  chown -R 1200:$ENV_DOCKER_GROUP /home/$ENV_DOCKER_USER/datas/g4f-cookies
  chown -R 1200:$ENV_DOCKER_GROUP /home/$ENV_DOCKER_USER/datas/g4f-medias
  chown -R 5050:$ENV_DOCKER_GROUP /home/$ENV_DOCKER_USER/datas/pgadmin

  if [[ "${ACMESH:-0}" -eq 1 ]]; then

    CERT_DIR="${ACMESH_HOME}/${DNS_OVH_DOMAIN1}_ecc"
    DEST_DIR="/home/docker/proxy/letsencrypt"

    if [[ -d "${CERT_DIR}" ]]; then

      # Vérifie la présence des fichiers indispensables
      if [[ -f "${CERT_DIR}/fullchain.cer" && \
          -f "${CERT_DIR}/${DNS_OVH_DOMAIN1}.key" ]]; then

        mkdir -p "${DEST_DIR}/${DNS_OVH_DOMAIN1}"

        cp -f "${CERT_DIR}/fullchain.cer" "${DEST_DIR}/${DNS_OVH_DOMAIN1}/fullchain.pem"
        cp -f "${CERT_DIR}/${DNS_OVH_DOMAIN1}.key" "${DEST_DIR}/${DNS_OVH_DOMAIN1}/privkey.pem"
        cp -f "${CERT_DIR}/${DNS_OVH_DOMAIN1}.cer" "${DEST_DIR}/${DNS_OVH_DOMAIN1}/cert.pem"
        DEST_DIR="/home/docker/proxy/letsencrypt/${DNS_OVH_DOMAIN1}"
        chmod 2750 "${DEST_DIR}"
        setfacl -m u:101:rx "${DEST_DIR}"
        setfacl -m u:101:r "${DEST_DIR}/cert.pem"
        setfacl -m u:101:r "${DEST_DIR}/fullchain.pem"
        setfacl -m u:101:r "${DEST_DIR}/privkey.pem"
        echo "Certificats copiés vers ${DEST_DIR} ✅"

      else
        echo "❌ Les certificats du domaine ${DNS_OVH_DOMAIN1} sont incomplets dans ${CERT_DIR}"
      fi

    else
      echo "❌ Répertoire ACME.SH introuvable : ${CERT_DIR}"
    fi

  fi
  

	# En cas de de bug de mise à jour sur containerd.io faire un un Rollback.
	# Liste des version disponibles de containerd.io --> apt list -a containerd.io
	# Réinstaller une version plus ancienne --> apt install containerd.io=1.7.28-2~debian.13~trixie && apt-mark hold containerd.io
	# Réinstaller une version plus ancienne --> apt install containerd.io=1.7.28-1~debian.13~trixie && apt-mark hold containerd.io
	# Réinstaller une version plus ancienne --> apt install containerd.io=1.7.28-0~debian.13~trixie && apt-mark hold containerd.io
	# Réinstaller une version plus ancienne --> apt install containerd.io=1.7.27-1 && apt-mark hold containerd.io
	# Puis fixer le paquet containerd.io --> apt-mark hold containerd.io
	# Vérifier les paquets fixés --> apt-mark showhold
	# Quand le problème sera résolue Défixer le paquet containerd.io --> apt-mark unhold containerd.io

	if dpkg -s containerd.io &>/dev/null
	then

		echo "DOCKER IS OK ✅"

		if [ "$DOCKER_CONTAINERDIO_FIXED" = 0 ]
		then

			apt-mark showhold | grep -q containerd.io && apt-mark unhold containerd.io

		else

			echo "🔧 INSTALL DOCKER FIXED VERSION"
			apt install containerd.io=$DOCKER_CONTAINERDIO_FIXED_VERSION -y --allow-downgrades && apt-mark hold containerd.io
			apt install docker-ce docker-ce-cli docker-buildx-plugin docker-compose-plugin uidmap -y

		fi

	else

		if [ "$DOCKER_CONTAINERDIO_FIXED" = 0 ]
		then

			echo "🔧 INSTALL DOCKER"
			apt-mark unhold containerd.io
			apt install containerd.io docker-ce docker-ce-cli docker-buildx-plugin docker-compose-plugin uidmap -y
		else

			echo "🔧 INSTALL DOCKER FIXED VERSION"
			apt install containerd.io=$DOCKER_CONTAINERDIO_FIXED_VERSION -y --allow-downgrades && apt-mark hold containerd.io
			apt install docker-ce docker-ce-cli docker-buildx-plugin docker-compose-plugin uidmap -y
		fi

	fi

	echo '{' > /etc/docker/daemon.json
	echo '  "log-driver": "syslog",' >> /etc/docker/daemon.json
	echo '  "log-opts": {' >> /etc/docker/daemon.json
	echo '    "tag": "docker-{{.Name}}",' >> /etc/docker/daemon.json
	echo '    "mode": "non-blocking"' >> /etc/docker/daemon.json
	if [ $DRIVERS_NVIDIA == "1" ]
	then
		echo '  },' >> /etc/docker/daemon.json
		echo '  "runtimes": {' >> /etc/docker/daemon.json
		echo '    "nvidia": {' >> /etc/docker/daemon.json
		echo '      "args": [],' >> /etc/docker/daemon.json
		echo '      "path": "nvidia-container-runtime"' >> /etc/docker/daemon.json
		echo '    }' >> /etc/docker/daemon.json
		echo '  }' >> /etc/docker/daemon.json
	else
		echo '  }' >> /etc/docker/daemon.json
	fi
	echo '}' >> /etc/docker/daemon.json
	echo "DOCKER CONFIGURED ✅"

	DOCKER_COMPOSE_LAST_VERSION=`git -c 'versionsort.suffix=-' ls-remote --tags --sort='v:refname' https://github.com/docker/compose.git | sed -r '/v2|v5\.5|\{\}/d' | tail --lines=1 | cut --delimiter='/' --fields=3`
	if test -f /usr/local/bin/docker-compose ; then DOCKER_COMPOSE_VERSION=`docker-compose --version | sed -e 's/.* //'` ; else DOCKER_COMPOSE_VERSION=0 ; fi

	if [ "$DOCKER_COMPOSE_VERSION" = "$DOCKER_COMPOSE_LAST_VERSION" ]
	then

		echo "DOCKER-COMPOSE ($DOCKER_COMPOSE_LAST_VERSION) is OK ✅"

	else

		echo "🔧 INSTALL DOCKER-COMPOSE"
		# CHECK RELEASE NOTE --> https://github.com/docker/compose/releases
		curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_LAST_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
		chmod +x /usr/local/bin/docker-compose
		ln -f -s /usr/local/bin/docker-compose /usr/bin/docker-compose
		docker-compose --version

	fi
	
	# DIVE_VERSION=$(curl -sL "https://api.github.com/repos/wagoodman/dive/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
	DIVE_VERSION=`git -c 'versionsort.suffix=-' ls-remote --tags --sort='v:refname' https://github.com/wagoodman/dive.git | tail --lines=1 | sed -e 's/.*v//'`

	if test -f /root/dive_${DIVE_VERSION}_linux_amd64.deb
	then

		echo "DIVE ($DIVE_VERSION) is OK ✅"		

	else

		echo "🔧 INSTALL DIVE"
		curl -fOL "https://github.com/wagoodman/dive/releases/download/v${DIVE_VERSION}/dive_${DIVE_VERSION}_linux_amd64.deb"
		dpkg -i /root/dive_${DIVE_VERSION}_linux_amd64.deb

	fi

	if [ $DOCKER_STACK_BUNKERWEB -eq 1 ]
	then
		echo "🔧 CONFIGURE /home/$DOCKER_USER FOR BUNKERWEB DOCKHAND"
		if [ ! -d "/home/$DOCKER_USER" ]; then
			mkhomedir_helper $DOCKER_USER
		fi	
		su -c "mkdir -p proxy/bw-data" - $DOCKER_USER
		su -c "mkdir -p proxy/bw-data-cache/bunkernet" - $DOCKER_USER
		su -c "mkdir -p proxy/bw-data-cache/bunkerweb" - $DOCKER_USER
		su -c "mkdir -p proxy/bw-data-cache/crowdsec" - $DOCKER_USER
		su -c "mkdir -p proxy/bw-data-cache/jinja_cache" - $DOCKER_USER
		su -c "mkdir -p proxy/bw-data-cache/misc" - $DOCKER_USER
		su -c "mkdir -p proxy/bw-data-cache/realip" - $DOCKER_USER
		su -c "mkdir -p proxy/bw-db" - $DOCKER_USER
		su -c "mkdir -p proxy/nginx-data/conf.d" - $DOCKER_USER
		su -c "mkdir -p proxy/nginx-data/ssl" - $DOCKER_USER
		su -c "mkdir -p proxy/dockhand-data" - $DOCKER_USER
		su -c "mkdir -p proxy/hawser-data" - $DOCKER_USER
		chown -R $DOCKER_USER:$DOCKER_USER /home/$DOCKER_USER
		chmod -R 0777 /home/$DOCKER_USER/datas
		chmod -R 0777 /home/$DOCKER_USER/inits
		chown -R 101:101 /home/$DOCKER_USER/proxy/bw-data
		chown -R 101:101 /home/$DOCKER_USER/proxy/bw-data-cache
		chmod -R 0775 /home/$DOCKER_USER/proxy/bw-data
		chmod -R 0775 /home/$DOCKER_USER/proxy/bw-data-cache
		chmod 0775 -R /home/$DOCKER_USER/proxy/letsencrypt
		chmod 600 /home/$DOCKER_USER/proxy/letsencrypt/acme.json
	fi

	if [ $SSH -eq 1 ]
	then

		echo "🔧 CONFIGURE /home/$DOCKER_USER FOR OPENSSH SERVER"
		su -c "mkdir -p .ssh" - $DOCKER_USER
		su -c " touch .ssh/authorized_keys" - $DOCKER_USER
		su -c "echo $KEY_SSH_ADMIN > .ssh/authorized_keys" - $DOCKER_USER
		su -c "echo $KEY_SSH_ACME >> .ssh/authorized_keys" - $DOCKER_USER
		su -c "chmod 0700 .ssh/authorized_keys" - $DOCKER_USER

	fi

	if test $DOCKER_TREE_HOME -eq 1
	then

		if [ $DOCKER_STACK_BUNKERWEB -eq 1 ]
		then

			echo ""
			su -c "tree" - $DOCKER_USER

		fi

		if [ $DOCKER_STACK_TRAEFIK_DOCKHAND -eq 1 ]
		then

			echo ""
			su -c "tree -I \"datas|proxy\" /home/$DOCKER_USER && tree -L 2 -I \"nits|proxy\" /home/$DOCKER_USER && tree -L 4 -I \"inits|datas\" /home/$DOCKER_USER" - $DOCKER_USER

		fi

	fi

	if [ $DOCKER_STACK_BUNKERWEB -eq 1 ]
	then

		if [ $DOCKER_STACK_BUNKERWEB_UPGRADE -eq 1 ]
		then

			if [ $DOCKER_STACK_BUNKERWEB_AUTO_UPDATE -eq 1 ]
			then
				DOCKER_BUNKERWEB=`git ls-remote --tags --sort='v:refname' https://github.com/bunkerity/bunkerweb.git | sed -r '/-rc|\^/d' | tail --lines=1 | sed -e 's/.*v//'`
				DOCKER_BUNKERWEB_SCHEDULER=$DOCKER_BUNKERWEB
				DOCKER_BUNKERWEB_UI=$DOCKER_BUNKERWEB
			else
				DOCKER_BUNKERWEB=$DOCKER_STACK_BUNKERWEB_VERSION
				DOCKER_BUNKERWEB_SCHEDULER=$DOCKER_STACK_BUNKERWEB_VERSION
				DOCKER_BUNKERWEB_UI=$DOCKER_STACK_BUNKERWEB_VERSION
			fi
			DOCKER_DOZZLE=`git ls-remote --tags --sort='v:refname' https://github.com/amir20/dozzle.git | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/\^{}//'`
			DOCKER_OST=`git ls-remote --tags --sort='v:refname' https://github.com/openspeedtest/Docker-Image.git | tail --lines=1 | cut --delimiter='/' --fields=3`
			DOCKER_PORTAINER=`git ls-remote --tags --sort='v:refname' https://github.com/portainer/portainer.git | sed -r '/edge|internal|v/d' | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/\^{}//'`
			DOCKER_POSTGRESQL=`git ls-remote --tags --sort='v:refname' https://github.com/postgres/postgres.git | sed -r '/PG95|REL2_|REL6_|REL7_|REL8_|REL9_|REL_10_|REL_11_|REL_12_|REL_13_|REL_15_|REL_16_|REL_17_|REL_18_|BETA|RC|release|Release/d' | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/REL_//' | sed -e 's/_/./'`
			# DOCKER_POSTGRESQL=`git ls-remote --tags --sort='v:refname' https://github.com/postgres/postgres.git | sed -r '/PG95|REL2_|REL6_|REL7_|REL8_|REL9_|REL_10_|REL_11_|REL_12_|REL_13_|REL_14_|REL_16_|REL_17_|REL_18_|BETA|RC|release|Release/d' | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/REL_//' | sed -e 's/_/./'`
			# DOCKER_POSTGRESQL=`git ls-remote --tags --sort='v:refname' https://github.com/postgres/postgres.git | sed -r '/PG95|REL2_|REL6_|REL7_|REL8_|REL9_|REL_10_|REL_11_|REL_12_|REL_13_|REL_14_|REL_15_|REL_17_|REL_18_|BETA|RC|release|Release/d' | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/REL_//' | sed -e 's/_/./'`
			# DOCKER_POSTGRESQL=`git ls-remote --tags --sort='v:refname' https://github.com/postgres/postgres.git | sed -r '/PG95|REL2_|REL6_|REL7_|REL8_|REL9_|REL_10_|REL_11_|REL_12_|REL_13_|REL_14_|REL_15_|REL_16_|REL_18_|BETA|RC|release|Release/d' | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/REL_//' | sed -e 's/_/./'`
			DOCKER_WHOAMI=`git ls-remote --tags --sort='v:refname' https://github.com/traefik/whoami.git | tail --lines=1 | cut --delimiter='/' --fields=3`

			if [ -f "/home/$DOCKER_USER/proxy/docker-compose.yml" ]
			then

				echo ""
				echo "STOP THE STACK PROXY BUNKERWEB"
				su -c "docker-compose -f /home/$DOCKER_USER/proxy/docker-compose.yml down" - $DOCKER_USER

				echo ""
				echo "CONFIGURE THE STACK PROXY BUNKERWEB"
				sed -i "s%.*image: bunkerity/bunkerweb:.*%    image: bunkerity/bunkerweb:$DOCKER_BUNKERWEB%" /home/$DOCKER_USER/proxy/docker-compose.yml
				sed -i "s%.*image: bunkerity/bunkerweb-scheduler:.*%    image: bunkerity/bunkerweb-scheduler:$DOCKER_BUNKERWEB_SCHEDULER%" /home/$DOCKER_USER/proxy/docker-compose.yml
				sed -i "s%.*image: bunkerity/bunkerweb-ui:.*%    image: bunkerity/bunkerweb-ui:$DOCKER_BUNKERWEB_UI%" /home/$DOCKER_USER/proxy/docker-compose.yml
				sed -i "s%.*image: amir20/dozzle:.*%    image: amir20/dozzle:$DOCKER_DOZZLE%" /home/$DOCKER_USER/proxy/docker-compose.yml
				sed -i "s%.*image: openspeedtest/latest:.*%    image: openspeedtest/latest:$DOCKER_OST%" /home/$DOCKER_USER/proxy/docker-compose.yml
				sed -i "s%.*image: portainer/portainer-ce:.*%    image: portainer/portainer-ce:$DOCKER_PORTAINER%" /home/$DOCKER_USER/proxy/docker-compose.yml
				sed -i "s%.*image: postgres:.*%    image: postgres:$DOCKER_POSTGRESQL%" /home/$DOCKER_USER/proxy/docker-compose.yml
				sed -i "s%.*image: traefik/whoami:.*%    image: traefik/whoami:$DOCKER_WHOAMI%" /home/$DOCKER_USER/proxy/docker-compose.yml	

				if [ -f "/home/$DOCKER_USER/proxy/letsencrypt/ch-nontron.fr/cert.pem" ] || [ -f "/home/$DOCKER_USER/proxy/letsencrypt/hl-nontron.fr/cert.pem" ]
				then

					echo ""
					echo "START THE STACK PROXY BUNKERWEB"
					su -c "docker-compose -f /home/$DOCKER_USER/proxy/docker-compose.yml up -d" - $DOCKER_USER
					echo "..."
					# sleep 7

				else

					echo ""
					echo "###############################################"
					echo "# NO CERTIFICAT LET'S ENCRYPT ON THIS MACHINE #"
					echo "###############################################"
					exit 0

				fi

			else

				echo ""
				echo "MISSING STACK PROXY FILES (docker-compose.yml)"

			fi

		fi

	fi

	if [ $DOCKER_STACK_TRAEFIK_DOCKHAND -eq 1 ]
	then

		if [ -f "/home/$DOCKER_USER/proxy/docker-compose.yml" ] && [ -f "/home/$DOCKER_USER/proxy/traefik-data/static.yml" ] && [ -f "/home/$DOCKER_USER/proxy/traefik-data/configurations/dynamic.yml" ]
		then

			if [ $DOCKER_STACK_TRAEFIK_DOCKHAND_UPGRADE -eq 1 ]
			then

				echo "🔧 CHECK DOCKER IMAGE STACK PROXY TRAEFIK FOR UPGRADE"
				DOCKER_DOCKHAND=`git ls-remote --tags --sort='v:refname' https://github.com/Finsys/dockhand.git | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/\^{}//'`
				DOCKER_DOZZLE=`git ls-remote --tags --sort='v:refname' https://github.com/amir20/dozzle.git | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/\^{}//'`
				DOCKER_HAWSER=`git ls-remote --tags --sort='v:refname' https://github.com/Finsys/hawser.git | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/v//' | sed -e 's/\^{}//'`
				DOCKER_LIBRESPEED=`git ls-remote --tags --sort='v:refname' https://github.com/linuxserver/docker-librespeed.git | tail --lines=1 | cut --delimiter='/' --fields=3`
				DOCKER_MYSPEED=`git ls-remote --tags --sort='v:refname' https://github.com/gnmyt/myspeed.git | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/v//'`
				# DOCKER_OST=`git ls-remote --tags --sort='v:refname' https://github.com/openspeedtest/Docker-Image.git | tail --lines=1 | cut --delimiter='/' --fields=3`
        DOCKER_SOCKET_PROXY=`git ls-remote --tags --sort='v:refname' https://github.com/tecnativa/docker-socket-proxy.git | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/\^{}//'`
				DOCKER_TRAEFIK3=`git ls-remote --tags --sort='v:refname' https://github.com/traefik/traefik.git | sed -r '/v2/d' | sed -r '/-rc/d' | tail --lines=1 | cut --delimiter='/' --fields=3`
				DOCKER_TRAEFIK_MANAGER=`git ls-remote --tags --sort='v:refname' https://github.com/chr0nzz/traefik-manager.git | sed -r '/-rc/d' | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/v//'`
				DOCKER_WHOAMI=`git ls-remote --tags --sort='v:refname' https://github.com/traefik/whoami.git | tail --lines=1 | cut --delimiter='/' --fields=3`

				echo "🔧 STOP THE STACK PROXY TRAEFIK DOCKHAND"
				su -c "docker-compose -f /home/$DOCKER_USER/proxy/docker-compose.yml down" - docker

				echo "🔧 CONFIGURE THE STACK PROXY TRAEFIK DOCKHAND"
				sed -i "s%.*image: fnsys/dockhand:.*%    image: fnsys/dockhand:$DOCKER_DOCKHAND%" /home/$DOCKER_USER/proxy/docker-compose.yml
				sed -i "s%.*image: amir20/dozzle:.*%    image: amir20/dozzle:$DOCKER_DOZZLE%" /home/$DOCKER_USER/proxy/docker-compose.yml
				sed -i "s%.*image: ghcr.io/finsys/hawser:.*%    image: ghcr.io/finsys/hawser:$DOCKER_HAWSER%" /home/$DOCKER_USER/proxy/docker-compose.yml
				sed -i "s%.*image: linuxserver/librespeed:.*%    image: linuxserver/librespeed:$DOCKER_LIBRESPEED%" /home/$DOCKER_USER/proxy/docker-compose.yml
				sed -i "s%.*image: germannewsmaker/myspeed:.*%    image: germannewsmaker/myspeed:$DOCKER_MYSPEED%" /home/$DOCKER_USER/proxy/docker-compose.yml
				# sed -i "s%.*image: openspeedtest/latest:.*%    image: openspeedtest/latest:$DOCKER_OST%" /home/$DOCKER_USER/proxy/docker-compose.yml
				sed -i "s%.*image: tecnativa/docker-socket-proxy:.*%    image: tecnativa/docker-socket-proxy:$DOCKER_SOCKET_PROXY%" /home/$DOCKER_USER/proxy/docker-compose.yml
				sed -i "s%.*image: traefik:.*%    image: traefik:$DOCKER_TRAEFIK3%" /home/$DOCKER_USER/proxy/docker-compose.yml
				sed -i "s%.*image: ghcr.io/chr0nzz/traefik-manager:.*%    image: ghcr.io/chr0nzz/traefik-manager:$DOCKER_TRAEFIK_MANAGER%" /home/$DOCKER_USER/proxy/docker-compose.yml
				sed -i "s%.*image: traefik/whoami:.*%    image: traefik/whoami:$DOCKER_WHOAMI%" /home/$DOCKER_USER/proxy/docker-compose.yml


        if [ -f "/home/$DOCKER_USER/proxy/letsencrypt/$DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN/cert.pem" ]
        then

          echo "🔧 START THE STACK PROXY TRAEFIK DOCKHAND"
          su -c "docker-compose -f /home/$DOCKER_USER/proxy/docker-compose.yml up -d" - docker
          echo "..."

        else

          echo "❌ NO CERTIFICAT LET'S ENCRYPT ON THIS MACHINE IN /home/$DOCKER_USER/proxy/letsencrypt/$DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN"
          exit 0

        fi

      else

				echo "🔧 CONFIGURE THE STACK PROXY TRAEFIK DOCKHAND"
				sed -i "s%.*image: fnsys/dockhand:.*%    image: fnsys/dockhand:latest%" /home/$DOCKER_USER/proxy/docker-compose.yml
				sed -i "s%.*image: amir20/dozzle:.*%    image: amir20/dozzle:latest%" /home/$DOCKER_USER/proxy/docker-compose.yml
				sed -i "s%.*image: ghcr.io/finsys/hawser:.*%    image: ghcr.io/finsys/hawser:latest%" /home/$DOCKER_USER/proxy/docker-compose.yml
				sed -i "s%.*image: linuxserver/librespeed:.*%    image: linuxserver/librespeed:latest%" /home/$DOCKER_USER/proxy/docker-compose.yml
				sed -i "s%.*image: germannewsmaker/myspeed:.*%    image: germannewsmaker/myspeed:latest%" /home/$DOCKER_USER/proxy/docker-compose.yml
				#sed -i "s%.*image: openspeedtest/latest:.*%    image: openspeedtest/latest:latest%" /home/$DOCKER_USER/proxy/docker-compose.yml
				sed -i "s%.*image: tecnativa/docker-socket-proxy:.*%    image: tecnativa/docker-socket-proxy:latest%" /home/$DOCKER_USER/proxy/docker-compose.yml
				sed -i "s%.*image: traefik:.*%    image: traefik:latest%" /home/$DOCKER_USER/proxy/docker-compose.yml
				sed -i "s%.*image: ghcr.io/chr0nzz/traefik-manager:.*%    image: ghcr.io/chr0nzz/traefik-manager:latest%" /home/$DOCKER_USER/proxy/docker-compose.yml
				sed -i "s%.*image: traefik/whoami:.*%    image: traefik/whoami:latest%" /home/$DOCKER_USER/proxy/docker-compose.yml

			fi

		else

			echo "❌ MISSING FILES STACK PROXY TRAEFIK DOCKHAND (docker-compose.yml/static.yml/dynamic.yml)"

		fi

	fi

	if [ $DOCKER_PORTAINER_STACK_ELK -eq 1 ]
	then

		if [ $DOCKER_PORTAINER_STACK_ELK_UPGRADE -eq 1 ]
		then

			echo "STOP STACK ELK"
			sleep 11
			curl --request POST --insecure --write-out "%{http_code}" --url "https://localhost:9443/api/stacks/$DOCKER_PORTAINER_STACK_ELK_DC_ID/stop?endpointId=$DOCKER_PORTAINER_STACK_ELK_ENDPOINT_ID" --header "x-api-key:$DOCKER_PORTAINER_API_KEY"
			echo "..."
			echo ""
			sleep 11

			echo ""
			echo "CONFIGURE THE STACK ELK"
			echo ""
			DOCKER_ELASTICSEARCH=`git ls-remote --tags --sort='v:refname' https://github.com/elastic/elasticsearch.git | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/v//'`
			DOCKER_KIBANA=`git ls-remote --tags --sort='v:refname' https://github.com/elastic/kibana.git | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/v//'`
			sed -i "s%.*image: elasticsearch:.*%    image: elasticsearch:$DOCKER_ELASTICSEARCH%" /home/$DOCKER_USER/proxy/portainer-data/compose/$DOCKER_PORTAINER_STACK_ELK_DC_ID/docker-compose.yml
			sed -i "s%.*image: kibana:.*%    image: kibana:$DOCKER_KIBANA%" /home/$DOCKER_USER/proxy/portainer-data/compose/$DOCKER_PORTAINER_STACK_ELK_DC_ID/docker-compose.yml

			echo "START STACK ELK"
			curl --request POST --insecure --write-out "%{http_code}" --url "https://localhost:9443/api/stacks/$DOCKER_PORTAINER_STACK_ELK_DC_ID/start?endpointId=$DOCKER_PORTAINER_STACK_ELK_ENDPOINT_ID" --header "x-api-key:$DOCKER_PORTAINER_API_KEY"
			echo "..."
			echo ""
			sleep 11

		fi

	fi

	if [ $DOCKER_PORTAINER_STACK_NEXTCLOUD -eq 1 ]
	then

		if [ $DOCKER_PORTAINER_STACK_NEXTCLOUD_UPGRADE -eq 1 ]
		then

			echo "STOP STACK NEXTCLOUD"
			sleep 11
			curl --request POST --insecure --write-out "%{http_code}" --url "https://localhost:9443/api/stacks/$DOCKER_PORTAINER_STACK_NEXTCLOUD_DC_ID/stop?endpointId=$DOCKER_PORTAINER_STACK_NEXTCLOUD_ENDPOINT_ID" --header "x-api-key:$DOCKER_PORTAINER_API_KEY"
			echo "..."
			echo ""
			sleep 11

			echo ""
			echo "CONFIGURE THE STACK NEXTCLOUD"
			echo ""

			DOCKER_POSTGRESQL=`git ls-remote --tags --sort='v:refname' https://github.com/postgres/postgres.git | sed -r '/PG95|REL2_|REL6_|REL7_|REL8_|REL9_|REL_10_|REL_11_|REL_12_|REL_13_|REL_15_|REL_16_|REL_17_|REL_18_|BETA|RC|release|Release/d' | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/REL_//' | sed -e 's/_/./'`
			DOCKER_REDIS=`git ls-remote --tags --sort='v:refname' https://github.com/redis/redis.git | sed -r '/-beta|-deprecated|-int|-m|-playpen|-rc|-watch|twitter|v1|v2/d' | tail --lines=1 | cut --delimiter='/' --fields=3`
			DOCKER_NEXTCLOUD=`git ls-remote --tags --sort='v:refname' https://github.com/nextcloud/server.git | grep "v$DOCKER_PORTAINER_STACK_NEXTCLOUD_BRANCH" | sed -r '/\^\{\}|beta|rc/d' | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/v//'`
			DOCKER_NGINX=`git ls-remote --tags --sort='v:refname' https://github.com/nginx/nginx.git | sed -r '/\^\{\}|beta|rc/d' | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/release-//'`
			DOCKER_PGADMIN=`git ls-remote --tags --sort='v:refname' https://github.com/pgadmin-org/pgadmin4.git | sed -r '/\^\{\}|beta|rc/d' | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/REL-//' | sed -e 's/_/./'`
			DOCKER_COLLABORA=`git ls-remote --tags --sort='v:refname' https://github.com/CollaboraOnline/online.git | grep "cp-" | sed -r '/\^\{\}|android|beta|rc/d' | tail --lines=1 | cut --delimiter='/' --fields=3 | sed -e 's/cp-//' | sed -e 's/-/./'`
			sed -i "s%.*image: postgres:.*%    image: postgres:$DOCKER_POSTGRESQL%" /home/$DOCKER_USER/proxy/portainer-data/compose/$DOCKER_PORTAINER_STACK_NEXTCLOUD_DC_ID/docker-compose.yml
			sed -i "s%.*image: redis:.*%    image: redis:$DOCKER_REDIS%" /home/$DOCKER_USER/proxy/portainer-data/compose/$DOCKER_PORTAINER_STACK_NEXTCLOUD_DC_ID/docker-compose.yml
			sed -i "s%.*image: nextcloud:.*%    image: nextcloud:$DOCKER_NEXTCLOUD-fpm%" /home/$DOCKER_USER/proxy/portainer-data/compose/$DOCKER_PORTAINER_STACK_NEXTCLOUD_DC_ID/docker-compose.yml
			sed -i "s%.*image: nginx:.*%    image: nginx:$DOCKER_NGINX%" /home/$DOCKER_USER/proxy/portainer-data/compose/$DOCKER_PORTAINER_STACK_NEXTCLOUD_DC_ID/docker-compose.yml
			sed -i "s%.*image: dpage/pgadmin4:.*%    image: dpage/pgadmin4:$DOCKER_PGADMIN%" /home/$DOCKER_USER/proxy/portainer-data/compose/$DOCKER_PORTAINER_STACK_NEXTCLOUD_DC_ID/docker-compose.yml
			sed -i "s%.*image: collabora/code:.*%    image: collabora/code:$DOCKER_COLLABORA.1%" /home/$DOCKER_USER/proxy/portainer-data/compose/$DOCKER_PORTAINER_STACK_NEXTCLOUD_DC_ID/docker-compose.yml

			echo "START STACK NEXTCLOUD"
			curl --request POST --insecure --write-out "%{http_code}" --url "https://localhost:9443/api/stacks/$DOCKER_PORTAINER_STACK_NEXTCLOUD_DC_ID/start?endpointId=$DOCKER_PORTAINER_STACK_NEXTCLOUD_ENDPOINT_ID" --header "x-api-key:$DOCKER_PORTAINER_API_KEY"
			echo "..."
			echo ""
			sleep 11

		fi

	fi

	if [ $DOCKER_CLEAN -eq 1 ]
	then

		# echo ""
		# echo "DOCKER NETWORK PRUNE"
		# su -c "docker network prune -f" - docker

		echo ""
		echo "DOCKER SYSTEM DF BEFORE PRUNE"
		docker system df

		echo ""
		echo "DOCKER SYSTEM PRUNE"
		docker system prune -f -a --volumes

		echo ""
		echo "DOCKER SYSTEM DF AFTER PRUNE"
		docker system df

		echo ""
		echo "DOCKER PS"
		su -c "docker ps" - $DOCKER_USER

		# echo ""
		# echo 'DOCKER RMI $(DOCKER IMAGE -f "dangling=true"'
		# docker rmi $(docker images -f "dangling=true")

		echo ""
		echo "DOCKER IMAGE LS"
		su -c "docker image ls" - $DOCKER_USER

		echo ""
		echo "DOCKER NETWORK LS"
		su -c "docker network ls" - $DOCKER_USER

		echo ""
		echo "DOCKER VOLUME LS"
		su -c "docker volume ls" - $DOCKER_USER

	fi

	if [ $DOCKER_STACK_BUNKERWEB -eq 1 ]
	then

		if [ -f "/home/$DOCKER_USER/proxy/docker-compose.yml" ]
		then

			if [ -f "/home/$DOCKER_USER/proxy/letsencrypt/ch-nontron.fr/cert.pem" ] || [ -f "/home/$DOCKER_USER/proxy/letsencrypt/hl-nontron.fr/cert.pem" ]
			then

				if [ $DOCKER_STACK_BUNKERWEB_UPGRADE -eq 1 ]
				then

					echo ""
					echo "🔧 STOP DOCKER DOZZZLE/OST/PORTAINER/WHOAMI FOR PRODUCTION"
					su -c "docker stop dozzle && docker stop ost && docker stop portainer && docker stop whoami" - $DOCKER_USER

				fi

			fi

		fi

	fi

	if [ $DOCKER_STACK_TRAEFIK_DOCKHAND -eq 1 ]
	then

		if [ -f "/home/$DOCKER_USER/proxy/docker-compose.yml" ] && [ -f "/home/$DOCKER_USER/proxy/traefik-data/static.yml" ] && [ -f "/home/$DOCKER_USER/proxy/traefik-data/configurations/dynamic.yml" ]
		then

			if [ -f "/home/$DOCKER_USER/proxy/letsencrypt/$DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN/cert.pem" ]
			then

        if [ $DOCKER_STACK_TRAEFIK_DOCKHAND_UPGRADE -eq 1 ]
        then

          echo ""
          echo "🔧 STOP DOCKER DOCKHAND/DOZZZLE/HAWSER/LIBRESPEED/MYSPEED/SOCKET-PROXY/TRAEFIK-MANAGER/WHOAMI FOR PRODUCTION"
          su -c "docker stop dockhand && docker stop dozzle && docker stop hawser && docker stop librespeed && docker stop myspeed && docker stop socket-proxy && docker stop traefik-manager && docker stop whoami" - $DOCKER_USER

        fi

			else

        echo "❌ NO CERTIFICAT LET'S ENCRYPT ON THIS MACHINE IN /home/$DOCKER_USER/proxy/letsencrypt/$DOCKER_STACK_TRAEFIK_DOCKHAND_DOMAIN"
				exit 0

			fi

		fi

	fi

else

	if test -f "/home/$DOCKER_USER/proxy/docker-compose.yml"
	then

		if test -f /usr/bin/dockerd
		then

			echo ""
			echo "🔧 STOP THE STACK PROXY"
			su -c "docker-compose -f /home/$DOCKER_USER/proxy/docker-compose.yml down" - $DOCKER_USER

		fi

		DIVE_VERSION=$(curl -sL "https://api.github.com/repos/wagoodman/dive/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
		if test -f /root/dive_${DIVE_VERSION}_linux_amd64.deb
		then

			echo ""
			echo "🔧 UNINSTALL DIVE"
			apt purge dive -y
			rm -f /root/dive_${DIVE_VERSION}_linux_amd64.deb

		fi

		if test -f /usr/bin/dockerd
		then

			echo ""
			echo "🔧 REMOVE CONTAINER STOPPED"
			docker container prune

			echo ""
			echo "🔧 REMOVE IMAGE DOCKER"
			docker rmi $(docker images -q)

			echo ""
			echo "🔧 REMOVE SYSTEM DOCKER"
			docker system prune

			echo ""
			echo "🔧 UNINSTALL DOCKER"
			if test -f /etc/docker/daemon.json
			then

				rm -f /etc/docker/daemon.json

			fi
			apt purge containerd.io docker-ce docker-ce-cli docker-buildx-plugin docker-compose-plugin -y

		fi

		if test -f /usr/local/bin/docker-compose
		then

			echo ""
			echo "🔧 UNINSTALL DOCKER-COMPOSE"
			rm -f /usr/local/bin/docker-compose
			rm -f /usr/bin/docker-compose

		fi

		echo ""
		echo "🔧 UNINSTALL STACK PROXY"
		rm -R -f /home/docker/proxy

	fi

fi

if [ $ENV_IA -eq 1 ]
then

	echo ""
  groupadd -f $ENV_IA_GROUP
	if id -u $ENV_IA_USER> /dev/null 2>&1 
	then
	  echo "USER FOR IA $ENV_IA_USER IS OK ✅"
	  echo "$ENV_IA_USER:$ENV_IA_PASSWORD" | chpasswd
	else
	  useradd -m $ENV_IA_USER --gid $ENV_IA_GROUP -s /bin/bash
	  echo "$ENV_IA_USER:$ENV_IA_PASSWORD" | chpasswd
	fi

	usermod -aG $ENV_IA_GROUP $ENV_IA_USER
	usermod -aG $ENV_IA_GROUP $ENV_HUMAN_USER

  if [[ "${ENV_IA_DOCKER_ROOTLESS:-0}" == "1" ]]; then
      if ! id -nG "$ENV_IA_USER" | grep -qw docker; then
          usermod -aG docker "$ENV_IA_USER"
      fi
  else
      if id -nG "$ENV_IA_USER" | grep -qw docker; then
          gpasswd -d "$ENV_IA_USER" docker
      fi
  fi

	echo "🔧 CONFIGURE /home/$ENV_IA_USER"
	if [ ! -d "/home/$ENV_IA_USER" ]; then
		mkhomedir_helper "$ENV_IA_USER"
	fi

	install -d -o "$ENV_IA_USER" -g "$ENV_IA_GROUP" -m 2770 "/home/$ENV_IA_USER/download" "/home/$ENV_IA_USER/tools"

  chown -R $ENV_IA_USER:$ENV_IA_GROUP /home/$ENV_IA_USER
  find /home/$ENV_IA_USER -mindepth 1 -type d -exec chmod 2770 {} +
  find /home/$ENV_IA_USER -type f ! -name '.env*' ! -name '*.token'  ! -name '*.username' -exec chmod 0770 {} +
  find /home/$ENV_IA_USER -type f \( -name '.env*' -o -name '*.token' -o -name '*.username' \) -exec chmod 0660 {} +
  chown -R $ENV_IA_USER:$ENV_IA_GROUP /home/$ENV_IA_USER/hermes
  find /home/$ENV_IA_USER/hermes -mindepth 0 -type d -exec chmod 2770 {} + 
  find /home/$ENV_IA_USER/hermes -type f ! -name '.env*' ! -name '*.token'  ! -name '*.username' -exec chmod 0770 {} +
  find /home/$ENV_IA_USER/hermes -type f \( -name '.env*' -o -name '*.token' -o -name '*.username' \) -exec chmod 0666 {} +
  chown -R $ENV_IA_USER:$ENV_IA_GROUP /home/$ENV_IA_USER/download
  find /home/$ENV_IA_USER/download -mindepth 0 -type d -exec chmod 2770 {} + 
  find /home/$ENV_IA_USER/download -type f ! -name '.env*' ! -name '*.token'  ! -name '*.username' -exec chmod 0770 {} +
  find /home/$ENV_IA_USER/download -type f \( -name '.env*' -o -name '*.token' -o -name '*.username' \) -exec chmod 0666 {} +
  chown -R $ENV_IA_USER:$ENV_IA_GROUP /home/$ENV_IA_USER/tools
  find /home/$ENV_IA_USER/tools -mindepth 0 -type d -exec chmod 2770 {} + 
  find /home/$ENV_IA_USER/tools -type f ! -name '.env*' ! -name '*.token'  ! -name '*.username' -exec chmod 0770 {} +
  find /home/$ENV_IA_USER/tools -type f \( -name '.env*' -o -name '*.token' -o -name '*.username' \) -exec chmod 0666 {} +

  chmod 2770 /home/$ENV_IA_USER

fi

if [ $FASTFETCH -eq 1 ]
then

	if [ $DEBIAN_RELEASE = "bookworm" ] || [ $DEBIAN_RELEASE = "bullseye" ]
	then

		echo "INSTALL NEOFETCH"
		mkdir -p /root/.config/neofetch
		apt install neofetch -y

		echo "CONFIGURE NEOFETCH"
		neofetch
		touch /root/.config/neofetch/config.conf
		sed -i 's%.*info "CPU Usage" cpu_usage.*%    info "CPU Usage" cpu_usage%' /root/.config/neofetch/config.conf
		sed -i 's%.*info "Disk" disk.*%    info "Disk" disk%' /root/.config/neofetch/config.conf
		sed -i 's%.*info "Local IP" local_ip.*%    info "Local IP" local_ip%' /root/.config/neofetch/config.conf
		sed -i 's%.*memory_percent=.*%memory_percent="on"%' /root/.config/neofetch/config.conf
		sed -i 's%.*memory_unit=.*%memory_unit="mib"%' /root/.config/neofetch/config.conf
		sed -i 's%.*shell_path=.*%shell_path="on"%' /root/.config/neofetch/config.conf
		sed -i 's%.*speed_shorthand=.*%speed_shorthand="on"%' /root/.config/neofetch/config.conf
		sed -i 's%.*cpu_brand=.*%cpu_brand="on"%' /root/.config/neofetch/config.conf
		sed -i 's%.*cpu_speed=.*%cpu_speed="on"%' /root/.config/neofetch/config.conf
		sed -i 's%.*cpu_cores=.*%cpu_cores="logical"%' /root/.config/neofetch/config.conf
		sed -i 's%.*cpu_temp=.*%cpu_temp="on"%' /root/.config/neofetch/config.conf
		sed -i 's%.*disk_percent=.*%disk_percent="on"%' /root/.config/neofetch/config.conf

	fi

	if [ $DEBIAN_RELEASE = "trixie" ]
	then

		if dpkg -s fastfetch &>/dev/null
		then

			echo "FASTFETCH OK ✅"

		else

			echo "🔧 INSTALL FASTFETCH"
			apt install fastfetch -y

		fi

	fi

fi

if [ $JSVC -eq 1 ]
then

	echo ""
	echo "🔧 INSTALL JSVC"
	apt install jsvc -y

fi

if [ $LEMONLDAP -eq 1 ]
then

	echo ""
	echo "🔧 INSTALL LEMONLDAP-NG"
	apt install lemonldap-ng lemonldap-ng-doc liblasso-perl krb5-user -y

fi

if [ $MONGODB -eq 1 ]
then

	echo ""
	echo "🔧 INSTALL MONGODB"
	apt install mongodb-org -y
	systemctl start mongod
	systemctl enable mongod
	mongosh --eval 'db.runCommand({ connectionStatus: 1 })'
	mongod --version
	mongosh --eval 'db.adminCommand( { getParameter: 1, featureCompatibilityVersion: 1 } )'
	# mongosh --eval 'db.adminCommand( { setFeatureCompatibilityVersion: "7.0", confirm: true } )'

fi

if [ $OPENJDK -eq 1 ]
then

	if [ $DEBIAN_RELEASE = "bookworm" ] || [ $DEBIAN_RELEASE = "bullseye" ]
	then

		echo ""
		echo "🔧 INSTALL OPENJDK"
		apt install openjdk-17-jre-headless -y
		mkdir -p /usr/lib/jvm/java-17-openjdk-amd64/lib/amd64
		ln -s -f /usr/lib/jvm/java-17-openjdk-amd64/lib/server /usr/lib/jvm/java-17-openjdk-amd64/lib/amd64/

		# CONFIGURE OPENJDK PROXY
		if [ $PROXY -eq 1 ]
		then

			sed -i "s%.*java.net.useSystemProxies=.*%java.net.useSystemProxies=true%" /etc/java-17-openjdk/net.properties
			sed -i "s%.*http.proxyHost=.*%http.proxyHost=$PROXY_HTTP_HOST%" /etc/java-17-openjdk/net.properties
			sed -i "s%.*http.proxyPort=.*%http.proxyPort=$PROXY_HTTP_PORT%" /etc/java-17-openjdk/net.properties
			sed -i "s%.*https.proxyHost=.*%https.proxyHost=$PROXY_HTTPS_HOST%" /etc/java-17-openjdk/net.properties
			sed -i "s%.*https.proxyPort=.*%https.proxyPort=$PROXY_HTTPS_PORT%" /etc/java-17-openjdk/net.properties
			sed -i "s%.*http.nonProxyHosts=.*%http.nonProxyHosts=localhost|127.0.0.1|127.0.1.1|[::1]%" /etc/java-17-openjdk/net.properties

		else

			sed -i "s%.*java.net.useSystemProxies=.*%java.net.useSystemProxies=false%" /etc/java-17-openjdk/net.properties
			sed -i "s%.*http.proxyHost=.*%# http.proxyHost=%" /etc/java-17-openjdk/net.properties
			sed -i "s%.*http.proxyPort=.*%# http.proxyPort=80%" /etc/java-17-openjdk/net.properties
			sed -i "s%.*https.proxyHost=.*%# https.proxyHost=%" /etc/java-17-openjdk/net.properties
			sed -i "s%.*https.proxyPort=.*%# https.proxyPort=443%" /etc/java-17-openjdk/net.properties
			sed -i "s%.*http.nonProxyHosts=.*%http.nonProxyHosts=localhost|127.*|[::1]%" /etc/java-17-openjdk/net.properties


		fi

	fi

	if [ $DEBIAN_RELEASE = "trixie" ]
	then


		echo ""
		echo "🔧 INSTALL OPENJDK"
		apt install openjdk-21-jre-headless -y
		mkdir -p /usr/lib/jvm/java-21-openjdk-amd64/lib/amd64
		ln -s -f /usr/lib/jvm/java-21-openjdk-amd64/lib/server /usr/lib/jvm/java-21-openjdk-amd64/lib/amd64/

		if [ $PROXY_HTTP -eq 1 ]
		then

			sed -i "s%.*java.net.useSystemProxies=.*%java.net.useSystemProxies=true%" /etc/java-21-openjdk/net.properties

		else

			sed -i "s%.*java.net.useSystemProxies=.*%java.net.useSystemProxies=false%" /etc/java-21-openjdk/net.properties

		fi

	fi

fi

if [ $OMADA -eq 1 ]
then

	if [ -f /root/omada_v${OMADA_VERSION}.deb ]
	then

		echo ""
		echo "OMADA OK ✅"

	else

		echo ""
		echo "🔧 INSTALL OMADA"
		wget https://ota-download.tplinkcloud.com/firmware/omada_v${OMADA_VERSION}.deb &&  dpkg -i /root/omada_v${OMADA_VERSION}.deb

	fi

fi

if [ $OPENVSWITCH -eq 1 ]
then

	if dpkg -s openvswitch-switch &>/dev/null
	then

		echo "OPENVSWITCH OK ✅"

	else

		echo "🔧 INSTALL OPENVSWITCH"
		apt install openvswitch-switch -y

	
	fi

fi

if [ $POSTGRESQL -eq 1 ]
then

	echo ""
	echo "🔧 INSTALL POSTGRESQL"
	apt install postgresql -y

fi

if [ $POSTFIX -eq 1 ]
then

	echo ""
	echo "🔧 INSTALL POSTFIX"
	apt install postfix -y
	sed -i "s%.*relayhost.*%relayhost = $POSTFIX_RELAY_HOST%" /etc/postfix/main.cf
	service postfix restart

fi

if [ $QEMU_GUEST_AGENT -eq 1 ]
then

	echo ""
	echo "🔧INSTALL QEMU GUEST AGENT"
	apt install qemu-guest-agent -y

fi

if [ $SYSLOG_CLIENT -eq 1 ]
then

	if dpkg -s rsyslog &>/dev/null
	then

		echo "RSYSLOG OK ✅"

	else

		echo "🔧INSTALL RSYSLOG"
		apt install rsyslog -y

	fi

	echo '' > /etc/rsyslog.conf
	echo '# MODULES' >> /etc/rsyslog.conf
	echo 'module(load="imuxsock")' >> /etc/rsyslog.conf
	echo '' >> /etc/rsyslog.conf
	echo '# RIGHTS' >> /etc/rsyslog.conf
	echo '$FileOwner root' >> /etc/rsyslog.conf
	echo '$FileGroup adm' >> /etc/rsyslog.conf
	echo '$FileCreateMode 0640' >> /etc/rsyslog.conf
	echo '$DirCreateMode 0755' >> /etc/rsyslog.conf
	echo '$Umask 0022' >> /etc/rsyslog.conf
	echo '' >> /etc/rsyslog.conf
	echo '# WORKING DIRECTORY' >> /etc/rsyslog.conf
	echo '$WorkDirectory /tmp' >> /etc/rsyslog.conf
	echo '' >> /etc/rsyslog.conf
	echo '# SPECIFIC CONFIGURATIONS' >> /etc/rsyslog.conf
	echo '$IncludeConfig /etc/rsyslog.d/*.conf' >> /etc/rsyslog.conf
	echo '' >> /etc/rsyslog.conf
	echo '# DEFAULT QUEUES TUNNING' >> /etc/rsyslog.conf
	echo '$ActionQueueFileName siem' >> /etc/rsyslog.conf
	echo '$ActionQueueMaxDiskSpace 1g' >> /etc/rsyslog.conf
	echo '$ActionQueueSaveOnShutdown off' >> /etc/rsyslog.conf
	echo '$ActionQueueType LinkedList' >> /etc/rsyslog.conf
	echo '$ActionResumeRetryCount -1' >> /etc/rsyslog.conf
	echo '' >> /etc/rsyslog.conf
	echo '# DEFAULT ACTIONS' >> /etc/rsyslog.conf
	echo "*.*	@$SYSLOG_CLIENT_SERVER:514" >> /etc/rsyslog.conf
	echo 'stop' >> /etc/rsyslog.conf
	echo '' >> /etc/rsyslog.conf

	rm -f /etc/rsyslog.d/*

	# if [ $DEBIAN_TYPE == "LXC" ]
	# then

	echo '' > /etc/rsyslog.d/kernel.conf
	echo '# TEMPLATE' >> /etc/rsyslog.d/kernel.conf
	echo 'template (name="ulogd" type="string" string="%TIMESTAMP:::date-rfc3339% %HOSTNAME% kernel:%msg%\\n")' >> /etc/rsyslog.d/kernel.conf
	echo '' >> /etc/rsyslog.d/kernel.conf
	echo '# RULESET' >> /etc/rsyslog.d/kernel.conf
	echo 'ruleset(name="ulogd") {' >> /etc/rsyslog.d/kernel.conf
	echo "	action(type=\"omfwd\" target=\"$SYSLOG_CLIENT_SERVER\" port=\"514\" protocol=\"udp\" template=\"ulogd\")" >> /etc/rsyslog.d/kernel.conf
	echo '}' >> /etc/rsyslog.d/kernel.conf
	echo '' >> /etc/rsyslog.d/kernel.conf
	echo '# SPECIFIC ACTION' >> /etc/rsyslog.d/kernel.conf
	echo 'if($programname == "ulogd")  then {' >> /etc/rsyslog.d/kernel.conf
	echo '	# KERNEL QUEUES TUNNING' >> /etc/rsyslog.d/kernel.conf
	echo '	$ActionQueueFileName kernel' >> /etc/rsyslog.d/kernel.conf
	echo '	$ActionQueueMaxDiskSpace 1g' >> /etc/rsyslog.d/kernel.conf
	echo '	$ActionQueueSaveOnShutdown off' >> /etc/rsyslog.d/kernel.conf
	echo '	$ActionQueueType LinkedList' >> /etc/rsyslog.d/kernel.conf
	echo '	$ActionResumeRetryCount -1' >> /etc/rsyslog.d/kernel.conf
	echo '	# CALL RULESET' >> /etc/rsyslog.d/kernel.conf
	echo '	call ulogd' >> /etc/rsyslog.d/kernel.conf
	echo '	stop' >> /etc/rsyslog.d/kernel.conf
	echo '}' >> /etc/rsyslog.d/kernel.conf
	echo '' >> /etc/rsyslog.d/kernel.conf
	echo '' >> /etc/rsyslog.d/kernel.conf
	echo '' >> /etc/rsyslog.d/kernel.conf
	echo '# TEMPLATE' >> /etc/rsyslog.d/kernel.conf
	echo 'template (name="iptables" type="string" string="%TIMESTAMP:::date-rfc3339% %HOSTNAME% kernel:%msg%\\n")' >> /etc/rsyslog.d/kernel.conf
	echo '' >> /etc/rsyslog.d/kernel.conf
	echo '# RULESET' >> /etc/rsyslog.d/kernel.conf
	echo 'ruleset(name="iptables") {' >> /etc/rsyslog.d/kernel.conf
	echo "	action(type=\"omfwd\" target=\"$SYSLOG_CLIENT_SERVER\" port=\"514\" protocol=\"udp\" template=\"iptables\")" >> /etc/rsyslog.d/kernel.conf
	echo '}' >> /etc/rsyslog.d/kernel.conf
	echo '' >> /etc/rsyslog.d/kernel.conf
	echo '# SPECIFIC ACTION' >> /etc/rsyslog.d/kernel.conf
	echo 'if($msg contains "REJECT")  then {' >> /etc/rsyslog.d/kernel.conf
	echo '	# KERNEL QUEUES TUNNING' >> /etc/rsyslog.d/kernel.conf
	echo '	$ActionQueueFileName kernel' >> /etc/rsyslog.d/kernel.conf
	echo '	$ActionQueueMaxDiskSpace 1g' >> /etc/rsyslog.d/kernel.conf
	echo '	$ActionQueueSaveOnShutdown off' >> /etc/rsyslog.d/kernel.conf
	echo '	$ActionQueueType LinkedList' >> /etc/rsyslog.d/kernel.conf
	echo '	$ActionResumeRetryCount -1' >> /etc/rsyslog.d/kernel.conf
	echo '	# CALL RULESET' >> /etc/rsyslog.d/kernel.conf
	echo '	call iptables' >> /etc/rsyslog.d/kernel.conf
	echo '	stop' >> /etc/rsyslog.d/kernel.conf
	echo '}' >> /etc/rsyslog.d/kernel.conf
	echo '' >> /etc/rsyslog.d/kernel.conf

	# fi

	service rsyslog restart

	if dpkg -s ulogd2 &>/dev/null
	then

		echo "ULOGD2 OK ✅"

	else

		echo "🔧INSTALL ULOGD2"
		apt install ulogd2 -y

	fi

	sed -i 's%.*stack=log1:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,emu1:LOGEMU.*%#stack=log1:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,emu1:LOGEMU%' /etc/ulogd.conf
	sed -i 's%.*stack=log3:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,sys1:SYSLOG.*%stack=log3:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,sys1:SYSLOG%' /etc/ulogd.conf
	# sed -i 's%.*stack=log1:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,sys1:SYSLOG.*%stack=log1:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,sys1:SYSLOG%' /etc/ulogd.conf
	sed -i 's%.*\[sys2].*%[sys1]%' /etc/ulogd.conf
	sed -i 's%.*facility=.*%facility=LOG_LOCAL0%' /etc/ulogd.conf

	service ulogd2 restart

fi

if [ $SYSLOG_SERVER -eq 1 ]
then

	if dpkg -s rsyslog &>/dev/null
	then

		echo "RSYSLOG OK ✅"

	else

		echo "🔧INSTALL RSYSLOG"
		apt install rsyslog -y

	fi


	mkdir -p /var/log/machines
		
	echo '#' > /etc/rsyslog.conf
	echo '# nano /etc/rsyslog.conf' >> /etc/rsyslog.conf
	echo '#' >> /etc/rsyslog.conf
	echo '' >> /etc/rsyslog.conf
	echo '### MODULES ###' >> /etc/rsyslog.conf
	echo 'module(load="imuxsock") # provides support for local system logging' >> /etc/rsyslog.conf
	echo '' >> /etc/rsyslog.conf
	echo 'module(load="imudp")' >> /etc/rsyslog.conf
	echo 'input(type="imudp" port="514")' >> /etc/rsyslog.conf
	echo '' >> /etc/rsyslog.conf
	echo 'module(load="imtcp")' >> /etc/rsyslog.conf
	echo 'input(type="imtcp" port="514")' >> /etc/rsyslog.conf
	echo '' >> /etc/rsyslog.conf
	echo '### RIGHTS ###' >> /etc/rsyslog.conf
	echo '$FileOwner root' >> /etc/rsyslog.conf
	echo '$FileGroup adm' >> /etc/rsyslog.conf
	echo '$FileCreateMode 0640' >> /etc/rsyslog.conf
	echo '$DirCreateMode 0755' >> /etc/rsyslog.conf
	echo '$Umask 0022' >> /etc/rsyslog.conf
	echo '' >> /etc/rsyslog.conf
	echo '### WORKING DIRECTORY ###' >> /etc/rsyslog.conf
	echo '$WorkDirectory /tmp' >> /etc/rsyslog.conf
	echo '' >> /etc/rsyslog.conf
	echo '### DEFAULT QUEUE ###' >> /etc/rsyslog.conf
	echo '$ActionQueueFileName siem' >> /etc/rsyslog.conf
	echo '$ActionQueueMaxDiskSpace 1g' >> /etc/rsyslog.conf
	echo '$ActionQueueSaveOnShutdown off' >> /etc/rsyslog.conf
	echo '$ActionQueueType LinkedList' >> /etc/rsyslog.conf
	echo '$ActionResumeRetryCount -1' >> /etc/rsyslog.conf
	echo '' >> /etc/rsyslog.conf
	echo '### SPECIFIC CONFIGURATIONS ###' >> /etc/rsyslog.conf
	echo '$IncludeConfig /etc/rsyslog.d/*.conf' >> /etc/rsyslog.conf

	if [ $SYSLOG_SERVER_SKIL_KERNEL -eq 1 ]
	then

		echo '#'  > /etc/rsyslog.d/1-kernel.conf
		echo '# nano /etc/rsyslog.d/1-kernel.conf'  >> /etc/rsyslog.d/1-kernel.conf
		echo '#'  >> /etc/rsyslog.d/1-kernel.conf
		echo ''  >> /etc/rsyslog.d/1-kernel.conf
		echo '# TEMPLATE'  >> /etc/rsyslog.d/1-kernel.conf
		echo 'template (name="ulogd" type="string" string="%TIMESTAMP:::date-rfc3339% %HOSTNAME% kernel:%msg%\n")'  >> /etc/rsyslog.d/1-kernel.conf
		echo ''  >> /etc/rsyslog.d/1-kernel.conf
		echo '# RULESET'  >> /etc/rsyslog.d/1-kernel.conf
		echo 'ruleset(name="ulogd") {'  >> /etc/rsyslog.d/1-kernel.conf
		echo "        action(type=\"omfile\" File=\"/var/log/machines/$HOSTNAME/kernel.log\" template=\"ulogd\")"  >> /etc/rsyslog.d/1-kernel.conf
		echo '}'  >> /etc/rsyslog.d/1-kernel.conf
		echo ''  >> /etc/rsyslog.d/1-kernel.conf
		echo '# ACTION'  >> /etc/rsyslog.d/1-kernel.conf
		echo 'if($programname == "ulogd")  then {'  >> /etc/rsyslog.d/1-kernel.conf
		echo '        # CALL RULESET'  >> /etc/rsyslog.d/1-kernel.conf
		echo '        call ulogd'  >> /etc/rsyslog.d/1-kernel.conf
		echo '        stop'  >> /etc/rsyslog.d/1-kernel.conf
		echo '}'  >> /etc/rsyslog.d/1-kernel.conf
		echo ''  >> /etc/rsyslog.d/1-kernel.conf

	else

		if test -f /etc/rsyslog.d/1-kernel.conf
		then

			rm -f /etc/rsyslog.d/1-kernel.conf

		fi

	fi

	if [ $SYSLOG_SERVER_SKIL_OMADA -eq 1 ]
	then

		echo '#'  > /etc/rsyslog.d/2-omada.conf
		echo '# nano /etc/rsyslog.d/2-omada.conf'  >> /etc/rsyslog.d/2-omada.conf
		echo '#'  >> /etc/rsyslog.d/2-omada.conf
		echo ''  >> /etc/rsyslog.d/2-omada.conf
		echo '# TEMPLATE'  >> /etc/rsyslog.d/2-omada.conf
		echo 'template (name="omada" type="string" string="%TIMESTAMP:::date-rfc3339% %HOSTNAME% omada:%msg%\n")'  >> /etc/rsyslog.d/2-omada.conf
		echo ''  >> /etc/rsyslog.d/2-omada.conf
		echo '# RULESET'  >> /etc/rsyslog.d/2-omada.conf
		echo 'ruleset(name="omada") {'  >> /etc/rsyslog.d/2-omada.conf
		echo '		action(type="omfile" File="/var/log/machines/omada/omada.log" template="omada")'  >> /etc/rsyslog.d/2-omada.conf
		echo '}'  >> /etc/rsyslog.d/2-omada.conf
		echo ''  >> /etc/rsyslog.d/2-omada.conf
		echo '# ACTION'  >> /etc/rsyslog.d/2-omada.conf
		echo 'if($programname == "-")  then {'  >> /etc/rsyslog.d/2-omada.conf
		echo '        # CALL RULESET'  >> /etc/rsyslog.d/2-omada.conf
		echo '        call omada'  >> /etc/rsyslog.d/2-omada.conf
		echo '        stop'  >> /etc/rsyslog.d/2-omada.conf
		echo '}'  >> /etc/rsyslog.d/2-omada.conf
		echo ''  >> /etc/rsyslog.d/2-omada.conf

	else

		if test -f /etc/rsyslog.d/2-omada.conf
		then

			rm -f /etc/rsyslog.d/2-omada.conf

		fi

	fi

	if [ $SYSLOG_SERVER_SKIL_SSO -eq 1 ]
	then

		echo '#' > /etc/rsyslog.d/3-sso.conf
		echo '# nano /etc/rsyslog.d/3-sso.conf' >> /etc/rsyslog.d/3-sso.conf
		echo '#' >> /etc/rsyslog.d/3-sso.conf
		echo '' >> /etc/rsyslog.d/3-sso.conf
		echo '# TEMPLATE' >> /etc/rsyslog.d/3-sso.conf
		echo '' >> /etc/rsyslog.d/3-sso.conf
		echo 'template (name="sso" type="string" string="%TIMESTAMP:::date-rfc3339% %HOSTNAME% lemonldap-ng:%msg%\n")' >> /etc/rsyslog.d/3-sso.conf
		echo '' >> /etc/rsyslog.d/3-sso.conf
		echo '# RULESET' >> /etc/rsyslog.d/3-sso.conf
		echo 'ruleset(name="sso") {' >> /etc/rsyslog.d/3-sso.conf
		echo '        action(type="omfile" File="/var/log/machines/sso/lemonldap-ng.log" template="sso")' >> /etc/rsyslog.d/3-sso.conf
		echo '}' >> /etc/rsyslog.d/3-sso.conf
		echo '' >> /etc/rsyslog.d/3-sso.conf
		echo '# ACTION' >> /etc/rsyslog.d/3-sso.conf
		echo 'if($msg contains "[LLNG:")  then {' >> /etc/rsyslog.d/3-sso.conf
		echo '        # CALL RULESET' >> /etc/rsyslog.d/3-sso.conf
		echo '        call sso' >> /etc/rsyslog.d/3-sso.conf
		echo '        stop' >> /etc/rsyslog.d/3-sso.conf
		echo '}' >> /etc/rsyslog.d/3-sso.conf
		echo '' >> /etc/rsyslog.d/3-sso.conf

	else

		if test -f /etc/rsyslog.d/3-sso.conf
		then

			rm -f /etc/rsyslog.d/3-sso.conf

		fi

	fi

	if [ $SYSLOG_SERVER_SKIL_SURICATA -eq 1 ]
	then

		echo '#' > /etc/rsyslog.d/4-suricata.conf
		echo '# nano /etc/rsyslog.d/4-suricata.conf' >> /etc/rsyslog.d/4-suricata.conf
		echo '#' >> /etc/rsyslog.d/4-suricata.conf
		echo '' >> /etc/rsyslog.d/4-suricata.conf
		echo '# TEMPLATES' >> /etc/rsyslog.d/4-suricata.conf
		echo 'template (name="fw-chn-suricata" type="string" string="fw-chn %SYSLOGTAG% %msg%\n")' >> /etc/rsyslog.d/4-suricata.conf
		echo 'template (name="fw-dmz-suricata" type="string" string="fw-dmz %SYSLOGTAG% %msg%\n")' >> /etc/rsyslog.d/4-suricata.conf
		echo 'template (name="fw-online-suricata" type="string" string="fw-online %SYSLOGTAG% %msg%\n")' >> /etc/rsyslog.d/4-suricata.conf
		echo 'template (name="fw-pln-suricata" type="string" string="fw-pln %SYSLOGTAG% %msg%\n")' >> /etc/rsyslog.d/4-suricata.conf
		echo 'template (name="fw-stp-suricata" type="string" string="fw-stp %SYSLOGTAG% %msg%\n")' >> /etc/rsyslog.d/4-suricata.conf
		echo '' >> /etc/rsyslog.d/4-suricata.conf
		echo '# RULESETS' >> /etc/rsyslog.d/4-suricata.conf
		echo 'ruleset(name="fw-chn-suricata") {' >> /etc/rsyslog.d/4-suricata.conf
		echo '		action(type="omfile" File="/var/log/machines/fw-chn/suricata.log" template="fw-chn-suricata")' >> /etc/rsyslog.d/4-suricata.conf
		echo '}' >> /etc/rsyslog.d/4-suricata.conf
		echo '' >> /etc/rsyslog.d/4-suricata.conf
		echo 'ruleset(name="fw-dmz-suricata") {' >> /etc/rsyslog.d/4-suricata.conf
		echo '		action(type="omfile" File="/var/log/machines/fw-dmz/suricata.log" template="fw-dmz-suricata")' >> /etc/rsyslog.d/4-suricata.conf
		echo '}' >> /etc/rsyslog.d/4-suricata.conf
		echo '' >> /etc/rsyslog.d/4-suricata.conf
		echo 'ruleset(name="fw-online-suricata") {' >> /etc/rsyslog.d/4-suricata.conf
		echo '		action(type="omfile" File="/var/log/machines/fw-online/suricata.log" template="fw-online-suricata")' >> /etc/rsyslog.d/4-suricata.conf
		echo '}' >> /etc/rsyslog.d/4-suricata.conf
		echo '' >> /etc/rsyslog.d/4-suricata.conf
		echo 'ruleset(name="fw-pln-suricata") {' >> /etc/rsyslog.d/4-suricata.conf
		echo '		action(type="omfile" File="/var/log/machines/fw-pln/suricata.log" template="fw-pln-suricata")' >> /etc/rsyslog.d/4-suricata.conf
		echo '}' >> /etc/rsyslog.d/4-suricata.conf
		echo '' >> /etc/rsyslog.d/4-suricata.conf
		echo 'ruleset(name="fw-stp-suricata") {' >> /etc/rsyslog.d/4-suricata.conf
		echo '		action(type="omfile" File="/var/log/machines/fw-stp/suricata.log" template="fw-stp-suricata")' >> /etc/rsyslog.d/4-suricata.conf
		echo '}' >> /etc/rsyslog.d/4-suricata.conf
		echo '' >> /etc/rsyslog.d/4-suricata.conf
		echo '# ACTIONS' >> /etc/rsyslog.d/4-suricata.conf
		echo 'if(($hostname == "fw-chn.ch-nontron.fr") and ($programname == "suricata"))  then {' >> /etc/rsyslog.d/4-suricata.conf
		echo '        # CALL RULESET' >> /etc/rsyslog.d/4-suricata.conf
		echo '        call fw-chn-suricata' >> /etc/rsyslog.d/4-suricata.conf
		echo '        stop' >> /etc/rsyslog.d/4-suricata.conf
		echo '}' >> /etc/rsyslog.d/4-suricata.conf
		echo '' >> /etc/rsyslog.d/4-suricata.conf
		echo 'if(($hostname == "fw-dmz.ch-nontron.fr") and ($programname == "suricata"))  then {' >> /etc/rsyslog.d/4-suricata.conf
		echo '        # CALL RULESET' >> /etc/rsyslog.d/4-suricata.conf
		echo '        call fw-dmz-suricata' >> /etc/rsyslog.d/4-suricata.conf
		echo '        stop' >> /etc/rsyslog.d/4-suricata.conf
		echo '}' >> /etc/rsyslog.d/4-suricata.conf
		echo '' >> /etc/rsyslog.d/4-suricata.conf
		echo 'if(($hostname == "fw-online.ch-nontron.fr") and ($programname == "suricata"))  then {' >> /etc/rsyslog.d/4-suricata.conf
		echo '        # CALL RULESET' >> /etc/rsyslog.d/4-suricata.conf
		echo '        call fw-online-suricata' >> /etc/rsyslog.d/4-suricata.conf
		echo '        stop' >> /etc/rsyslog.d/4-suricata.conf
		echo '}' >> /etc/rsyslog.d/4-suricata.conf
		echo '' >> /etc/rsyslog.d/4-suricata.conf
		echo 'if(($hostname == "fw-online-int.ch-nontron.fr") and ($programname == "suricata"))  then {' >> /etc/rsyslog.d/4-suricata.conf
		echo '        # CALL RULESET' >> /etc/rsyslog.d/4-suricata.conf
		echo '        call fw-online-suricata' >> /etc/rsyslog.d/4-suricata.conf
		echo '        stop' >> /etc/rsyslog.d/4-suricata.conf
		echo '}' >> /etc/rsyslog.d/4-suricata.conf
		echo '' >> /etc/rsyslog.d/4-suricata.conf
		echo 'if(($hostname == "fw-pln.ch-nontron.fr") and ($programname == "suricata"))  then {' >> /etc/rsyslog.d/4-suricata.conf
		echo '        # CALL RULESET' >> /etc/rsyslog.d/4-suricata.conf
		echo '        call fw-pln-suricata' >> /etc/rsyslog.d/4-suricata.conf
		echo '        stop' >> /etc/rsyslog.d/4-suricata.conf
		echo '}' >> /etc/rsyslog.d/4-suricata.conf
		echo '' >> /etc/rsyslog.d/4-suricata.conf
		echo '' >> /etc/rsyslog.d/4-suricata.conf
		echo 'if(($hostname == "fw-pln-int.ch-nontron.fr") and ($programname == "suricata"))  then {' >> /etc/rsyslog.d/4-suricata.conf
		echo '        # CALL RULESET' >> /etc/rsyslog.d/4-suricata.conf
		echo '        call fw-pln-suricata' >> /etc/rsyslog.d/4-suricata.conf
		echo '        stop' >> /etc/rsyslog.d/4-suricata.conf
		echo '}' >> /etc/rsyslog.d/4-suricata.conf
		echo '' >> /etc/rsyslog.d/4-suricata.conf
		echo 'if(($hostname == "fw-stp.ch-nontron.fr") and ($programname == "suricata"))  then {' >> /etc/rsyslog.d/4-suricata.conf
		echo '        # CALL RULESET' >> /etc/rsyslog.d/4-suricata.conf
		echo '        call fw-stp-suricata' >> /etc/rsyslog.d/4-suricata.conf
		echo '        stop' >> /etc/rsyslog.d/4-suricata.conf
		echo '}' >> /etc/rsyslog.d/4-suricata.conf
		echo '' >> /etc/rsyslog.d/4-suricata.conf
		echo 'if(($hostname == "fw-stp-int.ch-nontron.fr") and ($programname == "suricata"))  then {' >> /etc/rsyslog.d/4-suricata.conf
		echo '        # CALL RULESET' >> /etc/rsyslog.d/4-suricata.conf
		echo '        call fw-stp-suricata' >> /etc/rsyslog.d/4-suricata.conf
		echo '        stop' >> /etc/rsyslog.d/4-suricata.conf
		echo '}' >> /etc/rsyslog.d/4-suricata.conf
		echo '' >> /etc/rsyslog.d/4-suricata.conf

	else

		if test -f /etc/rsyslog.d/4-suricata.conf
		then

			rm -f /etc/rsyslog.d/4-suricata.conf

		fi

	fi

	echo '#' > /etc/rsyslog.d/default.conf
	echo '# nano /etc/rsyslog.d/default.conf' >> /etc/rsyslog.d/default.conf
	echo '#' >> /etc/rsyslog.d/default.conf
	echo '' >> /etc/rsyslog.d/default.conf
	echo '# DEFAULT ACTION' >> /etc/rsyslog.d/default.conf
	echo '$template remote-incoming-all-logs,"/var/log/machines/%HOSTNAME%/%PROGRAMNAME%.log"' >> /etc/rsyslog.d/default.conf
	echo '*.*		?remote-incoming-all-logs' >> /etc/rsyslog.d/default.conf

	service rsyslog restart

	if dpkg -s ulogd2 &>/dev/null
	then

		echo "ULOGD2 OK ✅"

	else

		echo "🔧 INSTALL ULOGD2"
		apt install ulogd2 -y

	fi

	sed -i 's%.*stack=log1:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,emu1:LOGEMU.*%#stack=log1:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,emu1:LOGEMU%' /etc/ulogd.conf
	sed -i 's%.*stack=log3:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,sys1:SYSLOG.*%stack=log3:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,sys1:SYSLOG%' /etc/ulogd.conf
	# sed -i 's%.*stack=log1:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,sys1:SYSLOG.*%stack=log1:NFLOG,base1:BASE,ifi1:IFINDEX,ip2str1:IP2STR,print1:PRINTPKT,sys1:SYSLOG%' /etc/ulogd.conf
	sed -i 's%.*\[sys2].*%[sys1]%' /etc/ulogd.conf
	sed -i 's%.*facility=.*%facility=LOG_LOCAL0%' /etc/ulogd.conf

	service ulogd2 restart

	# echo "RESTART LOGROTATE"
	# service logrotate restart

fi

if [ $SSH -eq 1 ]
then

	if dpkg -s openssh-server &>/dev/null
	then

		echo "OPENSSH SERVER OK ✅"

	else

		echo "🔧 INSTALL OPENSSH SERVER"
		apt install openssh-server -y

	fi

	touch /root/.ssh/authorized_keys
	echo $KEY_SSH_ADMIN > /root/.ssh/authorized_keys
	echo $KEY_SSH_ACME >> /root/.ssh/authorized_keys
	sed -i 's%.*AuthorizedKeysFile.*%%' /etc/ssh/sshd_config
	sed -i 's%.*PermitRootLogin.*%PermitRootLogin yes%' /etc/ssh/sshd_config
	sed -i 's%.*UsePAM.*%UsePAM yes%' /etc/ssh/sshd_config
	sed -i 's%.*X11Forwarding.*%X11Forwarding no%' /etc/ssh/sshd_config
	systemctl restart ssh.service

fi

if [ "${SYNCTHING}" -eq 1 ]; then

    if dpkg -s syncthing >/dev/null 2>&1; then
        echo "SYNCTHING OK ✅"
    else
        echo "🔧 INSTALL SYNCTHING"
        apt-get install -y syncthing
    fi

fi

if [ $WEBMIN -eq 1 ]
then

	echo "🔧 INSTALL WEBMIN"
	apt install webmin --install-recommends -y

else

	if [ -e /usr/share/webmin/miniserv.pl ]
	then

		echo "🔧 REMOVE WEBMIN"	
		apt purge webmin -y

	fi

fi

if [ $WAZUH_CLIENT -eq 1 ]
then

	if [ -f /root/wazuh-agent_${WAZUH_CLIENT_VERSION}_amd64.deb ]
	then

		echo ""
		echo "WAZUH-AGENT OK ✅"

	else

		echo ""
		echo "🔧 INSTALL WAZUH-AGENT"
		wget https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_${WAZUH_CLIENT_VERSION}_amd64.deb && sudo WAZUH_MANAGER='10.25.106.1' WAZUH_REGISTRATION_PASSWORD='A.JKPIS}x,hck$|;X3(L6ZCO?R,3o@aX' WAZUH_AGENT_GROUP='Linux' WAZUH_PROTOCOL='UDP' dpkg -i /root/wazuh-agent_${WAZUH_CLIENT_VERSION}_amd64.deb
		systemctl enable wazuh-agent.service
		systemctl start wazuh-agent.service

	fi

else

	if [ -d /var/ossec ]
	then

		echo ""	
		echo "🔧  REMOVE WAZUH-AGENT"
		apt purge wazuh-agent -y

	fi

fi

if [ $WAZUH_SERVER -eq 1 ]
then

	if [ $WAZUH_SERVER_UPGRADE -eq 1 ]
	then

		echo ""
		echo "🔧 UPGRADE WAZUH-SERVER"
		apt -y install debhelper tar curl libcap2-bin
		apt -y install wazuh-indexer
		apt -y install wazuh-manager
		apt -y install filebeat
		apt -y install wazuh-dashboard

	fi

fi

if [ $ZOOM -eq 1 ]
then

	APP_NAME="zoom"
	DEB_URL="https://zoom.us/client/latest/zoom_amd64.deb"
	ROOT_DEB="/root/zoom_latest.deb"
	TMP_DEB="/tmp/zoom_latest.deb"

	# -------------------------
	# 1. Version installée
	# -------------------------
	if test -f ${ROOT_DEB}
	then
		INSTALLED_VERSION=$(dpkg-deb -f "$ROOT_DEB" Version)

	else

		INSTALLED_VERSION="none"

	fi

	# -------------------------
	# 2 - Télécharger le .deb temporairement pour lire sa version
	# -------------------------
	DEB_VERSION=$(curl -fsSI ${DEB_URL} | grep -i '^location:' | cut -d/ -f5)

	# -------------------------
	# 3 - Installation / update
	# -------------------------
	if [ "$INSTALLED_VERSION" = "none" ] || [ "$INSTALLED_VERSION" != "$DEB_VERSION" ]; then
		echo "🔧 INSTALL/UPDATE ZOOM"
		wget -q -O "$TMP_DEB" "$DEB_URL"
		apt install -y "$TMP_DEB"
	else
		echo "ZOOM OK ✅"
	fi

	if test -f ${TMP_DEB}
	then

		mv -f $TMP_DEB $ROOT_DEB

	fi

fi

if [ $ZSH -eq 1 ]
then
	
	if dpkg -s fish &>/dev/null
	then

		echo "ZSH & FISH OK ✅"

	else

		echo "🔧 INSTALL ZSH"
		apt install zsh zsh-autosuggestions zsh-syntax-highlighting -y
		chsh -s $(which zsh)

		echo "🔧 INSTALL FISH"
		apt install -y fish

	fi

	if dpkg -s fzf &>/dev/null
	then

		echo "	FZF OK ✅"

	else

		echo "	🔧 INSTALL FZF"
		apt install -y fzf

	fi

	if dpkg -s tmux &>/dev/null
	then

		echo "	TMUX OK ✅"

	else

		echo "	🔧 INSTALL TMUX"
		apt install -y tmux
		tmux new -s test

	fi

  if [ "$GO" -eq 1 ]
  then

      GO_BIN="/home/$DEVOPS_USER/go/current/bin/go"
      SESH_BIN="/home/$DEVOPS_USER/go/bin/sesh"

      if [ -x "$SESH_BIN" ]
      then

          echo "	SESH OK ✅"

      else

          if [ ! -x "$GO_BIN" ]
          then

              echo "	💥 Go n'est pas installé pour $DEVOPS_USER. Abandon."
              exit 1

          fi

          echo "	🔧 INSTALL SESH"

          runuser -u "$DEVOPS_USER" -- \
              env \
                  HOME="/home/$DEVOPS_USER" \
                  GOPATH="/home/$DEVOPS_USER/go" \
                  "$GO_BIN" install github.com/joshmedeski/sesh@latest

      fi

  fi

	if dpkg -s zoxide &>/dev/null
	then

		echo "	ZOXIDE OK ✅"

	else

		echo "	🔧 INSTALL ZOXIDE"
		apt install -y zoxide

	fi

	echo "🔧 CONFIGURE ZSH FOR USER ROOT"
	sed -i 's#root:x:0:0:root:/root:/bin/bash#root:x:0:0:root:/root:/bin/zsh#' /etc/passwd
	if [ -e /root/.zshrc ]
	then
		rm /root/.zshrc
		cp /etc/zsh/newuser.zshrc.recommended /root/.zshrc
	fi
	echo "" >> /root/.zshrc
	echo "# GLOBAL VARIABLES #" >> /root/.zshrc
	echo "export API_DEEPSEEK_KEY=$API_DEEPSEEK_KEY" >> /root/.zshrc
	echo "export API_GEMINI_KEY=$API_GEMINI_KEY" >> /root/.zshrc
	echo "export API_OPENROUTER_KEY=$API_OPENROUTER_KEY" >> /root/.zshrc
	echo "export EDITOR=nano" >> /root/.zshrc
	echo "export LANG=fr_FR.UTF-8" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# CLEAN PATH #" >> /root/.zshrc		
	echo 'typeset -U path PATH' >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# SOURCES #" >> /root/.zshrc	
	echo 'source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh' >> /root/.zshrc
	echo 'source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# HISTORY #" >> /root/.zshrc
	echo "HISTSIZE=10000" >> /root/.zshrc
	echo "SAVEHIST=10000" >> /root/.zshrc
	echo "setopt inc_append_history" >> /root/.zshrc
	echo "setopt share_history" >> /root/.zshrc
	echo "setopt hist_ignore_dups" >> /root/.zshrc
	echo "setopt hist_reduce_blanks" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# GLOBAL ALIAS #" >> /root/.zshrc
	echo "alias -g G='| grep --color'" >> /root/.zshrc
	echo "alias -g H='| head'" >> /root/.zshrc
	echo "alias -g L='| less'" >> /root/.zshrc
	echo "alias -g M='| more'" >> /root/.zshrc
	echo "alias -g W='| wc -l'" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# APT APTITUDE#" >> /root/.zshrc
	echo "alias acd='apt-cache depends'" >> /root/.zshrc
	echo "alias acp='apt-cache policy'" >> /root/.zshrc
	echo "alias acr='apt-cache rdepends -i --no-pre-depends'" >> /root/.zshrc
	echo "alias agd='apt -q -y --allow-downgrades --allow-change-held-packages -f -m --show-progress dist-upgrade'" >> /root/.zshrc
	echo "alias agi='apt --show-progress install'" >> /root/.zshrc
	echo "alias agif='apt -q -y --allow-downgrades --allow-change-held-packages -f -m --show-progress install'" >> /root/.zshrc
	echo "alias agp='apt --show-progress purge'" >> /root/.zshrc
	echo "alias agpf='apt -q -y --allow-downgrades --allow-change-held-packages -f -m --show-progress purge'" >> /root/.zshrc
	echo "alias agu='apt update'" >> /root/.zshrc
	echo "alias agud='apt update && apt -q -y --allow-downgrades --allow-change-held-packages -f -m --show-progress dist-upgrade'" >> /root/.zshrc
	echo "alias alu='apt list --upgradable'" >> /root/.zshrc
	echo "alias ama='apt-mark auto'" >> /root/.zshrc
	echo "alias amm='apt-mark manual'" >> /root/.zshrc
	echo "alias aps='aptitude search'" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# CAT #" >> /root/.zshrc
	echo "alias c='cat '" >> /root/.zshrc
	echo "alias cdv='cat /etc/debian_version'" >> /root/.zshrc
	echo "alias ceh='cat /etc/hosts'" >> /root/.zshrc
	echo "alias cehc='cat /etc/host.conf'" >> /root/.zshrc
	echo "alias cel='cat /etc/localtime'" >> /root/.zshrc
	echo "alias cm='cat /home/monero/monero.log'" >> /root/.zshrc
	echo "alias cpmh='cat /proc/meminfo | grep Huge'" >> /root/.zshrc
	echo "alias cer='cat /etc/rsyslog.conf'" >> /root/.zshrc
	echo "alias cer1='cat /etc/rsyslog.d/1-kernel.conf'" >> /root/.zshrc
	echo "alias cerd='cat /etc/rsyslog.d/default.conf'" >> /root/.zshrc
	echo "alias cerp='cat /etc/rsyslog.d/postfix.conf'" >> /root/.zshrc
	echo "alias cetv='cat /etc/tmpfiles.d/var2log.conf'" >> /root/.zshrc
	echo "alias ceu='cat /etc/ulogd.conf'" >> /root/.zshrc
	echo "alias chda='cat /home/docker/.ssh/authorized_keys'" >> /root/.zshrc
	echo "alias cp2='cat /home/monero/p2pool.log'" >> /root/.zshrc
	echo "alias cra='cat /root/.ssh/authorized_keys'" >> /root/.zshrc
	echo "alias cvll='cat /var/log/letsencrypt.log'" >> /root/.zshrc
	echo "alias cx='cat /home/monero/xmrig.log'" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# CD CP MV RM #" >> /root/.zshrc
	echo "alias ..='cd ..'" >> /root/.zshrc
	echo "alias ...='cd ../..'" >> /root/.zshrc
	# echo "alias cd='z'" >> /root/.zshrc
	echo "alias cde='cd /etc'" >> /root/.zshrc
	echo "alias cdea='cd /etc/apache2'" >> /root/.zshrc
	echo "alias cdeapt='cd /etc/apt'" >> /root/.zshrc
	echo "alias cdeaptconf='cd /etc/apt/apt.conf.d'" >> /root/.zshrc
	echo "alias cdeaptpref='cd /etc/apt/preferences.d'" >> /root/.zshrc
	echo "alias cdeaptsl='cd /etc/apt/sources.list.d'" >> /root/.zshrc
	echo "alias cdeapttrust='cd /etc/apt/trusted.gpg.d'" >> /root/.zshrc
	echo "alias cdeaca='cd /etc/apache2/conf-available'" >> /root/.zshrc
	echo "alias cdeace='cd /etc/apache2/conf-enabled'" >> /root/.zshrc
	echo "alias cdeama='cd /etc/apache2/mods-available'" >> /root/.zshrc
	echo "alias cdeame='cd /etc/apache2/mods-enabled'" >> /root/.zshrc
	echo "alias cdeasa='cd /etc/apache2/sites-available'" >> /root/.zshrc
	echo "alias cdease='cd /etc/apache2/sites-enabled'" >> /root/.zshrc
	echo "alias cded='cd /etc/default'" >> /root/.zshrc
	echo "alias cdeg='cd ~/.local/share/gnome-shell/extensions/'" >> /root/.zshrc
	echo "alias cdel='cd /etc/ldap'" >> /root/.zshrc
	echo "alias cdels='cd /etc/ldap/slapd.d'" >> /root/.zshrc
	echo "alias cdelsc='cd /etc/ldap/slapd.d/cn=config'" >> /root/.zshrc
	echo "alias cden='cd /etc/network'" >> /root/.zshrc
	echo "alias cdeni='cd /etc/network/interfaces.d'" >> /root/.zshrc
	echo "alias cdenm='cd /etc/NetworkManager/system-connections'" >> /root/.zshrc
	echo "alias cdenm='cd /etc/NetworkManager/system-connections'" >> /root/.zshrc
	echo "alias cdeovpn='cd /etc/openvpn'" >> /root/.zshrc
	echo "alias cder='cd /etc/rsyslog.d'" >> /root/.zshrc
	echo "alias cdepf='cd /etc/postfix'" >> /root/.zshrc
	echo "alias cdes='cd /etc/systemd'" >> /root/.zshrc
	echo "alias cdesn='cd /etc/systemd/network'" >> /root/.zshrc
	echo "alias cdess='cd /etc/systemd/system'" >> /root/.zshrc
	echo "alias cdessh='cd /etc/ssh'" >> /root/.zshrc
	echo "alias cdessl='cd /etc/ssl'" >> /root/.zshrc
	echo "alias cdesu='cd /etc/systemd/user'" >> /root/.zshrc
	echo "alias cdh='cd /home'" >> /root/.zshrc
	echo "alias cdhde='cd /home/devops'" >> /root/.zshrc
	echo "alias cdhded='cd /home/devops/datas'" >> /root/.zshrc
	echo "alias cdhdo='cd /home/docker'" >> /root/.zshrc
	echo "alias cdhdod='cd /home/docker/datas'" >> /root/.zshrc
	echo "alias cdhdos='cd /home/docker/.ssh'" >> /root/.zshrc
	echo "alias cdhdop='cd /home/docker/proxy'" >> /root/.zshrc
	echo "alias cdhi='cd /home/ia'" >> /root/.zshrc
	echo "alias cdhid='cd /home/ia/download'" >> /root/.zshrc
	echo "alias cdhih='cd /home/ia/hermes'" >> /root/.zshrc
	echo "alias cdhit='cd /home/ia/tools'" >> /root/.zshrc
	echo "alias cdm='cd /home/monero'" >> /root/.zshrc
	echo "alias cdr='cd /root'" >> /root/.zshrc
	echo "alias cdt='cd /tmp'" >> /root/.zshrc
	echo "alias cdub='cd /usr/bin'" >> /root/.zshrc
	echo "alias cdv='cd /var'" >> /root/.zshrc
	echo "alias cdvc='cd /var/cache'" >> /root/.zshrc
	echo "alias cdvl='cd /var/log'" >> /root/.zshrc
	echo "alias cdvlm='cd /var/log/machines'" >> /root/.zshrc
	echo "alias cdvlib='cd /var/lib'" >> /root/.zshrc
	echo "alias cdvlibl='cd /var/lib/ldap'" >> /root/.zshrc
	echo "alias cdvm='cd /var/mail'" >> /root/.zshrc
	echo "alias cdvs='cd /var/spool'" >> /root/.zshrc
	echo "alias cdvt='cd /var/tmp'" >> /root/.zshrc
	echo "alias cp='cp -i'" >> /root/.zshrc
	echo "alias mv='mv -i'" >> /root/.zshrc
	echo "alias rm='rm -i'" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# COMMAND #" >> /root/.zshrc
	echo "alias co='command -v '" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# DIU #" >> /root/.zshrc
	echo "alias rcicd='ridt proj cicd'" >> /root/.zshrc
	echo "alias rido='rid proj ocrw'" >> /root/.zshrc
	echo "alias rid='/root/diu/root-install-debian.sh'" >> /root/.zshrc
	echo "alias ridt='/home/devops/datas/diu/root-install-debian.sh'" >> /root/.zshrc
	echo "alias ridu='rid update'" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# DF #" >> /root/.zshrc
	echo "alias dfh='df -h'" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# DOCKER #" >> /root/.zshrc
	echo "alias d0='docker stop'" >> /root/.zshrc
	echo "alias d0d='docker stop dockhand'" >> /root/.zshrc
	echo "alias d0dz='docker stop dozzle'" >> /root/.zshrc
	echo "alias d0h='docker stop hawser'" >> /root/.zshrc
	echo "alias d0o='docker stop ost'" >> /root/.zshrc
	echo "alias d0t='docker stop traefik'" >> /root/.zshrc
	echo "alias d0w='docker stop whoami'" >> /root/.zshrc
	echo "alias d01d='docker restart dockhand'" >> /root/.zshrc
	echo "alias d01dz='docker restart dozzle'" >> /root/.zshrc
	echo "alias d01h='docker restart hawser'" >> /root/.zshrc
	echo "alias d01o='docker restart ost'" >> /root/.zshrc
	echo "alias d01t='docker restart traefik'" >> /root/.zshrc
	echo "alias d01w='docker restart whoami'" >> /root/.zshrc
	echo "alias d1='docker start'" >> /root/.zshrc
	echo "alias d1d='docker start dockhand'" >> /root/.zshrc
	echo "alias d1dz='docker start dozzle'" >> /root/.zshrc
	echo "alias d1h='docker start hawser'" >> /root/.zshrc
	echo "alias d1o='docker start ost'" >> /root/.zshrc
	echo "alias d1t='docker start traefik'" >> /root/.zshrc
	echo "alias d1w='docker start whoami'" >> /root/.zshrc
	echo "alias dc='docker-compose --version'" >> /root/.zshrc
	echo "alias ddp='su -c \"docker-compose -f /home/docker/proxy/docker-compose.yml down\" - docker'" >> /root/.zshrc
	echo "alias dii='docker image inspect'" >> /root/.zshrc
	echo "alias dils='docker image ls'" >> /root/.zshrc
	echo "alias dl='docker logs'" >> /root/.zshrc
	echo "alias dp='docker ps'" >> /root/.zshrc
	echo "alias dlb='docker logs bunkerweb'" >> /root/.zshrc
	echo "alias dlbbd='docker logs bw-bd'" >> /root/.zshrc
	echo "alias dlbs='docker logs bw-scheduler'" >> /root/.zshrc
	echo "alias dlbui='docker logs bw-ui'" >> /root/.zshrc
	echo "alias dld='docker logs dozzle'" >> /root/.zshrc
	echo "alias dlo='docker logs ost'" >> /root/.zshrc
	echo "alias dlp='docker logs portainer'" >> /root/.zshrc
	echo "alias dlt='docker logs traefik'" >> /root/.zshrc
	echo "alias dlw='docker logs whoami'" >> /root/.zshrc
	echo "alias dnls='docker network ls'" >> /root/.zshrc
	echo "alias dpp='su -c \"docker stop dockhand && docker stop dozzle && docker stop hawser && docker stop librespeed && docker stop myspeed && docker stop traefik-manager && docker stop socket-proxy && docker stop whoami\" - docker'" >> /root/.zshrc
	echo "alias drid='docker run --rm --entrypoint id'" >> /root/.zshrc
	echo "alias dspa='docker system prune -f -a --volumes'" >> /root/.zshrc
	echo "alias dup='su -c \"docker-compose -f /home/docker/proxy/docker-compose.yml up -d\" - docker'" >> /root/.zshrc
	echo "alias dvls='docker volume ls'" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# EXIT #" >> /root/.zshrc
	echo "alias e='exit'" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# FIND #" >> /root/.zshrc
	echo "alias f=\"find / \( ! -regex '\/dev\|\/lost.*\|\/sys\|\/proc' -o -prune \) -type f -name\"" >> /root/.zshrc
	echo "alias f1=\"find / \( ! -regex '\/dev\|\/lost.*\|\/sys\|\/proc' -o -prune \) -mmin -1 -type f -name\"" >> /root/.zshrc
	echo "alias f7=\"find / \( ! -regex '\/dev\|\/lost.*\|\/sys\|\/proc' -o -prune \) -mmin -7 -type f -name\"" >> /root/.zshrc
	echo "alias f70=\"find / \( ! -regex '\/dev\|\/lost.*\|\/sys\|\/proc' -o -prune \) -mmin -70 -type f -name\"" >> /root/.zshrc
	echo "alias feg=\"find ~/.local/share/gnome-shell/extensions -maxdepth 2 -type f -name metadata.json -print\"" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# FREE #" >> /root/.zshrc
	echo "alias mem='free -h'" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# GIT #" >> /root/.zshrc
	echo "alias ga='git add .'" >> /root/.zshrc
	echo "alias gb='git branch'" >> /root/.zshrc
	echo "alias gbmain='git branch -M main'" >> /root/.zshrc
	echo "alias gcll='git config --list --local'" >> /root/.zshrc
	echo "alias gcoa='git commit -a '" >> /root/.zshrc
	echo "alias gco1='git commit -m '" >> /root/.zshrc
	echo "alias gcue='git config user.email'" >> /root/.zshrc
	echo "alias gcun='git config user.name'" >> /root/.zshrc
	echo "alias gd='git diff --cached --name-status'" >> /root/.zshrc
	echo "alias gi='git init'" >> /root/.zshrc
	echo "alias gls='git ls-files'" >> /root/.zshrc
	echo "alias glog='git log --oneline --graph --decorate --all'" >> /root/.zshrc
	echo "alias gp='git push -u origin main'" >> /root/.zshrc
	echo "alias gr='git remote -v'" >> /root/.zshrc
	echo "alias gra='git remote add origin'" >> /root/.zshrc
	echo "alias grs='git remote show origin'" >> /root/.zshrc
	echo "alias gs='git status'" >> /root/.zshrc
	echo "alias gsi='git status --ignored'" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# IP #" >> /root/.zshrc
	echo "alias ipr='ip route'" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# IPTABLES #" >> /root/.zshrc
	echo "alias ipt0='/root/fwoff.sh'" >> /root/.zshrc
	echo "alias ipt1='/root/fwon.sh'" >> /root/.zshrc
	echo "alias iptd='iptables -L DOCKER -nvx'" >> /root/.zshrc
	echo "alias ipti='iptables -L INPUT -nvx'" >> /root/.zshrc
	echo "alias iptf='iptables -L FORWARD -nvx'" >> /root/.zshrc
	echo "alias ipto='iptables -L OUTPUT -nvx'" >> /root/.zshrc

	echo "# IPSET #" >> /root/.zshrc
	echo "alias isd='ipset destroy'" >> /root/.zshrc
	echo "alias isf='ipset flush'" >> /root/.zshrc
	echo "alias isl='ipset -name list'" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# JOURNALCTL #" >> /root/.zshrc
	echo "alias j='journalctl -f'" >> /root/.zshrc
	echo "alias jf='journalctl -feu'" >> /root/.zshrc
	echo "alias jx='journalctl -xeu'" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# LOCATE #" >> /root/.zshrc
	echo "alias lo='locate'" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# LS #" >> /root/.zshrc
	echo "alias la='ls -lA --color'" >> /root/.zshrc
	echo "alias ll='ls -lah --color'" >> /root/.zshrc
	echo "alias lll='ls -las --color'" >> /root/.zshrc
	echo "alias ls='ls --color'" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# MORE #" >> /root/.zshrc
	echo "alias logs='more /var/log/syslog'" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# NANO #" >> /root/.zshrc
	echo "alias n='nano'" >> /root/.zshrc
	echo "alias ndc='nano /home/docker/proxy/docker-compose.yml'" >> /root/.zshrc
	echo "alias ndipb='nano /home/docker/inits/postgres/bases.sql'" >> /root/.zshrc
	echo "alias nedd='nano /etc/docker/daemon.json'" >> /root/.zshrc
	echo "alias nedns='nano /etc/resolv.conf'" >> /root/.zshrc
	echo "alias neni='nano /etc/network/interfaces'" >> /root/.zshrc
	echo "alias nef='nano /etc/fstab'" >> /root/.zshrc
	echo "alias neg='nano /etc/group'" >> /root/.zshrc
	echo "alias neh='nano /etc/hosts'" >> /root/.zshrc
	echo "alias nehc='nano /etc/host.conf'" >> /root/.zshrc
	echo "alias nep='nano /etc/passwd'" >> /root/.zshrc
	echo "alias ner='nano /etc/rsyslog.conf'" >> /root/.zshrc
	echo "alias ner1='nano /etc/rsyslog.d/1-kernel.conf'" >> /root/.zshrc
	echo "alias nerc='nano /etc/rc.local'" >> /root/.zshrc
	echo "alias nerd='nano /etc/rsyslog.d/default.conf'" >> /root/.zshrc
	echo "alias nerp='nano /etc/rsyslog.d/postfix.conf'" >> /root/.zshrc
	echo "alias nesj='nano /etc/systemd/journald.conf'" >> /root/.zshrc
	echo "alias nesshd='nano /etc/ssh/sshd_config'" >> /root/.zshrc
	echo "alias netv='nano /etc/tmpfiles.d/var2log.conf'" >> /root/.zshrc
	echo "alias neu='nano /etc/ulogd.conf'" >> /root/.zshrc
	echo "alias ng='nano /etc/group'" >> /root/.zshrc
	echo "alias nm='nano /etc/monero/monerod.conf'" >> /root/.zshrc
	echo "alias np='nano /etc/passwd'" >> /root/.zschrc
	echo "alias nrid='nano /root/diu/root-install-debian.sh'" >> /root/.zshrc
	echo "alias nriv='nano /root/diu/variables.sh'" >> /root/.zshrc
	echo "alias nriidjd='nano /root/root-install-init-django-dev.sh'" >> /root/.zshrc
	echo "alias nriidjp='nano /root/root-install-init-django-prod.sh'" >> /root/.zshrc
	echo "alias nriim='nano /root/root-install-init-monero.sh'" >> /root/.zshrc
	echo "alias nriip='nano /root/root-install-init-p2pool.sh'" >> /root/.zshrc
	echo "alias nriix='nano /root/root-install-init-xmrig.sh'" >> /root/.zshrc
	echo "alias nriw='nano root-install-wazuh-step-by-step-single-node.sh'" >> /root/.zshrc
	echo "alias nt='nano /etc/tor/torrc'" >> /root/.zshrc
	echo "alias ntd='nano /home/docker/proxy/traefik-data/configurations/dynamic.yml'" >> /root/.zshrc
	echo "alias ntdpixs='nano /home/docker/proxy/traefik-data/configurations/1-stack-pixs.yml'" >> /root/.zshrc
	echo "alias nts='nano /home/docker/proxy/traefik-data/static.yml'" >> /root/.zshrc
	echo "alias nulfdp='nano /usr/lib/firefox-esr/distribution/policies.json'" >> /root/.zshrc
	echo "alias nz='nano /root/.zshrc'" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# Commande NETSTAT #" >> /root/.zshrc
	echo "alias net='netstat -plantu'" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# Commande OPENCODE #" >> /root/.zshrc
	echo "alias oc='opencode --version'" >> /root/.zshrc
	echo "alias oca='/opsx:apply'" >> /root/.zshrcd
	echo "alias ocar='/opsx:archive'" >> /root/.zshrcd
	echo "alias occ='/opsx:continue'" >> /root/.zshrcd
	echo "alias oce='/opsx:explore'" >> /root/.zshrcd
	echo "alias ocp='/opsx:propose'" >> /root/.zshrcd
	echo "alias ocs='/opsx:sync'" >> /root/.zshrcd
	echo "alias ocv='/opsx:verify'" >> /root/.zshrcd

	echo "" >> /root/.zshrc
	echo "# Commande OPENSPEC #" >> /root/.zshrc
	echo "alias os='openspec --version'" >> /root/.zshrc
	echo "alias osi='openspec init --tools opencode --profile custom'" >> /root/.zshrc
	echo "alias oscl='openspec config list'" >> /root/.zshrc
	echo "alias oscp='openspec config path'" >> /root/.zshrc
	echo "alias oscpr='openspec config profile'" >> /root/.zshrc
	echo "alias oscpr='openspec config schema'" >> /root/.zshrc
	echo "alias oscgd='oopenspec config get delivery'" >> /root/.zshrc
	echo "alias oscgp='oopenspec config get profile'" >> /root/.zshrc
	echo "alias oscgt='oopenspec config get telemetry.enabled'" >> /root/.zshrc
	echo "alias osl='openspec list'" >> /root/.zshrc
	echo "alias osnc='openspec new change'" >> /root/.zshrc
	echo "alias oss='openspec status'" >> /root/.zshrc
	echo "alias osshe='openspec schemas'" >> /root/.zshrc
	echo "alias ossho='openspec show'" >> /root/.zshrc
	echo "alias osu='openspec update'" >> /root/.zshrc
	echo "alias osv='openspec validate'" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# Commande OVS-VSCTL #" >> /root/.zshrc
	echo "alias ovs='ovs-vsctl'" >> /root/.zshrc
	echo "alias ovss='ovs-vsctl show'" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# Commande P2POOL #" >> /root/.zshrc
	echo "alias p2pb='echo \"bans\" > /run/p2pool/p2pool.control | sleep 1 | tail -n 100 /home/monero/p2pool.log'" >> /root/.zshrc
	echo "alias p2pe='echo \"exit\" > /run/p2pool/p2pool.control | sleep 1 | tail -n 100 /home/monero/p2pool.log'" >> /root/.zshrc
	echo "alias p2ph='echo \"hosts\" > /run/p2pool/p2pool.control | sleep 1 | tail -n 100 /home/monero/p2pool.log'" >> /root/.zshrc
	echo "alias p2phelp='echo \"help\" > /run/p2pool/p2pool.control | sleep 1 | tail -n 100 /home/monero/p2pool.log'" >> /root/.zshrc
	echo "alias p2plog0='echo \"loglevel 0\" > /run/p2pool/p2pool.control | sleep 1 | tail -f -n 100 /home/monero/p2pool.log'" >> /root/.zshrc
	echo "alias p2plog1='echo \"loglevel 1\" > /run/p2pool/p2pool.control | sleep 1 | tail -f -n 100 /home/monero/p2pool.log'" >> /root/.zshrc
	echo "alias p2plog2='echo \"loglevel 2\" > /run/p2pool/p2pool.control | sleep 1 | tail -f -n 100 /home/monero/p2pool.log'" >> /root/.zshrc
	echo "alias p2plog3='echo \"loglevel 3\" > /run/p2pool/p2pool.control | sleep 1 | tail -f -n 100 /home/monero/p2pool.log'" >> /root/.zshrc
	echo "alias p2pp='echo \"peers\" > /run/p2pool/p2pool.control | sleep 1 | tail -n 100 /home/monero/p2pool.log'" >> /root/.zshrc
	echo "alias p2ps='echo \"status\" > /run/p2pool/p2pool.control | sleep 1 | tail -n 100 /home/monero/p2pool.log'" >> /root/.zshrc
	echo "alias p2pv='echo \"version\" > /run/p2pool/p2pool.control | sleep 1 | tail -n 100 /home/monero/p2pool.log'" >> /root/.zshrc
	echo "alias p2pw='echo \"workers\" > /run/p2pool/p2pool.control | sleep 1 | tail -n 100 /home/monero/p2pool.log'" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# Commande PING #" >> /root/.zshrc
	echo "alias p='ping -4'" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# Commande PS #" >> /root/.zshrc
	echo "alias psc='ps xawf -eo pid,user,cgroup,args'" >> /root/.zshrc
	echo "alias psf='ps faux'" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# Commande PYTHON #" >> /root/.zshrc
	echo "alias pv=' python3 -m pip --version'" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# Commande SESH #" >> /root/.zshrc
	echo "alias sl='sesh list'" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# Commande SOURCE #" >> /root/.zshrc
	echo "alias sa='zsh -n ~/.zshrc && source ~/.zshrc && hash -r'" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# Commande SS #" >> /root/.zshrc
	echo "alias ss='ss -tulpn'" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# Commande SU #" >> /root/.zshrc
	echo "alias s='su -'" >> /root/.zshrc
	echo "alias sudev='su - devops'" >> /root/.zshrc
	echo "alias sudoc='su - docker'" >> /root/.zshrc
	echo "alias suia='su - ia'" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# Commande SYSTEMCTL #" >> /root/.zshrc
	echo "alias sd='systemctl disable'" >> /root/.zshrc
	echo "alias sdr='systemctl daemon-reload'" >> /root/.zshrc
	echo "alias se='systemctl enable'" >> /root/.zshrc
	echo "alias sss='systemctl status'" >> /root/.zshrc
	echo "alias ssrc='systemctl status rc-local.service'" >> /root/.zshrc
	echo "alias s0='systemctl stop'" >> /root/.zshrc
	echo "alias s0rc='systemctl stop rc-local.service'" >> /root/.zshrc
	echo "alias s1='systemctl start'" >> /root/.zshrc
	echo "alias s1rc='systemctl start rc-local.service'" >> /root/.zshrc
	echo "alias s01='systemctl restart'" >> /root/.zshrc
	echo "alias s11='systemctl reload'" >> /root/.zshrc
	echo "alias sser='systemctl -t service'" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# Commande SYSTEMD-ANALYSE #" >> /root/.zshrc
	echo "alias sdana='systemd-analyze'" >> /root/.zshrc
	echo "alias sdanab='systemd-analyze blame'" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# Commande SYSTEMD-CGLS #" >> /root/.zshrc
	echo "alias syscg='systemd-cgls'" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# Commande TAIL #" >> /root/.zshrc
	echo "alias ta='tail -f -n 100'" >> /root/.zshrc
	echo "alias tam='tail -f -n 100 /home/monero/monero.log'" >> /root/.zshrc
	echo "alias tap='tail -f -n 100 /home/monero/p2pool.log'" >> /root/.zshrc
	echo "alias tax='tail -f -n 100 /home/monero/xmrig.log'" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# Commande TMUX SESH #" >> /root/.zshrc
	echo "alias tm='tmux'" >> /root/.zshrc
	echo "alias tma='tmux attach'" >> /root/.zshrc
	echo "alias tmk='tmux kill-session -t'" >> /root/.zshrc
	echo "alias tml='tmux ls'" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# Commande TREE #" >> /root/.zshrc
	echo 'alias t0="tree -a"' >> /root/.zshrc
	echo 'alias t1="tree -a -L 1"' >> /root/.zshrc
	echo 'alias t2="tree -a -L 2"' >> /root/.zshrc
	echo 'alias t3="tree -a -L 3"' >> /root/.zshrc
	echo 'alias t4="tree -a -L 4"' >> /root/.zshrc
	echo 'alias thde0="tree -a /home/devops"' >> /root/.zshrc
	echo 'alias thde1="tree -a -L 1 /home/devops"' >> /root/.zshrc
	echo 'alias thde2="tree -a -L 2 /home/devops"' >> /root/.zshrc
	echo 'alias thde3="tree -a -L 3 /home/devops"' >> /root/.zshrc
	echo 'alias thde4="tree -a -L 4 /home/devops"' >> /root/.zshrc
	echo 'alias thded0="tree -a /home/devops/datas"' >> /root/.zshrc
	echo 'alias thded1="tree -a -L 1 /home/devops/datas"' >> /root/.zshrc
	echo 'alias thded2="tree -a -L 2 /home/devops/datas"' >> /root/.zshrc
	echo 'alias thded3="tree -a -L 3 /home/devops/datas"' >> /root/.zshrc
	echo 'alias thded4="tree -a -L 4 /home/devops/datas"' >> /root/.zshrc
	echo 'alias thdo="tree -a -I \"datas|proxy\" /home/docker && tree -a -L 2 -I \"inits|proxy\" /home/docker && tree -a -L 4 -I \"inits|datas\" /home/docker"' >> /root/.zshrc
	echo 'alias thdo1="tree -a -L 1 /home/docker"' >> /root/.zshrc
	echo 'alias thdo2="tree -a -L 2 /home/docker"' >> /root/.zshrc
	echo 'alias thdo3="tree -a -L 3 /home/docker"' >> /root/.zshrc
	echo 'alias thdo4="tree -a -L 4 /home/docker"' >> /root/.zshrc
	echo "alias tvl='tree /var/log'" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# Commande UNAME #" >> /root/.zshrc
	echo 'alias u="uname -r"' >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# Commande WHICH #" >> /root/.zshrc
	echo 'alias wh="which "' >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# Commande ZOXIDE #" >> /root/.zshrc
	echo "alias ze='zoxide edit'" >> /root/.zshrc
	echo "alias zl='zoxide query -l'" >> /root/.zshrc
	echo "alias zq='zoxide query'" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# Commande ZSH #" >> /root/.zshrc
	echo "alias zshc='zsh -n ~/.zshrc'" >> /root/.zshrc

	echo "" >> /root/.zshrc
	echo "# Commands on loading #" >> /root/.zshrc

	echo 'eval "$(zoxide init zsh)"' >> /root/.zshrc

	# echo 'if command -v tmux >/dev/null && [ -z "$TMUX" ]; then' >> /root/.zshrc
	# echo '  tmux attach -t main || tmux new -s main' >> /root/.zshrc
	# echo 'fi' >> /root/.zshrc

	if [ $DEBIAN_RELEASE = "bookworm" ] || [ $DEBIAN_RELEASE = "bullseye" ]
	then

		echo "neofetch" >> /root/.zshrc

	fi

	if [ $DEBIAN_RELEASE = "trixie" ]
	then

		echo "fastfetch" >> /root/.zshrc

	fi

	cat >> /root/.zshrc <<'EOF'

sc() {
  [[ -t 1 ]] || return

  local session

  session=$(sesh list | fzf \
    --prompt="Session > " \
    --preview="sesh connect {} --dry-run 2>/dev/null") || return

  # 1. tmux prioritaire
  if command -v tmux >/dev/null 2>&1; then
    if [ -n "$TMUX" ]; then
      tmux switch-client -t "$session"
    else
      tmux attach -t "$session" 2>/dev/null || tmux new -s "$session"
    fi
    return
  fi

  # 2. zellij fallback
  if command -v zellij >/dev/null 2>&1; then
    if [ -n "$ZELLIJ" ]; then
      zellij action switch-session "$session" 2>/dev/null || zellij attach -c "$session"
    else
      zellij attach "$session" 2>/dev/null || zellij attach -c "$session"
    fi
    return
  fi

  # 3. fallback sesh pur
  sesh connect "$session"
}

EOF
	cat >> /root/.zshrc <<'EOF'

ai() {
  echo "aid		-->		deepseek-v4-flash"
  echo "aidc		-->		deepseek-v4-pro"
  echo "aig		-->		gemini-3-flash-preview"
  echo "aiod		-->		deepseek/deepseek-v4-flash"
  echo "aiodc		-->		deepseek/deepseek-v4-pro"
  echo "aiog		-->		z-ai/glm-5.1"
  echo "aiok		-->		moonshotai/kimi-k2.6"
  echo "aiol		-->		inclusionai/ling-2.6-1t:free"
  echo "aiom5		-->		minimax/minimax-m2.5:free"
  echo "aiom7		-->		minimax/minimax-m2.7"
  echo "aioq		-->		qwen/qwen3.6-plus"
  echo "aip		-->		Perplexity"
}

EOF
	cat >> /root/.zshrc <<'EOF'

aid() {
  local MODEL="deepseek-v4-flash"   # deepseek-v4-flash / deepseek-v4-pro
  local PROMPT="${*:-Indique uniquement ton nom exact, ton modèle, ta version et ta date de publication.}"
  local RULES="Tu es un assistant utile. Réponds uniquement en français de façon concise mais complète."

  # Génération JSON
  payload=$(jq -n \
    --arg text "$PROMPT" \
    --arg rules "$RULES" \
    --arg model "$MODEL" \
    '{
      model: $model,
      messages: [
        {
          role: "system",
          content: $rules
        },
        {
          role: "user",
          content: $text
        }
      ],
      temperature: 0.5,
      top_p: 0.9,
      max_tokens: 1024,
      stream: false
    }')

  # Appel API DeepSeek
  curl -sk \
    https://api.deepseek.com/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_DEEPSEEK_KEY" \
    -d "$payload" | jq -r '.choices[0].message.content // .error.message'
}

EOF
	cat >> /root/.zshrc <<'EOF'

aidc() {
  local MODEL="deepseek-v4-pro"   # deepseek-v4-flash / deepseek-v4-pro
  local PROMPT="${*:-Indique uniquement ton nom exact, ton modèle, ta version et ta date de publication.}"
  local RULES="Tu es un assistant utile. Réponds uniquement en français de façon concise mais complète."

  # Génération JSON
  payload=$(jq -n \
    --arg text "$PROMPT" \
    --arg rules "$RULES" \
    --arg model "$MODEL" \
    '{
      model: $model,
      messages: [
        {
          role: "system",
          content: $rules
        },
        {
          role: "user",
          content: $text
        }
      ],
      temperature: 0.5,
      top_p: 0.9,
      max_tokens: 1024,
      stream: false
    }')

  # Appel API DeepSeek
  curl -sk \
    https://api.deepseek.com/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_DEEPSEEK_KEY" \
    -d "$payload" | jq -r '.choices[0].message.content // .error.message'
}

EOF
	cat >> /root/.zshrc <<'EOF'

aig() {
  local MODEL="gemini-3-flash-preview" # gemini-2.5-flash / gemini-2.5-pro / gemini-3.1-pro-preview / gemma-4-31b-it
  local PROMPT="${*:-Indique uniquement ton nom exact, ton modèle, ta version et ta date de publication.}"
  local RULES="Tu es un assistant utile. Réponse uniquement en français de façon concises mais complètes."
  # Génération JSON
  payload=$(jq -n \
    --arg text "$PROMPT" \
    --arg rules "$RULES" \
    '{
      system_instruction: {
        parts: [
          {
            text: $rules
          }
        ]
      },
      contents: [
        {
          parts: [
            {
              text: $text
            }
          ]
        }
      ],
      generationConfig: {
		  maxOutputTokens: 1024,
		  temperature: 0.5,
		  topP: 0.9
      }
    }')
  # Appel API Google
  curl -sk \
    "https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent?key=${API_GEMINI_KEY}" \
    -H "Content-Type: application/json" \
    -d "$payload" | jq -r '.candidates[0].content.parts[0].text'
}

EOF
	cat >> /root/.zshrc <<'EOF'

aiod() {

  local PROMPT="${*:-Indique uniquement ton nom exact, ton modèle, ta version et ta date de publication.}"
  local SYSTEM="Tu es un assistant utile. Réponse uniquement en français de façon concises mais complètes."

  payload=$(jq -n \
    --arg text "$PROMPT" \
    --arg system "$SYSTEM" \
    '{
      model: "deepseek/deepseek-v4-flash",
      messages: [
        { role: "system", content: $system },
        { role: "user", content: $text }
      ],
      temperature: 0.5,
      top_p: 0.9
    }')

  curl -s https://openrouter.ai/api/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_OPENROUTER_KEY" \
    -d "$payload" | jq -r '.choices[0].message.content // .error.message'
}

EOF
	cat >> /root/.zshrc <<'EOF'

aiodc() {

  local PROMPT="${*:-Indique uniquement ton nom exact, ton modèle, ta version et ta date de publication.}"
  local SYSTEM="Tu es un assistant utile. Réponse uniquement en français de façon concises mais complètes."

  payload=$(jq -n \
    --arg text "$PROMPT" \
    --arg system "$SYSTEM" \
    '{
      model: "deepseek/deepseek-v4-pro",
      messages: [
        { role: "system", content: $system },
        { role: "user", content: $text }
      ],
      temperature: 0.5,
      top_p: 0.9
    }')

  curl -s https://openrouter.ai/api/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_OPENROUTER_KEY" \
    -d "$payload" | jq -r '.choices[0].message.content // .error.message'
}

EOF
	cat >> /root/.zshrc <<'EOF'

aiog() {

  local PROMPT="${*:-Indique uniquement ton nom exact, ton modèle, ta version et ta date de publication.}"
  local SYSTEM="Tu es un assistant utile. Réponse uniquement en français de façon concises mais complètes."

  payload=$(jq -n \
    --arg text "$PROMPT" \
    --arg system "$SYSTEM" \
    '{
      model: "z-ai/glm-5.1",
      messages: [
        { role: "system", content: $system },
        { role: "user", content: $text }
      ],
      temperature: 0.5,
      top_p: 0.9
    }')

  curl -s https://openrouter.ai/api/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_OPENROUTER_KEY" \
    -d "$payload" | jq -r '.choices[0].message.content // .error.message'
}

EOF
	cat >> /root/.zshrc <<'EOF'

aiok() {

  local PROMPT="${*:-Indique uniquement ton nom exact, ton modèle, ta version et ta date de publication.}"
  local SYSTEM="Tu es un assistant utile. Réponse uniquement en français de façon concises mais complètes."

  payload=$(jq -n \
    --arg text "$PROMPT" \
    --arg system "$SYSTEM" \
    '{
      model: "moonshotai/kimi-k2.6",
      messages: [
        { role: "system", content: $system },
        { role: "user", content: $text }
      ],
      temperature: 0.5,
      top_p: 0.9
    }')

  curl -s https://openrouter.ai/api/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_OPENROUTER_KEY" \
    -d "$payload" | jq -r '.choices[0].message.content // .error.message'
}

EOF
	cat >> /root/.zshrc <<'EOF'

aiol() {

  local PROMPT="${*:-Indique uniquement ton nom exact, ton modèle, ta version et ta date de publication.}"
  local SYSTEM="Tu es un assistant utile. Réponse uniquement en français de façon concises mais complètes."

  payload=$(jq -n \
    --arg text "$PROMPT" \
    --arg system "$SYSTEM" \
    '{
      model: "inclusionai/ling-2.6-1t:free",
      messages: [
        { role: "system", content: $system },
        { role: "user", content: $text }
      ],
      temperature: 0.5,
      top_p: 0.9
    }')

  curl -s https://openrouter.ai/api/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_OPENROUTER_KEY" \
    -d "$payload" | jq -r '.choices[0].message.content // .error.message'
}

EOF
	cat >> /root/.zshrc <<'EOF'

aiom5() {

  local PROMPT="${*:-Indique uniquement ton nom exact, ton modèle, ta version et ta date de publication.}"
  local SYSTEM="Tu es un assistant utile. Réponse uniquement en français de façon concises mais complètes."

  payload=$(jq -n \
    --arg text "$PROMPT" \
    --arg system "$SYSTEM" \
    '{
      model: "minimax/minimax-m2.5:free",
      messages: [
        { role: "system", content: $system },
        { role: "user", content: $text }
      ],
      temperature: 0.5,
      top_p: 0.9
    }')

  curl -s https://openrouter.ai/api/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_OPENROUTER_KEY" \
    -d "$payload" | jq -r '.choices[0].message.content // .error.message'
}

EOF
	cat >> /root/.zshrc <<'EOF'

aiom7() {

  local PROMPT="${*:-Indique uniquement ton nom exact, ton modèle, ta version et ta date de publication.}"
  local SYSTEM="Tu es un assistant utile. Réponse uniquement en français de façon concises mais complètes."

  payload=$(jq -n \
    --arg text "$PROMPT" \
    --arg system "$SYSTEM" \
    '{
      model: "minimax/minimax-m2.7",
      messages: [
        { role: "system", content: $system },
        { role: "user", content: $text }
      ],
      temperature: 0.5,
      top_p: 0.9
    }')

  curl -s https://openrouter.ai/api/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_OPENROUTER_KEY" \
    -d "$payload" | jq -r '.choices[0].message.content // .error.message'
}

EOF
	cat >> /root/.zshrc <<'EOF'

aioq() {

  local PROMPT="${*:-Indique uniquement ton nom exact, ton modèle, ta version et ta date de publication.}"
  local SYSTEM="Tu es un assistant utile. Réponse uniquement en français de façon concises mais complètes."

  payload=$(jq -n \
    --arg text "$PROMPT" \
    --arg system "$SYSTEM" \
    '{
      model: "qwen/qwen3.6-plus",
      messages: [
        { role: "system", content: $system },
        { role: "user", content: $text }
      ],
      temperature: 0.5,
      top_p: 0.9
    }')

  curl -s https://openrouter.ai/api/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_OPENROUTER_KEY" \
    -d "$payload" | jq -r '.choices[0].message.content // .error.message'
}

EOF
	cat >> /root/.zshrc <<'EOF'

aip() {
  local MODEL="auto"
  local PROVIDER="Perplexity"

  local PROMPT="${*:-Indique uniquement ton nom exact, ton modèle, ta version et ta date de publication.}"
  local RULES="Tu es un assistant utile. Réponds uniquement en français de façon concise mais complète."

  payload=$(jq -n \
    --arg model "$MODEL" \
    --arg provider "$PROVIDER" \
    --arg text "$PROMPT" \
    --arg rules "$RULES" \
    '{
      model: $model,
      provider: $provider,
      messages: [
        {
          role: "system",
          content: $rules
        },
        {
          role: "user",
          content: $text
        }
      ],
      temperature: 0.5,
      top_p: 0.9,
      max_tokens: 1024,
      stream: false
    }')

  curl -sk \
    https://g4f.pixs.fr/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Accept-Encoding: identity" \
    -d "$payload" | jq -r '.choices[0].message.content // .error.message' | sed '/^> \[[0-9]\+\]/,$d'
}

EOF

	ZPROFILE="/root/.zprofile"

	if ! grep -q "/etc/profile" "$ZPROFILE" 2>/dev/null; then

		cat <<'EOF' >>"$ZPROFILE"
# Load system environment
if [ -f /etc/profile ]; then
	source /etc/profile
fi

EOF

	fi

	SOURCE_ZSHRC="/root/.zshrc"
	HOME_BASE="/home"
	SKEL_ZSHRC="/etc/skel/.zshrc"

	if [[ ! -f "$SOURCE_ZSHRC" ]]; then
		echo "❌ Erreur : fichier source introuvable : $SOURCE_ZSHRC"
		exit 1
	fi

	echo "🔧 CONFIGURE ZSH RC FOR /ETC/SKEL"
	cp "$SOURCE_ZSHRC" "$SKEL_ZSHRC"
	chmod 644 "$SKEL_ZSHRC"

	echo "🔧 CONFIGURE ZSH RC FOR ALL USERS IN HOME"

	for user_home in "$HOME_BASE"/*; do
		[[ -d "$user_home" ]] || continue

		username="$(basename "$user_home")"
		target_zshrc="$user_home/.zshrc"

		# Vérifie que l'utilisateur système existe
		if id "$username" &>/dev/null; then
			echo "	→ $username"
			cp "$SOURCE_ZSHRC" "$target_zshrc"
			chown "$username" "$target_zshrc"
			chmod 644 "$target_zshrc"
		fi
	done

	SOURCE_ZPROFILE="/root/.zprofile"
	HOME_BASE="/home"
	SKEL_ZPROFILE="/etc/skel/.zprofile"

	if [[ ! -f "$SOURCE_ZPROFILE" ]]; then
		echo "❌ Erreur : fichier source introuvable : $SOURCE_ZPROFILE"
		exit 1
	fi

	echo "🔧 CONFIGURE ZSH PROFILE FOR /ETC/SKEL"
	cp "$SOURCE_ZPROFILE" "$SKEL_ZPROFILE"
	chmod 644 "$SKEL_ZPROFILE"

	echo "🔧 CONFIGURE ZSH AS DEFAULT SHELL"

	ZSH_PATH="$(command -v zsh)"

	if [[ -z "$ZSH_PATH" ]]; then
		echo "❌ Erreur : Zsh n'est pas installé"
		exit 1
	fi

	for user_home in /home/*; do
		[[ -d "$user_home" ]] || continue

		username="$(basename "$user_home")"

		if ! id "$username" &>/dev/null; then
			continue
		fi

		current_shell="$(getent passwd "$username" | cut -d: -f7)"

		if [[ "$current_shell" != "$ZSH_PATH" ]]; then
			echo "    → $username : $current_shell → $ZSH_PATH"
			echo "    → 🔧 PROPAGATE .ZSHRC .ZPROFILE& FOR $username : $current_shell → $ZSH_PATH"
			usermod --shell "$ZSH_PATH" "$username"
		else
			echo "    → $username  ZSH OK ✅"
		fi
	done

	echo "🔧 CONFIGURE TMUX FOR USER ROOT"
	echo "" > /root/.tmux.conf
	echo "# BASE #" >> /root/.tmux.conf
	echo "" >> /root/.tmux.conf
	echo "set -g mouse on" >> /root/.tmux.conf
	echo "set -g history-limit 20000" >> /root/.tmux.conf
	echo "set -g base-index 1" >> /root/.tmux.conf
	echo "setw -g pane-base-index 1" >> /root/.tmux.conf
	echo "" >> /root/.tmux.conf
	echo "# PREFIX #" >> /root/.tmux.conf
	echo "unbind C-b" >> /root/.tmux.conf
	echo "set -g prefix C-a" >> /root/.tmux.conf
	echo "bind C-a send-prefix" >> /root/.tmux.conf
	echo "" >> /root/.tmux.conf
	echo "# RELOADING CONFIG #" >> /root/.tmux.conf
	echo "bind r source-file ~/.tmux.conf \; display-message "Reloaded!"" >> /root/.tmux.conf
	echo "" >> /root/.tmux.conf
	echo "# SPLITS #" >> /root/.tmux.conf
	echo "bind | split-window -h" >> /root/.tmux.conf
	echo "bind - split-window -v" >> /root/.tmux.conf
	echo "" >> /root/.tmux.conf

	echo "# NAVIGATION #" >> /root/.tmux.conf
	echo "bind h select-pane -L" >> /root/.tmux.conf
	echo "bind l select-pane -R" >> /root/.tmux.conf
	echo "bind k select-pane -U" >> /root/.tmux.conf
	echo "bind j select-pane -D" >> /root/.tmux.conf
	echo "" >> /root/.tmux.conf
	echo "# COPY MODE #" >> /root/.tmux.conf
	echo "setw -g mode-keys vi" >> /root/.tmux.conf
	echo "" >> /root/.tmux.conf
	echo "# STATUS BAR #" >> /root/.tmux.conf
	echo "set -g status-bg colour235" >> /root/.tmux.conf
	echo "set -g status-fg white" >> /root/.tmux.conf
	echo "set -g status-left " DEVOPS "" >> /root/.tmux.conf
	echo "set -g status-right '#(hostname) | %H:%M'" >> /root/.tmux.conf
	echo "" >> /root/.tmux.conf
	echo "" >> /root/.tmux.conf

	echo "🔧 CONFIGURE SESH FOR USER ROOT"
	mkdir -p /root/.config/sesh
	echo "" > /root/.config/sesh/config.yaml
	echo "# DOCKER #" >> /root/.config/sesh/config.yaml
	echo "projects:" >> /root/.config/sesh/config.yaml
	echo "  docker:" >> /root/.config/sesh/config.yaml
	echo "    path: ~/docker" >> /root/.config/sesh/config.yaml
	echo "    command: tmux new-session -A -s docker" >> /root/.config/sesh/config.yaml
	echo "" >> /root/.config/sesh/config.yaml
	echo "  infra:" >> /root/.config/sesh/config.yaml
	echo "    path: ~/infra" >> /root/.config/sesh/config.yaml
	echo "    command: tmux new-session -A -s infra" >> /root/.config/sesh/config.yaml
	echo "" >> /root/.config/sesh/config.yaml
	echo "  homelab:" >> /root/.config/sesh/config.yaml
	echo "    path: ~/homelab" >> /root/.config/sesh/config.yaml
	echo "    command: tmux new-session -A -s homelab" >> /root/.config/sesh/config.yaml
	echo "" >> /root/.config/sesh/config.yaml

	# echo 'zoxide init fish | source' >> ~/.config/fish/config.fish

fi

### RC.LOCAL ###

if [ $RCLOCAL -eq 1 ]
then

	echo "🔧 CONFIGURE RC.LOCAL"
	echo ""
	touch /etc/rc.local
	chmod +x /etc/rc.local
	echo '#!/bin/bash -e' > /etc/rc.local
	echo '' >> /etc/rc.local
	echo '' >> /etc/rc.local
	echo '' >> /etc/rc.local

	echo 'case "$1" in' >> /etc/rc.local
	echo '	start)' >> /etc/rc.local
	echo '		echo "rc.local Start..."' >> /etc/rc.local
	echo '' >> /etc/rc.local
	echo '' >> /etc/rc.local
	echo '' >> /etc/rc.local

	if [ $DEBIAN_TYPE == "PROXMOX" ]
	then

		if [ $BRIDGE_ETHERNET1_CONFIG_IP == "PROXMOX" ]
		then

			echo '# CONFIGURE FILE HOST' >> /etc/rc.local
			echo "HOSTNAME=$HOSTNAME"  >> /etc/rc.local
			echo "HOSTNAME_FQDN=$HOSTNAME_FQDN"  >> /etc/rc.local
			echo "BRIDGE_ETHERNET1_IP=\`ip a show $BRIDGE_ETHERNET1 | grep inet | sed -e 's/^.*inet[[:space:]]//' | sed -e 's/[[:space:]]brd.*//' | sed -e 's/\/.*//'\`"  >> /etc/rc.local
			echo 'echo "127.0.0.1       localhost" > /etc/hosts' >> /etc/rc.local
			echo 'echo "$BRIDGE_ETHERNET1_IP	$HOSTNAME_FQDN	$HOSTNAME" >> /etc/hosts' >> /etc/rc.local
			echo 'echo "" >> /etc/hosts' >> /etc/rc.local
			echo 'echo "# The following lines are desirable for IPv6 capable hosts" >> /etc/hosts' >> /etc/rc.local
			echo 'echo "::1     localhost ip6-localhost ip6-loopback" >> /etc/hosts' >> /etc/rc.local
			echo 'echo "ff02::1 ip6-allnodes" >> /etc/hosts' >> /etc/rc.local
			echo 'echo "ff02::2 ip6-allrouters" >> /etc/hosts' >> /etc/rc.local
			echo "" >> /etc/rc.local
			echo "" >> /etc/rc.local
			echo "" >> /etc/rc.local

		fi

	fi

	echo '# IPTABLES INIT' >> /etc/rc.local
	echo '# IPTABLES INIT' > /root/fwon.sh
	if test $DOCKER -eq 1
	then
		echo 'if iptables -L | grep -q "^Chain DOCKER"' >> /etc/rc.local
		echo 'if iptables -L | grep -q "^Chain DOCKER"' >>  /root/fwon.sh
		echo 'then' >> /etc/rc.local
		echo 'then' >> /root/fwon.sh
			echo '	echo "Chain DOCKER OK"' >> /etc/rc.local
			echo '	echo "Chain DOCKER OK"' >> /root/fwon.sh
		echo 'else' >> /etc/rc.local
		echo 'else' >> /root/fwon.sh
			echo '	iptables -N DOCKER' >> /etc/rc.local
			echo '	iptables -N DOCKER' >> /root/fwon.sh
		echo 'fi' >> /etc/rc.local
		echo 'fi' >> /root/fwon.sh
	fi
	echo 'iptables -t filter -F' >> /etc/rc.local
	echo 'iptables -t filter -F' >> /root/fwon.sh
	echo 'iptables -t filter -X' >> /etc/rc.local
	echo 'iptables -t filter -X' >> /root/fwon.sh
	echo '' >> /etc/rc.local
	echo '' >> /etc/rc.local
	echo '' >> /etc/rc.local

	echo '# IPTABLES STATES RELATED AND ESTABLISHED' >> /etc/rc.local
	echo '# IPTABLES STATES RELATED AND ESTABLISHED' >> /root/fwon.sh
	echo 'iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT' >> /etc/rc.local
	echo 'iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT' >> /root/fwon.sh
	echo '' >> /etc/rc.local
	echo '' >> /etc/rc.local
	echo '' >> /etc/rc.local

	echo '# IPTABLES FILTER LOCALHOST' >> /etc/rc.local
	echo '# IPTABLES FILTER LOCALHOST' >> /root/fwon.sh
	echo 'iptables -A INPUT -i lo -j ACCEPT' >> /etc/rc.local
	echo 'iptables -A INPUT -i lo -j ACCEPT' >> /root/fwon.sh
	echo '' >> /etc/rc.local
	echo '' >> /etc/rc.local
	echo '' >> /etc/rc.local

	echo '# IPTABLES FILTER ICMP' >> /etc/rc.local
	echo '# IPTABLES FILTER ICMP' >> /root/fwon.sh
	echo 'iptables -A INPUT -p icmp -j ACCEPT' >> /etc/rc.local
	echo 'iptables -A INPUT -p icmp -j ACCEPT' >> /root/fwon.sh
	echo '' >> /etc/rc.local
	echo '' >> /etc/rc.local
	echo '' >> /etc/rc.local

	if [ $DOCKER -eq 1 ]
	then

		DOCKER_BRIDGE=`ip a | grep docker | grep 1500 | grep -v "veth" | sed -e 's/[[:digit:]]*:[[:space:]]//' | sed -e 's/:[[:space:]].*//'`
		[[ "$DOCKER_BRIDGE" == *"docker"* ]] && echo "Bridge DOCKER OK --> $DOCKER_BRIDGE" || echo "Bridge DOCKER KO"

		if [[ "$DOCKER_BRIDGE" == *"docker"* ]]
		then

			echo '# IPTABLES FILTER FOR DOCKER BRIDGE' >> /etc/rc.local
			echo '# IPTABLES FILTER FOR DOCKER BRIDGE' >> /root/fwon.sh
			echo "iptables -A INPUT -s 192.168.100.0/24 -j ACCEPT" >> /etc/rc.local
			echo "iptables -A INPUT -s 192.168.100.0/24 -j ACCEPT" >> /root/fwon.sh
			echo '' >> /etc/rc.local
			echo '' >> /etc/rc.local
			echo '' >> /etc/rc.local

		fi

	fi

	if [ $ADMIN_NETWORK1 != "NONE" ]
	then

		echo "# IPTABLES FILTER ADMIN NETWORK 1" >> /etc/rc.local
		echo "# IPTABLES FILTER ADMIN NETWORK 1" >> /root/fwon.sh
		echo "iptables -A INPUT -i $INTERFACE_SERVER -s $ADMIN_NETWORK1 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -s $ADMIN_NETWORK1 -j ACCEPT" >> /root/fwon.sh
		echo "" >> /etc/rc.local
		echo "" >> /etc/rc.local
		echo "" >> /etc/rc.local

	fi

	if [ $ADMIN_NETWORK2 != "NONE" ]
	then

		echo "# IPTABLES FILTER ADMIN NETWORK 2" >> /etc/rc.local
		echo "# IPTABLES FILTER ADMIN NETWORK 2" >> /root/fwon.sh
		echo "iptables -A INPUT -i $INTERFACE_SERVER -s $ADMIN_NETWORK2 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -s $ADMIN_NETWORK2 -j ACCEPT" >> /root/fwon.sh
		echo "" >> /etc/rc.local
		echo "" >> /etc/rc.local
		echo "" >> /etc/rc.local

	fi

	if [ $ACME != "NONE" ]
	then

		echo "# IPTABLES FILTER ACME" >> /etc/rc.local
		echo "# IPTABLES FILTER ACME" >> /root/fwon.sh
		echo "iptables -A INPUT -s $ACME -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -s $ACME -j ACCEPT" >> /root/fwon.sh
		echo "" >> /etc/rc.local
		echo "" >> /etc/rc.local
		echo "" >> /etc/rc.local

	fi

	echo "# IPTABLES FILTER TCP/UDP PORT(S)" >> /etc/rc.local
	echo "# IPTABLES FILTER TCP/UDP PORT(S)" >> /root/fwon.sh
	if [ $OPEN_22_TCP -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 22 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 22 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_53_TCP -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 53 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 53 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_53_UDP -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 53 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 53 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_80_TCP -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 80 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 80 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_88_TCP -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 88 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 88 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_88_UDP -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 88 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 88 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_123_UDP -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 123 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 123 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_389_TCP -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 389 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 389 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_443_TCP -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 443 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 443 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_443_UDP -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 443 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 443 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_464_TCP -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 464 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 464 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_464_UDP -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 464 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 464 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_514_TCP -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 514 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 514 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_514_UDP -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 514 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 514 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_636_TCP -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 636 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 636 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_1514_UDP -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 1514 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 1514 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_1515_TCP -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 1515 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 1515 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_2222_TCP -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 2222 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 2222 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_3001_TCP -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 3001 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 3001 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_4443_TCP -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 4443 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 4443 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_4662_TCP -eq 1 ]
	then
		echo "iptables -A INPUT -p tcp --dport 4662 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -p tcp --dport 4662 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_4662_TCP -eq 1 ]
	then
		echo "iptables -A INPUT -p tcp --dport 4662 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -p tcp --dport 4662 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_4665_UDP -eq 1 ]
	then
		echo "iptables -A INPUT -p udp --dport 4665 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -p udp --dport 4665 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_4672_UDP -eq 1 ]
	then
		echo "iptables -A INPUT -p udp --dport 4672 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -p udp --dport 4672 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_7389_TCP -eq 1 ]
	
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 7389 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 7389 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_7422_TCP -eq 1 ]
	
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 7422 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 7422 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_8006_TCP -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 8006 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 8006 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_8043_TCP -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 8043 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 8043 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_8080_TCP -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 8080 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 8080 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_8088_TCP -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 8088 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 8088 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_8843_TCP -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 8843 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 8843 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_9000_TCP -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 9000 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 9000 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_9443_TCP -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 9443 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 9443 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_9444_TCP -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 9444 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 9444 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_9445_TCP -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 9445 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 9445 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_9200_TCP -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 9200 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 9200 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_10000_TCP -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 10000 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 10000 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OPEN_50000_TCP -eq 1 ]
	then
		echo "iptables -A INPUT -p tcp --dport 50000 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -p tcp --dport 50000 -j ACCEPT" >> /root/fwon.sh
	fi
	if [ $OMADA -eq 1 ]
	then
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 19810 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 19810 -j ACCEPT" >> /root/fwon.sh
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 27001 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 27001 -j ACCEPT" >> /root/fwon.sh
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 27002 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 27002 -j ACCEPT" >> /root/fwon.sh
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 29723 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 29723 -j ACCEPT" >> /root/fwon.sh
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 29810 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p udp --dport 29810 -j ACCEPT" >> /root/fwon.sh
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 29811 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 29811 -j ACCEPT" >> /root/fwon.sh
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 29812 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 29812 -j ACCEPT" >> /root/fwon.sh
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 29813 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 29813 -j ACCEPT" >> /root/fwon.sh
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 29814 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 29814 -j ACCEPT" >> /root/fwon.sh
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 29815 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 29815 -j ACCEPT" >> /root/fwon.sh
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 29816 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 29816 -j ACCEPT" >> /root/fwon.sh
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 29817 -j ACCEPT" >> /etc/rc.local
		echo "iptables -A INPUT -i $INTERFACE_SERVER -p tcp --dport 29817 -j ACCEPT" >> /root/fwon.sh
	fi

	echo "" >> /etc/rc.local
	echo "" >> /etc/rc.local
	echo "" >> /etc/rc.local

	echo '# IPITABLES LOG' >> /etc/rc.local
	echo '# IPITABLES LOG' >> /root/fwon.sh
	echo 'iptables -A INPUT -m state --state NEW -j NFLOG --nflog-group 2 --nflog-prefix "REJECT"' >> /etc/rc.local
	echo 'iptables -A INPUT -m state --state NEW -j NFLOG --nflog-group 2 --nflog-prefix "REJECT"' >> /root/fwon.sh
	echo '' >> /etc/rc.local
	echo '' >> /etc/rc.local
	echo '' >> /etc/rc.local

	echo '# IPITABLES POLICY' >> /etc/rc.local
	echo '# IPITABLES POLICY' >> /root/fwon.sh
	echo 'iptables -t filter -P INPUT DROP' >> /etc/rc.local
	echo 'iptables -t filter -P INPUT DROP' >> /root/fwon.sh
	echo 'iptables -t filter -P FORWARD ACCEPT' >> /etc/rc.local
	echo 'iptables -t filter -P FORWARD ACCEPT' >> /root/fwon.sh
	echo 'iptables -t filter -P OUTPUT ACCEPT' >> /etc/rc.local
	echo 'iptables -t filter -P OUTPUT ACCEPT' >> /root/fwon.sh
	echo '' >> /etc/rc.local
	echo '' >> /etc/rc.local
	echo '' >> /etc/rc.local

	echo 'TIMEOUT=30' >> /etc/rc.local
	echo 'COUNT=0' >> /etc/rc.local

	echo "until ping -c1 -W1 $GATEWAY >/dev/null 2>&1" >> /etc/rc.local
	echo 'do' >> /etc/rc.local
	echo '	sleep 1' >> /etc/rc.local
	echo '	COUNT=$((COUNT+1))' >> /etc/rc.local

	echo '	if [ $COUNT -ge $TIMEOUT ]; then' >> /etc/rc.local
	echo '		echo "Network Timeout"' >> /etc/rc.local
	echo '		exit 1' >> /etc/rc.local
	echo '	fi' >> /etc/rc.local
	echo 'done' >> /etc/rc.local

	echo '' >> /etc/rc.local
	echo 'echo "Nextwork OK"' >> /etc/rc.local
	echo '' >> /etc/rc.local

	if [ $INTERFACE_ETHERNET1 != "NONE" ]
	then

		if [ "$DEBIAN_TYPE" = "LXC" ]
		then
			{
				echo "# DISABLE MULTICAST FOR ETHERNET1"
				echo "ip link set $INTERFACE_ETHERNET1 multicast off"
				echo ""
				echo ""
				echo ""

				echo "# ENABLE HARDWARE OFFLOAD"
				echo "ethtool -K $INTERFACE_ETHERNET1 gso on gro on tso on"
				echo ""
				echo ""
				echo ""

				echo "# Idem to net.core.netdev_max_backlog in sysctl.conf"
				echo "# SET TX QUEUE LEN"
				echo "ip link set $INTERFACE_ETHERNET1 txqueuelen 250000"
				echo ""
				echo ""
				echo ""
				} >> /etc/rc.local
		fi

		if [ "$DEBIAN_TYPE" = "PHYSICAL" ] || [ "$DEBIAN_TYPE" = "PROXMOX" ]
		then
			{
				echo "# DISABLE MULTICAST FOR ETHERNET1"
				echo "ip link set $INTERFACE_ETHERNET1 multicast off"
				echo ""
				echo ""
				echo ""

				echo "# ENABLE HARDWARE OFFLOAD"
				echo "ethtool -K $INTERFACE_ETHERNET1 gso on gro on tso on"
				echo ""
				echo ""
				echo ""

				echo "# SET RING BUFFER"
				echo "ethtool -G $INTERFACE_ETHERNET1 rx 4096 tx 4096"
				echo ""
				echo ""
				echo ""

				echo "# Idem to net.core.netdev_max_backlog in sysctl.conf"
				echo "# SET TX QUEUE LEN"
				echo "ip link set $INTERFACE_ETHERNET1 txqueuelen 250000"
				echo ""
				echo ""
				echo ""
				} >> /etc/rc.local
		fi

		echo "# SET UP INTERFACE" >> /etc/rc.local
		echo "ip link set $INTERFACE_ETHERNET1 up" >> /etc/rc.local
		echo "" >> /etc/rc.local
		echo "" >> /etc/rc.local
		echo "" >> /etc/rc.local

	fi

	if [ $INTERFACE_ETHERNET2 != "NONE" ]
	then

		if [ "$DEBIAN_TYPE" = "LXC" ]
		then
			{
				echo "# DISABLE MULTICAST FOR INTERFACE_ETHERNET2"
				echo "ip link set $INTERFACE_ETHERNET2 multicast off"
				echo ""
				echo ""
				echo ""

				echo "# ENABLE HARDWARE OFFLOAD"
				echo "ethtool -K $INTERFACE_ETHERNET2 gso on gro on tso on"
				echo ""
				echo ""
				echo ""

				echo "# Idem to net.core.netdev_max_backlog in sysctl.conf"
				echo "# SET TX QUEUE LEN"
				echo "ip link set $INTERFACE_ETHERNET2 txqueuelen 250000"
				echo ""
				echo ""
				echo ""
				} >> /etc/rc.local
		fi

		if [ "$DEBIAN_TYPE" = "PHYSICAL" ] || [ "$DEBIAN_TYPE" = "PROXMOX" ] || [ "$DEBIAN_TYPE" = "VM" ]
		then
			{
				echo "# DISABLE MULTICAST FOR INTERFACE_ETHERNET2"
				echo "ip link set $INTERFACE_ETHERNET2 multicast off"
				echo ""
				echo ""
				echo ""

				echo "# ENABLE HARDWARE OFFLOAD"
				echo "ethtool -K $INTERFACE_ETHERNET2 gso on gro on tso on"
				echo ""
				echo ""
				echo ""

				echo "# SET RING BUFFER"
				echo "ethtool -G $INTERFACE_ETHERNET2 rx 4096 tx 4096"
				echo ""
				echo ""
				echo ""

				echo "# Idem to net.core.netdev_max_backlog in sysctl.conf"
				echo "# SET TX QUEUE LEN"
				echo "ip link set $INTERFACE_ETHERNET2 txqueuelen 250000"
				echo ""
				echo ""
				echo ""
			} >> /etc/rc.local
		fi

		echo "# SET UP INTERFACE" >> /etc/rc.local
		echo "ip link set $INTERFACE_ETHERNET2 up" >> /etc/rc.local
		echo "" >> /etc/rc.local
		echo "" >> /etc/rc.local
		echo "" >> /etc/rc.local

	fi

	if [ $BRIDGE_ETHERNET1 != "NONE" ]
	then

		if [ "$DEBIAN_TYPE" = "PHYSICAL" ] || [ "$DEBIAN_TYPE" = "PROXMOX" ]
		then
			{
			echo "# DISABLE MULTICAST FOR BRIDGE_ETHERNET1"
			echo "ip link set $BRIDGE_ETHERNET1 multicast off"
			echo ""
			echo ""
			echo ""

			echo "# ENABLE HARDWARE OFFLOAD"
			echo "ethtool -K $BRIDGE_ETHERNET1 gso on gro on tso on"
			echo ""
			echo ""
			echo ""

			echo "# Idem to net.core.netdev_max_backlog in sysctl.conf"
			echo "# SET TX QUEUE LEN"
			echo "ip link set $BRIDGE_ETHERNET1 txqueuelen 250000"
			echo ""
			echo ""
			echo ""
			} >> /etc/rc.local
		fi

	fi

	if [ $CROWDSEC_BOUNCER -eq 1 ]
	then
		echo '# RESTART CROWDSEC FIREWALL BOUNCER' >> /etc/rc.local
		echo 'systemctl restart crowdsec-firewall-bouncer.service' >> /etc/rc.local
		echo '' >> /etc/rc.local
		echo '' >> /etc/rc.local
		echo '' >> /etc/rc.local
	fi

	echo '# TUNING ROUTE' >> /etc/rc.local
	echo "ip route change default via $GATEWAY dev $GATEWAY_INTERFACE proto kernel onlink initcwnd 44 initrwnd 44" >> /etc/rc.local
	if [ $ROUTE1 -eq 1 ]
	then

		echo "$ROUTE1_DATA" >> /etc/rc.local

	fi
	if [ $ROUTE2 -eq 1 ]
	then

		echo "$ROUTE2_DATA" >> /etc/rc.local

	fi
	if [ $ROUTE3 -eq 1 ]
	then

		echo "$ROUTE3_DATA" >> /etc/rc.local

	fi
	echo '' >> /etc/rc.local
	echo '' >> /etc/rc.local
	echo '' >> /etc/rc.local

	echo '		exit 0' >> /etc/rc.local
	echo '	;;' >> /etc/rc.local
	echo '	stop)' >> /etc/rc.local
	echo '		echo "rc.local Stop..."' >> /etc/rc.local
	echo '		exit 0' >> /etc/rc.local
	echo '	;;' >> /etc/rc.local
	echo '	*)' >> /etc/rc.local
	echo '		echo "Usage: $0 {start|stop}"' >> /etc/rc.local
	echo '		exit 1' >> /etc/rc.local
	echo '	;;' >> /etc/rc.local
	echo 'esac' >> /etc/rc.local

	# FW OFF
	echo '#!/bin/sh -e' > /root/fwoff.sh
	echo '' >> /root/fwoff.sh
	echo '' >> /root/fwoff.sh
	echo '' >> /root/fwoff.sh
	echo '# IPTABLES OFF' >> /root/fwoff.sh
	echo 'iptables -t filter -P INPUT ACCEPT' >> /root/fwoff.sh
	echo 'iptables -t filter -P FORWARD ACCEPT' >> /root/fwoff.sh
	echo 'iptables -t filter -P OUTPUT ACCEPT' >> /root/fwoff.sh
	echo 'iptables -t filter -F' >> /root/fwoff.sh
	echo 'iptables -t filter -X' >> /root/fwoff.sh
	if [ $DOCKER -eq 1 ]
	then
		echo 'iptables -X DOCKER' >> /root/fwoff.sh
	fi

	chmod +x /root/fwon.sh
	chmod +x /root/fwoff.sh

	chmod +x /etc/rc.local
	systemctl daemon-reload
	# systemctl status rc-local

	echo ""

fi

if [ $DOCKER_STACK_BUNKERWEB_UPGRADE -eq 1 ]
then

	echo "###############################################"
	echo "#        STACK PROXY DOCKER_BUNKERWEB         #"
	echo "###############################################"
	echo "   DOCKER-COMPOSE	: $DOCKER_COMPOSE_LAST_VERSION"
	echo ""
	echo "   BUNKERWEB    	: $DOCKER_BUNKERWEB"
	echo "   DOCKHAND    	: $DOCKER_DOCKHAND"
	echo "   DOZZLE 		: $DOCKER_DOZZLE"
	echo "   HAWSER    	: $DOCKER_HAWSER"
	echo "   LIBRESPEED    		    : $DOCKER_LIBRESPEED"
	echo "   MYSPEED    		: $DOCKER_MYSPEED"
	echo "   SOCKET-PROXY    		: $DOCKER_SOCKET_PROXY"
	echo "   POSTGESQL    	: $DOCKER_POSTGRESQL"
	echo "   WHOAMI 		: $DOCKER_WHOAMI"
	echo "###############################################"

fi

if [ $DOCKER_STACK_TRAEFIK_DOCKHAND_UPGRADE -eq 1 ]
then

	echo "##############################################"
	echo "#        STACK PROXY DOCKER TRAEFIK          #"
	echo "##############################################"
	echo "   DOCKER-COMPOSE	: $DOCKER_COMPOSE_LAST_VERSION"
	echo ""
	echo "   DOCKAND 		: $DOCKER_DOCKHAND"
	echo "   DOZZLE 		: $DOCKER_DOZZLE"
	echo "   HAWSER    	        : v$DOCKER_HAWSER"
	echo "   LIBRESPEED           : $DOCKER_LIBRESPEED"
	echo "   MYSPEED    		: v$DOCKER_MYSPEED"
	echo "   SOCKET-PROXY    	: $DOCKER_SOCKET_PROXY"
	echo "   TRAEFIK    	        : $DOCKER_TRAEFIK3"
	echo "   TRAEFIK-MANAGER    	: v$DOCKER_TRAEFIK_MANAGER"
	echo "   WHOAMI 		: $DOCKER_WHOAMI"
	echo "###############################################"

fi

echo ""
echo ""
echo ""
echo "######################################"
echo "# Update ALIAS 		: $VERSION_ALIAS #"
echo "# Update VARIABLES 	: $VERSION_VARIABLES #"
echo "# Update SCRIPT - RI 	: $VERSION #"
echo "######################################"
echo ""
echo ""
echo ""

if [[ "${DEBIAN_TYPE}" == "PROXMOX" ]]; then
  dmesg | grep -e DMAR -e IOMMU -e AMD-Vi || true
fi

display_infos

exit 0

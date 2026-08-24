#!/usr/bin/env bash

# Gestions des projets géré par le DIU

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

    # Mise à jour de la configuration du projet
    if ! git_update "${project_id}"; then
        print_error \
            "Impossible d'initialiser la configuration du projet."
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
		"skill": {
			"*": "ask",
			"openspec-*": "allow"
		},
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
			"docker": "ask",
			"docker *": "ask",
			"docker-compose": "ask",
			"docker-compose *": "ask",
			"echo *": "ask",
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
			"id": "allow",
			"id *": "allow",
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

Établir un projet de développement, pour l'évolution et la maintenance du ${project_name}.

L'objectif détaillé du projet est définis dans le fichier PROJET.md :

les agents respecteront les règles suivantes :

Reproductible
Maintenable
Documenté
Spécifié avec OpenSpec
Versionné avec Git
Assisté par OpenCode et Hermes

Toutes les décisions doivent privilégier ces objectifs.

## Rôle du projet

Le projet ${project_name} est développé selon une approche progressive, documentée et reproductible.

Les agents de codage doivent préserver le comportement existant tout en respectant les spécifications validées.

## Portée

AGENTS.md ;
PROJET.md ;
les spécifications présentes dans openspec/ ;
les conventions du projet ;
Les règles définies dans ce fichier s'appliquent à l'ensemble du projet.

Un fichier AGENTS.md situé dans un sous-répertoire peut être utilisé lorsque l'agent est lancé depuis ce sous-répertoire,
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
PROJET.md ;
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
PROJET.md
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
PROJET.md
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

bash -n et shellcheck

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

bash -n et shellcheck

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

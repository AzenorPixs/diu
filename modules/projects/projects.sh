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
	"share": "disabled",
	"snapshot": false,
	"autoupdate": false,
	"mcp": {
		"cgpt-validation": {
			"type": "remote",
			"url": "http://127.0.0.1:8787/mcp",
			"enabled": true,
			"oauth": false,
			"timeout": 30000
		}
	},
	"agent": {
		"plan": {
			"model": "opencode-go/qwen3.8-flash",
			"reasoningEffort": "low"
		},
		"build": {
			"model": "opencode-go/qwen3.8-flash",
			"reasoningEffort": "low"
		}
	},
	"permission": {
		"*": "ask",
		"cgpt-validation_request_validation": "allow",
		"skill": {
			"*": "ask",
			"openspec-*": "allow"
		},
		"bash": {
			"*": "ask",
			"awk": "ask",
			"awk *": "ask",
			"bash /tmp/opencode/*": "ask",
			"bash -n *": "allow",
			"cat": "allow",
			"cat *": "allow",
			"chmod": "ask",
			"chmod *": "ask",
			"chown": "ask",
			"chown *": "ask",
			"command -v": "allow",
			"command -v *": "allow",
			"cp": "allow",
			"cp *": "allow",
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
			"openspec list": "allow",
			"openspec list *": "allow",
			"openspec show": "allow",
			"openspec show *": "allow",
			"openspec status": "allow",
			"openspec status *": "allow",
			"openspec view": "allow",
			"openspec view *": "allow",
			"openspec validate": "ask",
			"openspec validate *": "ask",
			"/opt/devops/npm/bin/openspec validate": "ask",
			"/opt/devops/npm/bin/openspec validate *": "ask",
			"pwd": "allow",
			"python3": "ask",
			"python3 *": "ask",
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
			"tree": "allow",
			"tree *": "allow",
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
			".stignore": "ask",
			".venv/**": "deny",
			".vscode/**": "deny",
			"AGENTS.md": "ask",
			"BUILD.md": "ask",
			"env/**": "deny",
			"LICENSE": "ask",
			"logs/**": "ask",
			"node_modules/**": "deny",
			"openspec/**": "deny",
			"openspec/AGENTS.md": "ask",
			"openspec/config.yaml": "ask",
			"openspec/changes/**": "ask",
			"openspec/specs/**": "ask",
			"output/**": "ask",
			"PROJECT.md": "ask"
			"README.md": "ask",
			"TECHNICAL.md": "ask",
			"reports/**": "ask",
			"tmp/**": "ask",
			"venv/**": "deny"
		},
		"external_directory": {
			"*": "ask",
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
			"BUILD.md": "allow",
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
			"PROJECT.md": "allow",
			"README.md": "allow",
			"TECHNICAL.md": "allow",
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
# Création initiale du fichier AGENTS.md.
{
    printf '# AGENTS.md — %s\n\n' "${project_name}"
    printf '## 1. Contexte\n\n'
    printf '* Projet : `%s` ;\n' "${project_name}"

    cat <<'EOF'
* Racine : `/workspace` ;
* Règles de sécurité et de travails des LLM : `AGENTS.md` ;
* Objectifs et architecture du projet : `PROJECT.md` ;
* Cadrage technique : `TECHNICAL.md` ;
* Cadrage de conteneurisation : `BUILD.md` ;

Toutes les opérations DOIVENT être réalisées relativement à `/workspace`.

L'agent NE DOIT PAS créer, modifier ou supprimer de fichier hors de `/workspace` sans validation explicite du développeur.

TECHNICAL.md et BUILD.md ne sont pas nécessairement présents, et restent complémentaires et optionnelles.

## 2. Priorité des règles

En cas de contradiction, appliquer cet ordre :

1. Demande explicite du développeur ;
2. Spécifications OpenSpec validées ;
3. Règles de sécurité et de travails des LLM : `AGENTS.md` ;
4. Objectifs et architecture du projet : `PROJECT.md` ;
5. Cadrage technique : `TECHNICAL.md` ;
6. Cadrage de conteneurisation : `BUILD.md` ;
7. documentation officielle du projet ;
8. code existant.

Une spécification OpenSpec validée prévaut sur un code contradictoire.

La stabilité du projet prévaut sur l'optimisation.

Un `AGENTS.md` situé dans un sous-répertoire s'applique uniquement lorsqu'il est explicitement chargé ou lorsque l'agent travaille depuis ce sous-répertoire.

Il DOIT reprendre explicitement les règles générales qui doivent continuer à s'appliquer.

En cas de conflit, le `AGENTS.md` le plus proche du fichier concerné prévaut, sauf instruction explicite du développeur.

## 3. Ordre de lecture

Avant toute intervention, l'agent DOIT lire uniquement ce qui est nécessaire, dans cet ordre :

1. `AGENTS.md` ;
2. `PROJECT.md` ;
2. `TECHNICAL.md` ;
2. `BUILD.md` ;
3. spécifications ou évolution OpenSpec applicables ;
4. conventions applicables du projet ;
5. code et documentation concernés.

L'agent DOIT privilégier :

* les recherches ciblées ;
* les lectures partielles ;
* les lectures incrémentales ;
* les répertoires directement concernés.

Il NE DOIT PAS parcourir récursivement l'ensemble du dépôt lorsqu'une lecture ciblée suffit.

## 4. Principes fondamentaux

L'agent DOIT privilégier :

* la stabilité ;
* la reproductibilité ;
* la simplicité ;
* la lisibilité ;
* la maintenabilité ;
* la sécurité ;
* la traçabilité ;
* la modularité ;
* la compatibilité.

L'agent DOIT réaliser la modification minimale répondant correctement à l'objectif validé.

Il DOIT préserver tout comportement existant non concerné par la demande.

Il NE DOIT PAS effectuer sans rapport avec la demande :

* de correction ;
* de refactoring ;
* d'optimisation ;
* de reformatage ;
* de renommage ;
* de réorganisation ;
* de modification de convention.

Toute amélioration non demandée DOIT être proposée séparément.

Une évolution complexe DEVRAIT être découpée en modifications indépendantes, testables et réversibles.

## 5. Méthode de travail et autorisations

Avant toute modification, l'agent DOIT :

1. comprendre la demande ;
2. consulter les éléments OpenSpec applicables ;
3. examiner l'implémentation actuelle ;
4. identifier les fichiers concernés ;
5. déterminer la modification minimale nécessaire ;
6. obtenir une validation explicite lorsqu'elle est requise.

L'agent DOIT modifier uniquement les fichiers nécessaires à l'objectif validé.

Lorsqu'une validation explicite est requise mais absente, l'agent DOIT se limiter à l'analyse et aux propositions.

Une validation explicite correspond à une demande ou confirmation claire du développeur autorisant l'action concernée.

Après modification, l'agent DOIT :

1. examiner les fichiers modifiés ;
2. vérifier leur syntaxe ;
3. exécuter les tests et vérifications applicables ;
4. vérifier la conformité OpenSpec ;
5. vérifier l'absence de modification hors périmètre ;
6. rapporter les fichiers modifiés, validations, impacts, échecs et incertitudes.

## 6. Modifications fonctionnelles et OpenSpec

OpenSpec constitue la source de vérité fonctionnelle et technique du projet.

Sources faisant autorité :

* `openspec/config.yaml`
* `openspec/changes/`
* `openspec/specs/`

L'agent DOIT consulter les spécifications applicables avant toute évolution fonctionnelle.

Il NE DOIT PAS implémenter une fonctionnalité absente d'une spécification validée, sauf autorisation explicite du développeur.

Toute évolution fonctionnelle DOIT être précédée ou accompagnée de la création ou mise à jour OpenSpec correspondante.

L'agent NE DOIT PAS créer une nouvelle évolution OpenSpec de sa propre initiative.

La création, modification, suppression ou régénération d'éléments OpenSpec nécessite :

* une demande explicite de travail sur les spécifications ;
* une validation explicite du développeur ;
* ou une commande OpenSpec explicitement demandée autorisant cette écriture.

La demande explicite d'une des commandes suivantes autorise les écritures OpenSpec nécessaires à son exécution :

* `/opsx-propose`
* `/opsx-new`
* `/opsx-continue`
* `/opsx-update`
* `/opsx-sync`
* `/opsx-archive`

### Délégation de pilotage OpenSpec

Lorsqu'un agent orchestrateur tel que CGPT pilote un agent de codage, il PEUT valider et autoriser les créations, modifications, corrections, synchronisations et archivages OpenSpec nécessaires à l'objectif demandé, à condition qu'ils respectent strictement les spécifications OpenSpec préalablement validées par le développeur.

Avant toute écriture OpenSpec, l'agent de codage DOIT présenter à l'agent orchestrateur les fichiers concernés et les modifications proposées, puis attendre sa validation explicite. La validation de l'agent orchestrateur vaut alors autorisation d'écriture dans ce périmètre.

L'agent de codage NE DOIT PAS valider seul ses modifications OpenSpec, étendre le périmètre validé, créer une évolution non demandée, ni effectuer un commit ou un push sans autorisation distincte.

Le développeur peut limiter ou révoquer cette délégation à tout moment. Ses instructions prévalent toujours.

Les spécifications OpenSpec DOIVENT rester cohérentes entre elles.

## 7. OpenCode

OpenCode est un composant technique du projet.

Les éléments suivants sont générés par OpenSpec/OpenCode et NE DOIVENT PAS être modifiés manuellement sans autorisation explicite :

* `.opencode/commands/`
* `.opencode/skills/`

Toute modification de la configuration OpenCode nécessite une validation explicite concernant OpenCode ou son intégration avec OpenSpec.

## 8. Arborescence et fichiers

L'agent DOIT préserver l'arborescence et les conventions existantes.

Le renommage, déplacement ou la suppression d'un fichier ou répertoire nécessite une validation explicite du développeur.

Lorsqu'un fichier semble inutilisé, l'agent DOIT le signaler avant toute suppression.

Toute suppression de code existant DOIT être limitée au strict nécessaire et justifiée.

Les fichiers temporaires ou artefacts de construction explicitement régénérables PEUVENT être supprimés puis recréés lorsque nécessaire.

Les éléments versionnés ou protégés suivants NE DOIVENT PAS être supprimés ou régénérés sans validation explicite :

* `.gitignore`
* `AGENTS.md`
* `BUILD.md`
* `LICENSE`
* `PROJECT.md`
* `README.md`
* `TECHNICAL.md`
* `.opencode/commands/`
* `.opencode/skills/`
* `.opencode/config/opencode.json`
* `openspec/config.yaml`
* `openspec/changes/`
* `openspec/specs/`

## 9. Sources du projet

Les fichiers du projet non explicitement exclus PEUVENT être utilisés comme sources :

* de code ;
* de documentation ;
* d'informations techniques ;
* d'informations fonctionnelles.

Les sources exclues NE DOIVENT PAS être lues, analysées, indexées ou utilisées :

```text id="6zj1eg"
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
```

### Inclusions explicites

Les inclusions suivantes prévalent sur les exclusions générales et PEUVENT être consultées lorsque nécessaire :

```text id="3ewy6y"
.gitignore
AGENTS.md
BUILD.md
LICENSE
PROJECT.md
README.md
TECHNICAL.md
.opencode/commands/
.opencode/config/opencode.json
.opencode/skills/
openspec/AGENTS.md
openspec/config.yaml
openspec/changes/
openspec/specs/
output/
reports/
```

Ces éléments ne constituent pas nécessairement une source de vérité fonctionnelle.

Leur modification nécessite une demande ou validation explicite concernant, selon le cas :

* OpenCode ;
* OpenSpec ;
* Git ;
* la production de rapports techniques.

`output/` et `reports/` :

* PEUVENT être lus ;
* NE DOIVENT PAS être considérés comme source de vérité ;
* NE DOIVENT PAS être versionnés dans Git ;
* NE DOIVENT être créés, modifiés ou supprimés que pour une demande explicite.

## 10. Secrets

L'agent NE DOIT PAS :

* ouvrir un fichier sensible ;
* transmettre un secret au modèle ;
* analyser un secret ;
* indexer un secret ;
* ajouter un secret à Git ;
* afficher un secret dans les journaux ou sorties.

Les données sensibles comprennent notamment :

* mots de passe ;
* clés privées ;
* clés SSH ;
* jetons d'API ;
* certificats ;
* identifiants de connexion.

Pour un fichier sensible, l'agent PEUT uniquement signaler sa présence à partir de son nom ou chemin.

Les secrets DOIVENT rester hors des sources versionnées et accessibles aux agents.

Un emplacement local tel que `.opencode/share/` PEUT contenir des secrets uniquement s'il est exclu :

* de Git ;
* de la lecture par les agents ;
* de l'indexation.

## 11. Sécurité

L'agent DOIT privilégier :

* le principe du moindre privilège ;
* la validation des entrées ;
* la gestion explicite des erreurs ;
* des permissions minimales ;
* l'absence de données sensibles dans les journaux.

L'agent NE DOIT PAS supposer disposer d'un accès complet à la machine hôte.

Sans validation explicite, il NE DOIT PAS modifier :

* les montages Docker ;
* les volumes ;
* les utilisateurs du conteneur ;
* les droits d'accès du conteneur ;
* les permissions accordées au conteneur.

## 12. Git

Sans validation explicite du développeur, l'agent NE DOIT PAS :

* modifier `.git/` ;
* réécrire l'historique ;
* supprimer des commits ;
* effectuer un push ;
* modifier la configuration Git du dépôt ;
* créer, modifier ou supprimer des branches ;
* modifier les sous-modules ;
* créer ou modifier des hooks Git.

Les commits DOIVENT être atomiques.

Un commit DOIT correspondre à une modification clairement identifiable.

Un commit NE DOIT PAS mélanger des modifications indépendantes de type :

* correction ;
* refactoring ;
* évolution fonctionnelle ;
* documentation.

Avant toute proposition de commit, l'agent DOIT :

1. vérifier la syntaxe ;
2. examiner les fichiers modifiés ;
3. vérifier que seuls les fichiers attendus sont modifiés ;
4. vérifier qu'aucun secret n'a été ajouté ;
5. exécuter les vérifications disponibles ;
6. décrire clairement le contenu du commit.

## 13. Bash et Shell

Les scripts DOIVENT rester compatibles avec la version de Bash fournie par les versions Debian supportées.

Les constructions POSIX DEVRAIENT être privilégiées lorsqu'elles permettent simplement le même résultat.

Une fonctionnalité spécifique à une version récente de Bash nécessite une justification claire.

Pour Bash, les vérifications minimales sont :

```bash id="8vhj9b"
bash -n <fichier>
shellcheck <fichier>
```

Les scripts DOIVENT :

* protéger les variables par des guillemets lorsque nécessaire ;
* gérer explicitement les échecs attendus ;
* détecter, traiter et signaler clairement les erreurs ;
* NE JAMAIS ignorer silencieusement une erreur ;
* préserver les comportements existants non concernés.

## 14. Variables

Les variables de configuration DOIVENT rester cohérentes avec les spécifications.

Les noms existants suffisamment explicites DOIVENT être conservés.

Les renommages purement esthétiques sont interdits.

Les valeurs codées en dur DOIVENT être évitées lorsque cela est raisonnable.

Une variable existante DOIT être réutilisée lorsqu'elle répond déjà au besoin.

Toute nouvelle variable de configuration DOIT être documentée dans OpenSpec.

Conventions :

* globale : `MAJUSCULE`
* locale : `minuscule`
* séparateur : `_`
* nouvelles variables : anglais

Pour toutes les spécifications techniques générales, se référer au fichier TECHNICAL.md.

## 15. Chemins, compatibilité et portabilité

L'agent DOIT privilégier les chemins relatifs au projet lorsqu'ils préservent la portabilité.

Les chemins absolus DEVRAIENT être utilisés uniquement lorsqu'ils sont imposés par le projet.

Toute modification DOIT préserver la compatibilité avec :

* les installations existantes ;
* les versions stables de Debian supportées.

Toute incompatibilité DOIT être explicitement signalée et spécifiée.

Toute dépendance spécifique à une distribution ou version DOIT être documentée.

## 16. Idempotence

Les scripts d'installation DEVRAIENT être idempotents lorsque raisonnablement possible.

Une nouvelle exécution NE DOIT PAS provoquer d'effets de bord inattendus.

## 17. Dépendances

L'agent DEVRAIT privilégier les outils disponibles dans une installation Debian standard.

Une dépendance existante DOIT être réutilisée lorsqu'elle répond au besoin.

Toute nouvelle dépendance nécessite :

* une justification ;
* une validation explicite du développeur ;
* une documentation.

## 18. Conventions et style

L'agent DOIT respecter les conventions existantes :

* nommage ;
* organisation ;
* formatage ;
* architecture.

Une convention existante NE DOIT PAS être modifiée sans validation explicite.

En cas d'ambiguïté, l'agent DOIT privilégier la cohérence avec le code existant.

Il DEVRAIT privilégier :

* les fonctions courtes ;
* les noms explicites ;
* une indentation homogène ;
* les commentaires utiles ;
* les traitements simples ;
* le principe KISS.

La simplicité prévaut sur l'optimisation prématurée.

Les commentaires existants DOIVENT être conservés lorsqu'ils restent exacts.

Un nouveau commentaire DOIT apporter une information utile et ne pas simplement répéter le code.

L'agent NE DOIT PAS introduire `TODO`, `FIXME` ou `HACK` sans validation explicite.

Un travail incomplet DEVRAIT être représenté dans OpenSpec plutôt que laissé sous forme de marqueur dans le code.

## 19. Documentation, encodage et licences

Toute évolution importante DOIT mettre à jour, lorsque nécessaire :

* les spécifications ;
* la documentation ;
* les commentaires concernés.

La documentation sans rapport avec la demande NE DOIT PAS être modifiée.

Tous les fichiers texte DOIVENT utiliser :

* UTF-8 ;
* fins de ligne Unix LF.

Les fins de ligne CRLF NE DOIVENT PAS être introduites.

Les en-têtes de licence existants DOIVENT être conservés.

Aucune licence NE DOIT être modifiée sans validation explicite.

## 20. Messages et robustesse

Les messages des scripts DOIVENT être :

* explicites ;
* cohérents ;
* utiles au suivi ;
* utiles au diagnostic.

Ils NE DOIVENT PAS :

* masquer un échec ;
* ignorer silencieusement une erreur ;
* exposer des données sensibles ;
* modifier le comportement fonctionnel attendu.

Le code DEVRAIT privilégier :

* une gestion explicite des erreurs ;
* des messages d'erreur compréhensibles ;
* des codes de retour explicites ;
* la validation des entrées ;
* l'idempotence lorsque pertinente.

## 21. Tests et validation finale

Lorsqu'un mécanisme de test existe, l'agent DOIT exécuter les tests applicables avant de déclarer le travail valide.

Pour Bash, les vérifications minimales sont :

```bash id="h2j28x"
bash -n
shellcheck
```

Avant de déclarer une modification valide, l'agent DOIT vérifier :

* la syntaxe ;
* l'absence d'erreur évidente ;
* la cohérence des fichiers modifiés ;
* la conformité avec OpenSpec ;
* l'absence de modification hors périmètre.

L'agent NE DOIT JAMAIS déclarer qu'un test ou une vérification a réussi s'il ne l'a pas réellement exécuté avec succès.
EOF
} > "$project_path/AGENTS.md"

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

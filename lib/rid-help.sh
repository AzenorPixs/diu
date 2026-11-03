#!/usr/bin/env bash

rid_help_line() {
    printf '%-54s → %s\n' "$1" "$2"
}

rid_display_help_context() {
    local context="${1:-}" subcontext="${2:-}" leaf="${3:-}" target="${4:-}"

    case "$context:$subcontext:$leaf" in
        projects::|projects:build:*|projects:deb:*|projects:docker:*|projects:git:*|projects:cicd:*|projects:cicddiu:*|projects:cicddr:*|projects:forgejo:push|projects:gitlab:push|projects:github:push|projects:forgejo:release|projects:gitlab:release|projects:github:release)
            printf '%s\n' 'Version prioritaire optionnelle : PROJECT_VERSION=x.y.z dans project.env ; sans cette clé, mécanismes actuels conservés.'
            printf '%s\n' 'Valeur présente invalide : erreur. Tag Git : v<VERSION> ; Docker : <VERSION> et latest ; Debian : priorité sur recette et tags.'
            printf '%s\n' 'Un tag existant ne sera pas remplacé ; les publications vérifient sa concordance avec HEAD.'
            ;;
    esac

    if [[ "$context:$subcontext" == projects:github && ( -z "$leaf" || "$leaf" == release ) ]]; then
        printf '%s\n' "GitHub release : PROJECT_DOCKERED=Yes/YES/1 publie l’image sur GHCR ; PROJECT_DEBIAN_PACKAGE=Yes/YES/1 publie le .deb dans GitHub Releases ; les deux sont possibles."
        printf '%s\n' 'Artefacts déjà construits, sans build ; contrôles Debian identiques à Forgejo, refus si une release existe déjà.'
    fi

    if [[ "$context:$subcontext" == projects:build ]]; then
        if [[ $# -gt 4 || ( -n "$leaf" && "$leaf" != deb && "$leaf" != debian ) ||
            ( -n "$target" && ( ! "$target" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ||
                "$target" == . || "$target" == .. ) ) ]]; then
            rid_display_command_error projects build
            return 2
        fi
        rid_help_line 'rid projects build debian <ID PROJECT>' 'Construit le paquet Debian défini par la recette du projet.'
        rid_help_line 'rid projects build deb <ID PROJECT>' 'Alias compatible de build debian.'
        printf '%s\n' 'Recette requise : build/debian-package.json ; elle est exclue du paquet.'
        printf '%s\n' 'Activation dans project.env : PROJECT_DEBIAN_PACKAGE=Yes, YES ou 1 ; sinon aucun paquet Debian.'
        printf '%s\n' 'Packaging activé et recette absente : erreur, le paquet ne peut pas être construit.'
        return 0
    fi

    if [[ "$context:$subcontext" == projects:deb ]]; then
        if [[ $# -gt 3 || ( -n "$leaf" && ( ! "$leaf" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ||
            "$leaf" == . || "$leaf" == .. ) ) ]]; then
            rid_display_command_error projects deb
            return 2
        fi
        rid_help_line 'rid projects deb [ID PROJECT]' 'Construit le paquet DIU depuis ce projet source ; défaut : diu.'
        rid_help_line 'rid proj deb <ID PROJECT>' 'Alias du packaging DIU avec source explicite.'
        return 0
    fi

    if [[ "$context:$subcontext" == system:drivers ]]; then
        if [[ $# -gt 4 || ( -n "$target" && "$target" != displaylink ) ]]; then
            rid_display_command_error system drivers
            return 2
        fi
        case "$leaf" in
            "") [[ -z "$target" ]] || return 2
                rid_help_line "rid system drivers install displaylink" "Installe et valide le pilote DisplayLink (PHYSICAL/PROXMOX)."
                rid_help_line "rid system drivers remove displaylink" "Supprime le pilote DisplayLink." ;;
            install|remove) rid_help_line "rid system drivers $leaf displaylink" "Gère le pilote DisplayLink et son état de configuration." ;;
            *) rid_display_command_error system drivers; return 2 ;;
        esac
        return 0
    fi

    if [[ "$context:$subcontext" == projects:update ]]; then
        if [[ $# -gt 3 ]]; then
            rid_display_command_error projects update
            return 2
        fi
        if [[ -n "$leaf" ]]; then
            rid_help_line "rid projects update ${leaf}" 'Met à jour les variables générales de ce seul projet, avec saisie interactive.'
        else
            rid_help_line 'rid projects update' 'Applique tous les modèles à tous les projets configurés ; OpenSpec puis DevOps en dernier pour chaque projet.'
            rid_help_line 'rid projects update <ID PROJECT>' 'Met à jour les variables générales du seul projet ciblé, avec saisie interactive.'
            printf '%s\n' 'Sans identifiant : même sélection project.env, traitement et bilan que rid projects template all all.'
        fi
        return 0
    fi

    if [[ "$context:$subcontext" == projects:template ]]; then
        if [[ "$leaf" == all ]]; then
            if [[ $# -gt 4 || ( -n "$target" && "$target" != all ) ]]; then
                rid_display_command_error projects template all
                return 2
            fi
            rid_help_line 'rid projects template all all' 'Applique tous les modèles à tous les projets configurés ; OpenSpec puis DevOps en dernier pour chaque projet.'
            printf '%s\n' 'Premier all : tous les modèles, actuellement OpenSpec et DevOps ; second all : tous les projets configurés.'
            printf '%s\n' 'Variables requises dans project.env : PROJECT_ID PROJECT_NAME PROJECT_TYPE PROJECT_DOCKERED PROJECT_DEBIAN_PACKAGE ; PROJECT_ID doit correspondre au dossier.'
            printf '%s\n' 'Un échec OpenSpec empêche DevOps pour ce projet ; le traitement poursuit les autres projets et affiche un bilan.'
            return 0
        fi
        if [[ "$leaf" == openspec ]]; then
            if [[ $# -gt 4 || "$target" == */* || "$target" == . ||
                "$target" == .. || "$target" =~ [[:cntrl:]] ]]; then
                rid_display_command_error projects template openspec
                return 2
            fi
            if [[ "$target" == all ]]; then
                rid_help_line 'rid projects template openspec all' 'Initialise ou actualise OpenSpec pour tous les projets configurés ; poursuit après un échec et affiche un bilan.'
                printf '%s\n' 'Variables requises dans project.env : PROJECT_ID PROJECT_NAME PROJECT_TYPE PROJECT_DOCKERED PROJECT_DEBIAN_PACKAGE.'
            else
                local openspec_project="${target:-<ID PROJECT>}"
                rid_help_line "rid projects template openspec ${openspec_project}" "Initialise ou actualise OpenSpec via ENV_DEVOPS_USER pour le projet ${openspec_project}"
                printf '%s\n' 'Initialisation avec profil custom ; opencode si OPENCODE=1 et dossier .opencode présent ; sans ce dossier : équivalent à OPENCODE=0 ; projet existant : openspec update.'
                if [[ -z "$target" ]]; then
                    rid_help_line 'rid projects template openspec all' 'Initialise ou actualise OpenSpec pour tous les projets configurés.'
                fi
            fi
            return 0
        fi
        if [[ "$leaf" == devops ]]; then
            if [[ $# -gt 4 || "$target" == */* || "$target" == . ||
                "$target" == .. || "$target" =~ [[:cntrl:]] ]]; then
                rid_display_command_error projects template devops
                return 2
            fi
            if [[ "$target" == all ]]; then
                rid_help_line 'rid projects template devops all' 'Génère DEVOPS.md pour tous les projets configurés ; poursuit après un échec.'
                printf '%s\n' 'Variables requises dans project.env : PROJECT_ID PROJECT_NAME PROJECT_TYPE PROJECT_DOCKERED PROJECT_DEBIAN_PACKAGE.'
            else
                rid_help_line "rid projects template devops ${target:-<ID PROJECT>}" 'Crée ou actualise DEVOPS.md pour ce projet ; manifeste minimal si PROJECT_TYPE=PYTHON.'
                if [[ -z "$target" ]]; then
                    rid_help_line 'rid projects template devops all' 'Génère DEVOPS.md pour tous les projets configurés.'
                fi
            fi
        elif [[ $# -le 4 && -z "$leaf" && -z "$target" ]]; then
            rid_help_line 'rid projects template devops <ID PROJECT>' 'Crée ou actualise DEVOPS.md pour le projet ; manifeste minimal si PROJECT_TYPE=PYTHON.'
            rid_help_line 'rid projects template openspec <ID PROJECT>' 'Initialise ou actualise OpenSpec via ENV_DEVOPS_USER pour le projet <ID PROJECT>'
            rid_help_line 'rid projects template openspec all' 'Initialise ou actualise OpenSpec pour tous les projets configurés.'
            rid_help_line 'rid projects template devops all' 'Génère DEVOPS.md pour tous les projets configurés.'
            rid_help_line 'rid projects template all all' 'Applique tous les modèles à tous les projets configurés ; OpenSpec puis DevOps en dernier pour chaque projet.'
        else
            rid_display_command_error projects template
            return 2
        fi
        return 0
    fi

    case "$context:$subcontext:$leaf" in
        infos::)
            rid_help_line 'rid infos' 'Affiche les informations de tous les modules.'
            ;;
        diu::)
            rid_help_line 'rid diu infos' 'Affiche les informations du DIU.'
            rid_help_line 'rid diu update' 'Met à jour le paquet DIU depuis GitHub.'
            ;;
        diu:update:|update:diu:)
            rid_help_line 'rid diu update' 'Met à jour le paquet DIU depuis GitHub.'
            ;;
        desktop::|environnements::)
            rid_help_line "rid ${context} infos" 'Affiche les informations du module.'
            ;;
        desktop:infos:|diu:infos:|environnements:infos:|ia:infos:|projects:infos:|softwares:infos:)
            rid_help_line "rid ${context} infos" 'Affiche les informations du module.'
            ;;
        system:infos:)
            rid_help_line 'rid system infos' 'Affiche toutes les informations système.'
            rid_help_line 'rid system infos network' 'Affiche les informations réseau.'
            rid_help_line 'rid system infos debian' 'Affiche la configuration Debian, APT et Flatpak.'
            rid_help_line 'rid system infos drivers' "Affiche l’état DisplayLink et la version du pilote installé."
            ;;
        system:infos:network|system:infos:debian|system:infos:drivers)
            rid_help_line "rid system infos ${leaf}" 'Affiche les informations système demandées.'
            ;;
        ::)
            rid_help_line 'rid system infos drivers' "Affiche l’état DisplayLink et la version du pilote installé."
            rid_help_line 'rid system drivers install displaylink' 'Installe et valide le pilote DisplayLink.'
            rid_help_line 'rid system drivers remove displaylink' 'Supprime le pilote DisplayLink.'
            rid_help_line 'rid infos' 'Affiche les informations de tous les modules.'
            rid_help_line 'rid desktop infos' 'Affiche les informations du bureau.'
            rid_help_line 'rid diu infos' 'Affiche les informations et la version du DIU.'
            rid_help_line 'rid diu update' 'Met à jour le paquet DIU.'
            rid_help_line 'rid environnements infos' 'Affiche les informations des environnements.'
            rid_help_line 'rid ia infos' 'Affiche les informations IA.'
            rid_help_line 'rid projects infos' 'Affiche les informations des projets.'
            rid_help_line 'rid softwares infos' 'Affiche les informations des logiciels.'
            rid_help_line 'rid system infos' 'Affiche toutes les informations système.'
            rid_help_line 'rid devops' 'Outils DevOps et OpenSpec.'
            rid_help_line 'rid docker' 'Gestion Docker root et rootless.'
            rid_help_line 'rid ia' 'Gestion des agents IA.'
            rid_help_line 'rid os' 'Validation OpenSpec.'
            rid_help_line 'rid projects' 'Gestion des projets et publications.'
            rid_help_line 'rid install' 'Installation de logiciels.'
            rid_help_line 'rid remove' 'Suppression de logiciels.'
            rid_help_line 'rid update' 'Mise à jour des composants.'
            rid_help_line 'rid softwares' 'Gestion des logiciels.'
            rid_help_line 'rid system' 'Gestion du système Debian.'
            rid_help_line 'rid version' 'Affiche la version du DIU.'
            ;;
        softwares::)
            rid_help_line 'rid softwares infos' 'Affiche les informations du module.'
            rid_help_line 'rid softwares install apt <SOFTWARE>' 'Installe un logiciel APT.'
            rid_help_line 'rid softwares remove apt <SOFTWARE>' 'Désinstalle un logiciel APT.'
            rid_help_line 'rid softwares update apt [SOFTWARE]' 'Met à jour un ou tous les logiciels APT.'
            rid_help_line 'rid softwares apt update' 'Met à jour les paquets installés avec APT.'
            rid_help_line 'rid softwares install github <SOFTWARE>' 'Installe depuis une release GitHub.'
            rid_help_line 'rid softwares remove github <SOFTWARE>' 'Désinstalle un logiciel GitHub.'
            rid_help_line 'rid softwares update github [SOFTWARE]' 'Met à jour un ou tous les logiciels GitHub.'
            rid_help_line 'rid softwares install flatpak <SOFTWARE>' 'Installe un logiciel Flatpak.'
            rid_help_line 'rid softwares remove flatpak <SOFTWARE>' 'Désinstalle un logiciel Flatpak.'
            rid_help_line 'rid softwares flatpak update' 'Met à jour les paquets installés avec Flatpak.'
            ;;
        softwares:install:|softwares:remove:)
            rid_help_line "rid softwares ${subcontext} apt <SOFTWARE>" 'Opération sur un logiciel APT.'
            rid_help_line "rid softwares ${subcontext} github <SOFTWARE>" 'Opération sur un logiciel GitHub.'
            rid_help_line "rid softwares ${subcontext} flatpak <SOFTWARE>" 'Opération sur un logiciel Flatpak.'
            ;;
        softwares:update:)
            rid_help_line 'rid softwares update apt [SOFTWARE]' 'Met à jour les logiciels APT.'
            rid_help_line 'rid softwares update github [SOFTWARE]' 'Met à jour les logiciels GitHub.'
            ;;
        softwares:apt:update)
            rid_help_line 'rid softwares apt update' 'Met à jour les paquets installés avec APT.'
            ;;
        softwares:flatpak:)
            rid_help_line 'rid softwares flatpak update' 'Met à jour les paquets installés avec Flatpak.'
            ;;
        softwares:flatpak:update)
            rid_help_line 'rid softwares flatpak update' 'Met à jour les paquets installés avec Flatpak.'
            ;;
        softwares:install:apt|softwares:remove:apt|softwares:install:github|softwares:remove:github|softwares:update:apt|softwares:update:github|softwares:install:flatpak|softwares:remove:flatpak)
            rid_help_line "rid softwares ${subcontext} ${leaf} <SOFTWARE>" "Exécute l'opération demandée sur le logiciel."
            ;;
        system::)
            rid_help_line 'rid system drivers install displaylink' 'Installe et valide le pilote DisplayLink.'
            rid_help_line 'rid system drivers remove displaylink' 'Supprime le pilote DisplayLink.'
            rid_help_line 'rid system infos' 'Affiche les informations du module.'
            rid_help_line 'rid system infos network' 'Affiche les informations réseau.'
            rid_help_line 'rid system infos debian' 'Affiche la configuration Debian, APT et Flatpak.'
            rid_help_line 'rid system infos drivers' "Affiche l’état DisplayLink et la version du pilote installé."
            rid_help_line 'rid system install apt <Dépôt>' 'Installe un dépôt APT.'
            rid_help_line 'rid system remove apt <Dépôt>' 'Supprime un dépôt APT.'
            rid_help_line 'rid system install flatpak' 'Installe Flatpak et Flathub.'
            rid_help_line 'rid system remove flatpak' 'Désinstalle le paquet Flatpak.'
            rid_help_line 'rid system update flatpak' 'Met à jour le paquet Flatpak.'
            rid_help_line 'rid system update apt' 'Régénère les dépôts APT.'
            rid_help_line 'rid system apt update' 'Met à jour le système APT Debian.'
            ;;
        system:install:|system:remove:)
            rid_help_line "rid system ${subcontext} flatpak" 'Opération sur Flatpak.'
            rid_help_line "rid system ${subcontext} apt <Dépôt>" 'Opération sur un dépôt APT.'
            ;;
        system:install:flatpak|system:remove:flatpak|system:update:flatpak)
            rid_help_line "rid system ${subcontext} ${leaf}" "Exécute l'opération système demandée."
            ;;
        system:update:)
            rid_help_line 'rid system update flatpak' 'Met à jour le paquet Flatpak.'
            rid_help_line 'rid system update apt' 'Met à jour APT.'
            rid_help_line 'rid system update apt debian' 'Met à jour les paquets Debian.'
            ;;
        system:apt:|system:apt:update|system:update:apt)
            rid_help_line 'rid system apt update' 'Met à jour le système APT Debian.'
            ;;
        system:install:apt|system:remove:apt)
            rid_help_line "rid system ${subcontext} apt <Dépôt>" 'Opération sur un dépôt APT reconnu.'
            ;;
        docker::)
            rid_help_line 'rid docker root' 'Actions Docker root.'
            rid_help_line 'rid docker rootless' 'Actions Docker rootless.'
            ;;
        docker:root:)
            rid_help_line 'rid docker root check-containers' 'Liste les conteneurs actifs.'
            rid_help_line 'rid docker root test <USER>' 'Teste Docker pour un utilisateur.'
            rid_help_line 'rid docker root diag <USER>' 'Diagnostique Docker.'
            ;;
        docker:rootless:)
            rid_help_line 'rid docker rootless analyse <USER>' 'Analyse Docker rootless.'
            rid_help_line 'rid docker rootless configure <USER>' 'Configure Docker rootless.'
            rid_help_line 'rid docker rootless delete-state <USER>' "Supprime l'état Docker rootless."
            rid_help_line 'rid docker rootless diag <USER>' 'Diagnostique Docker rootless.'
            rid_help_line 'rid docker rootless exec <USER> <CONTAINER>' 'Exécute dans un conteneur.'
            rid_help_line 'rid docker rootless inspect <USER> <CONTAINER>' 'Inspecte un conteneur.'
            rid_help_line 'rid docker rootless log <USER> <CONTAINER>' "Affiche les journaux d'un conteneur."
            rid_help_line 'rid docker rootless ps <USER>' 'Liste les conteneurs.'
            rid_help_line 'rid docker rootless restore-state <USER>' "Restaure l'état Docker rootless."
            rid_help_line 'rid docker rootless save-state <USER>' "Sauvegarde l'état Docker rootless."
            rid_help_line 'rid docker rootless test <USER>' 'Teste Docker rootless.'
            rid_help_line 'rid docker rootless unconfigure <USER>' 'Déconfigure Docker rootless.'
            ;;
        ia::)
            rid_help_line 'rid ia infos' 'Affiche les informations du module.'
            rid_help_line 'rid ia configure hm' 'Configure Hermès.'
            rid_help_line 'rid ia install hm' 'Installe Hermès.'
            rid_help_line 'rid ia start hm' 'Démarre Hermès.'
            rid_help_line 'rid ia stop hm' 'Arrête Hermès.'
            rid_help_line 'rid ia update hm' 'Met à jour Hermès.'
            rid_help_line 'rid ia uninstall hm' 'Désinstalle Hermès.'
            ;;
        ia:configure:|ia:install:|ia:start:|ia:stop:|ia:update:|ia:uninstall:)
            rid_help_line "rid ia ${subcontext} hm" "Exécute l'opération Hermès demandée."
            ;;
        devops::)
            rid_help_line 'rid devops info' 'Affiche les informations DevOps.'
            rid_help_line 'rid devops os' 'Gère OpenSpec pour un projet.'
            ;;
        os::)
            rid_help_line 'rid os validate <PROJET> <SPEC>' 'Valide une spécification.'
            ;;
        projects::)
            rid_help_line 'rid projects infos' 'Affiche les informations du module.'
            rid_help_line 'rid projects template devops <ID PROJECT>' 'Crée ou actualise DEVOPS.md pour le projet.'
            rid_help_line 'rid projects template openspec <ID PROJECT>' 'Initialise ou actualise OpenSpec via ENV_DEVOPS_USER pour le projet <ID PROJECT>'
            rid_help_line 'rid projects template openspec all' 'Initialise ou actualise OpenSpec pour tous les projets configurés.'
            rid_help_line 'rid projects template devops all' 'Génère DEVOPS.md pour tous les projets configurés.'
            rid_help_line 'rid projects template all all' 'Applique tous les modèles à tous les projets configurés ; OpenSpec puis DevOps en dernier pour chaque projet.'
            rid_help_line 'rid projects create <ID PROJECT>' 'Crée un projet depuis le modèle local, prépare OpenSpec puis génère DEVOPS.md.'
            rid_help_line 'rid projects clone <ID PROJECT SOURCE> <ID PROJECT DESTINATION>' 'Clone un projet local sans ses métadonnées Git.'
            rid_help_line 'rid projects del <ID PROJECT>' 'Supprime un projet.'
            rid_help_line 'rid projects update' 'Applique tous les modèles à tous les projets configurés ; OpenSpec puis DevOps en dernier pour chaque projet.'
            rid_help_line 'rid projects update <ID PROJECT>' 'Met à jour les variables du projet.'
            rid_help_line 'rid projects sync <ID PROJECT>' 'Synchronise le projet depuis le modèle local.'
            rid_help_line 'rid projects sync all' 'Synchronise tous les projets configurés.'
            rid_help_line 'rid projects git commit all' 'Commit tous les dépôts Git configurés.'
            rid_help_line 'rid projects docker' 'Gestion Docker des projets.'
            rid_help_line 'rid projects cicd <ID PROJECT> [VERSION]' 'Exécute la CI/CD conditionnelle du projet.'
            rid_help_line 'rid projects finds <ID PROJECT>' 'Recherche les conflits de synchronisation.'
            rid_help_line 'rid projects findads <ID PROJECT>' 'Supprime les conflits de synchronisation.'
            rid_help_line 'rid projects git' 'Gestion du dépôt local Git.'
            rid_help_line 'rid projects git analyse <ID PROJECTS>' 'Analyse le dépôt Git local.'
            rid_help_line 'rid projects git commit <ID PROJECT> [COMMIT]' 'Commit le dépôt Git local.'
            rid_help_line 'rid projects git init <ID PROJECT>' 'Initialise le dépôt Git local et safe.directory système.'
            rid_help_line 'rid projects gitic <ID PROJECT>' 'Initialise et clone le dépôt Git.'
            rid_help_line 'rid projects gitpdiu' 'Publie le paquet DIU vers Forgejo.'
            rid_help_line 'rid projects git status <ID PROJECTS>' 'Affiche le statut Git et safe.directory système.'
            rid_help_line 'rid projects git update <ID PROJECT>' 'Met à jour les variables Git et safe.directory système.'
            rid_help_line 'rid projects gitlab' 'Gestion des dépôts GitLab.'
            rid_help_line 'rid projects gitlab clone <ID PROJECT>' 'Crée et fusionne un dépôt GitLab distant.'
            rid_help_line 'rid projects github' 'Gestion des dépôts GitHub.'
            rid_help_line 'rid projects github clone <ID PROJECT>' 'Crée et fusionne un dépôt GitHub distant.'
            rid_help_line 'rid projects forgejo' 'Gestion des dépôts Forgejo.'
            rid_help_line 'rid projects forgejo push all' 'Pousse tous les dépôts Forgejo configurés.'
            rid_help_line 'rid projects ocro <ID PROJECT>' 'Ouvre le projet en lecture seule.'
            rid_help_line 'rid projects ocrw <ID PROJECT>' 'Ouvre le projet en lecture-écriture.'
            rid_help_line 'rid projects ocsh <ID PROJECT>' 'Ouvre un shell dans le projet.'
            rid_help_line 'rid projects deb [ID PROJECT]' 'Construit le paquet DIU ; source par défaut : diu.'
            rid_help_line 'rid projects build debian <ID PROJECT>' 'Construit un paquet Debian depuis build/debian-package.json (PROJECT_DEBIAN_PACKAGE=Yes/YES/1).'
            rid_help_line 'rid projects build deb <ID PROJECT>' 'Alias compatible de build debian.'
            rid_help_line 'rid projects cicddiu' 'Lance la CI/CD du projet DIU.'
            rid_help_line 'rid projects cicddr <ID PROJECT>' 'Lance la CI/CD du projet.'
            ;;
        projects:cicd:|projects:cicd:*)
            rid_help_line 'rid projects cicd <ID PROJECT> [VERSION]' 'Configure éventuellement PROJECT_VERSION puis exécute les six étapes CI/CD.'
            printf '%s\n' '1. Commit/tag ; 2. Pushes Git ; 3. Build Docker ; 4. Build Debian ; 5. Publications ; 6. Bilan.'
            printf '%s\n' 'Build Debian indépendant de Docker : PROJECT_DEBIAN_PACKAGE=Yes/YES/1 ; même moteur que rid projects build debian <ID PROJECT>.'
            printf '%s\n' 'Un échec du build empêche les releases ; les pushes déjà réalisés restent publiés.'
            printf '%s\n' "À l’étape 5, Debian peut être publié sur Forgejo, GitLab et GitHub selon leur configuration, même sans Docker."
            printf '%s\n' 'Les messages identifient la forge, le tag et les contrôles effectivement réalisés.'
            printf '%s\n' 'Un tag existant est rejoué depuis son commit isolé ; les modifications locales ne sont pas livrées.'
            printf '%s\n' "En rejeu, la publication Docker est ignorée : l'immutabilité du tag distant n'est pas vérifiée."
            ;;
        projects:cicddiu:|projects:cicddiu:*)
            rid_help_line 'rid projects cicddiu [COMMIT] [TAG]' 'Exécute la CI/CD du DIU ; PROJECT_VERSION est prioritaire pour le tag.'
            ;;
        projects:cicddr:|projects:cicddr:*)
            rid_help_line 'rid projects cicddr <ID PROJECT> [COMMIT] [TAG]' 'Exécute la CI/CD Docker ; PROJECT_VERSION est prioritaire pour le tag.'
            ;;
        projects:docker:)
            rid_help_line 'rid projects docker build <ID PROJECT>' "Construit l'image Docker du projet."
            ;;
        projects:create:)
            rid_help_line 'rid projects create <ID PROJECT>' 'Crée un projet depuis le modèle local, prépare OpenSpec puis génère DEVOPS.md.'
            ;;
        projects:clone:)
            rid_help_line 'rid projects clone <ID PROJECT SOURCE> <ID PROJECT DESTINATION>' 'Clone un projet local sans ses métadonnées Git.'
            ;;
        projects:sync:)
            rid_help_line 'rid projects sync <ID PROJECT>' 'Synchronise le projet depuis le modèle local.'
            rid_help_line 'rid projects sync all' 'Synchronise tous les projets configurés.'
            ;;
        projects:commit:)
            rid_help_line 'rid projects git commit all' 'Commit tous les dépôts Git configurés.'
            ;;
        projects:git:)
            rid_help_line 'rid projects git analyse <ID PROJECTS>' 'Analyse le dépôt Git local.'
            rid_help_line 'rid projects git commit <ID PROJECT> [COMMIT]' 'Commit le dépôt Git local.'
            rid_help_line 'rid projects git commit all' 'Commit tous les dépôts Git configurés.'
            rid_help_line 'rid projects git init <ID PROJECT>' 'Initialise le dépôt Git local et safe.directory système.'
            rid_help_line 'rid projects git status <ID PROJECTS>' 'Affiche le statut Git et safe.directory système.'
            rid_help_line 'rid projects git update <ID PROJECT>' 'Met à jour les variables Git et safe.directory système.'
            ;;
        projects:git:commit)
            rid_help_line 'rid projects git commit <ID PROJECT> [COMMIT]' 'Commit le dépôt Git local.'
            rid_help_line 'rid projects git commit all' 'Commit tous les dépôts Git configurés.'
            ;;
        projects:git:status)
            rid_help_line 'rid projects git status <ID PROJECTS>' 'Affiche le statut Git et safe.directory système.'
            ;;
        projects:gitlab:|projects:github:|projects:forgejo:)
            rid_help_line "rid projects ${subcontext} update <ID PROJECT>" 'Met à jour la configuration distante.'
            rid_help_line "rid projects ${subcontext} push <ID PROJECT>" 'Pousse le dépôt local.'
            if [[ "${subcontext}" == "gitlab" ]]; then
                rid_help_line 'rid projects gitlab clone <ID PROJECT>' 'Crée et fusionne un dépôt GitLab distant.'
            fi
            if [[ "${subcontext}" == "github" ]]; then
                rid_help_line 'rid projects github clone <ID PROJECT>' 'Crée et fusionne un dépôt GitHub distant.'
            fi
            if [[ "${subcontext}" == "forgejo" ]]; then
                rid_help_line 'rid projects forgejo push all' 'Pousse tous les dépôts Forgejo configurés.'
            fi
            rid_help_line "rid projects ${subcontext} release <ID PROJECT>" 'Publie les artefacts du projet.'
            ;;
        projects:docker:build|projects:git:update|projects:gitlab:clone|projects:gitlab:update|projects:gitlab:push|projects:gitlab:release|projects:github:clone|projects:github:update|projects:github:push|projects:github:release|projects:forgejo:update|projects:forgejo:push|projects:forgejo:release)
            rid_help_line "rid projects ${subcontext} ${leaf} <ID PROJECT>" "Exécute l'opération demandée."
            if [[ "${context}:${subcontext}:${leaf}" == "projects:forgejo:push" ]]; then
                rid_help_line 'rid projects forgejo push all' 'Pousse tous les dépôts Forgejo configurés.'
            fi
            ;;
        install::|remove::)
            rid_help_line "rid ${context} deb <SOFTWARE>" 'Opération sur un paquet Debian.'
            rid_help_line "rid ${context} apt <SOFTWARE>" 'Opération sur un logiciel tiers.'
            ;;
        update::)
            rid_help_line 'rid update' 'Met à jour le DIU en premier, puis les autres modules et les modèles via rid projects update.'
            rid_help_line 'rid update diu' 'Alias de rid diu update.'
            ;;
        *)
            rid_display_command_error "$context" "$subcontext" "$leaf"
            return 2
            ;;
    esac
}

rid_display_command_error() {
    local context="${1:-}" subcontext="${2:-}" leaf="${3:-}" help_context=''

    if [[ -z "$context" ]]; then
        case "${argument_class:-}" in
            devops|docker|ia|os|projects|install|remove|softwares|system|update)
                context="$argument_class"
                ;;
        esac
    fi

    if [[ -z "$subcontext" ]]; then
        case "$context:${action:-}" in
            docker:root|docker:rootless|ia:configure|ia:install|ia:start|ia:stop|ia:update|ia:uninstall|system:install|system:remove|system:update|system:apt|softwares:install|softwares:remove|softwares:update|softwares:apt|softwares:flatpak|projects:docker|projects:git|projects:gitlab|projects:github|projects:forgejo)
                subcontext="$action"
                ;;
        esac
    fi

    if [[ -n "$context" ]]; then
        help_context=" $context"
    fi
    if [[ -n "$subcontext" ]]; then
        help_context+=" $subcontext"
    fi
    if [[ -n "$leaf" ]]; then
        help_context+=" $leaf"
    fi

    printf '❌ Commande inconnue. Consultez : rid%s help\n' "$help_context"
}

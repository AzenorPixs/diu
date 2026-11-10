#!/usr/bin/env bash

diu_help_line() {
    printf '%-54s → %s\n' "$1" "$2"
}

diu_display_help_context() {
    local context="${1:-}" subcontext="${2:-}" leaf="${3:-}" target="${4:-}"

    case "$context:$subcontext:$leaf" in
        projects::|projects:build:*|projects:deb:*|projects:docker:*|projects:git:*|projects:cicd:*|projects:cicddiu:*|projects:cicddr:*|projects:forgejo:push|projects:gitlab:push|projects:github:push|projects:forgejo:release|projects:gitlab:release|projects:github:release)
            if [[ "$leaf" == push && "$subcontext" =~ ^(forgejo|gitlab|github)$ ]]; then
                printf '%s\n' 'Push direct : VERSION x.y.z ou horodatage si absente ; PROJECT_VERSION reste inchangée.'
                printf '%s\n' 'Tag distant supérieur ou non comparable : refus ; sinon branche et tag sont alignés sous lease.'
                printf '%s\n' 'Version stable prioritaire sur horodatage ; une version attribuée est rejouée isolément.'
            else
                printf '%s\n' 'Version prioritaire optionnelle : PROJECT_VERSION=x.y.z dans project.env ; sans cette clé, mécanismes actuels conservés.'
                printf '%s\n' 'Valeur présente invalide : erreur. Tag Git : v<VERSION> ; Docker : <VERSION> et latest ; Debian : priorité sur recette et tags.'
                printf '%s\n' 'Le tag local ne sera pas déplacé ; les publications vérifient sa concordance avec HEAD.'
            fi
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
            diu_display_command_error projects build
            return 2
        fi
        diu_help_line 'diu projects build debian <ID PROJECT>' 'Construit le paquet Debian défini par la recette du projet.'
        diu_help_line 'diu projects build deb <ID PROJECT>' 'Alias compatible de build debian.'
        printf '%s\n' 'Recette requise : build/debian-package.json ; elle est exclue du paquet.'
        printf '%s\n' 'Activation dans project.env : PROJECT_DEBIAN_PACKAGE=Yes, YES ou 1 ; sinon aucun paquet Debian.'
        printf '%s\n' 'Packaging activé et recette absente : erreur, le paquet ne peut pas être construit.'
        return 0
    fi

    if [[ "$context:$subcontext" == projects:deb ]]; then
        if [[ $# -gt 3 || ( -n "$leaf" && ( ! "$leaf" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ||
            "$leaf" == . || "$leaf" == .. ) ) ]]; then
            diu_display_command_error projects deb
            return 2
        fi
        diu_help_line 'diu projects deb [ID PROJECT]' 'Construit le paquet DIU depuis ce projet source ; défaut : diu.'
        diu_help_line 'diu proj deb <ID PROJECT>' 'Alias du packaging DIU avec source explicite.'
        return 0
    fi

    if [[ "$context:$subcontext" == system:engine ]]; then
        if [[ $# -gt 4 ]]; then
            diu_display_command_error system engine
            return 2
        fi
        case "$leaf:$target" in
            :|install:|remove:|install:apt|install:github|install:flatpak|remove:apt|remove:github|remove:flatpak)
                diu_help_line 'diu system engine install <apt|github|flatpak>' 'Active un moteur et vérifie ses dépendances.'
                diu_help_line 'diu system engine remove <apt|github|flatpak>' 'Désactive un moteur sans supprimer ses dépendances.'
                diu_help_line 'diu system engine update' 'Met à jour successivement les trois moteurs.'
                diu_help_line 'diu system engine apt update' 'Met à jour le système APT et affiche son bilan.'
                diu_help_line 'diu system engine github update' 'Vérifie GitHub et met à jour Codex CLI si configuré.'
                diu_help_line 'diu system engine flatpak update' 'Vérifie Flatpak et Flathub.' ;;
            update:) diu_help_line 'diu system engine update' 'Met à jour successivement les trois moteurs.' ;;
            apt:|github:|flatpak:|apt:update|github:update|flatpak:update)
                diu_help_line "diu system engine ${leaf} update" 'Exécute uniquement le parcours du moteur indiqué.' ;;
            *) diu_display_command_error system engine; return 2 ;;
        esac
        return 0
    fi

    if [[ "$context:$subcontext" == system:network ]]; then
        if [[ $# -gt 6 || ( -n "$leaf" && "$leaf" != update && "$leaf" != hosts ) ||
              ( "$leaf" == update && -n "$target" ) ||
              ( "$leaf" == hosts && -n "$target" && "$target" != update && "$target" != add && "$target" != del && "$target" != list ) ]]; then
            diu_display_command_error system network hosts
            return 2
        fi
        diu_help_line 'diu system network update' 'Met à jour le réseau et reconstruit /etc/hosts.'
        diu_help_line 'diu system network hosts' 'Affiche le contenu actuel de /etc/hosts.'
        diu_help_line 'diu system network hosts update' 'Reconstruit /etc/hosts depuis le hosts.json de production.'
        diu_help_line 'diu system network hosts add <IP> <FQDN>' 'Ajoute et trie un couple dans le hosts.json de production.'
        diu_help_line 'diu system network hosts del <IP> <FQDN>' 'Supprime un couple du hosts.json de production.'
        diu_help_line 'diu system network hosts del all' 'Vide le hosts.json de production.'
        diu_help_line 'diu system network hosts list' 'Liste les couples du hosts.json de production.'
        diu_help_line 'diu system network hosts <action> help' "Affiche l'aide de l'action hosts."
        printf '%s\n' 'Lors de la reconstruction de /etc/hosts, les entrées existantes sont remplacées.'
        return 0
    fi

    if [[ "$context:$subcontext" == system:drivers ]]; then
        if [[ $# -gt 4 || ( -n "$target" && "$target" != displaylink ) ]]; then
            diu_display_command_error system drivers
            return 2
        fi
        case "$leaf" in
            "") [[ -z "$target" ]] || return 2
                diu_help_line "diu system drivers install displaylink" "Installe et valide le pilote DisplayLink (PHYSICAL/PROXMOX)."
                diu_help_line "diu system drivers remove displaylink" "Supprime le pilote DisplayLink." ;;
            install|remove) diu_help_line "diu system drivers $leaf displaylink" "Gère le pilote DisplayLink et son état de configuration." ;;
            *) diu_display_command_error system drivers; return 2 ;;
        esac
        return 0
    fi

    if [[ "$context:$subcontext" == projects:update ]]; then
        if [[ $# -gt 3 ]]; then
            diu_display_command_error projects update
            return 2
        fi
        if [[ -n "$leaf" ]]; then
            diu_help_line "diu projects update ${leaf}" 'Met à jour les variables générales de ce seul projet, avec saisie interactive.'
        else
            diu_help_line 'diu projects update' 'Applique tous les modèles à tous les projets configurés ; OpenSpec puis DevOps en dernier pour chaque projet.'
            diu_help_line 'diu projects update <ID PROJECT>' 'Met à jour les variables générales du seul projet ciblé, avec saisie interactive.'
            printf '%s\n' 'Sans identifiant : même sélection project.env, traitement et bilan que diu projects template all all.'
        fi
        return 0
    fi

    if [[ "$context:$subcontext" == projects:template ]]; then
        if [[ "$leaf" == all ]]; then
            if [[ $# -gt 4 || ( -n "$target" && "$target" != all ) ]]; then
                diu_display_command_error projects template all
                return 2
            fi
            diu_help_line 'diu projects template all all' 'Applique tous les modèles à tous les projets configurés ; OpenSpec puis DevOps en dernier pour chaque projet.'
            printf '%s\n' 'Premier all : tous les modèles, actuellement OpenSpec et DevOps ; second all : tous les projets configurés.'
            printf '%s\n' 'Variables requises dans project.env : PROJECT_ID PROJECT_NAME PROJECT_TYPE PROJECT_DOCKERED PROJECT_DEBIAN_PACKAGE ; PROJECT_ID doit correspondre au dossier.'
            printf '%s\n' 'Un échec OpenSpec empêche DevOps pour ce projet ; le traitement poursuit les autres projets et affiche un bilan.'
            return 0
        fi
        if [[ "$leaf" == openspec ]]; then
            if [[ $# -gt 4 || "$target" == */* || "$target" == . ||
                "$target" == .. || "$target" =~ [[:cntrl:]] ]]; then
                diu_display_command_error projects template openspec
                return 2
            fi
            if [[ "$target" == all ]]; then
                diu_help_line 'diu projects template openspec all' 'Initialise ou actualise OpenSpec pour tous les projets configurés ; poursuit après un échec et affiche un bilan.'
                printf '%s\n' 'Variables requises dans project.env : PROJECT_ID PROJECT_NAME PROJECT_TYPE PROJECT_DOCKERED PROJECT_DEBIAN_PACKAGE.'
            else
                local openspec_project="${target:-<ID PROJECT>}"
                diu_help_line "diu projects template openspec ${openspec_project}" "Initialise ou actualise OpenSpec via ENV_DEVOPS_USER pour le projet ${openspec_project}"
                printf '%s\n' 'Initialisation avec profil custom ; opencode si OPENCODE=1 et dossier .opencode présent ; sans ce dossier : équivalent à OPENCODE=0 ; projet existant : openspec update.'
                if [[ -z "$target" ]]; then
                    diu_help_line 'diu projects template openspec all' 'Initialise ou actualise OpenSpec pour tous les projets configurés.'
                fi
            fi
            return 0
        fi
        if [[ "$leaf" == devops ]]; then
            if [[ $# -gt 4 || "$target" == */* || "$target" == . ||
                "$target" == .. || "$target" =~ [[:cntrl:]] ]]; then
                diu_display_command_error projects template devops
                return 2
            fi
            if [[ "$target" == all ]]; then
                diu_help_line 'diu projects template devops all' 'Génère DEVOPS.md pour tous les projets configurés ; poursuit après un échec.'
                printf '%s\n' 'Variables requises dans project.env : PROJECT_ID PROJECT_NAME PROJECT_TYPE PROJECT_DOCKERED PROJECT_DEBIAN_PACKAGE.'
            else
                diu_help_line "diu projects template devops ${target:-<ID PROJECT>}" 'Crée ou actualise DEVOPS.md pour ce projet ; manifeste minimal si PROJECT_TYPE=PYTHON.'
                if [[ -z "$target" ]]; then
                    diu_help_line 'diu projects template devops all' 'Génère DEVOPS.md pour tous les projets configurés.'
                fi
            fi
        elif [[ $# -le 4 && -z "$leaf" && -z "$target" ]]; then
            diu_help_line 'diu projects template devops <ID PROJECT>' 'Crée ou actualise DEVOPS.md pour le projet ; manifeste minimal si PROJECT_TYPE=PYTHON.'
            diu_help_line 'diu projects template openspec <ID PROJECT>' 'Initialise ou actualise OpenSpec via ENV_DEVOPS_USER pour le projet <ID PROJECT>'
            diu_help_line 'diu projects template openspec all' 'Initialise ou actualise OpenSpec pour tous les projets configurés.'
            diu_help_line 'diu projects template devops all' 'Génère DEVOPS.md pour tous les projets configurés.'
            diu_help_line 'diu projects template all all' 'Applique tous les modèles à tous les projets configurés ; OpenSpec puis DevOps en dernier pour chaque projet.'
        else
            diu_display_command_error projects template
            return 2
        fi
        return 0
    fi

    case "$context:$subcontext:$leaf" in
        infos::)
            diu_help_line 'diu infos' 'Affiche les informations de tous les modules.'
            diu_help_line 'diu infos softwares' 'Affiche les logiciels par moteur.'
            ;;
        infos:softwares:)
            diu_help_line 'diu infos softwares' 'Affiche les logiciels par moteur.'
            ;;
        diu::)
            diu_help_line 'diu diu infos' 'Affiche les informations du DIU.'
            diu_help_line 'diu diu update [VERSION]' 'Met à jour DIU ou installe une version exacte de GitHub.'
            ;;
        diu:update:|update:diu:)
            diu_help_line 'diu diu update' 'Met à jour DIU depuis GitHub, ou Forgejo en secours.'
            diu_help_line 'diu diu update <VERSION>' 'Installe la version exacte de GitHub, même déjà installée ou plus ancienne.'
            diu_help_line 'diu diu update 1.1.7' 'Exemple de réinstallation de la version 1.1.7 disponible sur GitHub.'
            ;;
        desktop::|environnements::)
            diu_help_line "diu ${context} infos" 'Affiche les informations du module.'
            ;;
        desktop:infos:|diu:infos:|environnements:infos:|ia:infos:|projects:infos:|softwares:infos:)
            diu_help_line "diu ${context} infos" 'Affiche les informations du module.'
            ;;
        system:infos:)
            diu_help_line 'diu system infos' 'Affiche toutes les informations système.'
            diu_help_line 'diu system infos network' 'Affiche les informations réseau.'
            diu_help_line 'diu system infos debian' 'Affiche la configuration Debian, APT et Flatpak.'
            diu_help_line 'diu system infos drivers' "Affiche l’état DisplayLink et la version du pilote installé."
            ;;
        system:infos:network|system:infos:debian|system:infos:drivers)
            diu_help_line "diu system infos ${leaf}" 'Affiche les informations système demandées.'
            ;;
        ::)
            diu_help_line 'diu system infos drivers' "Affiche l’état DisplayLink et la version du pilote installé."
            diu_help_line 'diu system drivers install displaylink' 'Installe et valide le pilote DisplayLink.'
            diu_help_line 'diu system drivers remove displaylink' 'Supprime le pilote DisplayLink.'
            diu_help_line 'diu infos' 'Affiche les informations de tous les modules.'
            diu_help_line 'diu infos softwares' 'Affiche les logiciels par moteur.'
            diu_help_line 'diu desktop infos' 'Affiche les informations du bureau.'
            diu_help_line 'diu diu infos' 'Affiche les informations et la version du DIU.'
            diu_help_line 'diu diu update' 'Met à jour le paquet DIU.'
            diu_help_line 'diu environnements infos' 'Affiche les informations des environnements.'
            diu_help_line 'diu ia infos' 'Affiche les informations IA.'
            diu_help_line 'diu projects infos' 'Affiche les informations des projets.'
            diu_help_line 'diu softwares infos' 'Affiche les informations des logiciels.'
            diu_help_line 'diu system infos' 'Affiche toutes les informations système.'
            diu_help_line 'diu devops' 'Outils DevOps et OpenSpec.'
            diu_help_line 'diu docker' 'Gestion Docker root et rootless.'
            diu_help_line 'diu ia' 'Gestion des agents IA.'
            diu_help_line 'diu os' 'Validation OpenSpec.'
            diu_help_line 'diu projects' 'Gestion des projets et publications.'
            diu_help_line 'diu install' 'Installation de logiciels.'
            diu_help_line 'diu remove' 'Suppression de logiciels.'
            diu_help_line 'diu update' 'Mise à jour des composants.'
            diu_help_line 'diu softwares' 'Gestion des logiciels.'
            diu_help_line 'diu system' 'Gestion du système Debian.'
            diu_help_line 'diu version' 'Affiche la version du DIU.'
            ;;
        softwares::)
            diu_help_line 'diu softwares update' 'Met à jour les logiciels séparément de diu update.'
            diu_help_line 'diu softwares infos' 'Affiche les informations du module.'
            diu_help_line 'diu softwares install apt <SOFTWARE>' 'Installe un logiciel APT.'
            diu_help_line 'diu softwares remove apt <SOFTWARE>' 'Désinstalle un logiciel APT.'
            diu_help_line 'diu softwares update apt [SOFTWARE]' 'Met à jour un ou tous les logiciels APT.'
            diu_help_line 'diu softwares install github <SOFTWARE>' 'Installe depuis une release GitHub.'
            diu_help_line 'diu softwares remove github <SOFTWARE>' 'Désinstalle un logiciel GitHub.'
            diu_help_line 'diu softwares update github [SOFTWARE]' 'Met à jour un ou tous les logiciels GitHub.'
            diu_help_line 'diu softwares install flatpak <SOFTWARE>' 'Installe un logiciel Flatpak.'
            diu_help_line 'diu softwares remove flatpak <SOFTWARE>' 'Désinstalle un logiciel Flatpak.'
            diu_help_line 'diu softwares flatpak update' 'Met à jour les paquets installés avec Flatpak.'
            ;;
        softwares:install:|softwares:remove:)
            diu_help_line "diu softwares ${subcontext} apt <SOFTWARE>" 'Opération sur un logiciel APT.'
            diu_help_line "diu softwares ${subcontext} github <SOFTWARE>" 'Opération sur un logiciel GitHub.'
            diu_help_line "diu softwares ${subcontext} flatpak <SOFTWARE>" 'Opération sur un logiciel Flatpak.'
            ;;
        softwares:update:)
            diu_help_line 'diu softwares update' 'Met à jour les logiciels ; commande indépendante de diu update.'
            diu_help_line 'diu softwares update apt [SOFTWARE]' 'Met à jour les logiciels APT.'
            diu_help_line 'diu softwares update github [SOFTWARE]' 'Met à jour les logiciels GitHub.'
            ;;
        softwares:flatpak:)
            diu_help_line 'diu softwares flatpak update' 'Met à jour les paquets installés avec Flatpak.'
            ;;
        softwares:flatpak:update)
            diu_help_line 'diu softwares flatpak update' 'Met à jour les paquets installés avec Flatpak.'
            ;;
        softwares:install:apt|softwares:remove:apt|softwares:install:github|softwares:remove:github|softwares:update:apt|softwares:update:github|softwares:install:flatpak|softwares:remove:flatpak)
            diu_help_line "diu softwares ${subcontext} ${leaf} <SOFTWARE>" "Exécute l'opération demandée sur le logiciel."
            ;;
        system::)
            diu_help_line 'diu system drivers install displaylink' 'Installe et valide le pilote DisplayLink.'
            diu_help_line 'diu system drivers remove displaylink' 'Supprime le pilote DisplayLink.'
            diu_help_line 'diu system infos' 'Affiche les informations du module.'
            diu_help_line 'diu system infos network' 'Affiche les informations réseau.'
            diu_help_line 'diu system network update' 'Met à jour la configuration réseau et reconstruit /etc/hosts.'
            diu_help_line 'diu system network hosts update' 'Reconstruit /etc/hosts.'
            diu_help_line 'diu system network hosts' 'Affiche le contenu actuel de /etc/hosts.'
            diu_help_line 'diu system network help' 'Présente les commandes réseau et la gestion du hosts.json.'
            diu_help_line 'diu system network hosts help' 'Présente les commandes hosts et leurs aides.'
            diu_help_line 'diu system infos network help' 'Présente les informations réseau.'
            diu_help_line 'diu system infos debian' 'Affiche la configuration Debian, APT et Flatpak.'
            diu_help_line 'diu system infos drivers' "Affiche l’état DisplayLink et la version du pilote installé."
            diu_help_line 'diu system install apt <Dépôt>' 'Installe un dépôt APT.'
            diu_help_line 'diu system remove apt <Dépôt>' 'Supprime un dépôt APT.'
            diu_help_line 'diu system engine install <apt|github|flatpak>' 'Active un moteur et vérifie ses dépendances.'
            diu_help_line 'diu system engine remove <apt|github|flatpak>' 'Désactive un moteur sans supprimer ses dépendances.'
            diu_help_line 'diu system engine update' 'Met à jour successivement les trois moteurs.'
            diu_help_line 'diu system engine apt update' 'Met à jour le système APT Debian et affiche son bilan.'
            diu_help_line 'diu system engine github update' 'Vérifie le moteur GitHub et met à jour Codex CLI si configuré.'
            diu_help_line 'diu system engine flatpak update' 'Vérifie le moteur Flatpak et Flathub.'
            ;;
        system:install:|system:remove:)
            diu_help_line "diu system ${subcontext} apt <Dépôt>" 'Opération sur un dépôt APT.'
            ;;
        system:update:)
            diu_help_line 'diu system update' 'Met à jour APT, GitHub, Flatpak et le réseau.'
            ;;
        system:install:apt|system:remove:apt)
            diu_help_line "diu system ${subcontext} apt <Dépôt>" 'Opération sur un dépôt APT reconnu.'
            ;;
        docker::)
            diu_help_line 'diu docker root' 'Actions Docker root.'
            diu_help_line 'diu docker rootless' 'Actions Docker rootless.'
            ;;
        docker:root:)
            diu_help_line 'diu docker root check-containers' 'Liste les conteneurs actifs.'
            diu_help_line 'diu docker root test <USER>' 'Teste Docker pour un utilisateur.'
            diu_help_line 'diu docker root diag <USER>' 'Diagnostique Docker.'
            ;;
        docker:rootless:)
            diu_help_line 'diu docker rootless analyse <USER>' 'Analyse Docker rootless.'
            diu_help_line 'diu docker rootless configure <USER>' 'Configure Docker rootless.'
            diu_help_line 'diu docker rootless delete-state <USER>' "Supprime l'état Docker rootless."
            diu_help_line 'diu docker rootless diag <USER>' 'Diagnostique Docker rootless.'
            diu_help_line 'diu docker rootless exec <USER> <CONTAINER>' 'Exécute dans un conteneur.'
            diu_help_line 'diu docker rootless inspect <USER> <CONTAINER>' 'Inspecte un conteneur.'
            diu_help_line 'diu docker rootless log <USER> <CONTAINER>' "Affiche les journaux d'un conteneur."
            diu_help_line 'diu docker rootless ps <USER>' 'Liste les conteneurs.'
            diu_help_line 'diu docker rootless restore-state <USER>' "Restaure l'état Docker rootless."
            diu_help_line 'diu docker rootless save-state <USER>' "Sauvegarde l'état Docker rootless."
            diu_help_line 'diu docker rootless test <USER>' 'Teste Docker rootless.'
            diu_help_line 'diu docker rootless unconfigure <USER>' 'Déconfigure Docker rootless.'
            ;;
        ia::)
            diu_help_line 'diu ia infos' 'Affiche les informations du module.'
            diu_help_line 'diu ia configure hm' 'Configure Hermès.'
            diu_help_line 'diu ia install hm' 'Installe Hermès.'
            diu_help_line 'diu ia start hm' 'Démarre Hermès.'
            diu_help_line 'diu ia stop hm' 'Arrête Hermès.'
            diu_help_line 'diu ia update hm' 'Met à jour Hermès.'
            diu_help_line 'diu ia uninstall hm' 'Désinstalle Hermès.'
            ;;
        ia:configure:|ia:install:|ia:start:|ia:stop:|ia:update:|ia:uninstall:)
            diu_help_line "diu ia ${subcontext} hm" "Exécute l'opération Hermès demandée."
            ;;
        devops::)
            diu_help_line 'diu devops info' 'Affiche les informations DevOps.'
            diu_help_line 'diu devops os' 'Gère OpenSpec pour un projet.'
            ;;
        os::)
            diu_help_line 'diu os validate <PROJET> <SPEC>' 'Valide une spécification.'
            ;;
        projects::)
            diu_help_line 'diu projects infos' 'Affiche les informations du module.'
            diu_help_line 'diu projects template devops <ID PROJECT>' 'Crée ou actualise DEVOPS.md pour le projet.'
            diu_help_line 'diu projects template openspec <ID PROJECT>' 'Initialise ou actualise OpenSpec via ENV_DEVOPS_USER pour le projet <ID PROJECT>'
            diu_help_line 'diu projects template openspec all' 'Initialise ou actualise OpenSpec pour tous les projets configurés.'
            diu_help_line 'diu projects template devops all' 'Génère DEVOPS.md pour tous les projets configurés.'
            diu_help_line 'diu projects template all all' 'Applique tous les modèles à tous les projets configurés ; OpenSpec puis DevOps en dernier pour chaque projet.'
            diu_help_line 'diu projects create <ID PROJECT>' 'Crée un projet depuis le modèle local, prépare OpenSpec puis génère DEVOPS.md.'
            diu_help_line 'diu projects clone <ID PROJECT SOURCE> <ID PROJECT DESTINATION>' 'Clone un projet local sans ses métadonnées Git.'
            diu_help_line 'diu projects del <ID PROJECT>' 'Supprime un projet.'
            diu_help_line 'diu projects update' 'Applique tous les modèles à tous les projets configurés ; OpenSpec puis DevOps en dernier pour chaque projet.'
            diu_help_line 'diu projects update <ID PROJECT>' 'Met à jour les variables du projet.'
            diu_help_line 'diu projects sync <ID PROJECT>' 'Synchronise le projet depuis le modèle local.'
            diu_help_line 'diu projects sync all' 'Synchronise tous les projets configurés.'
            diu_help_line 'diu projects git commit all' 'Commit tous les dépôts Git configurés.'
            diu_help_line 'diu projects docker' 'Gestion Docker des projets.'
            diu_help_line 'diu projects cicd <ID PROJECT> [VERSION]' 'Exécute la CI/CD conditionnelle du projet.'
            diu_help_line 'diu projects finds <ID PROJECT>' 'Recherche les conflits de synchronisation.'
            diu_help_line 'diu projects findads <ID PROJECT>' 'Supprime les conflits de synchronisation.'
            diu_help_line 'diu projects git' 'Gestion du dépôt local Git.'
            diu_help_line 'diu projects git analyse <ID PROJECTS>' 'Analyse le dépôt Git local.'
            diu_help_line 'diu projects git commit <ID PROJECT> [COMMIT]' 'Commit le dépôt Git local.'
            diu_help_line 'diu projects git init <ID PROJECT>' 'Initialise le dépôt Git local et safe.directory système.'
            diu_help_line 'diu projects gitic <ID PROJECT>' 'Initialise et clone le dépôt Git.'
            diu_help_line 'diu projects gitpdiu' 'Publie le paquet DIU vers Forgejo.'
            diu_help_line 'diu projects git status <ID PROJECTS>' 'Affiche le statut Git et safe.directory système.'
            diu_help_line 'diu projects git update <ID PROJECT>' 'Met à jour les variables Git et safe.directory système.'
            diu_help_line 'diu projects gitlab' 'Gestion des dépôts GitLab.'
            diu_help_line 'diu projects gitlab clone <ID PROJECT>' 'Crée et fusionne un dépôt GitLab distant.'
            diu_help_line 'diu projects github' 'Gestion des dépôts GitHub.'
            diu_help_line 'diu projects github clone <ID PROJECT>' 'Crée et fusionne un dépôt GitHub distant.'
            diu_help_line 'diu projects forgejo' 'Gestion des dépôts Forgejo.'
            diu_help_line 'diu projects forgejo push all' 'Pousse tous les dépôts Forgejo configurés.'
            diu_help_line 'diu projects ocro <ID PROJECT>' 'Ouvre le projet en lecture seule.'
            diu_help_line 'diu projects ocrw <ID PROJECT>' 'Ouvre le projet en lecture-écriture.'
            diu_help_line 'diu projects ocsh <ID PROJECT>' 'Ouvre un shell dans le projet.'
            diu_help_line 'diu projects deb [ID PROJECT]' 'Construit le paquet DIU ; source par défaut : diu.'
            diu_help_line 'diu projects build debian <ID PROJECT>' 'Construit un paquet Debian depuis build/debian-package.json (PROJECT_DEBIAN_PACKAGE=Yes/YES/1).'
            diu_help_line 'diu projects build deb <ID PROJECT>' 'Alias compatible de build debian.'
            diu_help_line 'diu projects cicddiu' 'Lance la CI/CD du projet DIU.'
            diu_help_line 'diu projects cicddr <ID PROJECT>' 'Lance la CI/CD du projet.'
            ;;
        projects:cicd:|projects:cicd:*)
            diu_help_line 'diu projects cicd <ID PROJECT> [VERSION]' 'Configure éventuellement PROJECT_VERSION puis exécute les six étapes CI/CD.'
            printf '%s\n' '1. Commit/tag ; 2. Pushes Git ; 3. Build Docker ; 4. Build Debian ; 5. Publications ; 6. Bilan.'
            printf '%s\n' 'Build Debian indépendant de Docker : PROJECT_DEBIAN_PACKAGE=Yes/YES/1 ; même moteur que diu projects build debian <ID PROJECT>.'
            printf '%s\n' 'Un échec du build empêche les releases ; les pushes déjà réalisés restent publiés.'
            printf '%s\n' "À l’étape 5, Debian peut être publié sur Forgejo, GitLab et GitHub selon leur configuration, même sans Docker."
            printf '%s\n' 'Les messages identifient la forge, le tag et les contrôles effectivement réalisés.'
            printf '%s\n' 'Un tag existant est rejoué depuis son commit isolé ; les modifications locales ne sont pas livrées.'
            printf '%s\n' 'Tag distant supérieur ou non comparable : refus ; sinon branche et tag sont alignés sous lease. Stable prime sur horodatage.'
            printf '%s\n' "En rejeu, la publication Docker est ignorée : l'immutabilité du tag distant n'est pas vérifiée."
            ;;
        projects:cicddiu:|projects:cicddiu:*)
            diu_help_line 'diu projects cicddiu [COMMIT] [TAG]' 'Exécute la CI/CD du DIU ; PROJECT_VERSION est prioritaire pour le tag.'
            ;;
        projects:cicddr:|projects:cicddr:*)
            diu_help_line 'diu projects cicddr <ID PROJECT> [COMMIT] [TAG]' 'Exécute la CI/CD Docker ; PROJECT_VERSION est prioritaire pour le tag.'
            ;;
        projects:docker:)
            diu_help_line 'diu projects docker build <ID PROJECT>' "Construit l'image Docker du projet."
            ;;
        projects:create:)
            diu_help_line 'diu projects create <ID PROJECT>' 'Crée un projet depuis le modèle local, prépare OpenSpec puis génère DEVOPS.md.'
            ;;
        projects:clone:)
            diu_help_line 'diu projects clone <ID PROJECT SOURCE> <ID PROJECT DESTINATION>' 'Clone un projet local sans ses métadonnées Git.'
            ;;
        projects:sync:)
            diu_help_line 'diu projects sync <ID PROJECT>' 'Synchronise le projet depuis le modèle local.'
            diu_help_line 'diu projects sync all' 'Synchronise tous les projets configurés.'
            ;;
        projects:commit:)
            diu_help_line 'diu projects git commit all' 'Commit tous les dépôts Git configurés.'
            ;;
        projects:git:)
            diu_help_line 'diu projects git analyse <ID PROJECTS>' 'Analyse le dépôt Git local.'
            diu_help_line 'diu projects git commit <ID PROJECT> [COMMIT]' 'Commit le dépôt Git local.'
            diu_help_line 'diu projects git commit all' 'Commit tous les dépôts Git configurés.'
            diu_help_line 'diu projects git init <ID PROJECT>' 'Initialise le dépôt Git local et safe.directory système.'
            diu_help_line 'diu projects git status <ID PROJECTS>' 'Affiche le statut Git et safe.directory système.'
            diu_help_line 'diu projects git update <ID PROJECT>' 'Met à jour les variables Git et safe.directory système.'
            ;;
        projects:git:commit)
            diu_help_line 'diu projects git commit <ID PROJECT> [COMMIT]' 'Commit le dépôt Git local.'
            diu_help_line 'diu projects git commit all' 'Commit tous les dépôts Git configurés.'
            ;;
        projects:git:status)
            diu_help_line 'diu projects git status <ID PROJECTS>' 'Affiche le statut Git et safe.directory système.'
            ;;
        projects:gitlab:|projects:github:|projects:forgejo:)
            diu_help_line "diu projects ${subcontext} update <ID PROJECT>" 'Met à jour la configuration distante.'
            diu_help_line "diu projects ${subcontext} push <ID PROJECT> [VERSION]" 'Prépare commit et tag, puis réconcilie et publie le dépôt.'
            if [[ "${subcontext}" == "gitlab" ]]; then
                diu_help_line 'diu projects gitlab clone <ID PROJECT>' 'Crée et fusionne un dépôt GitLab distant.'
            fi
            if [[ "${subcontext}" == "github" ]]; then
                diu_help_line 'diu projects github clone <ID PROJECT>' 'Crée et fusionne un dépôt GitHub distant.'
            fi
            if [[ "${subcontext}" == "forgejo" ]]; then
                diu_help_line 'diu projects forgejo push all' 'Pousse tous les dépôts Forgejo configurés.'
            fi
            diu_help_line "diu projects ${subcontext} release <ID PROJECT>" 'Publie les artefacts du projet.'
            ;;
        projects:docker:build|projects:git:update|projects:gitlab:clone|projects:gitlab:update|projects:gitlab:push|projects:gitlab:release|projects:github:clone|projects:github:update|projects:github:push|projects:github:release|projects:forgejo:update|projects:forgejo:push|projects:forgejo:release)
            if [[ "$leaf" == push && "$subcontext" =~ ^(forgejo|gitlab|github)$ ]]; then
                diu_help_line "diu projects ${subcontext} push <ID PROJECT> [VERSION]" 'Commit et tag avant réconciliation Git ; VERSION x.y.z ou horodatage si absente.'
                printf '%s\n' 'Une version déjà attribuée est rejouée isolément ; les modifications locales sont conservées.'
            else
                diu_help_line "diu projects ${subcontext} ${leaf} <ID PROJECT>" "Exécute l'opération demandée."
            fi
            if [[ "${context}:${subcontext}:${leaf}" == "projects:forgejo:push" ]]; then
                diu_help_line 'diu projects forgejo push all' 'Pousse tous les dépôts Forgejo configurés.'
            fi
            ;;
        install::|remove::)
            diu_help_line "diu ${context} apt <SOFTWARE>" 'Opération sur un logiciel tiers.'
            ;;
        update::)
            diu_help_line 'diu update' 'Met à jour DIU, système, environnements, IA et modèles via diu projects update ; sans diu softwares update.'
            diu_help_line 'diu softwares update' 'Met à jour séparément les logiciels.'
            diu_help_line 'diu update diu' 'Alias de diu diu update.'
            ;;
        *)
            diu_display_command_error "$context" "$subcontext" "$leaf"
            return 2
            ;;
    esac
}

diu_display_command_error() {
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
            docker:root|docker:rootless|ia:configure|ia:install|ia:start|ia:stop|ia:update|ia:uninstall|system:install|system:remove|system:update|system:engine|softwares:install|softwares:remove|softwares:update|softwares:apt|softwares:flatpak|projects:docker|projects:git|projects:gitlab|projects:github|projects:forgejo)
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

    printf '❌ Commande inconnue. Consultez : diu%s help\n' "$help_context"
}

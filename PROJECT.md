# Projet Debian Installer Unifié (DIU)

## Présentation

Le Debian Installer Unifié (DIU) est un moteur d'installation et de
configuration pour Debian, écrit en Bash.

Il fournit un point d'entrée commun pour installer, configurer et administrer
un système Debian ainsi que les composants nécessaires à ses différents
usages. Son organisation repose sur des modules fonctionnels, chacun étant
responsable d'un domaine clairement identifié.

## Objectifs

Le DIU vise à fournir une installation et une configuration Debian :

- reproductibles ;
- progressives ;
- modulaires ;
- lisibles et maintenables ;
- compatibles avec les installations existantes ;
- pilotées par une configuration centralisée.

Le projet préserve un point d'entrée principal unique tout en répartissant
progressivement les responsabilités dans des modules spécialisés.

## Architecture fonctionnelle

### Module `diu`

Le module `diu` assure la configuration et la gestion du moteur DIU lui-même.

Il porte notamment la nouvelle gestion des variables globales du projet. Cette
gestion comprend le chargement de la configuration existante, la génération
des variables nécessaires et l'organisation des valeurs de configuration par
domaine.

L'ancien mécanisme centralisé dans `variables.sh` est conservé tant que sa
migration progressive reste nécessaire à la compatibilité du projet.

### Module `system`

Le module `system` assure la configuration et la gestion du système Debian.

Il regroupe les responsabilités directement liées au fonctionnement du
système d'exploitation.

### Module `desktop`

Le module `desktop` assure la configuration et la gestion des environnements
graphiques.

Il regroupe les fonctions liées aux bureaux et à leur intégration dans le
système Debian.

### Module `environments`

Le module `environments` assure la configuration et la gestion des
environnements utilisateurs.

Il regroupe les fonctions nécessaires à la préparation des contextes de
travail associés aux différents usages et utilisateurs du système.

### Module `softwares`

Le module `softwares` assure la configuration, la gestion, l'installation et
la désinstallation des logiciels.

Il regroupe les opérations portant sur le cycle de vie des logiciels gérés par
le DIU.

### Module `projects`

La commande `rid projects build deb <ID PROJECT>` construit un paquet Debian
à partir de la recette publique `build/debian-package.json` du projet, lorsque
`PROJECT_DEBIAN_PACKAGE` vaut `Yes`, `YES` ou `1`. Le moteur est indépendant
du nom et de l’arborescence du projet.

Le module `projects` assure la configuration et la gestion des projets de
développement.

Il regroupe les fonctions nécessaires à la création, à l'initialisation et à
l'administration des projets pris en charge par le DIU, ainsi qu'à la
publication de leurs images Docker et paquets Debian vers Forgejo.

La construction Docker accepte un fichier public optionnel
`build/docker-build.args`, propre à chaque projet. Le DIU valide sa syntaxe
et transmet ses valeurs littéralement ; aucune logique applicative, version
métier ou dépendance à un outil de projet n'est intégrée au moteur.

## Principes d'organisation

Le DIU respecte les principes suivants :

- `root-install-debian.sh` reste le point d'entrée principal ;
- les fonctions sont réparties progressivement selon leur domaine ;
- les fonctions génériques et réutilisables sont séparées des fonctions
  propres aux modules ;
- chaque module reste responsable de son domaine fonctionnel ;
- la gestion des variables appartient au module `diu` ;
- toute évolution préserve les comportements existants qui ne sont pas
  concernés par la modification ;
- les évolutions fonctionnelles sont définies et validées avec OpenSpec avant
  leur implémentation.

## Technologies

Le DIU est développé en Bash pour les versions stables de Debian prises en
charge par le projet.

Les scripts privilégient les outils disponibles dans une installation Debian
standard et doivent rester simples, portables, explicites et reproductibles.

## Chaine de Développements

Outils :

* OpenSpec : spécifications ;
* OpenCode : agent de codage ;
* Codex    : orchestrateur ;
* Git local et distant : versionnement ;
* VS Code / Geany : développement ;

Architecture :

```text
                    Développeur
                        │
              interaction / validation
                        │
             ┌──────────┴──────────┐
             ▼                     ▼
         OpenCode               Codex
      Agent de codage        Orchestrateur
             ▲                     │
             └────── API ──────────┘
                                   │
                                   ▼
                                  GPT
                     Analyse / Revue / Validation
```

OpenCode reste l'agent de codage du projet.

Codex intervient en analyse, en revue de code, et en validateur.

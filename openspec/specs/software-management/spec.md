# software-management Specification

## Purpose

Définir le routage et la gestion des logiciels pris en charge par les moteurs
du DIU.

## Requirements

### Requirement: Routage du cycle de vie des logiciels

DIU SHALL refuser explicitement le moteur logiciel `deb` pour les commandes d'installation, de suppression et de mise à jour. Les moteurs logiciels restants et les commandes de construction de paquets Debian SHALL conserver leurs comportements.

#### Scenario: Installation ciblée

- **WHEN** `diu install apt chatgpt` est invoqué
- **THEN** DIU délègue l'installation à la recette APT existante

#### Scenario: Désinstallation sans logiciel

- **WHEN** `diu remove apt` est invoqué
- **THEN** DIU retourne une erreur de syntaxe

#### Scenario: Moteur inconnu

- **WHEN** une commande désigne un moteur inconnu
- **THEN** DIU retourne une erreur sans exécuter d'opération de remplacement

#### Scenario: Ancienne commande du moteur deb

- **WHEN** une commande logicielle désigne le moteur `deb`
- **THEN** DIU SHALL retourner une erreur sans exécuter d'opération sur les paquets

### Requirement: Logiciels tiers avec dépôt

Le moteur `apt` SHALL déterminer, à partir de la définition du logiciel, si
l'installation dépend d'un dépôt. Si oui, il SHALL déléguer la préparation de
ce dépôt au moteur de dépôts DIU avant d'installer le paquet.
Il SHALL NOT reproduire localement un moteur de dépôts de remplacement.
La désinstallation et la mise à jour SHALL cibler les paquets du logiciel tiers.

#### Scenario: Dépôt requis

- **WHEN** `diu install apt <SOFTWARE>` cible un logiciel nécessitant un dépôt
- **THEN** DIU fait préparer le dépôt par son moteur de dépôts
- **AND** il installe le paquet uniquement après le succès de cette préparation

#### Scenario: Moteur de dépôts indisponible

- **WHEN** l'installation requiert un dépôt et que son moteur DIU n'est pas disponible
- **THEN** DIU signale la fonctionnalité indisponible et retourne un code non nul
- **AND** il ne tente pas l'installation du logiciel

### Requirement: Logiciels tiers sans dépôt

Pour un logiciel tiers sans dépôt, le moteur `apt` SHALL appeler une fonction
propre au logiciel pour chacune des actions installation, désinstallation et
mise à jour. Il SHALL NOT construire une commande arbitraire à partir de
l'identifiant fourni par l'utilisateur.

#### Scenario: Installation sans dépôt

- **WHEN** `diu install apt <SOFTWARE>` cible un logiciel déclaré sans dépôt
- **THEN** DIU appelle sa fonction spécifique d'installation
- **AND** il n'appelle pas le moteur de dépôts

#### Scenario: Désinstallation sans dépôt

- **WHEN** `diu remove apt <SOFTWARE>` cible un logiciel déclaré sans dépôt
- **THEN** DIU appelle sa fonction spécifique de désinstallation

#### Scenario: Mise à jour sans dépôt

- **WHEN** `diu update apt <SOFTWARE>` cible un logiciel déclaré sans dépôt
- **THEN** DIU appelle sa fonction spécifique de mise à jour

#### Scenario: Fonction indisponible

- **WHEN** une action ne dispose pas de fonction spécifique pour le logiciel
- **THEN** DIU signale l'action non prise en charge et retourne un code non nul

### Requirement: Mise à jour de tous les logiciels tiers

`diu update apt` SHALL traiter les logiciels tiers installés et reconnus par DIU, selon leur mode avec dépôt ou sans dépôt, sans installer de logiciel absent.

#### Scenario: Mise à jour du moteur apt

- **WHEN** `diu update apt` est invoqué et le moteur est disponible
- **THEN** DIU exécute les mises à jour des logiciels tiers installés reconnus
- **AND** il utilise les fonctions propres aux logiciels sans dépôt

### Requirement: Erreurs et répétition des opérations

Les moteurs SHALL propager les échecs avec un diagnostic et un code non nul.
Une installation d'un logiciel déjà à la version attendue, une suppression
d'un logiciel reconnu déjà absent ou une mise à jour sans version plus récente
SHALL signaler cet état sans effet de bord inattendu.

#### Scenario: Échec du gestionnaire de paquets

- **WHEN** le gestionnaire de paquets échoue
- **THEN** DIU retourne un code non nul et ne présente pas l'action comme réussie

#### Scenario: Aucune mise à jour disponible

- **WHEN** un logiciel est déjà à jour
- **THEN** DIU signale cet état sans réinstallation inutile

### Requirement: Commandes modulaires du moteur APT
DIU SHALL accepter `diu softwares install apt <SOFTWARE>`, `diu softwares remove apt <SOFTWARE>` et `diu softwares update apt <SOFTWARE>`. DIU SHALL refuser `diu softwares apt update` sans lancer de mise à jour APT.

#### Scenario: Commande granulaire
- **WHEN** l'utilisateur invoque `diu softwares install apt <SOFTWARE>`
- **THEN** DIU route l'action vers le moteur APT du module `softwares`

#### Scenario: Ancienne commande refusée
- **WHEN** l'utilisateur invoque `diu softwares apt update`
- **THEN** DIU retourne une erreur sans lancer de mise à jour APT

### Requirement: Opérations granulaires idempotentes

Les opérations granulaires SHALL sélectionner une sous-fonction explicitement
déclarée pour le logiciel demandé. Aucune sous-fonction logicielle concrète
n'est déclarée par cette évolution. En l'absence de recette, DIU SHALL signaler
l'action comme non prise en charge sans appeler APT. Les opérations SHALL être
idempotentes, ne SHALL NOT pas construire une commande ou un nom de fonction
arbitraire depuis l'entrée utilisateur, et SHALL propager les erreurs.

#### Scenario: Recette absente

- **WHEN** aucun logiciel concret n'est déclaré pour l'identifiant demandé
- **THEN** DIU retourne une erreur sans appeler APT
- **AND** aucune mutation système n'est effectuée

#### Scenario: Logiciel non déclaré

- **WHEN** aucun sous-fonctionnaire explicite n'est déclaré pour le logiciel
- **THEN** DIU retourne une erreur sans appeler APT

### Requirement: Mise à jour globale APT
`diu softwares update apt` SHALL converger les logiciels APT gérés vers leur état désiré, sans lancer de mise à jour globale APT. `diu update` SHALL appeler cette convergence via `softwares_update` en fin de parcours.

#### Scenario: Mise à jour globale
- **WHEN** l'utilisateur invoque `diu softwares update apt`
- **THEN** DIU converge les logiciels APT gérés sans mettre à jour leurs versions

#### Scenario: Mise à jour globale du DIU
- **WHEN** l'utilisateur invoque `diu update`
- **THEN** DIU appelle la convergence générale du module logiciels en dernier

### Requirement: Organisation des modules
Le chargement SHALL respecter l'ordre `diu`, `system`, `softwares`, puis les autres modules. La configuration des dépôts et la mise à jour globale APT restent fournies par `system`.

#### Scenario: Ordre de chargement
- **WHEN** DIU démarre
- **THEN** le module `system` est chargé avant `softwares`
- **AND** les modules suivants sont chargés après `softwares`

### Requirement: Variables ChatGPT du moteur APT
DIU SHALL déclarer l'état désiré `SOFTWARE_APT_CHATGPT`, préserver une valeur existante et ne détecter le paquet que pour une première initialisation sans valeur migrable. DIU SHALL NOT utiliser la variable historique de personnalisation `SOFTWARES_APT_CHATGPT_HOME`.

#### Scenario: ChatGPT absent au démarrage
- **WHEN** aucune valeur désirée n'existe et que le paquet ChatGPT est absent
- **THEN** DIU initialise `SOFTWARE_APT_CHATGPT` à `0`

#### Scenario: ChatGPT présent au démarrage
- **WHEN** aucune valeur désirée n'existe et que le paquet ChatGPT est présent
- **THEN** DIU initialise `SOFTWARE_APT_CHATGPT` à `1`

#### Scenario: Persistance cohérente
- **WHEN** l'état désiré ChatGPT est initialisé
- **THEN** `softwares.env` contient `SOFTWARE_APT_CHATGPT`
- **AND** DIU ne persiste pas la variable historique de personnalisation

### Requirement: Installation APT de ChatGPT

`diu install apt chatgpt` et `diu softwares install apt chatgpt` SHALL utiliser
la recette explicite ChatGPT. Lorsque `SYSTEM_APT_CGPT` ne vaut pas `1`, elle SHALL préparer le
dépôt avec le moteur `system`, actualiser les index APT, puis installer le
paquet `chatgpt`. Après une installation réussie, elle SHALL modifier
`/usr/share/applications/chatgpt.desktop` pour définir une entrée
`Exec=env CODEX_HOME=<HOME résolu> chatgpt %U`.

#### Scenario: Dépôt CGPT absent

- **WHEN** ChatGPT est installé alors que `SYSTEM_APT_CGPT` vaut `0`
- **THEN** le dépôt CGPT est préparé, les index sont actualisés, puis le paquet
  `chatgpt` est installé
- **AND** le fichier desktop reçoit la variable `CODEX_HOME`

#### Scenario: Dépôt CGPT déjà disponible

- **WHEN** ChatGPT est installé alors que `SYSTEM_APT_CGPT` vaut `1`
- **THEN** la recette n'installe pas à nouveau le dépôt
- **AND** elle installe le paquet puis modifie le fichier desktop

### Requirement: Désinstallation APT de ChatGPT

`diu remove apt chatgpt` et `diu softwares remove apt chatgpt` SHALL supprimer le paquet `chatgpt`, puis
retirer le dépôt CGPT avec le moteur `system`, puis actualiser les index APT.
Tout échec SHALL être propagé et l'ordre SHALL être conservé.

#### Scenario: Désinstallation complète

- **WHEN** ChatGPT est installé et le dépôt CGPT est actif
- **THEN** DIU supprime le paquet, retire le dépôt, puis actualise les index
  APT

### Requirement: Mise à jour sélective APT de ChatGPT
`diu softwares update apt chatgpt` SHALL converger ChatGPT vers son état désiré sans mise à jour de version. La commande générique historique `diu update apt chatgpt` conserve son contrat propre hors de cette convergence.

#### Scenario: Paquet absent
- **WHEN** ChatGPT est absent et son état désiré est 1
- **THEN** DIU demande son installation et vérifie son état

#### Scenario: ChatGPT installé
- **WHEN** ChatGPT est installé et son état désiré est 1
- **THEN** DIU indique que l'état réel est conforme sans mettre à jour le paquet

### Requirement: Mise à jour globale APT du module softwares
`diu softwares update apt` SHALL converger chaque logiciel APT géré, installé ou absent, vers son état désiré. La commande SHALL NOT effectuer de mise à jour des versions APT.

#### Scenario: Ordre des phases
- **WHEN** l'utilisateur invoque `diu softwares update apt`
- **THEN** DIU vérifie l'état désiré et réel de chaque logiciel APT géré puis corrige les écarts

#### Scenario: Logiciel absent
- **WHEN** un logiciel géré est absent et son état désiré vaut 1
- **THEN** DIU demande son installation et vérifie son état réel

### Requirement: Dispatch de la mise à jour du module softwares
`diu softwares update` SHALL lancer la convergence des moteurs activés dans l'ordre APT, Flatpak, GitHub. Les échecs SHALL être signalés et les moteurs suivants SHALL être traités.

#### Scenario: Mise à jour du module softwares
- **WHEN** l'utilisateur invoque `diu softwares update`
- **THEN** DIU converge les moteurs activés dans l'ordre APT, Flatpak, GitHub

### Requirement: Moteur GitHub pour les logiciels

DIU SHALL accept `diu softwares install github <SOFTWARE>`,
`diu softwares remove github <SOFTWARE>`, `diu softwares update github
<SOFTWARE>` and `diu softwares update github`. The engine SHALL route only to
an explicitly registered software recipe and SHALL return a non-zero error for
an unknown software without executing a system command.

#### Scenario: Action GitHub déclarée

- **WHEN** an action targets a software with an explicit GitHub recipe
- **THEN** DIU calls the corresponding recipe action

#### Scenario: Action GitHub inconnue

- **WHEN** an action targets an undeclared software
- **THEN** DIU returns an error without executing an installation command

### Requirement: Opérations GitHub granulaires idempotentes

Each GitHub recipe SHALL provide installation, removal and update behavior as
applicable, SHALL be granular and idempotent, and SHALL set its global software
state variable to `1` after successful installation or to `0` after successful
removal. Installation of an installed software and removal of an absent
software SHALL not cause an unintended side effect.

#### Scenario: Installation répétée

- **WHEN** an already installed GitHub software is installed again
- **THEN** the recipe reports the existing state without reinstalling it

#### Scenario: Suppression répétée

- **WHEN** an absent GitHub software is removed
- **THEN** the recipe reports the absent state and returns success

### Requirement: Mise à jour depuis la dernière release GitHub

For an installed GitHub software, the update recipe SHALL obtain the latest
available GitHub release, compare it with the locally installed version, and
perform an update only when the remote release is newer. A targeted update
SHALL not install an absent software.

#### Scenario: Release plus récente

- **WHEN** the latest GitHub release is newer than the local version
- **THEN** DIU calls the software update recipe

#### Scenario: Logiciel déjà à jour

- **WHEN** the local version matches or is newer than the latest release
- **THEN** DIU reports that no update is available without reinstalling

### Requirement: Mise à jour du sous-module GitHub
`diu softwares update github` SHALL converger tous les logiciels GitHub gérés vers leur état désiré. La commande SHALL poursuivre les logiciels indépendants après un échec et retourner un résultat non nul en cas d'échec.

#### Scenario: Mise à jour globale
- **WHEN** la convergence globale GitHub est invoquée
- **THEN** DIU converge chaque logiciel GitHub géré

#### Scenario: Échec isolé
- **WHEN** la convergence d'un logiciel GitHub échoue
- **THEN** DIU signale l'échec après traitement des autres logiciels indépendants

### Requirement: Variables Codex CLI
DIU SHALL déclarer `SOFTWARE_GITHUB_CODEX_CLI` dans le scope `softwares` et conserver sa valeur persistée. En son absence initiale, DIU SHALL migrer l'ancienne valeur si elle existe ou l'initialiser depuis l'état réel du logiciel.

#### Scenario: Codex absent
- **WHEN** aucun état désiré n'existe et que Codex CLI est absent
- **THEN** DIU initialise l'état désiré à 0

#### Scenario: Codex présent
- **WHEN** aucun état désiré n'existe et que Codex CLI est présent
- **THEN** DIU initialise l'état désiré à 1

### Requirement: Installation GitHub de Codex CLI
`diu softwares install github codex-cli` SHALL installer Codex CLI depuis une GitHub Release du dépôt `openai/codex`. La cible SHALL être exclusivement Linux x86_64 avec l'artefact `codex-package-x86_64-unknown-linux-musl.tar.gz`. L'opération SHALL vérifier le digest SHA-256 avant toute installation et SHALL échouer sans présenter l'installation comme réussie si la vérification échoue.

#### Scenario: Installation valide
- **WHEN** une release GitHub compatible est disponible et son archive est vérifiée
- **THEN** DIU installe Codex CLI et ses ressources nécessaires
- **AND** `SOFTWARE_GITHUB_CODEX_CLI` vaut `1`

#### Scenario: Plateforme non supportée
- **WHEN** l'installation n'est pas exécutée sur Linux x86_64
- **THEN** DIU retourne une erreur explicite sans téléchargement ni mutation

### Requirement: Désinstallation sans suppression du profil
`diu softwares remove github codex-cli` SHALL supprimer les binaires, liens et releases installées par DIU, mais SHALL préserver le répertoire et les données du profil utilisateur.

#### Scenario: Désinstallation
- **WHEN** Codex CLI est installé par DIU
- **THEN** ses binaires et artefacts d'installation sont supprimés
- **AND** le profil Codex n'est pas supprimé
- **AND** `SOFTWARE_GITHUB_CODEX_CLI` vaut `0`

### Requirement: Mise à jour ciblée depuis GitHub
`diu softwares update github codex-cli` SHALL converger Codex CLI vers son état désiré sans mettre à jour sa version lorsqu'il est déjà présent.

#### Scenario: Nouvelle release
- **WHEN** Codex CLI est présent et son état désiré est 1, même si une release plus récente existe
- **THEN** la convergence ne remplace pas sa version

#### Scenario: Version à jour
- **WHEN** l'état réel de Codex CLI correspond à son état désiré
- **THEN** DIU ne télécharge ni ne remplace le logiciel

### Requirement: Mise à jour globale GitHub
`diu softwares update github` SHALL converger Codex CLI vers sa variable d'état désiré. `diu softwares update` SHALL inclure cette convergence une seule fois. `diu update` SHALL conserver la mise à jour de Codex CLI par la phase système lorsque applicable.

#### Scenario: Codex absent
- **WHEN** `SOFTWARE_GITHUB_CODEX_CLI` vaut `0` et Codex CLI est absent
- **THEN** la convergence n'installe pas Codex CLI

### Requirement: Désactivation de la variable HOME Codex CLI
DIU SHALL NOT créer, utiliser ou persister `SOFTWARES_APT_CODEX_CLI_HOME`. L'installation SHALL exposer directement le binaire extrait par un lien symbolique et SHALL NOT générer de wrapper shell.

#### Scenario: Codex installé
- **WHEN** l'état réel de Codex CLI correspond à `SOFTWARE_GITHUB_CODEX_CLI=1`
- **THEN** la convergence ne change pas sa version

### Requirement: Résultat visible des opérations des moteurs

Les recettes des moteurs `apt` et `github` SHALL afficher une ligne de succès
identifiant le moteur et le logiciel après chaque installation ou
désinstallation effective. La ligne SHALL inclure la version installée lorsque
celle-ci est disponible. Une mise à jour effective SHALL afficher les versions
avant et après. Une opération idempotente SHALL afficher explicitement l'état
déjà atteint et SHALL ne pas afficher une réussite d'installation, de
désinstallation ou de mise à jour effective.

#### Scenario: Installation avec version

- **WHEN** `diu softwares install github codex-cli` réussit
- **THEN** DIU affiche `✅ softwares/github/codex-cli (<VERSION>): installé.`

#### Scenario: Désinstallation avec version

- **WHEN** `diu softwares remove github codex-cli` réussit
- **THEN** DIU affiche `✅ softwares/github/codex-cli (<VERSION>): désinstallé.`

#### Scenario: Mise à jour avec changement de version

- **WHEN** une recette `apt` ou `github` met effectivement à jour un logiciel
- **THEN** DIU affiche `✅ softwares/<ENGINE>/<SOFTWARE> (<AVANT> --> <APRES>): mis à jour.`

#### Scenario: Aucun changement

- **WHEN** le logiciel est déjà installé, absent ou à jour selon l'action
- **THEN** DIU affiche l'état sans présenter une mutation qui n'a pas eu lieu

### Requirement: Retrait de la personnalisation ChatGPT

La recette APT de ChatGPT SHALL gérer uniquement le paquet et son dépôt. Elle
SHALL NOT modifier `/usr/share/applications/chatgpt.desktop` ni utiliser ou
persister `SOFTWARES_APT_CHATGPT_HOME`. Cette exigence remplace les exigences
antérieures de personnalisation desktop et de gestion de cette variable.

#### Scenario: Installation sans personnalisation desktop

- **WHEN** `diu softwares install apt chatgpt` réussit
- **THEN** DIU gère le paquet et son dépôt sans modifier
  `/usr/share/applications/chatgpt.desktop`
- **AND** DIU n'utilise ni ne persiste `SOFTWARES_APT_CHATGPT_HOME`

### Requirement: Cohérence persistée de l'état Codex CLI
Les commandes explicites install et remove de Codex CLI SHALL persister respectivement les états désirés 1 et 0. La convergence SHALL conserver cet état même en cas d'échec de l'opération.

#### Scenario: Désinstallation persistée
- **WHEN** `diu softwares remove github codex-cli` est demandé
- **THEN** l'état désiré 0 est persisté et la désinstallation est demandée

#### Scenario: Mise à jour après désinstallation
- **WHEN** `diu softwares update github codex-cli` est invoqué alors que l'état désiré et l'état réel valent 0
- **THEN** DIU signale la convergence sans téléchargement ni installation

### Requirement: Cohérence persistée de l'état ChatGPT
Les commandes explicites install et remove de ChatGPT SHALL persister respectivement les états désirés 1 et 0. La convergence SHALL conserver cet état même en cas d'échec de l'opération.

#### Scenario: Installation persistée
- **WHEN** `diu softwares install apt chatgpt` est demandé
- **THEN** l'état désiré 1 est persisté et l'installation est demandée

#### Scenario: Désinstallation persistée
- **WHEN** `diu softwares remove apt chatgpt` est demandé
- **THEN** l'état désiré 0 est persisté et la désinstallation est demandée

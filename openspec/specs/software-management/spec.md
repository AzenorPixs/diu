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

DIU SHALL accepter les commandes `diu softwares install apt <SOFTWARE>`,
`diu softwares remove apt <SOFTWARE>`, `diu softwares update apt <SOFTWARE>`
et `diu softwares apt update`.

#### Scenario: Commande granulaire

- **WHEN** l'utilisateur invoque `diu softwares install apt <SOFTWARE>`
- **THEN** DIU route l'action vers le moteur APT du module `softwares`

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

`diu softwares apt update` SHALL mettre à jour tous les paquets installés avec
APT. Elle SHALL NOT rejouer les fonctions granulaires `install`, `remove` ou
`update` propres aux logiciels.

#### Scenario: Mise à jour globale

- **WHEN** l'utilisateur invoque `diu softwares apt update`
- **THEN** DIU met à jour les paquets installés avec APT une seule fois

#### Scenario: Mise à jour globale du DIU

- **WHEN** l'utilisateur invoque `diu update`
- **THEN** DIU inclut la mise à jour globale APT du module `softwares`
- **AND** il ne rejoue pas les actions granulaires des logiciels

### Requirement: Organisation des modules

Le chargement SHALL respecter l'ordre `diu`, `system`, `softwares`, puis les
autres modules. La configuration des dépôts reste fournie par `system`, mais
la mise à jour globale APT appartient au module `softwares`.

#### Scenario: Ordre de chargement

- **WHEN** DIU démarre
- **THEN** le module `system` est chargé avant `softwares`
- **AND** les modules suivants sont chargés après `softwares`

### Requirement: Variables ChatGPT du moteur APT

Le scope `softwares` SHALL déclarer `SOFTWARES_APT_CHATGPT` et
`SOFTWARES_APT_CHATGPT_HOME` statiques et `ENABLE`, avec pour défauts
respectifs `0` et `~/.codex`. Si la première variable est absente, son
initialisation SHALL produire `1` si le paquet Debian `chatgpt` est installé,
`0` sinon. Une valeur persistée SHALL être conservée. `softwares.env` SHALL
contenir les exports des deux variables : état `0|1` et chemin par défaut
littéral `~/.codex`.

#### Scenario: ChatGPT absent au démarrage

- **WHEN** le paquet Debian `chatgpt` n'est pas installé
- **THEN** `SOFTWARES_APT_CHATGPT` vaut `0`

#### Scenario: ChatGPT présent au démarrage

- **WHEN** le paquet Debian `chatgpt` est installé
- **THEN** `SOFTWARES_APT_CHATGPT` vaut `1`

#### Scenario: Persistance cohérente

- **WHEN** les variables ChatGPT sont initialisées
- **THEN** `softwares.env` contient les deux variables
- **AND** la valeur par défaut du chemin est écrite sous la forme littérale
  `~/.codex`

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

`diu update apt chatgpt` et `diu softwares update apt chatgpt` SHALL vérifier
que le paquet `chatgpt` est installé puis SHALL réappliquer la modification de
`/usr/share/applications/chatgpt.desktop`. Cette action SHALL NOT mettre à jour
le paquet : les mises à jour APT sont gérées globalement.

#### Scenario: Paquet absent

- **WHEN** ChatGPT n'est pas installé
- **THEN** la mise à jour échoue explicitement sans installation

#### Scenario: ChatGPT installé

- **WHEN** ChatGPT est installé
- **THEN** aucune commande APT de mise à jour sélective n'est invoquée
- **AND** la ligne desktop contient `CODEX_HOME`

### Requirement: Mise à jour globale APT du module softwares

`diu softwares update apt` SHALL exécuter `diu softwares apt update`, puis
réexécuter les mises à jour sélectives des logiciels APT reconnus et installés.
La phase sélective SHALL toujours être exécutée après la phase APT. Les
logiciels absents ou non déclarés SHALL être ignorés sans installation.

#### Scenario: Ordre des phases

- **WHEN** l'utilisateur invoque `diu softwares update apt`
- **THEN** DIU exécute d'abord la mise à jour APT globale
- **AND** DIU exécute ensuite les mises à jour sélectives applicables

#### Scenario: Logiciel absent

- **WHEN** un logiciel reconnu n'est pas installé
- **THEN** DIU ne rejoue pas sa mise à jour sélective
- **AND** DIU ne l'installe pas

### Requirement: Dispatch de la mise à jour du module softwares

`diu softwares update` SHALL lancer les mises à jour des sous-modules
`softwares` disponibles. Les comportements, prérequis, erreurs et validations
de chaque sous-module restent définis par leurs spécifications respectives.

#### Scenario: Mise à jour du module softwares

- **WHEN** l'utilisateur invoque `diu softwares update`
- **THEN** DIU lance les mises à jour de ses sous-modules disponibles

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

`diu softwares update github` SHALL traiter uniquement les recettes GitHub
reconnues et installées. La commande SHALL
continue independent recipes after an individual failure and SHALL return a
non-zero result when at least one recipe fails.

#### Scenario: Mise à jour globale

- **WHEN** the global GitHub update command is invoked
- **THEN** DIU updates each installed recognized GitHub software once

#### Scenario: Échec isolé

- **WHEN** one GitHub software update fails
- **THEN** DIU reports a global failure after processing the other recognized software

### Requirement: Variables Codex CLI

DIU SHALL déclarer `SOFTWARES_APT_CODEX_CLI` en `DYNAMIC`, `ENABLE`, scope `softwares`, avec repli `0`. À chaque chargement de la déclaration, DIU SHALL recalculer la valeur, même si elle était déjà définie : `1` si `codex` est un exécutable accessible dans le PATH du processus DIU, `0` sinon. La valeur détectée SHALL être persistée suivant le mécanisme existant lorsque la configuration est accessible en écriture.

#### Scenario: Codex absent

- **WHEN** aucun binaire Codex CLI exécutable n'est disponible dans le PATH du DIU
- **THEN** `SOFTWARES_APT_CODEX_CLI` vaut `0`, quelle que soit sa valeur précédente

#### Scenario: Codex présent

- **WHEN** un binaire Codex CLI exécutable est disponible dans le PATH du DIU
- **THEN** `SOFTWARES_APT_CODEX_CLI` vaut `1`, quelle que soit sa valeur précédente

### Requirement: Installation GitHub de Codex CLI

`diu softwares install github codex-cli` SHALL installer Codex CLI depuis une
GitHub Release du dépôt `openai/codex`. La cible SHALL être exclusivement
Linux x86_64 avec l’artefact `codex-package-x86_64-unknown-linux-musl.tar.gz`.
L’opération SHALL vérifier le digest SHA-256 avant toute installation et SHALL
échouer sans présenter l’installation comme réussie si la vérification échoue.

#### Scenario: Installation valide

- **WHEN** une release GitHub compatible est disponible et son archive est
  vérifiée
- **THEN** DIU installe Codex CLI et ses ressources nécessaires
- **AND** `SOFTWARES_APT_CODEX_CLI` vaut `1`

#### Scenario: Plateforme non supportée

- **WHEN** l’installation n’est pas exécutée sur Linux x86_64
- **THEN** DIU retourne une erreur explicite sans téléchargement ni mutation

### Requirement: Désinstallation sans suppression du profil

`diu softwares remove github codex-cli` SHALL supprimer les binaires, liens et
releases installées par DIU, mais SHALL préserver le répertoire et les données
du profil utilisateur.

#### Scenario: Désinstallation

- **WHEN** Codex CLI est installé par DIU
- **THEN** ses binaires et artefacts d’installation sont supprimés
- **AND** le profil Codex n’est pas supprimé
- **AND** `SOFTWARES_APT_CODEX_CLI` vaut `0`

### Requirement: Mise à jour ciblée depuis GitHub

`diu softwares update github codex-cli` SHALL comparer la version locale de
Codex CLI avec la dernière release GitHub. Elle SHALL télécharger et installer
la release uniquement si elle est supérieure.

#### Scenario: Nouvelle release

- **WHEN** GitHub fournit une version supérieure à la version locale
- **THEN** DIU installe la nouvelle version après vérification SHA-256

#### Scenario: Version à jour

- **WHEN** la version locale est égale ou supérieure à la release GitHub
- **THEN** DIU n’effectue aucun téléchargement ni remplacement

### Requirement: Mise à jour globale GitHub

`diu softwares update github` SHALL traiter Codex CLI uniquement lorsque sa
variable d’état indique qu’il est installé. `diu softwares update` et
`diu update` SHALL inclure cette opération une seule fois.

#### Scenario: Codex absent

- **WHEN** `SOFTWARES_APT_CODEX_CLI` vaut `0`
- **THEN** la mise à jour globale n'installe pas Codex CLI

### Requirement: Désactivation de la variable HOME Codex CLI

DIU SHALL NOT créer, utiliser ou persister `SOFTWARES_APT_CODEX_CLI_HOME`.
Ce retrait SHALL préserver la déclaration `ENABLE` de la variable d'état
`SOFTWARES_APT_CODEX_CLI` et ses opérations. L'installation SHALL exposer
directement le binaire extrait par un lien symbolique et SHALL NOT générer
de wrapper shell.

#### Scenario: Codex installé

- **WHEN** `SOFTWARES_APT_CODEX_CLI` vaut `1`
- **THEN** la mise à jour globale compare puis met à jour Codex CLI si nécessaire

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

Après une installation ou une désinstallation réussie de Codex CLI, DIU SHALL
persister la valeur correspondante de `SOFTWARES_APT_CODEX_CLI` dans
`/root/diu/config/softwares.env` lorsque ce fichier est accessible en écriture.

#### Scenario: Désinstallation persistée

- **WHEN** `diu softwares remove github codex-cli` réussit
- **THEN** `SOFTWARES_APT_CODEX_CLI` vaut `0` dans le processus courant
- **AND** la configuration persistée contient `export SOFTWARES_APT_CODEX_CLI=0`
- **AND** une initialisation ultérieure ne considère pas Codex CLI comme installé

#### Scenario: Mise à jour après désinstallation

- **WHEN** `diu softwares update github codex-cli` est invoqué alors que
  `SOFTWARES_APT_CODEX_CLI` vaut `0`
- **THEN** DIU n'effectue aucun accès réseau ni téléchargement
- **AND** DIU affiche que Codex CLI n'est pas installé
- **AND** la commande réussit sans erreur d'opération

### Requirement: Cohérence persistée de l'état ChatGPT

Après une installation ou une désinstallation réussie de ChatGPT par le
moteur APT, DIU SHALL persister la valeur correspondante de
`SOFTWARES_APT_CHATGPT` dans `/root/diu/config/softwares.env` lorsque ce
fichier est accessible en écriture.

#### Scenario: Installation persistée

- **WHEN** `diu softwares install apt chatgpt` réussit
- **THEN** `SOFTWARES_APT_CHATGPT` vaut `1` dans le processus courant
- **AND** la configuration persistée contient
  `export SOFTWARES_APT_CHATGPT=1`

#### Scenario: Désinstallation persistée

- **WHEN** `diu softwares remove apt chatgpt` réussit
- **THEN** `SOFTWARES_APT_CHATGPT` vaut `0` dans le processus courant
- **AND** la configuration persistée contient
  `export SOFTWARES_APT_CHATGPT=0`
- **AND** une initialisation ultérieure ne considère pas ChatGPT comme installé

# software-management Specification

## Purpose

Définir la gestion des mises à jour des paquets Debian officiels par le moteur
`deb` du DIU.

## Requirements

### Requirement: Mise à jour globale des paquets Debian

Le moteur `deb` SHALL collecter les paquets installés dont une version
officielle est disponible, puis SHALL exécuter leur mise à jour dans une seule
transaction APT. Il SHALL ne pas afficher de ligne individuelle pour les
paquets déjà à jour ou non applicables.

#### Scenario: Plusieurs paquets Debian

- **WHEN** plusieurs paquets installés disposent d'une mise à jour officielle
- **THEN** une seule transaction APT est exécutée avec toutes les cibles

#### Scenario: Paquets sans action

- **WHEN** un paquet est déjà à jour ou sans candidat Debian officiel
- **THEN** il est ignoré sans message individuel et sans installation
  supplémentaire

### Requirement: Routage du cycle de vie des logiciels

DIU SHALL accepter `rid install <ENGINE> <SOFTWARE>`,
`rid remove <ENGINE> <SOFTWARE>`, `rid update <ENGINE> <SOFTWARE>` et
`rid update <ENGINE>`. Les moteurs définis SHALL être `deb` et `apt`.
Le logiciel SHALL être obligatoire pour installer ou désinstaller.
Un moteur inconnu, un identifiant invalide ou des arguments supplémentaires
SHALL provoquer un échec explicite avant toute opération sur le système.

#### Scenario: Installation ciblée

- **WHEN** `rid install deb geany` est invoqué
- **THEN** DIU délègue l'installation de `geany` au moteur `deb`

#### Scenario: Désinstallation sans logiciel

- **WHEN** `rid remove deb` est invoqué
- **THEN** DIU retourne une erreur de syntaxe sans désinstaller de paquet

#### Scenario: Moteur inconnu

- **WHEN** une commande désigne un moteur inconnu
- **THEN** DIU retourne une erreur sans exécuter d'opération de remplacement

### Requirement: Paquets officiels Debian

Le moteur `deb` SHALL installer, désinstaller et mettre à jour les paquets
logiciels officiels Debian à l'aide de la gestion APT Debian.
Il SHALL vérifier que le paquet ciblé relève de son périmètre et SHALL NOT
sélectionner une version issue d'un dépôt tiers, y compris pour les dépendances.
Il SHALL signaler l'impossibilité de satisfaire ce périmètre sans basculer
implicitement vers le moteur `apt`.

#### Scenario: Installation officielle

- **WHEN** `rid install deb <SOFTWARE>` cible un paquet officiel disponible
- **THEN** DIU installe ce paquet et ses dépendances nécessaires depuis les sources officielles autorisées

#### Scenario: Version tierce candidate

- **WHEN** un dépôt tiers fournit une version candidate du paquet demandé
- **THEN** le moteur `deb` ne sélectionne pas cette version tierce
- **AND** il échoue explicitement si aucune résolution officielle admissible n'est possible

#### Scenario: Désinstallation officielle

- **WHEN** `rid remove deb <SOFTWARE>` cible un paquet officiel installé
- **THEN** DIU demande sa désinstallation au gestionnaire de paquets
- **AND** tout échec est propagé à l'appelant

### Requirement: Portée des mises à jour du moteur deb

`rid update deb <SOFTWARE>` SHALL mettre à jour uniquement le logiciel officiel
ciblé et les dépendances nécessaires à cette opération.
`rid update deb` SHALL traiter tous les paquets officiels Debian installés,
y compris ceux installés en dehors de DIU, sans inclure les logiciels tiers.
Une mise à jour SHALL NOT installer un logiciel cible absent.

#### Scenario: Mise à jour ciblée

- **WHEN** `rid update deb geany` est invoqué pour un paquet installé
- **THEN** DIU limite l'opération à ce paquet et à ses dépendances nécessaires

#### Scenario: Mise à jour de tous les paquets officiels

- **WHEN** `rid update deb` est invoqué
- **THEN** DIU traite les mises à jour admissibles de tous les paquets officiels installés
- **AND** il ne met pas à jour les paquets tiers

#### Scenario: Logiciel cible absent

- **WHEN** une mise à jour ciblée désigne un logiciel non installé
- **THEN** DIU signale cette absence sans installer le logiciel

### Requirement: Logiciels tiers avec dépôt

Le moteur `apt` SHALL déterminer, à partir de la définition du logiciel, si
l'installation dépend d'un dépôt. Si oui, il SHALL déléguer la préparation de
ce dépôt au moteur de dépôts DIU avant d'installer le paquet.
Il SHALL NOT reproduire localement un moteur de dépôts de remplacement.
La désinstallation et la mise à jour SHALL cibler les paquets du logiciel tiers.

#### Scenario: Dépôt requis

- **WHEN** `rid install apt <SOFTWARE>` cible un logiciel nécessitant un dépôt
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

- **WHEN** `rid install apt <SOFTWARE>` cible un logiciel déclaré sans dépôt
- **THEN** DIU appelle sa fonction spécifique d'installation
- **AND** il n'appelle pas le moteur de dépôts

#### Scenario: Désinstallation sans dépôt

- **WHEN** `rid remove apt <SOFTWARE>` cible un logiciel déclaré sans dépôt
- **THEN** DIU appelle sa fonction spécifique de désinstallation

#### Scenario: Mise à jour sans dépôt

- **WHEN** `rid update apt <SOFTWARE>` cible un logiciel déclaré sans dépôt
- **THEN** DIU appelle sa fonction spécifique de mise à jour

#### Scenario: Fonction indisponible

- **WHEN** une action ne dispose pas de fonction spécifique pour le logiciel
- **THEN** DIU signale l'action non prise en charge et retourne un code non nul

### Requirement: Mise à jour de tous les logiciels tiers

`rid update apt` SHALL traiter tous les logiciels tiers installés et reconnus
par DIU, selon leur mode avec dépôt ou sans dépôt, sans traiter les logiciels
officiels du moteur `deb` ni installer des logiciels absents.

#### Scenario: Mise à jour du moteur apt

- **WHEN** `rid update apt` est invoqué et le moteur est disponible
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

### Requirement: Isolation des sources officielles dans la première étape

Le moteur `deb` SHALL utiliser des index temporaires limités aux dépôts d'origine
Debian de la version installée, avec ses suites updates et security, vérifiés
avec le trousseau officiel Debian. Il SHALL NOT modifier les sources persistantes
ni inclure les backports ou une autre version majeure de Debian.
Une origine installée non vérifiable SHALL entraîner un refus explicite.

#### Scenario: Sources officielles et tierces mélangées

- **WHEN** la machine dispose de dépôts officiels et tiers
- **THEN** la transaction deb utilise uniquement les index officiels isolés
- **AND** les sources persistantes restent inchangées

#### Scenario: Version installée introuvable dans les index officiels

- **WHEN** la version installée ne figure ni dans les index officiels actualisés ni dans les anciens index officiels disponibles
- **THEN** DIU refuse l'opération sur ce paquet et signale une origine non vérifiable

#### Scenario: Moteur apt réservé à une étape ultérieure

- **WHEN** une commande apt est invoquée dans la première étape sans moteur implémenté
- **THEN** DIU retourne un code non nul et annonce explicitement son indisponibilité

### Requirement: Commandes modulaires du moteur APT

DIU SHALL accepter les commandes `rid softwares install apt <SOFTWARE>`,
`rid softwares remove apt <SOFTWARE>`, `rid softwares update apt <SOFTWARE>`
et `rid softwares apt update`.

#### Scenario: Commande granulaire

- **WHEN** l'utilisateur invoque `rid softwares install apt <SOFTWARE>`
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

`rid softwares apt update` SHALL mettre à jour tous les paquets installés avec
APT. Elle SHALL NOT rejouer les fonctions granulaires `install`, `remove` ou
`update` propres aux logiciels.

#### Scenario: Mise à jour globale

- **WHEN** l'utilisateur invoque `rid softwares apt update`
- **THEN** DIU met à jour les paquets installés avec APT une seule fois

#### Scenario: Mise à jour globale du DIU

- **WHEN** l'utilisateur invoque `rid update`
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

Le scope `softwares` SHALL déclarer statiquement
`SOFTWARES_APT_CHATGPT` et `SOFTWARES_APT_CHATGPT_HOME` avec l'état `ENABLE`.
La valeur par défaut de
`SOFTWARES_APT_CHATGPT` SHALL être `0`, puis son initialisation SHALL détecter
le statut installé du paquet Debian `chatgpt` et produire `1` lorsqu'il est
installé lorsque la variable n'est pas encore définie. Une valeur déjà
persistée SHALL être conservée. La valeur par défaut de
`SOFTWARES_APT_CHATGPT_HOME` SHALL être `~/.codex`. Le fichier `softwares.env`
SHALL persister les deux variables,
avec une ligne `export SOFTWARES_APT_CHATGPT=0|1` et une ligne littérale
`export SOFTWARES_APT_CHATGPT_HOME=~/.codex` pour la valeur par défaut.

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

`rid install apt chatgpt` et `rid softwares install apt chatgpt` SHALL utiliser
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

`rid remove apt chatgpt` et `rid softwares remove apt chatgpt` SHALL supprimer le paquet `chatgpt`, puis
retirer le dépôt CGPT avec le moteur `system`, puis actualiser les index APT.
Tout échec SHALL être propagé et l'ordre SHALL être conservé.

#### Scenario: Désinstallation complète

- **WHEN** ChatGPT est installé et le dépôt CGPT est actif
- **THEN** DIU supprime le paquet, retire le dépôt, puis actualise les index
  APT

### Requirement: Mise à jour sélective APT de ChatGPT

`rid update apt chatgpt` et `rid softwares update apt chatgpt` SHALL vérifier
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

`rid softwares update apt` SHALL exécuter `rid softwares apt update`, puis
réexécuter les mises à jour sélectives des logiciels APT reconnus et installés.
La phase sélective SHALL toujours être exécutée après la phase APT. Les
logiciels absents ou non déclarés SHALL être ignorés sans installation.

#### Scenario: Ordre des phases

- **WHEN** l'utilisateur invoque `rid softwares update apt`
- **THEN** DIU exécute d'abord la mise à jour APT globale
- **AND** DIU exécute ensuite les mises à jour sélectives applicables

#### Scenario: Logiciel absent

- **WHEN** un logiciel reconnu n'est pas installé
- **THEN** DIU ne rejoue pas sa mise à jour sélective
- **AND** DIU ne l'installe pas

### Requirement: Dispatch de la mise à jour du module softwares

`rid softwares update` SHALL lancer les mises à jour des sous-modules
`softwares` disponibles. Les comportements, prérequis, erreurs et validations
de chaque sous-module restent définis par leurs spécifications respectives.

#### Scenario: Mise à jour du module softwares

- **WHEN** l'utilisateur invoque `rid softwares update`
- **THEN** DIU lance les mises à jour de ses sous-modules disponibles

### Requirement: Moteur GitHub pour les logiciels

DIU SHALL accept `rid softwares install github <SOFTWARE>`,
`rid softwares remove github <SOFTWARE>`, `rid softwares update github
<SOFTWARE>` and `rid softwares update github`. The engine SHALL route only to
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

`rid softwares update github` SHALL traiter uniquement les recettes GitHub
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

DIU SHALL déclarer `SOFTWARES_APT_CODEX_CLI` avec une valeur initiale `0` et
`SOFTWARES_APT_CODEX_CLI_HOME` avec une valeur initiale `~/.codex`.
Lors de l’initialisation, DIU SHALL positionner la première variable à `1`
lorsqu’un binaire `codex` exécutable est présent, et à `0` sinon. La valeur
persistée du répertoire HOME SHALL rester cohérente avec la valeur configurée.

#### Scenario: Codex absent

- **WHEN** aucun binaire Codex CLI exécutable n’est disponible
- **THEN** `SOFTWARES_APT_CODEX_CLI` vaut `0`

#### Scenario: Codex présent

- **WHEN** un binaire Codex CLI exécutable est disponible
- **THEN** `SOFTWARES_APT_CODEX_CLI` vaut `1`

### Requirement: Installation GitHub de Codex CLI

`rid softwares install github codex-cli` SHALL installer Codex CLI depuis une
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

`rid softwares remove github codex-cli` SHALL supprimer les binaires, liens et
releases installées par DIU, mais SHALL préserver le répertoire et les données
du profil défini par `SOFTWARES_APT_CODEX_CLI_HOME`.

#### Scenario: Désinstallation

- **WHEN** Codex CLI est installé par DIU
- **THEN** ses binaires et artefacts d’installation sont supprimés
- **AND** le profil Codex n’est pas supprimé
- **AND** `SOFTWARES_APT_CODEX_CLI` vaut `0`

### Requirement: Mise à jour ciblée depuis GitHub

`rid softwares update github codex-cli` SHALL comparer la version locale de
Codex CLI avec la dernière release GitHub. Elle SHALL télécharger et installer
la release uniquement si elle est supérieure. Elle SHALL définir `CODEX_HOME`
à partir de `SOFTWARES_APT_CODEX_CLI_HOME` lors de l’exécution de Codex CLI.

#### Scenario: Nouvelle release

- **WHEN** GitHub fournit une version supérieure à la version locale
- **THEN** DIU installe la nouvelle version après vérification SHA-256

#### Scenario: Version à jour

- **WHEN** la version locale est égale ou supérieure à la release GitHub
- **THEN** DIU n’effectue aucun téléchargement ni remplacement

### Requirement: Mise à jour globale GitHub

`rid softwares update github` SHALL traiter Codex CLI uniquement lorsque sa
variable d’état indique qu’il est installé. `rid softwares update` et
`rid update` SHALL inclure cette opération une seule fois.

#### Scenario: Codex absent

- **WHEN** `SOFTWARES_APT_CODEX_CLI` vaut `0`
- **THEN** la mise à jour globale n'installe pas Codex CLI

### Requirement: Désactivation de la variable HOME Codex CLI

Le fichier déclaratif Codex CLI SHALL être à l'état `DISABLE`. DIU SHALL NOT
créer, utiliser ou persister `SOFTWARES_APT_CODEX_CLI_HOME`. L'installation
SHALL exposer directement le binaire extrait par un lien symbolique et SHALL
NOT générer de wrapper shell.

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

- **WHEN** `rid softwares install github codex-cli` réussit
- **THEN** DIU affiche `✅ softwares/github/codex-cli (<VERSION>): installé.`

#### Scenario: Désinstallation avec version

- **WHEN** `rid softwares remove github codex-cli` réussit
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

- **WHEN** `rid softwares install apt chatgpt` réussit
- **THEN** DIU gère le paquet et son dépôt sans modifier
  `/usr/share/applications/chatgpt.desktop`
- **AND** DIU n'utilise ni ne persiste `SOFTWARES_APT_CHATGPT_HOME`

### Requirement: Cohérence persistée de l'état Codex CLI

Après une installation ou une désinstallation réussie de Codex CLI, DIU SHALL
persister la valeur correspondante de `SOFTWARES_APT_CODEX_CLI` dans
`/root/diu/config/softwares.env` lorsque ce fichier est accessible en écriture.

#### Scenario: Désinstallation persistée

- **WHEN** `rid softwares remove github codex-cli` réussit
- **THEN** `SOFTWARES_APT_CODEX_CLI` vaut `0` dans le processus courant
- **AND** la configuration persistée contient `export SOFTWARES_APT_CODEX_CLI=0`
- **AND** une initialisation ultérieure ne considère pas Codex CLI comme installé

#### Scenario: Mise à jour après désinstallation

- **WHEN** `rid softwares update github codex-cli` est invoqué alors que
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

- **WHEN** `rid softwares install apt chatgpt` réussit
- **THEN** `SOFTWARES_APT_CHATGPT` vaut `1` dans le processus courant
- **AND** la configuration persistée contient
  `export SOFTWARES_APT_CHATGPT=1`

#### Scenario: Désinstallation persistée

- **WHEN** `rid softwares remove apt chatgpt` réussit
- **THEN** `SOFTWARES_APT_CHATGPT` vaut `0` dans le processus courant
- **AND** la configuration persistée contient
  `export SOFTWARES_APT_CHATGPT=0`
- **AND** une initialisation ultérieure ne considère pas ChatGPT comme installé

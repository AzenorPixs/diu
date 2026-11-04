## MODIFIED Requirements

### Requirement: Structure et version documentaire

Le document SHALL conserver le titre `DEVOPS.md — <ID PROJECT>`, la version
`0.6` et l'ordre du scénario « Rubriques documentaires conservées ».
Pour template, le titre SHALL être `DEVOPS.md — Template`.
Matériel SHALL suivre immédiatement Système d'exploitation.
Chaque rubrique logicielle SHALL placer le chemin après la version ;
PostgreSQL Serveur SHALL placer l'adresse après la version.
Tests navigateurs extérieurs en mode headless SHALL terminer le document.

#### Scenario: Actualisation d'un document ancien

- **WHEN** DEVOPS.md existe avec des versions anciennes
- **THEN** toutes les versions logicielles sont sondées de nouveau et les valeurs anciennes sont remplacées
- **AND THEN** la version documentaire devient 0.6 et les rubriques existantes conservent leur ordre relatif
- **AND THEN** une seule section Prompts précède la section finale Tests navigateurs extérieurs en mode headless

#### Scenario: Rubriques documentaires conservées

- **WHEN** un document DevOps est généré
- **THEN** les rubriques restent dans l'ordre : Système d'exploitation, Matériel, `Docker, pour tests nécessitant des droits root`, Docker-Compose, Git, Go, Node, NPM, OpenCode, OpenSpec, OpenSSL, PostgreSQL Client, PostgreSQL Serveur, Python, Python - Dépendances du projet - Source de vérité `pyproject.toml`, Python - Gestionnaire de paquets, Prompts, Tests navigateurs extérieurs en mode headless
- **AND THEN** seules les métadonnées de traçabilité et la légende précèdent la première rubrique, après la version documentaire
- **AND THEN** la section finale contient Chromium puis Firefox

## ADDED Requirements

### Requirement: Structure de l'inventaire matériel TPM

La rubrique Matériel SHALL contenir une sous-rubrique TPM avec six puces
dans cet ordre : Chemin, Version, Fabricant, Identifiant fournisseur,
Révision de spécification, Registres PCR. Le rendu SHALL être commun aux
générations individuelle, groupée et finale de création.

#### Scenario: Rendu matériel commun

- **WHEN** un des trois parcours génère le document
- **THEN** Matériel et TPM apparaissent une seule fois après l'OS et avant Docker
- **AND THEN** les six champs sont présents dans l'ordre prévu

### Requirement: Sélection locale et version du TPM

DIU SHALL sélectionner un périphérique caractère tpmrmN avant tpmN dans
l'ordre lexical C de chaque famille. La version majeure sysfs du même
indice SHALL fournir 1.2 ou 2.0 pour les valeurs 1 ou 2. Une famille TPM 2
valide MAY compléter une version sysfs indisponible. DIU SHALL conserver
le chemin choisi si les sondes échouent, sans repli sur un autre TPM.

#### Scenario: Gestionnaire de ressources disponible

- **WHEN** /dev/tpmrm0 et /dev/tpm0 sont visibles
- **THEN** Chemin indique /dev/tpmrm0 en première puce
- **AND THEN** la version provient du sysfs de tpm0 ou de la famille observée

#### Scenario: Gestionnaire absent

- **WHEN** seul un périphérique caractère tpmN est visible
- **THEN** son chemin est sélectionné et le sysfs du même indice est utilisé

#### Scenario: Aucun périphérique visible

- **WHEN** aucun périphérique TPM n'est visible dans le contexte DIU
- **THEN** les six champs indiquent cette indisponibilité sans conclure à une absence physique
- **AND THEN** aucune sonde TPM n'est exécutée

### Requirement: Propriétés publiques du TPM

DIU SHALL utiliser uniquement properties-fixed de tpm2_getcap déjà présent
pour relever la famille, la valeur ASCII et le code hexadécimal de
TPM2_PT_MANUFACTURER, puis TPM2_PT_REVISION. Fabricant SHALL utiliser la
valeur ASCII ; Identifiant fournisseur SHALL utiliser le code hexadécimal.
Une propriété absente, invalide ou dupliquée SHALL rester non vérifiable.

#### Scenario: Propriétés disponibles

- **WHEN** la sonde renvoie des propriétés publiques reconnues
- **THEN** famille, fabricant, identifiant et révision de spécification sont rendus séparément
- **AND THEN** aucune version de firmware n'est utilisée comme révision de spécification

#### Scenario: Propriétés incomplètes ou mal formées

- **WHEN** une propriété manque, est dupliquée ou n'a pas un format reconnu
- **THEN** le champ concerné reste non vérifiable et les autres champs valides sont conservés
- **AND THEN** aucune valeur brute non reconnue n'est publiée ou exécutée

### Requirement: Inventaire des registres PCR alloués

DIU SHALL utiliser uniquement pcrs de tpm2_getcap pour indiquer les banques
et leurs indices PCR alloués. DIU SHALL NOT lire les valeurs de registres,
choisir arbitrairement un PCR ou modifier l'allocation. Une réponse vide,
ambiguë ou mal formée SHALL rester non vérifiable.

#### Scenario: Plusieurs banques allouées

- **WHEN** pcrs fournit des banques et des listes d'indices valides
- **THEN** Registres PCR contient chaque banque et ses indices sans valeur de registre

#### Scenario: PCR impossibles à relever

- **WHEN** la réponse PCR échoue ou n'est pas reconnue
- **THEN** Registres PCR indique cette limite sans bloquer la génération ni effacer les propriétés valides

### Requirement: Sondes TPM bornées et sans mutation

Chaque sonde SHALL utiliser le transport explicite device du chemin retenu,
avec 5 secondes de délai et une seconde supplémentaire avant terminaison
forcée. DIU SHALL NOT installer un outil, modifier permissions ou TPM,
utiliser un transport réseau implicite ou publier stderr. Une indisponibilité
SHALL produire un diagnostic fixe par champ sans bloquer le document.

#### Scenario: Outil absent ou accès refusé

- **WHEN** tpm2_getcap manque ou le périphérique n'est pas accessible
- **THEN** chemin et version sysfs disponibles sont conservés, les autres champs explicitent la limite
- **AND THEN** aucune installation ni élévation de privilèges n'est tentée

#### Scenario: Sonde expirée ou échouée

- **WHEN** une requête échoue ou dépasse son délai
- **THEN** ses champs indiquent une sonde échouée ou expirée sans exposer ses sorties
- **AND THEN** la génération continue avec les autres informations vérifiables

#### Scenario: TPM 1.2 visible

- **WHEN** sysfs indique un TPM 1.2
- **THEN** chemin et version sont rendus, les autres champs signalent la limite de la sonde TPM 2
- **AND THEN** tpm2_getcap n'est pas exécuté

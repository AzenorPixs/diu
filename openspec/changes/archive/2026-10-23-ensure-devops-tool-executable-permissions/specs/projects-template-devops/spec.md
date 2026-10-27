## ADDED Requirements

### Requirement: Préparation des exécutables DevOps connus

Avant les inventaires et sondes du rendu commun, DIU SHALL préparer uniquement
ces chemins sous `/home/${ENV_DEVOPS_USER}` : `go/current/bin/go`,
`node/current/bin/node`, `node/current/bin/npm`, `.opencode/bin/opencode`,
`.local/npm/bin/openspec`, `python/current/bin/python3` et
`python/current/bin/pip3`. Les outils absents SHALL rester indisponibles sans
création ni installation. La version documentaire, les commandes et le
contexte des sondes SHALL rester inchangés.

#### Scenario: Sept outils présents sans droit d'exécution

- **WHEN** les sept fichiers DevOps existent sans bits d'exécution
- **THEN** DIU ajoute leurs bits ugo+x avant les inventaires et les sondes
- **AND THEN** les versions et inventaires disponibles sont relevés normalement
- **AND THEN** propriétaires, droits de lecture et d'écriture, outils hôte et autres fichiers restent inchangés

### Requirement: Confinement de la préparation DevOps

DIU SHALL résoudre chaque cible existante et SHALL vérifier qu'elle est un
fichier ordinaire dans le domicile canonique DevOps avant de modifier ses
droits. DIU SHALL NOT parcourir récursivement le domicile, modifier les outils
hôte ou modifier un autre fichier pour cette préparation. Une cible externe
ou non ordinaire SHALL être refusée sans modification de cette cible.

#### Scenario: Cible externe ou non ordinaire

- **WHEN** un chemin connu désigne une cible externe ou un objet non ordinaire
- **THEN** DIU refuse la préparation sans modifier cette cible
- **AND THEN** le document précédent est conservé

### Requirement: Ajout idempotent des droits d'exécution

DIU SHALL ajouter les seuls bits `ugo+x` manquants et SHALL conserver le
propriétaire et les droits de lecture et d'écriture. Un fichier déjà doté de
ces trois bits SHALL rester inchangé. Les liens internes SHALL être conservés.

#### Scenario: Liens symboliques internes et réexécution

- **WHEN** un chemin connu désigne un fichier via un lien interne au domicile DevOps
- **THEN** DIU prépare sa cible ordinaire sans remplacer le lien
- **AND THEN** une réexécution ne modifie pas les fichiers déjà dotés des trois bits d'exécution

### Requirement: Diagnostics et échecs de préparation DevOps

Une sonde directe SHALL distinguer fichier absent et fichier présent non
exécutable sans modifier ses droits. Une préparation impossible SHALL arrêter
la génération avec un code non nul et un diagnostic contextuel avant les
inventaires et sondes suivants. Le DEVOPS.md précédent SHALL être conservé.
Les droits déjà préparés SHALL rester appliqués sans annulation automatique.

#### Scenario: Outil absent ou sonde directe non exécutable

- **WHEN** un outil connu est absent ou une sonde directe reçoit un fichier non exécutable
- **THEN** le diagnostic distingue binaire absent et binaire non exécutable
- **AND THEN** aucun fichier manquant n'est créé ni remplacé par un outil hôte

#### Scenario: Préparation refusée

- **WHEN** une cible sort du domicile, n'est pas un fichier ordinaire, ne peut pas être résolue ou ses droits ne peuvent pas être préparés
- **THEN** DIU retourne un code non nul avec un diagnostic contextuel sans lancer les inventaires et sondes suivants
- **AND THEN** le DEVOPS.md précédent est conservé
- **AND THEN** les droits déjà préparés restent appliqués sans annulation automatique

## MODIFIED Requirements

### Requirement: Écriture limitée et robuste

DIU SHALL limiter ses écritures à DEVOPS.md, ses temporaires et au manifeste Python conditionnel du projet, en UTF-8/LF, sauf préparation des exécutables DevOps connus. Tout échec SHALL être signalé par un code non nul et préserver l'existant. L'actualisation SHALL conserver droits et propriétaire. Synchronisation et préparation des créations SHALL rester inchangées ; les créations SHALL finir par la génération DevOps. À observations identiques, le contenu SHALL être identique hors horodatage.

#### Scenario: Échec de remplacement

- **WHEN** la préparation ou le remplacement du document échoue
- **THEN** le document existant est conservé et l'échec est signalé

#### Scenario: Réexécution stable

- **WHEN** deux exécutions observent le même environnement
- **THEN** le contenu documentaire produit est identique hors horodatage du début du relevé
- **AND THEN** chaque document indique le début de son propre relevé

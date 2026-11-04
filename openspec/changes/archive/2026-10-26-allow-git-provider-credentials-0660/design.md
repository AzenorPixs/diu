## Context

Les six lecteurs des trois bibliothèques vérifient actuellement `stat -c %a`
contre `600`. Les opérations Git et API délèguent à ces lecteurs. Les chemins
Forgejo, GitHub et GitLab ont été examinés sans ouvrir les identifiants réels.

## Goals / Non-Goals

Accepter les deux modes exacts `600` et `660`, sans migration. Les autres
modes, y compris ceux ajoutant des bits spéciaux, restent refusés. La création
initiale reste en `600`. Le stockage temporaire du cœur Git reste inchangé.
Aucun contournement par chmod, copie persistante ou affaiblissement TLS.

## Decisions

Conserver les lecteurs existants et ajouter localement la seconde valeur
admise. GitHub/GitLab stockent le résultat de stat une seule fois avant le
contrôle ; Forgejo dispose déjà de cette variable. Ne pas ajouter de helper
commun qui changerait les dépendances de chargement.

Les deux exigences longues de forgejo-release modifiées par le delta gardent
leurs contrôles existants dans des scénarios de contraintes conservées, afin
de satisfaire la validation stricte sans perdre de règle ni modifier les
comportements étrangers aux permissions.

## Risks / Trade-offs

Le groupe a accès en lecture et écriture aux identifiants en `660`. Ce partage
est explicitement demandé. Les permissions des répertoires et ACL restent
inchangées ; cette correction ne crée aucun accès système supplémentaire.

## Validation Strategy

Données fictives et ressources temporaires confinées au projet. Matrice des
six lecteurs : 600/660 acceptés, modes différents refusés avant lecture,
fichiers absents/vides en erreur, contenu et mode conservés. Parcours réels des
providers avec transport Git/API simulé sans réseau ; vérifier les secrets
temporaires Git en 600, le répertoire en 700 et le nettoyage même en échec.
Syntaxe Bash, ShellCheck, compilation Python, régressions projets et validation
OpenSpec ciblée puis globale comparée à l'état initial.

## Migration / Rollback

Aucune migration ni installation. Le retour aux anciennes sources rétablit
le refus de 660 ; aucune permission n'aura été changée par ce correctif.

## Context

`modules/diu/config.sh` charge `/root/diu/config/environnements.env` avant
de découvrir les déclarations `modules/diu/variables/<scope>/*.sh`.
Le mécanisme existant distingue une variable absente d'une variable vide.
La modification reste limitée aux déclarations et ne change pas le chargeur.

## Goals / Non-Goals

- Initialiser indépendamment les deux variables à `0`, seulement si absentes.
- Conserver toute valeur existante sans normalisation ni validation nouvelle.
- Persister avant d'exporter et propager explicitement les échecs attendus.
- Préserver les autres lignes et les autres scopes.
- Ne pas brancher ces indicateurs sur des actions Docker/LXC ni installer,
  exécuter ou configurer ces environnements.

## Decisions

Un fichier par variable déclare `config="STATIC"`, `state="ENABLE"`,
`scope="environnements"` et `default_value=0`. La destination reste
`/root/diu/config/${scope}.env`, conformément aux conventions existantes.
Les nouvelles déclarations suivent la gestion explicite des erreurs de
`system_time_zone.sh` : création du répertoire si nécessaire, écriture
contrôlée puis export. Elles retournent un statut non nul avec diagnostic
stderr si la création ou l'écriture échoue.

Une variable définie, même vide, est conservée et exportée sans réécriture.
Après un nouveau chargement du fichier persistant, la déclaration ne produit
aucune ligne supplémentaire. Chaque variable est traitée indépendamment.
La branche de désactivation déclarative conserve la convention existante :
retrait de la variable et de sa seule ligne persistante exacte.

Les tests travaillent dans des répertoires temporaires sous la racine du
projet. Ils redirigent les chemins des copies de test vers ce répertoire.
Un test d'intégration exerce le vrai chargeur avec seulement les deux
déclarations copiées et des chemins de configuration contrôlés. Aucun fichier
`.env` réel n'est lu ni exécuté.

## Risks / Trade-offs

Les variables n'activent aucun test : leurs consommateurs éventuels restent
hors périmètre. Comme les autres déclarations, l'initialisation se fonde sur
l'état de la variable après chargement de la configuration ; elle ne parcourt
pas à nouveau le fichier pour résoudre des valeurs concurrentes.

Un échec n'annule pas une autre déclaration déjà persistée. Aucune atomicité
globale ni protection contre plusieurs processus concurrents n'est ajoutée.
Il n'y a pas de migration et aucune valeur existante n'est remplacée.

## Repli et déploiement

La session ne modifie pas l'installation réelle. Les nouvelles valeurs
seront générées lors d'une prochaine exécution normale du DIU mis à jour.
Retirer ultérieurement les déclarations laisserait les valeurs déjà
persistées en place ; aucune suppression automatique ni opération de repli
sur la configuration réelle n'est incluse.

## Validation Strategy

Syntaxe Bash et ShellCheck des deux déclarations ; compilation du fichier de
test avec cache isolé ; tests unittest de première initialisation, export,
valeurs existantes, complétion partielle, idempotence, conservation des lignes
voisines, erreurs de persistance et découverte par le chargeur.
Validation stricte du change puis de la spécification canonique après
archivage ; comparaison des diagnostics globaux avant/après ; revue des
documents applicables et contrôle UTF-8/LF des fichiers produits.

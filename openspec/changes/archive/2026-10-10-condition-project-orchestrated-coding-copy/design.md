## Décision

Lire le mode avec project_orchestrated_coding_get depuis le project.env du
projet destination, jamais celui du modèle ni une valeur héritée du shell.
La synchronisation utilise une liste de fichiers racine commune à la
préparation, à la publication et au changement de propriétaire. Le document
conditionnel rejoint cette liste seulement pour Yes et suit la
personnalisation Markdown existante. sync all applique la décision par projet
et conserve sa poursuite après échec.

La création lit le mode après le questionnaire et avant la copie du modèle.
Pour No elle ajoute ORCHESTRATED_CODING.md aux exclusions racine existantes,
sans remplacer l'exclusion de project.env ni celle de pyproject.toml.
Pour Yes elle vérifie le document modèle avant de copier. Un échec conserve
le répertoire et la configuration déjà créés ; aucune suppression automatique
n'est introduite.

## Chevauchements OpenSpec

Le delta projects-sync de ce change conserve la sélection de la spécification
principale et ajoute exclusivement l'exception conditionnelle. Le delta actif
add-projects-sync-broker décrit déjà la sélection réduite implémentée
(AGENTS.md, .gitignore, PROMPTS). Son exigence de copie reçoit la même exception,
pour que son archivage futur conserve le comportement demandé. Ce change
ne rétablit aucune copie OpenCode ou CAB et ne reprend pas les tâches anciennes.

Le delta actif projects-template-creation de refactor-projects-template-copy
reçoit la même réserve conditionnelle dans son exigence et ses scénarios.
L'exclusion Git prévue dans cet autre change reste hors périmètre : elle
n'est pas implémentée par cette session. Les capacités synchronisées ici sont
projects-sync et implement-projects-update, pas projects-template-creation.

## Validation et limites

Tests synthétiques pour Yes, No, absence, vide, valeur invalide et fichier
source absent ; copies personnalisées, écrasement, préservation des attributs,
sélection indépendante par projet et poursuite après échec. Création avec le
questionnaire réel ; outils OpenSpec et DevOps simulés dans ces tests.
Les autres suites ciblées assurent la non-régression des exclusions et du CLI.

ShellCheck complet présente avant modification un SC2004 dans
project_env_set_variables (keys[${index}]). Ce diagnostic préexistant n'est
pas corrigé dans ce périmètre ; les fonctions modifiées sont également
analysées séparément sans suppression de diagnostics.

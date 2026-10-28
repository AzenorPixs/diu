## Context

projects_template_devops_section émet les puces version et chemin avec le séparateur final. Le rendu commun ajoute ensuite les dépendances OpenCode éventuelles.

## Goals / Non-Goals

Ajouter une puce statique après le chemin, avant le séparateur et les dépendances éventuelles. Conserver sondes, format, chemins et autres rubriques. Aucun accès supplémentaire à project.env, aucune lecture ou exposition du mot de passe.

## Decisions

Traiter OpenCode dans le helper de rubrique par un printf à format fixe et des arguments cités. Compléter le test de structure existant pour vérifier le bloc exact et l'unicité du texte. Ce test utilise déjà des sondes et projets fictifs.

## Risks / Trade-offs

La phrase indique la source conventionnelle de configuration ; elle ne prouve pas que la variable est définie ou que l'API fonctionne. Aucun test d'authentification réelle n'est nécessaire. Le retour au rendu précédent consiste à retirer la branche OpenCode du helper ; aucune migration.

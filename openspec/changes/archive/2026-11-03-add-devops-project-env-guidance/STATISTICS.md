# Statistiques — add-devops-project-env-guidance

## 1. Statistiques générales et décisions

Session SCM directe du 3 novembre 2026 ; un agent de codage. Change archivé,
code non attribué ; attribution ultérieure à traiter par ACL. Version DIU
1.0.7 vers 1.0.8 ; version documentaire DEVOPS.md 0.7 vers 0.8. Durée et
volumes de jetons : N/A, mesures non disponibles.

## 2. Types de messages et d'outils

Échanges avec le développeur, outils locaux de lecture, édition et validation.
Décomptes exhaustifs : N/A, télémétrie de session non disponible. Aucun agent
de pilotage ni collecte de télémétrie dédiée n'a été lancé.

## 3. Fichiers modifiés

Générateur `modules/projects/template.sh`, tests `tests/test_projects_template_devops.py`,
document local `DEVOPS.md`, valeur ciblée `PROJECT_VERSION` dans `project.env`,
`CHANGELOG.md`, `DEVELOPMENT_MAP.md`, `openspec/BATCH_CODES.md`, capacité
`openspec/specs/projects-template-devops/spec.md` et artefacts de cette archive.
Les données sensibles ne sont pas reproduites.

## 4. Commandes

`bash -n` et ShellCheck sur le générateur : réussis. Test ciblé du contenu :
réussi. Suite ciblée avec Python DevOps : 153 tests, dont 2 ignorés, réussie.
Suite globale avec Python DevOps : 1 105 tests, dont 2 ignorés, réussie.
Une première suite avec Python système a échoué : une attente de titre a été
corrigée et 26 erreurs de création de fixtures Python ont été évitées avec
l'interpréteur DevOps retenu par le projet. Validations OpenSpec strictes du
change et de la capacité : réussies. Archive créée le 2026-11-03.

## 5. Accès web

Aucun accès web effectué pendant la réalisation. Publications Git : résultat
non encore disponible au moment de la rédaction de ce rapport.

## 6. Synthèse globale

Le texte demandé est produit une fois avant la légende des sondes ; les
versions documentaire et DIU sont mises à jour. Les validations citées
ci-dessus établissent le résultat local, sans prouver de déploiement.
Rapport global : absent ; mandater SGS.md pour le générer.

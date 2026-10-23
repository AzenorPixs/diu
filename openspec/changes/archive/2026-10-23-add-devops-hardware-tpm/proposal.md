# Section Matériel et inventaire TPM du document DevOps

## Why

Le document DEVOPS.md ne décrit pas le TPM visible dans le contexte DIU.
Le développement utilisant un TPM a besoin de son chemin en premier, puis
de son identité et des registres PCR disponibles, sans modifier ce matériel.

## What Changes

- Ajouter Matériel immédiatement après Système d'exploitation, avec TPM.
- Afficher chemin, version, fabricant, identifiant fournisseur, révision de
  spécification et banques/indices PCR, dans cet ordre.
- Préférer les périphériques tpmrm aux périphériques tpm ; utiliser sysfs et
  les capacités publiques de tpm2_getcap déjà installé, avec transport local.
- Expliciter les données absentes, inaccessibles ou non vérifiables, sans
  bloquer le document, installer un outil ou changer des permissions.
- Conserver la version documentaire 0.6 et les autres comportements.

## Impact

Capacité : projects-template-devops. Code et tests :
modules/projects/template.sh et tests/test_projects_template_devops.py.
Documentation : TECHNICAL.md, README.md et CHANGELOG.md. Synchronisation,
archivage du seul change et STATISTIQUES.md font partie du périmètre validé.
DEVOPS.md existant reste inchangé jusqu'à sa prochaine génération normale.
Les autres informations matérielles restent des propositions.

## Autorisation

Le développeur a explicitement validé le périmètre TPM et le cycle OpenSpec
complet le 23 octobre 2026, puis demandé l'exécution SCM jusqu'à son terme.
La session est directe, sans pilotage OpenCode/CAB ni opération Git.

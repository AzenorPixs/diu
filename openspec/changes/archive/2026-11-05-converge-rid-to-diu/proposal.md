# Convergence des commandes et de l’aide vers DIU

## Why
Les commandes publiques sont `diu` et `diut`, mais le code, les alias générés, l’aide et les spécifications courantes utilisent encore les anciens noms. La convergence supprime cette incohérence.

## What Changes
- Employer `diu` en production et `diut` en développement dans le code, l’aide, les diagnostics et les exemples courants.
- Renommer les fonctions d’aide, la bibliothèque et ses tests, ainsi que la capacité courante d’aide.
- Générer les alias `diu`, `diut`, `diuo`, `diuu` et `ndiu` ; conserver les autres raccourcis, en basculant leurs appels vers `diut`.
- Harmoniser mécaniquement les spécifications courantes et les deltas actifs concernés. Préserver les identifiants de change, codes de lot et preuves archivées.
- **BREAKING** : les anciens alias DIU ne sont plus générés. Les sessions shell et fichiers d’alias déjà installés ne sont pas migrés par cette modification des sources.

## Capabilities

### New Capabilities
- `diu-command-convergence` : noms de commandes, alias dérivés et interfaces d’aide cohérents.

### Modified Capabilities
- `diu-command-links` : remplacer l’obligation de conserver les alias historiques par les alias DIU.

## Impact
`root-install-debian.sh`, `lib/diu-help.sh`, modules produisant des usages, tests associés, documentation courante, `openspec/specs/` et deltas actifs de l’aide. Les chemins des archives restent inchangés. Aucun changement des sous-commandes, des traitements métier, des cibles des liens ou des configurations protégées. Aucun commit, tag, publication, installation ou CI/CD dans cette session.

Code non attribué : attribution et normalisation définitive à traiter ultérieurement par ACL.

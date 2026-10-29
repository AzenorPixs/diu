# ENV09 — Alignement du format des indicateurs de test

## Why

Les deux nouvelles déclarations sont générées sans retrait, alors que le
développeur souhaite les aligner sur les lignes existantes du scope
`environnements`. L'exemple fourni montre huit espaces avant `export`.

## What Changes

- Préfixer de huit espaces les nouvelles lignes des deux indicateurs.
- Adapter leur suppression déclarative aux lignes avec ou sans retrait.
- Conserver les valeurs, les lignes déjà présentes et le défaut `0`.
- Ajuster les tests et la documentation dans le périmètre SCM précédent.

## Capabilities

### Modified Capabilities

- `devops-tests-environment-flags`: format des lignes persistées et retrait
  des déclarations indentées.

## Impact

Deux déclarations Bash, leur fichier de tests, TECHNICAL.md, README.md,
CHANGELOG.md et la spécification canonique. Cycle OpenSpec complet et rapport
d'archive dans la continuité du périmètre autonome approuvé. L'archive
initiale reste historique et inchangée.

La demande d'aligner les deux dernières variables, précisée par l'exemple du
développeur, autorise cette correction limitée. Aucun reformatage global,
accès au fichier de configuration réel ou changement de valeur n'est prévu.

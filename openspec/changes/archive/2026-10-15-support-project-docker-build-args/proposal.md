# ART10 — Arguments Docker publics par projet

## Why

La construction actuelle appelle Docker sans arguments de BUILD. Un projet
qui exige une version ou une empreinte explicite ne peut pas utiliser ce
parcours. Les valeurs applicatives doivent rester dans chaque projet ; le
moteur de construction reste générique.

## What Changes

- Lire le fichier public optionnel `build/docker-build.args` du projet.
- Valider intégralement ses lignes avant Docker, puis transmettre des paires
  `--build-arg`, `NOM=VALEUR` dans un tableau Bash, sans interprétation shell.
- Conserver arguments natifs, chemins, utilisateur, tag, contrôles et
  comportement des projets sans ce fichier.
- Couvrir refus et valeurs particulières par des tests isolés ; adapter un
  consommateur dans son propre dépôt.

## Capabilities

### New Capabilities

Aucune.

### Modified Capabilities

- `modify-projects-docker-build`: arguments optionnels littéraux, validation
  bloquante et diagnostics sans valeurs.

## Impact

Modifications limitées à `modules/projects/docker.sh`, tests dédiés,
PROJECT/TECHNICAL/README/CHANGELOG et ce change. BUILD porte exclusivement le
paquet Debian et reste inchangé ; AGENTS, DEVOPS, prompts et outillage de
pilotage restent inchangés. Aucun fournisseur applicatif, helper externe ou
version métier n'est ajouté au DIU. Le consommateur publie son fichier public
et vérifie sa concordance avec sa référence dans son dépôt.

Aucun fichier sensible réel n'est lu. Aucun commit, push, déploiement,
publication ou installation système n'est exécuté. Le cycle SCM comprend
validation, synchronisation et archivage de ce seul change s'il est éligible,
puis rapport d'archive sans sondes de statistiques de pilotage.

# Ajouter le nom d'hôte au document DevOps

## Why

L'inventaire système affiche l'OS sans identifier la machine de développement.
Le développeur demande la valeur de hostname -f juste après l'OS et valide
le passage du format documentaire de 0.6 à 0.7.

## What Changes

- Ajouter le résultat dynamique de hostname -f comme deuxième puce de la
  rubrique Système d'exploitation.
- Borner et isoler la sonde ; rendre explicitement les indisponibilités
  sans bloquer la génération.
- Passer le rendu commun, ses tests et la documentation courante à 0.7.
- Conserver les autres rubriques et les parcours individuel, groupé et de création.

## Impact

- Capacité : projects-template-devops.
- Code et tests : modules/projects/template.sh et tests/test_projects_template_devops.py.
- Documentation : TECHNICAL.md, README.md, CHANGELOG.md.
- Aucun nom d'hôte codé en dur, aucune configuration réseau, installation,
  opération Git ou régénération du DEVOPS.md courant.


# Ne plus définir les mots de passe des comptes techniques

## Objectif

Les environnements DevOps, Docker et IA sont configurés par root ; leur
provisionnement ne nécessite pas de définir un mot de passe. Supprimer cette
dépendance évite une erreur lorsque les anciennes variables sont absentes.

## Périmètre

Conserver les comptes existants et créer les comptes absents sans modifier ni
définir leur mot de passe. Conserver les configurations historiques, les
groupes, les choix rootless et les mécanismes existants de changement d'identité.
La publication et le commit sont exclus du mandat courant.

## Capacités

- Nouvelle capacité `technical-accounts-passwords` : provisionnement sans
  intervention sur les mots de passe des trois comptes.

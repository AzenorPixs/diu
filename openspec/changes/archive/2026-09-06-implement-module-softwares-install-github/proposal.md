# SW08 — Proposition : moteur d'installation des logiciels depuis GitHub

## Pourquoi

DIU dispose d'un moteur APT pour les logiciels tiers, mais ne possède pas de
moteur commun pour les logiciels distribués par les releases GitHub. Il faut
fournir un cycle de vie homogène tout en laissant à chaque logiciel sa recette
d'installation.

## Ce qui change

- ajouter le moteur `github` au routage des logiciels ;
- exposer les actions granulaires `install`, `remove` et `update` ;
- enregistrer explicitement les recettes GitHub, sans construire de fonction
  ou de commande à partir de l'identifiant utilisateur ;
- ajouter la mise à jour globale des logiciels GitHub installés et reconnus ;
- intégrer cette mise à jour à `rid softwares update` et `rid update` ;
- permettre à une recette de maintenir sa variable globale d'état à `0` ou `1`.

## Hors périmètre

- ajout d'une recette logicielle GitHub concrète ;
- choix d'un format d'archive ou d'une méthode d'installation propre à un
  logiciel ;
- modification des dépôts APT ou des sources persistantes ;
- téléchargement ou mutation réelle de la machine pendant les tests.

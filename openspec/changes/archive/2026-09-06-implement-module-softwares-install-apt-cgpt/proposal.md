# Proposition : installation de ChatGPT Desktop par APT

## Why

Le moteur `apt` du module `softwares` est désormais disponible, mais aucune
recette logicielle concrète n'est encore déclarée. DIU doit pouvoir gérer
ChatGPT Desktop depuis le dépôt APT OpenAI déjà pris en charge par le module
`system`, tout en conservant `CODEX_HOME` au lancement graphique.

## What Changes

- déclarer l'état d'installation de ChatGPT et son chemin `CODEX_HOME` dans le
  scope `softwares` ;
- ajouter les actions d'installation, de désinstallation et de mise à jour
  sélective du paquet `chatgpt` ;
- préparer ou retirer le dépôt CGPT via le moteur `system` ;
- réécrire l'entrée `Exec` de `/usr/share/applications/chatgpt.desktop` après
  installation et mise à jour.

## Out of Scope

- installation réelle sur la machine de développement ;
- modification du paquet Debian OpenAI ;
- ajout d'autres logiciels ou d'un nouveau moteur de dépôts.

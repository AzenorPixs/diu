# Affichage et résultat de la mise à jour hosts

## Why

Faciliter la consultation de hosts et rendre immédiatement visible le résultat de sa mise à jour.

## What Changes

Ajouter `system network hosts` pour afficher `/etc/hosts`. La commande ciblée `system network hosts update` émet une ligne avec coche verte ou croix rouge et cause courte, en conservant les codes de retour. Adapter les aides et tests. CI/CD explicitement exclue ; code de lot non attribué.

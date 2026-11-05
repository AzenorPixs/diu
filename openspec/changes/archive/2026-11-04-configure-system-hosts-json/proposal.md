# Configuration des hôtes par JSON

## Why

Permettre l'ajout de plusieurs couples IP/FQDN à la génération du fichier hosts sans modifier le code.

## What Changes

Créer un tableau JSON vide par environnement, ajouter les couples validés après le contenu standard et inclure un modèle vide protégé comme conffile dans le paquet Debian. Préserver hosts en cas de configuration invalide. Étendre aussi la recette générique et son moteur pour un conffile et un modèle JSON vide, afin que les deux constructeurs restent cohérents. Code de lot non attribué.

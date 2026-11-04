# Déplacer les commandes hosts vers system

## Why

Les commandes de gestion de hosts appartiennent au module système et partagent son chemin réseau.

## What Changes

Remplacer `projects system network hosts` par `system network hosts` pour add, del et list. Supprimer les anciens chemins et adapter les aides, sans modifier la gestion JSON ni les mises à jour réseau existantes. Code de lot non attribué.

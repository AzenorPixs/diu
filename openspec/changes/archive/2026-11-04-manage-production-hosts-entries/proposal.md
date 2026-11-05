# Gestion des entrées hosts de production

## Why

Administrer les couples IP/FQDN du fichier hosts de production depuis les commandes DIU, quel que soit le point d'entrée.

## What Changes

Ajouter les commandes projects system network add, del, del all et list. Après ajout, trier les adresses numériquement puis les FQDN alphabétiquement. Faire toujours lire le JSON de production par system network hosts update ; le fichier de développement absent est créé vide sans être utilisé. Code de lot non attribué.

# Corriger le faux avertissement APT

Code non attribué ; attribution ultérieure par ACL.

## Why
La capture de la sortie APT déclenche son message habituel sur la stabilité de son interface. Le bilan le classe à tort comme un avertissement de mise à jour et échoue.

## What Changes
Ignorer uniquement cette ligne exacte pour la classification, préserver les autres avertissements et les erreurs, et vérifier ces cas par des tests isolés. Aucune modification des opérations APT ou des autres commandes.

## Capabilities
- `system-update-report` : distinguer l'avertissement de compatibilité de l'interface APT des diagnostics de mise à jour.

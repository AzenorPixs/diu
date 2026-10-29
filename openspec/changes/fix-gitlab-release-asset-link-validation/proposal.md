# Validation du lien d’asset Debian GitLab

## Why

La réponse HTTP de création du lien d’asset est actuellement jetée : un
transport curl réussi peut masquer un refus HTTP et annoncer un faux succès.

## What Changes

- Capturer la réponse et vérifier le statut HTTP avant le message de succès.
- Propager refus et erreurs de transport sans exposer le corps de réponse.
- Tester les cas sur fixtures et transports simulés, sans appel distant.

## Capabilities

### Modified Capabilities

- implement-projects-gitlab-release : validation de création du lien d’asset.

## Impact

Plan ACSM-DIU-REGRESSIONS-SHELLCHECK-20261028-R1 validé, options U1 et Z1.
Les corrections de fixtures et annotations statiques associées préservent les
contrats actuels. Aucun changement de l’orchestrateur update_all, du générateur
Zsh, des archives ou de la configuration Git de la machine.

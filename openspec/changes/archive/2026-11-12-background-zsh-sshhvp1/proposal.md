## Why
Le raccourci sshhvp1 doit lancer SSH en arrière-plan avec contrôle du transfert X11 et sorties masquées.

## What Changes
- Ajouter -f et ExitOnForwardFailure=yes à SSH et rediriger les sorties.
- Préserver le parcours distant, les paramètres locaux et les définitions personnelles.

## Capabilities
### Modified Capabilities
- zsh-sshhvp1: fonctionnement du raccourci.

## Impact
Déclaration GLOBAL Zsh, tests et documentation ; OpenSpec et CICD SCM. Code non attribué.

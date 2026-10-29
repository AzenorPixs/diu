# SW05 — Persistance de l’état APT ChatGPT

## Why

Les recettes APT de ChatGPT modifient `SOFTWARES_APT_CHATGPT` dans le
processus courant, mais ne persistent pas toujours cette valeur dans
`config/softwares.env`. Après une relance, l'état déclaré peut donc diverger
de l'état réel du paquet `chatgpt`.

## What Changes

- persister l'état `SOFTWARES_APT_CHATGPT` après une installation réussie ;
- persister l'état `SOFTWARES_APT_CHATGPT` après une désinstallation réussie ;
- ajouter des tests couvrant les deux transitions.

## Hors périmètre

- modification de la gestion du dépôt ChatGPT ;
- modification de la mise à jour ciblée ou globale APT ;
- modification de `SOFTWARES_APT_CHATGPT_HOME`.

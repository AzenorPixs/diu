# ENV03 — Diagnostic des téléchargements Node.js

## Why

L'échec TLS du téléchargement de l'index Node.js est actuellement rapporté
deux fois par le piège ERR du DIU, avec une attribution trompeuse à `tail -n 1`.
Un passage temporaire par un portail captif a révélé ce diagnostic ambigu.

## What Changes

- Séparer le téléchargement de l'index de sa sélection de version.
- Traiter explicitement l'échec curl, conserver son diagnostic et son code de
  sortie, puis afficher un seul diagnostic DIU contextualisé par l'URL.
- Limiter la connexion à 10 secondes et le transfert à 60 secondes.
- Couvrir le comportement par des tests isolés sans réseau ni installation.

## Capabilities

### New Capabilities
- `devops-nodejs-download`: téléchargement borné et diagnostic explicite de
  l'index des versions Node.js DevOps.

### Modified Capabilities
Aucune.

## Impact

Le bloc Node.js de `root-install-debian.sh`, un test dédié et un paragraphe de
`TECHNICAL.md` sont concernés. La vérification TLS, l'URL officielle, la série
configurée et l'installation existante sont préservées. Aucun changement
réseau, dépendance, installation système ou opération Git n'est inclus.
Un téléchargement trop lent échoue désormais explicitement ; aucun repli ou
nouvelle tentative automatique n'est introduit.

Le développeur a validé le périmètre autonome : spécification, implémentation,
tests, documentation, synchronisation et archivage de ce seul change.

# Actualisation de l'état Codex CLI

## Why

Une valeur persistée peut devenir obsolète après une installation ou suppression extérieure au DIU.

## What Changes

Recalculer `SOFTWARES_APT_CODEX_CLI` à chaque chargement de sa déclaration en fonction du binaire exécutable `codex` accessible dans le PATH du processus DIU, puis conserver la persistance existante. La recette GitHub reste inchangée.

## Capabilities

### Modified Capabilities
- `software-management`: actualisation de l'état Codex CLI.

## Impact

Une valeur préexistante est remplacée par le résultat de la détection à chaque chargement ; une installation hors du PATH du DIU ne peut pas être détectée.

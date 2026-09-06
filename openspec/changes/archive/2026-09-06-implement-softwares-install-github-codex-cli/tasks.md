# Tâches

## Spécification

- [x] Définir le périmètre Linux x86_64 et GitHub Releases uniquement.
- [x] Définir les variables Codex CLI et la préservation du profil.
- [x] Définir les actions granulaires et l’intégration aux mises à jour.

## Implémentation

- [x] Ajouter les variables déclaratives Codex CLI.
- [x] Ajouter la recette `github/codex-cli` et ses utilitaires dédiés.
- [x] Garantir l’injection de `CODEX_HOME` à l’exécution de Codex CLI.
- [x] Ajouter le routage, les messages d’aide et la mise à jour globale.
- [x] Ajouter les tests sans téléchargement ni mutation réelle du système.

## Validation et clôture

- [x] Exécuter les tests et vérifications Bash.
- [x] Valider l’évolution avec OpenSpec.
- [x] Vérifier l’absence de modification hors périmètre.
- [x] Archiver l’évolution.

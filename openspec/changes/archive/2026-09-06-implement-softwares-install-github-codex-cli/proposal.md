# SW10 — Proposition : installer Codex CLI depuis GitHub

## Why

DIU doit gérer le cycle de vie du client Codex CLI distribué par les GitHub
Releases officielles d’OpenAI, sans dépendre de `releases.openai.com` ni de
`npm`.

## What Changes

- ajouter la recette explicite `github/codex-cli` ;
- ajouter les variables `SOFTWARES_APT_CODEX_CLI` et
  `SOFTWARES_APT_CODEX_CLI_HOME` ;
- installer, désinstaller et mettre à jour Codex CLI sur Linux x86_64 ;
- vérifier l’archive téléchargée avec SHA-256 ;
- exporter `CODEX_HOME` vers le répertoire configuré lors de l’exécution de
  Codex CLI ;
- intégrer Codex CLI aux mises à jour globales du moteur GitHub.

## Out of Scope

- macOS, Windows et ARM64 ;
- téléchargement depuis une source autre que GitHub ;
- modification ou suppression du profil utilisateur Codex (`CODEX_HOME`) lors
  de la désinstallation ;
- ajout d’une gestion npm ou d’une compilation depuis les sources.

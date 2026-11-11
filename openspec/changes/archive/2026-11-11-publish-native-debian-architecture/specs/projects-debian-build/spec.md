## ADDED Requirements

### Requirement: Publication selon les métadonnées Debian
Les publications Debian Forgejo et GitHub MUST lire Architecture et vérifier
le nom exact projet_version_architecture.deb. Elles MUST conserver les gardes
de version, tag, commit et unicité ; elles MUST NOT imposer all à un paquet natif.

#### Scenario: Paquet CAB natif
- **WHEN** cab3.0.0 déclare amd64 et son nom correspond aux métadonnées
- **THEN** le contrôle autorise la publication sans modifier le tag ou le paquet

#### Scenario: Architecture discordante
- **WHEN** un paquet amd64 porte un nom se terminant par all.deb
- **THEN** le contrôle refuse avant tout upload

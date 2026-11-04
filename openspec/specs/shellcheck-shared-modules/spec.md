# shellcheck-shared-modules Specification

## Purpose
TBD - created by archiving change migrate-env-devops-projects-root. Update Purpose after archive.

## Requirements

### Requirement: Analyse des modules partagés
Les modules `lib/gitlab-auth.sh`, `lib/docker.sh` et `modules/projects/projects.sh` MUST réussir `bash -n` et `shellcheck -x`. Les corrections MUST préserver les comportements non concernés. Les annotations locales MAY documenter les usages indirects ou expansions différées démontrés. La résolution GitLab MUST traiter littéralement l’autorité HTTPS.

#### Scenario: Analyse des modules concernés
- **WHEN** les trois modules sont analysés séparément avec les outils prescrits
- **THEN** les contrôles de syntaxe et ShellCheck réussissent.

#### Scenario: Comportements indirects
- **WHEN** un module expose des valeurs à son appelant ou exécute une expansion dans un autre shell
- **THEN** ces valeurs et cette expansion restent inchangées.

#### Scenario: Autorité IPv6 GitLab
- **WHEN** une URL HTTPS contient une autorité IPv6 entre crochets et un chemin propriétaire/dépôt valide
- **THEN** sa résolution conserve l’autorité et extrait le propriétaire et le dépôt.

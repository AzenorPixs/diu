# GIT19 — Why

La commande publique de commit Git d'un projet utilise l'abréviation isolée
`gitc`, alors que les autres opérations Git sont regroupées sous
`rid projects git`. Cette divergence rend l'interface moins prévisible et
l'aide contextuelle incomplète.

# What Changes

- Exposer le commit d'un dépôt local par
  `rid projects git commit <ID PROJECT> [COMMIT]`.
- **BREAKING** Retirer la commande publique historique
  `rid projects gitc <ID PROJECT> [COMMIT]`.
- Préserver les valeurs par défaut existantes du nom et du tag de commit.
- Mettre à jour les aides `rid projects help`, `rid projects git help` et
  `rid projects git commit help`.

# Capabilities

## New Capabilities

- `projects-git-commit`: Routage public du commit Git local d'un projet sous
  le sous-contexte `projects git`.

## Modified Capabilities

- `rid-help`: Les aides contextuelles présentent la commande canonique de
  commit et ne présentent plus l'alias retiré.

# Impact

Le dispatch de `root-install-debian.sh`, l'aide de `lib/rid-help.sh` et les
tests d'aide ciblés sont concernés. Aucune dépendance, configuration ni
fonction `git_commit` n'est modifiée.

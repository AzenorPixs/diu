## Context

Le générateur Bash possède déjà un analyseur Python et une borne utilisateur de 15 secondes. La proposition a été validée par le développeur avec le format documentaire 0.5.

## Goals / Non-Goals

Fournir un inventaire local lisible et reproductible pour les dépendances directes, sans parcourir les paquets tiers ni confondre déclaration, verrou et installation. Préserver toutes les sondes et écritures existantes.

## Decisions

- Un seul analyseur Python standard par rendu collecte les deux sous-sections ; deux fragments Markdown validés sont séparés par un caractère de contrôle interne jamais autorisé dans les données restituées.
- Les lectures JSON sont limitées, rejettent les doublons et n'exécutent aucun paquet. Les erreurs deviennent des diagnostics fixes.
- Découverte sans liens ni ressources exclues ; .opencode est traité uniquement par ses fichiers racine désignés. Les membres de workspaces sont identifiés par motifs confinés parmi les manifestes découverts.
- Les verrous locaux priment, npm-shrinkwrap prime sur package-lock. L'héritage est réservé aux workspaces déclarés. Les autres verrous sont signalés sans choisir implicitement un gestionnaire.
- Les métadonnées d'installation sont recherchées près du manifeste puis aux parents internes. Les liens d'installation internes sont admis ; les fichiers symboliques et cibles extérieures ou protégées sont refusés.
- Aucune dépendance supplémentaire ; Python DevOps isolé sans site, sinon Python système existant pour cette seule analyse.

## Risks / Trade-offs

Un arbre grand ou inaccessible peut produire un inventaire partiel, explicitement marqué. Les formats non pris en charge, références privées, caches externes OpenCode et compatibilités SemVer restent non vérifiés. La présence d'un SDK OpenCode ne prouve pas un plugin chargé.

## Validation

Fixtures synthétiques inspirées de Pixs, catégories, workspaces, liens, alias, verrous concurrents et invalides, limites, confidentialité, absence d'effets de bord et parcours existants. Contrôles Bash, shellcheck, compilation des programmes Python et régressions ciblées des templates.

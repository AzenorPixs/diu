## Why

La synchronisation des projets écrase actuellement les commandes, la
configuration et les skills OpenCode, ainsi que les ressources CAB locales
et globales. Ces ressources doivent désormais rester indépendantes de
`rid projects sync`. Le change actif est réorienté dans le périmètre validé
par le développeur, sans création d'un second change.

## What Changes

- Limiter les sources requises et les copies à `AGENTS.md`, `.gitignore`
  et `PROMPTS/` pour la synchronisation unitaire et groupée.
- Conserver la copie conditionnelle de `ORCHESTRATED_CODING.md` pour un mode
  destination `Yes` lu selon `implement-projects-update`. Pour `No`, une valeur
  absente ou vide, préserver la destination et ne pas exiger la source.
- Retirer les copies de `.opencode/commands`, `.opencode/config`,
  `.opencode/skills` et `.opencode/broker` dans les projets.
- Retirer la copie CAB globale vers `/home/${DEVOPS_USER}/.opencode/broker`.
- Préserver le contenu, les droits et le propriétaire des ressources exclues,
  y compris leurs caches, sans création ni suppression de ces ressources.
- Conserver la personnalisation Markdown, la sélection des projets, la
  poursuite après échec, les codes de retour et la préservation de `DEVOPS.md`.

## Capabilities

### New Capabilities

- Aucune.

### Modified Capabilities

- `projects-sync` : copie limitée aux ressources communes conservées et
  préservation des ressources OpenCode et CAB locales et globales.

## Impact

Sont concernés `modules/projects/projects.sh`, `tests/test_projects.py` et
la spécification `projects-sync`. Les ressources exclues déjà présentes ne
sont plus actualisées ni nettoyées par sync ; aucune migration ni suppression
physique n'est prévue. Les copies conservées peuvent toujours écraser leur
destination sans sauvegarde ni retour arrière automatique.

Le routage, la création de projets, les commandes de templates, les
dépendances et les configurations Git restent inchangés. Aucun déploiement,
aucune opération Git ni inspection de l'état Git n'appartient au périmètre.

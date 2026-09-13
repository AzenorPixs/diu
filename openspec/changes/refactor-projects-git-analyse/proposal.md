# Proposition : refactoriser l'analyse Git des projets

## Pourquoi

La commande publique historique `rid projects gita <ID PROJECT>` est placée
hors du sous-contexte `projects git`, contrairement aux autres opérations Git
des projets. Cette divergence rend l'interface moins cohérente.

## Changements

- Exposer l'analyse via `rid projects git analyse <ID PROJECTS>`.
- Retirer le routage public de `rid projects gita <ID PROJECT>`.
- Mettre à jour les aides `rid projects help` et `rid projects git help`.

## Impact

- La fonction existante `git_analyse` et son comportement restent inchangés.
- La syntaxe publique historique `gita` devient non reconnue.

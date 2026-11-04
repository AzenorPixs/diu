## Réalisation et validation

- [x] Harmoniser l'alignement des informations du projet et les libellés.
- [x] Annoncer les contrôles réellement réalisés par Forgejo, GitHub et GitLab et préciser les tags.
- [x] Tester les messages, les erreurs et l'absence de secret avec des fournisseurs simulés.
- [x] Mettre à jour les aides et la documentation pertinentes, puis valider le change.

## Preuves

- Suite globale Python DevOps : 1 119 tests, dont 2 ignorés, sans échec. Les dernières modifications ont été revérifiées par les tests ciblés Forgejo, GitHub et GitLab.
- Tests ciblés Forgejo push : 14 ; Forgejo Debian : 4 ; GitHub Debian : 28 ; projet GitLab : 32 ; rejeu : 10 ; aides : 59.
- Syntaxe Bash, ShellCheck et validation OpenSpec stricte du change réussies. Aucune publication réelle, aucun commit et aucun changement de version.

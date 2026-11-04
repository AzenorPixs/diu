# Blocages — diu-command-links

Constat du 2026-11-04 07:59 UTC, session SCM directe. Change ouvert ; archivage en attente.

Les liens et leur spécification ont été préparés. Les 88 tests ciblés réussis couvrent notamment l’extraction et l’exécution isolée du postinst, la racine personnalisée, les collisions et le point d’entrée par lien. Bash et ShellCheck -x réussissent. Aucune installation réelle n’a été exécutée.

| Tâche non validée | Dépendance et phase empêchée | Contrôles et reprise |
| --- | --- | --- |
| Mettre à jour la documentation et valider la cohérence globale. | La dépendance `migrate-env-devops-projects-root/tasks.md` laisse sa validation et sa publication ouvertes. Le constructeur du paquet a aussi changé pendant la session, en dehors de ce change : stabilité partagée non établie. Phase : intégration et validation finale. | Vérifier la finalisation et la disponibilité de la migration, réconcilier les changements concurrents et relancer les vérifications finales appropriées. |
| Synchroniser et archiver après validation de tous les critères et dépendances. | Dépend de la tâche précédente et de la validation de la migration. Phase : synchronisation et archivage. | Vérifier toutes les preuves et la cohérence, puis synchroniser et archiver uniquement ce change si éligible. |

Contrôles non exécutés : suite globale finale, installation réelle, synchronisation et archivage. Aucune publication ni commit réalisés. Aucun mécanisme de réservation propre à cette session n’a été mis en place.

## Réévaluation du 2026-11-04 à 08:24 UTC

La suite complète avec le Python DevOps réussit sur 1 160 tests, dont 2 ignorés ; 194 tests ciblés réussissent. La dépendance demeure ouverte : voir le [bilan de la migration](../archive/2026-11-04-migrate-env-devops-projects-root/STATISTICS.md). Sa validation ShellCheck et sa tâche de publication puis de reprise CISMP ne sont pas achevées. L’archivage de ce change reste donc en attente.

## Réévaluation du 2026-11-04 à 08:50 UTC

Les tests de liens et de packaging réussissent sur l’état courant (17 tests
avec le contrôle GitLab) et ShellCheck réussit. La suite globale est en échec
sur la divergence du paquet `hosts.json` dans le change alors actif
[configure-system-hosts-json](../archive/2026-11-04-configure-system-hosts-json/tasks.md) ; voir
aussi le [bilan de migration](../archive/2026-11-04-migrate-env-devops-projects-root/STATISTICS.md).
La validation globale et l’archivage attendent la cohérence et une suite
réussie ; aucune installation réelle n’est revendiquée.

## Réévaluation après archivage du change hosts

Le change `configure-system-hosts-json` a été archivé le 2026-11-04. Le test
`test_diu_recipe_matches_historical_builder` réussit désormais isolément.
La validation globale sur le nouvel état reste à exécuter ; son résultat ne
peut pas être déduit du seul test ciblé.

## Réévaluation après archivage de la migration

La migration a été synchronisée et archivée le 2026-11-04, après validation
OpenSpec stricte, ShellCheck et 1 164 tests dont 2 ignorés. La dépendance de
source est levée ; la validation et l’archivage des liens restent à finaliser.

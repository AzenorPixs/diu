# Suivi de reprise — reconcile-cicd-git-publication

## Constat du 2026-11-04

Le change reste ouvert. La création d'un commit est réservée au développeur. La reprise de la branche GitHub divergente par la fusion prévue nécessite un commit de fusion ; aucun n'a été créé et aucune référence distante n'a été modifiée pendant cette session. La branche GitHub `main` a été observée sur `c98edf59` et le commit local `v1.2.2` sur `0257946b` ; ces valeurs doivent être revérifiées avant toute publication. L'API GitHub trouvait le commit `0257946b` mais ne trouvait pas le tag `v1.2.2` lors du contrôle.

| Tâche non validée | Phase et état | Reprise vérifiable |
| --- | --- | --- |
| 2.2 Mettre à jour les spécifications et la documentation concernées. | Deltas et documentation préparés ; synchronisation des canons en attente. | Synchroniser les seules capacités concernées, puis vérifier la cohérence et les liens. |
| 2.3 Exécuter les tests ciblés et globaux, puis valider et archiver le change. | Tests exécutés sur fixtures ; archivage en attente des tâches restantes et des conditions SCM. | Revalider l'état courant, les canons et toutes les tâches avant archivage. |
| 2.4 Vérifier l'état réel et reprendre la publication 1.2.2 lorsque les conditions le permettent. | Publication non exécutée ; la fusion des historiques nécessite un commit que le développeur effectue lui-même. | Revérifier branche, tag et artefacts, puis reprendre la publication avec le code corrigé lorsque le commit nécessaire est disponible. |

Contrôles exécutés : 1 182 tests globaux avec Python 3.14.10, dont deux ignorés ; quatre tests de fusion et de lease ; syntaxe Bash ; ShellCheck avec exclusion des sources externes SC1091 ; validation stricte OpenSpec. L'exécution antérieure avec Python système 3.13 a échoué sur deux anciennes attentes de message corrigées et 26 erreurs de fixtures de venv ; elle ne constitue pas une validation globale réussie. Les tests n'établissent pas que GitHub acceptera la publication réelle.


## Reprise SCM du 2026-11-17

La référence de publication v1.2.2 mentionnée le 2026-11-04 est historique et
n'est pas réutilisée. L'environnement projet indique PROJECT_VERSION=1.3.16 ;
le parcours SCM courant prévoit l'incrément 1.3.17. Le développeur a demandé
explicitement le commit et la livraison par la commande DIU.

Le change couvre maintenant les versions stables à trois ou quatre composants.
Les suites ciblées (25 + 8 + 11 tests) et la suite globale (1 374 tests, 2
ignorés) ont réussi ; openspec validate reconcile-cicd-git-publication
--strict, Bash -n et ShellCheck ont réussi. Restent la synchronisation stricte
des canons, l'archivage et la livraison native DIU 1.3.17.


## Résultat de livraison et couverture CAB — 2026-11-17

La suite globale exécutée sur l'environnement DIU prescrit a réussi : 1 374
tests, 2 ignorés. Les suites ciblées version, push direct et rejeu CI/CD ont
réussi : 25, 8 et 11 tests. Les six spécifications canoniques et les contrôles
Bash/ShellCheck passent en strict/syntaxe.

Le contrôle global dans l'atelier CAB n'a pas fourni de preuve réussie :
la première exécution a été tuée sur le montage en lecture seule des fixtures ;
la seconde a terminé avec 15 échecs d'environnement (droits chown, absence de
/etc/os-release et fixtures hosts). Les résultats directs sur l'environnement
DIU restent réussis ; le reçu local CAB reste non passant. La livraison DIU
1.3.17 et son attestation native sont encore à établir.

## 1. Réconciliation et publication

- [x] 1.1 Préparer et tester la fusion isolée des branches avec priorité aux fichiers versionnés locaux.
- [x] 1.2 Implémenter et tester sur fixtures la publication des branches et tags avec protection contre les modifications concurrentes.
- [x] 1.3 Intégrer ces règles au CI/CD normal et au rejeu sans perdre les modifications locales en attente.
- [x] 1.4 Étendre la validation des versions stables et leur comparaison aux tags à quatre composants pour les pushes directs et le CI/CD.

## 2. Validation et livraison

- [x] 2.1 Tester sur fixtures la préservation et le signalement des artefacts existants.
- [x] 2.2 Synchroniser les spécifications et mettre à jour l'aide et la documentation pour les versions à trois ou quatre composants.
- [x] 2.3 Exécuter les tests ciblés et globaux, les contrôles syntaxiques et les validations OpenSpec strictes, puis préparer l'archivage.
- [x] 2.4 Vérifier PROJECT_VERSION=1.3.16 et préparer son incrément de livraison 1.3.17 sans réutiliser le repère historique 1.2.2.

Le suivi des opérations restantes figure dans [BLOCKERS.md](BLOCKERS.md).

## Sous-lots normalisés

### reconcile-cicd-git-publication — code non attribué : réconciliation Git

Tâches 1.1 à 1.4 ; dépendances : références et transport des fournisseurs ; contrôle : tests Git isolés de divergence, conflit, concurrence, rejeu et tags à quatre composants. État : VALIDÉ sur fixtures le 2026-11-04 : 4 tests de fusion et de lease, 30 tests CI/CD, 61 tests de routage ; aucune qualification distante.

### reconcile-cicd-git-publication — code non attribué : validation et reprise

Tâches 2.1 à 2.4 ; dépendance : réconciliation Git ; contrôle : tests de publication et validation globale, puis contrôle des références réelles. État : EN COURS ; extension aux versions x.y.z.w documentée et testée ; archivage après validation stricte des canons, livraison SCM/CICD 1.3.17 après archivage. L'attribution définitive du code et des sous-lots relève d'ACL.

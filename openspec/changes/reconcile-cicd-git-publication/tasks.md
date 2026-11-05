## 1. Réconciliation et publication

- [x] 1.1 Préparer et tester la fusion isolée des branches avec priorité aux fichiers versionnés locaux.
- [x] 1.2 Implémenter et tester sur fixtures la publication des branches et tags avec protection contre les modifications concurrentes.
- [x] 1.3 Intégrer ces règles au CI/CD normal et au rejeu sans perdre les modifications locales en attente.

## 2. Validation et livraison

- [x] 2.1 Tester sur fixtures la préservation et le signalement des artefacts existants.
- [ ] 2.2 Mettre à jour les spécifications et la documentation concernées.
- [ ] 2.3 Exécuter les tests ciblés et globaux, puis valider et archiver le change.
- [ ] 2.4 Vérifier l'état réel et reprendre la publication 1.2.2 lorsque les conditions le permettent.

Le suivi des opérations restantes figure dans [BLOCKERS.md](BLOCKERS.md).

## Sous-lots normalisés

### reconcile-cicd-git-publication — code non attribué : réconciliation Git

Tâches 1.1 à 1.3 ; dépendances : références et transport des fournisseurs ; contrôle : tests Git isolés de divergence, conflit, concurrence et rejeu. État : VALIDÉ sur fixtures le 2026-11-04 : 4 tests de fusion et de lease, 30 tests CI/CD, 61 tests de routage ; aucune qualification distante.

### reconcile-cicd-git-publication — code non attribué : validation et reprise

Tâches 2.1 à 2.4 ; dépendance : réconciliation Git ; contrôle : tests de publication et validation globale, puis contrôle des références réelles. État : EN COURS, 2026-11-04 : 1 182 tests globaux exécutés dont 2 ignorés, validation stricte du change réussie ; synchronisation documentaire, archivage et publication 1.2.2 restent à établir. L'attribution définitive du code et des sous-lots relève d'ACL.

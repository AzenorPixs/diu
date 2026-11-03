## 1. Version et CI/CD

- [x] 1.1 Valider et modifier PROJECT_VERSION sans évaluer la configuration ; tester création, préservation et refus.
- [x] 1.2 Accepter la version facultative, préserver la forme historique et mettre à jour les aides.
- [x] 1.3 Rendre les commits et reprises CI/CD idempotents sans déplacer les tags ; tester les collisions et les reprises.
- [x] 1.4 Appliquer la priorité stable aux sélecteurs DIU et tester les versions horodatées et stables.

## 2. Publications

- [x] 2.1 Rendre les publications Forgejo, GitHub et GitLab idempotentes sans écrasement ; tester les releases complètes, incomplètes et erreurs.

## 3. Nettoyage et livraison

- [x] 3.1 Inventorier et sauvegarder les références, releases et assets 2026 avant tout effacement.
- [x] 3.2 Supprimer les seuls éléments autorisés avec contrôle de concurrence et vérifier les références conservées.
- [x] 3.3 Actualiser la documentation et exécuter les contrôles locaux et globaux applicables.
- [x] 3.4 Vérifier les critères d'archivage et préparer la livraison locale 1.0.7.

## Preuves

- Suite globale DevOps : 1 103 tests exécutés, dont 2 ignorés, sans échec ; contrôle ciblé ultérieur de `test_projects.py` : 32 tests réussis.
- Validation stricte du change réussie ; validation globale OpenSpec non stricte : 120 éléments valides. Le mode strict global signale 47 spécifications historiques hors de ce change.
- Sauvegarde locale vérifiée : 216 tags, 194 releases Forgejo et 193 fichiers joints avec empreintes. Suppression vérifiée : 216 tags locaux, 208 Forgejo, 9 GitHub et 194 releases Forgejo ; aucune release GitHub 2026.
- Branches main et tags stables vérifiés après nettoyage. Aucune construction ou installation de production.

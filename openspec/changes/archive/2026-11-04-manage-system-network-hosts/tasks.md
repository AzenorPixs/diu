## Tâches

- [x] 1. Spécifier la génération, les commandes et le retrait des noms Docker.
- [x] 2. Déplacer la fonction, raccorder l'installation et les mises à jour et actualiser les aides.
- [x] 3. Mettre à jour les documents affectés et vérifier les comportements par tests isolés et contrôles applicables.
- [x] 4. Valider le change et préparer son archivage.

## Sous-lots normalisés

### manage-system-network-hosts — code non attribué — Gestion du fichier hosts

Tâches 1 à 4 : spécification, implémentation et validation cohérentes du même comportement. Prérequis : périmètre validé. Critères : scénarios OpenSpec, syntaxe, ShellCheck, tests isolés et validation globale. État : VALIDÉ le 2026-11-04. Preuves : validation OpenSpec stricte ; bash -n et ShellCheck ; 4 tests réseau, 6 Docker, 15 APT, 17 informations et 11 mise à jour globale réussis ; aide réelle vérifiée. Les tests utilisent des fichiers isolés, sans modification du hosts système. La normalisation définitive attend l'attribution du code par ACL.

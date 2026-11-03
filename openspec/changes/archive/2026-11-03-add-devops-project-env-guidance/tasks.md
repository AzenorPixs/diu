## Tâches

- [x] 1. Adapter le générateur, le document local et les tests ; vérifier le contenu et la version. Preuves du 2026-11-03 : test ciblé du texte exact et de sa position, `bash -n` et ShellCheck réussis ; suite de régression en cours.
- [x] 2. Mettre à jour la version DIU et le changelog ; vérifier la valeur sans exposer les autres variables. Preuve du 2026-11-03 : passage ciblé de 1.0.7 à 1.0.8 vérifié localement.
- [x] 3. Valider globalement et synchroniser la spécification. Preuves du 2026-11-03 : 1 105 tests exécutés, 2 ignorés ; validations strictes du change et de la capacité réussies.

## Sous-lots normalisés

### add-devops-project-env-guidance — code non attribué : génération et version

- Tâches : 1 à 3 ; objectif : intégrer la configuration locale et les versions validées.
- Périmètre : générateur, tests, document local, version DIU, spécification et changelog.
- Dépendances : validation OpenSpec avant le code ; contrôles ciblés avant validation globale.
- Critères : texte exact et unique avant la légende, version documentaire 0.8, version DIU 1.0.8 et validations réussies.
- État au 2026-11-03 : VALIDÉ ; génération, version et validation globale vérifiées. Archivage en attente ; attribution définitive du code à traiter ultérieurement avec ACL.

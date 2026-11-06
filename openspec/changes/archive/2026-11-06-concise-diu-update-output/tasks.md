## Tâches

- [x] 1.1 Définir le contrat et valider le change. Preuve : `openspec validate concise-diu-update-output --strict`, 2026-11-06.
- [x] 1.2 Adapter la sortie et les tests isolés. Preuves : 15 tests de mise à jour DIU et 3 tests HTTP réussis, `bash -n` et ShellCheck réussis, 2026-11-06.
- [x] 1.3 Mettre à jour la documentation et vérifier la cohérence. Preuve : sections mise à jour de `TECHNICAL.md`, `README.md` et `CHANGELOG.md` relues, 2026-11-06.
- [x] 1.4 Effectuer les validations globales et préparer l'archivage du change. Preuve : 1 216 tests exécutés, 2 ignorés, succès avec Python DevOps ; validation OpenSpec stricte et contrôles de syntaxe réussis, 2026-11-06.
- [x] 1.5 Relier la mise à jour réseau au parcours hosts et vérifier son résultat et son statut. Preuve : 17 tests réseau et 11 tests de mise à jour générale réussis, 2026-11-06.
- [x] 1.6 Corriger la découverte des aides réseau et vérifier les descriptions. Preuve : tests des aides inclus dans les 17 tests réseau réussis, 2026-11-06.

## Sous-lots normalisés

### concise-diu-update-output — code non attribué — Contrat et réalisation

- Tâches : 1.1 à 1.3 ; périmètre : spécification, module, tests et documentation.
- Dépendances : validation du périmètre reçue ; critères : contrat strict et tests ciblés réussis.
- État : VALIDÉ, 2026-11-06 ; preuves des tâches 1.1 à 1.3 ci-dessus.

### concise-diu-update-output — code non attribué — Validation finale

- Tâche : 1.4 ; dépendance : tâches 1.1 à 1.3 validées.
- Critères : contrôles globaux réussis et archivage éligible ; état : VALIDÉ, 2026-11-06, preuves de la tâche 1.4 ; archivage réalisé séparément.

### concise-diu-update-output — code non attribué — Réseau et aide

- Tâches : 1.5 et 1.6 ; périmètre : routage réseau, aide, tests et spécifications associées.
- Dépendances : extension validée le 2026-11-06 ; critères : résultats et statuts identiques, aides exactes et tests ciblés réussis.
- État : VALIDÉ, 2026-11-06 ; preuves des tâches 1.5 et 1.6 ci-dessus.

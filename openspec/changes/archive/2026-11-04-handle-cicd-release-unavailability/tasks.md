# Tâches

- [x] 1. Étendre la classification des pannes reconnues aux transports de release et préserver les erreurs non qualifiées.
- [x] 2. Isoler les statuts de release par fournisseur et poursuivre la CI/CD après une indisponibilité reconnue.
- [x] 3. Tester les trois fournisseurs, les transports et les publications partielles, les deux syntaxes et le rejeu, ainsi que les erreurs bloquantes.
- [x] 4. Mettre à jour les documents concernés et valider les tests, la syntaxe, ShellCheck et OpenSpec.
- [x] 5. Vérifier les critères et préparer la synchronisation et l’archivage.

## Sous-lots

### handle-cicd-release-unavailability-SL01 — Traitement des indisponibilités de release

Tâches : 1 à 4. Objectif : conserver la poursuite et un bilan sincère ; dépendances : aucune autre que les contrats existants. Validation : tests simulés des transports et de l’orchestration, contrôles syntaxiques et documentaires. État : validé le 2026-11-04.

### handle-cicd-release-unavailability-SL02 — Finalisation du change

Tâche : 5. Dépendance : SL01 validé. Validation : synchronisation, archivage et rapports requis vérifiés. État : éligibilité vérifiée le 2026-11-04 ; archivage à exécuter.

## Preuves du 2026-11-04

- `/home/devops/python/current/bin/python3 -m unittest discover -s tests -p 'test_*.py'` : 1 171 tests exécutés, 2 ignorés, succès.
- Tests ciblés CI/CD, rejeu, releases Debian et classification : réussis, transports simulés.
- `bash -n` sur les trois scripts modifiés ; ShellCheck avec exclusion SC1091 pour les imports dynamiques existants ; OpenSpec strict : réussis.
- Aucun transport réel ni publication de release exécuté dans ces tests. La première suite globale avec `/usr/bin/python3` a échoué sur 26 fixtures venv ; le Python DevOps documenté a permis la validation globale ci-dessus.

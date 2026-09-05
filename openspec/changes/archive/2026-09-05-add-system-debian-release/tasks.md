## 1. Spécification et implémentation

- [x] 1.1 Spécifier la variable demandée et ses cas limites.
- [x] 1.2 Ajouter la déclaration et son générateur.

## 2. Validation et clôture

- [x] 2.1 Vérifier bash -n et shellcheck.
- [x] 2.2 Tester releases, casse, environnement existant, erreurs et idempotence.
- [x] 2.3 Synchroniser la spécification et archiver cette évolution.

## Résultat des vérifications

- `bash -n` et `shellcheck` : succès sur la nouvelle déclaration.
- `python3 -B tests/test_system_debian_release.py` : 4 tests réussis,
  avec cas paramétrés trixie/Bookworm/BULLSEYE, valeurs préexistantes, erreurs,
  isolation, export, idempotence et détection réelle sur le système courant.
- `git diff --check` : succès.
- Synchronisation et archivage réalisés manuellement, puis contrôlés avec
  OpenSpec 1.12.0 installé dans `/home/devops/.local/npm/bin`, avec Node dans
  `/home/devops/node/current/bin` ajoutés au PATH.
- `openspec validate system-debian-release --type spec --strict --no-interactive` : succès.
- `openspec validate --archived --strict --no-interactive` : cette évolution
  est valide. Le contrôle global échoue uniquement sur l'ancienne archive
  `2026-08-12-git-https-token-auth` (8 tâches incomplètes sur 50).
- À la demande complémentaire du développeur, la racine `/workspace` a été
  remplacée par `/home/devops/datas/diu` dans AGENTS.md, TECHNICAL.md et
  l'évolution d'architecture modulaire concernée.

## 1. Spécification et implémentation

- [x] 1.1 Valider le delta OpenSpec avant toute écriture de code ou test.
- [x] 1.2 Implémenter le rendu matériel TPM et ses diagnostics sans mutation.
- [x] 1.3 Couvrir la sélection, les propriétés, les PCR et les indisponibilités.
- [x] 1.4 Actualiser TECHNICAL.md, README.md et CHANGELOG.md.

## 2. Validation et clôture

- [x] 2.1 Réussir syntaxe, ShellCheck, compilation et tests ciblés.
- [x] 2.2 Vérifier cohérence documentaire, encodage et périmètre des écritures.
- [x] 2.3 Vérifier l'éligibilité à la synchronisation et à l'archivage ciblés.

Après ces tâches, archiver uniquement ce change avec synchronisation de sa
capacité, puis produire et vérifier le rapport STATISTIQUES.md de l'archive.

## Preuves de validation avant archivage

- Delta strict valide avant implémentation.
- `bash -n modules/projects/template.sh` et ShellCheck : réussis.
- Compilation Python via `-m py_compile` avec cache temporaire local : réussie.
- Tests sous `/home/devops/python/current/bin/python3` : 13 tests TPM réussis,
  puis 103 tests (101 réussis, deux ignorés faute de Go/Node dans le PATH).
  Reprise de ces deux seuls tests avec les chemins explicites DevOps : deux
  réussites. Les 103 méthodes distinctes ont donc réussi, dont 14 nouvelles.
- Rendu TPM réel, sans écriture : chemin /dev/tpmrm0, version 2.0 et quatre
  diagnostics d'accès refusé ; aucun droit modifié.
- Huit avertissements canoniques de longueur observés avant synchronisation ;
  la comparaison finale et les commandes figurent dans STATISTIQUES.md.

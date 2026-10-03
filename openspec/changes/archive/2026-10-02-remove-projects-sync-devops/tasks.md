## 1. Spécification et implémentation

- [x] 1.1 Définir et valider le delta projects-sync couvrant le retrait de DEVOPS.md.
- [x] 1.2 Retirer DEVOPS.md des prérequis, de la préparation, de la copie et de chown.
- [x] 1.3 Vérifier la préservation, l'absence de création, le modèle sans document et sync all par les tests ciblés.

## 2. Validation et clôture

- [x] 2.1 Exécuter bash -n, ShellCheck et les tests ciblés applicables.
- [x] 2.2 Vérifier la cohérence des cadrages et les seuls fichiers attendus sans inspection Git.
- [x] 2.3 Valider le change strictement et le rendre éligible à l'archivage avec synchronisation de projects-sync.

## Preuves de validation

- `bash -n modules/projects/projects.sh` : exécutée et réussie.
- `shellcheck modules/projects/projects.sh` : exécutée et échouée avec le
  seul diagnostic SC2004 dans project_env_set_variables, hors des fonctions
  modifiées. Le contenu initial a été reconstitué en mémoire et son empreinte
  SHA-256 vérifiée ; ShellCheck y produit exactement le même avertissement
  (ligne 375 avant, ligne 374 après). Aucune correction hors périmètre.
- ShellCheck sur la section complète des fonctions de synchronisation,
  extraite en mémoire avant project_env_set_variables : exécutée et réussie,
  sans désactivation de diagnostic.
- `PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests -p test_projects.py -v` :
  exécutée et réussie, 25 tests. Le nouveau test couvre huit combinaisons
  (unitaire/groupée, document source présent/absent, destination
  présente/absente), chacune avec deux exécutions. Il vérifie contenu, mode,
  UID/GID, inode, date de modification et absence du document parmi les
  arguments des appels chown enregistrés. Les chown des fixtures de
  synchronisation sont simulés ; aucun propriétaire réel n'est modifié.
- `PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests -p test_projects_template_devops.py -v` :
  premier passage dans le sandbox échoué sur chown --reference (Invalid
  argument), avec deux tests Go ignorés. Relance hors sandbox autorisée par
  la plateforme avec `DIU_TEST_GO=/home/devops/go/current/bin/go` : 37 tests
  exécutés et réussis, aucun ignoré. Les fichiers sont des fixtures isolées.
- `openspec validate remove-projects-sync-devops --type change --strict`
  via /home/devops/.local/npm/bin/openspec : exécutée et réussie avant code
  puis après implémentation.
- Revue sans Git : empreinte initiale du code reconstitué vérifiée ; idem
  pour les tests après retrait en mémoire des seuls ajouts prévus.
  AGENTS.md, PROJECT.md, TECHNICAL.md, BUILD.md, DEVOPS.md, README.md et les
  tâches de add-projects-sync-broker conservent leurs empreintes initiales.
  Tous les fichiers modifiés ou créés sont UTF-8 avec fins de ligne LF.
  Les cadrages n'imposent pas la copie du document ; projects-sync-all
  conserve sa délégation au comportement unitaire.
- Aucun projet réel synchronisé, aucune inspection ou mutation Git,
  aucun changement de génération dédiée. Le diagnostic de style préexistant
  reste signalé ; les validations du comportement modifié sont réussies.
- Archivage via `openspec archive remove-projects-sync-devops --json --yes`
  après validation explicite du périmètre par le développeur : exécuté et
  réussi, archive `2026-10-02-remove-projects-sync-devops`, deux exigences
  modifiées dans projects-sync. La première invocation --json a demandé
  la confirmation de synchronisation ; la relance applique l'autorisation
  d'archivage déjà reçue, sans contourner de permission de la plateforme.
- `openspec validate projects-sync --type spec --strict` après archivage :
  exécutée et réussie. Deux conseils non bloquants signalent la longueur
  des exigences ; aucun échec de validation.

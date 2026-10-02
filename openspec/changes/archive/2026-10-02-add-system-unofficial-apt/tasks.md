# Tasks

- [x] Ajouter le moteur générique au module `system`.
- [x] Ajouter les variables statiques détectées et persistées au module `diu`.
- [x] Ajouter `diu system install/remove apt <repository>` et les mises à jour imbriquées.
- [x] Retirer les déclarations de dépôts tiers du script monolithique.
- [x] Valider puis corriger l'adaptation de la branche Wazuh `4` au moteur booléen et tester les valeurs retenues.
- [x] Ajouter les tests d'écriture et de suppression des deux formats APT.
- [x] Valider la structure du change avec OpenSpec en mode strict.
- [x] Vérifier la couverture des exigences et la cohérence préalable à la synchronisation et à l'archivage.
- [x] Ajouter `SYSTEM_APT_CGPT` et `rid system install/remove apt cgpt`.
- [x] Corriger les fichiers deb822 NVIDIA pour omettre `Components`.
- [x] Ajouter la spécification OpenSpec du comportement NVIDIA.
- [x] Réutiliser les trousseaux gérés présents, lisibles et non vides sans téléchargement.
- [x] Tester la réutilisation, les clés absentes ou vides et les échecs d'installation dans les deux formats APT.
- [x] Valider le correctif et mettre à jour son cadrage technique.

- [x] Préserver les activations historiques et la priorité des variables persistées.
- [x] Préserver MongoDB 4.4, la suite Bullseye et une branche valide pour l'installation générique.
- [x] Réutiliser le trousseau CrowdSec historique sans téléchargement.
- [x] Tester l'installation, la suppression et la persistance réelle de chaque dépôt dans des fixtures isolées.

## Validation préalable à l'archivage — 2026-10-02

La finalisation de ce seul change, incluant les corrections, les tests,
la synchronisation et l'archivage, a été validée par le développeur.
Les travaux d'implémentation sont terminés dans les sources de développement.
L'archivage OpenSpec réalise la synchronisation des exigences ajoutées dans
`openspec/specs/system-debian-apt/spec.md` après cette validation préalable.

### Preuves et couverture

| Exigence | Preuves observées |
| --- | --- |
| Moteur commun et formats APT | Tests des deux formats, des fichiers alternatifs, des dépôts désactivés et des fichiers non gérés dans `test_system_apt.py` et `test_system_apt_unofficial.py` |
| Réutilisation des clés | Clés présentes, absentes, vides ou illisibles, échecs de téléchargement/conversion, réutilisation après installation et copie du trousseau CrowdSec historique |
| Variables et compatibilité | Détection des onze dépôts, export et persistance sans doublon, priorité des valeurs initialisées, activations historiques, branches MongoDB 4 à 8 et valeurs Wazuh 0/1/4 |
| Configuration unique du monolithe | Sept blocs redondants retirés ; exécution isolée des branches Bookworm et Bullseye ; FusionDirectory testé activé et désactivé |
| NVIDIA | Absence de `Components` vérifiée pour les deux dépôts NVIDIA en deb822 |
| OpenAI | Installation et suppression via le dispatch, clé locale synthétique, absence de téléchargement et de source Codex supplémentaire |

### Validations exécutées et réussies

- `python3 -B -m unittest discover -s tests -p 'test_system_apt*.py'` : **31 tests**.
- `python3 -B tests/test_root_shellcheck.py` : **9 tests**.
- `python3 -B tests/test_config_cleanup.py` : **6 tests**.
- `python3 -B tests/test_rid_help.py` : **47 tests**.
- `bash -n` exécuté séparément sur `root-install-debian.sh`,
  `modules/system/apt.sh` et
  `modules/diu/variables/system/system_apt_unofficial.sh`.
- `shellcheck --format=gcc root-install-debian.sh modules/system/apt.sh
  modules/diu/variables/system/system_apt_unofficial.sh`.
- `/home/devops/.local/npm/bin/openspec validate add-system-unofficial-apt
  --type change --strict --no-interactive`.

### Périmètre et limites

Les tests utilisent des fichiers temporaires dans le projet et des clés
synthétiques ; aucun dépôt APT système ni réseau réel n'est modifié. Les
transactions APT et l'installation en production ne sont pas exécutées.
La validité cryptographique des clés et la disponibilité des serveurs distants
ne sont pas évaluées par ces tests ; la vérification TLS reste active.

Le bloc APT correspond exactement aux sept retraits prévus. Une modification
concurrente indépendante dans le dispatch `projects template all` a été
préservée. Après normalisation de ce seul ajout pour comparaison, l'empreinte
du monolithe hors bloc APT correspond à l'empreinte initiale ; elle n'a pas été
réécrite pour annuler ce travail concurrent.

Le cadrage technique et les exigences OpenSpec décrivent le comportement
final. L'architecture, le packaging, les dépendances et les autres changes
OpenSpec restent hors du périmètre de cette finalisation.

## Clôture observée — 2026-10-02

- `openspec archive add-system-unofficial-apt --json --yes` : exécutée et
  réussie, avec validation et mise à jour des spécifications actives.
- Archive créée : `2026-10-02-add-system-unofficial-apt` ; six exigences
  ajoutées à `system-debian-apt`, sans modification ou suppression des
  exigences Debian préexistantes.
- Validation stricte de `system-debian-apt` après synchronisation : exécutée
  et réussie. Le validateur émet deux informations non bloquantes sur la
  longueur des exigences de compatibilité et de réutilisation des clés.
- Contrôle après archivage : change actif absent, toutes les tâches archivées
  cochées, six exigences synchronisées à contenu identique, UTF-8/LF vérifiés.

La première invocation d'archivage sans `--yes` demandait une confirmation et
n'a pas archivé le change. L'option documentée a confirmé l'opération couverte
par la validation de finalisation du développeur ; aucune validation ni mise
à jour des spécifications n'a été désactivée.

## 1. Spécification

- [x] 1.1 Valider strictement le change avant implémentation.

## 2. Implémentation

- [x] 2.1 Ajouter le traitement groupé et le routage.
- [x] 2.2 Actualiser aides, documentation et tests nécessaires.

## 3. Validation

- [x] 3.1 Exécuter Bash -n, ShellCheck et les suites ciblées sous devops.
- [x] 3.2 Vérifier cohérence, périmètre et validation stricte finale.

## Preuves de validation

Périmètre validé explicitement par le développeur : ajout de la commande
groupée, mêmes critères project.env que DevOps all, aides, documentation,
tests et cycle OpenSpec ciblé, archivage inclus. La précision ultérieure sur
all confirme ces critères sans modifier le périmètre.

Validations exécutées et réussies :

- `bash -n modules/projects/template.sh root-install-debian.sh lib/rid-help.sh`.
- `shellcheck modules/projects/template.sh root-install-debian.sh lib/rid-help.sh`.
- Sous devops, `python3 -B -m unittest discover -s tests -p test_projects_template_openspec.py` : 14 tests.
- Sous devops, `python3 -B -m unittest discover -s tests -p test_projects_template_devops.py` : 37 tests.
- Sous devops, `python3 -B -m unittest discover -s tests -p test_rid_help.py` : 51 tests.
- Sous devops, `python3 -B -m unittest discover -s tests -p test_projects.py` : 25 tests.
- Sous devops, `/home/devops/.local/npm/bin/openspec validate add-projects-template-openspec-all --type change --strict --no-interactive` : avant implémentation puis sur le change final.
- Aides réelles : `bash root-install-debian.sh projects template openspec all help` et `bash root-install-debian.sh projects template openspec help`.
- Lecture finale ciblée, syntaxe Python, UTF-8/LF et absence de répertoires temporaires des tests.

La première exécution DevOps a échoué dans le garde-fou d'isolation, avant
traitement : deux affectations de domicile étaient attendues, trois existent
avec la nouvelle fonction. L'attente a été corrigée à trois, en conservant
le contrôle strict et le remplacement de tous ces chemins. La réexécution
des 37 tests a réussi. Aucun test n'a été désactivé.

Les tests utilisent des configurations factices et des doubles OpenSpec/su ;
aucun vrai projet n'a été initialisé ou actualisé. Couverture : cinq variables
non vides et identifiant concordant, valeurs 0/No, dossiers cachés et all,
configuration non exécutée, liens et configurations invalides ignorés,
init/update OPENCODE 0/1, répétition, échec suivi de réussite, bilan et codes
de retour, prérequis invalides et routage CLI.

## Cohérence finale avant archivage

| Élément | Résultat dans le périmètre ciblé |
| --- | --- |
| Projet réel | Fonction groupée, routage et aides relus ; fonction individuelle, sélection DevOps et ordre create conservés. |
| AGENTS.md | Écritures limitées au périmètre approuvé ; tests isolés ; aucun accès Git ni écriture OpenCode. |
| PROJECT.md | Architecture modulaire et évolution spécifiée préservées. |
| TECHNICAL.md | Commande groupée, sélection, bilan et réservation CLI de all documentés ; absence de lecture project.env limitée explicitement à la fonction individuelle. |
| BUILD.md | Aucun changement de construction, packaging ou infrastructure. |
| DEVOPS.md | Environnement réel et chemin explicite OpenSpec utilisés sous devops. |
| README.md | Présentation générale des variables de projets cohérente ; aucune modification nécessaire. |
| OpenSpec | Change ciblé validé strictement, exigences RFC 2119 et scénarios alignés avec code et tests. |

Fichiers applicatifs modifiés : modules/projects/template.sh,
root-install-debian.sh, lib/rid-help.sh, TECHNICAL.md,
tests/test_projects_template_openspec.py, tests/test_projects_template_devops.py
et tests/test_rid_help.py. Les autres écritures concernent uniquement le change
ciblé et les deux capacités synchronisées. Aucun blocage connu avant archivage.

## Archivage et clôture

Exécuté et réussi sous devops :
`/home/devops/.local/npm/bin/openspec archive add-projects-template-openspec-all --json --yes`.
Archive : `2026-10-02-add-projects-template-openspec-all` ; synchronisation
effective de deux exigences ajoutées et deux modifiées, sans suppression ni
renommage. Le Purpose de projects-template-openspec mentionne aussi les
projets configurés, en cohérence avec la capacité étendue.

Exécutées et réussies sous devops :

- `/home/devops/.local/npm/bin/openspec validate projects-template-openspec --type spec --strict --no-interactive`.
- `/home/devops/.local/npm/bin/openspec validate rid-help --type spec --strict --no-interactive`.

Les messages INFO relatifs à la longueur de certaines exigences sont
informatifs ; les deux validations strictes ont rendu un code zéro.
Le change ciblé est archivé et n'est plus actif. Aucun travail du périmètre
validé ne reste en attente ; aucune initialisation de projet réel n'a été
exécutée pour les tests.

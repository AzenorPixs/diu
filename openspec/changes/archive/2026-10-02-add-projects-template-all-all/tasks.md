## 1. Spécification

- [x] 1.1 Valider le change strictement avant implémentation.

## 2. Implémentation

- [x] 2.1 Ajouter la boucle par projet et le routage all all.
- [x] 2.2 Actualiser documentation, aides et tests isolés.

## 3. Validation

- [x] 3.1 Vérifier syntaxe, ShellCheck et tests ciblés sous devops.
- [x] 3.2 Vérifier cohérence, périmètre et validation OpenSpec finale.

## Mandat et résultats

Le développeur a validé le périmètre proposé, avec OpenSpec avant DevOps pour
chaque projet et absence d'appel DevOps si OpenSpec échoue. Sa correction
« oubliant PAS » et sa confirmation suivante incluent explicitement les aides.
Le seul change traité est add-projects-template-all-all ; les autres changes
actifs ne sont pas repris ni archivés.

Validations exécutées et réussies :

- `bash -n modules/projects/template.sh root-install-debian.sh lib/rid-help.sh`.
- `shellcheck modules/projects/template.sh root-install-debian.sh lib/rid-help.sh`.
- Sous devops, `python3 -B -m unittest discover -s tests -p test_projects_template_all.py` : 8 tests.
- Sous devops, `python3 -B -m unittest discover -s tests -p test_projects_template_openspec.py` : 14 tests.
- Sous devops, `python3 -B -m unittest discover -s tests -p test_projects_template_devops.py` : 37 tests.
- Sous devops, `python3 -B -m unittest discover -s tests -p test_rid_help.py` : 53 tests.
- Sous devops, `python3 -B -m unittest discover -s tests -p test_projects.py` : 25 tests.
- Sous devops, `/home/devops/.local/npm/bin/openspec validate add-projects-template-all-all --type change --strict --no-interactive` : avant implémentation puis sur le change final.
- `bash root-install-debian.sh projects template all all help` et `bash root-install-debian.sh projects template all '?'` : ordre, critères et gestion des échecs affichés sans traitement.
- Contrôle ciblé de syntaxe Python, UTF-8/LF et nettoyage des fixtures : réussi.

Total : 137 tests. Tous utilisent des données temporaires, des doubles
OpenSpec/su ou des binaires DevOps simulés. Les nouveaux tests couvrent
notamment ordre par projet, sélection commune, variables 0/No, identifiant
concordant, dossiers cachés/all, configuration non exécutée ni héritée,
liens et fichiers illisibles ignorés, compte et racine invalides, init/update
avec OPENCODE 0/1 et compte su vérifié, échec OpenSpec sans DevOps, échec DevOps
avec poursuite, bilan compté par projet et vrais documents DevOps sur fixtures.
Aucun projet réel n'a été initialisé ou actualisé pour ces tests.

L'attente stricte d'isolation du test DevOps a été actualisée de trois à
quatre affectations de domicile, correspondant à la nouvelle fonction. Le
contrôle et le remplacement de tous ces chemins restent actifs. L'ancien
test d'aide exclut désormais le contexte intermédiaire all des contextes
invalides, car ce contexte est spécifié et testé comme valide ; les anciens
ordres all devops et all openspec restent rejetés et testés.

## Matrice de cohérence avant archivage

| Élément | Résultat dans le périmètre concerné |
| --- | --- |
| Projet réel | Boucle par projet, fonctions individuelles réutilisées, sélection DevOps inchangée, comptage par projet et CLI exacte all all. |
| AGENTS.md | Périmètre explicite, spécification avant code, tests isolés, aucune inspection Git ni écriture OpenCode. |
| PROJECT.md | Module projects et architecture modulaire conservés. |
| TECHNICAL.md | Deux all, sélection, ordre, erreurs, bilan et aides documentés. |
| BUILD.md | Construction, packaging et infrastructure inchangés. |
| DEVOPS.md | Commandes OpenSpec via le chemin explicite de l'environnement réel sous devops. |
| README.md | Présentation générale des projets et publications cohérente ; aucune modification nécessaire. |
| OpenSpec | Nouvelle capacité projects-template-all et delta d'aide rid-help, exigences RFC 2119, change final valide. |

Fichiers applicatifs modifiés : modules/projects/template.sh,
root-install-debian.sh, lib/rid-help.sh, TECHNICAL.md,
tests/test_projects_template_devops.py et tests/test_rid_help.py.
Fichier créé : tests/test_projects_template_all.py.
Les autres écritures concernent uniquement les artefacts du change ciblé et
les capacités synchronisées lors de l'archivage. Les commandes individuelles,
les deux commandes groupées existantes et create sont préservés et testés.
Aucune dépendance ni variable nouvelle, aucune migration ou suppression.
Aucun échec de validation ni blocage restant avant archivage.

## Archivage et clôture

Exécuté et réussi sous devops :
`/home/devops/.local/npm/bin/openspec archive add-projects-template-all-all --json --yes`.
Archive : `2026-10-02-add-projects-template-all-all`. Les capacités ont été
synchronisées : cinq exigences ajoutées, aucune modifiée, supprimée ou renommée.
Le Purpose de la nouvelle capacité a été finalisé pour remplacer le texte
provisoire généré par l'archivage.

Exécutées et réussies sous devops :

- `/home/devops/.local/npm/bin/openspec validate projects-template-all --type spec --strict --no-interactive`.
- `/home/devops/.local/npm/bin/openspec validate rid-help --type spec --strict --no-interactive`.

Les messages INFO de longueur de certaines exigences sont informatifs ; les
deux validations strictes rendent un code zéro. La nouvelle capacité existe,
le change ciblé n'est plus actif et toutes ses tâches sont terminées.
Aucun blocage ni travail du périmètre validé restant.

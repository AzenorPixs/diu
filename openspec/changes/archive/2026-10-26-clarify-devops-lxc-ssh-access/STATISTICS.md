# STATISTIQUES — Accès SSH LXC et conservation des dépendances de test

## 1. Identification et périmètre

- Projet : Debian Installeur Unifié ; identifiant `diu`.
- Racine : `/home/devops/datas/diu` ; date utilisateur : 26 octobre 2026, Europe/Paris.
- Session SCM directe, sans pilotage OpenCode/CAB ni compétence de télémétrie SCMP.
- Change : `clarify-devops-lxc-ssh-access`.
- Archive : `2026-10-26-clarify-devops-lxc-ssh-access`.
- Autorisation : périmètre proposé puis explicitement validé par le développeur,
  avec ajout de la cinquième puce de conservation des binaires et bibliothèques.
- Sources de preuve : commandes de cette session, [proposition](proposal.md),
  [conception](design.md), [tâches](tasks.md), [delta](specs/projects-template-devops/spec.md)
  et [spécification synchronisée](../../../specs/projects-template-devops/spec.md).

Le titre devient « Conteneur LXC, pour tests nécessitant des droits root accessible en SSH ».
La première puce devient « Variables d'accès disponible dans project.env pour l'accès SSH ».
La cinquième et dernière puce est exactement :
« Binaires et bibliothèques installés pour les tests ne sont pas à désinstaller après tests. »
L’autorisation commune reste identique en quatrième position pour LXC.

## 2. Durées et mesures disponibles

| Mesure | Valeur et justification |
| --- | --- |
| Fenêtre mesurée de réalisation avant rapport | 397 s, de 15:47:21 à 15:53:58 UTC le 26 octobre 2026 ; hors exploration antérieure, attente de validation, rapport et commit |
| Premier passage ciblé | 6,876 s ; échec corrigé avant validation |
| Passage ciblé après correction | 8,729 s ; cinq méthodes réussies |
| Suite complète du générateur | 85,631 s selon unittest |
| Durée globale de la conversation | N/A : absence de mesure continue couvrant toute la conversation |
| Tokens, coût, CPU et mémoire | N/A : aucune instrumentation dédiée disponible |
| Messages et outils exhaustifs | N/A : absence d’export de télémétrie de cette session |
| Approbations CAB | N/A : session directe, sans protocole CAB |

Les sous-tests ne sont pas comptés comme méthodes supplémentaires.
Les résultats des archives précédentes ne sont pas utilisés comme preuves actuelles.

## 3. Fichiers et comportement livré

| Catégorie | Nombre | Chemins |
| --- | ---: | --- |
| Code existant modifié | 1 | modules/projects/template.sh |
| Tests existants modifiés | 1 | tests/test_projects_template_devops.py |
| Documentation existante modifiée | 3 | TECHNICAL.md ; README.md ; CHANGELOG.md |
| Spécification canonique modifiée | 1 | openspec/specs/projects-template-devops/spec.md |
| Fichiers de la nouvelle archive | 6 | .openspec.yaml ; proposal.md ; design.md ; tasks.md ; specs/projects-template-devops/spec.md ; STATISTIQUES.md |
| **Total final** | **12** | **1 + 1 + 3 + 1 + 6** |

Six fichiers préexistants modifiés et six nouveaux fichiers à leur emplacement final.
Les cinq artefacts du change sont déplacés par OpenSpec ; le rapport est créé ensuite.
Le générateur ajoute la dernière puce après l’autorisation commune et propage tout
échec d’écriture. Le helper commun accepte un séparateur final interne optionnel :
trois sauts de ligne par défaut pour Docker, un seul avant la cinquième puce LXC.
Le texte de l’autorisation commune n’est pas modifié.

Les deux conteneurs comportent cinq puces. LXC reste conditionné à la valeur
exacte `ENV_DEVOPS_TESTS_LXC=1`, indépendamment de Docker ; son ordre et le format
documentaire `0.7` sont conservés. Les trois parcours partagent le même rendu.
Aucune installation, désinstallation ni connexion SSH n’est déclenchée par ce rendu.
Les documents déjà générés adoptent ces textes à leur prochaine génération normale.

## 4. Tests et vérifications

| Passage | Méthodes exécutées | Réussies | Échouées | Erreurs | Ignorées |
| --- | ---: | ---: | ---: | ---: | ---: |
| Ciblé initial | 5 | 1 | 4 | 0 | 0 |
| Ciblé corrigé | 5 | 5 | 0 | 0 | 0 |
| Suite complète finale | 121 | 119 | 0 | 0 | 2 |

Le premier passage a produit treize échecs de sous-tests dans quatre méthodes :
le helper d’autorisation émettait la séparation entre rubriques avant la cinquième
puce. Le séparateur a été adapté ; les mêmes attentes exactes passent ensuite.
Aucun test n’a été affaibli pour accepter cette mise en page incorrecte.

Les cinq méthodes ciblées sont les tests des indicateurs indépendants, des valeurs
désactivantes, de la création, du traitement groupé et de la conservation du
document après échec de rendu/remplacement. L’assertion commune contrôle le titre,
la première puce, le texte intégral des cinq puces et leur ordre. Un stub SSH
interdit et un échec simulé d’écriture de la cinquième puce complètent les cas existants.

Commande de la suite finale réellement exécutée :

```bash
env PYTHONDONTWRITEBYTECODE=1 /home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_template_devops.py
```

Les deux tests Go sont ignorés : `go` est absent du PATH de test et `DIU_TEST_GO`
n’est pas défini. L’UID effectif observé est 1000 ; les tests de permissions
ordinaires ne sont pas ignorés pour une exécution root.

| Contrôle | Résultat réel |
| --- | --- |
| bash -n modules/projects/template.sh | Exécuté et réussi après correction finale |
| shellcheck modules/projects/template.sh | Exécuté et réussi, aucun diagnostic |
| Compilation Python | Exécutée et réussie avec le Python DevOps et py_compile.compile ; cfile temporaire sous le projet, nettoyé |
| Change OpenSpec strict avant code | Exécuté et réussi |
| Change OpenSpec strict avant archivage | Exécuté et réussi |
| Canon projects-template-devops standard après synchronisation | Exécuté et réussi, huit avertissements de longueur préexistants |
| Global OpenSpec strict initial | Exécuté et échoué : 68 éléments, 46 valides, 22 en échec |
| Global OpenSpec strict avec le change actif | Exécuté et échoué : 69 éléments, 47 valides, 22 en échec ; change ciblé valide sans diagnostic |
| Global OpenSpec strict après archivage | Exécuté et échoué : 68 éléments, 46 valides, 22 en échec ; éléments et diagnostics identiques à l’état initial |
| Global OpenSpec standard final | Exécuté et échoué : 68 éléments, 66 valides, deux changes Forgejo préexistants en échec |
| Concordance delta/canon | Exécutée et réussie : cinq exigences et onze scénarios, hors lignes vides normalisées par OpenSpec |
| Archivage | Exécuté et réussi : cinq exigences modifiées, zéro ajout, suppression ou renommage |
| Empreintes des artefacts déplacés | Exécutées et réussies : les cinq SHA-256 sont conservés |
| Références inchangées | AGENTS.md, PROJECT.md, BUILD.md et DEVOPS.md conservent leurs SHA-256 initiaux |
| UTF-8/LF sans BOM | Réussi sur les onze fichiers avant rapport ; vérification finale étendue au rapport |
| Temporaires | Aucun résidu après la suite sous .diu-test-devops-* ou .diu-scm-pycompile-* |
| Suite complète du dépôt | Non exécutée : suite du générateur directement concernée retenue |
| Tests réels Docker/LXC et accès SSH | Non exécutés : modification documentaire du générateur uniquement |

Les validations OpenSpec utilisent le binaire explicite
`/home/devops/.local/npm/bin/openspec`, avec `--no-interactive`, `--strict` pour
le change et les comparaisons globales, `--json` pour les relevés globaux.
La validation standard ciblée utilise `--type spec`.

## 5. Cohérence documentaire et archivage

| Élément SCM | État et preuve |
| --- | --- |
| Projet réel | Nouveau rendu vérifié dans les trois parcours, 119 méthodes finales réussies |
| AGENTS.md | Inchangé, empreinte conservée ; règles de périmètre et statistiques appliquées |
| PROJECT.md | Inchangé, empreinte conservée ; architecture du module projects préservée |
| TECHNICAL.md | Traçabilité du document DevOps mise à jour : SSH, cinq puces, ordre et échecs d’écriture |
| BUILD.md | Inchangé, empreinte conservée ; construction et packaging non concernés |
| DEVOPS.md | Inchangé, empreinte conservée ; relevé daté utilisé pour les chemins d’outils, nouvelle rédaction à la prochaine génération |
| README.md | Description des rubriques mise à jour : accès SSH et conservation finale des dépendances |
| CHANGELOG.md | Entrée Unreleased dédiée, sans version de publication inventée |
| openspec/specs/ | projects-template-devops synchronisé : cinq exigences modifiées, onze scénarios concernés |

Commande d’archivage réussie :

```bash
env OPENSPEC_TELEMETRY=0 /home/devops/.local/npm/bin/openspec archive clarify-devops-lxc-ssh-access --json --yes
```

La première invocation JSON sans `--yes` a refusé l’archivage sans effet, avec
`archive_confirmation_required`. L’invocation complète exécute l’archivage
déjà autorisé par le développeur ; un seul archivage a réussi.
Le change actif est absent, l’archive est présente, les quatre tâches sont
cochées sur preuves et les cinq artefacts déplacés gardent leurs empreintes.
Le fichier BLOCKERS.md et ses liens sont absents : aucun nettoyage n’est nécessaire.

| Sources qualifiées | SHA-256 |
| --- | --- |
| modules/projects/template.sh | 3ce749956c57b0571b73f7470d3e07109f9856e25692cc13d37fa8f09e21ce36 |
| tests/test_projects_template_devops.py | 82f2752e29ee5ae37824fac82bbacbae6cfb5c424943187977b2a6425d7be63d |

Totaux : 12 = 1 + 1 + 3 + 1 + 6 ; 121 = 119 + 0 + 0 + 2 ; quatre tâches sur quatre ;
cinq exigences modifiées, onze scénarios, un change archivé et six fichiers dans l’archive.
Le contrôle du rapport vérifie six sections, UTF-8/LF, liens et totaux avant l’étape Git.

## 6. Limites et clôture

Le générateur, ses tests, la documentation et la spécification sont alignés sur
la demande validée. Le change est archivé et ce rapport est produit.
Le contrôle global strict reste en échec sur les mêmes 22 éléments préexistants.
En mode standard, seuls modify-projects-forgejo-push-force-with-lease et
restore-forgejo-push-to-create échouent : leurs deltas omettent deux scénarios
existants du canon Forgejo. Ces éléments hors périmètre restent inchangés.

Le relevé DEVOPS.md réel n’a pas été régénéré ; aucun conteneur ni paquet
installé n’a été modifié. Aucune information d’accès SSH réelle n’a été lue.
Le commit local conditionnel SCM est l’étape suivant la vérification de ce
rapport ; sa branche, son SHA et son résultat réel sont restitués dans le bilan
final. Aucun push, changement de branche, tag ou déploiement n’est autorisé ici.

Préparation Git observée : dépôt existant, branche `main` conforme à
LOCAL_DEFAULT_BRANCH, identité auteur/committer extraite localement et validée
sans lecture des autres variables. L’index initial est vide et les différences
des six fichiers existants du change correspondent au périmètre validé.
DEVOPS.md présente une modification antérieure au change : son empreinte
initiale est conservée et ce fichier est exclu du commit. Les douze chemins
du change sont indexés explicitement pour le seul commit local autorisé.

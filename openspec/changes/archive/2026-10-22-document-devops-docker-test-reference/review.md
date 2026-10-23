# Revue SCM — références Docker de DEVOPS.md

## Périmètre et décision

Le développeur a validé le périmètre autonome proposé le 22 octobre 2026 :
change ciblé, rendu Docker et attentes existantes, documentation, validation,
synchronisation, archivage et rapport de statistiques. Session directe SCM,
sans pilotage OpenCode/CAB ni compétence de télémétrie SCMP.

## Checkpoint

- État : TERMINÉ dans le périmètre validé ; change archivé, synchronisation et
  rapport de statistiques vérifiés, limites préexistantes consignées.
- Tâche courante : aucune tâche d'implémentation restante.
- Prérequis prouvés : rendu, tests, documentation et change strictement valide.
- Prochaine action : aucune action restante pour cette session SCM.

## Témoins inchangés

Empreintes SHA-256 relevées avant toute écriture de cette session :

| Fichier | SHA-256 |
| --- | --- |
| AGENTS.md | 6e2b49d68e090609d3a8d23c74ba650709f1c8ccca834563bdd6aa93da90d2d0 |
| PROJECT.md | 530bcf8f9db0f7b46cbd9dd7969c37832f25e5857983854d65dd37cc73181f7a |
| BUILD.md | d68bd59259e1f50df300cee9ed8ff2b7e5653e5a4b13a60a02feb17a82b17658 |
| DEVOPS.md | af7897c2dab09fc842e4d82a49a711843f373fe065735543064a5d8a6a621ec5 |
| openspec/config.yaml | 2a791b0ccc50e2c2ebbb3ba28692a4ad0e4b6ab94ed2151375ac404d7056e89a |

## Résultats des tâches

### Tâche 1.1 — validée

La validation stricte initiale du change a d'abord refusé une exigence ajoutée
trop longue. Sa rédaction a été raccourcie et ses détails reportés dans les
scénarios ; aucun contrôle n'a été désactivé. La deuxième validation stricte
a réussi avant la première écriture de code ou de test.

Commandes et résultats :

| Contrôle | Commande ou preuve | Résultat |
| --- | --- | --- |
| OpenSpec avant implémentation | `env PATH=/home/devops/node/current/bin:/usr/bin:/bin /home/devops/.local/npm/bin/openspec validate document-devops-docker-test-reference --strict` | Réussite après correction rédactionnelle |
| Syntaxe Bash | `bash -n modules/projects/template.sh` | Réussite |
| Analyse Bash | `shellcheck modules/projects/template.sh` | Réussite, zéro diagnostic |
| Syntaxe Python | `py_compile.compile(..., doraise=True)` sous Python système puis `/home/devops/python/current/bin/python3`, cache temporaire dans le projet et supprimé | Deux réussites |
| Première suite | `env DIU_TEST_GO=/home/devops/go/current/bin/go python3 -B -m unittest discover -s tests -p test_projects_template_devops.py` | 89 méthodes en 51,142 s : 80 réussies et 9 erreurs de fixtures venv |
| Suite avec Python du projet | `env DIU_TEST_GO=/home/devops/go/current/bin/go /home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_template_devops.py` | 89 méthodes en 61,508 s, toutes réussies, aucune ignorée |
| Encodage et périmètre | Contrôle Python ciblé de SHA-256, décodage UTF-8, absence de CR et BOM, LF final | 9 témoins inchangés et 7 fichiers contrôlés conformes |

Les neuf erreurs initiales `StopIteration` viennent de `project_venv`, qui
ne trouve aucun des répertoires `site.getsitepackages` attendus avec le
Python Debian système 3.13.5. Une reproduction locale isolée a confirmé ce
décalage ; le Python DevOps 3.14.9 déclaré dans DEVOPS.md crée bien le
répertoire attendu. Aucun code de fixture venv n'a été modifié : seule la
commande utilise l'interpréteur du projet pour la validation finale.

Les attentes existantes prouvent le titre exact, les quatre puces ordonnées,
l'unicité des références et les diagnostics lorsque le binaire Docker est
absent ou échoue. Le faux binaire Docker n'accepte que `--version` ; aucun
appel d'image n'est ajouté. La revue du générateur montre un seul branchement
sur le titre interne `Docker`, l'autre branche conservant son rendu initial.
La suite couvre aussi les autres rubriques, les parcours individuels, groupés
et de création, la réexécution et la préservation des droits.

### Tâche 2.1 — validée

Les trois ajouts documentaires ont été relus avec `rg -n -A 11 -B 2` sur les
références Docker. Un contrôle Python ciblé vérifie les références dans ces
trois documents, UTF-8/LF sans BOM sur les dix fichiers concernés à ce stade,
et six empreintes témoins inchangées, dont la spécification canonique.
Le générateur retrouve exactement son empreinte initiale lorsque sa seule
fonction de rendu est remplacée en mémoire par son texte initial : le reste
du script est inchangé.

La validation stricte du change réussit après les mises à jour documentaires.
La validation de la spécification canonique, avant toute synchronisation et
à SHA-256 initial identique, constate huit avertissements de longueur sur
`requirements[0,2,4,6,7,8,9,10]`. La commande
`/home/devops/.local/npm/bin/openspec validate projects-template-devops --strict`
échoue pour ces seuls avertissements ; la même commande sans `--strict`
réussit et les affiche. Le PATH explicite utilisé dans les deux cas est
`/home/devops/node/current/bin:/usr/bin:/bin`. Ces défauts rédactionnels
préexistent et restent hors périmètre ; le delta ciblé ne les étend pas.
Aucun contrôle n'est désactivé pour l'archivage normal.

## Matrice de cohérence documentaire

| Élément | État et justification | Preuve |
| --- | --- | --- |
| Projet réel | Rendu implémenté et vérifié en fixtures isolées ; références constantes, sans action Docker supplémentaire | Fonction de rendu ; 89 tests finaux réussis |
| AGENTS.md | Inchangé : règles de travail et séquentialité respectées | Empreinte témoin |
| PROJECT.md | Inchangé : architecture et objectifs non modifiés | Empreinte témoin ; section Module projects |
| TECHNICAL.md | Mis à jour : ordre des quatre puces, indisponibilité, portée documentaire et tag non figé | Section Traçabilité du document DevOps, paragraphe Docker |
| BUILD.md | Inchangé : aucun changement de packaging ou déploiement | Empreinte témoin ; Objet et périmètre |
| DEVOPS.md | Inchangé : relevé historique, aucune régénération réelle demandée ; rendu futur décrit dans les cadrages | Empreinte témoin ; version documentaire 0.6 et relevé du 22 octobre 2026 |
| README.md | Mis à jour : résumé du nouveau rendu et de sa portée | Passage Inventaire DevOps, paragraphe Docker |
| CHANGELOG.md | Mis à jour : entrée concise sur le rendu et son adoption à la prochaine génération | Première entrée Unreleased |
| openspec/specs/ | Synchronisée : une exigence ajoutée, une modifiée ; autres exigences préservées ; huit avertissements canoniques préexistants identiques après archivage | Delta validé strictement ; comparaison des 39 exigences initiales aux 40 finales ; validation canonique ordinaire réussie avant et après synchronisation |
| openspec/config.yaml | Inchangé : schéma spec-driven conservé | Empreinte témoin |

## Éligibilité à l'archivage

Les deux tâches élémentaires ont été traitées et validées séparément, dans
l'ordre. Les critères fonctionnels sont prouvés, la documentation est
cohérente et les huit avertissements canoniques préexistants sont explicités.
Aucune installation réelle, migration, action Git, sollicitation de Docker
réel ou modification de permissions n'est nécessaire. L'archivage autonome
autorisé porte uniquement sur `document-devops-docker-test-reference`.

## Archivage et vérification de synchronisation

La commande exécutée, avec le PATH Node DevOps explicite, est :

```bash
/home/devops/.local/npm/bin/openspec archive document-devops-docker-test-reference --yes
```

Résultat : code zéro, tâches complètes, une exigence ajoutée et une modifiée,
aucune suppression ni aucun renommage d'exigence. L'archive porte le nom
`2026-10-22-document-devops-docker-test-reference` ; le change actif ciblé
n'existe plus.

Un contrôle en mémoire compare les blocs d'exigences avant et après archive :
les 38 exigences non concernées sont identiques, l'exigence de structure
correspond au delta et l'exigence Docker ajoutée correspond au delta. La
spécification passe ainsi de 39 à 40 exigences. Les dix empreintes de code,
tests, cadrages, documentation et configuration figées avant l'archive sont
inchangées par cette opération.

Les validations canoniques après synchronisation donnent exactement les
mêmes résultats qu'avant : validation ordinaire réussie avec huit
avertissements de longueur et validation stricte échouée pour ces seuls
avertissements préexistants, aux mêmes indices. Aucun nouvel avertissement
n'est introduit par les exigences de ce change.

Le rapport `STATISTIQUES.md` est produit après cet archivage réussi ;
son contrôle final a réussi : six sections numérotées, douze fichiers du
périmètre en UTF-8/LF sans BOM, deux tâches cochées et absence du change actif.
Les totaux sont vérifiés par calcul : 89 méthodes distinctes, 178 exécutions
cumulées, 169 réussites et neuf erreurs initiales de fixtures, 112,650 s
cumulées. Les dix empreintes figées avant archive restent identiques ;
aucun code ou test n'a changé depuis la suite finale de 89 réussites.

La session est terminée pour le périmètre approuvé. Les huit avertissements
stricts préexistants de la spécification canonique restent signalés, sans
correction hors périmètre. Le relevé DEVOPS.md existant et la production
ne sont pas régénérés ou mis à jour par cette livraison des sources.

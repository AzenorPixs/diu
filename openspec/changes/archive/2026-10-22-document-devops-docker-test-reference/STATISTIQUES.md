# STATISTIQUES — Références Docker dans DEVOPS.md

## 1. Identification et périmètre

- Projet : Debian Installeur Unifié, identifiant `diu`.
- Racine : `/home/devops/datas/diu`.
- Date de session et d'archive : 22 octobre 2026, fuseau Europe/Paris.
- Session : SCM directe, périmètre explicitement validé par le développeur.
- Change : `document-devops-docker-test-reference`.
- Archive : `2026-10-22-document-devops-docker-test-reference`.
- Objet : compléter la rubrique Docker générée par son titre explicite,
  `/var/run/docker.sock` et `debian:stable-slim`.
- Preuves : sorties de commandes de la session, tâches cochées après
  validation, contrôles ciblés et [review.md](review.md).

Le rapport n'utilise aucune compétence de télémétrie SCMP, aucun service CAB
et aucune session OpenCode pilotée. Il décrit les observations disponibles.

## 2. Durées et mesures disponibles

| Mesure | Valeur et justification |
| --- | --- |
| Durée complète de session | N/A : aucun chronométrage global initialisé |
| Première suite, Python système 3.13.5 | 51,142 s, durée fournie par unittest |
| Suite finale, Python DevOps 3.14.9 | 61,508 s, durée fournie par unittest |
| Total des durées unittest observées | 112,650 s = 51,142 + 61,508 ; hors exploration, édition, lint et OpenSpec |
| Tokens, coût et ressources machine | N/A : aucune mesure instrumentée disponible |
| Nombre exhaustif de messages ou appels d'outils | N/A : aucun export de télémétrie de session |
| Approbations CAB | N/A : protocole CAB non applicable à cette session SCM directe |

## 3. Fichiers et contrat livré

| Catégorie finale | Nombre | Fichiers |
| --- | ---: | --- |
| Code existant modifié | 1 | modules/projects/template.sh |
| Tests existants modifiés | 1 | tests/test_projects_template_devops.py |
| Documentation existante modifiée | 3 | TECHNICAL.md ; README.md ; CHANGELOG.md |
| Spécification canonique synchronisée | 1 | openspec/specs/projects-template-devops/spec.md |
| Documents de l'archive créée | 6 | proposal.md ; design.md ; tasks.md ; specs/projects-template-devops/spec.md ; review.md ; STATISTIQUES.md |
| **Total final du périmètre** | **12** | **1 + 1 + 3 + 1 + 6** |

Six fichiers existants sont modifiés et six documents d'archive sont créés.
Les cinq artefacts actifs sont déplacés par OpenSpec, puis le présent rapport
est ajouté. Aucun fichier préexistant n'est supprimé ou renommé par la session.

Le rendu comporte quatre puces après le titre
`Docker, pour tests nécessitant des droits root` : version détectée ou
diagnostic, chemin du binaire ou diagnostic, `/var/run/docker.sock`,
`debian:stable-slim`. Les références restent présentes si Docker est absent
ou défaillant. Les autres rubriques, sondes et interfaces sont conservées ;
la version documentaire reste `0.6`.

Les cinq témoins inchangés sont AGENTS.md, PROJECT.md, BUILD.md, DEVOPS.md et
openspec/config.yaml. Le générateur retrouve son empreinte initiale en
remplaçant en mémoire uniquement la fonction de rendu modifiée. Les dix
empreintes de fichiers existants figées avant archivage sont conservées
par celui-ci. Les 38 exigences canoniques hors modification sont identiques.

## 4. Tests et vérifications

| Exécution unittest | Méthodes | Réussites | Échecs | Erreurs | Ignorées |
| --- | ---: | ---: | ---: | ---: | ---: |
| Première suite, Python système | 89 | 80 | 0 | 9 | 0 |
| Suite finale, Python DevOps | 89 | 89 | 0 | 0 | 0 |
| **Total cumulé des exécutions** | **178** | **169** | **0** | **9** | **0** |

Ces 178 exécutions couvrent 89 méthodes distinctes ; les sous-tests ne sont
pas comptés comme des méthodes supplémentaires. Les neuf erreurs initiales
`StopIteration` proviennent des chemins de paquets des fixtures venv sous le
Python système. Une reproduction isolée confirme ce décalage ; la suite
finale réussit avec le Python DevOps déclaré dans DEVOPS.md, sans modification
des fixtures venv. Les commandes exactes figurent dans review.md.

| Autre contrôle | Résultat |
| --- | --- |
| `bash -n modules/projects/template.sh` | Exécuté et réussi |
| `shellcheck modules/projects/template.sh` | Exécuté et réussi, zéro diagnostic |
| Compilation Python du test modifié | Exécutée et réussie sous les deux interpréteurs, caches temporaires supprimés |
| Change OpenSpec strict | Trois validations réussies ; une tentative initiale échouée pour longueur de rédaction, corrigée avant implémentation |
| Spécification canonique, validation ordinaire | Exécutée et réussie avant et après synchronisation, avec huit avertissements préexistants |
| Spécification canonique, validation stricte | Exécutée et échouée avant et après synchronisation pour les mêmes huit avertissements de longueur, indices 0, 2, 4, 6, 7, 8, 9 et 10 |
| Synchronisation ciblée | Exécutée et vérifiée : 39 exigences initiales, 40 finales, une ajoutée et une modifiée |
| Cohérence documentaire | Revue par fichier consignée dans review.md |
| UTF-8/LF, absence de BOM, six sections, tâches et totaux | Contrôle local final effectué après écriture du rapport, résultat consigné dans review.md |
| Docker réel, disponibilité du socket ou de l'image | Non exécutés : références documentaires ; seules les sondes simulées sont utilisées dans les tests |

Aucun test ni règle de validation n'a été désactivé ou affaibli. Le faux
binaire Docker accepte uniquement l'argument `--version`. Le code de rendu
ajoute des chaînes fixes et ne sonde pas le socket, ne télécharge ni ne
lance de conteneur, et ne modifie aucune permission.

## 5. Résultats et archivage

Commande exécutée avec le PATH Node DevOps explicite :

```bash
/home/devops/.local/npm/bin/openspec archive document-devops-docker-test-reference --yes
```

Elle retourne zéro, annonce les tâches complètes, synchronise la spécification
et crée l'archive ciblée. L'absence du change actif et la présence des cinq
artefacts archivés sont vérifiées avant création du rapport.

| Résultat OpenSpec | Nombre |
| --- | ---: |
| Tâches élémentaires validées séparément | 2 sur 2 |
| Exigences ajoutées | 1 |
| Exigences modifiées | 1 |
| Exigences supprimées | 0 |
| Exigences renommées | 0 |
| Changes archivés dans cette session | 1 |

Le présent fichier constitue le sixième document de l'archive. Aucun autre
change n'est archivé. Les écritures restent dans le périmètre approuvé.
Aucun commit, push, branche, tag, release, installation ou action Docker
réelle n'est effectué. Aucun état Git n'est inspecté pendant la session SCM.

## 6. Limites et suites

L'évolution est implémentée, vérifiée et archivée. Les huit avertissements
canoniques de longueur préexistants demeurent hors périmètre et empêchent
toujours la validation stricte du document canonique complet ; le delta ciblé
est strictement valide et la validation canonique ordinaire réussit.

Le changement de titre peut affecter un consommateur recherchant exactement
`# Docker`. Le tag `debian:stable-slim` suit Debian stable sans figer de version
ou de digest. Ces références ne démontrent ni la présence ni le fonctionnement
du socket ou de l'image.

Le DEVOPS.md existant n'est pas régénéré et la production n'est pas mise à
jour. Les documents adopteront le nouveau rendu à leur prochaine génération
normale avec les sources modifiées. Aucun autre change ni correction des
écarts rédactionnels antérieurs n'est engagé.

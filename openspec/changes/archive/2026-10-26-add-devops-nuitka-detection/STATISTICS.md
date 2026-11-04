# STATISTIQUES — Détection conditionnelle de Nuitka dans DEVOPS.md

## 1. Identification et périmètre

- Projet : Debian Installeur Unifié (`diu`), racine `/home/devops/datas/diu`.
- Session SCM directe, version 0.1 ; change `add-devops-nuitka-detection` ; date : 26 octobre 2026.
- Archive : `2026-10-26-add-devops-nuitka-detection`.
- Périmètre présenté puis explicitement validé par le développeur : détection Nuitka dans [build-system].requires, rubrique commune avec Cython, tests, documentation, synchronisation OpenSpec, archivage et statistiques.
- Aucun pilotage OpenCode, CAB ni sous-agent ; aucune compétence de statistiques pilotées invoquée, conformément à SCM.
- Les étapes Git conditionnelles prévues par SCM suivent ce rapport et restent distinctes de l’archivage.

## 2. Durées et mesures disponibles

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Durée totale de session | N/A | Pas de chronométrage complet fiable |
| Premier passage ciblé Cython/Nuitka | 25 tests réussis, 18,752 s | Sortie unittest observée |
| Complément découverte/sonde partagées | 1 test réussi, 0,144 s | Ajouté après le lancement du premier passage |
| Ciblés uniques validés | 26 | 14 existants Cython et 12 nouveaux Nuitka |
| Suite complète finale | 152 tests réussis, 114,953 s | Aucun cas ignoré, chemin Go déclaré fourni |
| Exécutions de méthodes de test | 178, toutes réussies | 25 + 1 + 152 ; les sous-cas ne sont pas additionnés |
| Cas uniques validés | 152 | Les ciblés sont inclus dans la suite finale |
| Nouveaux cas uniques Nuitka | 12 | Plus enrichissement du test existant de création |
| Modèle, jetons et coût | N/A | Aucune télémétrie qualifiée disponible |
| Messages, outils et commandes totaux | N/A | Aucun compteur exhaustif qualifié |
| Approbations/refus CAB | Non applicable | SCM directe |
| Recherche web | 1 appel préparatoire, 0 pendant la reprise de réalisation | Documentation officielle Nuitka consultée pendant l’exploration avant validation |

## 3. Fichiers et comportement livré

Six fichiers existants modifiés et cinq fichiers dans la nouvelle archive, rapport inclus : onze fichiers. Les écarts ci-dessous proviennent des sauvegardes ciblées initiales ; ils n’attribuent pas au change des modifications antérieures du dépôt.

| Fichier existant | Lignes ajoutées | Lignes retirées |
| --- | ---: | ---: |
| modules/projects/template.sh | 34 | 26 |
| tests/test_projects_template_devops.py | 213 | 8 |
| TECHNICAL.md | 24 | 20 |
| README.md | 12 | 9 |
| CHANGELOG.md | 8 | 0 |
| openspec/specs/projects-template-devops/spec.md | 56 | 5 |
| Total | 347 | 68 |

L’archive contient proposal.md, design.md, tasks.md, specs/projects-template-devops/spec.md et ce STATISTIQUES.md. Aucun fichier de l’archive Cython précédente n’a été modifié par cette évolution.

Le mode compilation du helper existant reconnaît seulement les distributions Cython et Nuitka déclarées dans [build-system].requires, sans distinction de casse, avec extras, contraintes et marqueurs déclaratifs. L’alias interne cython est conservé. Le rendu utilise compilation, effectue une seule découverte et demande seulement les noms déclarés encore recherchés aux sondes.

Une seule rubrique suit pip et précède Prompts. Elle affiche Cython puis Nuitka, uniquement s’ils sont déclarés. Sans les deux déclarations, la rubrique et toute découverte/sonde de compilation sont omises. Une autre table ou un commentaire ne déclenche pas cet inventaire.

Les états restent indépendants par outil : version, interpréteur, environnement et installation observés ; non installé avec les venv vérifiés si l’absence est établie ; installation non vérifiable sinon, notamment sans venv. Une ambiguïté de métadonnées pour l’un ne modifie pas une observation valide de l’autre. Aucun paquet global ne sert de repli.

Sondes -I -B -S, mêmes priorités de venv et mêmes bornes de 3 secondes par sonde et 12 secondes pour recherche/sondes. Aucun import de Cython ou Nuitka, chargement de .pth, installation, compilation, modification de manifeste ou de backend. Les références directes sont masquées et les contraintes ne sont pas résolues. Les versions présentes dans les fixtures ne prouvent aucune installation réelle des compilateurs.

## 4. Tests et vérifications

| Contrôle | État final et résultat |
| --- | --- |
| bash -n modules/projects/template.sh | Exécuté et réussi |
| shellcheck modules/projects/template.sh | Exécuté et réussi |
| py_compile tests/test_projects_template_devops.py | Exécuté et réussi avec Python DevOps, cache isolé dans le temporaire de session |
| Tests ciblés Cython/Nuitka | Exécutés et réussis : 25 méthodes puis un complément, 26 uniques |
| Suite complète du générateur | Exécutée et réussie : 152 méthodes, aucun cas ignoré |
| Change OpenSpec strict | Exécuté et réussi avant code puis après implémentation, sans diagnostic |
| Canon OpenSpec standard après archivage | Exécuté et réussi avec ses huit avertissements préexistants |
| Stricte globale initiale | Exécutée et échouée : 46 valides, 22 échecs sur 68 éléments |
| Stricte globale avant archive | Exécutée et échouée : 47 valides, mêmes 22 échecs et diagnostics sur 69 éléments |
| Stricte globale finale | Exécutée et échouée : 46 valides, mêmes 22 échecs et diagnostics initiaux sur 68 éléments |
| Synchronisation | Six blocs du delta retrouvés exactement dans le canon |
| UTF-8/LF et périmètre | Vérifiés par lecture et comparaison aux sauvegardes ciblées |
| Construction de paquet, installation et compilation applicative | Non pertinentes : génération documentaire DIU uniquement |

Commandes principales réellement exécutées :

```bash
bash -n modules/projects/template.sh
shellcheck modules/projects/template.sh
env PYTHONPYCACHEPREFIX=<temporaire-de-session>/pycache /home/devops/python/current/bin/python3 -m py_compile tests/test_projects_template_devops.py
/home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_template_devops.py -k test_nuitka -k test_cython
/home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_template_devops.py -k test_nuitka_shared
env DIU_TEST_GO=/home/devops/go/current/bin/go /home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_template_devops.py
sudo -n -u devops /home/devops/.local/npm/bin/openspec validate add-devops-nuitka-detection --type change --strict --json
sudo -n -u devops /home/devops/.local/npm/bin/openspec validate projects-template-devops --type spec --json
sudo -n -u devops /home/devops/.local/npm/bin/openspec validate --all --strict --json
```

Couverture : quatre combinaisons de déclaration, ordre et titre unique, casse, extras, marqueurs, contraintes, références masquées, autres tables et commentaires ignorés, noms demandés aux sondes limités aux déclarations, découverte et sonde uniques pour deux outils dans le même venv, états indépendants, métadonnées dupliquées, paquets globaux ignorés, environnements distincts et chemins avec espaces, priorité, non-import et .pth non chargé, absence de venv, échec, budget épuisé, terminaison des descendants expirés, analyse sans Python DevOps, manifeste invalide, génération groupée et création depuis modèle Python déclarant les deux compilateurs. Les tests Cython antérieurs restent exécutés.

Aucun contrôle requis du change n’est en échec. La stricte globale conserve ses diagnostics préexistants ; elle n’est pas présentée comme réussie. Aucune modification de code ni de tests après la suite finale.

## 5. Cohérence documentaire et archivage

| Élément | État final et preuve |
| --- | --- |
| Projet réel | Générateur et 152 tests validés ; pas de génération sur un projet réel |
| AGENTS.md | Inchangé, comparaison octet pour octet ; règles générales respectées |
| PROJECT.md | Inchangé, comparaison octet pour octet ; architecture et module projects préservés |
| TECHNICAL.md | Mis à jour : Outils de compilation Python : Cython et Nuitka déclarés, découverte commune et états indépendants |
| BUILD.md | Inchangé, comparaison octet pour octet ; packaging non concerné |
| DEVOPS.md | Inchangé pendant cette réalisation, comparaison octet pour octet ; relevé daté conservé au format 0.7 |
| README.md | Mis à jour : déclenchement des deux outils, rubrique unique, états et limites |
| CHANGELOG.md | Entrée Unreleased ajoutée sans version de publication inventée |
| openspec/config.yaml | Inchangé, comparaison octet pour octet |
| openspec/specs/projects-template-devops/spec.md | Synchronisé : trois exigences ajoutées, trois modifiées, aucune supprimée ou renommée |

Archivage effectué sous devops par `openspec archive add-devops-nuitka-detection --yes --json`, code 0, specsUpdated=true. Dossier actif absent et archive présente ; six tâches cochées sur preuves. Les six contrats du delta ont une longueur inférieure à 500 caractères ; aucun nouvel avertissement dans le canon.

Ce rapport comporte six sections, en UTF-8/LF ; les totaux de fichiers, lignes et tests sont vérifiés. Aucun BLOCKER.md ou BLOCKERS.md ni lien caduc dans cette archive ; aucun nettoyage de bilan nécessaire. Aucun autre change ni archive modifié dans le cadre de cette évolution.

## 6. Limites et clôture

L’évolution est réalisée, testée et archivée. Les 22 échecs OpenSpec stricts préexistants restent hors périmètre et sont identiques à l’état initial ; le canon concerné passe en mode standard avec huit avertissements préexistants.

La livraison porte sur les sources DIU. Aucun déploiement, régénération de DEVOPS.md de Pixs, modification de son pyproject.toml ni compilation avec Nuitka n’a été effectué. Les documents existants adoptent la rubrique lors de leur prochaine génération avec cette version DIU.

Les sauvegardes et caches temporaires sont retirés après leurs derniers contrôles et avant Git. Les étapes conditionnelles de commit global local puis Forgejo, GitHub et GitLab suivent ce rapport ; leurs résultats vérifiés ou motifs de non-application sont restitués dans le bilan final, sans préjuger ici de leur réussite.

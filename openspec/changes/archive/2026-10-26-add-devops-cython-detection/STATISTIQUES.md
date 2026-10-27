# STATISTIQUES — Détection conditionnelle de Cython dans DEVOPS.md

## 1. Identification et périmètre

- Projet : Debian Installeur Unifié (`diu`), racine `/home/devops/datas/diu`.
- Session : SCM directe, version 0.1, détection Cython, 26 octobre 2026.
- Change : `add-devops-cython-detection` ; archive : `2026-10-26-add-devops-cython-detection`.
- Le développeur a explicitement validé la proposition puis demandé le lancement SCM : détecter Cython dans `[build-system].requires`, sonder seulement après déclaration et omettre la rubrique sans déclaration.
- Périmètre : générateur, tests, spécifications, documentation, archivage et présent rapport. Les étapes Git conditionnelles du prompt suivent le rapport.
- Aucun pilotage OpenCode, mandat CAB ni sous-agent. La compétence de statistiques pilotées n’a pas été invoquée conformément à SCM.

## 2. Durées et mesures disponibles

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Durée totale de session | N/A | Aucun chronométrage global fiable |
| Premier passage Cython | 12 tests, 9,242 s ; échec | Deux méthodes en échec, six enregistrements d’échec dont cinq sous-cas ; fixtures d’appel et de remplacement corrigées |
| Deuxième passage Cython | 12 tests réussis, 8,811 s | Sortie unittest observée |
| Passage Cython final | 14 tests réussis, 9,818 s | Ajout des contrôles groupé et de rejet de sortie partielle |
| Suite complète finale | 140 tests réussis, 105,113 s | Aucun cas ignoré, avec le chemin Go déclaré |
| Nouveaux cas uniques Cython | 14 | Inclus dans les 140, plus enrichissement du cas existant de création |
| Exécutions de méthodes de test | 178 | 12 + 12 + 14 + 140 ; les sous-cas ne sont pas ajoutés comme méthodes |
| Cas uniques validés | 140 | La suite finale couvre les passages ciblés |
| Modèle, jetons et coût | N/A | Aucune télémétrie qualifiée disponible |
| Messages, outils et commandes totaux | N/A | Aucun compteur exhaustif qualifié |
| Approbations/refus CAB | Non applicable | SCM directe |
| Outils de recherche web utilisés | 0 | Aucune recherche web nécessaire à cette implémentation |

## 3. Fichiers et comportement livré

Six fichiers existants modifiés et cinq fichiers dans l’archive, rapport inclus : onze fichiers. Les écarts ci-dessous sont calculés par comparaison aux sauvegardes ciblées initiales, sans inspection Git pendant l’implémentation et sans attribution des travaux antérieurs du dépôt.

| Fichier existant | Lignes ajoutées | Lignes retirées |
| --- | ---: | ---: |
| modules/projects/template.sh | 69 | 11 |
| tests/test_projects_template_devops.py | 212 | 1 |
| TECHNICAL.md | 30 | 2 |
| README.md | 10 | 0 |
| CHANGELOG.md | 8 | 0 |
| openspec/specs/projects-template-devops/spec.md | 59 | 3 |
| Total | 388 | 17 |

L’archive contient proposal.md, design.md, tasks.md, specs/projects-template-devops/spec.md et ce STATISTIQUES.md.

Le mode interne Cython du helper existant lit le TOML avant toute découverte de venv. Une déclaration dans `[build-system].requires` produit la rubrique après pip et avant Prompts. L’absence de déclaration, y compris lorsque Cython apparaît seulement dans un commentaire ou une autre table, ne lance aucune découverte ni sonde Cython. Les autres outils de compilation ne sont pas ajoutés par cette évolution.

Une installation observée indique version, interpréteur, environnement et emplacement issus des métadonnées. Une absence établie dans les venv sondés indique non installé avec les environnements vérifiés. Une absence de venv ou une vérification impossible/incomplète indique installation non vérifiable. Aucun paquet global ne sert de repli Cython ; l’inventaire d’exécution conserve son comportement et son repli existants.

Les sondes réutilisent l’ordre .venv, venv, env puis autres chemins triés et les limites de 3 secondes par sonde et 12 secondes pour recherche/sondes. Aucun import Cython, chargement de .pth, installation, compilation ou modification de manifeste. Les contraintes restent déclaratives ; aucune conformité de version ni utilisation effective pour compiler n’est déduite.

## 4. Tests et vérifications

| Contrôle | État final et résultat |
| --- | --- |
| bash -n modules/projects/template.sh | Exécuté et réussi |
| shellcheck modules/projects/template.sh | Exécuté et réussi |
| py_compile du fichier de tests | Exécuté et réussi avec Python DevOps ; cache isolé dans le temporaire de session |
| Tests Cython ciblés | Exécutés et réussis : 14 méthodes |
| Suite complète test_projects_template_devops.py | Exécutée et réussie : 140 méthodes, aucun cas ignoré |
| Change OpenSpec strict | Exécuté et réussi avant code puis avant archive, sans diagnostic après correction des contrats trop longs |
| Canon OpenSpec standard après synchronisation | Exécuté et réussi, huit avertissements préexistants |
| Stricte globale initiale | Exécutée et échouée : 46 valides, 22 échecs, 68 éléments |
| Stricte globale avant archive | Exécutée et échouée : 47 valides, mêmes 22 échecs et diagnostics, 69 éléments |
| Stricte globale finale | Exécutée et échouée : 46 valides, mêmes 22 échecs et diagnostics initiaux, 68 éléments |
| Contrôle de synchronisation | Six blocs du delta final retrouvés exactement dans le canon |
| UTF-8/LF et périmètre | Vérifiés par lecture et comparaison aux sauvegardes ciblées |
| Construction de paquet, installation et compilation Pixs | Non pertinentes : génération documentaire DIU uniquement |

Commandes principales :

```bash
bash -n modules/projects/template.sh
shellcheck modules/projects/template.sh
env PYTHONPYCACHEPREFIX=<temporaire-de-session>/pycache /home/devops/python/current/bin/python3 -m py_compile tests/test_projects_template_devops.py
/home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_template_devops.py -k test_cython
env DIU_TEST_GO=/home/devops/go/current/bin/go /home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_template_devops.py
sudo -n -u devops /home/devops/.local/npm/bin/openspec validate add-devops-cython-detection --type change --strict --json
sudo -n -u devops /home/devops/.local/npm/bin/openspec validate projects-template-devops --type spec --json
sudo -n -u devops /home/devops/.local/npm/bin/openspec validate --all --strict --json
```

Les tests vérifient casse, contraintes et marqueurs, commentaires et autres tables, absence de toute découverte Cython sans déclaration, installation globale ignorée, venv sans paquet, venv absent, manifeste invalide, analyse système sans Python DevOps, priorité et chemins avec espaces, import et .pth non exécutés, métadonnées dupliquées, erreurs, budgets, arrêt des descendants, références directes masquées, sortie partielle rejetée et parcours groupé. Le test existant de création vérifie aussi la rubrique pour un modèle Python déclarant Cython et son omission pour les autres créations.

Après synchronisation, un nouveau diagnostic de longueur du paragraphe de provenance a été détecté et corrigé dans le canon et le delta archivé à contenu équivalent, sans réarchivage. La comparaison finale des diagnostics est identique à l’état initial. Aucune modification de code ni de tests n’a suivi la suite finale.

## 5. Cohérence documentaire et archivage

| Élément | État final et preuve |
| --- | --- |
| Projet réel | Générateur et 140 tests validés ; aucun document de projet réel régénéré |
| AGENTS.md | Inchangé, comparaison octet pour octet ; règles générales conservées |
| PROJECT.md | Inchangé, comparaison octet pour octet ; module projects et architecture conservés |
| TECHNICAL.md | Mis à jour : provenance, placement de Prompts et section Outils de compilation Python : Cython déclaré |
| BUILD.md | Inchangé, comparaison octet pour octet ; packaging hors périmètre |
| DEVOPS.md | Inchangé, comparaison octet pour octet ; inventaire daté au format 0.7, prochaine génération normale nécessaire |
| README.md | Mis à jour : déclenchement, états, limites et prochaine génération |
| CHANGELOG.md | Entrée Unreleased ajoutée, sans version de publication inventée |
| openspec/config.yaml | Inchangé, comparaison octet pour octet |
| openspec/specs/projects-template-devops/spec.md | Synchronisé : trois exigences ajoutées et trois modifiées ; six blocs retrouvés dans le canon |

Archivage réussi sous le compte devops : `openspec archive add-devops-cython-detection --yes --json`, code 0, specsUpdated=true. Dossier actif absent, dossier d’archive présent, six tâches cochées sur preuves. Aucun autre change ni archive modifié dans cette session. Le premier contrôle de correspondance utilisait une expression de recherche trop large ; sa correction a permis de comparer exactement les six blocs.

Le rapport possède six sections, en UTF-8/LF. Les totaux de fichiers, lignes et méthodes sont vérifiés. Aucun fichier BLOCKER.md ou BLOCKERS.md ni lien caduc ne se trouve dans l’archive ; aucun nettoyage de bilan nécessaire.

## 6. Limites et clôture

L’évolution est réalisée, testée et archivée. La stricte globale OpenSpec conserve les 22 échecs préexistants ; ils restent hors périmètre et ne constituent pas une validation globale réussie. Le canon concerné passe en mode standard avec ses huit avertissements préexistants.

La livraison concerne les sources DIU. Aucun déploiement, régénération de DEVOPS.md de Pixs ou modification de son pyproject.toml n’a été effectué. Le format documentaire 0.7 reste conservé.

Les sauvegardes et caches temporaires sont supprimés après leurs derniers contrôles, avant l’étape Git. Les étapes conditionnelles de commit local puis publication Forgejo, GitHub et GitLab sont distinctes de l’archivage : leurs résultats réels ou motifs de non-application sont restitués dans le bilan final, après ce rapport, sans préjuger ici de leur succès.

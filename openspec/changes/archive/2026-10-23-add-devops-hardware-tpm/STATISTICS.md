# STATISTIQUES — Inventaire matériel TPM dans DEVOPS.md

## 1. Identification et périmètre

- Projet : Debian Installeur Unifié, identifiant `diu`.
- Racine : `/home/devops/datas/diu`.
- Date : 23 octobre 2026, fuseau Europe/Paris.
- Session : SCM directe, périmètre TPM et cycle OpenSpec complet explicitement
  validés par le développeur après exploration en lecture seule.
- Change : `add-devops-hardware-tpm`.
- Archive : `2026-10-23-add-devops-hardware-tpm`.
- Objet : Matériel après l'OS, puis TPM avec chemin, version, fabricant,
  identifiant fournisseur, révision de spécification et registres PCR.
- Preuves : commandes et résultats de cette session, [tasks.md](tasks.md),
  [design.md](design.md) et delta [specs/projects-template-devops/spec.md](specs/projects-template-devops/spec.md).

SCM est exécuté directement, sans compétence de télémétrie SCMP ni service
CAB/OpenCode. Les autres informations matérielles restent des propositions.

## 2. Durées et mesures disponibles

| Mesure | Valeur et justification |
| --- | --- |
| Début de la capture d'empreintes | 2026-10-23T12:27:53.988815Z |
| Point de mesure avant ce rapport | 2026-10-23T12:42:46Z, horloge UTC de session |
| Durée globale complète | N/A : l'exploration du tour précédent et les contrôles après ce point ne sont pas chronométrés globalement |
| Suite TPM initiale | 8,816 s selon unittest |
| Suite complète du générateur | 72,138 s selon unittest |
| Reprise ciblée Go et Node | 0,063 s selon unittest |
| Total des durées unittest | 81,017 s = 8,816 + 72,138 + 0,063 ; hors exploration, édition, lint et OpenSpec |
| Tokens, coût et ressources machine | N/A : aucune mesure instrumentée disponible |
| Nombre exhaustif de messages et appels d'outils | N/A : aucun export de télémétrie de session |
| Approbations CAB | N/A : SCM directe, protocole CAB non applicable |

## 3. Fichiers et contrat livré

| Catégorie finale | Nombre | Fichiers |
| --- | ---: | --- |
| Code existant modifié | 1 | modules/projects/template.sh |
| Tests existants modifiés | 1 | tests/test_projects_template_devops.py |
| Documentation existante modifiée | 3 | TECHNICAL.md ; README.md ; CHANGELOG.md |
| Spécification canonique synchronisée | 1 | openspec/specs/projects-template-devops/spec.md |
| Documents de l'archive créée | 5 | proposal.md ; design.md ; tasks.md ; specs/projects-template-devops/spec.md ; STATISTIQUES.md |
| **Total final du périmètre** | **11** | **1 + 1 + 3 + 1 + 5** |

Six fichiers existants sont modifiés et cinq documents d'archive sont créés.
OpenSpec déplace les quatre artefacts actifs ; ce rapport est ensuite ajouté.
Aucun fichier préexistant n'est supprimé ou renommé par cette session.
Les fichiers témoins AGENTS.md, PROJECT.md, BUILD.md, DEVOPS.md et
openspec/config.yaml conservent leur empreinte initiale et leur mode.
Les dix empreintes hors canon figées juste avant archivage sont inchangées
après celui-ci. Aucun temporaire de test ou compilation ne subsiste.

La section Matériel suit l'OS et précède Docker, avec une seule sous-rubrique
TPM. Les six puces restent présentes dans l'ordre demandé. Les chemins
tpmrmN sont prioritaires sur tpmN ; la collecte utilise le même indice dans
sysfs. Le fabricant est le code ASCII observé de TPM2_PT_MANUFACTURER et
l'identifiant fournisseur son code hexadécimal, sans nom commercial inventé.
La révision de spécification reste distincte du firmware. Les PCR désignent
les banques et indices alloués, sans lecture de leurs valeurs.

Les requêtes properties-fixed et pcrs utilisent un transport device explicite,
5 secondes de délai et une seconde supplémentaire avant terminaison forcée.
Les réponses de plus de 64 Kio ne sont pas analysées. Les données absentes,
invalides ou ambiguës restent non vérifiables ; les erreurs brutes ne sont
pas publiées. Aucun outil, permission ou état du TPM n'est modifié.
Les rubriques existantes, la version documentaire 0.6, les commandes, les
droits et la publication robuste du document sont conservés.

## 4. Tests et vérifications

| Exécution unittest | Méthodes exécutées | Réussites | Échecs | Erreurs | Ignorées |
| --- | ---: | ---: | ---: | ---: | ---: |
| Suite TPM initiale | 13 | 13 | 0 | 0 | 0 |
| Suite complète du générateur | 103 | 101 | 0 | 0 | 2 |
| Reprise ciblée Go et Node | 2 | 2 | 0 | 0 | 0 |
| **Total cumulé des exécutions** | **118** | **116** | **0** | **0** | **2** |

Les 103 méthodes distinctes ont toutes réussi au moins une fois : 89
préexistantes et 14 nouvelles méthodes TPM. Les deux tests réels Go/Node
initialement ignorés ont été repris avec les binaires DevOps explicites et
ont réussi. Les sous-tests ne sont pas comptés comme méthodes supplémentaires.
Les tests utilisent des symlinks vers /dev/null comme périphériques caractères
factices, un sysfs temporaire et un faux tpm2_getcap ; ils ne touchent pas au
TPM réel. Le refus d'accès est simulé à la frontière de contrôle des droits.

Commandes unittest exécutées depuis la racine :

```bash
/home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_template_devops.py -k tpm -v
/home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_template_devops.py
env DIU_TEST_GO=/home/devops/go/current/bin/go DIU_TEST_NODE=/home/devops/node/current/bin/node /home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_template_devops.py -k test_real_go -k test_real_node -v
```

| Autre contrôle | Résultat observé |
| --- | --- |
| `bash -n modules/projects/template.sh` | Exécuté et réussi |
| `shellcheck modules/projects/template.sh` | Exécuté et réussi, zéro diagnostic final ; les diagnostics initiaux SC2120/SC2119 ont été corrigés par le passage explicite des racines à la fonction interne |
| Compilation du test modifié | Exécutée et réussie avec le Python DevOps et `-m py_compile`, cache temporaire créé sous la racine puis supprimé |
| Change OpenSpec strict | Deux validations réussies, dont une avant toute écriture de code ou test |
| Canon OpenSpec ordinaire | Exécuté et réussi avant et après synchronisation, avec les mêmes huit avertissements |
| Canon OpenSpec strict | Exécuté et échoué avant et après synchronisation pour les mêmes huit avertissements de longueur, indices 0, 2, 4, 6, 7, 8, 9 et 10 ; comparaison JSON identique |
| Synchronisation canonique ciblée | 40 exigences initiales, 45 finales ; cinq ajoutées, une modifiée, 39 préservées hors séparation finale |
| Empreintes des exigences | Le premier contrôle brut a détecté un saut de ligne séparateur ajouté avant les nouvelles exigences ; la comparaison suivante confirme que seule Structure et version documentaire change de contenu |
| TPM réel en lecture seule | La requête directe initiale échoue pour accès refusé ; le rendu final réussit avec /dev/tpmrm0, version 2.0 issue de sysfs et quatre diagnostics d'accès refusé |
| UTF-8/LF, absence de BOM et modes | Contrôle réussi avant archivage ; rapport et archive contrôlés après écriture |
| Tests des autres modules et qualification complète du TPM réel | Non exécutés : autres modules hors périmètre et accès matériel refusé au compte courant |

Les tests TPM couvrent priorités de chemins et indice sysfs, repli sur tpmN,
famille sans sysfs, absence de périphérique, outil manquant, accès refusé,
TPM 1.2, propriétés partielles/dupliquées, sorties mal formées, PCR invalides,
limites de taille, expiration de chacune des deux sondes et chemins avec
espaces. Les parcours groupé et de création vérifient aussi le rendu TPM.
Aucun test préexistant n'est désactivé ou affaibli ; ses attentes de structure
sont actualisées uniquement pour la rubrique et sous-rubrique ajoutées.

## 5. Cohérence documentaire et archivage

| Élément de la matrice SCM | État et preuve |
| --- | --- |
| Projet réel | Rendu dans modules/projects/template.sh ; 103 méthodes distinctes validées ; lecture réelle limitée par les droits, explicitée ci-dessus |
| AGENTS.md | Inchangé, empreinte et mode conservés ; sections 5, 6, 7 et 19 respectées : périmètre validé, OpenSpec, rapport d'archive et encodage |
| PROJECT.md | Inchangé, empreinte et mode conservés ; module projects et architecture existants préservés |
| TECHNICAL.md | Mis à jour dans Matériel TPM dans le document DevOps : sources, ordre, diagnostics, délais, PCR et limites |
| BUILD.md | Inchangé, empreinte et mode conservés ; aucune dépendance, construction ou installation modifiée |
| DEVOPS.md | Inchangé, empreinte et mode conservés ; inventaire existant actualisé à sa prochaine génération normale, conformément au périmètre validé |
| README.md | Mis à jour après la présentation de la génération DevOps : rubrique, ordre et limites TPM |
| CHANGELOG.md | Entrée Unreleased ajoutée pour le comportement TPM livré, sans inventer de version de publication |
| openspec/specs/ | projects-template-devops synchronisée : cinq exigences TPM nouvelles et structure complétée ; 39 exigences préservées hors séparateurs |

Tous les appels OpenSpec utilisent le binaire
`/home/devops/.local/npm/bin/openspec`, avec
`PATH=/home/devops/node/current/bin:/usr/local/bin:/usr/bin:/bin` et
`OPENSPEC_TELEMETRY=0`. Les validations utilisent `validate` avec `--type change`
ou `--type spec`, les options `--strict` et `--json` lorsque précisées.
La synchronisation et l'archivage ont été réalisés par :

```bash
env PATH=/home/devops/node/current/bin:/usr/local/bin:/usr/bin:/bin OPENSPEC_TELEMETRY=0 /home/devops/.local/npm/bin/openspec archive add-devops-hardware-tpm --yes
```

La commande retourne zéro, confirme les tâches complètes, synchronise la
capacité et annonce l'archive ciblée. L'absence du change actif, les quatre
artefacts archivés et les sept tâches cochées sont vérifiés avant création
de ce cinquième document. Aucun autre change n'est archivé.

| Résultat | Nombre |
| --- | ---: |
| Tâches préalables validées | 7 sur 7 |
| Exigences ajoutées | 5 |
| Exigences modifiées | 1 |
| Exigences supprimées | 0 |
| Exigences renommées | 0 |
| Changes archivés dans la session | 1 |
| Documents finaux dans l'archive | 5 |

Le contrôle final du présent rapport vérifie les six sections, les 11
fichiers du périmètre, les totaux 118 = 116 + 0 + 0 + 2 et 103 = 89 + 14,
l'encodage UTF-8/LF sans BOM, les sept tâches cochées, les empreintes témoins
et l'absence de temporaires de test ou compilation.

## 6. Limites et suites

L'évolution TPM est implémentée, vérifiée, synchronisée et archivée. Les huit
avertissements canoniques de longueur préexistants restent hors périmètre :
le canon complet échoue toujours en mode strict, tandis que son mode ordinaire
et le delta ciblé sont valides. Aucun nouvel avertissement n'est introduit.

La collecte matérielle complète n'a pas pu être vérifiée sur le TPM réel
avec le compte courant ; aucune élévation de privilèges ou modification des
droits n'est tentée. Les lectures réussies sont validées par fixtures isolées.
Le code ASCII fabricant ne constitue pas un nom commercial déduit. Les
banques/indices PCR décrivent l'allocation, sans qualification d'attestation.

DEVOPS.md existant n'est pas régénéré et la production n'est pas mise à jour.
Les documents adopteront ce rendu à leur prochaine génération normale avec
les sources modifiées. Aucun état Git n'est inspecté, aucun commit, push,
branche, tag ou release n'est créé. Aucun service partagé n'est touché.
CPU, mémoire, GPU et stockage restent à l'état de propositions.

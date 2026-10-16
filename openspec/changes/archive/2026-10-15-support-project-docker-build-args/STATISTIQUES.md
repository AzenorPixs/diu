# STATISTIQUES — Arguments Docker publics

## 1. Identification et périmètre

Date : 15 octobre 2026, Europe/Paris. Change :
`support-project-docker-build-args`. Archive :
`2026-10-15-support-project-docker-build-args`.

Session SCM directe, sans délégation, OpenCode/CAB ou compétence de
statistiques de pilotage. Périmètre : lecteur générique de
build/docker-build.args, tests, adaptation d'un consommateur dans son dépôt,
revue documentaire et archivage ciblé. Aucune dépendance applicative n'est
ajoutée au DIU ; aucun commit, push, déploiement, publication ou installation
système n'est exécuté. Aucun état Git ni fichier sensible réel n'est consulté.

## 2. Durées et mesures disponibles

Référence SHA-256 prise le 2026-10-15T15:44:54+02:00.
Rapport produit le 2026-10-15T16:11:25+02:00.
Intervalle observé : 1590.931 s, sans prétendre mesurer
la conversation entière. Somme des durées unittest : 3,515 s.

Tokens, coût, compte exhaustif des messages/outils et télémétrie d'agents :
N/A, aucune sonde de pilotage n'est activée pour SCM. Lignes modifiées : N/A,
le relevé capture seulement les empreintes et aucune inspection Git n'est
réalisée. Agents délégués : 0. Paquets hôte installés : 0.

## 3. Fichiers et contrat

34 références préexistantes suivies par SHA-256 : 13 modifiées attendues,
21 inchangées. Les entrées consommateur ci-dessous sont des chemins relatifs
à son dépôt, distinct du moteur générique :

- `PROJECT.md`
- `TECHNICAL.md`
- `README.md`
- `CHANGELOG.md`
- `modules/projects/docker.sh`
- `openspec/specs/modify-projects-docker-build/spec.md`
- `consommateur/PROJECT.md`
- `consommateur/TECHNICAL.md`
- `consommateur/BUILD.md`
- `consommateur/README.md`
- `consommateur/CHANGELOG.md`
- `consommateur/tests/test_packaging.py`
- `consommateur/docs/exploitation.md`

Nouveaux fichiers hors change : tests/test_projects_docker_build_args.py et
consommateur/build/docker-build.args. Six fichiers du change sont créés puis
déplacés dans l'archive ; ce rapport y ajoute un septième fichier. Le fichier
de spécification principale existant est enrichi, aucune nouvelle capacité
principale n'est créée. Les catégories création, déplacement et modification
se recouvrent et ne sont pas additionnées comme des fichiers distincts.

La comparaison des corps normatifs confirme cinq exigences antérieures
inchangées et huit nouvelles exigences identiques au delta archivé : treize
exigences et vingt-et-un scénarios au total. Les autres changes actifs ne
sont pas traités. Règles, prompts, inventaires, configuration OpenSpec,
licences, .gitignore, BUILD du paquet Debian et runtime du consommateur restent
inchangés.

## 4. Tests et vérifications

| Suite | Cas exécutés | Réussis | Échecs | Erreurs | Durée s |
|---|---:|---:|---:|---:|---:|
| DIU initial | 16 | 16 | 0 | 0 | 0.727 |
| DIU, ajout flux simulé | 17 | 16 | 1 | 0 | 0.828 |
| DIU, correction fixture | 17 | 16 | 0 | 1 | 0.769 |
| DIU final | 17 | 17 | 0 | 0 | 0.807 |
| Consommateur packaging | 4 | 4 | 0 | 0 | 0.384 |
| Total, répétitions incluses | 71 | 69 | 1 | 1 | 3.515 |

Résultat final : **21 tests ciblés distincts réussis**, sans test ignoré,
soit 17 DIU et 4 packaging consommateur. L'échec puis l'erreur intermédiaires
concernent uniquement le harnais du flux CI/CD : print_title simulé absent,
puis fixture Dockerisation 1 alors que ce flux historique attend Yes.
Les assertions sont conservées, la fixture corrigée. Aucun comportement
hors périmètre du pipeline n'est modifié.

Bash -n et ShellCheck réussissent sur le module Docker. La suppression
SC2034 est limitée à une affectation par nameref réellement consommée et
couverte par les tests. Les deux modules Python concernés compilent.
Validation stricte du change avant archivage puis de la spécification
principale après archivage : exécutées et réussies, aucune issue.

Le BUILD local avec les six arguments du lecteur générique réussit et sa
version native correspond à la référence publique du consommateur. Aucun
project.env réel n'est chargé pour ce contrôle, capture Git automatique
Buildx désactivée, aucune CI/CD réelle n'est exécutée. Les tests du flux
simulent entièrement Git, runuser, Docker et publications.

## 5. Résultats et archivage

Le lecteur conserve octets et frontières de valeurs, y compris espaces,
quotes, dollars, antislashs, Unicode, #, = et valeur vide. Il ne les exécute
pas et ne les affiche pas. Doublons, clés invalides, CR/NUL, FIFO/liens et
fichiers hors limite sont refusés avant Docker. La lecture est bornée à
65 537 octets pour détecter également une croissance après stat ; maximum
accepté 65 536 octets. Cent appels vérifient la fermeture des descripteurs.
Sans fichier, la commande et l'utilisateur historiques restent identiques.

Archivage officiel exécuté une seule fois :
`openspec archive support-project-docker-build-args --json --yes`.
Résultat : specsUpdated=true, 8 exigences ajoutées, 0 modifiée, 0 supprimée,
0 renommée. Les huit tâches sont réalisées. Le rapport compte six sections.
La recherche ciblée des fichiers DIU concernés confirme l'agnosticisme ;
les paramètres applicatifs restent exclusivement dans le consommateur.

## 6. Limites et suites

Le fichier est public et non sensible. Sa syntaxe ne peut pas classifier une
valeur arbitraire ni garantir le masquage des sorties natives Docker.
Les quotes sont littérales et aucune interpolation d'environnement n'est
ajoutée. La cohérence applicative appartient au consommateur et à ses tests.

Les tests runtime/protocoles du consommateur ne sont pas relancés : ils ne
sont pas concernés par cette transmission de BUILD et leurs sources restent
inchangées. La validation locale n'est pas une publication ou installation.
Le DIU installé n'est pas mis à jour par cette session ; cette action reste
séparée. Images locales et cache de construction sont conservés, seules les
fixtures sous les deux dépôts sont nettoyées.

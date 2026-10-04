## Context

Le monolithe installe et met à jour `psycopg[binary]>=3.2,<4` après les liens
Python/pip DevOps, contrôle sa version et son import, puis génère le profil.
`launch_ocrw` installe également `psycopg>=3.2,<4` au démarrage du conteneur.
La spécification `devops-python` exige actuellement la gestion DevOps.

## Goals / Non-Goals

Objectif : désactiver ces opérations spécifiques à Psycopg et conserver
leur code en commentaires, conformément au périmètre validé.
Préserver la préparation Python et le lancement OpenCode. Ne pas modifier les
montages, permissions, dépendances système, configurations, routes CLI ou
dépendances des projets ; ne pas exécuter d'installation ni de conteneur.

## Decisions

- Commenter chaque ligne du bloc Psycopg DevOps, y compris le code Python
  embarqué et les messages, afin qu'aucun contrôle annexe ne reste actif.
- Déplacer la commande pip du conteneur vers un commentaire Bash adjacent à
  l'appel `su`, puis la retirer de sa chaîne `apk ... && exec setpriv ...`.
  Un commentaire placé dans une continuation de cette chaîne risquerait
  d'interrompre la commande de lancement.
- Remplacer les attentes d'installation des tests par des assertions
  comportementales : aucun appel pip/métadonnées/import, aucun message
  Psycopg, profil et liens préservés, paquets existants inchangés même si une
  version plus récente est disponible ou si les contrôles simulés échoueraient.
- Tester la commande OpenCode avec `id`, `stat`, `ensure_docker_image` et `su`
  simulés, puis sa chaîne interne avec des outils simulés. Aucun Docker réel.
- Remplacer les exigences de gestion automatique par la responsabilité des
  projets, la préservation de Python et le lancement sans Psycopg.

## Risks / Trade-offs

Un projet ou un conteneur neuf qui dépend de Psycopg doit le fournir lui-même.
Les installations existantes restent présentes mais ne sont plus actualisées
par ces chemins du DIU. La préparation Python conserve ses propres effets
existants ; ce changement ne garantit pas la conservation des paquets lors
d'un remplacement du préfixe Python par son mécanisme historique.

## Migration Plan

Aucune migration ni désinstallation. Après validation stricte du change,
commenter les opérations, adapter les tests et la documentation, valider puis
archiver ce seul change et vérifier la spécification canonique synchronisée.
Le repli nécessite la réactivation des commandes conservées et une nouvelle
décision OpenSpec cohérente ; aucun repli automatique n'est ajouté.

## Validation

`bash -n root-install-debian.sh`, ShellCheck global et ciblé sur les blocs,
compilation syntaxique Python, tests isolés `test_devops_python.py`, régression
du relevé des dépendances `test_projects_template_devops.py` et du lancement
shell `test_root_shellcheck.py`, validation OpenSpec stricte avant code et
avant/après archivage. Les cadrages généraux restent applicables ; seule la
section Psycopg de `TECHNICAL.md` devient inexacte et doit être actualisée.

# Revue du correctif d'authentification 0600/0660

## Périmètre et décision

Session SCM directe, sans agent délégué ni pilotage OpenCode/CAB. Le développeur
a validé le périmètre proposé par « Je valide » le 26 octobre 2026. Aucune
lecture d'identifiant réel, modification de mode d'identifiants réels,
installation ou publication de tools-codex n'est incluse.

Les six lecteurs des trois bibliothèques acceptent exactement 600 et 660.
Les autres modes restent refusés avant lecture. Aucun nouveau helper,
paramètre ou contrôle d'identité système n'est ajouté. La création initiale
en 600 et les protections des secrets temporaires restent inchangées.

## Critères et preuves locales

- Six lecteurs : fichiers synthétiques 600/660 acceptés sans changement de
  contenu, mtime ou ctime ; douze autres modes refusés avant lecture.
- Fichiers absents/vides et échec de stat : rejet explicite, sans divulgation.
- Push/fetch des trois providers : 24 combinaisons (600/600, 660/660,
  600/660 et 660/600), avec le vrai cœur git_with_token et transport simulé.
- Clonage des providers existants GitHub/GitLab et réutilisation par leur
  initialisation : identifiants en 660 acceptés sans réécriture.
- API Forgejo/GitHub : configuration curl et réponse en 600, secrets hors
  des arguments, nettoyage en succès et sur erreur réseau simulée.
- Registre GitLab : les vrais lecteurs alimentent le parcours Docker ;
  transport simulé, token via stdin, configuration privée nettoyée après
  succès et échec. Aucune connexion réseau ni opération Docker réelle.
- Cœur Git : credentials en 600, répertoire et askpass en 700, nettoyage
  après succès et conservation du code 73 en échec simulé.

Le clonage Forgejo n'est pas implémenté dans ce correctif. Les fonctions de
release réutilisent les lecteurs corrigés ; ces fixtures ne constituent pas
une publication distante ou une qualification d'authentifiants réels.

## Contrôles et limites

- `bash -n` des trois bibliothèques : exécuté et réussi.
- Syntaxe des cinq scripts de fixtures : exécutée et réussie.
- `shellcheck lib/forgejo-auth.sh lib/github-auth.sh lib/gitlab-auth.sh` :
  exécuté, code 1. Forgejo/GitHub sans diagnostic ; quatre diagnostics GitLab
  préexistants (SC2295 ligne 30, SC2034 lignes 44–46). Une comparaison entre
  sources antérieures reconstituées en mémoire et sources actuelles prouve
  leur identité exacte ; aucun diagnostic ajouté et aucune exclusion de lint.
- Compilation Python et suite dédiée : exécutées et réussies (14 tests).
- Premier lancement `unittest discover -s tests -p 'test_projects*.py'` :
  283 tests, un échec et deux ignorés. Le test existant
  test_git_local_update_preserves_mode_without_asking tente d'écrire dans
  /etc/gitconfig sans droits ; il ne charge aucune bibliothèque modifiée.
  Rejoué seul avec GIT_CONFIG_SYSTEM redirigé vers une fixture temporaire
  dans le projet : réussi. Aucun changement de test ou de configuration hôte.
- Validation stricte du change : exécutée et réussie sans diagnostic.
- OpenSpec global strict initial : 68 éléments, 46 valides et 22 en échec.
  Avec le change avant archivage : 69 éléments, 47 valides et les mêmes
  22 en échec, diagnostics intégralement identiques. Ils comprennent les
  deux changes Forgejo dont les deltas omettent deux scénarios du canon.
  Ces écarts hors périmètre ne sont pas corrigés ou masqués.

## Matrice documentaire

| Document | État et preuve |
| --- | --- |
| Projet réel | Trois bibliothèques modifiées ; tests confinés au projet et transports simulés. Aucun déploiement. |
| AGENTS.md | Inchangé : sections 6, 10, 13 et 21 applicables, sans règle fixant 600 pour les fichiers fournisseurs. |
| PROJECT.md | Inchangé : architecture modulaire et évolution OpenSpec conservées. SCM autorise la session directe. |
| TECHNICAL.md | Mis à jour : Authentification distante / Fichiers d'identifiants décrit 600/660 et les protections temporaires. |
| BUILD.md | Inchangé : construction du paquet hors périmètre ; aucune nouvelle dépendance ou étape de build. |
| DEVOPS.md | Inchangé par la session : chemins Python/OpenSpec utilisés ; modification préexistante conservée. |
| README.md | Mis à jour : règles publiques 0600/0660, conservation des fichiers et partage de groupe. |
| CHANGELOG.md | Mis à jour : entrée Unreleased sans version ni date de publication inventée. |
| openspec/specs/ | Cinq deltas préparés, validation stricte réussie ; synchronisation à l'archivage de ce seul change. |
| Change Forgejo voisin | Seule phrase de refus des permissions alignée ; ni correction des autres écarts ni archivage. |

## État de finalisation

Validation finale du périmètre réalisée : campagne combinée de 297 tests en
111,256 secondes, 295 réussis, zéro échec et deux ignorés. Configuration Git
système redirigée par GIT_CONFIG_SYSTEM vers un fichier de fixture temporaire
sous le projet ; aucune modification de /etc/gitconfig. Les deux tests ignorés
concernent le binaire Go réel non déclaré dans le PATH de test (DIU_TEST_GO
absent), hors du comportement modifié.

Commande de la campagne : Python DevOps avec `-B`, unittest.TestLoader.discover
sur `test_projects*.py` et `test_provider_credential_permissions.py`, regroupés
dans une même TestSuite ; ressources temporaires nettoyées à la sortie.
La première suite non isolée reste tracée comme échec initial, puis résolue
par l'isolation du test, sans changement de sources ni d'attente.

OpenSpec global standard avant archive : 69 éléments, 67 valides et les deux
changes Forgejo préexistants en échec. Strict : 22 éléments préexistants en
échec, aucune régression ; les diagnostics ont été comparés en JSON. La suite
complète du dépôt, les publications réelles et les tests Docker/LXC réels ne
sont pas exécutés : validations projets et transports simulés retenus.

Critères d'acceptation du correctif satisfaits ; les cinq tâches sont cochées
sur ces preuves. L'archivage et les statistiques constituent l'étape suivante,
puis le commit local et les publications conditionnelles SCM. Ce constat
ne prouve ni installation en production ni publication distante.

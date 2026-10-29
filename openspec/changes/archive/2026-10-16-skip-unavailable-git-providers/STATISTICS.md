# STATISTIQUES — Fournisseurs Git indisponibles

## 1. Identification et périmètre

Date : 16 octobre 2026, Europe/Paris. Change :
`skip-unavailable-git-providers`. Archive :
`2026-10-16-skip-unavailable-git-providers`.

Session SCM directe. Périmètre : pushes Git Forgejo/GitLab/GitHub, opérations
API/fetch nécessaires, poursuite CI/CD, parcours Forgejo groupé, tests,
documentation, spécifications et archivage ciblé. Les releases lancées
directement et les clonages conservent leur gestion d'erreur.

Aucun commit, push, appel API réel, build Docker, déploiement ou installation
système n'est exécuté. Aucun état Git ni fichier sensible réel n'est consulté.
Les tokens, mots de passe, configurations et outils des tests sont factices.
Aucune compétence statistique de pilotage, aucun agent délégué, OpenCode/CAB
ou sonde de pilotage ne sont utilisés.

## 2. Durées et mesures disponibles

Référence SHA-256 (UTC) : 2026-10-16T06:03:44.118346+00:00.
Contrôle final : 2026-10-16T08:23:28.379354+02:00, Europe/Paris.
Intervalle observé : 1184.261 s, distinct de la durée de la conversation.
Somme des durées unittest : 33,712 s.

Tokens, coût, compte exhaustif des messages/outils et durées des agents : N/A,
aucune télémétrie de pilotage n'est activée pour SCM. Statistiques Git de
lignes : N/A, aucune inspection Git. Agents délégués : 0.
Paquets système installés par la session : 0.

## 3. Fichiers et cohérence documentaire

Vingt-deux références préexistantes sont suivies par SHA-256 :
douze modifiées dans le périmètre, une modifiée en parallèle et préservée,
neuf identiques. Treize fichiers nouveaux sont livrés : un module de tests,
une spécification principale et onze fichiers dans l'archive. Dix fichiers
du change sont créés puis déplacés ; ces catégories ne s'additionnent pas.

Fichiers préexistants modifiés dans le périmètre :

- `modules/projects/git.sh` : contexte privé de push, classification Git/curl,
  résultat public non bloquant, statut CI/CD et parcours Forgejo groupé.
- `lib/forgejo-auth.sh` : transport contextualisé, statuts HTTP de vérification,
  authentification initiale et création de token.
- `lib/github-auth.sh` : transport et qualification des réponses API.
- `TECHNICAL.md`, `README.md`, `CHANGELOG.md` : contrat et limites.
- `openspec/specs/git-auth/spec.md`.
- `openspec/specs/projects-cicd/spec.md`.
- `openspec/specs/implement-projects-forgejo-push/spec.md`.
- `openspec/specs/implement-projects-gitlab-push/spec.md`.
- `openspec/specs/implement-projects-github-push/spec.md`.
- `openspec/specs/projects-forgejo-push-all/spec.md`.

Nouveaux fichiers hors archive :
`tests/test_projects_provider_unavailable.py` et
`openspec/specs/git-provider-availability/spec.md`.

L'archive conserve `proposal.md`, `design.md`, `tasks.md`, sept deltas
`specs/*/spec.md` et ce rapport. Les copies et artefacts temporaires
régénérables de qualification ont été nettoyés avant archivage.

| Élément de la matrice SCM | État et preuve |
|---|---|
| Projet réel | Pannes reconnues non bloquantes ; erreurs réelles conservées ; tests de branche/tag/API/fetch, poursuite et nettoyage réussis. |
| AGENTS.md | Inchangé, empreinte identique ; règles et autorisations conservées. |
| PROJECT.md | Inchangé, empreinte identique ; architecture, fournisseurs et objectifs préservés. |
| TECHNICAL.md | Mis à jour, section « Indisponibilité pendant une publication Git ». |
| BUILD.md | Inchangé, empreinte identique ; packaging Debian hors correction. |
| DEVOPS.md | Modification parallèle conservée sans écriture par la session : relevé passé de 05:51:15Z à 06:11:02Z et OpenCode détecté en 1.19.2 au lieu d'absent. Aucun lancement ni installation OpenCode par la session. |
| README.md | Mis à jour : résultat zéro, publication non confirmée, poursuite, releases ignorées et erreurs bloquantes. |
| CHANGELOG.md | Entrée Unreleased ajoutée, sans version ni publication inventée. |
| openspec/specs/ | Sept capacités synchronisées ; 43 exigences et 81 scénarios au total ; corps normatifs identiques aux versions prospectives qualifiées. |

Les neuf références identiques sont `AGENTS.md`, `PROJECT.md`, `BUILD.md`,
`PROMPTS/SCM.md`, `openspec/config.yaml`, `lib/gitlab-auth.sh`,
`tests/test_projects.py`, `tests/test_rid_help.py` et
`root-install-debian.sh`. La bibliothèque GitLab n'a pas besoin d'une
modification propre : elle utilise déjà le cœur Git commun.
Les autres changes actifs ne sont pas traités.

## 4. Tests et vérifications

| Exécution unittest | Méthodes | Réussites | Échecs | Erreurs | Durée s |
|---|---:|---:|---:|---:|---:|
| Indisponibilités initiales | 13 | 13 | 0 | 0 | 5,748 |
| Aide et publications existantes | 56 | 56 | 0 | 0 | 1,457 |
| Indisponibilités enrichies | 16 | 16 | 0 | 0 | 8,539 |
| CI/CD et releases existantes | 8 | 8 | 0 | 0 | 0,584 |
| Indisponibilités après qualification des délais | 16 | 16 | 0 | 0 | 7,143 |
| Indisponibilités finales, bootstrap compris | 17 | 17 | 0 | 0 | 8,578 |
| Aide et publications finales | 56 | 56 | 0 | 0 | 1,663 |
| Total, répétitions incluses | 182 | 182 | 0 | 0 | 33,712 |

Résultat final : **81 méthodes distinctes réussies**, dont 17 nouvelles
méthodes paramétrées, 56 existantes d'aide/publication et huit existantes de
CI/CD/releases. Les sous-tests ne sont pas additionnés aux méthodes.

Commandes exécutées avec un TMPDIR de validation sous le dépôt et
`PYTHONDONTWRITEBYTECODE=1` :

- `python3 -m unittest discover -s tests -p test_projects_provider_unavailable.py -v` :
  exécutée et réussie.
- `python3 -m unittest discover -s tests -p test_rid_help.py` :
  exécutée et réussie.
- `python3 -m unittest discover -s tests -p test_projects.py -k cicd -k github_release -k gitlab_docker -v` :
  exécutée et réussie.

Couverture : DNS, proxy DNS, connexion impossible, timeout, résolution trop
lente, transfert trop lent, HTTP 502/503/504 ; API, vérification des credentials
Forgejo, initialisation Forgejo, fetch, branche et tag ; poursuite des autres
fournisseurs, build local, releases ignorées, échec réel ultérieur, parcours
groupé, nettoyage et statut remis à zéro. Authentification, TLS, rejet,
message distant ambigu et 128 générique restent bloquants.
Les fichiers de configuration fixtures et les identifiants factices ne sont
ni modifiés par la qualification des pushes ordinaires ni divulgués.
Un Git hors contexte conserve son code 128 et ses diagnostics précédents.

Autres validations :

- `bash -n` sur les trois fichiers Bash modifiés : exécutée et réussie.
- Compilation Python du nouveau test par `py_compile.compile(...,
  doraise=True)`, dans un temporaire nettoyé : exécutée et réussie.
- ShellCheck complet : exécuté et échoué uniquement sur SC2034, SC2269,
  SC2086 historiques du module Git. Comparaison structurée des codes,
  niveaux et messages avec les copies initiales : identique. Les deux
  bibliothèques modifiées n'ont aucun diagnostic. Aucun nouveau diagnostic.
- UTF-8/LF, empreintes et périmètre : exécutés et réussis après qualification
  de la modification parallèle de DEVOPS.md ; le premier contrôle strict
  du périmètre s'était arrêté sur cette modification non produite par la session.
- Validation stricte du change : exécutée et réussie avant code et avant archive.
- Validation prospective des sept capacités, comparée aux six versions
  initiales : cinq réussites et deux avertissements de longueur hérités,
  dans l'exigence « identifiants Forgejo » et la sélection des projets de
  `forgejo push all`. Leurs corps sont inchangés ; aucun nouvel avertissement.
  Les exigences GitHub et CI/CD modifiées sont désormais sous la limite.
- Validation stricte après synchronisation : cinq capacités réussies et les
  deux mêmes avertissements hérités. Le premier contrôle de la nouvelle
  capacité avait détecté le Purpose provisoire généré par l'outil ; son objet
  a été rédigé dans la spécification principale puis validé strictement.
- Publication réelle, clonage réel, build Docker et mise à jour du DIU installé :
  non exécutés, hors périmètre.

Un premier patch documentaire s'est arrêté sur un contexte différent dans
TECHNICAL.md ; aucun fichier n'avait été modifié par ce patch. Il a été repris
sur le contexte effectivement observé. Aucun test n'a été affaibli ni ignoré
pour obtenir une réussite.

## 5. Résultats et archivage

Une indisponibilité reconnue donne « serveur indisponible — publication non
confirmée, reprise nécessaire », sans erreur DIU et avec code public zéro.
`git_with_token` conserve le code Git original. Le résumé CI/CD indique
« terminé avec indisponibilités », poursuit les fournisseurs disponibles et
le build activé, puis ignore les releases concernées.

Un contexte privé transmet le signal au travers des sous-shells API.
Les diagnostics natifs sont classés de façon restrictive ; un code 128 seul
ou un texte préfixé `remote:` ne suffit pas. Les invites interactives ne sont
pas redirigées. Le contexte et les temporaires sont nettoyés après les appels ;
les signaux HUP/INT/TERM disposent également d'un nettoyage du contexte.
Les appels curl contextualisés sont bornés à 10 s de connexion et 30 s au
total, sans sonde préalable ni retry automatique.

Archivage officiel exécuté une seule fois sous le compte devops :

`/home/devops/.local/npm/bin/openspec archive skip-unavailable-git-providers --json --yes`

Code de sortie : 0. Réponse : `specsUpdated=true`, sept exigences ajoutées,
cinq modifiées, zéro supprimée et zéro renommée. Sept tâches cochées.
Les sept ensembles de corps normatifs synchronisés correspondent aux versions
prospectives qualifiées. Le Purpose finalisé est une métadonnée documentaire ;
aucun second archivage n'est exécuté.

Le présent rapport comporte six sections. Les totaux, UTF-8/LF, les tâches,
la cohérence des deltas et les fichiers finaux sont contrôlés à la clôture.

## 6. Limites et suites

Une connexion perdue pendant un tag peut laisser la branche déjà publiée.
Le résultat reste non confirmé ; aucune annulation automatique n'est tentée.
Une reprise est nécessaire pour achever la publication.

Une panne non reconnue reste une erreur explicite. En particulier, le code
128 n'est jamais ignoré globalement. Les droits des comptes et la disponibilité
des services réels ne sont pas qualifiés par les fixtures.
Clonages et releases directes gardent leur contrat antérieur.

Les trois diagnostics ShellCheck et les deux avertissements OpenSpec hérités
restent hors correction et sont explicitement signalés. Les suites générales
sans rapport avec le flux de publication ne sont pas relancées. Le libellé
Docker initial d'un résumé interrompu n'est pas corrigé ici.
Le DIU installé n'est pas mis à jour et aucune publication réelle n'est faite.

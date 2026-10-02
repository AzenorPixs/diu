# Context

Le bloc `ENV_DOCKER=1` prépare déjà `ENV_DOCKER_USER`. DevOps dispose d'une
génération isolée et testée ; sa politique doit être préservée.

# Decisions

- Extraire le mécanisme dans `configure_environment_sudoers`, limité aux
  scopes fixes `devops` et `docker`. Un autre scope est refusé avant toute
  écriture. Conserver `configure_devops_sudoers` et ajouter le point d'appel
  `configure_docker_sudoers` ; leurs chemins internes permettent les tests
  isolés sans nouvelle variable de configuration publique.
- Conserver la sélection locale fondée sur UID_MIN/UID_MAX et un shell
  existant et exécutable, avec les mêmes exclusions root, nologin, false,
  ENV_DEVOPS_USER, ENV_DOCKER_USER et ENV_IA_USER pour les deux scopes.
  L'exclusion DevOps utilise toujours la vraie configuration DevOps,
  indépendamment du compte cible de la génération Docker.
- Conserver le contenu DevOps à l'identique. Docker utilise un candidat
  `.diu-docker.XXXXXX`, un en-tête Docker et `99-diu-docker`. Les deux fragments
  peuvent être générés indépendamment sans écrasement mutuel.
- Réutiliser la validation `visudo -cf`, root:root, 0440 et le remplacement
  atomique dans le même répertoire. Un échec préserve le fragment précédent
  et nettoie le candidat avec un diagnostic et un retour non nul.
- Appeler Docker immédiatement avant le fi final du bloc ENV_DOCKER. Un bloc
  désactivé ou un compte cible absent ne révoque pas de règles existantes.

# Risks and Rollback

Les personnes sélectionnées obtiennent les droits du compte Docker. La notion
de compte humain demeure une convention UID/shell : d'autres comptes techniques
non configurés peuvent la satisfaire. Une règle sudoers ultérieure peut
influer sur les accès effectifs. Le fragment précédent est préservé sur erreur
avant publication ; après publication réussie, une restauration relève d'une
intervention administrateur distincte. Aucune installation réelle ne sera
exécutée par cette session.

# Validation

Exécuter bash -n, ShellCheck, les tests de régression du monolithe et les tests
sudoers des deux scopes. Les fixtures passwd/login.defs et fragments restent
dans des répertoires temporaires du dépôt, nettoyés après les tests. Les
commandes privilégiées sont simulées ; le vrai visudo disponible contrôle les
candidats isolés. Vérifier notamment sélection, activation, compte absent,
idempotence, refus de noms invalides, erreurs de publication et coexistence.
Valider OpenSpec strictement et comparer les exigences synchronisées avant
de déclarer le cycle terminé.

# Observed Validation — 2026-10-02

- `bash -n root-install-debian.sh` : réussi.
- ShellCheck : réussi, zéro diagnostic. Le test de régression exécute aussi
  `shellcheck root-install-debian.sh` directement avec succès.
- `python3 -B -m unittest discover -s tests -p test_devops_sudoers.py -v` :
  15 tests réussis, aucun ignoré ; contenu et comportement DevOps préservés.
- `python3 -B -m unittest discover -s tests -p test_docker_sudoers.py -v` :
  19 tests réussis, aucun ignoré ; compte cible variable, coexistence dans les
  deux ordres, conservation DevOps sur erreur Docker et refus de scope inconnu.
- `python3 -B -m unittest discover -s tests -p test_root_shellcheck.py -v` :
  9 tests de régression réussis.
- Le vrai `/usr/sbin/visudo` a validé les fragments isolés et rejeté un
  candidat volontairement invalide. Chown est simulé avec contrôle de ses
  arguments ; chmod et le remplacement agissent seulement dans les fixtures.
- `openspec validate allow-human-sudo-docker --strict` : réussi, avant
  implémentation et après revue du code et de la documentation.
- Relecture ciblée : appel Docker immédiatement avant le fi final, appel
  DevOps conservé et documentation alignée. Les cadrages PROJECT.md, BUILD.md,
  DEVOPS.md, README.md et AGENTS.md restent applicables sans modification.

Une première tentative d'édition a été refusée par le contexte du document,
qui comporte désormais une section Python DevOps. Cette tentative n'a modifié
aucun fichier ; la reprise ciblée a préservé cette section et ajouté uniquement
la documentation Docker. Cette section hors périmètre a été conservée.

Aucun fichier système réel, compte, configuration PAM ou état Docker n'a été
modifié pendant les essais. Aucune opération Git n'a été exécutée. Les droits
effectifs avec l'ensemble de la politique sudoers restent un contrôle
administrateur après exécution du DIU sur l'installation concernée.

L'archivage a réussi avec
`openspec archive allow-human-sudo-docker --json --yes` : sept exigences
ajoutées à `openspec/specs/docker-sudoers/spec.md` et change déplacé vers
`openspec/changes/archive/2026-10-02-allow-human-sudo-docker`. Le texte Purpose
provisoire généré par OpenSpec a été remplacé par l'objectif réel.

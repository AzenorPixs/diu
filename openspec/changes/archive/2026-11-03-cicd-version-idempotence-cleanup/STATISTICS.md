# Statistiques — cicd-version-idempotence-cleanup

## Statistiques générales et décisions

- Session SCM directe du 2026-11-03, version locale 1.0.7, code non attribué.
- Priorité aux versions stables dans DIU sans epoch Debian ; reprises de publication sans remplacement d'asset ou déplacement de tag.
- Durée totale et tokens : N/A, mesures exhaustives indisponibles.

## Types de messages et d'outils

- Exécution directe par Codex, avec coordination entre chats DIU autorisée ; aucun agent de codage délégué.
- Décompte exhaustif des messages et outils : N/A, journal agrégé indisponible.

## Fichiers modifiés

- Modules de version, CI/CD, publication Debian et mise à jour DIU ; aides, documentation et tests associés.
- Huit spécifications synchronisées et change archivé ; cartographie et registre actualisés sans attribution de code. Le bloc de version du change actif `reconcile-diu-deb-packaging-contract` est mis en cohérence pour conserver les règles et le scénario synchronisés.
- PROJECT_VERSION mis à jour localement dans project.env, fichier exclu de Git. Volume de lignes : N/A.

## Commandes

- Suite globale avec le Python DevOps : 1 103 tests exécutés, dont 2 ignorés, sans échec ; 257,782 secondes. Les modifications finales ciblées de GitLab ont également été vérifiées par 32 tests ciblés réussis.
- Syntaxe Bash, ShellCheck du périmètre, compilation Python, validation OpenSpec stricte du change et validation globale standard réussies ; après archivage et mise en cohérence, 119 éléments OpenSpec valides.
- Le contrôle OpenSpec strict sur tout le dépôt signale 47 spécifications historiques hors du change avec avertissements préexistants.
- Total exhaustif des commandes : N/A, journal agrégé indisponible.

## Accès web

- Forgejo et GitHub : inventaire et nettoyage des versions 2026 autorisés, sans modification des branches ni des versions stables.
- Sauvegarde vérifiée : 216 tags locaux, métadonnées de 194 releases et 193 assets. Suppression vérifiée de 216 tags locaux, 208 tags et 194 releases Forgejo, 9 tags GitHub ; aucune release GitHub 2026.
- Sauvegarde privée hors Git : `output/version-cleanup-20261103-R1/`.

## Synthèse globale

Change validé et archivé. La construction et la publication des paquets de production restent à la charge du développeur. Les releases supprimées ne peuvent pas retrouver leurs identifiants ou compteurs initiaux lors d'une restauration.

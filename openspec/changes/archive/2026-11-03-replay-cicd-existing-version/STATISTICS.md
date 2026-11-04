# Statistiques — replay-cicd-existing-version

## Statistiques générales et décisions

- Session SCM directe du 2026-11-03, livraison locale 1.0.9, code non attribué.
- Un tag existant est rejoué depuis son commit isolé, sans intégrer les modifications locales ni ramener une branche distante en arrière.
- Sur décision de fonctionnement, la publication Docker est ignorée en rejeu tant que l'immutabilité du tag distant n'est pas vérifiée ; Debian reste indépendant.
- Durée totale et tokens : N/A, mesures exhaustives indisponibles.

## Types de messages et d'outils

- Exécution directe par Codex, sans délégation à un agent de codage.
- Décompte exhaustif des messages et outils : N/A, journal agrégé indisponible.

## Fichiers modifiés

- Orchestration Git, constructeur Docker, publications Debian Forgejo et GitHub, aides et tests associés.
- README, BUILD, TECHNICAL, CHANGELOG, Development Map et registre des codes ; quatre spécifications synchronisées et change archivé. Le delta actif Forgejo lié a été maintenu cohérent.
- PROJECT_VERSION mis à jour localement dans project.env, hors Git. Modifications préexistantes du projet comprises dans le commit demandé. Nombre de lignes : N/A.

## Commandes

- Suite globale avec le Python DevOps : 1 119 tests exécutés, dont 2 ignorés, sans échec, en 251,513 secondes. Les dernières modifications ont également été vérifiées par les tests ciblés.
- Dix tests ciblés de rejeu réussis, dont paquet Debian réel de fixture, contexte Docker sans identifiants, préservation de l'index, répétition et nettoyage sur interruption.
- Syntaxe Bash, ShellCheck du périmètre, compilation Python et validation OpenSpec : change et quatre spécifications stricts, 119 éléments valides en contrôle global standard.
- Décompte exhaustif des commandes : N/A, journal agrégé indisponible.

## Accès web

- Consultation des spécifications OCI Distribution et de la documentation GitLab sur l'immutabilité des tags. Aucune publication d'artefact de production effectuée par cette session.

## Synthèse globale

Rejeu isolé, contrôles et documentation validés ; change archivé. Les registres Docker non vérifiés ne sont pas publiés pendant le rejeu. La construction et la publication des paquets de production restent à la charge du développeur.

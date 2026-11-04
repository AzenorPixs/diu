# Statistiques — reconcile-cicd-git-publication

## Statistiques générales et décisions

Session SCM directe du 2026-11-04 ; change ouvert, publication et archivage en attente. Priorité aux fichiers versionnés locaux lors des conflits ; remplacement du tag distant sous lease sans sauvegarde. Les commits sont réservés au développeur. Durée, tokens et coût : N/A, mesures non disponibles.

## Types de messages et d'outils

Comptages exhaustifs par type : N/A, mesures non disponibles. Aucun pilotage OpenCode ni CAB.

## Fichiers modifiés

Code Git et releases, tests, documentation, change OpenSpec, cartographie et registre de codes. Le nombre final de fichiers est à établir à la clôture du change.

## Commandes

Suite globale : 1 182 tests exécutés dont 2 ignorés avec Python 3.14.10. Quatre tests ciblés de fusion et de lease réussis après le complément de test, syntaxe Bash et ShellCheck avec exclusion SC1091 réussis, validation stricte OpenSpec réussie. Une première suite avec Python 3.13 a échoué sur les fixtures venv et deux attentes de messages corrigées.

## Accès web

Lecture par le connecteur GitHub des commits et branches ; aucune écriture distante. Nombre exhaustif d'appels : N/A, mesure non collectée.

## Synthèse globale

Implémentation et contrôles sur fixtures réalisés ; synchronisation des spécifications, publication de `1.2.2` et archivage restent en attente selon [BLOCKERS.md](BLOCKERS.md). Aucun commit créé.

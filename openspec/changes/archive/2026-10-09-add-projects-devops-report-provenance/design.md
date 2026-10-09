## Context

projects_template_devops_render produit le document et projects_template_devops conserve une écriture temporaire puis un remplacement contrôlé. Les tests isolent outils, PostgreSQL, domicile DevOps et projets sous la racine du dépôt. SYSTEM_DEBIAN_ENVIRONNEMENT possède déjà un vocabulaire fermé.

## Goals / Non-Goals

Objectif : contextualiser l'inventaire 0.3. Hors périmètre : nouveau détecteur, qualification réelle, installation, secrets/configurations réelles, génération dans d'autres projets, Git et reprise d'autres changes.

## Decisions

1. Capturer le début avant les sondes avec le date hôte trouvé par le résolveur existant, date -u +%Y-%m-%dT%H:%M:%SZ sous timeout 15s. Vérifier forme UTC et bornes ; refuser sans écho toute absence, erreur, sortie mal formée ou expiration. Ce début ne prouve ni synchronisation ni simultanéité.
2. Réutiliser la classification SYSTEM_DEBIAN_ENVIRONNEMENT. Accepter exactement DOCKER, LXC, PHYSICAL, PROXMOX, VM et UNSET ; toute autre valeur devient UNSET sans écho ni interprétation. Ne pas utiliser PROJECT_DOCKERED ni relancer la détection.
3. Insérer métadonnées et légende après Version : 0.3, sans titre supplémentaire. Conserver rubriques, sondes et remplacement.
4. Distinguer inventaire des outils indiqués et qualification fonctionnelle ; la version documentaire n'est pas une version logicielle DIU.
5. Préserver l'idempotence technique hors horodatage. Figer l'horloge des comparaisons identiques et vérifier séparément deux instants distincts.
6. L'ancien document reste intact si la capture échoue. Le manifeste Python conditionnel peut déjà avoir été créé ; ce comportement existant reste inchangé.
7. Garder toutes les garanties des exigences modifiées ; référencer explicitement le scénario détaillé des rubriques pour des exigences courtes et validables.

## Risks / Trade-offs

L'horodatage fera varier les comparaisons du fichier complet. La classification affichée est celle fournie par DIU, sans nouvelle détection ni topologie du projet. Date indisponible bloque le relevé sans inventer de date. Les diagnostics globaux OpenSpec préexistants seront distingués des résultats ciblés.

## Validation

Valider le change avant code. Tester UTC indépendant du fuseau, capture unique avant sondes, contextes reconnus/hostiles, refus et ancien document intact, réexécution et trois parcours. Exécuter bash -n, ShellCheck, py_compile et régressions DevOps/OpenSpec/all/general-update. Contrôler UTF-8/LF, empreintes et diagnostics globaux avant/après.

## Migration Plan

Aucune migration ni retouche manuelle d'un DEVOPS.md réel. Prochaine génération normale : 0.3. Après les preuves, terminer les tâches, synchroniser le seul canon, archiver le change et produire le rapport requis. Aucun Git, déploiement ou logiciel installé.

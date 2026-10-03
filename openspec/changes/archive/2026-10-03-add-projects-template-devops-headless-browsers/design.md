## Context

projects_template_devops_render, dans modules/projects/template.sh, produit
actuellement un document terminé par la rubrique Python - Gestionnaire de paquets.
projects_template_devops_host_binary résout les exécutables dans un PATH système
fixe, indépendant du PATH DevOps. projects_template_devops_version dispose d'un
contexte host, d'un délai de 15 secondes et de diagnostics fixes pour les absences,
les échecs et les versions non reconnues.

## Goals / Non-Goals

Ajouter une seule section finale, actualisée avec le document, qui indique les
versions et les chemins de Chromium et Firefox présents sur l'hôte de génération.
Préserver les rubriques et protections existantes et la version documentaire 0.2.

L'exécution de tests navigateur, l'installation de logiciels, les caches de
frameworks de test, les conteneurs distants et les profils utilisateur sont hors périmètre.

## Decisions

Réutiliser le résolveur hôte et la sonde de version existants. Pour chaque famille,
retenir le premier exécutable disponible : chromium puis chromium-browser ;
firefox puis firefox-esr. Une sonde échouée conserve le chemin détecté et affiche
son diagnostic ; elle ne provoque pas de recherche d'une version de remplacement.

Ajouter le titre de niveau 1 « Tests navigateurs extérieurs en mode headless »,
puis les sous-titres de niveau 2 « Chromium » et « Firefox ». Chaque sous-rubrique
place la version avant le chemin, puis indique « Mode headless : --headless ».
Préciser dans la section que la détection ne vérifie pas le fonctionnement headless.

Les sondes utilisent --version et ne chargent pas de page. Les indisponibilités
restent documentaires et ne rendent pas la génération globale erronée.

## Risks / Trade-offs

Un navigateur peut être détecté et sa version lisible sans pouvoir démarrer en
headless sous les permissions ou bibliothèques présentes. Le document précise
cette limite. Les installations hors du PATH système retenu restent non détectées,
conformément à la séparation existante entre outils hôte et DevOps.

La recherche respecte un ordre fixe afin de produire un contenu déterministe.
Les chemins contenant des espaces restent des arguments uniques.

## Validation

Les tests isolent les exécutables hôte et contrôlent l'ordre documentaire,
les versions et chemins, les variantes de noms, la priorité des noms canoniques,
l'absence, la sonde échouée et la version non reconnue. Les tests d'actualisation
contrôlent le remplacement des anciennes versions, l'absence de doublons,
l'idempotence et la conservation des droits. Les tests existants vérifient les
générations groupées, la création finale et la préservation du document en cas
d'échec d'écriture. Le délai reste celui de la sonde commune déjà couverte.

Exécuter bash -n, ShellCheck, python3 -m py_compile pour le test modifié,
les suites test_projects_template_devops.py, test_projects_template_all.py,
test_projects_general_update.py et test_rid_help.py, et les validations OpenSpec
strictes avant puis après archivage. Les tests utilisent uniquement les fixtures
temporaires dans la racine DIU ; aucun projet utilisateur n'est régénéré.

## Migration / Rollback

Aucune migration ni incompatibilité de commande. Le document suivant est enrichi
lors de sa génération habituelle. La publication atomique existante conserve le
document précédent si la préparation ou l'écriture échoue. Aucun repli automatique
de code n'est prévu ; une réversion éventuelle reste à la charge du développeur.

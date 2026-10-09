## Context

projects_template_devops_dependencies interroge actuellement les métadonnées du Python DevOps et le document 0.3 indique seulement ce contexte. Le correctif doit mesurer les installations des venv du projet avant le repli global, avec leur provenance, sans importer leurs paquets.

## Goals / Non-Goals

Inventaire exact des distributions déclarées et de leurs emplacements. Hors périmètre : installation, résolution de contraintes, activation shell, modification des venv, import applicatif, génération dans un projet réel, Git, déploiement et reprise d'autres changes.

## Decisions

1. Conserver l'API Bash et les rubriques d'outillage Python/pip DevOps. Passer le format documentaire et les attentes à 0.4 ; modifier la légende des dépendances.
2. Lire uniquement [project].dependencies avec le Python DevOps disponible, sinon /usr/bin/python3. Ce dernier est un analyseur, jamais une source de paquets de repli. Conserver les diagnostics de manifeste et l'occultation des références directes.
3. Rechercher pyvenv.cfg dans les dossiers ordinaires du projet, sans liens de dossiers, caches, sorties ni ressources d'outillage. Arrêter la descente à chaque venv. Priorité .venv, venv, env à la racine, puis chemins relatifs triés.
4. Exécuter bin/python3 puis bin/python sous le compte DevOps, en conservant l'entrée du venv même si elle est symbolique. Utiliser -I -B -S et les répertoires site-packages calculés pour ce préfixe explicite : aucune activation, .pth ou import de dépendance.
5. Lire Name, Version et locate_file depuis importlib.metadata. Normaliser les noms de distributions, refuser métadonnées ambiguës et réponses mal formées sans les publier. Ne pas résoudre les contraintes ni déduire un nom de module depuis la distribution.
6. Borne par sonde 3 secondes et budget recherche/venv 12 secondes, sous la borne utilisateur existante de 15 secondes. Signaler toute recherche incomplète ; ne jamais la confondre avec une absence.
7. Préférer chaque distribution observée localement ; à défaut, consulter le Python DevOps en repli explicite. Afficher le chemin de l'interpréteur et l'installation issue des métadonnées. Aucun paquet système n'est substitué au DevOps absent.
8. Chaque ligne conserve sa propre provenance ; plusieurs environnements ne prouvent pas une composition unique. Les versions observées sont rapportées sans qualification fonctionnelle.

## Risks / Trade-offs

Les chemins supplémentaires et la version 0.4 font évoluer le document. Les sondes de venv utilisent leurs interpréteurs sous le compte DevOps avec démarrage isolé. Les liens des interpréteurs usuels sont admis, les liens de dossiers ne sont pas parcourus. Des environnements brisés ou une recherche tronquée produisent non vérifiable ; le repli observé reste identifiable.

## Validation

Change strict avant code ; tests avec venv synthétiques sous la racine, distributions factices et absence d'effets .pth/paquets. Couvrir priorités, sous-dossiers, exclusion des caches/liens, chemins avec espaces, installation réelle par métadonnées, repli, absence de Python DevOps, erreurs et délais. Régressions existantes des quatre suites de modèles. bash -n, ShellCheck, py_compile, UTF-8/LF, diff sans Git, empreintes et contrôles OpenSpec ciblés/globaux.

## Migration Plan

Aucune migration des environnements ni retouche des documents réels. Prochaine génération avec ce code : 0.4. Après preuve des tâches, synchroniser le seul canon, archiver ce change et produire STATISTIQUES.md avec six sections et N/A motivé pour les mesures absentes.

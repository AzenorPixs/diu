## Context
Le monolithe contient des expansions non protégées, des scripts générés avec des dollars littéraux et des appels indirects aux bibliothèques chargées. ShellCheck ne dispose pas de la configuration privée locale.

## Goals / Non-Goals
Obtenir zéro diagnostic avec ShellCheck et conserver le comportement non concerné. Ne pas exécuter le parcours d'installation ni modifier de configuration réelle. Ne pas modifier globalement les règles ShellCheck.

## Decisions
Citer les scalaires ; conserver les listes sous forme de tableaux lorsque nécessaire. Utiliser $(...) sans modifier les filtres existants. Tester les sorties générées et les routes avec des commandes simulées. Transmettre le projet à launch_oc_shell et le conteneur fourni à docker_rootless_inspect. Préserver IPv6 et GATEWAY comme entrées historiques externes sans inventer de valeur. Les annotations locales ne couvrent que les imports privés ou contrôlés, les expansions volontairement différées et les fonctions invoquées indirectement, avec justification.

## Risks / Trade-offs
Les nombreuses corrections d'expansion peuvent modifier les arguments contenant espaces ou glob ; elles doivent préserver un argument scalaire et garder les listes explicites. Les redirections regroupées doivent préserver les données et leur ordre. Les sorties générées sont comparées sur des données contrôlées. Le parcours d'installation complet reste non exécuté car il modifie la machine.

## Migration Plan
Aucune migration de données ni nouvelle dépendance. Déployer le script corrigé ; aucune opération système pendant la validation. Archiver ce change après validation puis reprendre add-system-time-zone.

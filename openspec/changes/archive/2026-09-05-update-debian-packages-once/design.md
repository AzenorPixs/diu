# Design

Le moteur `software_deb update` conserve son parcours de validation : index
Debian isolés, contrôle d'origine et simulation du solveur. Il agrège ensuite
les cibles dans le tableau `targets` et appelle APT une seule fois avec
`--only-upgrade` et `--no-remove`. Les états normaux par paquet ne sont pas
affichés ; les erreurs d'origine ou de résolution restent explicites.

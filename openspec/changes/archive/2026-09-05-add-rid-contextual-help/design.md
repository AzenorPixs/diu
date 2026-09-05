# Conception

Le point d'entrée dispatchera `?` vers une fonction d'aide dédiée. Cette
fonction utilisera les mêmes classes et actions que le dispatch existant et
affichera uniquement les choix valides au niveau demandé. `diu ?` affichera
les premières sous-fonctions de `diu`, sans détailler leurs arguments.

Les descriptions seront statiques, en français, et limitées à une demi-ligne.
`help`, `--help` et `-h` resteront des alias de compatibilité vers l'aide
racine, mais la documentation montrera `?`.


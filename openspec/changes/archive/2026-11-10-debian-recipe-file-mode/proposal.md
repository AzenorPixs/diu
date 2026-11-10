# Mode de fichier dans les recettes Debian

## Pourquoi

Le constructeur copie les permissions des sources : un script non exécutable dans le dépôt produit un paquet dont le point d'entrée ne peut pas être exécuté.

## Changements

- Permettre à chaque copie de fichier régulier de déclarer un mode octal explicite dans la recette générique.
- Déclarer le mode 0755 du point d'entrée dans la recette DIU ; préserver les recettes sans mode.
- Vérifier les modes, les erreurs et le paquet produit avec des sources contrôlées.

## Capacités modifiées

- `projects-debian-build` : mode optionnel des fichiers copiés.

## Hors périmètre

Pas de changement du constructeur historique, des permissions des répertoires ou de l'installation système.

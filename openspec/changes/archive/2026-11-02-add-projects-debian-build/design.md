# Construction générique

## Contrat de recette

`build/debian-package.json` est un objet JSON de données publiques, lu par jq.
Champs obligatoires : package, architecture, maintainer, description, files.
Champs facultatifs : depends (tableau de chaînes), version (version Debian littérale).
files contient des objets source/destination : source relative au projet,
destination absolue dans le paquet. Les champs inconnus sont refusés.
Aucun hook shell n'est exécuté. Cette première version assemble des sources
préparées ; elle ne compile pas un projet et ne génère pas de scripts mainteneur.

Les identifiants, métadonnées et chemins sont validés avant les copies.
Les chemins contenant des traversées, composants vides ou caractères de contrôle,
les sources symboliques et leurs descendants symboliques sont refusés.
Les sources restent dans le projet ; les destinations restent dans le staging,
hors /DEBIAN. Les destinations ne se recouvrent pas. Une source ne peut inclure
la recette ni dist/. Les noms de caches, configurations privées et fichiers
temporaires reconnus par le contrôle historique sont également refusés.

PROJECT_DEBIAN_PACKAGE est extrait littéralement et isolément de project.env.
Les autres lignes sont ignorées sans exécution. Une clé absente ou vide désactive
la construction ; seuls Yes, YES et 1 l'activent. Les doublons et valeurs
nécessitant une interprétation sont des erreurs de configuration.

## Version et publication locale

Sans version explicite, appliquer la sélection historique des tags de HEAD,
avec retrait du préfixe v, refus des versions distinctes ou invalides et repli
sur l'heure locale uniquement en absence de Git ou de tag.
Copier les fichiers de travail, pas une extraction du commit.

Construire dans un répertoire temporaire du projet et déplacer le paquet
dans dist/ après succès. Remplacer le même nom et supprimer ensuite uniquement
les anciens fichiers de même package et architecture. Un échec de rotation
est signalé même si le nouveau paquet existe déjà. Nettoyer les temporaires
par trap, y compris lors d'une interruption.

## Compatibilité et repli

Le constructeur historique reste inchangé et permet le repli par projects deb.
La recette DIU produit les mêmes fichiers, modes, propriétaires et métadonnées,
à version identique. Les octets de l'archive peuvent différer par horodatage.
L'exécution réelle de rid utilise le moteur installé ; sa mise à jour sur la
machine n'est pas réalisée par cette session.

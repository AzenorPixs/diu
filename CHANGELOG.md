# Changelog

Toutes les évolutions significatives du Debian Installer Unified seront documentées dans ce fichier.

## Unreleased

- Ajout de `PROJECT_ORCHESTRATED_CODING=Yes|No` dans les variables des projets :
  question à la création et à la mise à jour, conservation de la valeur
  existante et défaut `No` en son absence. `Yes` déclare un codage piloté par
  un orchestrateur ; `No` un codage autonome. Lecture isolée et conservation
  dans la configuration historique du clonage, sans migration globale ni
  lancement automatique d'agent ou de service.

- Génération de `DEVOPS.md` au format `0.5` : inventaire JavaScript par
  manifeste et catégorie sous NPM, dépendances `.opencode/package.json`
  sous OpenCode, workspaces et verrous npm 2/3. Déclarations, versions
  verrouillées et installations locales sont distinguées avec leurs chemins ;
  la collecte reste passive, bornée et confinée au projet.
- Génération de `DEVOPS.md` au format `0.4` : dépendances recherchées dans les
  venv du projet avant le repli DevOps, avec priorité déterministe, provenance
  et chemins d'installation observés. Les sondes impossibles ne sont plus
  assimilées à une absence certaine ; aucun environnement n'est activé ni
  paquet importé ou installé pour cet inventaire.
- Génération de `DEVOPS.md` au format documentaire `0.3` avec provenance DIU,
  début du relevé UTC, classification du contexte et légende sur la portée
  des sondes. Le contenu technique reste stable hors horodatage ; une capture
  temporelle indisponible conserve le document existant.
- Restructuration initiale du projet DIU.

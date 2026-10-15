# Changelog

Toutes les évolutions significatives du Debian Installer Unified seront documentées dans ce fichier.

## Unreleased

- Arguments Docker publics optionnels par projet via `build/docker-build.args` :
  valeurs littérales transmises en tableau après validation complète, sans
  interprétation shell ni dépendance applicative. Refus des doublons, noms
  invalides, CR/NUL, chemins symboliques et fichiers hors limite ; diagnostics
  sans valeurs. Les projets sans fichier conservent leur comportement.

- Exclusion du `.git` racine du modèle lors de `rid projects create` pour
  éviter le transfert de son dépôt Git. Les autres fichiers cachés, dont
  `.gitignore`, et les règles de copie existantes sont conservés. Les `.git`
  imbriqués et les projets déjà créés ne sont pas concernés.

- Correction ShellCheck `SC2004` dans `project_env_set_variables` : indice de
  tableau arithmétique simplifié, sans changement des affectations de
  configuration ni des interfaces.

- Copie de `ORCHESTRATED_CODING.md` depuis le modèle uniquement pour
  `PROJECT_ORCHESTRATED_CODING=Yes`, à la création et à la synchronisation
  unitaire ou groupée. Le document est personnalisé ; pour `No` ou une
  variable absente ou vide, aucune copie ni suppression d'une destination
  existante. Une source requise absente ou un mode invalide provoque un échec
  avant la copie du modèle, sans migration ni activation de service.

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

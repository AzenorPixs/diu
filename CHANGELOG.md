# Changelog

Toutes les évolutions significatives du Debian Installer Unified seront documentées dans ce fichier.

## Unreleased

- Correction du push Forgejo après copie ou changement de dépôt : réalignement
  automatique des URL du remote configuré sur `project.env`, y compris une
  URL de push distincte. Le premier push vers un dépôt absent utilise une
  attente explicite d'absence de branche, indépendante des références de
  suivi héritées et protégée contre une création concurrente. Le fetch des
  dépôts existants, les tags sans forçage et GitLab/GitHub sont conservés.

- Correction de l'alias Zsh `ci` généré pour root : lecture de
  `/home/devops/datas/prompts/INDEX.md` à la place de l'ancien chemin
  `/home/devops/datas/template/PROMPTS/INDEX.md`. Les configurations déjà
  installées ne sont pas modifiées par cette correction des sources.

- Génération de `DEVOPS.md` au format `0.6` : rubrique Prompts avec le dossier
  `/home/${ENV_DEVOPS_USER}/datas/prompts` et son `INDEX.md`, selon le compte
  DevOps configuré et indépendamment de la racine des projets. Les chemins
  sont documentés sans lecture ni création des ressources correspondantes.

- Les pushes Forgejo, GitLab et GitHub signalent les indisponibilités réseau
  reconnues sans erreur de commande ni faux succès. CI/CD poursuit les autres
  fournisseurs et le build, ignore les releases concernées et présente un
  résumé avec indisponibilités. Le parcours Forgejo groupé poursuit aussi les
  autres projets. Authentification, TLS, configuration et rejets Git restent
  bloquants ; une publication partielle nécessite une reprise. Clonages et
  releases directes conservent leur comportement.

- Correction des références Docker GHCR : propriétaire et dépôt GitHub
  convertis en minuscules pour la release et son résumé CI/CD. Les valeurs de
  `project.env`, l'identité GitHub, l'image locale et la casse du tag de version
  sont conservées.

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

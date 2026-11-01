# Changelog

Toutes les évolutions significatives du Debian Installer Unified seront documentées dans ce fichier.

## Unreleased

- Variables système : migration de `JOURNALD_MAX_USE` vers
  `SYSTEM_JOURNALD_MAX_USE`, déclaré en `STATIC`, `ENABLE`, scope `system`,
  défaut `500M`. L’ancienne valeur de taille littérale est transférée sans
  interprétation si la nouvelle variable n’est pas déjà configurée; les
  directives `SystemMaxUse` et `RuntimeMaxUse` utilisent le nouveau nom.

- Configuration Docker : déclaration de `DOCKER_STACK_DEVOPS` en `STATIC`,
  `ENABLE`, scope `docker`, défaut `0`. Une valeur existante `0` ou `1` est
  conservée; le défaut est persisté uniquement en l’absence de valeur.

- Configuration Docker : déclaration de
  `DOCKER_STACK_TRAEFIK_DOCKHAND` en `STATIC`, `ENABLE`, scope `docker`, défaut
  `0`. Une valeur existante `0` ou `1` est conservée; le défaut est persisté
  uniquement en l’absence de valeur.

- Variables système : migration de `LOG_ROTATE` vers `SYSTEM_LOG_ROTATE`,
  déclaré en `STATIC`, `ENABLE`, scope `system`, défaut `0`. La dernière
  valeur historique littérale `0` ou `1` est transférée exactement sauf si la
  nouvelle variable est déjà configurée.

- Variables système : migration du contrôle `IPv6` vers `SYSTEM_IPV6`, déclaré
  en `STATIC`, `ENABLE`, scope `system`. En l’absence de valeur configurée,
  l’état initial est détecté avec sysctl et persisté. La valeur historique
  littérale `0` ou `1` est transférée telle quelle; une valeur nouvelle déjà
  présente reste prioritaire.

- Variables système : migration du contrôle GRUB `GRUB_CONFIG` vers
  `SYSTEM_GRUB_CONFIG`, déclaré en `STATIC`, `ENABLE`, scope `system`, défaut
  `0`. La dernière valeur historique littérale `0` ou `1` est transférée sauf
  si la nouvelle variable est déjà configurée ; les déclarations ambiguës
  bloquent le nettoyage.

- Variables système : migration du drapeau `FILES2RAM` vers
  `SYSTEM_FILES2RAM`, déclaré en `STATIC`, `ENABLE`, scope `system`, défaut
  `0`. Une ancienne valeur littérale `0` ou `1` est migrée sauf si la nouvelle
  variable est déjà configurée; la valeur `1` conserve les effets existants.

- Variables système : migration de `FSTAB` et `FSTAB_CONFIG1` à
  `FSTAB_CONFIG5` vers les six déclarations `SYSTEM_FSTAB*`, en `STATIC`,
  `ENABLE`, scope `system`; défauts `0` et `NONE`. Les anciennes valeurs
  littérales sont transférées sauf si la nouvelle variable existe déjà;
  les syntaxes shell ambiguës bloquent le nettoyage.

- FSTAB système : ajout de `SYSTEM_FSTAB_CONFIG6`, en `STATIC`, `ENABLE`,
  scope `system`, défaut `NONE`. Lorsque le drapeau est activé, l’entrée est
  ajoutée après la cinquième; l’affectation littérale historique est migrée si
  la nouvelle déclaration est absente.

- Variables système : migration du drapeau `DRIVERS_NVIDIA` vers
  `SYSTEM_DRIVERS_NVIDIA`, déclarée en `STATIC`, `ENABLE`, scope `system`,
  défaut `0`. Les anciennes valeurs littérales `0` ou `1` sont migrées sauf
  si la nouvelle variable est déjà configurée ; les déclarations ambiguës
  bloquent le nettoyage.

- Variables système : migration du drapeau `PROXY` vers `SYSTEM_PROXY`,
  déclarée en `STATIC`, `ENABLE`, scope `system`, défaut `0`. Les valeurs
  historiques simples `0` ou `1` sont migrées sauf si `SYSTEM_PROXY` est déjà
  configurée ; les déclarations ambiguës bloquent le nettoyage.

- Variables système : migration de `PROXY_CA` vers `SYSTEM_PROXY_CA`, déclarée
  en `STATIC`, `ENABLE`, scope `system`, défaut `0`. Le traitement CA existant
  reste actif uniquement pour la valeur `1` ; la valeur historique n’est pas
  transférée.

- Génération de DEVOPS.md : ajout de la puce « Accès TPM OK » après l'image
  debian:stable-slim dans la rubrique Docker activée. Mention documentaire
  fixe, sans sonde ni changement d'infrastructure ; la rubrique passe à six
  puces et les autres comportements restent inchangés.

- Régressions : isolation des configurations Git de test, fixtures globales
  alignées sur U1, référence Zsh Z1 avec inventaire explicite et contrôle APT
  indépendant de l’ordre de démarrage du pipeline.
- Release Debian GitLab : vérification du statut HTTP de création du lien
  d’asset ; les refus HTTP et erreurs de transport empêchent le faux succès.
- Modules projects : chemins de clonage protégés et échecs mkdir explicites ;
  annotations ShellCheck locales pour les usages indirects et marqueurs Debian.

- Forgejo : provider sans interaction, setup explicitement confirmé avant les
  transports, validation candidate et préservation des identifiants existants
  lors des refus et erreurs. Les fichiers manquants sont publiés seulement
  après validation, avec nettoyage des publications partielles.
- Packaging DIU : source paramétrable via projects deb, alias proj deb,
  cache deb/ non requis et sélection unique d’une version Debian depuis HEAD,
  avec horodatage de repli sans tag. La release applique la même sélection.
  Le contrôle Debian du staging n’hérite plus du bit setgid du répertoire parent.

- Synchronisation des projets : copie initiale de `DEVELOPMENT_MAP.md` depuis
  le modèle uniquement si son entrée destination est absente, en mode unitaire
  ou groupé. La copie reçoit la personnalisation Markdown et le propriétaire
  prévus ; toute entrée existante reste intacte. Une source requise absente ou
  non régulière bloque les copies dans ce projet, sans arrêter le parcours groupé.

- Génération de `DEVOPS.md` : ajout après le chemin OpenCode de la puce
  « La variable OPENCODE_PASSWORD pour l'API est chargée depuis project.env ».
  Indication statique, sans lecture supplémentaire de configuration ni affichage
  du mot de passe. Format `0.7`, sondes et parcours conservés ; application à la
  prochaine génération normale des documents existants.

- Installation OpenCode DevOps : recherche de la dernière release stable V2 sur
  GitHub et comparaison numérique avec la version installée. DIU utilise
  `https://opencode.ai/v2/install` pour mettre à jour uniquement un binaire
  absent ou plus ancien ; une version égale ou supérieure est conservée.
  L'activation `OPENCODE=1`, le chemin DevOps et l'absence de modification du
  PATH restent inchangés.

- Génération de `DEVOPS.md` : ajout de Nuitka déclaré dans
  `[build-system].requires`, avec contraintes et extras éventuels, dans la
  rubrique commune « Python - Outils de compilation ». Seuls les outils déclarés
  apparaissent, Cython puis Nuitka ; découverte et sondes partagées, états et
  provenances indépendants, sans repli global ni import des compilateurs.
  Aucun paquet installé, manifeste modifié ou compilation lancée. Format `0.7`
  et parcours existants conservés ; application à la prochaine génération normale.

- Génération de `DEVOPS.md` : rubrique « Python - Outils de compilation »
  après pip et avant Prompts uniquement si Cython est déclaré dans
  `[build-system].requires` de `pyproject.toml`. Vérification isolée dans les
  venv du projet, avec version et provenance, absence vérifiée ou installation
  non vérifiable ; aucune sonde Cython sans déclaration, aucun repli global,
  installation ni modification du manifeste. Format `0.7` conservé, appliqué
  aux documents existants lors de leur prochaine génération normale.

- Génération de `DEVOPS.md` : rubrique permanente « OpenSSH & SSHPASS » après
  les conteneurs éventuels et avant Docker-Compose. Quatre puces présentent
  les versions et chemins hôte de `ssh` et `sshpass`, relevés avec `-V` et
  une borne de 15 secondes par outil, sans connexion ni lecture d’identifiants.
  Les indisponibilités sont explicites ; le format `0.7` reste conservé.
  Les documents existants adoptent ce contenu à leur prochaine génération normale.

- Authentification Forgejo, GitHub et GitLab : les fichiers `.username` et
  `.token` existants acceptent exactement `0600` ou `0660` dans les parcours
  Git et API, sans modification de contenu ou de permissions. Les autres modes
  restent refusés avant lecture. Le mode `0660` autorise l'accès du groupe ;
  les nouveaux identifiants et les secrets temporaires restent en `0600`.

- Génération de `DEVOPS.md` : le titre LXC précise « accessible en SSH » et sa
  première puce devient « Variables d'accès disponible dans project.env pour l'accès SSH ».
  Une cinquième puce indique « Binaires et bibliothèques installés pour les tests ne sont pas à désinstaller après tests. ».
  L’autorisation commune reste inchangée en quatrième position pour LXC et en
  dernière position pour Docker. Activation, ordre des rubriques et format `0.7`
  conservés, sans connexion distante ni gestion des paquets pendant la génération.
  Les documents existants adoptent ce rendu à leur prochaine génération normale.

- Génération de `DEVOPS.md` : dernière puce commune aux rubriques Docker et LXC
  activées, autorisant explicitement les agents de codage et les orchestrateurs
  à préparer, exécuter, répéter et nettoyer les tests du projet dans le conteneur,
  y compris avec droits root, sans approbation supplémentaire. L'autorisation
  couvre le conteneur et les ressources dédiées aux tests. Les conditions
  d'activation, l'ordre, les sondes et le format `0.7` restent inchangés ; les
  contrôles techniques des outils ou plateformes ne sont pas modifiés.
  Les documents existants adoptent cette puce à leur prochaine génération normale.

- Alignement des nouvelles lignes `ENV_DEVOPS_TESTS_DOCKER` et
  `ENV_DEVOPS_TESTS_LXC` avec huit espaces avant `export` dans
  `environnements.env`. Leur suppression déclarative accepte aussi les lignes
  sans retrait ou précédées de tabulations. Les valeurs et lignes déjà
  présentes sont conservées sans reformatage global.

- Génération de `DEVOPS.md` : les rubriques « Conteneur Docker, pour tests
  nécessitant des droits root » et « Conteneur LXC, pour tests nécessitant des
  droits root » dépendent indépendamment de `ENV_DEVOPS_TESTS_DOCKER=1` et
  `ENV_DEVOPS_TESTS_LXC=1`. Une valeur absente, vide ou différente de `1` omet
  la rubrique concernée ; Docker désactivé n'est pas sondé. LXC suit Docker
  s'il est présent, sinon Matériel, avant Docker-Compose qui reste indépendant.
  Les trois puces LXC sont déclaratives, sans connexion, lecture d'identifiants
  ni qualification TPM distante. Les références Docker restent inchangées.
  Le format reste `0.7`, appliqué à la prochaine génération normale.

- Initialisation de `ENV_DEVOPS_TESTS_DOCKER` et `ENV_DEVOPS_TESTS_LXC` à `0`
  dans le scope `environnements` si elles sont absentes, avec persistance puis
  export. Les valeurs existantes, même vides, sont conservées sans doublon
  lors des réexécutions normales. Les erreurs de persistance sont explicites.
  Aucun test Docker/LXC n'est lancé ; la configuration réelle sera complétée
  à la prochaine exécution normale du DIU mis à jour.

- Génération de `DEVOPS.md` au format documentaire `0.7` : le résultat
  dynamique de `hostname -f` apparaît en deuxième puce sous « Système
  d'exploitation », après le nom de l'OS. La sonde est limitée à 15 secondes ;
  absence, échec, expiration ou sortie invalide sont signalés sans bloquer la
  génération. Aucun nom n'est codé en dur et aucune configuration réseau ou
  du nom d'hôte n'est modifiée. Les documents existants adoptent le format
  à leur prochaine génération normale.

- Génération de `DEVOPS.md` : ajout des droits d'exécution manquants aux sept
  outils DevOps connus avant les inventaires et sondes. Les liens restent
  confinés au domicile DevOps ; outils hôte, autres fichiers, propriétaires
  et droits de lecture et d'écriture sont conservés. Aucun outil absent n'est
  installé. Une préparation impossible bloque la génération et préserve le
  document précédent ; les droits déjà ajoutés restent appliqués. Les sondes
  distinguent désormais binaire absent et binaire non exécutable. Le format
  reste `0.6`, sans modification des outils installés par cette livraison.

- Génération de `DEVOPS.md` : section « Matériel » après l'OS, avec TPM et
  chemin prioritaire `/dev/tpmrm0`, version, fabricant, identifiant fournisseur,
  révision de spécification et banques/indices PCR alloués. La collecte locale
  est bornée et en lecture seule ; TPM inaccessible, outil absent et
  propriétés non vérifiables restent explicites sans bloquer la génération.
  Aucune installation, modification de droits ni lecture des valeurs PCR.
  Le format reste `0.6`, adopté lors de la prochaine génération normale.

- Génération de `DEVOPS.md` : rubrique « Docker, pour tests nécessitant des
  droits root » avec `/var/run/docker.sock` puis `debian:stable-slim` après
  la version et le binaire. Ces références documentaires restent affichées
  si Docker est indisponible, sans sonde du socket, téléchargement ou
  lancement de l'image. La version documentaire reste `0.6` ; les documents
  existants adoptent ce rendu à leur prochaine génération normale.

- Enregistrement idempotent d'une exception `safe.directory` système limitée
  au chemin canonique du projet par `rid projects git init` et `update`, y
  compris pour un dépôt déjà initialisé. `status` affiche son état sans la
  modifier. Les autres règles et propriétaires sont conservés ; les erreurs
  de configuration système sont bloquantes, sans annuler les écritures
  antérieures. Aucun joker ni migration automatique des dépôts existants.

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

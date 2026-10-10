# Debian Installer Unifié (DIU)

Le DIU installe et configure Debian grâce à une architecture modulaire en
Bash. Le module `projects` gère également les projets de développement et
leurs publications Forgejo.

La création avec `rid projects create <ID PROJECT>` et la mise à jour des
variables avec `rid projects update <ID PROJECT>` demandent
`PROJECT_ORCHESTRATED_CODING` : `No` pour un agent de codage autonome, `Yes`
pour un agent piloté par un orchestrateur. La valeur existante est proposée,
sinon `No` ; une entrée vide conserve ce défaut. Une variable absente dans
`project.env` vaut `No`, sans migration globale ni activation automatique.

Pour publier les artefacts activés d’un projet :

```bash
rid projects forgejo release <ID PROJECT>
```

La commande publie l’image Docker et/ou le paquet Debian selon
`PROJECT_DOCKERED` et `PROJECT_DEBIAN_PACKAGE` dans `project.env`.

Pour générer l'inventaire DevOps d'un projet :

```bash
rid projects template devops <ID PROJECT>
```

`DEVOPS.md` est généré au format documentaire `0.5`, avec provenance DIU,
début du relevé UTC et classification de l'environnement d'exécution fournie
par DIU. Les dépendances Python sont recherchées en priorité dans les venv du projet
(`.venv`, `venv`, `env`, puis autres chemins triés), avec repli DevOps explicite.
Chaque résultat indique son interpréteur, son environnement et son
installation observée. Les recherches ou sondes impossibles sont signalées
comme non vérifiables. Cet inventaire ne valide pas une composition Python
unique et ne constitue ni une qualification fonctionnelle ni une preuve de
réussite des tests.

Les manifestes `package.json` des composants et workspaces sont regroupés sous
NPM ; `.opencode/package.json` figure sous OpenCode. Les dépendances directes
sont séparées par catégorie, avec contrainte déclarée, version verrouillée
npm (formats 2/3) et version observée localement, puis chemin réel
d'installation. Un verrou ne prouve pas une installation ; les formats non
analysés et recherches incomplètes restent explicites. La collecte ne lance
aucun gestionnaire, script ou paquet et n'utilise aucun repli npm global.
Les détails sont décrits dans
[le cadrage technique](TECHNICAL.md#traçabilité-du-document-devops).

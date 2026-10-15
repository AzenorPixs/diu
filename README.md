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

Lors de la création depuis le modèle et de `rid projects sync <ID PROJECT>`
(y compris `sync all`), `ORCHESTRATED_CODING.md` est copié et personnalisé
uniquement si le mode du projet destination vaut `Yes`. Pour `No` ou une
variable absente ou vide, il n'est pas copié et une version destination
existante reste intacte. Pour `Yes`, son absence dans le modèle provoque une
erreur avant la copie des ressources du modèle.

La création exclut le `.git` à la racine du modèle : son dépôt Git n'est pas
transféré au nouveau projet. Les autres fichiers cachés, dont `.gitignore`,
restent copiés selon les règles existantes. Cette exclusion ne concerne pas
les `.git` imbriqués et ne modifie aucun projet existant.

Pour construire une image avec `rid projects docker build <ID PROJECT>`, le
projet peut fournir le fichier public optionnel `build/docker-build.args` :

```text
# Paramètres publics propres à ce projet
APP_VERSION=1.2.3
BUILD_MODE=release
```

DIU transmet ces lignes comme arguments Docker, sans interprétation shell.
Les quotes restent dans la valeur, les dollars ne sont pas développés et une
valeur vide reste vide. Les commentaires/blancs sont ignorés. Noms invalides,
doublons, CR/NUL, liens symboliques, fichiers non réguliers/illisibles ou
supérieurs à 64 Kio bloquent la construction. La dernière ligne sans LF est
acceptée. Le fichier ne doit contenir aucun secret ; les paramètres et leur
cohérence applicative restent dans chaque projet. Sans fichier, le parcours
existant est conservé. Aucun helper applicatif n'est exécuté.

Le [dossier de validation](openspec/changes/archive/2026-10-15-support-project-docker-build-args/review.md)
et son [rapport d'archive](openspec/changes/archive/2026-10-15-support-project-docker-build-args/STATISTIQUES.md)
conservent les preuves et limites de cette évolution.

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

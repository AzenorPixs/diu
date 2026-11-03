## MODIFIED Requirements

### Requirement: Structure et version documentaire

Le document SHALL conserver le titre `DEVOPS.md — <ID PROJECT>`, la version
`0.8` et l'ordre du scénario « Rubriques documentaires conservées ».
Pour template, le titre SHALL être `DEVOPS.md — Template`.
Matériel SHALL suivre immédiatement Système d'exploitation.
Chaque rubrique logicielle SHALL placer le chemin après la version ;
PostgreSQL Serveur SHALL placer l'adresse après la version.
Tests navigateurs extérieurs en mode headless SHALL terminer le document.

#### Scenario: Actualisation d'un document ancien

- **WHEN** DEVOPS.md existe avec des versions anciennes
- **THEN** toutes les versions logicielles sont sondées de nouveau et les valeurs anciennes sont remplacées
- **AND THEN** la version documentaire devient 0.8 et les rubriques existantes conservent leur ordre relatif
- **AND THEN** une seule section Prompts précède la section finale Tests navigateurs extérieurs en mode headless

#### Scenario: Rubriques documentaires conservées

- **WHEN** un document DevOps est généré
- **THEN** les rubriques restent dans l'ordre : Système d'exploitation, Matériel, `Conteneur Docker, pour tests nécessitant des droits root` si activé, `Conteneur LXC, pour tests nécessitant des droits root accessible en SSH` si activé, OpenSSH & SSHPASS, Docker-Compose, Git, Go, Node, NPM, OpenCode, OpenSpec, OpenSSL, PostgreSQL Client, PostgreSQL Serveur, Python, Python - Dépendances du projet - Source de vérité `pyproject.toml`, Python - Gestionnaire de paquets, Python - Outils de compilation si Cython ou Nuitka est déclaré dans [build-system].requires, Prompts, Tests navigateurs extérieurs en mode headless
- **AND THEN** les métadonnées de traçabilité, la section de configuration locale et la légende précèdent la première rubrique, après la version documentaire
- **AND THEN** la section finale contient Chromium puis Firefox

#### Scenario: Configuration locale et sécurité

- **WHEN** un document DevOps est généré
- **THEN** le texte de configuration locale validé apparaît une seule fois avant la légende des sondes et rappelle les restrictions de consultation de project.env par les agents

Texte attendu :

```markdown
## Configuration locale — project.env
Le fichier `project.env`, situé à la racine du projet, est une configuration
locale protégée. Sa consultation par les agents relève des sections 9 et 10
d’AGENTS.md.

Pour le travail autorisé, l’agent peut extraire localement les variables
non secrètes nécessaires, notamment `PROJECT_*`, `LOCAL_DEFAULT_BRANCH`,
`GIT_*` et `REMOTE_*`, sans limitation à ces familles. Seul un processus
local parcourt le fichier et restitue les noms et valeurs validés comme
non secrets.

La lecture brute, l’exécution du fichier et son chargement dans
l’environnement par l’agent sont interdits. L’agent ne doit ni créer,
ni modifier, ni régénérer ce fichier. Aucun secret ne doit être restitué,
affiché, journalisé ou transmis au modèle.

Les mentions de chargement de variables dans cet inventaire décrivent
leur utilisation par les outils locaux. Elles n’accordent aucun droit
supplémentaire de consultation à l’agent, notamment pour les variables
d’authentification SSH, OpenCode ou PostgreSQL.
```

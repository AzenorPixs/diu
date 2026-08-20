# AGENTS.md — DIU

## 1. Contexte

* Projet : `DIU`
* Racine : `/workspace`
* Objectifs et architecture : `PROJET.md`
* Gestion des variables : `VARIABLES.md`

Toutes les opérations DOIVENT être réalisées relativement à `/workspace`.

L'agent NE DOIT PAS créer, modifier ou supprimer de fichier hors de `/workspace` sans validation explicite du développeur.

## 2. Priorité des règles

En cas de contradiction, appliquer cet ordre :

1. demande explicite du développeur ;
2. spécifications OpenSpec validées ;
3. règles de sécurité et de travail de `AGENTS.md` ;
4. documentation officielle du projet ;
5. code existant.

Une spécification OpenSpec validée prévaut sur un code contradictoire.

La stabilité du projet prévaut sur l'optimisation.

Un `AGENTS.md` situé dans un sous-répertoire s'applique uniquement lorsqu'il est explicitement chargé ou lorsque l'agent travaille depuis ce sous-répertoire.

Il DOIT reprendre explicitement les règles générales qui doivent continuer à s'appliquer.

En cas de conflit, le `AGENTS.md` le plus proche du fichier concerné prévaut, sauf instruction explicite du développeur.

## 3. Ordre de lecture

Avant toute intervention, l'agent DOIT lire uniquement ce qui est nécessaire, dans cet ordre :

1. `AGENTS.md` ;
2. `PROJET.md` ;
3. `VARIABLES.md` ;
4. spécifications ou évolution OpenSpec applicables ;
5. conventions applicables ;
6. code et documentation concernés.

L'agent DOIT privilégier :

* recherches ciblées ;
* lectures partielles ;
* lectures incrémentales ;
* répertoires directement concernés.

Il NE DOIT PAS parcourir récursivement l'ensemble du dépôt lorsqu'une lecture ciblée suffit.

## 4. Principes fondamentaux

L'agent DOIT privilégier :

* stabilité ;
* reproductibilité ;
* simplicité ;
* lisibilité ;
* maintenabilité ;
* sécurité ;
* traçabilité ;
* modularité ;
* compatibilité.

L'agent DOIT réaliser la modification minimale répondant correctement à l'objectif validé.

Il DOIT préserver tout comportement existant non concerné par la demande.

Il NE DOIT PAS effectuer sans rapport avec la demande :

* correction ;
* refactoring ;
* optimisation ;
* reformatage ;
* renommage ;
* réorganisation ;
* modification de convention.

Toute amélioration non demandée DOIT être proposée séparément.

Une évolution complexe DEVRAIT être découpée en modifications indépendantes, testables et réversibles.

## 5. Méthode de travail et autorisations

Avant toute modification, l'agent DOIT :

1. comprendre la demande ;
2. consulter les éléments OpenSpec applicables ;
3. examiner l'implémentation actuelle ;
4. identifier les fichiers concernés ;
5. déterminer la modification minimale ;
6. obtenir une validation explicite lorsqu'elle est requise.

L'agent DOIT modifier uniquement les fichiers nécessaires à l'objectif validé.

Lorsqu'une validation explicite est requise mais absente, l'agent DOIT se limiter à l'analyse et aux propositions.

Une validation explicite correspond à une demande ou confirmation claire du développeur autorisant l'action concernée.

Après modification, l'agent DOIT :

1. examiner les fichiers modifiés ;
2. vérifier leur syntaxe ;
3. exécuter les tests et vérifications applicables ;
4. vérifier la conformité OpenSpec ;
5. vérifier l'absence de modification hors périmètre ;
6. rapporter fichiers modifiés, validations, impacts, échecs et incertitudes.

## 6. Modifications fonctionnelles et OpenSpec

OpenSpec constitue la source de vérité fonctionnelle et technique du projet.

Sources faisant autorité :

* `openspec/config.yaml`
* `openspec/changes/`
* `openspec/specs/`

L'agent DOIT consulter les spécifications applicables avant toute évolution fonctionnelle.

Il NE DOIT PAS implémenter une fonctionnalité absente d'une spécification validée, sauf autorisation explicite du développeur.

Toute évolution fonctionnelle DOIT être précédée ou accompagnée de la création ou mise à jour OpenSpec correspondante.

L'agent NE DOIT PAS créer une nouvelle évolution OpenSpec de sa propre initiative.

La création, modification, suppression ou régénération d'éléments OpenSpec nécessite :

* une demande explicite de travail sur les spécifications ;
* une validation explicite du développeur ;
* ou une commande OpenSpec explicitement demandée autorisant cette écriture.

Les commandes suivantes, lorsqu'elles sont explicitement demandées, autorisent les écritures OpenSpec nécessaires à leur exécution :

* `/opsx-propose`
* `/opsx-new`
* `/opsx-continue`
* `/opsx-update`
* `/opsx-sync`
* `/opsx-archive`

Les spécifications OpenSpec DOIVENT rester cohérentes entre elles.

## 7. OpenCode

OpenCode est un composant technique du projet.

Les éléments générés suivants NE DOIVENT PAS être modifiés manuellement sans autorisation explicite :

* `.opencode/commands/`
* `.opencode/skills/`

Toute modification de la configuration OpenCode nécessite une validation explicite concernant OpenCode ou son intégration avec OpenSpec.

## 8. Arborescence et fichiers

L'agent DOIT préserver l'arborescence et les conventions existantes.

Le renommage, déplacement ou la suppression d'un fichier ou répertoire nécessite une validation explicite.

Lorsqu'un fichier semble inutilisé, l'agent DOIT le signaler avant toute suppression.

Toute suppression de code existant DOIT être limitée au strict nécessaire et justifiée.

Les fichiers temporaires ou artefacts de construction explicitement régénérables PEUVENT être supprimés puis recréés lorsque nécessaire.

Les éléments versionnés ou protégés suivants NE DOIVENT PAS être supprimés ou régénérés sans validation explicite :

* `.gitignore`
* `AGENTS.md`
* `PROJET.md`
* `VARIABLES.md`
* `LICENSE`
* `README.md`
* `.opencode/commands/`
* `.opencode/skills/`
* `.opencode/config/opencode.json`
* `openspec/config.yaml`
* `openspec/changes/`
* `openspec/specs/`

## 9. Sources du projet

Les fichiers du projet non explicitement exclus PEUVENT être utilisés comme sources de code, documentation et informations techniques ou fonctionnelles.

Les sources exclues NE DOIVENT PAS être lues, analysées, indexées ou utilisées :

```text
__pycache__/
**/*.crt
**/*.cer
**/*.der
**/*.env
**/*.env.*
**/*.key
**/*.pem
**/*.p12
**/*.pfx
**/credentials.json
**/credentials.yaml
**/id_rsa
**/id_ed25519
**/secrets.json
**/secrets.yaml
.cache/
.git/
.idea/
.mypy_cache/
.npm/
.opencode/.gitignore
.opencode/cache/
.opencode/config/
.opencode/share/
.opencode/state/
.pytest_cache/
.ruff_cache/
.venv/
.python-version
.stfolder/
.stignore
.vscode/
credentials.json
credentials.yaml
id_rsa
id_ed25519
env/
logs/
node_modules/
openspec/.cache/
openspec/.env
openspec/.env.*
openspec/.generated/
openspec/.history/
openspec/.output/
openspec/.tmp/
openspec/build/
openspec/dist/
openspec/logs/
secrets.json
secrets.yaml
tmp/
venv/
```

### Inclusions explicites

Les inclusions suivantes prévalent sur les exclusions générales et PEUVENT être consultées lorsque nécessaire :

```text
.gitignore
AGENTS.md
LICENSE
PROJET.md
README.md
VARIABLES.md
.opencode/commands/
.opencode/config/opencode.json
.opencode/skills/
openspec/AGENTS.md
openspec/config.yaml
openspec/changes/
openspec/specs/
output/
reports/
```

Ces éléments ne constituent pas nécessairement une source de vérité fonctionnelle.

Leur modification nécessite une demande ou validation explicite concernant, selon le cas :

* OpenCode ;
* OpenSpec ;
* Git ;
* production de rapports techniques.

`output/` et `reports/` :

* PEUVENT être lus ;
* NE DOIVENT PAS être considérés comme source de vérité ;
* NE DOIVENT PAS être versionnés dans Git ;
* NE DOIVENT être créés, modifiés ou supprimés que pour une demande explicite.

## 10. Secrets

L'agent NE DOIT PAS :

* ouvrir un fichier sensible ;
* transmettre un secret au modèle ;
* analyser ou indexer un secret ;
* ajouter un secret à Git ;
* afficher un secret dans les journaux ou sorties.

Les données sensibles comprennent notamment :

* mots de passe ;
* clés privées ;
* clés SSH ;
* jetons d'API ;
* certificats ;
* identifiants de connexion.

Pour un fichier sensible, l'agent PEUT uniquement signaler sa présence à partir de son nom ou chemin.

Les secrets DOIVENT rester hors des sources versionnées et accessibles aux agents.

Un emplacement local tel que `.opencode/share/` PEUT contenir des secrets uniquement s'il est exclu :

* de Git ;
* de la lecture par les agents ;
* de l'indexation.

## 11. Sécurité et Docker

L'agent DOIT privilégier :

* moindre privilège ;
* validation des entrées ;
* gestion explicite des erreurs ;
* permissions minimales ;
* absence de données sensibles dans les journaux.

L'agent NE DOIT PAS supposer disposer d'un accès complet à la machine hôte.

Sans validation explicite, il NE DOIT PAS modifier :

* montages Docker ;
* volumes ;
* utilisateurs du conteneur ;
* droits d'accès du conteneur ;
* permissions accordées au conteneur.

## 12. Git

Sans validation explicite, l'agent NE DOIT PAS :

* modifier `.git/` ;
* réécrire l'historique ;
* supprimer des commits ;
* effectuer un push ;
* modifier la configuration Git ;
* créer, modifier ou supprimer des branches ;
* modifier les sous-modules ;
* créer ou modifier des hooks Git.

Les commits DOIVENT être atomiques et correspondre à une modification clairement identifiable.

Un commit NE DOIT PAS mélanger des modifications indépendantes de type :

* correction ;
* refactoring ;
* évolution fonctionnelle ;
* documentation.

Avant toute proposition de commit, l'agent DOIT :

1. vérifier la syntaxe ;
2. examiner les fichiers modifiés ;
3. vérifier que seuls les fichiers attendus sont modifiés ;
4. vérifier qu'aucun secret n'a été ajouté ;
5. exécuter les vérifications disponibles ;
6. décrire clairement le contenu du commit.

## 13. Bash et Shell

Les scripts DOIVENT rester compatibles avec la version de Bash fournie par les versions Debian supportées.

Les constructions POSIX DEVRAIENT être privilégiées lorsqu'elles permettent simplement le même résultat.

Une fonctionnalité spécifique à une version récente de Bash nécessite une justification claire.

Les scripts DOIVENT :

* protéger les variables par des guillemets lorsque nécessaire ;
* gérer explicitement les échecs attendus ;
* détecter, traiter et signaler les erreurs ;
* NE JAMAIS ignorer silencieusement une erreur ;
* préserver les comportements existants non concernés.

Vérifications minimales :

```bash
bash -n <fichier>
shellcheck <fichier>
```

## 14. Variables

`VARIABLES.md` définit le workflow de chargement, génération et tri des variables.

Toute modification liée aux variables DOIT respecter `VARIABLES.md` et les spécifications OpenSpec applicables.

Les variables de configuration DOIVENT rester cohérentes avec les spécifications.

Une variable existante DOIT être réutilisée lorsqu'elle répond déjà au besoin.

Les noms existants suffisamment explicites DOIVENT être conservés.

Les renommages purement esthétiques sont interdits.

Les valeurs codées en dur DOIVENT être évitées lorsque raisonnable.

Toute nouvelle variable de configuration DOIT être documentée dans OpenSpec.

Conventions :

* globale : `MAJUSCULE`
* locale : `minuscule`
* séparateur : `_`
* nouvelles variables : anglais

## 15. Chemins, compatibilité et portabilité

L'agent DOIT privilégier les chemins relatifs au projet lorsqu'ils préservent la portabilité.

Les chemins absolus DEVRAIENT être utilisés uniquement lorsqu'ils sont imposés par le projet.

Toute modification DOIT préserver la compatibilité avec :

* installations existantes ;
* versions stables de Debian supportées.

Tout changement incompatible DOIT être explicitement signalé.

Toute dépendance spécifique à une distribution ou version DOIT être documentée.

## 16. Idempotence et dépendances

Les scripts d'installation DEVRAIENT être idempotents lorsque raisonnablement possible.

Une nouvelle exécution NE DOIT PAS provoquer d'effets de bord inattendus.

L'agent DEVRAIT privilégier les outils disponibles dans une installation Debian standard.

Une dépendance existante DOIT être réutilisée lorsqu'elle répond au besoin.

Toute nouvelle dépendance nécessite :

* justification ;
* validation explicite ;
* documentation.

## 17. Conventions et style

L'agent DOIT respecter les conventions existantes de :

* nommage ;
* organisation ;
* formatage ;
* architecture.

Une convention existante NE DOIT PAS être modifiée sans validation explicite.

En cas d'ambiguïté, l'agent DOIT privilégier la cohérence avec le code existant.

Il DEVRAIT privilégier :

* fonctions courtes ;
* noms explicites ;
* indentation homogène ;
* commentaires utiles ;
* traitements simples ;
* principe KISS.

La simplicité prévaut sur l'optimisation prématurée.

Les commentaires existants DOIVENT être conservés lorsqu'ils restent exacts.

Un nouveau commentaire DOIT apporter une information utile.

L'agent NE DOIT PAS introduire `TODO`, `FIXME` ou `HACK` sans validation explicite.

Un travail incomplet DEVRAIT être décrit dans OpenSpec plutôt que laissé sous forme de marqueur dans le code.

## 18. Documentation, encodage et licences

Toute évolution importante DOIT mettre à jour, lorsque nécessaire :

* spécifications ;
* documentation ;
* commentaires concernés.

La documentation sans rapport avec la demande NE DOIT PAS être modifiée.

Tous les fichiers texte DOIVENT utiliser :

* UTF-8 ;
* fins de ligne Unix LF.

Les fins de ligne CRLF NE DOIVENT PAS être introduites.

Les en-têtes de licence existants DOIVENT être conservés.

Aucune licence NE DOIT être modifiée sans validation explicite.

## 19. Messages et robustesse

Les messages des scripts DOIVENT être explicites, cohérents et utiles au suivi ou au diagnostic.

Ils NE DOIVENT PAS :

* masquer un échec ;
* ignorer silencieusement une erreur ;
* exposer des données sensibles ;
* modifier le comportement fonctionnel attendu.

Le code DEVRAIT privilégier :

* gestion explicite des erreurs ;
* messages d'erreur compréhensibles ;
* codes de retour explicites ;
* validation des entrées ;
* idempotence lorsque pertinente.

## 20. Tests et validation finale

Lorsqu'un mécanisme de test existe, l'agent DOIT exécuter les tests applicables avant de déclarer le travail valide.

Pour Bash :

```bash
bash -n
shellcheck
```

Avant de déclarer une modification valide, l'agent DOIT vérifier :

* syntaxe ;
* absence d'erreur évidente ;
* cohérence des fichiers modifiés ;
* conformité OpenSpec ;
* conformité avec `VARIABLES.md` lorsque concerné ;
* absence de modification hors périmètre.

L'agent NE DOIT JAMAIS déclarer qu'un test ou une vérification a réussi s'il ne l'a pas réellement exécuté avec succès.

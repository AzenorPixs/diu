AGENTS.md
Debian Installeur Unifié (DIU)}

Ce fichier est généré à l'initialisation du projet par le DIU.

## Variables utilisées :

Debian Installeur Unifié (DIU)} : nom du projet ;
/workspace : chemin racine du projet.

## Préambule

Ce document définit les règles que doivent respecter les agents de codage intervenant sur ce projet.

Les agents doivent privilégier :

la stabilité ;
la reproductibilité ;
la simplicité ;
la lisibilité ;
la maintenabilité ;
la sécurité ;
la traçabilité des modifications.

Les agents doivent toujours privilégier les modifications les plus petites possibles.

Une évolution complexe doit être découpée en plusieurs modifications indépendantes afin de faciliter :

la relecture ;
les tests ;
la validation ;
les retours arrière.

Les agents ne doivent jamais profiter d'une modification pour corriger, reformater, renommer ou réorganiser des éléments sans rapport avec la demande.

Toute amélioration non demandée doit être proposée séparément.

## Objectif

L'objectif du projet est de produire un installeur Debian unifié :

reproductible ;
maintenable ;
documenté ;
spécifié avec OpenSpec ;
versionné avec Git ;
assisté par OpenCode.

Toutes les décisions doivent privilégier ces objectifs.

## Rôle du projet

Le projet Debian Installeur Unifié (DIU)} est développé selon une approche progressive, documentée et reproductible.

Les agents de codage doivent préserver le comportement existant tout en respectant les spécifications validées.

## Portée

AGENTS.md ;
les spécifications présentes dans openspec/ ;
les conventions du projet ;
Les règles définies dans ce fichier s'appliquent à l'ensemble du projet.

Un fichier AGENTS.md situé dans un sous-répertoire peut être utilisé lorsque OpenCode est lancé depuis ce sous-répertoire,
ou lorsqu’il est explicitement chargé dans les instructions.

Il ne doit pas être considéré comme complétant automatiquement le fichier AGENTS.md racine.

Il doit reprendre explicitement toutes les règles générales qui doivent continuer à s’appliquer.

En cas de conflit, le fichier AGENTS.md le plus proche du fichier modifié prévaut, sauf demande explicite du développeur.

## Emplacement du projet

La racine du projet est située dans :

/workspace

Toutes les opérations doivent être réalisées relativement à cette racine.

Les agents ne doivent créer, modifier ou supprimer des fichiers que sous :

/workspace

Toute écriture en dehors de cette arborescence nécessite une validation explicite.

## Ordre de lecture

Avant toute intervention, les agents doivent lire dans l'ordre :

AGENTS.md ;
les spécifications présentes dans openspec/ ;
les conventions du projet ;
le code et la documentation concernés.

## Méthode de travail

Avant toute modification, les agents doivent :

comprendre la demande ;
consulter les spécifications OpenSpec applicables ;
identifier les fichiers concernés ;
proposer les modifications ;
réaliser uniquement les modifications validées ;
vérifier la syntaxe et la cohérence ;
expliquer les impacts.

Les évolutions doivent être :

progressives ;
limitées à un objectif clairement défini ;
documentées ;
vérifiables ;
facilement réversibles.

Chaque proposition doit préciser :

l'objectif ;
les fichiers concernés ;
les modifications envisagées ;
les impacts éventuels ;
les vérifications à effectuer.

## Règles permanentes de Développements

Privilégier une architecture modulaire
Préserver la compatibilité
Pas de changement fonctionnel non spécifié

## Périmètre des modifications

Les agents doivent limiter leurs modifications aux fichiers strictement nécessaires à l'objectif demandé.

Ils ne doivent jamais :

modifier plusieurs fonctionnalités simultanément ;
effectuer des optimisations non demandées ;
reformater massivement les fichiers ;
effectuer des modifications de style sans rapport avec la demande ;
renommer des variables uniquement pour des raisons esthétiques ;
déplacer des fichiers ou modifier l'arborescence sans validation explicite ;
modifier une convention existante sans validation explicite.

En cas de doute, l'agent doit proposer une solution sans modifier le fonctionnement existant de sa propre initiative.

## Modifications fonctionnelles

Aucune modification du comportement fonctionnel ne doit être réalisée sans spécification explicite ou validation explicite du développeur.

Toute évolution fonctionnelle doit être précédée ou accompagnée de la création ou de la mise à jour de la spécification OpenSpec correspondante.

Les agents ne doivent jamais implémenter une fonctionnalité absente d'une spécification validée.

## OpenSpec

Les spécifications OpenSpec constituent la source de vérité fonctionnelle et technique du projet.

Avant toute modification du code, les agents doivent vérifier qu'une spécification correspondante existe ou qu'une validation explicite a été obtenue.

Lorsqu'une spécification validée est en contradiction avec le code existant, la spécification prévaut.

Les spécifications doivent rester cohérentes entre elles.

Les agents ne doivent créer ou modifier une spécification OpenSpec que lorsque :

la demande concerne explicitement une évolution fonctionnelle ;
la demande concerne explicitement un travail de spécification ;
une validation explicite du développeur a été obtenue ;
une commande OpenSpec autorisant cette opération a été demandée.

La demande explicite d'utiliser une commande OpenSpec nécessitant une écriture,
notamment :

/opsx-propose ;
/opsx-new ;
/opsx-continue ;
/opsx-update ;
/opsx-sync ;
/opsx-archive ;

constitue l'autorisation de modifier les fichiers OpenSpec nécessaires
à l'exécution de cette commande.

Les agents ne doivent pas créer une nouvelle évolution OpenSpec de leur propre initiative.

## Sources de spécifications faisant autorité

Les éléments suivants constituent les sources de spécifications et de configuration faisant autorité pour le projet :

openspec/config.yaml
openspec/changes/
openspec/specs/

Ils doivent être consultés avant toute évolution fonctionnelle.

Leur création, modification, suppression ou régénération nécessite une demande ou une validation explicite.

## OpenCode

OpenCode doit être considéré comme un composant technique du projet.

Les fichiers présents dans les répertoires suivants sont générés par OpenSpec et ne doivent pas être modifiés manuellement sans demande explicite :

.opencode/commands/
.opencode/skills/

Les modifications de la configuration OpenCode nécessitent une validation explicite portant sur OpenCode ou sur son intégration avec OpenSpec.

## Arborescence

Les agents doivent respecter l'organisation actuelle du projet.

Les renommages, déplacements ou suppressions de fichiers et de répertoires sont considérés comme des modifications majeures et nécessitent une validation explicite.

Lorsqu'un fichier semble inutilisé, l'agent doit le signaler avant toute suppression.

## Suppressions

Les suppressions de code existant doivent être limitées au strict nécessaire.

Tout bloc supprimé doit être justifié.

La suppression d'un fichier ou d'un répertoire nécessite une validation explicite.

## Fichiers générés

Les fichiers temporaires ou les artefacts de construction explicitement identifiés comme régénérables peuvent être supprimés puis recréés.

Cette règle ne s'applique pas aux fichiers générés et versionnés suivants :

.gitignore
AGENTS.md
LICENSE
README.md
.opencode/commands/
.opencode/skills/
.opencode/config/opencode.json
openspec/config.yaml
openspec/changes/
openspec/specs/

Toute suppression ou régénération de ces éléments nécessite une validation explicite.

## Sources du projet

Tous les fichiers et répertoires situés dans le projet et qui ne sont pas explicitement exclus peuvent être utilisés comme sources :

de code ;
de documentation ;
d'informations techniques ;
d'informations fonctionnelles.

Les éléments explicitement exclus ne doivent pas être lus, analysés, indexés ou utilisés comme sources du projet.

## Sources exclues du projet

Les agents ne doivent jamais lire, analyser, indexer ou utiliser les éléments suivants comme sources de code, de documentation ou de spécifications fonctionnelles :

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
env/Debian Installer Unifié (DIU)
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
venv/Debian Installer Unifié (DIU)

## Sources incluses et protégées

Lorsqu'un fichier correspond à la fois à une règle d'exclusion générale et à une inclusion explicite dans cette section, l'inclusion explicite prévaut.

Les agents peuvent consulter les éléments suivants pour les besoins techniques liés à OpenCode, OpenSpec ou Git :

.gitignore
AGENTS.md
LICENSE
README.md
.opencode/commands/
.opencode/config/opencode.json
.opencode/skills/
openspec/AGENTS.md
openspec/config.yaml
openspec/changes/
openspec/specs/
output/
reports/

Ces éléments ne constituent pas nécessairement une source de vérité fonctionnelle.

Leur modification nécessite une demande ou une validatiDebian Installer Unifié (DIU)on explicite portant sur :

OpenCode ;
OpenSpec ;
Git ;
la production de rapports techniques.

Les répertoires output/ et reports/ :

ne doivent pas être versionnés dans Git ;
peuvent contenir des résultats ou rapports temporaires ;
peuvent être lus ;
ne constituent pas une source de vérité du projet ;
ne doivent être créés, modifiés ou supprimés que dans le cadre d'une demande explicite.

## Secrets

Aucun secret ne doit être :

ajouté au dépôt Git ;
transmis au modèle ;
affiché dans les journaux ;
analysé ;
indexé.

Les fichiers identifiés comme sensibles ne doivent pas être ouverts.

L'agent peut uniquement signaler leur présence à partir de leur nom ou de leur chemin.

Les données sensibles interdites comprennent notamment :

les mots de passe ;
les clés privées ;
les clés SSH ;
les jetons d'API ;
les certificats ;
les identifiants de connexion.

Les secrets doivent être externalisés des fichiers versionnés et des sources accessibles aux agents.

Ils peuvent être stockés dans un emplacement local non versionné explicitement prévu à cet effet, notamment .opencode/share/,
à condition que cet emplacement soit exclu de Git, de la lecture par les agents et de l’indexation.

## Sécurité

Les agents doivent privilégier :

le principe du moindre privilège ;
la validation des entrées ;
l'absence de données sensibles dans les journaux ;
des permissions minimales sur les fichiers créés ;
une gestion explicite des erreurs.

## Docker

Les agents ne doivent jamais supposer qu'ils disposent d'un accès à l'ensemble de la machine hôte.

Ils ne doivent jamais modifier sans validation explicite :

les montages Docker ;
les volumes ;
les droits d'accès du conteneur ;
les utilisateurs du conteneur ;
les permissions accordées au conteneur.

## Git

Les agents ne doivent jamais :

modifier le contenu du répertoire .git/ ;
réécrire l'historique Git ;
supprimer des commits ;
effectuer un push sans validation explicite ;
modifier la configuration Git du dépôt sans validation explicite ;
créer, modifier ou supprimer des branches sans validation explicite ;
modifier les sous-modules sans validation explicite ;
créer ou modifier des hooks Git sans validation explicite.

## Commit

Les commits doivent rester atomiques.

Chaque commit doit correspondre à une seule modification clairement identifiable.

Un commit ne doit pas mélanger :

une correction ;
un refactoring ;
une évolution fonctionnelle ;
une mise à jour documentaire indépendante.
Avant un commit

Avant toute proposition de commit, les agents doivent :

vérifier la syntaxe ;
examiner les fichiers modifiés ;
vérifier que seuls les fichiers attendus sont modifiés ;
vérifier qu'aucun secret n'a été ajouté ;
exécuter les vérifications disponibles ;
expliquer clairement le contenu du commit.

## Bash et scripts Shell

Les scripts doivent rester compatibles avec la version de Bash installée par défaut sur les versions Debian supportées par le projet.

Les constructions POSIX doivent être privilégiées lorsqu'elles permettent d'obtenir le même résultat simplement.

Les fonctionnalités spécifiques à une version récente de Bash ne doivent être utilisées qu'en cas de nécessité clairement justifiée.

Les scripts doivent pouvoir être analysés avec :

bash -n

et, lorsque l'outil est disponible :

shellcheck

Les scripts doivent être robustes.

Les variables doivent être protégées par des guillemets lorsque nécessaire.

Les commandes dont l'échec est attendu doivent être explicitement gérées.

Les erreurs doivent être :

détectées ;
traitées ;
signalées clairement.

Les erreurs ne doivent jamais être ignorées silencieusement.

## Variables

Les variables de configuration doivent rester cohérentes avec les spécifications du projet.

Les noms existants doivent être conservés lorsqu'ils sont suffisamment explicites.

Les renommages purement esthétiques sont interdits.

Les valeurs codées en dur doivent être évitées.

Une nouvelle variable ne doit pas être ajoutée lorsqu'une variable existante répond déjà au besoin.

Toute nouvelle variable de configuration doit être documentée dans les spécifications OpenSpec.

Les variables à portée globale seront notées en MAJUSCULE.

Les variables à portée locale seront notées en minuscule.

Le sepérateur entre deux mots dans une variable sera toujours le caractères _ (underscore).

Les nouvelles variables seront exprimées en anglais.

## Chemins

Les chemins absolus ne doivent être utilisés que lorsqu'ils sont imposés par le projet.

Les scripts doivent privilégier des chemins relatifs au projet lorsqu'ils permettent de conserver la portabilité.

Compatibilité et portabilité

Toute modification doit préserver la compatibilité avec les installations existantes.

Les comportements attendus ne doivent pas être modifiés sans spécification validée.

Les changements incompatibles doivent être explicitement signalés.

Le projet doit rester compatible avec les versions stables de Debian supportées par le projet.

Toute dépendance spécifique à une distribution ou à une version particulière doit être explicitement documentée.

## Idempotence

Les scripts d'installation doivent être idempotents lorsque cela est raisonnablement possible.

Une seconde exécution ne doit pas provoquer d'effets de bord inattendus.

## Dépendances et outils externes

Les agents doivent privilégier les outils présents dans une installation Debian standard.

Aucune nouvelle dépendance ne doit être ajoutée sans justification et validation explicite.

Toute nouvelle dépendance doit être documentée.

Une dépendance existante doit être privilégiée lorsqu'elle répond déjà au besoin.

## Conventions et style du projet

Les conventions existantes de nommage, d'organisation, de formatage et d'architecture doivent être respectées.

Une convention existante ne doit pas être modifiée sans validation explicite.

En cas d'ambiguïté, l'agent doit privilégier la cohérence avec le code et les conventions existantes.

Le style de codage actuel doit être conservé autant que possible.

## Lisibilité

Les agents doivent privilégier :

des fonctions courtes ;
des noms explicites ;
une indentation homogène ;
des commentaires utiles ;
des traitements simples.

La simplicité doit être privilégiée à l'optimisation prématurée.

## Principe KISS

Les agents doivent privilégier la solution la plus simple répondant correctement au besoin.

Toute complexité inutile doit être évitée.

## Commentaires

Les commentaires existants doivent être conservés lorsqu'ils restent exacts.

Les nouveaux commentaires doivent apporter une information utile et ne pas simplement répéter le code.

Les agents ne doivent pas introduire de commentaires TODO, FIXME ou HACK sans validation explicite.

Une tâche incomplète doit être décrite dans OpenSpec plutôt que laissée dans le code.

## Documentation

Toute évolution importante doit être accompagnée, lorsque nécessaire, de la mise à jour :

des spécifications ;
de la documentation ;
des commentaires concernés.

La documentation ne doit pas être modifiée pour des éléments sans rapport avec la demande en cours.

## Encodage

Tous les fichiers texte doivent utiliser :

l'encodage UTF-8 ;
les fins de ligne Unix LF.

Les fins de ligne Windows CRLF sont interdites.

## Journalisation et messages

Les messages affichés par les scripts doivent être :

explicites ;
cohérents ;
utiles au suivi de l'avancement ;
utiles au diagnostic des erreurs.

Les messages ne doivent jamais :

masquer un échec ;
ignorer silencieusement une erreur ;
afficher des données sensibles ;
modifier le comportement fonctionnel attendu.

## Robustesse

Les agents doivent privilégier :

une gestion explicite des erreurs ;
des messages d'erreur compréhensibles ;
des codes de retour explicites ;
des traitements idempotents lorsque cela est possible ;
la validation des entrées.

## Lecture minimale

Les agents doivent limiter la lecture des fichiers au strict nécessaire.

Ils ne doivent pas parcourir récursivement l'ensemble du dépôt lorsqu'une lecture ciblée permet de répondre à la demande.

Ils doivent privilégier :

les recherches ciblées ;
les ouvertures partielles de fichiers ;
les lectures incrémentales ;
les répertoires directement concernés.

## Tests et vérifications

Lorsqu'un mécanisme de test existe, les agents doivent l'exécuter avant toute proposition de validation.

Pour les scripts Bash, les vérifications minimales sont :

bash -n

et, lorsque disponible :

shellcheck

Avant toute proposition de validation, les agents doivent vérifier :

la syntaxe des langages utilisés ;
l'absence d'erreur évidente ;
la cohérence des fichiers modifiés ;
la conformité avec les spécifications ;
l'absence de modification hors périmètre.

## Licences

Les en-têtes de licence existants doivent être conservés.

Aucune licence ne doit être modifiée sans validation explicite.

## Priorité

En cas de contradiction, l'ordre de priorité suivant s'applique :

les demandes explicites du développeur ;
les spécifications OpenSpec validées ;
les règles de sécurité et de travail définies dans AGENTS.md ;
la documentation officielle du projet ;
le code existant.

Le code existant ne constitue pas une référence lorsqu'il contredit une spécification validée.

En cas de conflit entre l'optimisation du code et la stabilité du projet, la stabilité du projet est prioritaire.

## Validation du développeur

Une validation explicite correspond à une demande ou une confirmation claire du développeur autorisant l'action concernée.

En l'absence d'une telle validation, l'agent doit limiter son intervention à des propositions ou des analyses.

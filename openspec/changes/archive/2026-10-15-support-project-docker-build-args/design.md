# Design — Arguments de BUILD publics

## Context

`projects_docker_build` charge les métadonnées selon son contrat existant,
contrôle Dockerisation et fichiers requis, puis appelle runuser/Docker.
Le lecteur ne change ni cette sélection ni le pipeline CI/CD.

## Goals / Non-Goals

Permettre à chaque projet d'exprimer ses arguments publics, sans dépendance
applicative dans DIU. Ne pas exécuter un helper de projet, interpréter un
fichier comme un script, charger d'autres configurations, déduire des secrets
ou publier un artefact.

## Decisions

Chemin fixe : `build/docker-build.args`. Absence ou fichier vide : aucun
argument supplémentaire. Une ligne utile suit `[A-Za-z_][A-Za-z0-9_]*=VALEUR`.
Les lignes blanches et commentaires # après indentation sont ignorés. Espaces,
dollars, antislashs, quotes, # et = de la valeur restent littéraux. Une valeur
vide reste vide. Une dernière ligne sans LF est acceptée ; CR et NUL refusés.

Le lecteur Bash utilise un tableau résultat, un tableau temporaire et un
ensemble de clés. Le résultat n'est affecté qu'après validation complète.
La locale ASCII reste locale au lecteur. Taille maximale : 65 536 octets ;
stat appartient aux outils Debian de base. Fichier régulier et lisible,
fichier et répertoire build non symboliques. Aucune réécriture ou modification
de droits. La lecture bornée détecte NUL, conserve le texte et ferme son
descripteur avant analyse. Diagnostics : catégorie et éventuellement numéro
de ligne, jamais clé libre ou valeur.

Le fichier public ne transporte pas de secrets. La syntaxe ne peut pas
classifier une valeur arbitraire ; le contenu reste sous la responsabilité
du projet. Les sorties natives Docker suivent leurs règles ; le DIU ne
promet pas de masquer un secret fourni en ARG.

Les paires validées précèdent le contexte Docker. Un refus empêche Docker.
Un échec Docker conserve le retour non nul existant. DIU ne connaît ni le
format de référence interne du consommateur, ni ses outils ou versions.

## Risks / Trade-offs

Les quotes font partie de la valeur. Doublons, chemins symboliques et fichiers
hors limite sont refusés explicitement, sans nouvelle priorité implicite.
Les tests rebasent seulement le chemin racine historique du module dans une
copie éphémère ; runuser et Docker sont simulés, sans configuration réelle.

## Migration Plan

Aucune migration globale. Un consommateur ajoute son fichier public et son
contrôle de cohérence. Retirer ce fichier restaure le parcours sans arguments,
sous sa responsabilité si les arguments sont obligatoires.

## Validation

Fixtures internes au dépôt, tableaux capturés, aucune évaluation shell,
erreurs sans valeurs, fichier intact, invalides avant Docker, contrôles
existants prioritaires. Bash -n, ShellCheck et syntaxe Python. Contrôle du
consommateur dans son dépôt et BUILD local avec le lecteur sans configuration
sensible ni pipeline CI/CD. Validation OpenSpec stricte, revue documentaire,
archivage ciblé puis rapport à six sections.

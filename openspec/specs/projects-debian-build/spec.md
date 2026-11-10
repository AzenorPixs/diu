# projects-debian-build Specification

## Purpose
Construire un paquet Debian depuis une recette publique propre au projet,
sans imposer les métadonnées ou l'arborescence du DIU.

## Requirements

### Requirement: Commande générique et activation

DIU SHALL accepter diu projects build debian <ID PROJECT> et son alias compatible
diu projects build deb <ID PROJECT> pour un enfant direct non symbolique de
ENV_DEVOPS_PROJECTS_ROOT. Il SHALL lire PROJECT_DEBIAN_PACKAGE sans exécuter
project.env et SHALL construire uniquement pour Yes, YES ou 1.

#### Scenario: Projet désactivé
- **WHEN** la variable est absente, vide ou différente des trois valeurs actives
- **THEN** la commande informe que le projet ne produit aucun paquet Debian, réussit sans construction et ne recherche pas la recette

#### Scenario: Arguments invalides
- **WHEN** l'identifiant manque, est invalide ou des arguments supplémentaires sont fournis
- **THEN** la commande échoue avec une aide avant le bootstrap

#### Scenario: deux syntaxes équivalentes
- **WHEN** debian ou deb est utilisé avec le même identifiant de projet
- **THEN** le même moteur reçoit les mêmes arguments et produit le même paquet

### Requirement: Recette déclarative obligatoire
Le moteur SHALL utiliser build/debian-package.json pour les métadonnées et les copies. Il SHALL refuser une recette absente, illisible, symbolique ou invalide, sans exécuter son contenu ni l'inclure dans le paquet.

#### Scenario: Recette absente
- **WHEN** le packaging est activé et la recette est absente
- **THEN** le message indique son chemin et que le paquet ne peut pas être construit, avec un code non nul et sans artefact

#### Scenario: Projet indépendant du DIU
- **WHEN** une recette valide définit un autre nom, une autre architecture et des sources sans arborescence DIU
- **THEN** le paquet utilise ces métadonnées et destinations

### Requirement: Isolation des copies et validation
Le moteur SHALL valider les métadonnées et les chemins avant construction. Il SHALL refuser traversées, sources symboliques, destinations recouvrantes, recette embarquée et éléments privés ou temporaires reconnus. Les sources SHALL rester dans le projet et les destinations dans le staging hors DEBIAN.

#### Scenario: Copie interdite
- **WHEN** une source contient la recette, dist, un lien symbolique ou un élément interdit
- **THEN** la construction échoue et les anciens paquets sont conservés

### Requirement: Version et construction locale

PROJECT_VERSION SHALL être prioritaire sur la version littérale de la recette. Sans cette clé, la recette MAY fournir une version ; sinon le moteur SHALL sélectionner l’unique version valide des tags de HEAD après exclusion des horodatages lorsqu'un tag stable est présent, ou l’heure locale sans Git ou tag. Le moteur SHALL construire avec dpkg-deb --root-owner-group depuis les fichiers de travail.

#### Scenario: Version ambiguë
- **GIVEN** PROJECT_VERSION est absente de project.env
- **WHEN** HEAD porte plusieurs versions distinctes après application de la priorité stable, un tag invalide ou sa consultation échoue
- **THEN** la construction échoue sans modifier dist

#### Scenario: Publication réussie
- **WHEN** dpkg-deb réussit
- **THEN** dist reçoit package_version_architecture.deb et seuls les anciens paquets de même nom et architecture sont supprimés

#### Scenario: Construction échouée
- **WHEN** la préparation, la construction ou le déplacement échoue
- **THEN** la commande échoue, nettoie les temporaires et ne lance pas la rotation

#### Scenario: Tag stable et horodaté
- **WHEN** HEAD porte une seule version stable et un ou plusieurs tags horodatés
- **THEN** le constructeur retient la version stable

### Requirement: Équivalence DIU et compatibilité
La recette DIU SHALL reproduire les métadonnées, le contenu et les propriétaires du constructeur historique à version identique. Les modes SHALL être équivalents sauf pour le point d'entrée DIU, dont le mode SHALL être 0755 indépendamment de la source. Les commandes historiques projects deb et cicddiu SHALL conserver leur comportement.

#### Scenario: Comparaison DIU
- **WHEN** les deux constructeurs utilisent les mêmes sources et la même version
- **THEN** les métadonnées et le contenu extrait sont équivalents, les modes sont équivalents sauf pour le point d'entrée DIU fixé à 0755, et la recette est absente du paquet

### Requirement: Fichiers de configuration dans la recette Debian

Chaque copie MAY déclarer `conffile: true` pour inscrire sa destination dans `DEBIAN/conffiles` ; la source SHALL être un fichier régulier. Chaque copie MAY déclarer `empty_json: true` pour exiger un tableau JSON vide dans le fichier copié. Les contrôles SHALL précéder la publication du paquet.

#### Scenario: Conffile déclaré
- **WHEN** une copie de fichier valide déclare `conffile: true`
- **THEN** sa destination absolue est inscrite dans `DEBIAN/conffiles`.

#### Scenario: Modèle JSON non vide
- **WHEN** une copie déclarant `empty_json: true` ne contient pas un tableau JSON vide
- **THEN** la construction échoue sans remplacer le paquet précédent.

#### Scenario: Recette sans nouveaux attributs
- **WHEN** une recette existante ne déclare aucun de ces attributs
- **THEN** son comportement et sa validation restent inchangés.

### Requirement: Mode explicite des fichiers dans la recette Debian

Chaque copie MAY déclarer `mode` comme chaîne de quatre chiffres octaux, de `0000` à `0777`, pour fixer les permissions du fichier régulier copié. Le constructeur SHALL refuser les modes invalides et les sources autres que des fichiers réguliers avant publication. Il SHALL appliquer le mode au fichier copié sans modifier la source. En l'absence de `mode`, le comportement existant SHALL rester inchangé.

#### Scenario: Mode exécutable explicite
- **GIVEN** une source régulière non exécutable et une recette déclarant `mode: "0755"`
- **WHEN** le paquet est construit
- **THEN** le fichier dans le paquet possède le mode 0755 et la source conserve son mode

#### Scenario: Mode ou source invalide
- **WHEN** un mode invalide ou un mode sur une source non régulière est déclaré
- **THEN** la construction échoue sans remplacer le paquet précédent

#### Scenario: Recette DIU
- **WHEN** le paquet DIU est construit à partir de sa recette
- **THEN** `/root/diu/root-install-debian.sh` possède le mode 0755 indépendamment de celui de sa source

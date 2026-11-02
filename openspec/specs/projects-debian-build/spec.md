# projects-debian-build Specification

## Purpose
Construire un paquet Debian depuis une recette publique propre au projet,
sans imposer les métadonnées ou l'arborescence du DIU.

## Requirements

### Requirement: Commande générique et activation
DIU SHALL accepter `rid projects build deb <ID PROJECT>` pour un enfant direct non symbolique de DEVOPS_PROJECTS_ROOT. Il SHALL lire PROJECT_DEBIAN_PACKAGE sans exécuter project.env et SHALL construire uniquement pour Yes, YES ou 1.

#### Scenario: Projet désactivé
- **WHEN** la variable est absente, vide ou différente des trois valeurs actives
- **THEN** la commande informe que le projet ne produit aucun paquet Debian, réussit sans construction et ne recherche pas la recette

#### Scenario: Arguments invalides
- **WHEN** l'identifiant manque, est invalide ou des arguments supplémentaires sont fournis
- **THEN** la commande échoue avec une aide avant le bootstrap

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

PROJECT_VERSION SHALL être prioritaire sur la version littérale de la recette. Sans cette clé, la recette MAY fournir une version ; sinon le moteur SHALL sélectionner l’unique version valide des tags de HEAD sans préfixe v, ou l’heure locale sans Git ou tag. Le moteur SHALL construire avec dpkg-deb --root-owner-group depuis les fichiers de travail.

#### Scenario: Version ambiguë
- **GIVEN** PROJECT_VERSION est absente de project.env
- **WHEN** HEAD porte plusieurs versions distinctes, un tag invalide ou sa consultation échoue
- **THEN** la construction échoue sans modifier dist

#### Scenario: Publication réussie
- **WHEN** dpkg-deb réussit
- **THEN** dist reçoit package_version_architecture.deb et seuls les anciens paquets de même nom et architecture sont supprimés

#### Scenario: Construction échouée
- **WHEN** la préparation, la construction ou le déplacement échoue
- **THEN** la commande échoue, nettoie les temporaires et ne lance pas la rotation

### Requirement: Équivalence DIU et compatibilité
La recette DIU SHALL reproduire les métadonnées, contenu, modes et propriétaires du constructeur historique à version identique. Les commandes historiques projects deb et cicddiu SHALL conserver leur comportement.

#### Scenario: Comparaison DIU
- **WHEN** les deux constructeurs utilisent les mêmes sources et la même version
- **THEN** les métadonnées et le contenu extrait sont équivalents et la recette est absente du paquet

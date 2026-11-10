## ADDED Requirements

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

## MODIFIED Requirements

### Requirement: Équivalence DIU et compatibilité
La recette DIU SHALL reproduire les métadonnées, le contenu et les propriétaires du constructeur historique à version identique. Les modes SHALL être équivalents sauf pour le point d'entrée DIU, dont le mode SHALL être 0755 indépendamment de la source. Les commandes historiques projects deb et cicddiu SHALL conserver leur comportement.

#### Scenario: Comparaison DIU
- **WHEN** les deux constructeurs utilisent les mêmes sources et la même version
- **THEN** les métadonnées et le contenu extrait sont équivalents, les modes sont équivalents sauf pour le point d'entrée DIU fixé à 0755, et la recette est absente du paquet

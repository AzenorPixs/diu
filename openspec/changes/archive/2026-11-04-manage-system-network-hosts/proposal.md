# Gestion système du fichier hosts

## Pourquoi

La génération du fichier hosts se trouve dans le script monolithique et ne dispose pas de commande système dédiée.

## Modification

Déplacer sa génération dans le module réseau système, exposer les commandes de mise à jour et les intégrer aux mises à jour globales et aux aides. Le fichier généré ne comprend plus les noms Docker auparavant ajoutés automatiquement ; les entrées préexistantes sont remplacées. Le change est sans code de lot attribué.

## Périmètre exclu

La détection des interfaces physiques existante et la configuration réseau extérieure au fichier hosts ne changent pas.

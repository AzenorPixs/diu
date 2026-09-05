## Context

variables.sh est une configuration locale potentiellement sensible, chargée avant les modules. SYSTEM_DEBIAN_RELEASE est déjà générée dynamiquement.

## Goals / Non-Goals

Supprimer les affectations historiques sans afficher ni sourcer leur contenu pendant le nettoyage. Préserver les autres variables et le générateur existant.

## Decisions

Charger modules/system/variables-cleanup.sh avant variables.sh et appeler config_cleanup explicitement. Le chemin par défaut reste /root/diu/variables.sh ; un argument de fonction permet les tests isolés sans ajouter de variable de configuration. Cibler les affectations simples sur une ligne, avec espaces initiaux et export optionnel. Vérifier la présence avant sed -i pour éviter toute réécriture au second passage. Propager les erreurs de lecture et d’écriture avec un diagnostic sans contenu de configuration. Ne pas recopier la valeur historique vers la nouvelle variable : elle est détectée par le générateur existant.

## Risks / Trade-offs

Les déclarations multilignes ou les commandes shell composées ne font pas partie du format d’affectation simple pris en charge. Le nettoyage doit précéder le source afin de ne pas charger l’ancienne déclaration.

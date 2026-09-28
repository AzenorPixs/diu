## Context
Le chargeur découvre automatiquement les déclarations. La configuration historique est nettoyée avant sourcing.

## Goals / Non-Goals
Initialiser une valeur statique à partir du système, puis la conserver. Ne pas changer le fuseau réel pendant les tests ni reprendre TIME_ZONE.

## Decisions
Utiliser timedatectl show --property=Timezone --value. Une commande absente, en échec ou une réponse vide produit Europe/Paris avec diagnostic stderr. Persister avec échappement Bash avant export ; une erreur de persistance reste bloquante. Conserver toute valeur déjà définie, même vide. Le nettoyage reste limité aux affectations simples.

## Risks / Trade-offs
La préférence historique est supprimée sans sauvegarde au prochain démarrage. Le fuseau local détecté devient la nouvelle valeur statique. Les archives OpenSpec historiques sont conservées.

## Migration Plan
Déployer les sources ; le bootstrap nettoiera la configuration historique puis initialisera la nouvelle variable. Aucun nettoyage de configuration réelle pendant cette session.

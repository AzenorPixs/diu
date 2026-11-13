# Conception

Le moteur commun orchestre détection, opération d'installation ou de désinstallation, configuration et nettoyage. Chaque moteur fournit des adaptateurs de configuration et de nettoyage qui délèguent aux traitements du logiciel ; une opération sans effet représente explicitement l'absence de traitement. La configuration s'exécute après le succès de l'opération d'installation et à chaque convergence d'un état désiré installé. Le nettoyage ne s'exécute qu'après confirmation de l'absence à l'issue de la désinstallation.

Les vérifications préalables nécessaires à une désinstallation sûre restent distinctes du nettoyage. Les règles de ressources partagées syslog et CrowdSec sont conservées. Les configurations existantes sont revues pour garantir l'idempotence et préserver les données personnelles ; les échecs sont propagés.

Les tests couvrent les trois moteurs, les transitions et états déjà conformes, les échecs, les rôles partagés et la configuration Zsh. Les moteurs DevOps, Docker et IA restent hors périmètre.

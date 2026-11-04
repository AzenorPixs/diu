## ADDED Requirements

### Requirement: Génération DevOps de tous les projets configurés

DIU SHALL exposer rid projects template all devops et projects_template_devops_all.
La fonction SHALL utiliser DEVOPS_PROJECTS_ROOT, sinon /home/${ENV_DEVOPS_USER}/datas,
et parcourir uniquement ses dossiers directs, y compris les dossiers cachés.
Elle SHALL sélectionner les project.env ordinaires dont les affectations
littérales PROJECT_ID, PROJECT_NAME, PROJECT_TYPE, PROJECT_DOCKERED et
PROJECT_DEBIAN_PACKAGE sont toutes non vides. PROJECT_ID SHALL correspondre
au nom du dossier. Les valeurs 0 et No SHALL être acceptées comme renseignées.
La sélection SHALL NOT exécuter project.env, utiliser des valeurs héritées
du shell ou afficher des valeurs de configuration. Les dossiers et fichiers
project.env symboliques SHALL être ignorés. Les projets incomplets, absents,
illisibles ou invalides SHALL être signalés puis ignorés.

#### Scenario: Projets complets

- **WHEN** plusieurs dossiers dont template contiennent les cinq variables renseignées et un PROJECT_ID conforme
- **THEN** projects_template_devops est appelée une fois pour chaque dossier éligible
- **AND THEN** les configurations restent isolées entre projets

#### Scenario: Projet incomplet ou identifiant discordant

- **WHEN** une variable requise manque ou est vide, ou PROJECT_ID diffère du dossier
- **THEN** le projet est ignoré avec un message et aucun de ses fichiers n'est généré

#### Scenario: Configuration contenant une commande

- **WHEN** une affectation du project.env contient une expression de commande
- **THEN** aucune commande n'est exécutée et une configuration inéligible ne déclenche aucune génération

#### Scenario: Dossier nommé all

- **WHEN** le dossier all remplit les critères
- **THEN** la boucle appelle directement projects_template_devops avec all sans relancer le traitement groupé

### Requirement: Bilan et poursuite du traitement groupé

La fonction SHALL conserver le comportement de génération individuelle et
l'appel en fin de création. Elle SHALL poursuivre après un échec individuel,
afficher les nombres de projets sélectionnés, réussis, ignorés et échoués,
et rendre un code non nul si une génération échoue. Sans projet éligible,
elle SHALL afficher un message et rendre un succès. Une racine absente,
un utilisateur DevOps invalide ou un Python système absent SHALL provoquer
une erreur avant génération. La commande SHALL refuser les arguments
supplémentaires et les opérations inconnues.

#### Scenario: Échec puis réussite

- **WHEN** une génération échoue et un projet suivant est éligible
- **THEN** le projet suivant est traité et le bilan compte l'échec
- **AND THEN** le code final est non nul

#### Scenario: Aucun projet éligible

- **WHEN** la racine existe mais aucun dossier ne remplit les critères
- **THEN** la commande signale l'absence de projet éligible et rend un succès

#### Scenario: Racine absente

- **WHEN** la racine configurée n'existe pas
- **THEN** la commande échoue sans créer de dossier ou de document

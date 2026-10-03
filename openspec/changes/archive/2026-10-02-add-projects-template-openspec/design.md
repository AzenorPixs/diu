## Contexte

La commande template ne route actuellement que devops. create_project termine
par l'attribution des droits puis projects_template_devops.

## Décisions

Ajouter projects_template_openspec dans le module template existant. Le chemin
utilise DEVOPS_PROJECTS_ROOT, sinon /home/${ENV_DEVOPS_USER}/datas. Valider
l'identifiant, le compte et les chemins avant su. Le dossier openspec marque
la présence d'OpenSpec, y compris lorsqu'il provient de la copie du modèle.
Un lien symbolique ou une cible non répertoire est rejeté.

La commande enfant utilise un chemin entre apostrophes avec échappement des
apostrophes internes, compatible avec le shell de connexion. Elle commence
par cd puis exécute exactement l'une des trois commandes demandées. Aucun
project.env n'est lu pour cette opération. OPENCODE est la configuration DIU
existante et doit valoir 0 ou 1 pour une initialisation.

L'identifiant all désigne un seul projet pour openspec ; seul all devops
conserve la génération groupée existante. Les aides terminales restent sans
chargement de configuration ni mutation.

## Erreurs et repli

Un échec de su ou d'OpenSpec rend un code non nul et un diagnostic. La création
conserve le projet préparé, sans lancer DevOps ni afficher de succès.
OpenSpec peut laisser des écritures partielles ; aucun nettoyage automatique
ni retour arrière des écritures de l'outil n'est ajouté.

## Validation

Tests avec su et openspec simulés : les trois branches, utilisateur,
répertoire, échappement, réexécution, prérequis et propagation des erreurs.
Tests d'ordre droits → OpenSpec → DevOps, d'échec de création, de dispatch et
d'aide help/?. Bash -n, ShellCheck et validations strictes du change et des
trois capacités après synchronisation. Aucun projet réel n'est initialisé.

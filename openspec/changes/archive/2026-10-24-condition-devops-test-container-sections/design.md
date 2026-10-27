## Contexte et décision

Le rendu commun `projects_template_devops_render` sert les générations individuelle,
groupée et finale de création. La sélection reste dans ce rendu et utilise les
variables déjà chargées par DIU, sans relire project.env pour ces indicateurs.
Une valeur absente, vide ou différente de la chaîne exacte `1` omet sa rubrique.

La boucle existante reçoit un emplacement LXC immédiatement après Docker.
Docker désactivé est sauté avant toute résolution ou sonde de son binaire.
LXC activé émet seulement les trois puces fixes demandées. Docker-Compose reste
indépendant. Le titre Docker est ajusté dans le helper existant.

## Portée des informations

La version et le chemin Docker restent observés, sans figer les exemples du
DEVOPS.md actuel. Socket et image restent documentaires. « Debian 13 » et
« Accès TPM OK » sont des mentions LXC déclaratives demandées par le développeur ;
elles ne prouvent ni une connexion distante, ni une qualification TPM.
Aucune commande LXC et aucune lecture d'identifiants n'est ajoutée.

## Risques et repli

Avec les indicateurs initialisés à 0, les rubriques sont désormais absentes.
Une valeur invalide reste silencieusement désactivante conformément au contrat
validé, sans publication de sa valeur. Les autres sondes sont préservées.
Le repli consiste à rétablir le générateur précédent puis régénérer normalement
les documents ; aucune migration de données n'est nécessaire.

## Validation et documentation

Les tests isolés couvrent les quatre combinaisons, les valeurs absentes, vides
et invalides, l'ordre, les puces, l'absence de sonde Docker désactivée, les
réexécutions et les parcours groupé et création. Syntaxe Bash/Python, ShellCheck,
UTF-8/LF et OpenSpec complètent ces contrôles.
TECHNICAL.md, README.md et CHANGELOG.md sont ajustés ; AGENTS.md, PROJECT.md et
BUILD.md ne changent pas car les règles, l'architecture et le packaging sont
inchangés. DEVOPS.md reste un inventaire historique généré, sans retouche manuelle.

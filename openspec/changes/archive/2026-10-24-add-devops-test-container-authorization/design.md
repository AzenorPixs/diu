## Décision

Une fonction de rendu commune émet la puce d'autorisation exacte. La section
Docker l'appelle après l'image ; la section LXC l'appelle après « Accès TPM OK ».
La même formulation est ainsi garantie pour les parcours individuel, groupé
et final de création, sans nouvelle variable de configuration.

Les contrôles indépendants d'activation sont conservés. Une rubrique absente
n'émet pas d'autorisation orpheline. Docker indisponible conserve ses diagnostics
et reçoit la puce si son indicateur vaut 1. Les autres rubriques ne la reçoivent pas.

## Portée et limites

L'autorisation validée couvre les opérations de test citées, avec droits root,
dans le conteneur et les ressources dédiées aux tests. La génération de texte
ne change aucun contrôle technique imposé par un outil ou une plateforme.
Elle ne lance aucun conteneur ni aucune opération de test réelle et ne lit
aucun identifiant LXC. Les mentions LXC existantes restent déclaratives.

## Risques et repli

La phrase « Toute autorisation pour tests » serait ambiguë sur les acteurs,
les actions et le périmètre. La formulation validée rend ces éléments explicites.
Les documents existants adoptent la nouvelle puce à leur prochaine génération.
Aucune migration de données n'est nécessaire ; le repli consiste à rétablir
le générateur précédent puis à régénérer normalement les documents.

## Vérifications et cohérence

Adapter les assertions communes pour vérifier la dernière puce exacte, sa
position, le nombre de puces et son absence dans les autres rubriques.
Les scénarios existants couvrent les indicateurs désactivés, les répétitions,
les erreurs Docker et les trois parcours. Ajouter un contrôle de l'échec
d'écriture de la puce pour que cet échec soit propagé par les deux rendus.
Exécuter la suite du générateur avec le Python DevOps, bash -n, ShellCheck,
compilation Python, validations OpenSpec et UTF-8/LF.

Mettre à jour TECHNICAL.md, README.md et CHANGELOG.md. Conserver AGENTS.md,
PROJECT.md et BUILD.md : les règles, l'architecture et le packaging ne changent
pas. DEVOPS.md reste un inventaire généré sans retouche manuelle.

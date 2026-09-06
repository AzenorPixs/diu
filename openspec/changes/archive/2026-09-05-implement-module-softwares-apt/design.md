# Design : moteur APT du module softwares

Le module `softwares` expose un routeur de commandes `softwares` séparé du
routeur historique. Le moteur valide le logiciel demandé, sélectionne une
sous-fonction explicitement déclarée et propage tout échec avec un code non nul.

L'infrastructure définit le contrat des sous-fonctions explicites par logiciel,
mais n'en fournit aucune dans cette évolution. En l'absence de recette, le
moteur signale l'action comme non prise en charge sans appeler APT. Aucun nom
de fonction ne doit être construit puis exécuté directement à partir de
l'entrée utilisateur.

La mise à jour globale APT est une fonction du module `softwares`. Elle exécute
la mise à jour des paquets installés avec APT une seule fois par invocation et
ne déclenche aucune des opérations granulaires des logiciels déclarés.

Le dispatch principal ajoute le contexte `softwares`. Le contexte historique
`install|remove` reste préservé pendant la migration, sauf lorsqu'une
spécification indique explicitement son remplacement.

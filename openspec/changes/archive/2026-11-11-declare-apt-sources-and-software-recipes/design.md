## Décisions validées
Les opérations restent génériques. Les recettes et hooks propres aux logiciels sont fournis par les déclarations GLOBAL ; les helpers communs restent dans les moteurs. Les fonctions peuvent être chargées sans initialiser ni modifier les valeurs.

Les sources actives .list et .sources sont lues littéralement, sans évaluation. Une erreur de lecture ou une source active mal formée bloque la détection, sans transformer une inconnue en absence. Les fichiers désactivés et commentaires sont exclus. La détection est une présence de déclaration, pas une preuve de disponibilité réseau ni de signature.

Une valeur existante valide est préservée. Une variable absente est initialisée d’après les sources réelles ; pas d’activation déduite du seul souhait logiciel. Les dépôts versionnés gardent leurs branches. Le nouveau firmware est détecté indépendamment sans copie aveugle de l’ancien interrupteur.

Les prérequis déclarés sont cumulatifs : composants Debian, dépôts tiers, paquet direct. Leur préparation vérifie la variable et l’état des sources ; une modification précède la régénération et la mise à jour des index. Aucune désactivation automatique d’un dépôt partagé au retrait d’un logiciel.

La présence d’une déclaration deb-src suffit à constater un dépôt déclaré à l’initialisation, mais ne prouve pas la disponibilité de paquets binaires. La préparation d’une installation vérifie donc spécifiquement les entrées deb, puis rafraîchit les index avant une transaction réelle.

Les recettes DevOps, Docker et IA et leurs dépendances restent inchangées. Seuls les blocs historiques SOFTWARES_APT du monolithe sont retirés ; les contrôles firewall existants restent en place. Les tests utilisent des sources temporaires et des doubles ; intégration Debian isolée avant livraison.

Extension explicitement validée : un appel au helper SYSTEM prépare non-free dans la branche d’installation Chromium du bureau. Ce changement de prérequis ne déplace ni ne modifie les paquets de la recette, et ne concerne pas les environnements exclus.

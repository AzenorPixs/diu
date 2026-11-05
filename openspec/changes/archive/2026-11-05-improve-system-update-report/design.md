# Conception

La phase APT conserve sa configuration, sa mise à jour, dist-upgrade, autoclean, autopurge, autoremove et les prérequis. Capturer sa sortie et comparer les états dpkg réels ; ne pas masquer les erreurs. Les logiciels APT sont capturés avant la phase système et affichés ensuite ; GitHub est actualisé par sa recette. Flatpak ne possède actuellement aucun registre de logiciels associé à des variables : aucune application n'est sélectionnée par cette nouvelle commande. Les autres commandes Flatpak conservent leur comportement.

Une sortie interactive peut afficher une animation, absente des sorties redirigées. Les tests substituent les commandes système et ne modifient pas la machine.

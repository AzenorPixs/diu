# Design
La fonction d’information est placée avec ses homologues dans modules/system/infos.sh. Elle affiche la valeur configurée sans la recalculer. Une variable absente est représentée par UNSET ; une valeur vide reste vide comme les autres informations système.

Si la variable vaut exactement 1, une interrogation dpkg-query demande le statut et la version de displaylink-driver. Seul le statut installed avec une version non vide est accepté. Une absence, un état incomplet ou une erreur affiche une version UNSET, un diagnostic et un retour non nul. Aucun état de configuration n’est modifié. Les agrégateurs continuent les autres sections en cas d’échec.

L’aide suit le mécanisme help/? existant avant configuration. Les tests utilisent des doublures dpkg-query ; aucune mise à jour ou action sur les pilotes n’est exécutée. Le développeur a corrigé explicitement la cible d’intégration : system infos, sans modification de system update.

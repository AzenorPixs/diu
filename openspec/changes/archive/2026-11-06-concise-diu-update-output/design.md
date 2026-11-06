## Approche

Conserver les opérations et leur ordre. Capturer les sorties de sélection, téléchargement et installation dans un fichier temporaire privé ; ne les restituer que si la commande échoue. Les erreurs propres aux vérifications restent explicites. Un message de succès utilise les versions déjà vérifiées. Le nettoyage temporaire reste assuré par le sous-shell.

## Limites

Une installation dpkg échouée peut avoir partiellement modifié le système ; les diagnostics sont conservés et aucun retour arrière automatique n'est ajouté.

La mise à jour réseau appelle le même rapport que la commande hosts ciblée. Les mises à jour englobantes héritent ainsi du résultat et de son statut. L'aide générale distingue l'affichage du fichier et la gestion du JSON et indique l'accès aux aides contextuelles.

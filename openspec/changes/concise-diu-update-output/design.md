## Approche

Conserver les opérations et leur ordre. Capturer les sorties de sélection, téléchargement et installation dans un fichier temporaire privé ; ne les restituer que si la commande échoue. Les erreurs propres aux vérifications restent explicites. Un message de succès utilise les versions déjà vérifiées. Le nettoyage temporaire reste assuré par le sous-shell.

## Limites

Une installation dpkg échouée peut avoir partiellement modifié le système ; les diagnostics sont conservés et aucun retour arrière automatique n'est ajouté.

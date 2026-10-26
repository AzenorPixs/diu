# Conception

Le rendu commun ajoute toujours une seule rubrique après LXC, ou après le dernier bloc précédent lorsque LXC est absent. Les quatre puces sont la version d’OpenSSH, le chemin hôte de ssh, la version de sshpass et son chemin hôte. La résolution réutilise le PATH système contrôlé du générateur.

Une sonde locale dédiée capture stdout et stderr de `ssh -V` (OpenSSH écrit sa version sur stderr), et uniquement stdout de `sshpass -V`. Elle accepte le préfixe OpenSSH_ ou sshpass sur la première ligne, extrait uniquement la version, ne publie aucun texte brut rejeté et conserve la limite de 15 secondes. Elle ne reçoit aucun hôte ni identifiant. Le helper de version des autres outils reste inchangé. Les erreurs restent documentaires et ne bloquent pas les rubriques suivantes ; une erreur d’écriture est propagée par le rendu.

Les tests utilisent des binaires factices isolés sous la racine du dépôt. Ils couvrent version sur stderr et stdout, versions différentes après régénération, chemins avec espaces, outils absents/non exécutables, échec, sortie mal formée et expiration. Les combinaisons Docker/LXC et les parcours individuel, groupé et de création conservent leur couverture existante.

Le retour consiste à retirer les ajouts ciblés aux sources et à régénérer normalement le document. Aucune migration de données ni opération distante SSH n’est nécessaire. La validation globale OpenSpec initiale comporte 22 éléments en échec préexistants ; leurs identités seront comparées au contrôle final.

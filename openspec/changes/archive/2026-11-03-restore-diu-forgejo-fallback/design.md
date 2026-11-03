## Décisions

Traiter les fournisseurs de manière séquentielle : GitHub puis Forgejo seulement si aucun candidat GitHub exploitable n'a été obtenu. Les erreurs de configuration ou d'API d'un fournisseur sont signalées ; elles permettent le passage à Forgejo pour GitHub, et conduisent à l'échec si aucun secours ne réussit. La configuration de chaque fournisseur est analysée séparément afin qu'un bloc Forgejo invalide n'empêche pas l'utilisation de GitHub. Les sources GitLab ne sont jamais consultées.

Une fois un candidat sélectionné, comparer à la version installée. Un candidat GitHub égal ou inférieur termine sans consultation de Forgejo. Les erreurs de téléchargement, de métadonnées ou de dpkg arrêtent la commande sans réessai ni second fournisseur. Conserver les limitations HTTPS, la validation des URL, les identifiants GitHub et la compression HTTP.

## Validation

Fixtures sans réseau distant ni installation réelle : priorité GitHub face à une version Forgejo supérieure, GitHub à jour, absence/échec/réponse invalide/sans candidat et secours réussi ou échoué, configuration Forgejo invalide ignorée si GitHub fonctionne, sécurité, pagination et contrôles de paquets. Vérifications ciblées, syntaxiques et globales.

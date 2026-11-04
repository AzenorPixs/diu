# Conception

Le paquet configure le lien de production dans `/usr/local/bin` sans remplacer une entrée existante. Le bootstrap résout son propre fichier avant de charger ses bibliothèques. Après chargement de la configuration et vérification des droits, il crée le lien de développement si sa cible existe et que le nom est libre. Les liens pendants sont considérés occupés. Les erreurs de création sont explicites. Les alias existants restent inchangés.

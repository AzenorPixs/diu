# Conception

Retirer les deux appels à `chpasswd` de chacun des trois blocs de création des
comptes. Conserver `id`, `useradd` et les opérations de groupes existants.
La configuration historique n'est ni lue ni modifiée par ce changement.
Les tests exécutent uniquement les fragments de gestion de compte avec des
commandes simulées, pour les comptes présents et absents sous `set -u`.

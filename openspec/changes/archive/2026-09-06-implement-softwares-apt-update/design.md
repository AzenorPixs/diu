# Design : mise à jour globale APT de softwares

`software_apt_update` conserve la responsabilité de la première phase : la
mise à jour APT globale. Une nouvelle fonction orchestre ensuite cette phase,
puis parcourt un registre explicite des logiciels APT connus. Pour chaque
logiciel activé et installé, elle appelle uniquement sa fonction de mise à
jour sélective.

Le registre est explicite afin d'éviter l'exécution de fonctions découvertes à
partir d'un nom fourni par l'utilisateur. La liste est vide en dehors des
recettes déjà présentes dans le module. L'orchestrateur retourne un échec si
la phase APT ou une mise à jour sélective échoue, tout en poursuivant les
autres logiciels afin de produire un bilan complet.

`rid softwares apt update` appelle uniquement `software_apt_update`.
`rid softwares update apt`, `rid softwares update` et `rid update` appellent
`software_apt_update_all`, garantissant que la phase sélective vient toujours
après la phase APT.


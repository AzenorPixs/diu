# Conception : moteur GitHub de `softwares`

Le moteur est déclaré dans `modules/softwares/github.sh` et est chargé par le
point d'entrée après le moteur APT. Un registre explicite associe chaque
identifiant à trois fonctions de recette : installation, suppression et mise à
jour. Un identifiant inconnu échoue avant toute commande système.

Chaque recette fournit la logique propre au logiciel. Elle peut utiliser des
fonctions génériques du moteur pour interroger la dernière release GitHub,
comparer la version distante à la version locale et télécharger l'artefact,
mais elle reste responsable de l'extraction, de l'installation et de la
désinstallation de son logiciel. La recette maintient sa variable globale
d'état à `1` après une installation réussie et à `0` après une suppression
réussie. Une installation déjà réalisée et une suppression d'un logiciel
absent sont sans effet de bord inattendu.

Les commandes acceptées sont :

```text
rid softwares install github <SOFTWARE>
rid softwares remove github <SOFTWARE>
rid softwares update github <SOFTWARE>
rid softwares update github
```

La mise à jour ciblée ne travaille que si le logiciel est installé. Elle
compare la version locale et la dernière release GitHub, puis n'appelle la
recette de mise à jour que si une version plus récente est disponible. La
mise à jour globale parcourt uniquement le registre GitHub et les variables
d'état actives ; elle ignore les logiciels absents et les logiciels non
déclarés.

`rid softwares update` et `rid update` exécutent la mise à jour globale GitHub
dans le même flux que les autres moteurs pris en charge, en conservant un
bilan d'erreur non nul si une sous-opération échoue.

Les tests remplacent les commandes réseau et les actions de recette par des
doublures. Ils vérifient le routage explicite, l'idempotence, la comparaison
de versions, l'absence de commande pour une entrée inconnue et l'ordre du
flux global.

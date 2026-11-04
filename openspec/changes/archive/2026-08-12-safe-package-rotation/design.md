## Context

Voir proposal.md — Why.

`build_deb()` construit actuellement le paquet directement dans `dist/` via :

```bash
destination="${project_path}/dist/${package_name}"
dpkg-deb --build --root-owner-group "${staging_dir}" "${destination}"
```

Cette approche conserve les anciens paquets après un build réussi et laisse
un paquet potentiellement corrompu en cas d'échec partiel.

## Goals / Non-Goals

**Goals:**

- Garantir que `dist/` ne contient qu'un seul paquet DIU après un build
  réussi
- Préserver les anciens paquets en cas d'échec
- Éviter toute fenêtre sans paquet valide dans `dist/`
- Cibler uniquement les artefacts `diu_*_all.deb` lors du nettoyage

**Non-Goals:**

- Modifier la liste blanche du contenu de production
- Modifier le comportement du staging
- Modifier les contrôles dpkg-deb ou --root-owner-group
- Modifier la commande `rid proj deb`
- Gérer le nettoyage de `dist/` en dehors de `build_deb()`

## Décisions

### Décision 1 : Construction dans un emplacement temporaire

**Choix :** Construire le nouveau paquet dans un répertoire temporaire
distinct du staging, puis le publier dans `dist/` après succès.

**Rationale :** Cette approche garantit qu'aucun paquet incomplet ou
corrompu n'apparaît dans `dist/`. Le nouveau paquet n'est publié que
lorsque `dpkg-deb` a confirmé sa validité.

**Implémentation :** Utiliser un second `mktemp -d` pour la construction,
distinct du staging utilisé pour l'assemblage du contenu. Le répertoire
de construction est créé sous `${project_path}/` avec un motif du type
`.diu-build.XXXXXX` afin de rester sur le même filesystem que `dist/`
tout en restant hors de `dist/`. Cette localisation garantit que le
`mv` final vers `dist/` est un renommage local et non une copie
inter-filesystem.

### Décision 2 : Séquence de publication

**Choix :** La séquence suit l'ordre :

1. Construire dans le répertoire temporaire de construction
2. Vérifier le succès de `dpkg-deb`
3. Publier (déplacer) le paquet dans `dist/`
4. Supprimer les anciens `diu_*_all.deb` en excluant le nouveau

**Rationale :** L'ancien paquet reste disponible pendant toute la durée de
la construction. La suppression n'intervient qu'après confirmation que le
nouveau paquet est valide et présent dans `dist/`.

### Décision 3 : Nettoyage ciblé

**Choix :** Le nettoyage utilise `find` avec le motif `diu_*_all.deb` et
exclut explicitement le nom du nouveau paquet.

**Rationale :** Cette approche est précise et ne touche pas aux autres
fichiers éventuellement présents dans `dist/`.

**Implémentation :**

```bash
find "${project_path}/dist" -maxdepth 1 -type f \
    -name "diu_*_all.deb" \
    ! -name "${package_name}" \
    -delete
```

### Décision 4 : Propagation des erreurs

**Choix :** En cas d'échec de `dpkg-deb` ou de déplacement vers `dist/`,
le nettoyage des anciens paquets n'est pas effectué. Le staging et le
répertoire temporaire de construction sont nettoyés.

Si la rotation des anciens `diu_*_all.deb` échoue après publication du
nouveau paquet :

- un message d'erreur explicite est affiché ;
- le code retour 1 est retourné ;
- aucun message de succès final n'est affiché ;
- le nouveau paquet déjà publié peut rester présent dans `dist/`.

**Rationale :** Cette approche préserve l'état précédent en cas d'échec
de construction ou de publication, conformément à l'exigence de
préservation des anciens paquets. En cas d'échec de rotation, l'état
est signalé comme incomplet puisque l'exigence « un seul paquet DIU
après succès » n'est pas satisfaite.

## Risques / Trade-offs

**[Risque] Espace disque** → Deux paquets coexistent brièvement dans
`dist/` (ancien + nouveau). L'impact est négligeable pour des paquets
de quelques Mo.

**[Risque] Course entre builds simultanés** → Ce change ne prend pas en
charge l'exécution simultanée de plusieurs builds sur le même projet. Deux
builds concurrents peuvent provoquer une course lors de la publication et
de la rotation des artefacts dans `dist/`. La gestion de cette concurrence
(verrouillage, sérialisation, etc.) est hors périmètre du change
`safe-package-rotation`.

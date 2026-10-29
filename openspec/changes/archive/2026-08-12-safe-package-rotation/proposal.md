# ART03 — Rotation sûre des paquets Debian

## Why

Actuellement, `build_deb()` conserve les anciens paquets `.deb` dans `dist/`
après un build réussi. Au fil des builds, `dist/` s'accumule avec plusieurs
versions du paquet DIU. De plus, si un build échoue après la création du
nouveau fichier dans `dist/`, le paquet corrompu ou incomplet reste présent.

Il est nécessaire que `dist/` représente le résultat courant du packaging,
tout en préservant le dernier paquet valide lorsqu'un build échoue.

## What Changes

- Modification de `build_deb()` pour construire le nouveau paquet dans un
  emplacement temporaire avant de le publier dans `dist/`
- Séquence après build réussi :
  1. Construire le nouveau paquet hors de `dist/`
  2. Vérifier que `dpkg-deb` a réussi
  3. Publier le nouveau paquet dans `dist/`
  4. Supprimer les anciens `diu_*_all.deb` en excluant le nouveau
- En cas d'échec avant ou pendant la publication : les anciens paquets
  restent intacts dans `dist/`
- Le nettoyage cible uniquement les artefacts Debian du DIU (`diu_*_all.deb`)
  et ne touche pas aux autres fichiers potentiellement présents dans `dist/`
- Priorité : aucune fenêtre sans paquet valide. Une courte coexistence
  ancien/nouveau est acceptable

## Capabilities

### New Capabilities

Aucune.

### Modified Capabilities

- `deb-package` : modification du comportement de nettoyage de `dist/` dans
  le scénario de construction réussie

## Impact

- Fichier modifié : `modules/projects/packaging.sh`
- Comportement modifié : rotation des paquets dans `dist/` après succès
- Comportement préservé : tous les autres comportements de `build_deb()`
  (liste blanche, staging, contrôles, commandes)

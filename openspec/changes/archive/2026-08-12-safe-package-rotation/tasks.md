## 1. Implémentation du build temporaire

- [x] 1.1 Créer un répertoire temporaire de construction distinct du staging
  dans `build_deb()` après la génération du nom de paquet

- [x] 1.2 Modifier l'appel `dpkg-deb --build` pour construire dans le
  répertoire temporaire de construction au lieu de `dist/`

- [x] 1.3 Ajouter la vérification du succès de `dpkg-deb` avant toute
  publication dans `dist/`

## 2. Publication et rotation

- [x] 2.1 Après succès de `dpkg-deb`, déplacer le paquet depuis le
  répertoire temporaire vers `<project_path>/dist/`

- [x] 2.2 Après publication, supprimer les anciens `diu_*_all.deb` dans
  `dist/` en excluant explicitement le nouveau paquet

- [x] 2.3 Vérifier que le nettoyage cible uniquement les fichiers
  correspondant au motif `diu_*_all.deb`

## 3. Gestion des erreurs

- [x] 3.1 Vérifier qu'en cas d'échec de `dpkg-deb`, les anciens paquets
  dans `dist/` ne sont pas modifiés

- [x] 3.2 Vérifier qu'en cas d'échec du déplacement vers `dist/`, les
  anciens paquets ne sont pas supprimés

- [x] 3.3 Vérifier que le nettoyage du staging et du répertoire temporaire
  de construction est effectué dans tous les cas (succès et échec)

## 4. Vérifications

- [x] 4.1 Vérifier la syntaxe Bash avec `bash -n` sur `packaging.sh`

- [x] 4.2 Tester le scénario avec plusieurs anciens paquets : après build
  réussi, seul le nouveau paquet subsiste

- [x] 4.3 Tester le scénario avec un build échoué : l'ancien paquet reste
  présent et inchangé

- [x] 4.4 Tester que `dist/` contenant un fichier autre que `diu_*_all.deb`
  n'est pas affecté par le nettoyage

- [x] 4.5 Tester que le premier build fonctionne quand `dist/` n'existe pas

- [x] 4.6 Vérifier que le paquet annoncé existe réellement dans `dist/`
  après succès

## 1. Spécification

- [x] 1.1 Valider le change et ses exigences avant toute écriture de code ou de test.

## 2. Implémentation

- [x] 2.1 Centraliser le socle et les compléments par famille dans system_install_prerequisites.
- [x] 2.2 Remplacer les listes historiques par l'appel commun et préserver DisplayLink à l'identique.
- [x] 2.3 Documenter les familles et les deux chemins d'appel dans TECHNICAL.md.

## 3. Validation et clôture

- [x] 3.1 Tester les familles, le repli, le filtrage des paquets, le tri et les erreurs sans APT réel.
- [x] 3.2 Vérifier la syntaxe, ShellCheck et les régressions concernées.
- [x] 3.3 Revoir les changements et la cohérence entre code, spécifications et cadrages.

Après ces vérifications, synchroniser la spécification et archiver le change
validé avec la commande d'archivage OpenSpec.

## Résultats observés

- Validation stricte du change avant le code : réussie.
- `bash -n modules/system/apt.sh` et `bash -n root-install-debian.sh` : syntaxe valide.
- `shellcheck modules/system/apt.sh` : réussi, aucun diagnostic.
- ShellCheck du monolithe : échec préexistant ; 635 diagnostics après modification
  contre 638 avant. Comparaison des codes, messages et lignes sources : aucun
  nouveau diagnostic. Les corrections historiques restent hors périmètre.
- `PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests -p test_system_apt.py -v` :
  10 tests réussis, avec sous-cas couvrant toutes les familles et DisplayLink.
- `TMPDIR=/home/devops/datas/diu PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests -p test_software.py` :
  44 tests exécutés, 39 réussis et 5 échecs dans les simulations de mise à jour
  globale (`system_update` absent). Les 5 échecs ont été reproduits dans une
  copie isolée contenant uniquement le test et ses quatre modules inchangés,
  sans aucun fichier modifié par cette évolution. Ils ne constituent pas une
  régression de ce change et restent signalés hors périmètre.
- Comparaison en mémoire avec l'état initial : DisplayLink strictement
  inchangé, monolithe inchangé hors bloc de prérequis, module APT inchangé hors
  fonction ciblée, tests préexistants conservés et absence de CRLF.
- Revue de cohérence : la spécification et TECHNICAL décrivent le socle, les
  familles et les deux chemins. PROJECT, BUILD, DEVOPS, README et AGENTS ne
  nécessitent aucune modification pour ce change.
- Aucune installation APT réelle ni validation sur une machine Debian cible.
  Aucun commit, push, changement de branche ou inspection Git pendant le SCM.

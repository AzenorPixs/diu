## 1. État et moteur Flatpak

- [x] 1.1 Déclarer `SYSTEM_FLATPAK`, avec détection `1`, `0` ou `UNSET` et persistance, puis vérifier ses cas isolés.
- [x] 1.2 Ajouter les opérations idempotentes d'installation, suppression, application et mise à jour ciblée, puis vérifier leurs commandes simulées.

## 2. Routage et migration

- [x] 2.1 Router les trois commandes `rid system ... flatpak` et leur aide, puis vérifier les syntaxes admises et refusées.
- [x] 2.2 Neutraliser uniquement l'installation et la mise à jour Flatpak conflictuelles du monolithe, puis vérifier l'absence de `flatpak update`.

## 3. Validation

- [x] 3.1 Ajouter les tests de déclaration, convergence, persistance, idempotence, routage et aide Flatpak, puis exécuter-les.
- [x] 3.2 Exécuter `bash -n`, `shellcheck`, les tests Python et la validation stricte OpenSpec ; vérifier le diff limité au changement.

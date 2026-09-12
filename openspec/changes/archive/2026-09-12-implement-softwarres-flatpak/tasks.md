## 1. Spécification et moteur Flatpak

- [x] 1.1 Ajouter le module d'applications Flatpak à portée système avec validation des identifiants, prérequis et idempotence, puis vérifier ses appels simulés.
- [x] 1.2 Ajouter le routage `softwares` pour install, remove et update Flatpak, puis vérifier les syntaxes admises et refusées.

## 2. Intégration et aide

- [x] 2.1 Intégrer la mise à jour Flatpak une fois dans les mises à jour `softwares` et universelle, puis vérifier l'absence de doublon.
- [x] 2.2 Ajouter les aides Flatpak hiérarchiques, puis vérifier chaque chemin d'aide sans chargement de configuration.

## 3. Validation

- [x] 3.1 Ajouter les tests isolés de Flatpak et exécuter les tests Python applicables.
- [x] 3.2 Exécuter `bash -n`, `shellcheck`, la validation stricte OpenSpec et contrôler le diff limité au changement.

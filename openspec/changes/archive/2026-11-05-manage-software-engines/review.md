# Revue — moteurs logiciels

## Comportement

Les six commandes `diu system engine install|remove apt|github|flatpak` pilotent les trois états. L’activation vérifie les paquets et outils requis avant de persister `1` ; une erreur préserve l’état précédent. La désactivation persiste `0` sans désinstaller les dépendances. Les actions logicielles explicites refusent les moteurs inactifs ; la mise à jour globale les ignore. Les opérations APT du système restent distinctes du moteur logiciel APT.

`SYSTEM_APT_ENGINE` vaut `1` par défaut. GitHub est initialisé selon les commandes présentes. `SYSTEM_FLATPAK_ENGINE` reprend `SYSTEM_FLATPAK` lorsqu’elle est absente ; l’état existant `UNSET` reste indéterminé sans désinstallation. La nouvelle variable a priorité si les deux sont présentes. `diu infos softwares` combine état et disponibilité effective ; pour Flatpak, le client et Flathub sont contrôlés localement.

Dépendances APT : apt, apt-transport-https, apt-utils et dpkg-query. GitHub : curl, jq, tar, gzip et sha256sum. Les commandes d’installation et de retrait Flatpak historiques sont remplacées par les commandes `system engine` ; `system update flatpak` reste disponible.

## Validation

Tests isolés avec simulations : 10 tests de moteurs, 7 Flatpak système, 9 Flatpak logiciel, 19 informations, 31 logiciels, 61 aides, 15 APT système et 14 réseau. Syntaxe Bash et ShellCheck réussis pour les 10 scripts modifiés ; compilation Python réussie pour les 5 tests modifiés ou créés. Les six spécifications affectées et le change sont valides individuellement en mode strict. Aucun paquet réel ni service n’a été installé ou retiré.

Un premier lancement global a exécuté 1 189 tests, dont 2 ignorés, sans échec. Une fixture réseau et une condition d’initialisation ont été corrigées pendant ce passage pour garantir l’absence d’installation réelle en test. Un second lancement a exécuté 1 189 tests, dont 2 ignorés, avec un échec intermittent du constructeur Debian (`dpkg-deb --root-owner-group`). Ce test a réussi isolément. Le contrôle d’empreintes a détecté une modification concurrente de la déclaration Codex CLI ; les 32 tests logiciels actuels réussissent. La troisième validation globale a réussi : 1 190 tests exécutés, dont 2 ignorés, sans échec ; aucune source ajoutée, supprimée ou modifiée pendant le passage (233,065 s).

## Matrice documentaire

`AGENTS.md`, `PROJECT.md`, `BUILD.md` et `DEVOPS.md` restent inchangés : leurs cadres généraux ne sont pas modifiés. `README.md`, `TECHNICAL.md` et `CHANGELOG.md` décrivent commandes, migration et impacts. `DEVELOPMENT_MAP.md` et `openspec/BATCH_CODES.md` portent une entrée provisoire ; attribution du code et normalisation définitive à traiter par ACL. Les spécifications `software-engines`, `system-flatpak`, `system-debian-apt`, `software-flatpak`, `software-inventory`, `module-infos` et `diu-help` couvrent le comportement ou ses références.

L’état des données ou des services en production n’a pas été modifié par cette session. Aucune CI/CD ni publication n’est lancée. Validation finale et archivage `2026-11-05-manage-software-engines` réussis. Le contrôle strict global a retourné 47 échecs ; les six spécifications concernées et le change passent individuellement en strict.

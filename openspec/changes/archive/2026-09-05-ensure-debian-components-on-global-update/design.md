# Design

`system_apt_update` appelle `system_apt_debian_configure` à chaque exécution.
La génération reste idempotente et ne modifie que les fichiers Debian gérés
par le moteur ; les dépôts tiers restent inchangés. La transaction globale
APT conserve ensuite sa forme unique `dist-upgrade -y`.

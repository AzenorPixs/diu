# Design

`system_apt_repository_engine` reçoit `enable`, `name`, `url_gpg_key`, `type`,
`suites`, `architecture` et `uris`. Il installe la clé dans
`/usr/share/keyrings`, écrit un seul fichier géré au nom du dépôt et supprime
les variantes `.sources`, `.list` et la clé lorsque `enable=0`.

`system_apt_configure_unofficial` fournit localement les paramètres de chaque
dépôt et appelle le moteur pour chaque variable, y compris lorsqu'elle vaut
zéro, afin de garantir l'idempotence.

Avant `curl` et `gpg --dearmor`, le moteur vérifie que le trousseau géré est un
fichier lisible et non vide (`-f`, `-r`, `-s`). Dans ce cas, il préserve son
contenu sans téléchargement ni conversion, puis poursuit la génération des
sources APT. Sinon, le chemin d'installation existant reste appliqué, avec un
retour non nul et un diagnostic si le téléchargement ou la conversion échoue.
La vérification TLS, les formats APT et la désactivation du dépôt sont conservés.

Cette vérification porte sur la disponibilité du fichier ; la validation des
signatures reste assurée par APT. Elle ne déclenche aucun renouvellement
automatique des clés. Pour CrowdSec uniquement, si le nom géré n'est pas
disponible, un trousseau historique lisible et non vide nommé
`crowdsec-crowdsec-archive-keyring.gpg` dans le même répertoire est copié avec
le mode `0644`, sans téléchargement ni modification de l'original.

## Compatibilité et configuration unique

Les onze variables statiques sont initialisées depuis les sources APT, puis
persistées. Une valeur déjà initialisée reste prioritaire. Sans source
détectée, la déclaration reprend les activations `CROWDSEC_BOUNCER`,
`LEMONLDAP`, `MONGODB` avec sa version, et Wazuh lorsque `WAZUH_SERVER` et
`WAZUH_SERVER_UPGRADE` valent tous deux `1`. Cette compatibilité ne réécrit
pas les variables historiques ni une valeur `SYSTEM_APT_*` existante.

Les sept recettes équivalentes du bloc APT historique sont retirées. L'appel
unique à `system_apt_debian_configure` déclare ces dépôts. Les traitements
système et les installations de logiciels restent inchangés. FusionDirectory,
qui n'a pas d'équivalent dans le moteur, conserve sa recette Bullseye et son
contrôle par `DIU_APT_REPOSITORY_FD`.

## Branches Wazuh et MongoDB

Wazuh `4` et l'activation historique `1` sont traduits en `enable=1` au point
d'appel du moteur ; `0` donne `enable=0`. La valeur persistée est conservée.
Toute autre valeur provoque un diagnostic avant configuration des dépôts.

MongoDB conserve les branches 4 à 8. La branche 4 utilise la clé et la suite
4.4, également reconnues par la détection historique. Les autres branches
utilisent leur version majeure suivie de `.0`. La suite Debian reste Bullseye
pour Bullseye et Bookworm pour les versions suivantes. `apt mongodb` conserve
une branche configurée valide, ou sélectionne 8 ; les formes `mongodb-N`
sélectionnent explicitement la branche correspondante.

## Erreurs et validation

Les échecs du moteur sont propagés même lors d'un appel conditionnel. Un échec
de téléchargement, conversion ou copie de clé empêche l'écriture des sources
du dépôt concerné ; la vérification TLS reste active.

La finalisation validée par le développeur le 2026-10-02 couvre ce seul change,
ses tests, son cadrage et sa synchronisation puis son archivage. Les tests
utilisent des répertoires temporaires dans le projet, des clés synthétiques
et des commandes réseau simulées. Les preuves et les limites de validation
sont consignées dans `tasks.md`.

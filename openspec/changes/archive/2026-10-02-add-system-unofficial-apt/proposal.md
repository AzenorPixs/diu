# SYS16 — Proposal: Moteur des dépôts Debian non officiels

Le module `system` doit remplacer les déclarations de dépôts tiers dispersées
dans le script monolithique par un moteur idempotent unique. Il choisit le
format deb822 (`.sources`) à partir de Trixie et le format historique (`.list`)
pour Bookworm et les versions antérieures.

Le DIU expose onze variables statiques `SYSTEM_APT_*`, y compris `SYSTEM_APT_CGPT`.
Leur valeur initiale est déduite de la présence du dépôt dans la configuration
APT, puis persistée dans `system.env`. MongoDB conserve la branche 4 à 8 et
Wazuh la branche 4.

Le changement inclut le retrait des recettes équivalentes du monolithe, sans
modifier les installations de logiciels qui les consomment.

Lors des réexécutions, le moteur réutilise le trousseau géré s'il est présent,
lisible et non vide. Le téléchargement reste nécessaire lorsqu'il est absent,
vide ou illisible ; son échec reste bloquant sans désactiver la vérification TLS.

## État de livraison et clôture

Le moteur, la réutilisation des clés et la compatibilité des variables
historiques sont implémentés. Les sept recettes redondantes de Bookworm et
Bullseye sont retirées du monolithe ; FusionDirectory et les traitements
indépendants sont préservés. Wazuh `4` et `1` sont adaptés au moteur booléen.
MongoDB conserve ses branches historiques et son installation générique
sélectionne une branche valide. Les tests isolés et les contrôles statiques
sont réussis. Les preuves préalables à la synchronisation et à l'archivage
sont détaillées dans `tasks.md`.

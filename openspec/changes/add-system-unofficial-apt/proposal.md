# Proposal: Moteur des dépôts Debian non officiels

Le module `system` doit remplacer les déclarations de dépôts tiers dispersées
dans le script monolithique par un moteur idempotent unique. Il choisit le
format deb822 (`.sources`) à partir de Trixie et le format historique (`.list`)
pour Bookworm et les versions antérieures.

Le DIU expose dix variables statiques `SYSTEM_APT_*`. Leur valeur initiale est
déduite de la présence du dépôt dans la configuration APT, puis persistée dans
`system.env`. MongoDB conserve la branche 4 à 8 et Wazuh la branche 4.

Le changement inclut le retrait des recettes équivalentes du monolithe, sans
modifier les installations de logiciels qui les consomment.

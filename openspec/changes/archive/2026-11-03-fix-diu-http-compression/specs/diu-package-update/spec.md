## ADDED Requirements

### Requirement: Décodage des réponses HTTP

La recherche des releases et le téléchargement du paquet SHALL utiliser le
décodage HTTP des encodages pris en charge par `curl`. Un échec de décodage
SHALL interrompre la mise à jour sans installation du paquet.

#### Scenario: Réponse Zstandard prise en charge
- **WHEN** une API ou un paquet est transmis avec `Content-Encoding: zstd` et que `curl` prend en charge cet encodage
- **THEN** les données décompressées sont respectivement analysées ou vérifiées avant installation

#### Scenario: Encodage ou contenu illisible
- **WHEN** `curl` ne peut pas décoder la réponse de l'API ou du paquet
- **THEN** la commande signale l'échec et ne lance aucune installation

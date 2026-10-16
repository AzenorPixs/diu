## ADDED Requirements

### Requirement: serveur temporairement indisponible pendant la publication

La commande publique de push MUST appliquer le contrat de
`git-provider-availability` aux opérations réseau de sa publication. Une
indisponibilité reconnue MUST produire un statut non bloquant, sans être
présentée comme une publication réussie. Les erreurs non qualifiées MUST
conserver leur comportement antérieur.

#### Scenario: fournisseur inaccessible

- **WHEN** une opération réseau du push rencontre une indisponibilité reconnue
- **THEN** la commande affiche une publication non confirmée et retourne zéro

#### Scenario: refus de publication

- **WHEN** Git refuse le push pour une cause autre qu'une indisponibilité reconnue
- **THEN** la commande échoue explicitement

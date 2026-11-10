## MODIFIED Requirements

### Requirement: Reprise idempotente du CI/CD
Le flux SHALL indiquer comme informations les étapes déjà satisfaites. Pour une version déjà attribuée, il SHALL poursuivre les étapes sur les sources isolées du commit du tag, préserver les modifications en attente, préserver les artefacts existants et appliquer la règle d’autorité des tags aux références distantes. Les erreurs réelles SHALL rester bloquantes.

#### Scenario: Version attribuée à un autre commit
- **WHEN** la version demandée désigne déjà un autre commit
- **THEN** le flux informe que cette version est déjà attribuée et ne publie pas le nouveau commit sous cette version
- **AND THEN** les étapes ultérieures utilisent uniquement le commit du tag

#### Scenario: Publication déjà présente
- **WHEN** le dépôt ou l'artefact cible est déjà publié pour la version cohérente
- **THEN** le bilan indique son état existant sans signaler une erreur

#### Scenario: Modifications en attente
- **WHEN** des fichiers indexés, modifiés ou non suivis sont présents au lancement du rejeu
- **THEN** ils sont préservés et exclus des sources de construction

#### Scenario: Branche distante plus récente
- **WHEN** un tag distant est supérieur à la version demandée
- **THEN** le fournisseur est refusé avant toute modification distante

#### Scenario: Erreur de vérification distante
- **WHEN** le fournisseur est inaccessible ou qu’une référence change pendant la publication
- **THEN** le flux signale l’erreur ou l’indisponibilité selon les règles applicables

#### Scenario: Immutabilité Docker non confirmée
- **WHEN** le rejeu ne peut pas confirmer l'immutabilité du tag Docker distant
- **THEN** la publication Docker est ignorée et indiquée sans erreur
- **AND THEN** la publication Debian reste éligible indépendamment


## MODIFIED Requirements

### Requirement: Reprise idempotente du CI/CD
Le flux SHALL réconcilier les branches Git distantes et publier le tag local de la version, y compris lorsque les historiques ou les tags divergent. Le rejeu SHALL construire à partir du commit du tag local et préserver les modifications en attente. La résolution des conflits de fichiers versionnés SHALL privilégier la version locale, tout en conservant les modifications distantes compatibles. Le remplacement d'une référence distante SHALL être conditionné à sa valeur observée. Les artefacts existants ne SHALL NOT être remplacés sans preuve de cohérence. Les indisponibilités reconnues restent informationnelles et les autres échecs restent explicites.

#### Scenario: Version attribuée à un autre commit
- **WHEN** la version demandée désigne déjà un autre commit local
- **THEN** les étapes de construction utilisent le commit du tag local

#### Scenario: Publication déjà présente
- **WHEN** la publication cible est déjà présente et cohérente
- **THEN** le bilan indique son état existant sans signaler une erreur

#### Scenario: Modifications en attente
- **WHEN** des fichiers indexés, modifiés ou non suivis sont présents au lancement du rejeu
- **THEN** ils sont préservés et exclus des sources de construction

#### Scenario: Branche distante plus récente
- **WHEN** la branche distante contient des commits absents du commit local de version
- **THEN** le système tente de conserver les changements distants compatibles dans une fusion isolée

#### Scenario: Erreur de vérification distante
- **WHEN** le fournisseur est inaccessible ou qu'une vérification de référence échoue
- **THEN** le système signale l'indisponibilité ou l'échec selon les règles applicables

#### Scenario: Immutabilité Docker non confirmée
- **WHEN** le rejeu ne peut pas confirmer l'immutabilité du tag Docker distant
- **THEN** la publication Docker est ignorée et indiquée sans erreur
- **AND THEN** la publication Debian reste éligible indépendamment

#### Scenario: Historiques distincts
- **WHEN** la branche distante et le commit local n'ont pas d'ancêtre commun
- **THEN** le système tente une fusion isolée et publie le résultat sans déplacer le tag local

#### Scenario: Conflit de sources
- **WHEN** les deux historiques modifient le même fichier versionné de manière incompatible
- **THEN** le contenu local prévaut et les changements distants compatibles sont conservés

#### Scenario: Tag distant divergent
- **WHEN** un tag distant porte le nom de la version locale mais désigne un autre commit
- **THEN** il est remplacé seulement si sa valeur n'a pas changé depuis la vérification

#### Scenario: Rejeu et modifications en attente
- **WHEN** le tag local existe et que des modifications locales sont en attente
- **THEN** le build utilise le commit du tag et les modifications en attente sont conservées

#### Scenario: Refus distant ou conflit non résolu
- **WHEN** la forge refuse la publication ou qu'une fusion ne peut être résolue automatiquement
- **THEN** le système signale explicitement l'échec sans annoncer la publication comme réussie

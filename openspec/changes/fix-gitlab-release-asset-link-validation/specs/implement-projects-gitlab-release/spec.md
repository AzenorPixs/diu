## ADDED Requirements

### Requirement: Validation du lien d’asset Debian

La publication Debian GitLab SHALL vérifier la réponse de création du lien
d’asset après succès du transport. Une réponse HTTP hors 2xx ou inexploitable
SHALL provoquer un diagnostic et un code non nul, sans annoncer une publication
réussie. Aucun corps de réponse ni identifiant sensible SHALL être journalisé.

#### Scenario: Lien créé avec succès

- **WHEN** le transport et la création du lien retournent une réponse HTTP 2xx
- **THEN** la publication Debian peut annoncer son succès

#### Scenario: Création du lien refusée

- **WHEN** le transport réussit mais la réponse HTTP n’est pas 2xx ou est inexploitable
- **THEN** la publication échoue explicitement sans faux succès

#### Scenario: Transport du lien en échec

- **WHEN** l’appel de création du lien échoue au niveau transport
- **THEN** l’échec est propagé et aucune publication réussie n’est annoncée


## ADDED Requirements

### Requirement: Aide des publications GitHub Docker et Debian
Les aides GitHub release et CI/CD SHALL décrire Docker seul, Debian seul et le parcours mixte, les indicateurs Yes/YES/1 et la publication de paquets déjà construits selon les conditions Forgejo, sans exécuter le flux.

#### Scenario: Aide avant bootstrap
- **WHEN** help ou ? est demandé pour projects github ou projects github release
- **THEN** les deux types d'artefacts et leur activation sont présentés sans lecture de configuration

## MODIFIED Requirements

### Requirement: Variables Codex CLI

DIU SHALL déclarer `SOFTWARES_APT_CODEX_CLI` en `DYNAMIC`, `ENABLE`, scope `softwares`, avec repli `0`. À chaque chargement de la déclaration, DIU SHALL recalculer la valeur, même si elle était déjà définie : `1` si `codex` est un exécutable accessible dans le PATH du processus DIU, `0` sinon. La valeur détectée SHALL être persistée suivant le mécanisme existant lorsque la configuration est accessible en écriture.

#### Scenario: Codex absent

- **WHEN** aucun binaire Codex CLI exécutable n'est disponible dans le PATH du DIU
- **THEN** `SOFTWARES_APT_CODEX_CLI` vaut `0`, quelle que soit sa valeur précédente

#### Scenario: Codex présent

- **WHEN** un binaire Codex CLI exécutable est disponible dans le PATH du DIU
- **THEN** `SOFTWARES_APT_CODEX_CLI` vaut `1`, quelle que soit sa valeur précédente

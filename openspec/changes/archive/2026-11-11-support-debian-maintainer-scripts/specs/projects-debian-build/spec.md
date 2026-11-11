## ADDED Requirements

### Requirement: Scripts de maintenance déclarés
Une recette MAY déclarer maintainer_scripts avec uniquement preinst,postinst,
prerm,postrm et des chemins relatifs de fichiers réguliers du projet. DIU
MUST valider ces sources sans liens, traversée ou données privées puis les
embarquer0755 dansDEBIAN, sans les exécuter pendant le build. Les recettes
sans ce champ MUST conserver leur comportement.

#### Scenario: Installation distincte du build
- **WHEN** un script valide est déclaré
- **THEN** le paquet le contient dans son archive de contrôle et aucun effet du script ne survient pendant la construction

#### Scenario: Script hors projet
- **WHEN** le nom ou le chemin déclaré est invalide, sensible ou symbolique
- **THEN** le build échoue avant publication et conserve le paquet précédent

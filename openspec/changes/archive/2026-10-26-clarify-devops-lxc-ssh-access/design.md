# Conception

## Modification minimale

Modifier le printf LXC dans modules/projects/template.sh et ajouter un printf
après projects_template_devops_test_authorization, avec propagation de son échec.
Le helper d’autorisation reste commun et son texte reste identique. Un argument
interne optionnel règle son séparateur final : trois sauts de ligne par défaut
pour préserver Docker, un seul pour placer la cinquième puce LXC immédiatement après.
Aucune nouvelle dépendance ni modification de configuration.

## Acceptation et preuves

1. Titre et première puce SSH exacts : helper assert_test_container_sections.
2. Cinq puces LXC, autorisation quatrième et conservation dernière : même helper
   sur les parcours individuel, groupé et final de création.
3. Rubrique absente si l’indicateur ne vaut pas exactement 1 ; Docker indépendant :
   tests existants des combinaisons et valeurs désactivantes.
4. Aucun accès distant : stubs LXC et SSH interdits dans le test des indicateurs.
5. Échec d’écriture de la cinquième puce : rendu non nul et ancien document conservé.
6. Validation finale : suite complète du générateur, Bash, ShellCheck, compilation
   Python, OpenSpec ciblé, comparaison globale avant/après et revue UTF-8/LF.

## Documentation

TECHNICAL.md et README.md : titre, première puce SSH, cinquième puce et position
actualisée de l’autorisation. CHANGELOG.md : entrée Unreleased dédiée.
AGENTS.md, PROJECT.md et BUILD.md restent cohérents : règles, architecture et
packaging inchangés. DEVOPS.md reste un relevé généré daté, sans régénération
ni retouche manuelle pour ce change. La spécification est synchronisée à l’archivage.

## Risques et repli

Risque limité à un écart de formulation ou d’ordre, couvert par les assertions exactes.
Aucune migration ni incompatibilité d’interface. Repli : rétablir les deux anciens
libellés et retirer la cinquième puce, avec spécifications, tests et documentation alignés.
Aucune ressource distante à nettoyer.
Les échecs OpenSpec globaux préexistants sont distingués des contrôles ciblés.

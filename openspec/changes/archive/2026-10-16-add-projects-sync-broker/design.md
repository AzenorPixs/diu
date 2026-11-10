## Contexte

`sync_project` prépare une zone temporaire, personnalise les Markdown puis
copie les ressources dans le projet. Le développeur a validé le retrait des
ressources OpenCode et CAB de ce flux, y compris le broker global.

## Décision

Le contrôle commun du modèle ne requiert plus que `AGENTS.md`, `.gitignore`
et `PROMPTS`. La préparation, la copie et l'attribution des droits sont limitées
à ces éléments et à la copie conditionnelle de `ancien protocole local`.
Cette exception conserve le contrat `implement-projects-update` : le mode est
lu dans la configuration destination, la copie est réalisée seulement pour
`Yes` et une source requise absente ou non régulière fait échouer le projet
avant toute copie du modèle. Pour `No`, une valeur absente ou vide, la source
n'est pas requise et une destination existante reste intacte. La décision est
prise séparément pour chaque projet du parcours groupé.

Les fonctions internes propres au broker et leur appel global sont retirés ;
la source CAB n'est plus consultée.

Les ressources exclues ne sont pas parcourues et ne reçoivent aucun
changement de contenu, droits ou propriétaire. Leurs caches restent intacts.
L'absence du modèle OpenCode, de la source CAB ou des destinations broker
n'empêche plus la synchronisation et n'entraîne aucune création.

Le staging, la personnalisation `Template`/`template`, la sélection groupée,
les diagnostics et les codes de retour existants sont conservés. La création
de projets et les commandes de templates restent hors périmètre.

## Alternatives écartées

- Supprimer les anciennes destinations : le retrait concerne les opérations
  de synchronisation, pas les ressources déjà installées.
- Conserver les contrôles de sources exclues : cela empêcherait une
  synchronisation valide lorsque ces sources n'existent pas.
- Modifier la sélection ou la création des projets : comportements indépendants
  de l'objectif validé.

## Validation

Les tests utilisent des données temporaires contrôlées dans `/tmp`, sans
configuration privée ni source CAB réelle. Ils vérifient les copies et la
personnalisation conservées, l'absence de création des ressources exclues,
leur préservation lorsqu'elles existent (contenu, mode, propriétaire et
horodatage), et l'absence de ces chemins dans les appels chown simulés.
Les variantes unitaire et groupée, les réexécutions, l'absence de projet
valide et la poursuite après échec sont couvertes. Les tests de copie
conditionnelle vérifient aussi les modes piloté, autonome et historique,
la préservation des attributs et les sources requises indisponibles.

La syntaxe Bash, ShellCheck, la compilation Python, les tests projets et
d'aide CLI et la validation OpenSpec stricte précèdent l'archivage ciblé.

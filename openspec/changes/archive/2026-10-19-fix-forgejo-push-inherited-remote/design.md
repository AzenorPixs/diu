## Context

`forgejo_remote_ensure` refuse actuellement une URL différente de la
configuration déclarative. Le push explicite utilise ensuite un lease
implicite fondé sur la référence de suivi locale, même lorsque l'API annonce
un dépôt absent et que le fetch est omis.

## Goals / Non-Goals

Les deux corrections sont limitées au remote Forgejo configuré et au premier
push vers un dépôt absent. Les autres remotes, fournisseurs, configurations,
branches locales et tags sont préservés. Aucun état Git réel du projet n'est
inspecté ni modifié pendant la session ; les opérations Git de validation
utilisent uniquement des dépôts temporaires locaux.

## Decisions

Le helper compare toutes les URL effectives de récupération et de
publication. Lorsqu'elles divergent, il normalise les valeurs locales du seul
remote concerné avec `git config --local --replace-all`. Une URL de push
distincte déjà configurée est réalignée ; aucune URL de push supplémentaire
n'est nécessaire si elle hérite déjà de l'URL de récupération. Après écriture,
les URL effectives sont relues et vérifiées. Tout échec bloque le push et
conserve un diagnostic explicite, sans faux succès. Les valeurs des anciennes
URL ne sont pas journalisées.

Pour un dépôt absent, le push explicite Forgejo emploie
`--force-with-lease=refs/heads/<branche>:`. Cette attente d'absence ignore les
références héritées tout en refusant d'écraser une branche créée entre la
vérification et le push. Le parcours historique conserve ses arguments ; le
parcours explicite pour un dépôt existant conserve le fetch et le lease
actuels. Les tags restent publiés sans forçage.

## Risks / Trade-offs

`project.env` devient la référence pour les URL du remote Forgejo configuré,
y compris lorsqu'elles avaient été changées manuellement. Le message indique
ce réalignement. Si plusieurs URL existent pour ce remote, elles sont ramenées
à la seule destination déclarée afin d'éviter une publication supplémentaire.
Un échec entre deux écritures peut laisser une correction partielle locale ;
le push est bloqué et une réexécution termine le réalignement.

Les règles Git de réécriture d'URL peuvent empêcher d'obtenir l'URL effective
attendue. Dans ce cas, le contrôle final échoue ; ces règles ne sont pas
modifiées. La création du dépôt reste conditionnée à l'activation serveur de
push-to-create. Aucun forçage inconditionnel ni repli API n'est ajouté.

Le repli consiste à rétablir le comportement précédent dans les sources. Les
URL déjà réalignées ne sont pas automatiquement restaurées. Aucune migration
globale ni suppression de référence locale n'est nécessaire.

## Validation

Des tests avec Git réel et dépôts locaux temporaires couvrent les URL héritées,
les pushurl distinctes ou multiples, l'idempotence, les échecs d'écriture, la
publication malgré une référence de suivi héritée et le refus d'une création
concurrente. Les tests existants contrôlent le fetch et les autres fournisseurs.
Syntaxe Bash, ShellCheck, compilation Python et validation stricte OpenSpec
complètent ces vérifications sans contacter Forgejo.

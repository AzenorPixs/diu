## Contexte

`sync_project` prépare déjà une zone temporaire pour les ressources du modèle
puis les copie dans le projet. Les ressources CAB ont une source distincte et
doivent être ajoutées sans modifier la sélection existante.

## Décision

Une fonction interne fournit le chemin fixe `/home/devops/datas/cab/src`.
Cette petite indirection permet aux tests ciblés d'utiliser une source
temporaire sans rendre ce chemin configurable pour les utilisateurs.

La source CAB est vérifiée avant toute synchronisation. Son contenu est
préparé dans une zone temporaire en parcourant les entrées hors des répertoires
`__pycache__`, puis copié dans `.opencode/broker`. Les fichiers de même chemin
sont ainsi écrasés par la source, tandis que les entrées destination sans
homologue source sont préservées. Le répertoire destination direct
`__pycache__` est supprimé conformément à la demande.

La personnalisation Markdown appliquée aux ressources du modèle exclut la zone
CAB préparée : le contenu CAB reste identique à sa source.

`sync_project_all` prépare séparément le même contenu CAB pour le synchroniser
dans `/home/${DEVOPS_USER}/.opencode/broker`. Cette copie exclut et nettoie le
répertoire direct `__pycache__`, écrase les chemins gérés par la source et
préserve les ressources destination sans homologue source.

## Alternatives écartées

- `rsync --exclude` : introduirait une dépendance supplémentaire non requise.
- une copie directe avec `cp -a` : ne permet pas d'exclure correctement les
  répertoires `__pycache__`.
- une synchronisation miroir : supprimerait des ressources destination non
  visées.

## Validation

Les tests utilisent une source CAB temporaire et vérifient la création de la
destination, l'écrasement, l'exclusion et le nettoyage. La syntaxe Bash,
ShellCheck, les tests ciblés et la validation OpenSpec sont exécutés.

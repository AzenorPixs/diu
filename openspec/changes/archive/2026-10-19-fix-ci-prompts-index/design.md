# Correction minimale du chemin ci

## Décision

Remplacer le chemin littéral de l'alias `ci` dans le groupe de commandes
`echo` qui génère `/root/.zshrc`. Conserver le compte `devops` et le nom
`INDEX.md` demandés, sans nouvelle variable ni modification des autres alias.

## Validation

Comparer le rendu isolé du bloc Zsh avant et après remplacement. Le seul
écart attendu est la ligne de l'alias `ci`. Le rendu utilise les fonctions
d'extraction existantes de `tests/test_root_shellcheck.py` : il exécute
uniquement les commandes de rendu, sans les redirections d'installation.

Actualiser ensuite la seule empreinte de `/root/.zshrc` dans ce test. Ce
changement d'attente traduit la modification autorisée ; toutes les autres
empreintes et assertions restent identiques. Exécuter la suite ciblée,
`bash -n`, ShellCheck, la compilation Python du test et les validations
strictes du change puis de la spécification synchronisée.

## Documentation et compatibilité

Ajouter une entrée concise sous `Unreleased` dans `CHANGELOG.md`.
`DEVOPS.md` (Prompts), `README.md` (inventaire DevOps) et `TECHNICAL.md`
(Traçabilité du document DevOps) décrivent déjà le nouveau dossier.
`AGENTS.md`, `PROJECT.md` et `BUILD.md` restent applicables sans modification.

Le chemin historique cesse d'être utilisé par l'alias nouvellement généré.
Aucune configuration installée ni ressource de prompts n'est modifiée dans
cette session. Le repli consiste à rétablir la ligne précédente et son
empreinte de test ; aucune migration de données n'est nécessaire.

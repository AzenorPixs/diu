# STATISTIQUES — Correction de l'alias ci

## 1. Identification et périmètre

Projet : Debian Installeur Unifié (`diu`).
Date : 19 octobre 2026, Europe/Paris.
Session : SCM directe, correction de l'alias `ci`.
Change : `fix-ci-prompts-index`.
Archive : `2026-10-19-fix-ci-prompts-index`.

Le périmètre validé couvre le chemin de l'alias Zsh généré pour root,
l'empreinte du rendu attendu, le changelog et le cycle OpenSpec complet avec
ce rapport. Il ne comprend aucune modification d'une configuration installée,
des ressources de prompts ou des autres alias.

Les valeurs non secrètes PROJECT_NAME et PROJECT_ID sont vérifiées par
extraction locale filtrée. Aucune écriture de project.env n'est effectuée
dans cette session. Aucun état Git n'est inspecté ; aucun commit, push,
changement de branche, installation ou déploiement n'est exécuté.

## 2. Durées et mesures disponibles

| Mesure | Résultat |
| --- | ---: |
| Exécutions de la suite ciblée | 1 |
| Tests exécutés et réussis | 9 |
| Échecs, erreurs, tests ignorés | 0 |
| Durée de la suite, mesurée par unittest | 7.337 s |
| Agents délégués | 0 |
| Dépendances ajoutées | 0 |
| Archivages exécutés | 1 |

Durée globale de session : N/A, absence de chronométrage global continu.
Tokens, coût et comptes exhaustifs des messages et outils : N/A, absence de
télémétrie de pilotage en SCM. Statistiques Git et inventaire global des
modifications antérieures ou concurrentes : N/A, inspection Git non autorisée
et absence de relevé global initial.

## 3. Fichiers et contrat

Trois fichiers préexistants sont modifiés :

- `root-install-debian.sh`, ligne de génération de l'alias `ci` ;
- `tests/test_root_shellcheck.py`, seule empreinte attendue de `/root/.zshrc` ;
- `CHANGELOG.md`, entrée sous `Unreleased`.

Une spécification principale est créée :
`openspec/specs/system-shell-aliases/spec.md`.

Cinq artefacts sont créés dans le change puis déplacés par l'archivage :
`.openspec.yaml`, `proposal.md`, `design.md`, `tasks.md` et
`specs/system-shell-aliases/spec.md`. Ce rapport complète l'archive : six
fichiers archivés, soit dix fichiers de livraison distincts au total.
La création et le déplacement d'un même artefact ne sont pas comptés deux fois.

Le contrat livré est exactement :

```sh
alias ci='cat /home/devops/datas/prompts/INDEX.md'
```

Le rendu isolé de la configuration Zsh est comparé avant et après correction.
Une seule ligne change : le chemin de `ci`. L'ancienne empreinte est
`ce4738f3e57fa8c21ee1ec4f58caaa9b5a254d832f883307f2ed7764005e8a88` ;
la nouvelle est
`d15e57e0a4e3245c93f03f583485a192492d60a43f4a0e532177187f2a1e3c98`.
Toutes les autres lignes du rendu et toutes les autres empreintes du test
restent identiques. Aucun test n'est supprimé, désactivé ou ajouté.

## 4. Tests et vérifications

| Contrôle | État et preuve |
| --- | --- |
| Syntaxe Bash | Exécutée et réussie : `bash -n root-install-debian.sh` |
| ShellCheck | Exécuté et réussi : `shellcheck root-install-debian.sh` |
| Compilation Python | Exécutée et réussie : `py_compile.compile` avec le Python DevOps, résultat dans un répertoire temporaire du projet ensuite nettoyé |
| Suite ciblée | Exécutée et réussie : neuf tests en 7.337 s, aucun échec, erreur ou ignoré |
| Comparaison du rendu | Exécutée et réussie : seule la ligne ci diffère ; ancienne empreinte cohérente et nouvelle calculée sur le rendu réel |
| Validation stricte du change | Exécutée et réussie avant le code et les tests, puis avant archivage |
| Validation stricte de la spécification synchronisée | Exécutée et réussie après archivage |
| Périmètre des trois fichiers préexistants modifiés | Contrôlé par comparaison SHA-256 avec les contenus attendus calculés avant correction |
| Encodage | UTF-8/LF, absence de NUL et LF final contrôlés sur les fichiers du périmètre |
| Installation réelle et suite entière du dépôt | Non exécutées, hors de la validation ciblée nécessaire |

Commande de la suite ciblée :

```sh
/home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_root_shellcheck.py
```

Les tests extraient et rendent les commandes du monolithe sans lancer
l'installation. La comparaison utilise `generated_commands` et
`render_commands` existantes, sans les redirections vers les fichiers système.
La compilation Python utilise `TemporaryDirectory` dans la racine du projet.

Le premier contrôle final du rapport échoue sur une comparaison littérale
d'une phrase répartie sur deux lignes. La comparaison est corrigée pour
normaliser les espaces avant vérification ; aucun contenu livré ni total
n'est modifié pour satisfaire ce contrôle.

Commandes OpenSpec exécutées avec le binaire indiqué dans DEVOPS.md :

```sh
/home/devops/.local/npm/bin/openspec validate fix-ci-prompts-index --type change --strict --no-interactive
/home/devops/.local/npm/bin/openspec validate system-shell-aliases --type spec --strict --no-interactive
```

## 5. Résultats, cohérence et archivage

Archivage officiel exécuté une seule fois :

```sh
/home/devops/.local/npm/bin/openspec archive fix-ci-prompts-index --json --yes
```

Résultat : `specsUpdated=true`, une exigence ajoutée, aucune modifiée,
supprimée ou renommée. Les six tâches du change sont cochées. La section
Purpose générée automatiquement est renseignée après archivage, puis la
spécification principale passe la validation stricte. Les exigences de cette
spécification correspondent au delta archivé.

| Élément de la matrice SCM | État et justification |
| --- | --- |
| Projet réel | Alias corrigé dans le générateur et neuf tests ciblés réussis ; configuration installée non modifiée |
| AGENTS.md | Inchangé : sections 5, 6, 7 et 21 appliquées pour la validation, OpenSpec et le rapport d'archive |
| PROJECT.md | Inchangé : Présentation et Technologies restent exactes ; aucun changement d'architecture |
| TECHNICAL.md | Inchangé : Traçabilité du document DevOps indique déjà le dossier datas/prompts et son INDEX.md |
| BUILD.md | Inchangé : Contenu du paquet et chaîne de construction non affectés |
| DEVOPS.md | Inchangé : rubrique Prompts avec /home/devops/datas/prompts et son INDEX.md ; outils DevOps réutilisés |
| README.md | Inchangé : présentation de l'inventaire DevOps avec les chemins datas/prompts déjà exacts |
| CHANGELOG.md | Mis à jour : Unreleased décrit le chemin ci et la portée sur les configurations générées |
| openspec/specs/ | Nouvelle spécification system-shell-aliases, une exigence et deux scénarios ; validation stricte réussie |
| openspec/config.yaml | Inchangé : schéma spec-driven conservé |

Les empreintes des sept fichiers de cadrage et de configuration laissés
inchangés sont comparées au relevé précédant la correction. Le contrôle final
vérifie aussi l'absence du change actif, la présence des cinq artefacts
archivés avec leurs empreintes initiales, les six tâches cochées et ce rapport
à six sections. Aucun document nécessaire du périmètre n'est absent.

## 6. Limites et suites

La correction des sources prend effet lors d'une génération ultérieure de la
configuration Zsh par le DIU. Elle ne modifie pas le shell courant, le DIU
installé ou une configuration root déjà présente. Aucune installation réelle
n'est exécutée pour ce contrôle.

Les autres alias, les variables, les permissions et la construction du paquet
restent inchangés. Aucun nouveau paramètre ni mécanisme de migration n'est
introduit. Le repli est le rétablissement de la ligne précédente et de son
empreinte attendue.

Le contrôle de périmètre est limité aux écritures effectuées et aux fichiers
explicitement examinés ; il ne prétend pas établir l'état global du dépôt.
Les autres changes actifs ne sont ni modifiés ni archivés. Aucun échec de
validation ou écart documentaire connu ne reste dans le périmètre traité.

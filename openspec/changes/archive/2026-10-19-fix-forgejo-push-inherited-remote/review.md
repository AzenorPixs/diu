# Validation — Push Forgejo après changement de dépôt

## Périmètre et comportement

Session SCM directe du 19 octobre 2026 pour Debian Installeur Unifié (`diu`).
Le périmètre couvre le change `fix-forgejo-push-inherited-remote`, son
implémentation, les tests, la documentation et son cycle d'archivage.

Le remote Forgejo configuré est réaligné sur la destination de `project.env`,
pour ses URL de récupération et de publication. Ses URL multiples sont
normalisées vers cette seule destination. Un échec bloque le push ; une
réexécution conforme n'effectue aucune écriture. Les autres remotes et la
configuration du projet sont préservés.

Le premier push explicite vers un dépôt annoncé absent attend l'absence de
la branche avec `--force-with-lease=refs/heads/<branche>:`. Il fonctionne
malgré une référence héritée et refuse une création concurrente. Les
références locales ne sont pas supprimées. Les dépôts existants conservent
leur fetch et leur lease, les tags restent sans forçage.

## Tests exécutés et réussis

```sh
bash -n modules/projects/git.sh
/home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p test_projects_forgejo_push.py -v
```

La nouvelle suite exécute 14 tests avec Git réel en 2.491 s : aucune erreur,
aucun échec, aucun test ignoré. Les dépôts temporaires sont confinés à la
racine du projet. Les seules communications Git sont locales par le protocole
`file`, imposé par `GIT_ALLOW_PROTOCOL=file`. Les fonctions d'authentification
et de vérification API sont remplacées par des fixtures sans credentials.

Les critères d'acceptation correspondent aux tests suivants :

| Critère | Test ou preuve |
| --- | --- |
| URL héritée du modèle | `test_realigns_inherited_url_without_adding_pushurl` |
| Pushurl distincte et destinations multiples | `test_realigns_distinct_pushurl`, `test_normalizes_multiple_fetch_and_push_urls` |
| Remote absent et remote nommé | `test_adds_absent_remote`, `test_first_push_uses_configured_remote_and_destination_branch` |
| Idempotence | `test_reexecution_does_not_rewrite_aligned_urls` |
| Échecs de correction, lecture ou vérification | tests `fetch_url_write_failure`, `pushurl_write_failure`, `pushurl_read_failure`, `url_rewrite_mismatch` |
| Référence de suivi héritée | `test_first_push_with_inherited_tracking_publishes_branch_and_tag` |
| Création concurrente | `test_concurrent_branch_creation_is_rejected_without_publishing_tag` |
| Fetch et lease du dépôt existant | tests `existing_repository_keeps_fetch_and_implicit_lease`, `existing_repository_fetch_failure_stops_push` |
| Conservation des autres remotes, HEAD, tag et project.env | assertions partagées `assert_urls_aligned` |

Les suites existantes `test_rid_help.py`,
`test_projects_provider_unavailable.py` et `test_projects.py` sont exécutées
ensemble par `unittest.defaultTestLoader.discover` et réussissent : 100 tests
en 15.053 s, aucun échec, erreur ou ignoré. Leur exécution utilise le Python
DevOps ci-dessus, `-B`, `PYTHONDONTWRITEBYTECODE=1` et un `TMPDIR` temporaire
sous la racine du projet, ensuite nettoyé. La compilation `py_compile` des
deux fichiers Python modifiés ou créés réussit également, avec sorties
temporaires confinées au projet.

Total : 114 tests exécutés et réussis, durée cumulée des suites 17.544 s.

## ShellCheck et périmètre du code

`shellcheck modules/projects/git.sh` est exécuté et échoue avec trois
diagnostics préexistants : SC2034 ligne 5116, SC2269 ligne 5400 et SC2086
ligne 7105. Ils ne concernent pas les fonctions modifiées.

La version précédente est reconstruite en annulant uniquement les deux
corrections dans une copie temporaire. Son SHA-256 est exactement celui
relevé avant écriture :
`ea62e5b1c7d5d6a1adad40a85582e034fa29e397cbb0d71847d68d38cac891aa`.
ShellCheck produit les mêmes trois codes, niveaux et messages sur cette
copie et sur le fichier actuel. Aucun nouveau diagnostic n'est introduit.
Les fonctions `_git_push_provider` et `forgejo_remote_ensure`, extraites dans
un fichier temporaire avec shebang Bash, passent ShellCheck sans diagnostic.
Les copies temporaires sont nettoyées. Ces diagnostics hors périmètre ne sont
ni supprimés ni désactivés dans la configuration.

## Matrice documentaire SCM

| Élément | État et preuve |
| --- | --- |
| Projet réel | Sources corrigées et 114 tests locaux réussis ; ni projet prompts réel ni installation modifiés |
| AGENTS.md | Inchangé : sections 5, 6, 7, 13 et 21 appliquées pour périmètre, tests, OpenSpec et rapport d'archive |
| PROJECT.md | Inchangé : module projects et architecture Bash conservés |
| TECHNICAL.md | Mis à jour : configuration des fournisseurs, publication Git et compatibilité décrivent le réalignement et le lease d'absence |
| BUILD.md | Inchangé : construction Debian et chaîne de packaging non affectées |
| DEVOPS.md | Inchangé : outils Bash, Python et OpenSpec existants réutilisés ; aucune dépendance ajoutée |
| README.md | Mis à jour : paragraphe de publication Forgejo avec réalignement, premier push, limites serveur et parcours all |
| CHANGELOG.md | Mis à jour : entrée Unreleased consacrée aux deux corrections et comportements conservés |
| openspec/specs/ | Delta validé avant le code ; synchronisation de la seule spécification implement-projects-forgejo-push par archivage |
| openspec/config.yaml | Inchangé : schéma spec-driven conservé |

## OpenSpec, limites et repli

La première validation stricte du delta signale deux noms de scénarios
existants omis. Les noms sont rétablis et la validation stricte réussit avant
toute écriture de code ou de test. Aucun scénario existant n'est supprimé.
La création du dépôt dépend toujours du serveur Forgejo ; aucun test réseau
ou push externe n'est exécuté. La validation locale vérifie la mécanique Git,
sans certifier la configuration push-to-create de l'instance distante.

Les URL réécrites manuellement du remote Forgejo configuré cèdent désormais
la place à `project.env`. Une erreur intermédiaire peut laisser une correction
locale partielle ; une réexécution reprend le réalignement. Les règles Git
de réécriture d'URL ne sont pas modifiées et une divergence effective bloque
la publication. Le repli est le rétablissement du code antérieur ; les URL
déjà réalignées ne sont pas restaurées automatiquement.

Les commandes du dépôt Git réel ne sont pas utilisées pendant SCM. Les
commits, tags, modifications de références et pushes de test concernent
uniquement les fixtures temporaires. Aucun commit du projet, branche,
publication, installation, service CAB ou agent délégué n'est créé.

## Archivage et contrôle de la spécification synchronisée

```sh
/home/devops/.local/npm/bin/openspec validate fix-forgejo-push-inherited-remote --type change --strict --no-interactive
/home/devops/.local/npm/bin/openspec archive fix-forgejo-push-inherited-remote --json --yes
/home/devops/.local/npm/bin/openspec validate implement-projects-forgejo-push --type spec --strict --no-interactive
```

Le change est validé avant archivage. L'archivage est exécuté une seule fois
avec `specsUpdated=true` : deux exigences modifiées, aucune ajoutée, supprimée
ou renommée. Les neuf tâches préalables sont cochées. Les opérations de
synchronisation, d'archivage et de rapport sont les étapes de clôture SCM.

Le premier contrôle strict de la spécification synchronisée signale deux
descriptions de plus de 500 caractères, dans les seules exigences modifiées
`commande de publication Forgejo` et `remote Forgejo HTTPS`. Leurs textes sont
condensés et les détails conservés dans les scénarios, à l'identique dans la
spécification principale et le delta archivé. Aucune autre exigence n'est
modifiée et aucun second archivage n'est exécuté. La validation stricte de
la spécification principale réussit ensuite sans diagnostic.

Le rapport `STATISTIQUES.md` complète cette archive avec six sections, les
mesures disponibles, le bilan documentaire et les limites. Les modifications
éditoriales après archivage ne touchent ni le code ni les tests déjà validés.

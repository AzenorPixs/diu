# Design

## Context

Voir `proposal.md` pour le besoin. L'installation est actuellement inline dans le bloc `OPENCODE=1` de `root-install-debian.sh` ; le dépôt GitHub sert déjà de source de version et le script officiel est exécuté sous le compte DevOps.

## Goals / Non-Goals

**Goals:**

- Suivre la dernière release stable de la série V2 même si une autre version majeure devient ensuite la release GitHub générale la plus récente.
- Comparer les numéros de version sans réinstaller une version égale ou supérieure.
- Garder le changement local au bloc d'installation OpenCode DevOps.

**Non-Goals:**

- Mettre à jour OpenCode déjà installé dans d'autres comptes ou conteneurs.
- Modifier le routage `rid softwares`, les préférences utilisateur, le PATH ou la configuration OpenCode.
- Installer une version préliminaire ou une version majeure autre que 2.

## Decisions

1. **Sélectionner une release V2 stable depuis l'API GitHub des releases.** Lire les pages ordonnées de releases du dépôt officiel, accepter uniquement les tags complets `v2.x.y` sans suffixe préliminaire, et retenir la plus récente. Une release V1 ou V3 ne peut donc pas être choisie par inadvertance. Une page vide avant toute V2 est une erreur explicite.
   - *Alternative écartée :* `/releases/latest` est plus simple, mais peut finir par désigner une version majeure autre que V2.
2. **Comparer les versions avec un tri versionné disponible sur Debian.** Normaliser le préfixe `v` du tag distant et accepter la version locale en `x.y.z`, quelle que soit sa majeure, afin que l'installation 1.19.4 puisse évoluer vers 2.2.0. Une version distante strictement supérieure déclenche la mise à jour ; une version locale égale ou supérieure la préserve.
   - *Alternative écartée :* l'égalité textuelle actuelle réinstalle une version plus ancienne ou égale lorsque les chaînes diffèrent et ne vérifie pas l'ordre numérique des composantes.
3. **Utiliser l'installateur officiel V2** `https://opencode.ai/v2/install` avec `--version "$LATEST" --no-modify-path`, en conservant l'exécution sous `DEVOPS_USER`, le chemin `.opencode/bin/opencode`, le chmod actuel et le nettoyage du profil historique. L'option `--version` garantit que le binaire installé correspond à la release comparée.
   - *Alternative écartée :* l'installateur V1 actuel ne correspond pas à la version obtenue sur GitHub.
4. **Fail closed avant l'installation.** Une erreur réseau, l'absence de release V2 stable ou une version mal formée empêche de lancer l'installateur. Aucune dépendance ou valeur de configuration persistante n'est ajoutée.

## Risks / Trade-offs

- [Limitation de l'API GitHub ou réseau indisponible] → conserver TLS, borner les appels, propager le code curl et ne pas remplacer le binaire en place.
- [Format inattendu des tags ou de `--version`] → vérifier les versions avant toute installation et tester les cas invalides sans accès réseau réel.
- [La release V2 évolue entre détection et exécution de l'installateur] → passer la version détectée à l'option `--version` de l'installateur officiel afin d'installer exactement celle qui a été comparée.

## Migration Plan

Aucune migration de données ou de configuration. À la prochaine exécution où `OPENCODE=1`, une installation 1.x sera remplacée par la dernière V2 stable ; une installation V2 égale ou plus récente sera conservée.

## Validation

Tester le bloc réel avec un `curl` simulé et un `su` simulé. Couvrir la sélection stable V2, la pagination, la comparaison numérique, les versions absente/égale/plus récente, l'échec réseau, l'absence de V2 et le fait qu'aucune installation ne se lance pour une réponse invalide. Exécuter ensuite la syntaxe Bash, ShellCheck, les tests ciblés et ceux du monolithe, puis OpenSpec en mode strict.

# Revue — inventaire des logiciels

## Comportement

`diu infos softwares` et `diu softwares infos` affichent la même vue, également utilisée par `diu infos`. Les moteurs APT, GitHub et Flatpak sont en colonnes ; leur disponibilité locale utilise des titres vert ou rouge gras. Les logiciels à état déclaré sont verts pour 1, jaunes pour 0, et marqués `?` lorsque leur état est inconnu. Les noms de variables et la clé API CrowdSec ne sont pas affichés. Codex CLI est associé à GitHub. Aucune installation ni requête réseau n’est lancée pour cet affichage.

## Cohérence documentaire

`PROJECT.md`, `BUILD.md`, `AGENTS.md` et `DEVOPS.md` restent inchangés : leurs contrats généraux ne sont pas modifiés. `TECHNICAL.md`, `README.md` et `CHANGELOG.md` décrivent la nouvelle vue. Les spécifications `module-infos`, `diu-help` et `software-inventory` portent les contrats concernés. `DEVELOPMENT_MAP.md` et `openspec/BATCH_CODES.md` conservent une entrée provisoire sans code attribué ; l’attribution relève ultérieurement d’ACL.

## Validation

Syntaxe Bash et ShellCheck réussis sur les sources modifiées ; compilation Python réussie. Les 19 tests ciblés des informations de modules réussissent. Les aides `diu infos help` et `diu infos softwares help` sont vérifiées. Le change et les spécifications `diu-help` et `module-infos` sont valides en mode strict.

Le premier lancement global a exécuté 1 177 tests, avec deux ignorés, un échec et deux erreurs dans un même test de génération DevOps : son répertoire temporaire n’était plus accessible en écriture. La reprise isolée de ce test a réussi. La seconde validation globale a réussi : 1 179 tests exécutés, dont 2 ignorés, sans échec ni erreur (289,934 s). Le répertoire de fixture `.diu-test-devops-w_p2t73i` reste présent, avec des éléments appartenant à `devops` ; son nettoyage n’a pas été forcé. Le contrôle OpenSpec global strict signale 47 échecs ; le résultat de la session précédente présentait également 47 échecs.

Pas de CI/CD, publication, installation ou modification volontaire de la configuration en production.

Archivage `2026-11-05-display-software-inventory` réussi le 2026-11-05 ; les spécifications sont synchronisées.

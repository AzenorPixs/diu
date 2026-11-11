# Revue documentaire et périmètre — 2026-11-11

| Document | État et preuve |
|---|---|
| AGENTS.md | Inchangé : règles de sécurité et processus toujours applicables. |
| PROJECT.md | Inchangé : responsabilités diu/system/softwares préservées (§ Architecture fonctionnelle). |
| TECHNICAL.md | Mis à jour : Dépôts Debian et APT, Moteurs logiciels, propriétaires GLOBAL, initialisation unique et firmware indépendant. |
| BUILD.md | Inchangé : copie du répertoire modules par la recette existante ; aucune nouvelle dépendance Python, déjà dans Depends. |
| DEVOPS.md | Modification préexistante conservée ; Python DevOps, OpenSpec et conteneur Debian utilisés selon cet inventaire. |
| DEVELOPMENT_MAP.md | Entrée ciblée, code non attribué, état et preuve du change. |
| openspec/BATCH_CODES.md | Entrée provisoire ; aucune attribution de code. |
| README.md | Mise à jour des cinq variantes, sources et composants indépendants. |
| CHANGELOG.md | Entrée Unreleased sur les comportements livrés et les exclusions. |
| OpenSpec | Capacités sources/recettes nouvelles, anciens replis et commandes logicielles réconciliés dans les deltas. |

Les recettes d'installation DevOps/Docker/IA et leurs blocs monolithiques sont préservés à l'identique. Les 22 blocs historiques du catalogue APT sont retirés, les fonctions spécifiques sont dans GLOBAL et les opérations communes restent agnostiques.

Les paragraphes historiques du journal conservent leur contexte. Une phrase préexistante de TECHNICAL.md dans le bilan système décrit encore Flatpak sans variable individuelle ; elle est hors du périmètre APT de ce change et n'est pas utilisée comme preuve fonctionnelle.

L’adaptateur non-free du bureau a été explicitement autorisé après inventaire, sans déplacement de sa recette.

Validation finale : 1 347 tests dont 2 ignorés, 48 scripts Bash et 13 fichiers Python contrôlés, synchronisation et validation OpenSpec stricte sur 121 spécifications réussies. Archive créée, rapport SGS individuel vérifié avec télémétrie native gelée. Le delta global reste refusé pour registre incompatible ; aucune reconstruction automatique. Livraison CICD 1.3.8 préparée après ces contrôles. Les essais réels ne constituent pas une installation réelle de chacun des 23 logiciels ; les autres cas sont couverts par les tests isolés.

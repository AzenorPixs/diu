# Tasks: Gestion des logiciels et mise à jour universelle

## 1. Validation des spécifications

- [x] Rédiger la proposition, le design et les exigences avec scénarios.
- [x] Autorisation d’implémentation reçue du développeur dans la conversation.
- [x] Documenter les décisions de la première étape et reporter les interfaces apt futures.

## 2. Première étape : moteur deb

- [x] Examiner les fonctions de paquets existantes et limiter les modifications.
- [x] Implémenter le routage action / moteur / logiciel et sa validation.
- [x] Implémenter installation et désinstallation des paquets officiels.
- [x] Implémenter les mises à jour ciblée et globale du moteur deb avec contrôle d'origine.
- [x] Mettre à jour l'aide des commandes concernées.

## 3. Mise à jour universelle

- [x] Inventorier les modules, leurs sous-fonctions et dépendances de mise à jour.
- [x] Définir leur participation explicite, sans doublons.
- [x] Étendre rid update à toutes les opérations applicables et à DIU lui-même.
- [x] Ajouter le bilan global et la propagation des échecs.

## 3 bis. Mise à jour des images Docker

- [x] Utiliser la fonction générique Docker avec une politique explicite.
- [x] Corriger l'appel Hermes et supprimer la dépendance à la variable globale obsolète.
- [x] Vérifier la syntaxe, les tests et la validation OpenSpec.

## 4. Étape ultérieure : moteur apt

- [ ] Définir les logiciels reconnus et leur dépendance ou non à un dépôt.
- [ ] Intégrer le moteur de dépôts DIU lorsqu'il sera disponible.
- [ ] Ajouter les fonctions propres aux logiciels sans dépôt.
- [ ] Implémenter les quatre commandes apt et leur participation à rid update.

## 5. Vérifications de l'implémentation future

- [x] Tester les arguments invalides avant toute mutation.
- [x] Tester l'isolation entre paquets officiels et tiers, y compris les dépendances.
- [x] Tester Hermès, les erreurs DIU et le refus explicite du moteur apt indisponible.
- [ ] Tester les recettes spécifiques apt lors de leur implémentation future.
- [x] Tester les mises à jour ciblées, globales, sans doublons et les échecs partiels.
- [x] Exécuter bash -n et shellcheck sur les scripts modifiés.
- [x] Vérifier la conformité OpenSpec et l'absence de modification hors périmètre.

## État

Le moteur apt et le moteur de dépôts restent explicitement différés.
La validation du programme en situation réelle (installation ou suppression de
paquets) n'est pas effectuée sur la machine de développement.

## Vérifications exécutées

- 23 tests automatisés réussis (`python3 tests/test_software.py`).
- `bash -n` réussi sur les cinq fichiers Bash concernés.
- ShellCheck 0.10.0 réussi sur les quatre fichiers des modules.
- Script principal : 596 diagnostics ShellCheck préexistants, aucun diagnostic
  ajouté lorsque les nouveaux composants sont fournis au contrôle.
- Simulation APT avec les vrais index locaux réussie pour le paquet bash ;
  aucune installation, suppression ou mise à jour réelle exécutée.
- `git diff --check` réussi ; les modifications préexistantes hors périmètre
  sont conservées.
- Validation officielle du changement réussie avec
  `openspec validate add-software-management --strict`.
- La validation globale des spécifications existantes signale un échec
  préexistant dans `deb-package` ; les autres spécifications passent ou ne
  présentent que des informations de style.

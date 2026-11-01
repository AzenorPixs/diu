# Statistiques — move-crowdsec-configuration-to-software-scope

Date de clôture documentaire : 2026-11-01. Session directe SCM, exécutée par
Codex ; aucun agent de codage délégué.

## Statistiques générales et décisions

- Changement : `move-crowdsec-configuration-to-software-scope`, code de lot non attribué.
- Les contrôles du dépôt APT, de l'agent, du bouncer et la clé API CrowdSec
  relèvent désormais du scope `softwares`.
- `SOFTWARES_APT_CROWDSEC_AGENT` et
  `SOFTWARES_APT_CROWDSEC_BOUNCER` sont `STATIC`, `ENABLE`, défaut `0`.
- Le dépôt CrowdSec conserve la détection des sources existantes et se déduit
  des contrôles agent/bouncer lorsque sa valeur n'est pas déjà configurée.
- Les paquets `crowdsec` et `crowdsec-firewall-bouncer-iptables` sont installés
  par APT.
- La clé API historique est migrée sans affichage ni exécution. Le fichier
  `softwares.env` passe en mode `0600`; le YAML du bouncer est remplacé via un
  fichier temporaire privé, sans passer la clé dans les arguments d'un
  processus enfant.
- Archivage réussi sous
  `2026-11-01-move-crowdsec-configuration-to-software-scope` avec deux
  spécifications ajoutées et quatre modifiées.
- Suite complète DIU avec l'interpréteur `/home/devops/python/current/bin/python3` :
  790 tests réussis, 2 ignorés, aucun échec.
- Publication du paquet DIU et cycle d'exécution dans CISMP non inclus dans ce
  relevé d'archive; ces étapes restent à réaliser.

## Types de messages et d'outils

- Agents intervenus : 1 (Codex en session directe).
- Délégation : 0.
- Comptages exhaustifs des messages et appels d'outils : N/A, aucune télémétrie
  de session directe disponible pour établir ces totaux sans estimation.

## Fichiers modifiés

- Implémentation : `root-install-debian.sh`,
  `modules/system/variables-cleanup.sh`, `modules/system/apt.sh`,
  `modules/system/infos.sh`, `modules/softwares/infos.sh`, et quatre modules
  de déclaration CrowdSec sous `modules/diu/variables/softwares/`.
- Tests : `tests/test_config_cleanup.py`, `tests/test_module_infos.py`,
  `tests/test_system_apt_unofficial.py`, `tests/test_system_crowdsec_agent.py`,
  `tests/test_crowdsec_api_key.py`, `tests/test_crowdsec_bouncer.py`.
- Documentation : `TECHNICAL.md`, `CHANGELOG.md`.
- Spécifications canoniques : `legacy-variable-cleanup`, `module-infos`,
  `system-crowdsec-agent`, `system-debian-apt` et `software-apt-crowdsec`.
- Archive : proposition, design, tâches, quatre deltas de spécification et
  ce rapport `STATISTICS.md`.

## Commandes

- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests` :
  790 tests réussis, 2 ignorés.
- Tests ciblés de migration, APT, agent, bouncer, clé API et informations des
  modules : réussis.
- `bash -n` sur le point d'entrée, le nettoyage, APT et les modules de
  déclaration CrowdSec : réussi.
- `shellcheck` sur les scripts Bash modifiés : réussi, aucun diagnostic.
- `python3 -m py_compile` sur les six fichiers Python de test modifiés : réussi.
- `/home/devops/.local/npm/bin/openspec validate
  move-crowdsec-configuration-to-software-scope --strict` : valide.
- `/home/devops/.local/npm/bin/openspec archive
  move-crowdsec-configuration-to-software-scope --yes --json` : réussi;
  deux specs ajoutées, quatre modifiées.
- `/home/devops/.local/npm/bin/openspec validate --archived --json
  --no-interactive` : 123/135 changes valides; les 12 échecs concernent des
  tâches incomplètes dans d'autres archives.
- `git diff --check` : réussi.

## Accès web

N/A — aucun accès web effectué.

## Synthèse globale

Le dépôt APT CrowdSec, l'agent, le bouncer et leur clé API sont regroupés sous
le scope logiciels. Les valeurs historiques sont migrées sans modification;
la clé est traitée sans exposition et les fichiers qui la contiennent sont
privés. Les tests, contrôles shell, validation stricte du change et archivage
réussissent. La publication et l'exécution CISMP sont distinctes et restent à
effectuer après ce relevé. Le rapport général `STATISTICS.md` à la racine est
absent; sa production relève du prompt SGS.

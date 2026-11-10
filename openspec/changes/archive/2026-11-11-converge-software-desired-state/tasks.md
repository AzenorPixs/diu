## 1. Contrats et inventaire

- [x] 1.1 Inventorier les logiciels existants, leurs variables, détecteurs, paquets, rôles partagés et traitements nécessaires ; identifier les états initialisés et les migrations sûres.
- [x] 1.2 Compléter les deltas OpenSpec, résoudre les contradictions avec les spécifications existantes et valider strictement le change.

## 2. Moteurs et convergence

- [x] 2.1 Implémenter la persistance du désir, la détection fiable et les trois opérations génériques par moteur, sans mutation implicite du désir.
- [x] 2.2 Raccorder les logiciels existants APT et GitHub et les applications Flatpak génériques, avec conservation des traitements spécifiques et gestion des dépendances partagées.
- [x] 2.3 Raccorder les commandes ciblées et globales, l'ordre APT, Flatpak, GitHub et la playlist `diu update`.
- [x] 2.4 Conserver les mises à jour de versions dans les parcours système et actualiser les aides.

Le noyau isolé `modules/softwares/convergence.sh` a été créé le 2026-11-10 et vérifié par cinq tests dans `tests/test_software_convergence_core.py`, ainsi que par `bash -n` et ShellCheck. Il n'est pas encore raccordé aux moteurs ; cette preuve ne valide pas la tâche 2.1.

Le 2026-11-10, un premier mécanisme isolé de migration de valeur et des détecteurs APT de paquets ont été ajoutés et contrôlés par `tests/test_software_desired_migration.py` (cinq tests) et `tests/test_software_apt_state.py` (trois tests), `bash -n` et ShellCheck. Ils ne sont pas raccordés aux commandes ; les rôles, paquets partagés et logiciels composites restent à qualifier.

Un premier catalogue APT isolé couvre jsvc, openvswitch, qemu-guest-agent et syncthing avec les trois opérations génériques ; `tests/test_software_apt_convergence.py` compte trois tests réussis le 2026-11-10. Le catalogue reste incomplet et non raccordé ; cela ne valide pas la tâche 2.2.

La détection Flatpak isolée distingue échec et absence ; elle associe à chaque identifiant valide un suffixe hexadécimal sans collision et un détecteur propre. `tests/test_software_flatpak_state.py` compte cinq tests réussis le 2026-11-10. La persistance et le routage Flatpak restent à réaliser.

La convergence Flatpak isolée réutilise les opérations génériques existantes et a été vérifiée par deux tests supplémentaires le 2026-11-10 ; les tests simulent Flatpak. Son parcours ciblé utilise la persistance isolée, mais n'est pas encore raccordé aux commandes DIU.

Le 2026-11-10, les parcours isolés de persistance et de convergence ciblée APT, Flatpak et GitHub ont été testés avec des doubles ; les opérations GitHub génériques vérifient SHA-256 et la mise à jour de version système conserve l'état désiré. Les tests ne prouvent ni le raccordement aux commandes ni la couverture de tous les logiciels.

Le 2026-11-10, la configuration syslog générée avec les quatre options serveur activées et le client a passé `rsyslogd -N1` avec rsyslog 8.2504.0 dans un conteneur Debian 13 dédié, supprimé après le test. Cela vérifie la syntaxe, pas le trafic réel ni les configurations historiques non marquées.

Une seconde campagne Debian 13 du même jour a installé rsyslog 8.2504.0, ulogd2 et Python dans un conteneur dédié : configuration serveur puis client, contrôles des deux rôles, retrait du client et nouveau contrôle serveur ont réussi sur les fichiers Debian réels ; les redémarrages de services étaient simulés. Le conteneur a été supprimé. Le trafic réel et les configurations historiques non marquées restent non qualifiés.

Le 2026-11-10, `unittest discover -s tests -p 'test_software*.py'` a réussi 336 tests ; 24 scripts Bash préparés ont réussi individuellement `bash -n` et ShellCheck, et 59 fichiers Python du périmètre ont été compilés. Ces contrôles précèdent le raccordement et ne constituent pas la validation finale.

Une nouvelle exécution ciblée a réussi 345 tests. Un chargeur des modules de convergence a ensuite été ajouté et vérifié avec les tests de démarrage ; il reste isolé du point d'entrée. La convergence globale signale également une valeur de moteur invalide tout en poursuivant les autres moteurs. Ces contrôles ne valent pas validation de bout en bout.

Avant raccordement, la suite complète `unittest discover -s tests` a réussi 1 414 tests, dont deux ignorés, en 250,597 s. Elle devra être rejouée après la bascule des commandes et des variables.

Le 2026-11-11, les anciennes syntaxes logicielles `diu install/remove/update apt|github` sont refusées avant chargement de la configuration. Le test `tests/test_software_retired_commands.py` couvre les six combinaisons ; `bash -n` et ShellCheck réussissent sur le point d'entrée. Ce retrait ne constitue pas le raccordement des nouvelles commandes.

Le 2026-11-10, un conteneur Debian 13 dédié a convergé `jsvc` de 0 vers 1, vérifié une seconde exécution sans changement, puis convergé de 1 vers 0 et vérifié à nouveau l'idempotence. APT a indiqué zéro mise à niveau et un seul paquet retiré ; `openjdk-21-jre-headless`, installé comme dépendance, est resté présent. Le conteneur et le script temporaire ont été supprimés.

## 3. Validation et livraison

- [x] 3.1 Tester les combinaisons désir/réalité, les erreurs, l'initialisation, la persistance, les ressources partagées et les logiciels existants dans un environnement isolé.
- [x] 3.2 Mettre à jour et vérifier les documents et spécifications impactés, puis exécuter les vérifications ciblées et globales applicables.
- [x] 3.3 Préparer la synchronisation OpenSpec et la livraison après contrôle des validations.

Après archivage : produire les statistiques requises, vérifier le rapport puis exécuter la CICD autorisée.

## Sous-lots normalisés

Code non attribué : repères provisoires fondés sur l'identifiant technique `converge-software-desired-state` ; normalisation définitive en attente d'ACL.

- Contrats et inventaire : tâches 1.1–1.2 ; prérequis : sources existantes et décision syslog ; validation : inventaire et OpenSpec strict ; état : VALIDÉ au 2026-11-11.
- Moteurs et convergence : tâches 2.1–2.4 ; prérequis : contrats validés ; validation : tests ciblés isolés ; état : VALIDÉ au 2026-11-11.
- Validation et livraison : tâches 3.1–3.3 ; prérequis : implémentation et vérifications ; validation : suite globale, archivage, statistiques et preuves CICD ; état : QUALIFIÉ au 2026-11-11 ; archivage et livraison à effectuer.

Le 2026-11-11, après raccordement : 1 326 tests de la suite générale réussis, dont deux ignorés ; 75 tests ciblés d’aide, migration et routage réussis ; `bash -n`, ShellCheck et OpenSpec strict réussis. Dans un conteneur Debian, les commandes publiques ont migré l’ancienne valeur jsvc, installé le paquet, convergé puis retiré le paquet en vérifiant la persistance. Les autres moteurs et cas d’erreur sont couverts par les tests isolés ; les logiciels externes ne sont pas tous qualifiés en installation réelle.

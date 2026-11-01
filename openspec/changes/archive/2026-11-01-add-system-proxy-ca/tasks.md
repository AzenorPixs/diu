## 1. Spécification

- [x] 1.1 Décrire la déclaration statique `SYSTEM_PROXY_CA` et la migration de l’option historique.
- [x] 1.2 Valider strictement le change OpenSpec avant toute modification du code ou des tests.

## 2. Implémentation

- [x] 2.1 Ajouter la déclaration statique dans le scope `system` et remplacer l’usage de `PROXY_CA` dans le point d’entrée.
- [x] 2.2 Étendre le nettoyage historique à `PROXY_CA` sans transférer sa valeur.
- [x] 2.3 Ajouter les tests de déclaration, de persistance, de nettoyage et de consommation du nouveau nom.

## 3. Documentation

- [x] 3.1 Mettre à jour `TECHNICAL.md` et `CHANGELOG.md` selon le comportement livré.
- [x] 3.2 Actualiser de façon ciblée `DEVELOPMENT_MAP.md` et `openspec/BATCH_CODES.md` avec le change actif sans code.

## 4. Validation et livraison

- [x] 4.1 Exécuter les tests ciblés, `bash -n`, ShellCheck et les validations OpenSpec applicables.
- [x] 4.2 Exécuter les validations globales applicables et vérifier la cohérence documentaire.
- [x] 4.3 Vérifier les liens, totaux et l’état provisoire du change dans la cartographie et le registre.

## Preuves de validation

- `sudo -n -u devops env OPENSPEC_TELEMETRY=0 /home/devops/.local/npm/bin/openspec validate add-system-proxy-ca --type change --strict --no-interactive` : succès avant implémentation et après intégration.
- `/home/devops/python/current/bin/python3 -B -m unittest discover -s tests -p 'test_*.py'` : 672 tests réussis, deux ignorés.
- `python3 -B -m unittest discover -s tests -p 'test_system_proxy_ca.py' -v` : 5 tests réussis.
- `python3 -B -m unittest discover -s tests -p 'test_config_cleanup.py' -v` : 7 tests réussis.
- `bash -n root-install-debian.sh modules/diu/variables/system/system_proxy_ca.sh modules/system/variables-cleanup.sh` : succès.
- `shellcheck root-install-debian.sh modules/diu/variables/system/system_proxy_ca.sh modules/system/variables-cleanup.sh` : succès.
- `python3 -B -m py_compile tests/test_system_proxy_ca.py tests/test_config_cleanup.py` : succès.
- Cartographie et registre : totaux, entrée provisoire et chemins du change relus et concordants.
- La qualification du paquet mis à jour dans le LXC reste en attente du changement de version et de la disponibilité du paquet par le développeur.

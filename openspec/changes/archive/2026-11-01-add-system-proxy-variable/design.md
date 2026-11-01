# Conception — SYSTEM_PROXY

## Décisions

- Déclarer `SYSTEM_PROXY` dans `modules/diu/variables/system/system_proxy.sh`
  avec les choix validés `STATIC`, `ENABLE`, `system`, défaut `0`.
- Remplacer uniquement les références au drapeau exact `PROXY` dans les
  consommateurs du point d’entrée. Les variables `PROXY_HTTP*` restent
  distinctes.
- Étendre le nettoyage historique pour transférer les affectations simples
  littérales `PROXY=0` ou `PROXY=1` vers `/root/diu/config/system.env`, avant
  leur suppression de `/root/diu/variables.sh`.
- Si `system.env` déclare déjà `SYSTEM_PROXY`, conserver cette déclaration
  et retirer l’ancienne affectation sans transfert.
- Toute affectation `PROXY` reconnue mais non conforme au format littéral
  accepté provoque un échec explicite avant modification des fichiers.
- Préserver le comportement par défaut désactivé et les commandes proxy
  existantes lorsque `SYSTEM_PROXY=1`.

## Risques et repli

Le transfert est limité aux valeurs booléennes littérales attendues par les
consommateurs existants. La migration écrit la nouvelle configuration avant
de supprimer l’ancienne affectation ; un échec conserve la source historique
et retourne une erreur afin qu’une nouvelle exécution puisse reprendre sans
perte silencieuse.

La construction et l’installation du prochain paquet ne font pas partie de ce
change ; elles fourniront la preuve CISMP après le changement de version sur
l’hôte.

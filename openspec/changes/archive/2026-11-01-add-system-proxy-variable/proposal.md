# Déclaration modulaire de SYSTEM_PROXY

## Résumé

Remplacer le drapeau historique `PROXY` par la variable système déclarée
`SYSTEM_PROXY`, afin que le point d’entrée DIU continue sous `set -u` et que
la configuration proxy soit persistée selon le système déclaratif actuel.

## Motivation

L’exécution de `root-install-debian.sh` dans CISMP s’arrête à la ligne 1854
sur `PROXY: unbound variable`. La variable historique est aussi consommée
dans le bloc de configuration Java. Le chargement modulaire découvre les
fichiers de variable sous `modules/diu/variables/`.

## Comportement attendu

- `SYSTEM_PROXY` est déclarée `STATIC`, `ENABLE`, scope `system`, défaut `0`.
- Les consommateurs système et Java utilisent `SYSTEM_PROXY` et traitent
  une variable absente comme désactivée.
- Une affectation historique littérale `PROXY=0` ou `PROXY=1` est migrée vers
  `SYSTEM_PROXY` lorsqu’aucune déclaration `SYSTEM_PROXY` n’existe déjà.
- Une déclaration `SYSTEM_PROXY` existante prévaut sur la valeur historique.
- Une affectation historique `PROXY` non littérale ou ambiguë bloque le
  nettoyage avec un diagnostic, sans afficher la valeur ni altérer le fichier.
- Les autres variables, notamment `PROXY_HTTP` et `PROXY_HTTP_HOST`, gardent
  leur comportement.

## Code de lot

Code non attribué. L’attribution reste distincte et pourra être mandatée par
ACL ; aucun code n’est inventé dans ce change.

## Hors périmètre

La construction du paquet Debian, le changement de version sur l’hôte et son
installation ultérieure dans CISMP sont réalisés dans le cycle de livraison
suivant. Les réglages hôte, certificats et valeurs proxy ne sont pas changés.

## Critères d’acceptation

1. La déclaration persiste et exporte `SYSTEM_PROXY=0` par défaut.
2. Les valeurs `0` et `1` contrôlent les deux blocs historiques système et Java.
3. Les valeurs historiques simples sont migrées sans exécuter ni afficher
   `variables.sh`; les cas ambigus échouent sans mutation.
4. Les autres variables et comportements proxy non concernés restent
   inchangés.
5. Les tests ciblés, contrôles shell et validation OpenSpec réussissent.

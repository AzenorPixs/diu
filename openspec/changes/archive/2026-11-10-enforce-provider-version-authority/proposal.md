# Autorité de la version publiée — code non attribué

## Pourquoi

Un push ou une CI/CD doit faire autorité sur l'état distant lorsque sa version n'est pas inférieure à une version déjà publiée, et refuser une régression de version.

## Changements

Comparer tous les tags distants reconnus avant publication. Refuser tout tag supérieur ou non comparable ; les versions stables priment sur les horodatages. Pour une version égale ou supérieure, remplacer la branche et le tag ciblés par les références locales, avec protection par SHA attendu. Chaque commande directe conserve son fournisseur ; CI/CD conserve son orchestration. Les autres tags distants et les artefacts existants sont préservés.

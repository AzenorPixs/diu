# Conception — SYSTEM_IPV6

## Déclaration statique

Ajouter `modules/diu/variables/system/system_ipv6.sh` en `STATIC`, `ENABLE`,
scope `system`. Si `SYSTEM_IPV6` est absente après le chargement de la
configuration, `variable_generator()` lit `net.ipv6.conf.all.disable_ipv6`.
La valeur sysctl `0` signifie IPv6 actif et produit `SYSTEM_IPV6=1`; la valeur
`1` produit `SYSTEM_IPV6=0`. Toute autre valeur ou erreur de lecture bloque la
génération. La valeur détectée est persistée dans `system.env`, puis exportée.

## Migration historique

Étendre `config_cleanup` pour accepter les affectations simples `IPv6=0|1`,
avec `export` facultatif et commentaire final facultatif. Retenir la dernière
valeur, persister celle-ci sous `SYSTEM_IPV6` uniquement si ce nouveau nom
n’est pas déjà déclaré, puis retirer les affectations historiques. Une forme
ambiguë bloque avant toute écriture.

## Consommateur et validation

Renommer le consommateur dans le point d’entrée sans modifier les écritures
sysctl existantes. Tester les deux valeurs détectées, l’erreur et la sortie
invalide de sysctl, la persistance, la priorité d’une valeur préconfigurée,
la migration de `0` et `1`, l’ambiguïté et l’absence d’ancien consommateur.

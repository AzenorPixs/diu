# Proposition : moteur APT du module softwares

## Problème

DIU dispose d'un moteur de configuration des dépôts APT dans le module
`system`, mais le cycle de vie des logiciels tiers n'est pas implémenté dans
le module `softwares`. Les anciennes commandes `rid install|remove|update apt`
ne correspondent pas à l'organisation modulaire cible.

## Évolution proposée

Ajouter au module `softwares` l'infrastructure d'un moteur APT global,
granulaire et idempotent, prête à recevoir ultérieurement des sous-fonctions
explicites propres à chaque logiciel déclaré par les variables globales. Aucun
logiciel concret ne sera déclaré dans cette évolution. Les commandes deviennent :

```text
rid softwares install apt <SOFTWARE>
rid softwares remove apt <SOFTWARE>
rid softwares update apt <SOFTWARE>
rid softwares apt update
```

La commande `rid softwares apt update` met à jour tous les paquets installés
avec APT. Elle est appelée par les commandes globales `rid softwares update` et
`rid update`. Les opérations granulaires ne sont pas rejouées pendant cette
mise à jour globale.

Le chargement respecte l'ordre `diu`, `system`, `softwares`, puis les autres
modules. Le moteur de configuration des dépôts reste dans `system`, tandis que
son utilisation pour la mise à jour APT est migrée vers `softwares`.

## Hors périmètre

- création de nouveaux dépôts APT ;
- modification des variables de dépôts existantes ;
- installation arbitraire construite depuis une entrée utilisateur ;
- modification de la configuration OpenCode ;
- commit ou archivage Git automatique.

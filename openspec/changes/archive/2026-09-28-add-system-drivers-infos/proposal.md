# Why
Afficher l’état DisplayLink et sa version dans les informations système.

# What Changes
- Ajouter system_info_drivers et rid system infos drivers.
- Afficher la variable, puis la version du paquet displaylink-driver seulement si elle vaut 1.
- Agréger Debian, drivers, réseau dans cet ordre, et adapter l’aide.
- Conserver rid system update inchangé conformément à la correction du développeur.

# Capabilities
## Modified Capabilities
- module-infos
- rid-help

# Impact
modules/system/infos.sh, modules/system/apt.sh (routage uniquement), lib/rid-help.sh, tests/test_module_infos.py et TECHNICAL.md. Aucun changement de configuration, dépendance ou installation. Le bootstrap existant reste inchangé.

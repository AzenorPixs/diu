# Conception — SYSTEM_CROWDSEC_AGENT

Ajouter `modules/diu/variables/system/system_crowdsec_agent.sh` en `STATIC`,
`ENABLE`, scope `system`, défaut `0`. Remplacer le consommateur `CROWDSEC_AGENT`
par `SYSTEM_CROWDSEC_AGENT`, sans modifier le flux d’installation.

Étendre `config_cleanup` pour accepter les affectations simples `CROWDSEC_AGENT=0|1`,
avec export et commentaire facultatifs. Retenir la dernière valeur, la migrer
vers `system.env` seulement si `SYSTEM_CROWDSEC_AGENT` n’y est pas déjà déclaré,
puis supprimer les anciennes affectations. Une forme ambiguë bloque avant
toute écriture.

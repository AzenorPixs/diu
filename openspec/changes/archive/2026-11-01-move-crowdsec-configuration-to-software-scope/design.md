# Design

Les déclarations STATIC/ENABLE du dépôt, de l'agent et du bouncer résident dans
`modules/diu/variables/softwares/` et utilisent `softwares.env`. Le contrôle du
dépôt conserve la détection des sources APT, et s'active par défaut si l'agent
ou le bouncer est activé. Une valeur déjà déclarée reste prioritaire.

`config_cleanup` transfère les valeurs simples des anciens noms vers les
nouveaux noms et retire les anciennes déclarations de `variables.sh` ou
`system.env`. Les valeurs ambiguës bloquent avant toute suppression. Le
consommateur des dépôts utilise `SOFTWARES_APT_CROWDSEC`; les interrupteurs
agent et bouncer gardent leurs installations APT existantes. La clé API est
copiée sans évaluation, validation ni affichage de son contenu. Sa migration
restreint `softwares.env` au mode `0600`; son application à YAML se fait sans
transmission dans les arguments d'un processus enfant ni sortie de la valeur.

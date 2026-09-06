# Gestion logicielle

### Requirement: Retrait de la personnalisation ChatGPT

Les commandes `rid softwares install apt chatgpt`, `rid softwares remove apt
chatgpt` et `rid softwares update apt chatgpt` SHALL gérer uniquement le paquet
APT ChatGPT et son dépôt. Elles SHALL NOT modifier
`/usr/share/applications/chatgpt.desktop` ni utiliser
`SOFTWARES_APT_CHATGPT_HOME`.

### Requirement: Variable ChatGPT minimale

Le module de variables ChatGPT SHALL gérer uniquement
`SOFTWARES_APT_CHATGPT`. Il SHALL NOT créer, conserver ou persister
`SOFTWARES_APT_CHATGPT_HOME`.

### Requirement: Conservation du moteur APT

Le retrait de cette personnalisation SHALL préserver l'installation, la
désinstallation, la mise à jour et la gestion du dépôt APT `chatgpt`.


# Conception

`projects_forgejo_release <ID PROJECT>` charge `project.env` après avoir
validé le répertoire du projet. Il vérifie d'abord les variables générales
du projet. Si elles sont absentes, vides ou incomplètes, il appelle
`update_projects <ID PROJECT>`, recharge le fichier et vérifie de nouveau.

Il vérifie ensuite les variables `REMOTE_FORGEJO_*`. Si cette configuration
est absente, vide ou incomplète, il appelle `forgejo_update <ID PROJECT>`,
recharge le fichier et vérifie de nouveau. Les fonctions de mise à jour
restent responsables de leurs interactions et de la conservation des autres
variables de `project.env`.

Les artefacts sont sélectionnés indépendamment selon les indicateurs
`PROJECT_DOCKERED` et `PROJECT_DEBIAN_PACKAGE`, avec les valeurs activées
`Yes`, `YES` ou `1`.

Les prérequis locaux des artefacts sont vérifiés avant tout push afin de
refuser une release partielle lorsqu'une image Docker manque ou lorsque
`dist/` est absent, vide ou contient plusieurs paquets Debian.

Pour Docker, l'image locale `${PROJECT_ID}:latest` doit déjà être visible par
Docker pour `DEVOPS_USER`. Le flux réutilise l'authentification Forgejo
existante, crée les tags versionné et `latest`, puis pousse les deux tags.

Pour Debian, `dist/` doit exister et contenir exactement un paquet `.deb`
correspondant au projet. Le paquet est validé avec `dpkg-deb` avant d'être
publié par le mécanisme de release Forgejo existant. Un projet doit activer au
moins un des deux artefacts.

Le dispatch appelle uniquement `projects_forgejo_release` pour la nouvelle
commande. Les entrées d'aide retirent `gitpdi` et décrivent `release`.

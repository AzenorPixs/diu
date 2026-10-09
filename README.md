# Debian Installer Unifié (DIU)

Le DIU installe et configure Debian grâce à une architecture modulaire en
Bash. Le module `projects` gère également les projets de développement et
leurs publications Forgejo.

Pour publier les artefacts activés d’un projet :

```bash
rid projects forgejo release <ID PROJECT>
```

La commande publie l’image Docker et/ou le paquet Debian selon
`PROJECT_DOCKERED` et `PROJECT_DEBIAN_PACKAGE` dans `project.env`.

Pour générer l'inventaire DevOps d'un projet :

```bash
rid projects template devops <ID PROJECT>
```

`DEVOPS.md` est généré au format documentaire `0.3`, avec provenance DIU,
début du relevé UTC et classification de l'environnement d'exécution fournie
par DIU. Sa légende distingue les sondes système des outils et dépendances
DevOps. Cet inventaire ne constitue pas une qualification fonctionnelle ni
une preuve de réussite des tests. Les détails sont décrits dans
[le cadrage technique](TECHNICAL.md#traçabilité-du-document-devops).

# Why

L'environnement Docker doit offrir aux comptes humains locaux le même accès
sudo sans mot de passe que l'environnement DevOps, avec `ENV_DOCKER_USER`
comme cible. Le bloc `ENV_DOCKER` ne génère actuellement aucun fragment dédié.

# What Changes

- Appeler la génération à la fin du bloc `ENV_DOCKER=1` si le compte cible
  existe, en reprenant les critères humains validés pour DevOps.
- Gérer `/etc/sudoers.d/99-diu-docker`, validé avant remplacement atomique,
  avec propriétaire `root:root` et mode `0440`.
- Partager le mécanisme interne dans le point d'entrée, tout en conservant
  `configure_devops_sudoers`, son comportement et son fragment indépendant.
- Adapter les tests DevOps au mécanisme commun, ajouter les tests Docker et
  documenter les deux environnements.

# Impact

Seuls `root-install-debian.sh`, `TECHNICAL.md`, les tests sudoers et les
artefacts OpenSpec ciblés sont concernés. Les règles DevOps existantes, PAM,
les autres fragments sudoers et les opérations Docker restent inchangés.
Aucune dépendance, opération Git ou modification système réelle n'est incluse.
Le développeur a explicitement validé ce périmètre jusqu'à l'archivage dans
la session SCM courante.

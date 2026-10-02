## Context

Le monolithe est exécuté avec les droits root. Le bloc `PYTHON=1`, à l'intérieur
de `ENV_DEVOPS=1`, prépare le Python compilé, son lien `current` et les liens
`python3`/`pip3`. Le changement doit aussi fonctionner lorsque la version de
Python est déjà à jour. Les droits du domicile DevOps sont ensuite rétablis
par le traitement existant du bloc ENV_DEVOPS.

## Goals / Non-Goals

Installer et maintenir Psycopg 3 et son implémentation binaire dans le Python
DevOps, sans réinstallation forcée. Préserver la compilation Python, les
profils, la gestion existante des droits et le conteneur OpenCode.
Ne pas modifier les dépendances propres aux projets ni leurs manifestes.

## Decisions

- Placer l'installation après les deux liens `python3`/`pip3` et avant le
  profil, hors de la condition qui décide de recompiler Python.
- Appeler directement `/home/${ENV_DEVOPS_USER}/python/current/bin/python3`
  avec `-m pip install --upgrade --no-user "psycopg[binary]>=3.2,<4"`.
  L'interpréteur sélectionne le bon pip et `--no-user` exclut l'installation
  dans le site utilisateur de root. L'appel reste sous l'identité root du DIU :
  un nouveau préfixe peut encore appartenir à root à cet endroit du bloc.
- Laisser pip résoudre les versions compatibles et mettre à jour l'extra
  binaire ; ne pas dupliquer son résolveur et ne pas employer `--force-reinstall`.
- Encadrer l'installation et le contrôle d'import par des conditions d'échec
  explicites, avec message utile et `exit 1`. Afficher la version seulement
  après réussite de l'import. Ne pas prétendre vérifier une connexion PostgreSQL.
- Tester le bloc réel extrait du monolithe, avec chemins redirigés uniquement
  vers un répertoire temporaire du dépôt et commandes externes contrôlées.

## Risks / Trade-offs

L'accès à l'index pip est nécessaire à chaque passage activé. Un échec réseau
ou une roue binaire indisponible fait échouer l'installation. La sélection de
la dernière version compatible peut changer avec l'index : l'idempotence
garantit l'absence de réinstallation lorsque l'état disponible est inchangé,
pas le verrouillage d'une version. Aucun rollback automatique n'est ajouté.

## Validation

Syntaxe Bash, ShellCheck, tests isolés du bloc Python, tests existants du
monolithe et de l'activation DevOps, validation OpenSpec stricte, contrôle
UTF-8/LF et revue des modifications sans inspection Git. L'installation
réelle et la connexion PostgreSQL restent hors des validations de cette session.

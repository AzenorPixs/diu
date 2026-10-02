# Context and Diagnosis

L'appel configure_docker_sudoers figurait avant le fi final mais après le
else externe de ENV_DOCKER. Le test d'activation prélevait cet appel et lui
préfixait une condition active reconstruite ; il perdait donc sa branche
réelle. L'assertion précédente ne prouvait pas le routage du code livré.

Le test réparé conserve les branches then/else observées et retire seulement
les autres opérations système. Avant correction du code, la suite Docker
a réellement exécuté 20 tests avec trois échecs : activation, absence de
mutation lorsque désactivé, et appel en dernière instruction de branche active.
Ces faits rectifient la conclusion de cohérence du cycle Docker précédent.

# Decisions

- Déplacer uniquement l'appel Docker avant le else externe. La branche de
  désactivation et ses opérations existantes ne sont pas modifiées.
- Conserver le mécanisme partagé, les critères UID/shell et les exclusions.
- Lire les noms dans le candidat généré, après le filtrage et avant sa
  validation/publication. Cette lecture fait partie des étapes dont un échec
  préserve le fragment précédent. Le commentaire est exclu ; les noms sont
  séparés par un espace, sans espace final et dans l'ordre des règles.
- Émettre le message nominatif uniquement après publication réussie. En cas
  de sélection vide, publier comme auparavant le fragment commenté puis
  afficher `Sudoers <label> : aucun compte humain retenu.`. Les diagnostics
  de compte cible absent et d'erreur sont conservés, sans faux succès.
- Le développeur demande explicitement l'affichage de ces noms ; ils sont les
  identités sélectionnées pour la politique, sans lecture de mots de passe ou
  d'autres données sensibles.

# Validation and Limits

Réexécuter bash -n, ShellCheck, les suites DevOps, Docker et du monolithe.
Vérifier les messages pour plusieurs comptes, une sélection vide, les erreurs,
le compte absent et le routage réel des branches Docker. Les candidats sont
contrôlés par le vrai visudo disponible ; les commandes privilégiées sont
simulées, dans les mêmes fixtures locales et nettoyées que précédemment.
Valider le change, puis les deux spécifications synchronisées et vérifier
l'identité des exigences avec les deltas archivés. Aucun environnement réel
n'est configuré pendant cette session ; sa politique effective reste à
contrôler après exécution du DIU.

# Observed Validation — 2026-10-02

- `bash -n root-install-debian.sh` : réussi.
- ShellCheck : réussi, zéro diagnostic ; également exécuté directement dans
  la suite du monolithe.
- `python3 -B -m unittest discover -s tests -p test_devops_sudoers.py -v` :
  16 tests réussis, aucun ignoré.
- `python3 -B -m unittest discover -s tests -p test_docker_sudoers.py -v` :
  21 tests réussis, aucun ignoré, après les trois échecs reproduits avant fix.
- `python3 -B -m unittest discover -s tests -p test_root_shellcheck.py -v` :
  9 tests réussis.
- Les tests contrôlent les messages exacts pour alice/bob, l'ordre zoe/alice
  après exclusion d'un shell false et déduplication, la sélection vide, le
  compte cible absent et l'absence de faux succès sur erreur. Un échec simulé
  de la lecture des noms préserve également le fragment précédent.
- Le vrai visudo disponible valide les candidats isolés ; les actions
  privilégiées sont simulées comme dans les cycles précédents.
- `openspec validate report-sudoers-human-accounts --strict` : réussi avant
  les modifications fonctionnelles et après revue.
- Relecture : l'appel Docker est en dernière instruction de branche active,
  avant le else externe, et absent de la branche de désactivation. Les noms
  proviennent du candidat filtré et le message suit la publication réussie.

TECHNICAL.md est aligné avec le code et les deltas. PROJECT.md, BUILD.md,
DEVOPS.md, README.md et AGENTS.md ne nécessitent pas de changement pour ce
périmètre. Les autres parties du script et de la documentation ont été
préservées. Aucun fichier système réel ni état Docker n'a été modifié ; aucune
opération Git n'a été exécutée.

L'archivage a réussi avec
`openspec archive report-sudoers-human-accounts --json --yes` : deux exigences
de compte rendu ajoutées et une exigence d'activation Docker précisée dans les
spécifications principales. Les validations strictes de devops-sudoers et
docker-sudoers ont réussi après synchronisation. OpenSpec émet seulement trois
conseils de concision sur des exigences DevOps préexistantes ; aucune erreur
de validation ne subsiste.

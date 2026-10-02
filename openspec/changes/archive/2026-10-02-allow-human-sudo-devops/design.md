# Context

`root-install-debian.sh` prépare déjà `ENV_DEVOPS_USER` dans le bloc activé par
`ENV_DEVOPS=1`. Les comptes Docker et IA peuvent aussi avoir un UID ordinaire
et un shell Bash : ils doivent être exclus explicitement.

# Decisions

- Définir une fonction interne dans le point d'entrée et l'appeler à la fin du
  bloc DevOps. Ses chemins optionnels permettent de tester avec des fixtures,
  sans ajouter de variable de configuration publique.
- Lire exclusivement les comptes locaux de `/etc/passwd`. La notion de compte
  humain est une convention validée fondée sur les UID et shells, pas une
  information explicite fournie par passwd. Un autre compte technique doté
  d'un UID ordinaire et d'un shell de connexion reste sélectionnable.
- Exiger des bornes UID numériques, positives et ordonnées ; une lecture ou
  configuration invalide provoque un diagnostic et un retour non nul.
- Construire un candidat caché dans le répertoire sudoers : les fichiers
  contenant un point sont ignorés par l'inclusion standard sudoers.d. Valider
  ce candidat avec `visudo -cf`, fixer propriétaire et mode, puis le renommer
  atomiquement vers `99-diu-devops`. Aucun fichier existant n'est remplacé en
  cas d'échec avant publication. Le candidat est supprimé sur erreur.
- Réécrire seulement le fichier géré ; une sélection vide produit un fichier
  commenté sans règle. Les autres fragments sudoers ne sont pas modifiés.
- Refuser avec un diagnostic les noms incompatibles avec une identité sudoers
  simple, notamment les virgules et espaces, avant publication ; une validation
  syntaxique seule pourrait accepter une virgule comme liste d'utilisateurs.
- Ne rien générer lorsque le compte DevOps est absent. Le bloc désactivé ne
  lance pas la fonction ; il ne révoque pas de règles déjà installées.

# Risks and Rollback

Toute personne sélectionnée peut agir avec les droits DevOps. Une règle
sudoers ultérieure contradictoire peut influer sur la politique effective.
La validation du candidat vérifie sa syntaxe ; la politique globale et les
accès effectifs sur une installation nécessitent un contrôle administrateur.
Le remplacement atomique préserve le fichier précédent sur erreur de
préparation ou validation. Après une publication réussie, la restauration
d'une ancienne politique relève d'une intervention administrateur distincte.

# Validation

`bash -n`, ShellCheck et les tests existants du monolithe contrôlent la
compatibilité. Les tests ciblés utilisent des fixtures passwd/login.defs et
un répertoire temporaire dans le dépôt. Les commandes privilégiées sont
simulées ; aucun compte, fragment sudoers réel ou autre fichier système n'est
modifié. Lorsque disponible, le vrai `visudo` valide également le fragment
généré isolé. Les tests vérifient le contenu, l'exclusion des comptes, les
bornes UID, le shell, l'idempotence et la préservation sur erreurs.

# Observed Validation — 2026-10-02

- `bash -n root-install-debian.sh` : réussi.
- ShellCheck : réussi, zéro diagnostic après correction des trois diagnostics
  introduits par l'ajout initial. Le test existant exécute également
  `shellcheck root-install-debian.sh` directement avec succès.
- `python3 -B -m unittest discover -s tests -p test_devops_sudoers.py -v` :
  15 tests réussis, aucun ignoré. Le vrai `/usr/sbin/visudo` contrôle les
  fragments isolés ; chown est simulé et ses arguments root:root vérifiés.
- `python3 -B -m unittest discover -s tests -p test_root_shellcheck.py -v` :
  9 tests de régression réussis.
- `openspec validate allow-human-sudo-devops --strict` : réussi.
- Relecture ciblée : appel après le profil DevOps et avant le fi final,
  documentation TECHNICAL.md alignée avec la spécification. PROJECT.md,
  BUILD.md, DEVOPS.md, README.md et AGENTS.md ne nécessitent pas de modification
  pour ce périmètre. Aucun comportement existant non concerné n'a été modifié.

Les vérifications sont isolées : aucune installation complète, modification
PAM, mutation des comptes ou publication dans `/etc/sudoers.d` sur cette
machine n'a été exécutée. Les droits effectifs dans la politique sudoers
globale d'une installation restent un contrôle administrateur après exécution
du DIU. Aucune opération Git n'a été effectuée.

L'archivage a réussi avec
`openspec archive allow-human-sudo-devops --json --yes` : quatre exigences
ajoutées à `openspec/specs/devops-sudoers/spec.md`, et change déplacé vers
`openspec/changes/archive/2026-10-02-allow-human-sudo-devops`. La première
invocation JSON exigeait le drapeau de confirmation ; la validation explicite
du développeur incluait déjà cette synchronisation et cet archivage. Le texte
Purpose provisoire généré par OpenSpec a été remplacé par l'objectif réel.

# Publication Debian GitHub

Les contrôles reprennent Forgejo : projet et configuration cohérents, un seul
.deb régulier dans dist, Package égal à l'identifiant projet, fichier
<ID>_<VERSION>_all.deb et métadonnées concordants. La version est vérifiée par
le helper commun diu_release_version_matches. Sans PROJECT_VERSION ni tag, la
version du paquet reste la référence ; une ambiguïté Git n'est pas ignorée.

Le dépôt déclaré doit correspondre au remote Git réel. Après fetch authentifié,
la branche courante doit être la branche locale attendue et HEAD doit égaler la
branche distante configurée. Le tag v<VERSION> existant est réutilisé seulement
si sa source est Git et s'il désigne ce HEAD. Un tag absent peut être créé sur
ce HEAD, sans déplacement de référence existante. Une release existante provoque
un refus : aucun asset ni release n'est remplacé ou supprimé automatiquement.

Le transport réutilise _github_api_request et les lecteurs de credentials.
Un helper distinct réalise l'upload binaire vers upload_url, après validation
de son origine et de son chemin (uploads.github.com pour GitHub public, même
base API pour Enterprise). Les credentials restent dans un fichier temporaire
0600, jamais dans les arguments ni dans les journaux. Les temporaires sont
nettoyés, y compris en erreur et interruption. HTTP, JSON et métadonnées de la
réponse d'upload sont contrôlés avant succès. Une release créée mais incomplète
reste signalée, sans rollback automatique, comme sur Forgejo.

La commande projects_github_release devient un sélecteur d'artefacts. Le corps
GHCR existant passe dans projects_github_release_docker, sans modification de
ses tags, références, credentials ou absence de build. Pour Debian seul, Docker
n'est ni requis ni appelé. Pour les deux, la présence du paquet est vérifiée
avant la publication Docker, puis les deux publications sont exécutées dans
cet ordre. Un projet sans artefact activé termine sans publication.

La CI/CD conserve l'activation Docker exacte Yes. Sans Docker actif, elle appelle
le helper Debian seul pour éviter toute publication Docker induite par d'autres
valeurs du champ ; en parcours mixte elle appelle le sélecteur. La commande
directe conserve les valeurs actives Yes/YES/1 pour les deux artefacts.
Les six étapes et les règles d'indisponibilité sont inchangées.

Les API publiques utilisées sont documentées dans GitHub REST Releases et
Release assets. Les tests utilisent des paquets réels de fixture et des
transports simulés, sans accès aux credentials ou réseaux réels.

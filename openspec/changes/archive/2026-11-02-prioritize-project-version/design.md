# Version de projet optionnelle

PROJECT_VERSION est lue par lib/project-version.sh, sans source/eval ni expansion
et sans publication des autres clés de project.env. Une seule affectation
littérale x.y.z est acceptée, éventuellement citée et commentée ; chacun des trois
entiers est sans zéro initial sauf 0. Une clé absente renvoie une sortie vide ;
une clé présente vide, dupliquée, invalide ou un fichier illisible/symbolique échoue.
La version est limitée à 128 caractères pour les tags Docker.

La priorité Debian est PROJECT_VERSION, puis recette.version pour le builder
générique, puis les règles de tags/horodatage précédentes. Pour le builder
historique et sa release, le helper existant reste l'interface compatible.

Les commits individuels et groupés et les flux CICD utilisent v<VERSION>.
Le nom automatique devient VERSION ; une description explicite est conservée.
Avant un nouveau commit versionné, une collision de tag est refusée sans commit.
Un arbre inchangé ne crée toujours ni commit vide ni tag.
Les pushes choisissent exclusivement ce tag quand la version est déclarée et
vérifient qu'il pointe sur HEAD avant toute publication ; les autres tags sont
ignorés. Un push ne crée ni ne remplace un tag.

Le build Docker conserve latest et ajoute le tag local VERSION. Les releases
versionnées utilisent cette image locale précise, et non un latest potentiellement
ancien. Le tag Git v<VERSION> doit désigner HEAD avant la publication Docker.
Le paquet Debian publié doit aussi porter la version déclarée. Sans clé, les
anciennes règles et transports (leases Forgejo/GitHub, push GitLab normal) restent
inchangés. Les images, paquets ou tags incohérents sont refusés sans réécriture.

La clôture SCM utilise le message 1.0.0 et le tag v1.0.0 sur le commit local,
après vérification d'absence de collision. La variable existante n'est pas modifiée.
Aucune installation, release réelle d'artefact ou migration de configuration n'est
nécessaire. Les nouvelles lectures n'introduisent pas d'exécution de configuration ;
les chargements historiques étrangers au sélecteur restent hors refactoring.

# Orchestration à six étapes

Le flux réutilise projects_build_deb pour la CLI build debian et son alias deb,
sans relancer le bootstrap de rid depuis la CI/CD. L'activation Debian est
exactement Yes, YES ou 1 ; absent, vide et toute autre valeur ignorent cette
construction. La lecture de configuration générale reste celle du flux existant.
Le builder conserve les contrôles de recette et de configuration littérale.

La sortie anticipée liée à Docker est remplacée par deux activations indépendantes.
L'activation Docker reste exactement Yes. Les étapes sont affichées même lorsque
leur opération est ignorée ; le bilan expose séparément les résultats des builds.
Les publications n'interviennent qu'après les builds activés réussis.

Avec Docker actif, les fonctions de release conditionnelles existantes sont
conservées. Pour Debian seul, appeler publish_release_debian pour Forgejo et
projects_gitlab_release_debian pour GitLab. La release GitHub reste réservée à
Docker, aucune capacité Debian GitHub n'est créée. Les conditions de complétude
fournisseur existantes, dont le registre GitLab, restent inchangées.

Le bilan conserve ses onze premiers paramètres et reçoit le statut Debian en
douzième paramètre facultatif pour préserver les appels existants. Il affiche
l'étape 6/6, les deux builds et les publications d'artefacts. Une erreur de build
Debian interrompt le flux avec bilan partiel et sans release ; les pushes déjà
réalisés restent publiés. Une indisponibilité reconnue permet les deux builds
et ignore les publications du seul fournisseur concerné, sans masquer une erreur.

La version est portée à 1.0.2 par une modification locale filtrée de la seule clé
PROJECT_VERSION de project.env, sans exécution ni exposition des autres valeurs,
en préservant leurs octets, permissions et propriétaire. Les autres sources et
les fichiers privés ne sont pas migrés. Les anciens parcours projects deb et
cicddiu restent inchangés. Repli : build deb reste accepté ; aucun renommage.

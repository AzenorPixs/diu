# Revue finale — Arguments Docker publics

Date : 15 octobre 2026. Session SCM directe, sans délégation, OpenCode/CAB
ou compétence de statistiques de pilotage. Les huit tâches applicables sont
réalisées ; validation stricte finale réussie sans issue, archivage réussi.

## Résultat et périmètre

Le module de construction utilise un lecteur générique du fichier public
optionnel `build/docker-build.args`. Il ne sélectionne aucune application,
version métier, URL d'artefact ou helper de projet. Les paramètres restent
exclusivement dans les projets consommateurs. Aucune configuration sensible
réelle, opération Git, installation système, CI/CD réelle, publication ou
mise en service n'est exécutée.

Le lecteur valide avant Docker, sans source/eval ni expansion, dans un tableau
transactionnel. Il borne la lecture, ferme son descripteur, refuse doublons,
clés invalides, CR/NUL, liens, ressources non régulières/illisibles et taille
supérieure à 65 536 octets. Les valeurs restent opaques et littérales. Le
fichier n'est pas réécrit. Sans fichier, utilisateur, chemins, tag et arguments
historiques sont conservés. Le contrôle de Dockerisation et les fichiers requis
restent prioritaires. Les erreurs propres au lecteur ne reprennent aucune valeur.

## Validations exécutées

- `bash -n modules/projects/docker.sh` : exécutée et réussie.
- `shellcheck modules/projects/docker.sh` : exécutée et réussie. La directive
  SC2034 est limitée à l'affectation par nameref du tableau appelant, dont
  l'utilisation est établie par les tests ; aucun diagnostic fonctionnel masqué.
- Compilation Python : exécutée et réussie pour les deux fichiers de test concernés.
- Suite DIU dédiée : 17 tests réussis en 0,807 s, aucun test ignoré. Les contrôles
  comprennent conservation de commande/utilisateur, valeurs littérales, absence
  d'exécution shell, doublons, octets interdits, bornes, FIFO/liens, erreurs
  de lecture, priorité des contrôles et fermeture de descripteurs sur 100 appels.
- Le test CI/CD appelle la fonction de construction réelle dans une fixture ;
  Git, runuser, Docker et toutes les publications restent simulés.
- Suite de packaging du consommateur : 4 tests réussis en 0,384 s, dont concordance
  stricte des six arguments avec sa référence publique, sans configuration réelle.
- BUILD local : exécuté et réussi avec le tableau produit par le lecteur DIU,
  en dehors du pipeline et sans charger les métadonnées sensibles du projet.
  La commande de version native réussit et correspond au profil du consommateur.
- Les tests runtime/protocoles du consommateur ne sont pas relancés : leurs
  sources, le Dockerfile et les interfaces runtime restent inchangés ; le
  changement concerne uniquement la transmission des paramètres de BUILD.

Deux essais de harnais CI/CD ont été corrigés : fonction print_title simulée
manquante, puis valeur de fixture 1 incompatible avec le parcours CI/CD historique
qui attend Yes. La fixture utilise désormais Yes ; la sélection existante du
pipeline n'est pas modifiée. Les assertions de transmission des arguments et
d'absence d'effets externes sont conservées.

## Matrice de cohérence SCM

| Élément | État | Preuve ou justification |
|---|---|---|
| Projet réel | Modifié dans les sources | Lecteur et intégration Docker, tests isolés et consommateur adapté |
| AGENTS.md | Inchangé | Règles et limites d'autorisation appliquées ; empreinte contrôlée |
| PROJECT.md | Mis à jour | Responsabilité générique du module projects et paramètres propres aux projets |
| TECHNICAL.md | Mis à jour | Contrat complet, refus, tableau, diagnostic et limite de masquage des sorties natives |
| BUILD.md | Inchangé | Document consacré au seul paquet Debian, non concerné par ce mécanisme |
| DEVOPS.md | Inchangé | Outils existants réutilisés, aucun paquet hôte ni inventaire régénéré |
| README.md | Mis à jour | Exemple générique et règles littérales du fichier public |
| CHANGELOG.md | Mis à jour | Entrée Unreleased du nouveau mécanisme sans annonce de publication |
| OpenSpec | Change ciblé | Huit exigences ajoutées à modify-projects-docker-build, sans modification du contrat antérieur |
| Prompts, licence, .gitignore, config OpenSpec | Inchangés | Empreintes vérifiées ; aucune opération d'outillage ou Git |
| ORCHESTRATED_CODING.md | Non applicable | SCM directe, aucun pilotage |
| Autres changes actifs | Hors périmètre | Aucun n'est synchronisé ou archivé par cette session |
| Consommateur | Adapté dans son dépôt | Fichier public, test de concordance et PROJECT/TECHNICAL/BUILD/README/CHANGELOG/exploitation actualisés ; runtime et référence inchangés |

## Limites et compatibilité

Le contrôle pré-archive confirme 12 modifications attendues parmi les
34 références capturées, et 22 empreintes inchangées. Dix-neuf fichiers
concernés respectent UTF-8/LF et les liens locaux. Les huit exigences et douze
scénarios ajoutés sont conformes au format attendu. La recherche ciblée dans
les fichiers DIU concernés confirme l'absence de dépendance applicative.
Les fixtures sont nettoyées ; les règles, prompts, inventaires, paquet Debian
et sources runtime du consommateur restent inchangés.

La syntaxe ne détermine pas la sensibilité d'une valeur arbitraire : le fichier
est réservé au public non sensible et n'est pas une convention de secrets.
Les sorties Docker ne sont pas filtrées. Les quotes sont des caractères
littéraux ; aucune interpolation d'environnement n'est proposée. Aucun
paramètre n'est déduit d'un framework ou d'un fichier de référence applicatif.

Les tests rebasent uniquement le chemin racine historique dans une copie
éphémère du module pour isoler les fixtures. Aucune version installée du DIU
n'est mise à jour. L'installation de cette modification relève d'une action
séparée ; la correction est livrée dans le dépôt de développement.

## Archivage

L'archivage officiel du 15 octobre 2026 réussit dans
`2026-10-15-support-project-docker-build-args`, specsUpdated=true : huit
exigences ajoutées, aucune modifiée, supprimée ou renommée. La validation
stricte de la spécification résultante réussit sans issue. Le rapport
[STATISTIQUES.md](STATISTIQUES.md) est produit dans ce seul dossier ; aucun
autre change n'est archivé et aucun historique Git n'est consulté.

## 1. Spécifications

- [x] 1.1 Valider les exigences du change ciblé avant le code et les tests. Validation stricte réussie ; le bloc d'aide conserve les noms des scénarios remplacés.

## 2. Implémentation

- [x] 2.1 Généraliser la génération, le titre, les chemins et le manifeste conditionnel.
- [x] 2.2 Adapter le routage et toutes les aides template/create.
- [x] 2.3 Intégrer la génération finale à create_project et la copie conditionnelle du manifeste.
- [x] 2.4 Adapter et compléter les tests des trois fichiers concernés.

## 3. Validation

- [x] 3.1 Exécuter les tests ciblés, les sondes réelles, bash -n et ShellCheck. Réussis : 31 tests de génération/sondes/routage, dont cinq tests de sondes réelles sans test ignoré ; 8 tests d'aide et 2 tests de création existants. Les deux tests complétés ensuite ont été réexécutés avec succès. Bash valide les quatre scripts. ShellCheck complet réussit sur template.sh, root-install-debian.sh et rid-help.sh. Sur projects.sh, il signale uniquement SC2004 (style), ligne 375, inchangé avant ce change (preuve par reconstruction en mémoire) ; ShellCheck au niveau warning réussit. Aucun avis nouveau, aucune correction hors périmètre.
- [x] 3.2 Vérifier UTF-8/LF, syntaxe Python, cohérence des cadrages et OpenSpec strict. Réussis : 12 fichiers UTF-8/LF ; syntaxe des trois fichiers de tests et des trois scripts Python intégrés. Cadrages cohérents selon la matrice du design ; change strictement valide. Aucun autre change actif modifié, aucune inspection Git.
- [x] 3.3 Générer réellement DEVOPS.md pour template et vérifier versions, manifeste existant, propriété et idempotence. Deux générations sous devops réussies : Go 1.27.1, PostgreSQL serveur 16.15 sur 127.0.0.1:5432 et lignes PG_HOST/PG_PORT demandées. Contenu stable, droits et propriétaire du document conservés ; manifeste préexistant inchangé, y compris inode et permissions. La création complète est testée sur des projets temporaires, avec génération réelle après copie et droits, pour Node, Python avec manifeste copié, Python sans manifeste et échec final conservant le projet. L'accès root de l'agent reste indisponible sans mot de passe ; aucune commande rid complète ni création réelle interactive sur l'hôte n'a été exécutée en root. Le routage est testé isolément et la génération réelle sous devops.

Archivage ciblé exécuté sous devops avec la confirmation --yes autorisée par
le développeur : `2026-10-02-generalize-projects-template-devops`. Les deux
spécifications sont synchronisées et leurs validations strictes réussissent.
L'objet de la capacité projects-template-devops a été adapté à la génération
par projet. Les remarques informatives de longueur d'exigence sont non
bloquantes. Aucun autre change n'a été archivé.

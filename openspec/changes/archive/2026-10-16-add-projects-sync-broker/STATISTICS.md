# STATISTIQUES — add-projects-sync-broker

Archive : /home/devops/datas/diu/openspec/changes/archive/2026-10-16-add-projects-sync-broker

Conversation source : 01a133bc-a8a2-7b63-be13-34f4a3a860a1. Borne finale : relevé de quota après archivage, avant rédaction du présent rapport.

Périmètre : historique natif de la conversation CGP, tous lots confondus, exposé par read_thread (10 tours, pagination épuisée). Ces agrégats ne sont pas attribués exclusivement à ce change. Les preuves antérieures à cette conversation sont conservées dans tasks.md, mais leurs appels, tokens et coûts ne sont pas reconstitués. Les résultats propres à la reprise d'archivage sont séparés ci-dessous. Le présent rapport, sa création et ses contrôles ultérieurs sont hors de la photographie statistique.

### Agents de codage

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
|---|---|---|---|---|---|---|
| Codex — modèle exact N/A | N/A | N/A | N/A | N/A | N/A | N/A |

### Agents orchestrateurs

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
|---|---|---|---|---|---|---|
| Codex — même acteur, rôle de revue | N/A | N/A | N/A | N/A | N/A | N/A |

Un seul acteur Codex est identifié, assurant les corrections directes et la revue. Aucun agent OpenCode piloté ni service CAB n'a été lancé dans le périmètre observé. Les deux tableaux décrivent des rôles du même acteur, sans double comptage. Version, fournisseur, niveau de raisonnement et temps de génération ne sont pas exposés par cette source. TTMT et débit : N/A — sondes périodiques non activées. Relèves prévues/réussies/échouées/manquées : N/A, collecte non activée. Temps de service et son dénominateur cumulé : N/A ; la durée calendaire et les durées d'outils ne sont pas des mesures de génération.

## 1. Statistiques générales et décisions

| Mesure observable | Valeur | Portée |
|---|---|---|
| Tours retournés | 10 | Conversation CGP jusqu’à la borne finale |
| Éléments natifs | 452 (100,0 %) | Messages, raisonnement résumé et opérations |
| Messages textuels | 48 (100,0 %) | 11 développeur + 37 agent |
| Opérations natives | 229 (100,0 %) | Commandes, appels fichiers et outils MCP |
| Approuvées et exécutées avec succès | 217 (94,8 %) | Résultats techniques réussis, pas nombre de confirmations manuelles |
| Refus de permission explicitement observés | 0 (0,0 %) | Aucun refus dans les événements exposés |
| Erreurs techniques | 12 (5,2 %) | 11 validations OpenSpec historiques en échec et 1 appel read_thread avec limite invalide |
| Tokens entrée/sortie/cache | N/A | Télémétrie non fournie |
| Coût et compactions | N/A | Télémétrie non fournie |
| Approbations manuelles ou automatiques détaillées | N/A | Granularité de décision non exposée par les événements natifs |

Convention : « approuvé et exécuté » désigne ici un événement natif autorisé dans le périmètre de travail, terminé avec succès. Cela ne prouve pas une approbation manuelle de chaque appel. Un refus exige une trace explicite ; un code non nul ou un argument invalide est une erreur technique. Les échecs historiques ne sont pas des refus. Les erreurs de scripts d'orchestration antérieures à un événement natif et les appels internes non exposés ne sont pas reconstitués : ces totaux portent uniquement sur la source indiquée.

| Contrôle final de la reprise ciblée | Réussites | Échecs |
|---|---|---|
| Tests projets | 26 (100,0 %) | 0 (0,0 %) |
| Tests aide et parcours projets | 56 (100,0 %) | 0 (0,0 %) |
| Tests copie conditionnelle | 10 (100,0 %) | 0 (0,0 %) |
| Total tests relancés avant archivage | 92 (100,0 %) | 0 (0,0 %) |

Syntaxe Bash et ShellCheck du module projects.sh, compilation des trois fichiers de tests, validations standard et strictes du change et de projects-sync : réussis. L11 passe aussi en standard et strict. Le diagnostic de refus d'archivage a disparu après L12. Tous les contrôles conditionnels finaux ont réussi avant l'archivage. Les 11 échecs OpenSpec agrégés ci-dessus concernent des états historiques avant correction ; l'appel read_thread invalide a été corrigé. Aucun de ces événements ne remplace un contrôle final réussi.

## 2. Types de messages et d’outils

| Type natif | Effectif et part |
|---|---|
| Messages développeur | 11 (2,4 %) |
| Éléments de raisonnement (métadonnées seulement) | 175 (38,7 %) |
| Messages agent | 37 (8,2 %) |
| Exécutions de commandes | 215 (47,6 %) |
| Appels de modification de fichiers | 11 (2,4 %) |
| Appels MCP | 3 (0,7 %) |
| Total | 452 (100,0 %) |

| Phase des messages agent | Effectif et part |
|---|---|
| commentary | 27 (73,0 %) |
| final_answer | 10 (27,0 %) |
| Total | 37 (100,0 %) |

| Type d’opération | Total et part | Succès / taux de ligne | Refus / taux de ligne | Erreur / taux de ligne |
|---|---|---|---|---|
| commandExecution | 215 (93,9 %) | 204 (94,9 %) | 0 (0,0 %) | 11 (5,1 %) |
| fileChange | 11 (4,8 %) | 11 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| mcpToolCall | 3 (1,3 %) | 2 (66,7 %) | 0 (0,0 %) | 1 (33,3 %) |
| Total | 229 (100,0 %) | 217 (94,8 %) | 0 (0,0 %) | 12 (5,2 %) |

Les phases final_answer/commentary sont observables ; les raisons de terminaison API et les types de parties brutes exhaustifs sont N/A. Les éléments de raisonnement sont comptés sans reproduction de leur contenu. Les trois appels MCP dans la photographie sont une lecture d'historique échouée, sa reprise réussie et le relevé de quota réussi ; les lectures statistiques ultérieures sont hors borne.

## 3. Fichiers modifiés

Unité de ce tableau : tentative d'écriture par chemin, issue des événements fileChange. Les 11 appels natifs concernent 27 tentatives sur 17 chemins. Les chemins sont ceux au moment des écritures. Les opérations système internes de l'archivage CLI ne sont pas détaillées en fileChange ; elles sont rapportées séparément après le tableau.

| Chemin absolu complet | Tentatives et part | Approuvées/exécutées et taux | Refusées et taux | Erreurs et taux |
|---|---|---|---|---|
| /home/devops/datas/diu/TECHNICAL.md | 3 (11,1 %) | 3 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| /home/devops/datas/diu/openspec/changes/add-projects-sync-broker/specs/projects-sync/spec.md | 1 (3,7 %) | 1 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| /home/devops/datas/diu/openspec/changes/add-projects-sync-broker/tasks.md | 2 (7,4 %) | 2 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| /home/devops/datas/diu/openspec/changes/configure-gitlab-container-registry/specs/implement-projects-gitlab-release/spec.md | 1 (3,7 %) | 1 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| /home/devops/datas/diu/openspec/changes/configure-gitlab-container-registry/tasks.md | 1 (3,7 %) | 1 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| /home/devops/datas/diu/openspec/changes/modify-projects-forgejo-push-force-with-lease/specs/forgejo-auth/spec.md | 1 (3,7 %) | 1 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| /home/devops/datas/diu/openspec/changes/modify-projects-forgejo-push-force-with-lease/specs/implement-projects-forgejo-push/spec.md | 1 (3,7 %) | 1 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| /home/devops/datas/diu/openspec/changes/restore-forgejo-push-to-create/specs/forgejo-auth/spec.md | 1 (3,7 %) | 1 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| /home/devops/datas/diu/openspec/changes/restore-forgejo-push-to-create/specs/implement-projects-forgejo-push/spec.md | 1 (3,7 %) | 1 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| /home/devops/datas/diu/openspec/specs/add-projects-gitlab-update/spec.md | 1 (3,7 %) | 1 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| /home/devops/datas/diu/openspec/specs/forgejo-auth/spec.md | 4 (14,8 %) | 4 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| /home/devops/datas/diu/openspec/specs/git-auth/spec.md | 3 (11,1 %) | 3 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| /home/devops/datas/diu/openspec/specs/implement-projects-forgejo-push/spec.md | 2 (7,4 %) | 2 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| /home/devops/datas/diu/openspec/specs/implement-projects-gitlab-release/spec.md | 1 (3,7 %) | 1 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| /home/devops/datas/diu/openspec/specs/projects-sync/spec.md | 1 (3,7 %) | 1 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| /home/devops/datas/diu/openspec/specs/refine-projects-gitlab-push-config/spec.md | 1 (3,7 %) | 1 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| /home/devops/datas/diu/openspec/specs/software-management/spec.md | 2 (7,4 %) | 2 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| Total | 27 (100,0 %) | 27 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |

Déplacement autorisé : /home/devops/datas/diu/openspec/changes/add-projects-sync-broker vers /home/devops/datas/diu/openspec/changes/archive/2026-10-16-add-projects-sync-broker. Six fichiers sur six conservés par empreinte (100,0 %), zéro altération observée (0,0 %). Fichiers déplacés :

- /home/devops/datas/diu/openspec/changes/archive/2026-10-16-add-projects-sync-broker/.openspec.yaml
- /home/devops/datas/diu/openspec/changes/archive/2026-10-16-add-projects-sync-broker/README.md
- /home/devops/datas/diu/openspec/changes/archive/2026-10-16-add-projects-sync-broker/design.md
- /home/devops/datas/diu/openspec/changes/archive/2026-10-16-add-projects-sync-broker/proposal.md
- /home/devops/datas/diu/openspec/changes/archive/2026-10-16-add-projects-sync-broker/specs/projects-sync/spec.md
- /home/devops/datas/diu/openspec/changes/archive/2026-10-16-add-projects-sync-broker/tasks.md

L'archiveur a également mis à jour /home/devops/datas/diu/openspec/specs/projects-sync/spec.md : deux exigences modifiées, aucune ajoutée, supprimée ou renommée. Le nombre d'écritures système internes par fichier est N/A, non exposé par le journal. Le présent STATISTIQUES.md est une création distincte autorisée après la borne statistique ; il ne fait pas partie des 27 tentatives ci-dessus. Les sources et tests liés ont des empreintes inchangées pendant la reprise.

## 4. Commandes

Unité : exécution native de commande, sans compter les interrogations d'un processus comme de nouvelles exécutions. Chaque libellé ci-dessous fait moins de 100 caractères.

| Famille / libellé | Occurrences et part | Succès et taux | Refus et taux | Erreurs et taux |
|---|---|---|---|---|
| Lectures cat | 34 (15,8 %) | 34 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| Recherches rg | 20 (9,3 %) | 20 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| Lectures sed/tail | 56 (26,0 %) | 56 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| Python — lectures et contrôles | 30 (14,0 %) | 30 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| OpenSpec — aide archive | 1 (0,5 %) | 1 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| OpenSpec — validations | 55 (25,6 %) | 44 (80,0 %) | 0 (0,0 %) | 11 (20,0 %) |
| Syntaxe Bash | 2 (0,9 %) | 2 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| ShellCheck | 2 (0,9 %) | 2 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| Tests Python directs | 7 (3,3 %) | 7 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| Compilation Python | 2 (0,9 %) | 2 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| OpenSpec — archivage ciblé | 1 (0,5 %) | 1 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| Tests unittest par découverte | 1 (0,5 %) | 1 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| Inventaires find | 2 (0,9 %) | 2 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| Identité et autres lectures | 1 (0,5 %) | 1 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| Autres commandes | 1 (0,5 %) | 1 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| Total | 215 (100,0 %) | 204 (94,9 %) | 0 (0,0 %) | 11 (5,1 %) |

Commandes refusées regroupées : aucune observée, 0/215 (0,0 %). Les 11 erreurs de commandes sont des validations OpenSpec historiques non nulles, pas des refus d'autorisation.

Commande d'archivage exécutée : openspec archive add-projects-sync-broker --yes --json. Une occurrence, succès. Ni --skip-specs ni --no-validate n'ont été utilisés. Parmi les sept invocations Python directes classées dans le journal, une n'exécutait aucun test car le fichier ne possédait pas de lanceur direct ; ses 17 tests ont ensuite été réellement exécutés par découverte unittest. Un code zéro seul n'est donc pas assimilé à une preuve de tests.

## 5. Accès web

| Mesure | Nombre | Part / taux |
|---|---|---|
| Accès de navigation ou recherche web observés | 0 | N/A — dénominateur nul |
| Accès web approuvés et exécutés | 0 | N/A |
| Accès web refusés | 0 | N/A |
| Erreurs d’accès web | 0 | N/A |

Aucune URL effectivement visitée par un outil de navigation/recherche web n'est exposée dans l'historique consulté. Les URL de documentation, de spécifications et de fixtures ne sont pas des accès effectifs. Les lectures MCP de quota et d'historique sont classées parmi les autres outils, sans URL de navigation fournie. Les tests finaux utilisent des données contrôlées et des commandes simulées ; ils ne prouvent aucune publication distante.

## 6. Synthèse globale

| Durée de la session de codage | Valeur |
|---|---|
| Début | 2026-10-13 07:29:26 CEST |
| Fin — après archivage | 2026-10-16 22:35:06 CEST |
| Durée globale (pauses et attentes incluses) | 87 h 05 min 40 s |

Cette durée concerne la conversation CGP mesurée, pas la génération du modèle ni l'ensemble des travaux historiques antérieurs sur le change.

| Mesure du quota Codex sur 7 jours | Horodatage du relevé | Quota utilisé | Réinitialisation |
|---|---|---|---|
| Avant — début de session | N/A — relevé initial absent | N/A | N/A |
| Après — après archivage de la spécification | 2026-10-16 22:35:06 CEST | 10 % | 2026-10-23 20:39:31 CEST |
| Différence après − avant | — | N/A — relevé initial absent | — |

Source : get_usage_limits, limitId=codex, fenêtre de 10080 minutes, compteur utilisé. Aucun relevé initial n'a été recréé rétroactivement. Les quotas sont partagés par le compte ; la valeur finale peut inclure d'autres tâches simultanées. Elle n'est convertie ni en tokens ni en euros, et aucune consommation exclusive de cette tâche n'est déduite.

| Domaine | Opérations et part globale | Succès et taux | Refus et taux | Erreurs et taux |
|---|---|---|---|---|
| Commandes | 215 (93,9 %) | 204 (94,9 %) | 0 (0,0 %) | 11 (5,1 %) |
| Fichiers — appels natifs | 11 (4,8 %) | 11 (100,0 %) | 0 (0,0 %) | 0 (0,0 %) |
| Autres outils MCP | 3 (1,3 %) | 2 (66,7 %) | 0 (0,0 %) | 1 (33,3 %) |
| Web | 0 (0,0 %) | 0 (N/A) | 0 (N/A) | 0 (N/A) |
| Total global | 229 (100,0 %) | 217 (94,8 %) | 0 (0,0 %) | 12 (5,2 %) |

Totaux croisés : 215 commandes + 11 appels fichiers + 3 autres outils = 229 opérations ; 217 succès + 0 refus + 12 erreurs = 229. Les 11 appels fichiers couvrent séparément 27 tentatives sur 17 chemins. Les parts sont arrondies à une décimale ; la somme des parts arrondies peut différer légèrement de 100 %, mais les totaux entiers sont vérifiés.

Bilan ciblé : 92/92 tests finaux réussis (100,0 %), six fichiers archivés sans altération (100,0 %), deux exigences principales mises à jour sans extension fonctionnelle. Archivage réussi sous 2026-10-16-add-projects-sync-broker ; contrat principal validé en standard et strict après archivage. Le présent rapport est contrôlé séparément après création : six sections numérotées, UTF-8/LF et cohérence des totaux.

Git : aucune inspection ou modification du dépôt projet exécutée dans cette session CGP ; les éventuelles opérations Git des fixtures restent isolées de ce dépôt. Secrets : aucun fichier réel de secret ou d'identifiant n'a été ouvert ; seules des sources autorisées et fixtures contrôlées ont été utilisées. Aucun déploiement, build, installation, démarrage CAB/OpenCode ou synchronisation de projet réel n'a été réalisé. L'archivage ciblé ne clôt pas la cohérence globale : bootstrap Forgejo, packaging, autres changes et couverture/historique restent soumis aux décisions du développeur.

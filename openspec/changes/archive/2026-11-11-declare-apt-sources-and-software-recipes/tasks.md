## 1. Contrat et inventaire
- [x] 1.1 Inventorier les variables de dépôts, recettes et consommateurs ; valider les deltas.
## 2. Sources et initialisation
- [x] 2.1 Implémenter et tester la lecture des sources actives et la première initialisation de toutes les variables de dépôts.
- [x] 2.2 Séparer non-free et firmware, exposer les composants dans SYSTEM et préparer les prérequis logiciels.
## 3. Recettes GLOBAL
- [x] 3.1 Déplacer les métadonnées et traitements particuliers des 23 logiciels dans GLOBAL avec chargement sans effet de bord.
- [x] 3.2 Retirer les blocs logiciels obsolètes du monolithe en préservant les environnements exclus.
- [x] 3.3 Résoudre les versions des .deb directs et garder leur mise à jour dans SYSTEM.
- [x] 3.4 Ajouter et qualifier le prérequis non-free du bureau autorisé, sans déplacer sa recette.
## 4. Validation et clôture
- [x] 4.1 Vérifier les tests ciblés, intégration isolée, suite globale, syntaxe et OpenSpec.
- [x] 4.2 Réconcilier les documents, cadrages et aides ; préparer archivage et livraison.

Après archivage : rapport SGS vérifié et CICD autorisée, avec réconciliation des effets.

## Sous-lots normalisés
Code non attribué, repère technique declare-apt-sources-and-software-recipes. Contrat (1.1), sources (2.1–2.2), recettes (3.1–3.4), validation (4.1–4.2). Prérequis : contrat validé par le développeur ; contrôles décrits dans chaque lot ; état VALIDÉ au 2026-11-11 ; preuves ci-dessous. Attribution ultérieure par ACL.

## Preuves du 2026-11-11
- Contrat : validation OpenSpec stricte réussie avant implémentation, deltas réconciliés avec les anciens replis LemonLDAP/MongoDB/Wazuh.
- Sources : 11 tests de lecture et initialisation, dont chargement des 18 variables GLOBAL ; 9 contrôles de recettes/prérequis. Sources commentées, désactivées, sauvegardes et noms ignorés exclus ; branche MongoDB ambiguë refusée.
- Déclarations : 23 recettes et 69 détecteurs/hooks déplacés ; le registre se charge sans initialisation. Les suites logicielles et les contrôles ciblés ont été exécutés ; la suite générale finale est qualifiée ci-dessous.
- Exclusions : blocs DevOps/Docker/IA identiques au début de session, empreinte 7e54fa8892c68e8cd22fdf2dca57bf2b68eda7e2c24ab456b0e4ec6b2726ac97 ; seules les variables de dépôts de ces écosystèmes sont revues pour leur initialisation.
- Debian isolé : composants firmware et non-free indépendants, cycle public jsvc installation/convergence/retrait réussi après régénération des sources, Zsh valide et alias/fonctions personnels préservés. Le premier essai a révélé le besoin de rafraîchir les index avant une transaction main ; correctif qualifié lors du second essai.
- Zsh : 305 alias distincts et 15 blocs littéraux historiques disponibles depuis GLOBAL, avec gardes de préservation ; aucune valeur de clé API n'est interpolée dans le rendu.

- Bureau : helper SYSTEM qualifié dans Debian, source non-free binaire disponible, firmware conservé à zéro, second appel sans actualisation répétée. Les tests vérifient l’ordre avant installation et l’arrêt en cas d’échec.
- Contrôles complémentaires : source deb-src distinguée de la disponibilité binaire ; branches MongoDB/Wazuh non prises en charge refusées ; mode 0700 d’un répertoire de configuration conservé.

## Validation finale du 2026-11-11
- Suite complète sur le code final : 1 347 tests, dont 2 ignorés, aucun échec ; durée observée 184,610 s. Les campagnes précédentes ne sont pas additionnées.
- Syntaxe : 48 scripts Bash validés par bash -n et ShellCheck ; 13 fichiers Python compilés, sans cache dans les sources du paquet. UTF-8/LF et git diff --check réussis.
- OpenSpec : simulation d’archivage et synchronisation des 4 capacités ; 121 spécifications valides en mode strict.
- Intégration : cycle public jsvc et indépendance firmware/non-free dans Debian ; helper bureau idempotent et disponibilité du pilote non-free confirmée ; rendu Zsh syntaxiquement valide, alias/fonctions personnels et alias globaux préservés.
- Limite : tous les logiciels externes ne sont pas installés réellement ; leurs comportements sont couverts par les suites isolées. Les recettes DevOps/Docker/IA restent inchangées.
- Revue documentaire : voir review.md ; aucune modification de l’environnement DevOps généré, hormis son état préexistant à la session.

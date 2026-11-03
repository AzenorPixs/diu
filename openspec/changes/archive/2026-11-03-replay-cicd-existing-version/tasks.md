## 1. Contrat et isolation

- [x] 1.1 Valider le contrat et les cas de conflit avec les spécifications existantes.
- [x] 1.2 Préparer et nettoyer un contexte isolé sur le commit du tag, sans modifier les fichiers ou l'index du projet.
- [x] 1.3 Adapter les constructeurs pour utiliser ce contexte, y compris Docker, et conserver les artefacts utiles sans écraser les résultats existants.

## 2. Rejeu des opérations

- [x] 2.1 Vérifier les branches et tags distants, effectuer les publications sûres et ne jamais ramener une branche en arrière.
- [x] 2.2 Rejouer les six étapes et distinguer les états déjà satisfaits, ignorés ou en échec.
- [x] 2.3 Préserver les assets Debian ; ignorer la publication Docker lorsque l'immutabilité distante ne peut pas être confirmée.

## 3. Validation et livraison

- [x] 3.1 Tester sur fixtures les fichiers indexés, non indexés et non suivis, les tags divergents et les erreurs réseau.
- [x] 3.2 Mettre à jour les aides, la documentation et les spécifications concernées.
- [x] 3.3 Exécuter les contrôles globaux applicables, vérifier la cohérence et préparer l'archivage.

## Preuves

- Suite globale DevOps : 1 119 tests exécutés, dont 2 ignorés, sans échec ; les dernières modifications ont été revérifiées par les tests ciblés.
- Rejeu : dix tests ciblés, dont construction Debian réelle sur fixture, chemins avec espaces, répétition, nettoyage sur interruption, absence d'identifiants du contexte Docker et préservation des fichiers locaux.
- Branche distante avancée conservée, tag absent publié sans retour arrière et tag divergent refusé sur dépôts simulés. Publications Forgejo et GitHub vérifiées avec transport fictif.
- ShellCheck, syntaxe Bash, compilation Python, validation stricte du change et validation globale OpenSpec standard réussis. Aucun build ni publication de production.
- Publication Docker ignorée en rejeu lorsque l'immutabilité ne peut être confirmée, conformément au choix retenu ; la publication Debian reste indépendante.

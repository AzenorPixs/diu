# Qualification du contrôle d’architecture — 11 novembre 2026

- 58 tests réussis : `python3 -m unittest discover -s tests -p test_projects_*debian*.py`.
- Forgejo : all conservé, amd64 correctement nommé publié, amd64 nommé all refusé.
- GitHub : paquet amd64 correctement nommé publié ; les anciens refus de nom ou
  d’architecture discordante restent inchangés.
- bash -n et shellcheck -x des deux modules réussis ; change OpenSpec strict valide.
- Aucun tag CAB déplacé, aucun paquet renommé ; la reprise vise le même commit3.0.0.

Les traces sont sous output/scm/cab-maintainer-scripts/native-architecture-tests.txt.
La livraison DIU est coordonnée avec le change CODING_RULES déjà autorisé de
l’autre session ; sa revue/qualification et son rapport restent distincts.

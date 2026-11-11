# Qualification minimale — 11 novembre 2026

- `python3 tests/test_projects_build_deb.py` : 17 tests réussis. Contrôle
  du paquet Debian réel : postinst présent en 0755, source inchangée, aucun
  effet du script pendant le build ; entrées inconnues, traversées, liens,
  chemins absolus et fichiers sensibles refusés.
- `python3 -m unittest discover -s tests -p 'test_projects_*debian.py'` :
  20 tests réussis ; parcours CI/CD et publication Debian existants conservés.
- `bash -n modules/projects/debian-build.sh` et
  `shellcheck -x modules/projects/debian-build.sh` : réussis.
- Validation stricte du change OpenSpec : réussie.

Preuves détaillées locales : `output/scm/cab-maintainer-scripts/`. Ces essais
ne prouvent pas l’installation des services CAB ; cette qualification appartient
au change CAB 3.0.0. Livraison DIU visée : 1.3.9, par le cycle DIU autorisé.

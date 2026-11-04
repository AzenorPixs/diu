# Tâches

- [x] Déclarer `DIU_VERSION` en `DYNAMIC/ENABLE`, scope `diu`, générée depuis
  le paquet Debian installé.
- [x] Remplacer l’affichage `VERSION_ALIAS` dans le résumé par `DIU_VERSION`.
- [x] Retirer sûrement l’ancien `VERSION_ALIAS` et tester génération/erreurs.
- [x] Valider et archiver le change OpenSpec.
- [x] Exécuter les tests et contrôles disponibles; la suite globale comporte
  26 échecs dans les tests de détection des venv projet, sans fichier de ce
  change dans leurs traces.

## 1. Contrat OpenSpec

- [x] 1.1 Retirer le contrat d'installation OpenCode dans l'environnement DevOps et préciser l'absence de sa rubrique dans le document généré.
- [x] 1.2 Décrire l'état désiré, la détection système, les releases V2 stables, l'intégrité et le cycle d'installation du CLI via GitHub.
- [x] 1.3 Mettre à jour le contrat des parcours de mise à jour système et valider le change en mode strict.

## 2. Moteur GitHub

- [x] 2.1 Déclarer `SOFTWARE_GITHUB_OPENCODE` et détecter uniquement `/usr/local/bin/opencode`.
- [x] 2.2 Sélectionner une release stable V2 avec l'archive CLI x64 et le manifeste `SHA256SUMS` ; refuser les tags V1, préliminaires ou mal formés.
- [x] 2.3 Installer, mettre à jour et retirer uniquement les fichiers possédés par DIU, avec vérification du digest et idempotence.
- [x] 2.4 Raccorder l'inventaire des logiciels et les mises à jour système aux logiciels GitHub désirés.

## 3. Nettoyage de l'environnement DevOps

- [x] 3.1 Retirer le chemin, la préparation de droits, la rubrique et les mentions OpenCode du rendu `DEVOPS.md`, tout en préservant les configurations OpenCode de projet.
- [x] 3.2 Mettre à jour le `DEVOPS.md` du DIU par sa commande normale de génération et relire son contenu utile.
- [x] 3.3 Actualiser README et TECHNICAL sans conserver l'ancien parcours d'installation DevOps.

## 4. Qualification et livraison

- [x] 4.1 Ajouter les tests ciblés de détection, sélection de release, intégrité, installation, retrait, convergence, informations logicielles et rendu DevOps.
- [x] 4.2 Exécuter les contrôles syntaxiques, ciblés, globaux et OpenSpec stricts applicables ; corriger les échecs et revérifier la portée.
- [x] 4.3 Examiner l'inventaire SCM complet et valider son inclusion intégrale avant la livraison.

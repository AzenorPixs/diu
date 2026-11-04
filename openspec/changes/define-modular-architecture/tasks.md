# Tasks: Définir l'architecture cible modulaire du DIU

- [ ] **Tâche 1 : Valider l'architecture cible**

Présenter l'architecture cible au développeur pour validation.

- Vérifier que les rôles de l'arborescence sont conformes à la décision du développeur
- Vérifier que le rôle de `lib/` et `modules/` est clairement défini
- Vérifier que les contraintes sont documentées

**Livrable :** Architecture cible validée

- [ ] **Tâche 2 : Créer la spécification OpenSpec**

Compléter la spécification delta du changement, puis la synchroniser vers
`openspec/specs/modular-architecture/spec.md` lors de l'archivage, en formalisant :

- L'architecture cible complète
- Le rôle de `lib/` et `modules/`
- Le caractère progressif de la migration
- La préservation du comportement existant
- Le maintien de `root-install-debian.sh` comme point d'entrée
- Le maintien de `variables.sh` à la racine
- Le principe de changements limités et validés

**Livrable :** Spécification delta créée et validée

- [x] **Tâche 3 : Documenter les principes de migration**

Documenter dans la spécification les principes suivants :

- La migration s'effectue par changements limités et cohérents
- Chaque étape fait l'objet d'un changement OpenSpec distinct
- Une étape peut concerner une partie seulement d'un futur module
- Chaque changement est validé par le développeur avant implémentation
- Le comportement fonctionnel est préservé
- Les commits restent atomiques et respectent les règles de `AGENTS.md`

**Livrable :** Principes de migration documentés

- [x] **Tâche 4 : Vérifier la cohérence de la spécification**

Relire la spécification pour vérifier :

- L'absence d'exigence incompatible avec le cadrage technique
- L'absence de contenu détaillé prématuré (fonctions, préfixes, phases)
- La conformité des rôles d'architecture avec la décision du développeur
- La cohérence entre les quatre artefacts du changement

**Livrable :** Spécification cohérente et conforme

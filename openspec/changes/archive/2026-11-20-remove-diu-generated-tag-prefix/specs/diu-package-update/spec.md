## MODIFIED Requirements

### Requirement: Sélection des versions de mise à jour DIU

La commande SHALL parcourir toutes les pages, exclure les brouillons et préversions, sélectionner un asset `diu_<version>_all.deb` lié au tag `<version>` ou au tag historique `v<version>`, en privilégiant les versions stables x.y.z ou x.y.z.w puis la plus élevée selon dpkg.

#### Scenario: Application de la règle

- **WHEN** la commande sélectionne un candidat de mise à jour
- **THEN** les pages, états de release, noms, tags et versions sont traités selon ces règles

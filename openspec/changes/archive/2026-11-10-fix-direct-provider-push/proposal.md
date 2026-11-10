# Correction des pushes directs — code non attribué

Les pushes directs Forgejo, GitLab et GitHub doivent préparer le commit et le tag demandé avant publication. Une version explicite sélectionne `vVERSION` ; sans version, un horodatage sélectionne `vAAAA.MM.JJ.HH.MM`. Cette sélection temporaire ne modifie pas PROJECT_VERSION. Le rejeu de version attribuée suit la CI/CD et les collisions des tags horodatés sont refusées et la réconciliation distante réutilise celle du CI/CD avec protection par référence attendue. Le parcours CI/CD existant reste inchangé.

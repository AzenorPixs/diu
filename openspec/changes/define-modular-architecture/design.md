# Design

Le changement formalise les rôles de `lib/` et `modules/` sans figer une liste
de fichiers ou de sous-répertoires. Cette approche préserve la compatibilité
avec l'architecture déjà documentée dans `TECHNICAL.md`, notamment les modules
et bibliothèques ajoutés par des évolutions validées.

Chaque migration concrète demeure un changement OpenSpec distinct. La présente
spécification fixe les invariants de répartition des responsabilités, de
progressivité et de préservation du comportement ; elle ne prescrit aucune
création ou suppression physique.

# Conception

La sélection locale template_files dans sync_project est étendue seulement si
DEVELOPMENT_MAP.md n'existe pas dans le projet destination. Les tests Bash -e
et -L distinguent l'absence d'une entrée d'un lien symbolique pendant.
Une entrée existante reste hors du staging, des substitutions et du chown.

Si la copie est nécessaire, la source modèle doit être un fichier régulier
selon le contrôle -f déjà utilisé pour les autres documents. Elle est vérifiée
avant mktemp et avant les copies dans le projet. Une source absente ou de type
incorrect rend ce seul projet en échec. La commande groupée poursuit son
parcours avec un code final non nul, selon son contrat actuel.

Le staging, les substitutions Template/template et le chown des seules copies
réalisées restent communs. Un second contrôle avant copie préserve aussi une
destination apparue pendant la préparation. Cette fonction n'introduit pas de
verrou entre synchronisations concurrentes ; elle conserve le modèle séquentiel
existant. Les erreurs de copie/propriété restent explicites et sans rollback
global, comme pour les autres ressources synchronisées.

Un seul lot de réalisation est nécessaire : sélection conditionnelle, tests
des branches et documentation du même comportement. Les tests utilisent des
modèles synthétiques dans la racine DIU, sans accès aux projets réels.

## Cohérence documentaire

- AGENTS.md : règles générales conservées, aucune nouvelle autorisation runtime.
- PROJECT.md : rôle du module projects inchangé.
- TECHNICAL.md : compléter la sélection décrite dans la gestion des projets.
- BUILD.md : aucune modification du packaging ni de la liste blanche.
- DEVOPS.md : outils déclarés réutilisés, aucune régénération nécessaire.
- README.md : documenter l'initialisation sans écrasement.
- CHANGELOG.md : ajouter une entrée Unreleased sans version inventée.
- OpenSpec : modifier la sélection autorisée et ajouter les scénarios ciblés.

## État initial des validations

ShellCheck modules/projects/projects.sh : succès avant modification.
OpenSpec --all --strict : 48 éléments valides, 21 en échec avant modification
(avertissements existants et deltas Forgejo incomplets hors périmètre).
projects-sync et projects-sync-all sont valides initialement.

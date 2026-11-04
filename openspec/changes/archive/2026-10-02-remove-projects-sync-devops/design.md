## Décision validée

Le développeur a validé le 2 octobre 2026 le retrait de DEVOPS.md de la
synchronisation, ainsi que la création, la validation et l'archivage de ce
change ciblé malgré la présence d'autres changes actifs.

## Modification minimale

Retirer DEVOPS.md des trois listes de fichiers de sync_project et de son
contrôle du modèle partagé, ainsi que de la liste de chemins passée à chown.
sync_project_all conserve son parcours et délègue toujours à sync_project.
Le document racine n'est ni lu, ni copié, ni personnalisé, ni supprimé, ni
soumis au changement de propriétaire par ces fonctions.

## Compatibilité et repli

Les utilisateurs qui souhaitent actualiser l'inventaire conservent la
commande dédiée rid projects template <ID PROJECT> devops. La création de
projets et cette génération ne changent pas. Aucune migration ni suppression
de document existant n'est nécessaire. Un repli consiste à rétablir les
quatre sélections antérieures par une modification ultérieure validée ;
aucun retour automatique n'est requis.

## Validation et cohérence

Les tests ciblés vérifient la préservation du contenu, du mode et du
propriétaire, l'absence de création, un modèle sans DEVOPS.md, les deux
commandes et leur idempotence. Un enregistrement des appels chown garantit
que DEVOPS.md n'en fait pas partie sans modifier de propriétaires réels.
Les autres copies, la personnalisation Markdown et les ressources CAB
restent couvertes par les tests existants. Les données sont temporaires ;
aucun projet réel ni configuration sensible n'est utilisé.

Les contrôles prévus sont bash -n, ShellCheck, les tests projects et ceux de
la génération dédiée, puis la validation stricte du change et de la
spécification synchronisée. La revue s'effectue sans inspection Git.

AGENTS.md, PROJECT.md, TECHNICAL.md, BUILD.md, DEVOPS.md et README.md ne
décrivent pas la sélection exacte de sync_project et restent cohérents sans
modification. projects-sync-all délègue déjà au comportement unitaire.

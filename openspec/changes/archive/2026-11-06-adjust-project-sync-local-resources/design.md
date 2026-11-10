# Conception

La synchronisation continue de traiter AGENTS.md et .gitignore, puis crée `.cab-tests` si nécessaire et attribue le propriétaire du projet uniquement au nouveau dossier. Un dossier existant et son contenu sont préservés. La carte de développement n'est ni consultée ni copiée. Les erreurs sont signalées sans annuler les écritures antérieures. Le mode groupé conserve son parcours et son traitement des erreurs.

Les modifications et tests ont été réalisés avant la création de ce change, à la suite de la validation des comportements et de la mise à jour du canon. Le change documente ces travaux sans prétendre avoir précédé leur implémentation.

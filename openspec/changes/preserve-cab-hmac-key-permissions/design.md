# Conception

La recherche générale conserve ses exclusions existantes et exclut aussi les clés HMAC du seul répertoire de journal CAB DevOps. Une seconde recherche de fichiers réguliers dans ce chemin applique 0770. Les liens symboliques ne sont pas suivis et les autres fichiers conservent les modes existants. Les tests utilisent un répertoire éphémère et ne lancent pas l'installateur système.

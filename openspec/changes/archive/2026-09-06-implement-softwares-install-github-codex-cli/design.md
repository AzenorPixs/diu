# Conception : recette GitHub de Codex CLI

La recette sera ajoutée au registre explicite du moteur GitHub. Elle ne
construira jamais un nom de fonction à partir de l’entrée utilisateur.

La cible supportée est Linux x86_64 et l’artefact attendu est
`codex-package-x86_64-unknown-linux-musl.tar.gz` dans la release GitHub
`openai/codex`. La recette interrogera l’API GitHub pour résoudre `latest` ou
une version demandée, téléchargera l’archive et `codex-package_SHA256SUMS`,
puis vérifiera le digest SHA-256 avant extraction.

L’installation conservera les binaires et ressources autonomes sous
`$SOFTWARES_APT_CODEX_CLI_HOME/packages/standalone`, avec un lien `current` et
une commande visible `codex` sous `$SOFTWARES_APT_CODEX_CLI_HOME/bin` ou dans
le répertoire d’installation DIU retenu par la recette. L’exécution devra
définir `CODEX_HOME` avec la valeur de `SOFTWARES_APT_CODEX_CLI_HOME`.

La variable `SOFTWARES_APT_CODEX_CLI` sera initialisée à `1` lorsque le binaire
Codex CLI est présent et exécutable, et à `0` sinon. La désinstallation retirera
les binaires, liens et releases installées par DIU, mais conservera le profil
Codex et ses données utilisateur. La mise à jour comparera la version locale
retournée par `codex --version` avec la dernière release GitHub et n’installera
une nouvelle archive qu’en cas de version supérieure.

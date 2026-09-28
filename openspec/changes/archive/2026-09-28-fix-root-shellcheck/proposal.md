## Why
Le script principal produit 631 diagnostics ShellCheck qui empêchent sa validation globale et la clôture de la migration SYSTEM_TIME_ZONE.

## What Changes
- Protéger les expansions scalaires et moderniser les substitutions de commandes.
- Préserver explicitement les listes, les scripts générés et les variables de configuration externes.
- Corriger la transmission des arguments ocsh et docker rootless inspect.
- Clarifier les redirections, les diagnostics justifiés et les appels indirects sans désactivation globale.

## Capabilities
### New Capabilities
- `root-shellcheck`: contrat de validation statique et comportement des corrections ciblées.
### Modified Capabilities

## Impact
root-install-debian.sh et tests/test_root_shellcheck.py. Tests isolés sans installation, accès réseau ni Docker réel. Les configurations locales, les interfaces non concernées et les autres changes sont préservés.

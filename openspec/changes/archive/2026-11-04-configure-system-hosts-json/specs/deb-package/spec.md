## MODIFIED Requirements

### Requirement: Contenu de production du paquet

Le paquet Debian produit SHALL contenir `root-install-debian.sh`, `lib/`, `modules/` et le seul fichier de configuration `config/hosts.json`, vide. Le fichier SHALL être déclaré conffile Debian. Un modèle non vide ou invalide SHALL faire échouer la construction. Les autres configurations locales, secrets, caches, journaux, sources de développement et fichiers temporaires SHALL NOT être inclus.

#### Scenario: Éléments inclus
- **WHEN** le paquet est construit depuis un modèle vide
- **THEN** il contient le script, les bibliothèques, les modules et `config/hosts.json` vide déclaré conffile.

#### Scenario: Modèle non vide
- **WHEN** le modèle de développement n'est pas un tableau JSON vide
- **THEN** la construction échoue sans publier de paquet.

#### Scenario: Éléments exclus
- **WHEN** le paquet est construit
- **THEN** `deb/`, `dist/`, `.git/`, `.opencode/`, `openspec/`, `variables.sh` et les autres fichiers de `config/` sont exclus.

#### Scenario: variables.sh non embarqué
- **WHEN** le paquet est construit
- **THEN** `variables.sh` n’est pas inclus.

#### Scenario: Préservation de variables.sh existant
- **WHEN** le paquet est installé ou mis à jour sur une machine cible
- **THEN** un éventuel `/root/diu/variables.sh` déjà présent n'est pas remplacé.

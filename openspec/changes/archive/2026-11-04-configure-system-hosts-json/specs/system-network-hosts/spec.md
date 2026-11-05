## ADDED Requirements

### Requirement: Couples d'hôtes configurables

Le DIU SHALL lire `config/hosts.json` à la racine réelle du script exécuté. En son absence il SHALL créer un tableau JSON vide. Le fichier SHALL contenir un tableau d'objets `ip` et `fqdn`. Chaque couple valide SHALL être ajouté au contenu standard de hosts dans l'ordre du tableau. Les adresses IPv4 et IPv6 sont prises en charge.

#### Scenario: Fichier absent
- **WHEN** le fichier de l'environnement exécuté est absent
- **THEN** le DIU crée `hosts.json` contenant `[]`.

#### Scenario: Plusieurs couples
- **WHEN** le tableau contient plusieurs couples valides
- **THEN** chaque couple est écrit sur une ligne distincte après le contenu standard.

#### Scenario: Configuration invalide ou illisible
- **WHEN** le JSON est invalide ou qu'un couple n'est pas une adresse IP et un FQDN valides
- **THEN** le DIU signale une erreur sans remplacer `/etc/hosts`.

#### Scenario: Environnement
- **WHEN** le script exécuté se trouve sous `/root/diu` ou dans l'arbre de développement
- **THEN** le fichier utilisé se trouve dans le sous-répertoire `config` de ce script.

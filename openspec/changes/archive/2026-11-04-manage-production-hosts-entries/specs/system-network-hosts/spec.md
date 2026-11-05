## MODIFIED Requirements

### Requirement: Couples d'hôtes configurables

Le DIU SHALL lire uniquement `/root/diu/config/hosts.json` pour générer hosts, quel que soit le point d'entrée. En son absence il SHALL créer un tableau JSON vide. Le fichier SHALL contenir un tableau d'objets `ip` et `fqdn`. Chaque couple valide SHALL être ajouté au contenu standard de hosts dans l'ordre du tableau. Les adresses IPv4 et IPv6 sont prises en charge.

#### Scenario: Fichier absent
- **WHEN** le fichier de production est absent
- **THEN** le DIU crée `hosts.json` contenant `[]`.

#### Scenario: Plusieurs couples
- **WHEN** le tableau contient plusieurs couples valides
- **THEN** chaque couple est écrit sur une ligne distincte après le contenu standard.

#### Scenario: Configuration invalide ou illisible
- **WHEN** le JSON est invalide ou qu'un couple n'est pas une adresse IP et un FQDN valides
- **THEN** le DIU signale une erreur sans remplacer `/etc/hosts`.

#### Scenario: Environnement
- **WHEN** le script est exécuté depuis l'arbre de développement
- **THEN** un fichier `config/hosts.json` absent dans cet arbre est créé vide, mais seul le fichier de production est utilisé.

## ADDED Requirements

### Requirement: Administration des couples de production

Les commandes `projects system network add <IP> <FQDN>`, `del <IP> <FQDN>`, `del all` et `list` SHALL agir uniquement sur `/root/diu/config/hosts.json` pour tous les points d'entrée. Elles SHALL créer un tableau vide si le fichier est absent et SHALL refuser une configuration invalide sans l'écraser. Elles SHALL NOT modifier `/etc/hosts`.

#### Scenario: Ajouter et trier
- **WHEN** un couple valide est ajouté
- **THEN** les couples sont triés par valeur numérique IP, IPv4 avant IPv6, puis FQDN alphabétique ; un couple exact existant n'est pas dupliqué.

#### Scenario: Supprimer un couple
- **WHEN** un couple exact est supprimé
- **THEN** les autres couples sont conservés ; si le couple est absent la commande le signale.

#### Scenario: Vider ou lister
- **WHEN** `del all` ou `list` est invoqué
- **THEN** la première commande vide le tableau et la seconde affiche les couples ou indique que la liste est vide.

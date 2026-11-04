# system-network-hosts Specification

## Purpose
Définir la reconstruction du fichier hosts et son intégration aux mises à jour du système.

## Requirements

### Requirement: Génération du fichier hosts système

Le DIU SHALL fournir `system_network_hosts` dans `modules/system/network.sh`. Il SHALL reconstruire `/etc/hosts` avec localhost, les noms de la machine associés à la première interface admissible et les entrées IPv6 historiques. Une interface est admissible si son état est `UP`, son adresse est différente de `NONE` et suit la forme IPv4 historique. Les entrées préexistantes et Docker SHALL NOT être conservées automatiquement.

#### Scenario: Première interface admissible
- **WHEN** les deux interfaces sont admissibles
- **THEN** la première adresse est associée à `HOSTNAME_FQDN` et `HOSTNAME` dans le fichier reconstruit.

#### Scenario: Seconde interface admissible
- **WHEN** la première interface n'est pas admissible et la seconde l'est
- **THEN** la seconde adresse est associée aux noms de la machine.

#### Scenario: Aucune interface admissible
- **WHEN** aucune des deux interfaces n'est admissible
- **THEN** la ligne des noms de la machine est omise et les entrées de boucle locale et IPv6 sont présentes.

### Requirement: Commandes et intégration

Le DIU SHALL exposer les commandes `diu` et `rid` `system network hosts update` et `system network update`. Les mises à jour système et globale SHALL déclencher la génération par cette chaîne. L'installation SHALL utiliser la nouvelle fonction et l'ancienne fonction SHALL être retirée. Les aides SHALL décrire les commandes et la reconstruction du fichier.

#### Scenario: Mise à jour ciblée
- **WHEN** une commande `system network hosts update` est invoquée
- **THEN** elle reconstruit le fichier hosts.

#### Scenario: Mises à jour englobantes
- **WHEN** une commande `system network update`, `system update` ou `update` est invoquée
- **THEN** elle appelle la génération du fichier hosts par la chaîne prévue.

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

### Requirement: Administration des couples de production

Les commandes `system network hosts` (`add`, `del`, `del all`, `list`) SHALL gérer exclusivement `/root/diu/config/hosts.json` pour tous les points d'entrée. Elles SHALL créer un tableau vide si nécessaire et refuser un JSON invalide sans l'écraser. Elles SHALL NOT modifier `/etc/hosts`. Les anciennes syntaxes sous `projects` SHALL être refusées avant accès au JSON. Les aides SHALL présenter les nouvelles syntaxes.

#### Scenario: Ajouter et trier
- **WHEN** un couple valide est ajouté
- **THEN** les couples sont triés par valeur numérique IP, IPv4 avant IPv6, puis FQDN alphabétique ; un couple exact existant n'est pas dupliqué.

#### Scenario: Supprimer un couple
- **WHEN** un couple exact est supprimé
- **THEN** les autres couples sont conservés ; si le couple est absent la commande le signale.

#### Scenario: Vider ou lister
- **WHEN** `hosts del all` ou `hosts list` est invoqué
- **THEN** la première commande vide le tableau et la seconde affiche les couples ou indique que la liste est vide.

#### Scenario: Ancienne commande
- **WHEN** une commande d'administration sous `projects system network hosts` est invoquée
- **THEN** elle est refusée avant toute lecture ou modification du JSON.

#### Scenario: Aide contextuelle
- **WHEN** l'aide des niveaux system network hosts ou de ses actions est demandée
- **THEN** elle présente les syntaxes de gestion système et la mise à jour de hosts.

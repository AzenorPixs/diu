## MODIFIED Requirements

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

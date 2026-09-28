## MODIFIED Requirements

### Requirement: Aide des informations de modules

L'aide racine et contextuelle SHALL présenter rid infos, les commandes rid
<module> infos pour desktop, diu, environnements, ia, projects, softwares et
system, ainsi que rid system infos debian, rid system infos drivers et rid system infos network. Elle
SHALL rester disponible avant tout chargement de configuration de production.

#### Scenario: Aide terminale
- **WHEN** une nouvelle commande infos ou system infos est suivie de help ou ?
- **THEN** la syntaxe concernée et une description sont affichées sans opération métier

#### Scenario: Aide intermédiaire
- **WHEN** rid system help ou rid system infos help est appelée
- **THEN** les commandes d'information accessibles sont affichées


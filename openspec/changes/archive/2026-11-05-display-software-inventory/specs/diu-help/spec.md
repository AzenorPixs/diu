## MODIFIED Requirements

### Requirement: Aide des informations de modules

L'aide racine et contextuelle SHALL présenter diu infos, diu infos softwares, les commandes diu
<module> infos pour desktop, diu, environnements, ia, projects, softwares et
system, ainsi que diu system infos debian, diu system infos drivers et diu system infos network. Elle
SHALL rester disponible avant tout chargement de configuration de production.

#### Scenario: Aide terminale
- **WHEN** une nouvelle commande infos ou system infos est suivie de help ou ?
- **THEN** la syntaxe concernée et une description sont affichées sans opération métier

#### Scenario: Aide intermédiaire
- **WHEN** diu system help ou diu system infos help est appelée
- **THEN** les commandes d'information accessibles sont affichées


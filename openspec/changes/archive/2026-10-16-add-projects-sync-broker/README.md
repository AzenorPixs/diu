# add-projects-sync-broker

Limiter la synchronisation des projets à `AGENTS.md`, `.gitignore` et
`PROMPTS/`, en conservant la copie conditionnelle de `ancien protocole local`
uniquement pour un projet destination dont le mode vaut `Yes`, selon
`implement-projects-update`. Pour `No`, une valeur absente ou vide, une
destination existante reste intacte et le document source n'est pas requis.
Les ressources OpenCode et CAB des projets et le broker global ne sont plus
synchronisés et restent intacts lorsqu'ils existent.

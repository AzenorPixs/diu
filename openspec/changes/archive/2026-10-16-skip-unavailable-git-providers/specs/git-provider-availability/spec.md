## ADDED Requirements

### Requirement: classification contextuelle des indisponibilités

Le contexte de push tolérant MUST identifier DNS, connexion TCP impossible,
délai réseau dépassé et HTTP 502/503/504. Il MUST NOT déduire une panne du seul
code Git 128. Authentification refusée, TLS invalide, configuration incorrecte
et rejet Git MUST rester bloquants. Hors contexte, les contrats existants
MUST rester inchangés.

#### Scenario: panne réseau reconnue

- **WHEN** curl retourne 5, 6, 7 ou 28, ou une opération HTTP retourne 502, 503 ou 504 dans un push
- **THEN** le contexte signale une indisponibilité sans exposer le contenu de la requête

#### Scenario: Git indisponible

- **WHEN** Git échoue avec un diagnostic natif en locale C identifiant une panne DNS, TCP, un timeout ou HTTP 502/503/504
- **THEN** le contexte signale une indisponibilité

#### Scenario: autre code 128 ou texte distant ambigu

- **WHEN** Git retourne 128 sans diagnostic natif de panne reconnu ou un serveur imprime un texte ressemblant à une panne
- **THEN** l'échec reste bloquant

#### Scenario: authentification ou TLS refusé

- **WHEN** une opération échoue sur 401/403, un certificat ou une configuration invalide
- **THEN** elle conserve un résultat non nul et un diagnostic explicite

### Requirement: publication non confirmée et contexte isolé

Une indisponibilité reconnue MUST être affichée comme publication non
confirmée, sans diagnostic d'erreur ni faux succès. La commande publique de
push MUST retourner zéro et transmettre un statut interne réinitialisé à
chaque appel. Le contexte temporaire MUST être privé, sans secret et nettoyé
après succès ou échec. Les invites existantes MUST rester visibles.

#### Scenario: interruption pendant le tag

- **WHEN** la branche est publiée puis le push du tag perd sa connexion
- **THEN** la publication est indiquée non confirmée et nécessitant une reprise
- **AND THEN** aucun rollback ou succès global de publication n'est annoncé

#### Scenario: appel suivant et nettoyage

- **WHEN** un push termine puis un autre commence
- **THEN** le contexte précédent est supprimé et aucun statut indisponible périmé n'est réutilisé

#### Scenario: appel hors contexte

- **WHEN** une commande de clonage ou une release directe rencontre une panne
- **THEN** son contrat d'erreur antérieur est conservé

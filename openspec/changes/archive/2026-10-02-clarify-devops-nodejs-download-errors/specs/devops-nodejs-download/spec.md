## Purpose

Définir le téléchargement borné de l'index officiel des versions Node.js
DevOps, le diagnostic explicite de ses échecs et la préservation de la
sélection de la dernière version dans la série configurée.

## ADDED Requirements

### Requirement: Téléchargement borné de l'index Node.js

Dans le bloc Node.js DevOps actif, DIU SHALL télécharger
`https://nodejs.org/dist/index.tab` avec curl avant de sélectionner une version.
L'appel SHALL conserver la vérification TLS, SHALL limiter la connexion à
10 secondes et SHALL limiter le transfert total à 60 secondes. Il SHALL NOT
modifier le proxy, la résolution DNS ou la configuration TLS pour contourner
un échec.

#### Scenario: Paramètres de téléchargement
- **WHEN** DIU recherche la dernière version Node.js de la série configurée
- **THEN** curl utilise l'URL officielle, les délais de 10 et 60 secondes et
  la vérification TLS active

### Requirement: Diagnostic contextualisé de l'échec de téléchargement

Si curl échoue, DIU SHALL conserver le diagnostic curl sur stderr, SHALL
afficher sur stderr un seul diagnostic DIU identifiant Node.js, l'URL et le
code curl, puis SHALL quitter avec ce même code. DIU SHALL NOT attribuer cet
échec à `tail -n 1`, SHALL NOT produire de rapport générique ERR supplémentaire
pour cet échec et SHALL NOT afficher le contenu téléchargé. La sélection de
version et les mutations du bloc Node.js SHALL NOT être exécutées après cet
échec. Les étapes déjà réalisées avant ce bloc ne sont pas annulées.

#### Scenario: Certificat ne correspondant pas à l'hôte
- **WHEN** curl retourne le code 60 pour l'index Node.js
- **THEN** le diagnostic DIU indique Node.js, l'URL et le code 60
- **AND** le processus quitte avec le code 60 sans rapport ERR supplémentaire
- **AND** aucune mutation du bloc Node.js n'est exécutée

#### Scenario: Erreur DNS, HTTP ou délai
- **WHEN** curl retourne respectivement le code 6, 22 ou 28
- **THEN** le diagnostic et le code de sortie conservent le code retourné
- **AND** aucune mutation du bloc Node.js n'est exécutée

#### Scenario: Téléchargement partiel en échec
- **WHEN** curl produit un contenu partiel puis retourne un code non nul
- **THEN** DIU quitte avec ce code sans sélectionner de version ni afficher
  le contenu partiel

### Requirement: Préservation de la sélection de version

Après un téléchargement réussi, DIU SHALL conserver le filtrage exact de la
série `NODEJS_SERIES`, le retrait du préfixe `v` et le tri par version pour
retenir la version la plus récente. L'absence de version dans cette série
SHALL conserver le diagnostic existant et le code de sortie 1 avant toute
mutation du bloc Node.js. L'installation et les liens existants SHALL rester
inchangés par cette évolution.

#### Scenario: Plusieurs séries présentes
- **WHEN** l'index contient les versions 24.2.0, 24.10.0 et 25.1.0 et la série
  configurée vaut 24
- **THEN** DIU sélectionne 24.10.0 et poursuit le bloc existant

#### Scenario: Série absente ou index vide
- **WHEN** curl réussit mais aucune version de la série configurée n'est présente
- **THEN** DIU conserve le diagnostic de version introuvable et quitte avec
  le code 1 avant toute mutation du bloc Node.js

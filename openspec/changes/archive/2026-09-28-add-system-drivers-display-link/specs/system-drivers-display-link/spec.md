## Purpose

Initialiser et conserver l'état des paquets DisplayLink dans la configuration
statique du module system.

## ADDED Requirements

### Requirement: Déclaration statique DisplayLink

Le DIU SHALL déclarer SYSTEM_DRIVERS_DISPLAY_LINK dans
modules/diu/variables/system/system_drivers_display_link.sh avec config STATIC,
state ENABLE, scope system et une fonction variable_generator. Les seules
valeurs acceptées SHALL être 0, 1 et UNSET. Le chargeur existant SHALL rester inchangé.

#### Scenario: Initialisation absente
- **WHEN** la variable est absente
- **THEN** sa valeur est générée, persistée dans /root/diu/config/system.env et exportée

#### Scenario: Valeur conservée
- **WHEN** la variable vaut déjà 0, 1 ou UNSET
- **THEN** elle est conservée sans détection ni nouvelle écriture

#### Scenario: Valeur invalide
- **WHEN** une valeur existante est différente de 0, 1 et UNSET, y compris vide
- **THEN** le chargement échoue explicitement sans détection ni écriture

#### Scenario: Persistance impossible
- **WHEN** la création du répertoire ou l'écriture de configuration échoue
- **THEN** un diagnostic stderr et un code non nul sont retournés
- **AND** aucune valeur nouvellement détectée n'est exportée comme initialisée

### Requirement: Détection des paquets

variable_generator SHALL utiliser dpkg-query pour déterminer l'état de
chaque paquet displaylink-driver et evdi-dkms. La valeur 1 SHALL exiger deux
paquets en état installed. La valeur 0 SHALL représenter un paquet absent ou
partiellement installé sans erreur de découverte. UNSET SHALL représenter
un outil absent, une erreur ou une réponse inexploitable, et SHALL primer
sur un résultat partiel 0. UNSET SHALL être accompagné d'un diagnostic.

#### Scenario: Installation complète
- **WHEN** les deux paquets sont installés et configurés
- **THEN** le résultat est 1

#### Scenario: Absence ou installation partielle
- **WHEN** un paquet est absent, dépaqueté, partiellement configuré ou dans un autre état incomplet reconnu
- **AND** les deux interrogations sont interprétables
- **THEN** le résultat est 0

#### Scenario: Découverte impossible
- **WHEN** dpkg-query manque ou une interrogation échoue de manière inattendue ou retourne un état inconnu
- **THEN** le résultat est UNSET, même si l'autre paquet est absent

### Requirement: Consommateur historique préservé

Le bloc d'installation existant SHALL utiliser SYSTEM_DRIVERS_DISPLAY_LINK
à la place de DISPLAY_LINK et SHALL conserver ses autres conditions et commandes.
La découverte SHALL ne pas installer de paquet. La valeur statique SHALL ne
pas être recalculée automatiquement après une installation externe.

#### Scenario: État initial non installé
- **WHEN** la détection initiale vaut 0 ou UNSET
- **THEN** le bloc historique DisplayLink n'est pas exécuté

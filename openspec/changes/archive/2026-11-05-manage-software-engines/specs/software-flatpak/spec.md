## MODIFIED Requirements

### Requirement: Préparation explicite du moteur Flatpak

Le moteur d'applications Flatpak SHALL exiger un client Flatpak utilisable et
le remote système `flathub`. Il SHALL NOT installer ou retirer le paquet Debian
`flatpak`, écrire `SYSTEM_FLATPAK_ENGINE`, ni créer, modifier ou supprimer un remote.
Une préparation absente SHALL être signalée explicitement sans action
implicite.

#### Scenario: Client Flatpak absent

- **WHEN** une commande d'application Flatpak est invoquée sans client Flatpak utilisable
- **THEN** DIU échoue sans appeler APT et indique la préparation système requise

#### Scenario: Flathub absent

- **WHEN** une installation d'application Flatpak est invoquée sans remote `flathub`
- **THEN** DIU échoue sans créer de remote


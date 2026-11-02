# Placer DESKTOP dans le scope desktop

## Pourquoi

Le contrôle de profil de bureau a été déclaré sous le scope logiciels. Le
développeur demande son nom `DESKTOP` et son déplacement dans le scope `desktop`.

## Changements

- Déclarer `DESKTOP` en `STATIC`, `ENABLE`, scope `desktop`, défaut `0`.
- Migrer `SOFTWARES_APT_DESKTOP` de `softwares.env` vers `desktop.env`, en
  préservant la valeur et en respectant la priorité d'un `DESKTOP` déjà déclaré.
- Conserver les anciennes valeurs littérales `DESKTOP=0|1` et les deux
  consommateurs du point d'entrée.
- Afficher `DESKTOP` dans les informations du module desktop.

## Context

Le point d'entrée charge les déclarations du scope system avant
`modules/system/apt.sh`. Ce module possède déjà le routage `rid system` et les
transactions APT, tandis que le monolithe contient encore une mise à jour
globale et une installation implicite de Flatpak.

## Goals / Non-Goals

**Goals:**

- Utiliser une déclaration unitaire qui détecte puis persiste l'état du paquet.
- Encapsuler les mutations Flatpak et leur persistance dans le module system.
- Rendre les commandes explicites testables sans modifier le système réel.

**Non-Goals:**

- Gérer les applications Flatpak, leurs données, ou `flatpak update`.
- Modifier les moteurs du module `softwares` ou la configuration APT tierce.

## Decisions

- La valeur sera une variable `STATIC` à initialisation détectée : contrairement
  à une variable dynamique, l'état demandé doit survivre aux exécutions. Une
  valeur `UNSET` est conservée pour empêcher une détection ambiguë répétée.
- Le moteur utilisera `dpkg-query` pour distinguer installé, absent et erreur,
  puis `apt-get install` ou `apt-get remove` pour des mutations explicites.
  `apt purge` est exclu afin de préserver les données demandées.
- La persistance suivra le remplacement ciblé déjà utilisé par le moteur de
  dépôts : l'état n'est écrit qu'après succès des commandes ciblées. L'appel de
  convergence ne réécrit pas la valeur déjà configurée.
- `system_update` conservera son rôle APT global ; la convergence est exposée
  séparément et ne sera appelée que par le traitement de configuration et les
  commandes Flatpak. Cette séparation évite que `rid update` devienne une mise
  à jour Flatpak implicite.

## Risks / Trade-offs

- [APT absent ou en échec] → propager l'erreur sans modifier la variable
  persistée ciblée.
- [Flathub inaccessible] → arrêter après l'installation du paquet ; une relance
  reconfigure le remote et reste idempotente.
- [Ancien monolithe encore exécuté] → supprimer seulement les deux blocs
  Flatpak incompatibles, sans toucher aux applications non concernées.

## Migration Plan

À la première exécution, l'état du paquet est enregistré dans `system.env`.
Les installations existantes ne sont pas modifiées avant l'application de
l'état ou une commande ciblée. Le retour arrière consiste à régler
`SYSTEM_FLATPAK=0` puis appliquer le module, ce qui retire seulement le paquet
Debian.

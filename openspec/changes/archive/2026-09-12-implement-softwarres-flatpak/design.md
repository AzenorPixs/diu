## Context

Le moteur système Flatpak installe le paquet Debian et configure Flathub mais
interdit volontairement `flatpak update`. Les moteurs APT et GitHub du module
`softwares` possèdent déjà leur routage et participent aux mises à jour
globales. Voir `proposal.md` pour la motivation et les deltas de spécification
pour le contrat fonctionnel.

## Goals / Non-Goals

**Goals:**

- Isoler les opérations sur les applications Flatpak dans un module `softwares`.
- Exposer le chemin de commande `softwares flatpak update` demandé.
- Préserver l'exécution unique de chaque moteur pendant une mise à jour globale.

**Non-Goals:**

- Installer ou retirer le paquet Debian `flatpak`.
- Créer, modifier ou retirer un remote Flatpak.
- Introduire des recettes DIU par application, une interface graphique ou une
  mise à jour Flatpak par le module `system`.

## Decisions

- Les applications sont installées depuis le remote `flathub`, mais le moteur
  vérifie qu'il existe au lieu de l'ajouter. Cela respecte la responsabilité
  de `system_flatpak_ensure_installed` et évite une mutation implicite.
- La portée est `--system`, cohérente avec l'exécution root du point d'entrée,
  le remote Flathub système créé par le module `system` et les applications
  administrées par DIU. Toutes les opérations Flatpak reçoivent cette portée.
- L'identifiant est limité à un identifiant d'application stable, formé de
  segments alphanumériques séparés par des points, et ne peut commencer par un
  tiret. Les arguments sont transmis directement, précédés de `--` lorsque la
  syntaxe Flatpak l'accepte ; aucune évaluation shell n'est construite.
- L'état installé est déterminé avant install/remove. Une opération répétée
  produit donc un diagnostic sans relancer la mutation.
- `update_all` appelle directement le participant Flatpak distinctement des
  moteurs APT et GitHub. `manage_softwares_action update` suit le même ordre,
  ce qui évite une délégation récursive ou un double appel.

## Risks / Trade-offs

- [Flatpak ou Flathub absent] → diagnostic explicite, sans installation ou
  ajout de remote ; l'utilisateur peut exécuter `rid system install flatpak`.
- [Différence entre installations utilisateur et système] → le moteur ne gère
  que la portée système documentée et ne touche pas les installations
  utilisateur existantes.
- [Échec d'une mise à jour Flatpak] → le participant marque le bilan global en
  échec, tandis que les autres participants restent exécutés.

## Migration Plan

Le module est chargé avec les autres moteurs `modules/softwares/*.sh` et ne
modifie aucun état persistant. Un retour arrière consiste à retirer ce module
et ses routes ; les applications déjà installées et le moteur système restent
intacts.

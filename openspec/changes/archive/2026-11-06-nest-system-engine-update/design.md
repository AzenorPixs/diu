## Conception
Une fonction commune exécute les moteurs APT, GitHub et Flatpak dans cet ordre et agrège leurs échecs. Le parcours système appelle cette fonction puis le réseau, même en cas d'échec. Les commandes ciblées appellent chacune leur phase existante. Les actions engine install/remove sont conservées. Les anciennes syntaxes ciblées sont refusées avant toute opération.

## Conception

Le routeur système affiche le fichier avec cat lorsque hosts ne reçoit aucun argument. Une fonction d'enveloppe capture les diagnostics de génération et produit une seule ligne de résultat pour la commande update ciblée. Le dispatch préserve son code d'échec sans déclencher le diagnostic générique multiligne ; les autres appels conservent leurs comportements. Les tests remplacent les chemins système par des fixtures.

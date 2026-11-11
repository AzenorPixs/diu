# Scripts de maintenance Debian déclarés

## Why
Le mandatCAB3.0.0 exige un paquet dont la mise à jour préserve les sessions.
Le constructeurDIU ne peut pas encore embarquer les scripts de contrôleDebian.

## What Changes
Ajouter maintainer_scripts, objet optionnel limité à preinst/postinst/prerm/postrm,
sources régulières et bornées au projet, copiées0755 dans le contrôleDebian.
Le build ne les exécute jamais. Recettes existantes et interdiction générale
des copies versDEBIAN conservées.

## Impact
Moteur générique, tests ciblés et documentation ; nouvelle livraisonDIU
explicitement incluse dans le mandat utilisateurCAB. DEVOPS préexistant inclus.
Code de lot non attribué.

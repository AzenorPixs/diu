# Conception

## Collecte et rendu

Une fonction interne choisit le premier périphérique caractère tpmrmN,
puis tpmN, dans l'ordre lexical C de chaque famille (tpmrm0 prioritaire).
Le suffixe N relie ce chemin à /sys/class/tpm/tpmN/tpm_version_major.
Un chemin absent ne prouve pas l'absence physique d'un TPM, notamment dans
un conteneur : le document décrit seulement le contexte d'exécution DIU.
La version majeure 1 ou 2 issue de sysfs devient 1.2 ou 2.0 ; une valeur
inconnue reste non vérifiable. La famille observée par tpm2_getcap peut
compléter une version sysfs indisponible.

Les deux seules requêtes au TPM 2 sont properties-fixed et pcrs, avec
`-T device:<chemin sélectionné>` explicite. Chaque commande est bornée à
5 secondes et sa terminaison forcée après une seconde supplémentaire.
Il n'existe ni transport réseau implicite, ni repli vers un autre TPM après
échec, ni installation. Les sorties stderr ne sont pas publiées.

Fabricant reprend la valeur ASCII reconnue de TPM2_PT_MANUFACTURER ;
Identifiant fournisseur reprend son code hexadécimal raw, sans inventer de
correspondance commerciale. Révision reprend TPM2_PT_REVISION, distincte
du firmware. Les propriétés absentes ou ambiguës restent non vérifiables.
Les banques PCR et leurs indices alloués sont relevés, sans lire les valeurs
des PCR, modifier leur allocation ou sélectionner un PCR particulier.
Les champs publiés sont validés ; aucune sortie brute défaillante n'est
reproduite. Un TPM 1.2 conserve chemin et version, les autres propriétés
étant explicitement non vérifiables par la sonde TPM 2.

## Compatibilité et limites

La rubrique de niveau 1 Matériel et la sous-rubrique TPM sont toujours
présentes. Les six champs conservent leur ordre même sans périphérique ou
outil. Les rubriques existantes gardent leur ordre relatif et la version
documentaire reste 0.6. Les parcours individuel, groupé et de création
partagent le même rendu. Aucun manifeste, droit ou mécanisme de publication
du document ne change. Pas de migration ni de régénération du DEVOPS.md du
dépôt pendant cette session.

## Validation et repli

Tests déterministes avec périphériques factices, sysfs temporaire et faux
tpm2_getcap : priorité des chemins, données complètes, absence, accès refusé,
outil absent, données partielles/mal formées, TPM 1.2, délais et PCR.
Les tests de génération et de publication existants restent applicables.
Syntaxe Bash/Python, ShellCheck, delta OpenSpec strict et canon ordinaire
sont contrôlés. Les huit avertissements canoniques de longueur observés
avant écriture restent hors périmètre et sont comparés après synchronisation.
En cas de sonde impossible, les diagnostics par champ constituent le repli ;
les échecs de publication conservent toujours le document précédent.

## Références techniques

- [Documentation officielle tpm2_getcap](https://tpm2-tools.readthedocs.io/en/latest/man/tpm2_getcap.1/) : properties-fixed et pcrs.
- [Source officielle tpm2_getcap](https://github.com/tpm2-software/tpm2-tools/blob/master/tools/tpm2_getcap.c) : formats de famille, fabricant et révision.

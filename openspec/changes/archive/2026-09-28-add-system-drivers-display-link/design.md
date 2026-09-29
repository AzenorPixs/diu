## Decisions

La déclaration est modules/diu/variables/system/system_drivers_display_link.sh.
Elle suit le modèle statique de SYSTEM_FLATPAK, mais utilise la fonction
variable_generator demandée. Le chargeur reste inchangé.

Le générateur interroge les paquets séparément par dpkg-query -W avec
${db:Status-Status}. Deux statuts installed donnent 1. Un paquet absent ou un
état partiel reconnu donne 0, sauf si une interrogation est indéterminée :
UNSET prime alors sur 0. Un retour 1 sans résultat signifie paquet absent ;
autre échec, résultat incohérent ou outil absent donnent UNSET et diagnostic.

L'initialisation absente calcule la valeur puis la persiste avant de l'exporter.
Un échec de création du répertoire ou d'écriture est propagé explicitement.
Une valeur existante 0/1/UNSET est conservée ; une autre valeur, même vide,
est rejetée sans détection ni persistance. UNSET est un résultat valide et
persistant, non une demande de relance automatique de la découverte.

La migration ne transfère pas l'ancienne préférence DISPLAY_LINK. Le nettoyage
reste exact, idempotent et exécuté avant le sourcing de variables.sh. Il ne
restaure pas automatiquement les affectations retirées.

## Impacts et limites

L'état décrit les paquets Debian, pas la compilation du module pour chaque
noyau, le service, le dock ou les écrans. Les installations manuelles hors
paquets ne sont pas couvertes. Une valeur statique ne se rafraîchit pas après
une installation externe. La valeur initiale 0 ne demande pas d'installation.
Le bloc historique réservé à PHYSICAL reste conditionné à 1 ; ses commandes
APT et son contrôle existant evdi-dkms ne sont pas modifiés par ce change.

## Validation

Tester les deux paquets installés, absents, partiels, erreurs de chaque paquet,
statuts inconnus, outil absent, valeurs existantes et invalides, persistance,
répétition, export et échecs d'écriture. Tester nettoyage et préservation de
l'installation historique sur données contrôlées. Bash -n, ShellCheck,
contrôle des anciens noms et validation OpenSpec stricte avant archivage.

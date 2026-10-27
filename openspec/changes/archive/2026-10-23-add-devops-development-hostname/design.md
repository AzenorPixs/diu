# Sonde du nom d'hôte

## Choix

Un helper dédié utilise la recherche de binaire système existante, appelle
hostname avec le seul argument -f et une borne de 15 secondes, puis valide
une seule ligne de 1 à 253 caractères ASCII alphanumériques, points ou tirets
commençant par un caractère alphanumérique. Une valeur courte retournée par
hostname -f reste acceptée : aucun suffixe DNS n'est inventé. La résolution
dépend du contexte d'exécution DIU et de ses mécanismes de résolution habituels.

La sortie standard rejetée et stderr ne sont pas publiées. Une commande
absente, une sonde échouée ou expirée, ou une sortie invalide produisent un
diagnostic fixe en deuxième puce, sans bloquer les autres rubriques. La valeur
est relevée une seule fois par rendu et remplace toute valeur précédente.

Le rendu reste commun aux générations individuelles, groupées et aux créations.
La version documentaire passe à 0.7. Les références courantes sont actualisées ;
les anciennes entrées de changelog conservent leur contexte historique.
Le DEVOPS.md existant n'est pas régénéré pendant la session.

## Vérification

Le binaire hostname est simulé dans les fixtures sous le dépôt. Les tests
vérifient les arguments exacts, le nombre d'appels, l'ordre des deux puces,
l'actualisation, les absences, erreurs, délais et sorties invalides.
La suite existante contrôle les parcours groupé et de création.
Les binaires réellement installés font l'objet d'empreintes de métadonnées
avant et après les tests ; aucun rendu réel susceptible de préparer leurs
droits n'est lancé.


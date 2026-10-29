# Conception

Le retour du transport reste vérifié en premier. Le code HTTP final est ensuite
extrait de la réponse et accepté uniquement dans la classe 2xx. Une réponse
malformée ou d’erreur empêche le succès public. Le corps n’est pas journalisé.
Aucune relance ni suppression de ressource distante n’est ajoutée.

Les fixtures U1 simulent les six frontières de modules dans l’ordre canonique.
Les wrappers réels DIU et IA sont testés séparément. Z1 adopte le rendu courant
avec inventaire des blocs littéraux et empreintes contrôlées, sans modifier
le générateur. Le pipeline APT est vérifié par événements et données, sans
imposer un ordre de démarrage des processus.

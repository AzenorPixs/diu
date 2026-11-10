## Contexte

Le répartiteur logiciels possède des recettes explicites APT et GitHub ; Flatpak accepte des identifiants génériques. D'autres logiciels APT sont actuellement configurés dans l'installateur linéaire. Les états désirés préexistants doivent rester inchangés lors de la migration.

## Décisions

- Séparer le catalogue, l'état désiré et la détection de l'état réel des opérations génériques d'installation, désinstallation et convergence propres à chaque moteur. La détection retourne une valeur 0/1 et signale séparément les erreurs.
- Le noyau de convergence reçoit des fonctions explicitement enregistrées de détection et d'action ; il valide les noms et la valeur retournée, signale l'état observé, exécute seulement l'action exigée puis vérifie à nouveau l'état. Il ne déduit jamais un nom de fonction d'une entrée utilisateur.
- Conserver les traitements nécessaires aux logiciels existants ; un nom de variable ne suffit pas à déduire de façon sûre les paquets et leurs dépendances.
- Réserver la persistance de l'état désiré aux commandes explicites install/remove et à l'initialisation d'une entrée absente. Une convergence ne doit pas inverser le désir si son action échoue.
- Pour les applications Flatpak génériques, encoder de façon réversible et sans collision leur identifiant dans le suffixe de variable, avec un registre persistant des identifiants gérés. Ne pas traiter silencieusement des applications existantes comme des entrées explicitement désactivées ; valider le contenu du registre et les variables avant tout effet.
- Le suffixe Flatpak est `X` suivi de l'encodage hexadécimal ASCII majuscule de l'identifiant complet. Ce choix distingue notamment les points, traits d'union et soulignements ; une fonction détectrice propre est enregistrée pour chaque identifiant préalablement validé.
- En l'absence d'historique Flatpak, initialiser au premier passage les applications système présentes depuis leur état réel, sans effectuer d'installation ou de retrait pendant cette initialisation. Un commentaire réservé dans la configuration marque sa fin ; les applications ajoutées ensuite sont enregistrées par les commandes ciblées. Cette hypothèse reste révisable selon la réponse du développeur.
- Les variables utilisent les préfixes `SOFTWARE_APT_`, `SOFTWARE_FLATPAK_` et `SOFTWARE_GITHUB_`. Migrer les valeurs préexistantes depuis `SOFTWARES_APT_` vers le moteur adéquat, notamment Codex CLI vers GitHub ; préserver toute valeur cible valide déjà présente, signaler les divergences et refuser les valeurs ambiguës sans perte silencieuse.
- Après migration sûre, désactiver les anciennes variables déclarées GLOBAL et supprimer celles de l'ancien mécanisme ; les nouvelles déclarations deviennent l'unique autorité. Préserver les données si la migration ne peut être établie.
- Exécuter les moteurs dans l'ordre APT, Flatpak, GitHub, puis intégrer cette convergence en fin de playlist `diu update`. Préserver les erreurs en poursuivant les unités indépendantes.
- Déplacer ou conserver les mises à jour de versions dans le moteur système, sans créer de double exécution par la convergence.

## Risques et points à résoudre

- Les rôles syslog client et serveur utilisent tous deux `rsyslog` : selon la décision du développeur, conserver le paquet tant qu'au moins un rôle le demande, et détecter et converger séparément l'état de chaque rôle.
- L'agent CrowdSec installe aussi le bouncer : le paquet partagé reste nécessaire tant que l'un des rôles le demande. Lorsque les deux rôles sont activés, la configuration d'API locale de l'agent prévaut selon la décision du développeur.
- Si seul l'agent CrowdSec est demandé, conserver le paquet du bouncer requis et désactiver son rôle autonome.
- Préserver les fichiers syslog non identifiables et signaler tout conflit empêchant de désactiver un rôle sans ambiguïté.
- Supprimer les anciennes syntaxes `diu install/remove/update apt|github` selon la décision du développeur ; les commandes `diu softwares` constituent l'interface de gestion des logiciels.
- Des configurations existantes à 0 peuvent entraîner une désinstallation lors de la première convergence ; les tests doivent couvrir cet effet explicitement demandé, sans opérer sur le système réel.
- Les opérations de certains logiciels ne se limitent pas à un paquet ; leur état réel, leurs effets et leurs traitements doivent être examinés avant leur rattachement au catalogue.
- Une erreur de détection, de lecture ou de persistance ne doit pas déclencher une suppression fondée sur une valeur supposée.
- Les spécifications individuelles APT existantes prescrivent souvent un défaut statique à 0 ; elles doivent être réconciliées avec l'initialisation sur l'état réel avant toute implémentation. Les variables déjà persistées ne doivent pas être réinitialisées.
- Les anciennes variables apparaissent aussi dans les consommateurs du script principal, les déclarations modulaires, les règles de dépôts système et les tests ; le changement de préfixe doit couvrir ces usages et leurs spécifications individuelles sans dégrader les migrations précédentes.

## Décisions soumises au développeur

- Flatpak historique sans registre : hypothèse de reprise des applications système présentes, avec état initial détecté ; réponse demandée.
- Zsh : hypothèse de préservation des configurations existantes sans recopier les clés API ; réponse demandée sur la reprise des traitements historiques.
- SSH : conservation des clés existantes et ajout des clés DIU en conservant l'activation historique de la connexion root.
- Wazuh agent : hypothèse de refus lorsque les paramètres sécurisés d'enregistrement sont absents ; réponse demandée.
- Dépôt CrowdSec : le prototype conserve `SOFTWARE_APT_CROWDSEC` comme réglage de dépôt distinct de l'état des logiciels ; question posée sur son éventuel transfert dans `SYSTEM_APT_CROWDSEC`.

Les hypothèses non confirmées sont documentées comme telles ; les modules sont raccordés au point d'entrée et les comportements concernés font l'objet des contrôles décrits ci-dessous.

## Validation

Contrôles OpenSpec stricts, tests isolés couvrant chaque combinaison désir/réalité, erreurs, initialisation, persistance, ordre des moteurs et playlist, non-régression des logiciels existants, contrôles syntaxiques et suite globale retenue par le projet. Aucune installation ou suppression réelle n'est requise pour ces contrôles.

## Conception

La CI/CD établit pour chaque release un contexte privé de classification, initialisé par appel et supprimé en sortie. Les transports signalent uniquement les indisponibilités reconnues dans ce contexte ; les autres échecs restent bloquants. Les résultats partiels ne sont ni annulés ni déclarés complets. Les messages ne reproduisent aucun secret. Les releases directes restent hors contexte. Le rejeu conserve ses restrictions de publication Docker.

Les tests isolent les transports et simulent les pannes, les refus d’authentification et les erreurs locales sans contacter les services réels. La classification ne repose pas sur le seul code de sortie générique d’un outil.

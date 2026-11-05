# Statistiques globales

**NCA — Nombre de changes analysés : 115**

## 1. Périmètre et durée

| Indicateur | Nombre de changes | Valeur (jours décimaux ; NCMA en changes achevés/jour) |
|---|---|---|
| DGCT — Temps total de développement du projet via l’IA | 0 | N/A |
| DGCTSPA — Temps total de développement du projet via l’IA hors pauses et attentes | 0 | N/A |
| NJT — Écart entre le premier change archivé à l’archivage du dernier | 115 | N/A |
| NCMA — Changes achevés par jour (NCA / NJT) | 115 | N/A |

| Indicateur | Nombre de changes | Valeur en heures décimales |
|---|---|---|
| DGCTM — Durée globale moyenne pour 0 changes | 0 | N/A |
| DGCTSPAM — Durée moyenne par change hors pauses et attentes pour 0 changes | 0 | N/A |

N/A désigne une mesure absente, des bornes incomplètes ou un périmètre incompatible. Les fenêtres partielles ne remplacent pas une durée globale. Les cumuls retiennent uniquement les valeurs exploitables.

## 2. Agents intervenants et LLM

À date, les agents de codage et les agents orchestrateurs ont toujours utilisé les dernières versions disponibles au moment de chaque change. Cette indication concerne les logiciels agents ; elle ne détermine pas les versions des LLM.

### LLM des agents de codage

| Nombre de changes réalisés ou partiellement réalisés | Modèle de LLM | Niveau de raisonnement | Pourcentage de NCA |
|---|---|---|---|
| 114 | N/A | N/A | 99,13 % |

## 3. Performances des LLM de codage OpenCode

Aucune ligne de performance complète n’est disponible. Aucun codeur OpenCode n’est attesté dans les rapports analysés.

| Indicateur | Valeur |
|---|---|
| TMTM total moyen (s) | N/A |
| Débit minimal total moyen (tokens/s) | N/A |
| Débit moyen total moyen (tokens/s) | N/A |
| Débit maximal total moyen (tokens/s) | N/A |

## 4. Consommation de tokens, coûts et compactions des codeurs

| Mesure | Total | Moyenne par change |
|---|---|---|
| Tokens d’entrée | N/A | N/A |
| Tokens de sortie | N/A | N/A |
| Tokens de raisonnement | N/A | N/A |
| Tokens de cache lus | N/A | N/A |
| Tokens de cache écrits | N/A | N/A |
| Total des tokens | N/A | N/A |
| Compactions des codeurs | N/A | N/A |

| Mesure | Total | Moyenne par change |
|---|---|---|
| Coût de production déclaré — devise non disponible | N/A | N/A |

## 6. Messages et outils des codeurs

| Mesure | Total | Moyenne par change |
|---|---|---|
| Messages des codeurs | N/A | N/A |
| Appels d’outils des codeurs | N/A | N/A |

| Rôle des messages | Nombre | Pourcentage |
|---|---|---|
| utilisateur | N/A | N/A |
| assistant | N/A | N/A |

Les messages utilisateur peuvent provenir d’un orchestrateur et ne représentent pas nécessairement des messages humains.

| Outil | Nombre d’appels | Pourcentage |
|---|---|---|
| N/A | N/A | N/A |

| Résultat technique | Nombre | Pourcentage |
|---|---|---|
| Terminé | N/A | N/A |
| Erreur | N/A | N/A |
| En cours | N/A | N/A |

## 7. Autorisations des opérations des codeurs

| Mesure | Total | Moyenne par change |
|---|---|---|
| Demandes d’autorisation distinctes | N/A | N/A |

| Statut final | Total | Pourcentage |
|---|---|---|
| Approuvées | N/A | N/A |
| Refusées | N/A | N/A |
| Expirées | N/A | N/A |
| Annulées | N/A | N/A |

## 8. Fichiers et volume du code actuel

| Mesure | Total | Moyenne par change |
|---|---|---|
| Écritures effectivement exécutées | N/A | N/A |
| Fichiers distincts touchés par change — cumul | 636 | 17,667 |

Le cumul des fichiers touchés compte un même fichier une fois dans chaque change concerné. Le volume ci-dessous représente le stock actuel, sans attribution historique à un agent. Une source contenant une donnée sensible est exclue du comptage ; les totaux concernés sont indisponibles.

| Périmètre | Lignes de code | Lignes de commentaires |
|---|---|---|
| Global | N/A | N/A |
| Point d’entrée et compatibilité | N/A | N/A |
| Bibliothèque commune | 4934 | 1107 |
| Module diu | 2782 | 408 |
| Module system | 3091 | 69 |
| Module desktop | 5 | 1 |
| Module environments | 10 | 2 |
| Module softwares | 452 | 8 |
| Module projects | 11199 | 793 |
| Module ia | 642 | 173 |

## 9. Commandes des codeurs

| Mesure | Total | Moyenne par change |
|---|---|---|
| Commandes exécutées | N/A | N/A |

| Résultat d’exécution | Total | Pourcentage |
|---|---|---|
| Réussies | N/A | N/A |
| En échec | N/A | N/A |

| Famille | Nombre d’exécutions | Pourcentage |
|---|---|---|
| N/A | N/A | N/A |

## 10. Accès web des codeurs

| Mesure | Total | Moyenne par change |
|---|---|---|
| Appels aux outils web | 0 | 0,000 |

| Mesure | Total | Pourcentage |
|---|---|---|
| Appels web réussis | 0 | N/A |
| Recherche | 0 | N/A |
| Consultation | 0 | N/A |

Le détail des appels documentés est N/A lorsque l’outil, la cible ou la corrélation entre une consultation et un appel ne sont pas renseignés. Les références documentaires ne sont pas comptées comme des visites.

## 11. Validation et livraison des codeurs

| Mesure | Total | Moyenne par change |
|---|---|---|
| Tests exécutés dans le bilan final du change | 76037 | 672,894 |
| Fichiers ayant passé un contrôle syntaxique | 394 | 4,283 |
| Tâches OpenSpec prouvées et terminées | 209 | 5,225 |

| Résultat des tests finaux | Nombre | Pourcentage |
|---|---|---|
| Réussis | 73622 | 99,77 % |
| Échoués | 15 | 0,02 % |

| Catégorie de tests | Effectif |
|---|---|
| N/A — ventilation globale non déterminable | N/A |

| Validation OpenSpec | Réussies | Échouées | Pourcentage de réussites | Pourcentage d’échecs |
|---|---|---|---|---|
| Standard | 26 | 6 | 50,00 % | 50,00 % |
| Strict | 173 | 75 | 55,63 % | 44,37 % |

Ces cumuls décrivent les bilans historiques documentés ; ils ne constituent pas une validation actuelle du projet. Les taux utilisent les seuls périmètres dont le résultat correspondant est connu.

## 12. Synthèse transversale des codeurs

| Domaine | Nombre d’appels | Pourcentage des appels |
|---|---|---|
| Écritures de fichiers | N/A | N/A |
| Commandes | N/A | N/A |
| Web | N/A | N/A |
| Autres outils | N/A | N/A |
| Total | N/A | N/A |

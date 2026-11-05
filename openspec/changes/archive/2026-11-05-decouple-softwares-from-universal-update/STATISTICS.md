# Statistiques du change

### Agents de codage — relevé scm-decouple-softwares-20261105

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| non communiqué | N/A | N/A | non communiqué | N/A | N/A | N/A |

### Agents orchestrateurs — relevé scm-decouple-softwares-20261105

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| N/A | N/A | N/A | N/A | N/A | N/A | N/A |

## 1. Statistiques générales et décisions

### Relevé scm-decouple-softwares-20261105

Change archivé ; mesures limitées aux preuves de ce relevé.

Portée : cumulative.

Agent coder : Codex, modèle non communiqué, raisonnement non communiqué.

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Durée globale | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Durée hors pauses et attentes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens d’entrée | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de sortie | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de raisonnement | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache lus | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tokens de cache écrits | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total natif des tokens | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Compactions achevées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes d’autorisation distinctes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes approuvées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes refusées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes expirées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Demandes annulées | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Mandat | SCM direct ; périmètre et livraison validés, DEVOPS.md préexistant inclus. | Conversation développeur du 2026-11-05 |

## 2. Types de messages et d’outils

### Relevé scm-decouple-softwares-20261105

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Messages des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages utilisateur | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Messages assistant | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels d’outils des codeurs | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels terminés | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Erreurs techniques | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels en cours | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Télémétrie | Comptes détaillés des messages et outils non disponibles ; aucune sonde de pilotage. | Session directe SCM |

## 3. Fichiers modifiés

### Relevé scm-decouple-softwares-20261105

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures effectivement exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers distincts touchés par change | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Fichiers | Code, aides, cinq tests, spécifications, documentation, cartographie et registre du change. | Git diff et archive OpenSpec |

## 4. Commandes

### Relevé scm-decouple-softwares-20261105

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Commandes exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes en échec | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests exécutés dans le bilan final | 1211 | Sortie observée dans la session SCM du 2026-11-05 : tests |
| Tests finaux réussis | N/A | 1209 réussis et 2 ignorés : le moteur impose un total égal aux succès et échecs. |
| Tests finaux échoués | 0 | Sortie observée dans la session SCM du 2026-11-05 : tests_failure |
| Fichiers ayant passé un contrôle syntaxique | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes réussies | 5 | Sortie observée dans la session SCM du 2026-11-05 : openspec_strict_success |
| Validations OpenSpec strictes échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tâches OpenSpec prouvées et terminées | 4 | Sortie observée dans la session SCM du 2026-11-05 : tasks |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Validation finale | 1 211 tests exécutés, 2 ignorés ; 132 tests ciblés ; bash -n, ShellCheck et py_compile réussis. | unittest discover ; unittest ciblé ; contrôles de syntaxe |
| Incidents corrigés | Un test ciblé initialement échoué par régression de texte, corrigé ; appel validate multi-arguments refusé puis quatre validations unitaires réussies. | Sorties de commande |

## 5. Accès web

### Relevé scm-decouple-softwares-20261105

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Appels aux outils web | 0 | Sortie observée dans la session SCM du 2026-11-05 : web |
| Appels web réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Recherches web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Consultations web | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Web | Aucun accès web. | Journal de session |

## 6. Synthèse globale

### Relevé scm-decouple-softwares-20261105

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures de fichiers | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Autres outils | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Archive | Change archivé et quatre spécifications synchronisées, chacune validée strictement ; livraison encore à vérifier. | openspec archive et validate --strict |


<!-- CAB_SGS_SESSIONS_V1
{
  "format": "cab-sgs-1",
  "sessions": [
    {
      "contribution": {
        "agents": [
          {
            "agent": "Codex",
            "model": "non communiqué",
            "reasoning": "non communiqué",
            "role": "coder"
          }
        ],
        "bounds": {
          "end": null,
          "start": null
        },
        "breakdowns": {},
        "costs": {},
        "metrics": {
          "commands": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "commands_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "compactions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_command": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_other": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_web": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "domain_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "files_touched": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_assistant": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "messages_user": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "net_duration": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_standard_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_failure": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "openspec_strict_success": {
            "evidence": [
              {
                "line": 1,
                "note": "Sortie observée dans la session SCM du 2026-11-05 : openspec_strict_success"
              }
            ],
            "reason": null,
            "state": "known",
            "value": "5"
          },
          "permissions": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_approved": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_cancelled": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_expired": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "permissions_rejected": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "syntax_files": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tasks": {
            "evidence": [
              {
                "line": 1,
                "note": "Sortie observée dans la session SCM du 2026-11-05 : tasks"
              }
            ],
            "reason": null,
            "state": "known",
            "value": "4"
          },
          "tests": {
            "evidence": [
              {
                "line": 1,
                "note": "Sortie observée dans la session SCM du 2026-11-05 : tests"
              }
            ],
            "reason": null,
            "state": "known",
            "value": "1211"
          },
          "tests_failure": {
            "evidence": [
              {
                "line": 1,
                "note": "Sortie observée dans la session SCM du 2026-11-05 : tests_failure"
              }
            ],
            "reason": null,
            "state": "known",
            "value": "0"
          },
          "tests_success": {
            "evidence": [],
            "reason": "1209 réussis et 2 ignorés : le moteur impose un total égal aux succès et échecs.",
            "state": "unavailable",
            "value": null
          },
          "tokens_cache_read": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_cache_write": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_input": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_output": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_reasoning": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tokens_total": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_completed": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_error": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "tools_running": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web": {
            "evidence": [
              {
                "line": 1,
                "note": "Sortie observée dans la session SCM du 2026-11-05 : web"
              }
            ],
            "reason": null,
            "state": "known",
            "value": "0"
          },
          "web_open": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_search": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "web_success": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          },
          "writes": {
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
          }
        },
        "performance": [],
        "proof_ids": [],
        "sessions": [],
        "web_calls": []
      },
      "details": {
        "1": [
          {
            "label": "Mandat",
            "proof": "Conversation développeur du 2026-11-05",
            "value": "SCM direct ; périmètre et livraison validés, DEVOPS.md préexistant inclus."
          }
        ],
        "2": [
          {
            "label": "Télémétrie",
            "proof": "Session directe SCM",
            "value": "Comptes détaillés des messages et outils non disponibles ; aucune sonde de pilotage."
          }
        ],
        "3": [
          {
            "label": "Fichiers",
            "proof": "Git diff et archive OpenSpec",
            "value": "Code, aides, cinq tests, spécifications, documentation, cartographie et registre du change."
          }
        ],
        "4": [
          {
            "label": "Validation finale",
            "proof": "unittest discover ; unittest ciblé ; contrôles de syntaxe",
            "value": "1 211 tests exécutés, 2 ignorés ; 132 tests ciblés ; bash -n, ShellCheck et py_compile réussis."
          },
          {
            "label": "Incidents corrigés",
            "proof": "Sorties de commande",
            "value": "Un test ciblé initialement échoué par régression de texte, corrigé ; appel validate multi-arguments refusé puis quatre validations unitaires réussies."
          }
        ],
        "5": [
          {
            "label": "Web",
            "proof": "Journal de session",
            "value": "Aucun accès web."
          }
        ],
        "6": [
          {
            "label": "Archive",
            "proof": "openspec archive et validate --strict",
            "value": "Change archivé et quatre spécifications synchronisées, chacune validée strictement ; livraison encore à vérifier."
          }
        ]
      },
      "id": "scm-decouple-softwares-20261105",
      "input_sha256": "8d30cac6db163a342477b27b0acd18c21b78496b8c64494e6e8e0296665b4192",
      "scope": "cumulative",
      "state": "archived"
    }
  ]
}
-->

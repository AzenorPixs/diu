# Statistiques du change

### Agents de codage — relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| gpt-6.1-sol | N/A | N/A | medium | N/A | N/A | N/A |

### Agents orchestrateurs — relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

| Modèle de LLM | Version | Fournisseur | Niveau de raisonnement | TTMT moyen | Tokens/seconde moyens | Temps de service (% total) |
| --- | --- | --- | --- | --- | --- | --- |
| N/A | N/A | N/A | N/A | N/A | N/A | N/A |

## 1. Statistiques générales et décisions

### Relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

Change archivé ; mesures limitées aux preuves de ce relevé.

Portée : cumulative.

Agent coder : codex, modèle gpt-6.1-sol, raisonnement medium.

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
| Mandat | SCM et prérequis bureau explicitement validés | Conversation ; proposal.md et inventory.md. |

Codage direct sans orchestrateur. La fenêtre native débute après exploration ; les totaux du change non établis restent indisponibles.

## 2. Types de messages et d’outils

### Relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

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
| Suite finale | 1 347 tests dont 2 ignorés, 0 échec ; 184,610 s | unittest discover -s tests sur le code final. |

## 3. Fichiers modifiés

### Relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures effectivement exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Fichiers distincts touchés par change | 80 | Écart Git de production avant rapport ; DEVOPS.md préexistant exclu. |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Recettes et variables | 23 recettes GLOBAL, 18 variables de sources et 22 blocs retirés | Tests de chargement et empreinte des blocs protégés dans tasks.md. |

#### Fichiers de la livraison SCM

| Chemin relatif | Attribution |
| --- | --- |
| CHANGELOG.md | Production du change |
| DEVELOPMENT_MAP.md | Production du change |
| DEVOPS.md | Préexistant conservé |
| README.md | Production du change |
| TECHNICAL.md | Production du change |
| lib/diu-help.sh | Production du change |
| modules/diu/variables/diu/diu_apt_repository_fd.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_apache2.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_chatgpt.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_crowdsec_agent.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_crowdsec_bouncer.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_fastfetch.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_jsvc.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_lemonldap.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_mongodb.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_omada.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_openjdk.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_openvswitch.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_postfix.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_postgresql.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_qemu_guest_agent.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_ssh_server.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_syncthing.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_syslog_client.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_syslog_server.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_wazuh_agent.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_wazuh_server.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_webmin.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_zoom.sh | Production du change |
| modules/diu/variables/softwares/desired_apt_zsh.sh | Production du change |
| modules/diu/variables/system/system_apt_debian_backport.sh | Production du change |
| modules/diu/variables/system/system_apt_debian_contrib.sh | Production du change |
| modules/diu/variables/system/system_apt_debian_nonfrfee.sh | Production du change |
| modules/diu/variables/system/system_apt_debian_nonfrfee_firmware.sh | Production du change |
| modules/diu/variables/system/system_apt_debian_sources.sh | Production du change |
| modules/diu/variables/system/system_apt_debian_updates.sh | Production du change |
| modules/diu/variables/system/system_apt_unofficial.sh | Production du change |
| modules/softwares/apt-configuration.sh | Production du change |
| modules/softwares/apt-convergence.sh | Production du change |
| modules/softwares/apt-management.sh | Production du change |
| modules/softwares/apt-recipes.sh | Production du change |
| modules/softwares/apt-state.sh | Production du change |
| modules/softwares/bootstrap.sh | Production du change |
| modules/softwares/crowdsec-hooks.sh | Production du change |
| modules/softwares/crowdsec-state.sh | Production du change |
| modules/softwares/global-declarations.sh | Production du change |
| modules/softwares/syslog-hooks.sh | Production du change |
| modules/softwares/syslog-state.sh | Production du change |
| modules/softwares/zsh_configuration.py | Production du change |
| modules/system/apt-source-state.sh | Production du change |
| modules/system/apt.sh | Production du change |
| modules/system/apt_sources.py | Production du change |
| modules/system/infos.sh | Production du change |
| modules/system/software-versions.sh | Production du change |
| openspec/BATCH_CODES.md | Production du change |
| openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/.openspec.yaml | Production du change |
| openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/design.md | Production du change |
| openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/inventory.md | Production du change |
| openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/proposal.md | Production du change |
| openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/review.md | Production du change |
| openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/specs/apt-software-declarations/spec.md | Production du change |
| openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/specs/apt-source-initialization/spec.md | Production du change |
| openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/specs/software-management/spec.md | Production du change |
| openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/specs/system-debian-apt/spec.md | Production du change |
| openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/tasks.md | Production du change |
| openspec/specs/apt-software-declarations/spec.md | Production du change |
| openspec/specs/apt-source-initialization/spec.md | Production du change |
| openspec/specs/software-management/spec.md | Production du change |
| openspec/specs/system-debian-apt/spec.md | Production du change |
| root-install-debian.sh | Production du change |
| tests/test_apt_recipe_sources.py | Production du change |
| tests/test_apt_source_initialization.py | Production du change |
| tests/test_crowdsec_api_key.py | Production du change |
| tests/test_diu_command_links.py | Production du change |
| tests/test_module_infos.py | Production du change |
| tests/test_root_shellcheck.py | Production du change |
| tests/test_software_apt_convergence.py | Production du change |
| tests/test_software_global_declarations.py | Production du change |
| tests/test_software_zsh_configuration.py | Production du change |
| tests/test_system_apt_unofficial.py | Production du change |
| tests/test_system_proxy.py | Production du change |

## 4. Commandes

### Relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Commandes exécutées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes en échec | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Tests exécutés dans le bilan final | 1345 | Bilan final documenté : 1 347 cas dont 2 ignorés ; 9 tâches ; 48 Bash et 13 Python ; OpenSpec strict final. |
| Tests finaux réussis | 1345 | Bilan final documenté : 1 347 cas dont 2 ignorés ; 9 tâches ; 48 Bash et 13 Python ; OpenSpec strict final. |
| Tests finaux échoués | 0 | Bilan final documenté : 1 347 cas dont 2 ignorés ; 9 tâches ; 48 Bash et 13 Python ; OpenSpec strict final. |
| Fichiers ayant passé un contrôle syntaxique | 61 | Bilan final documenté : 1 347 cas dont 2 ignorés ; 9 tâches ; 48 Bash et 13 Python ; OpenSpec strict final. |
| Validations OpenSpec standard réussies | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec standard échouées | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Validations OpenSpec strictes réussies | 1 | Bilan final documenté : 1 347 cas dont 2 ignorés ; 9 tâches ; 48 Bash et 13 Python ; OpenSpec strict final. |
| Validations OpenSpec strictes échouées | 0 | Bilan final documenté : 1 347 cas dont 2 ignorés ; 9 tâches ; 48 Bash et 13 Python ; OpenSpec strict final. |
| Tâches OpenSpec prouvées et terminées | 9 | Bilan final documenté : 1 347 cas dont 2 ignorés ; 9 tâches ; 48 Bash et 13 Python ; OpenSpec strict final. |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Validation | 48 bash -n/ShellCheck, 13 py_compile ; 121 spécifications strictes | Commandes finales, simulation et validation après archive. |
| Debian | Cycle jsvc, indépendance firmware, prérequis bureau idempotent et Zsh préservé | Conteneurs dédiés supprimés ; preuves tasks.md. |

## 5. Accès web

### Relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Appels aux outils web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Appels web réussis | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Recherches web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Consultations web | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Sources | Code local, manuel APT, métadonnées APT et références Git | Aucune mesure web exhaustive ajoutée aux compteurs natifs. |

## 6. Synthèse globale

### Relevé 01a1c6d4-6541-7fb1-82f3-997b307df2a2

| Mesure | Valeur | Preuve ou limite |
| --- | --- | --- |
| Écritures de fichiers | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Commandes | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Web | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Autres outils | N/A | Mesure absente ou périmètre exhaustif non identifiable |
| Total | N/A | Mesure absente ou périmètre exhaustif non identifiable |

| Élément documenté | Valeur | Preuve |
| --- | --- | --- |
| Suivi | SGS 2.7.1 et snapshot natif gelé | Même binding/session que le RUN SCM-apt-sources-recipes. |

Archive et spécifications vérifiées ; CICD 1.3.8 prévue après rapport. Tous les logiciels externes ne sont pas qualifiés par installation réelle.


### Télémétrie native et chronologie des modèles

| Rôle | Agent | Session | Mode |
| --- | --- | --- | --- |
| coder | codex | 01a1c6d4-6541-7fb1-82f3-997b307df2a2 | direct |

| Mesure | Valeur | Couverture |
| --- | --- | --- |
| command_wall_seconds | 1121.778 | native |
| commands | 149 | native |
| commands_failure | 13 | native |
| commands_success | 136 | native |
| files_touched | 27 | partial |
| message_span_seconds | 27.548 | native |
| messages | 20 | native |
| messages_assistant | 18 | native |
| messages_llm | 25 | native |
| messages_user | 2 | native |
| reasoning_span_seconds | 2216.972 | native |
| tokens_cache_read | 84385792 | native |
| tokens_cache_write | 0 | native |
| tokens_input | 84504351 | native |
| tokens_output | 116818 | native |
| tokens_reasoning | 63337 | native |
| tokens_total | 84621169 | native |
| tool_wall_seconds | 30.056 | native |
| tools | 181 | native |
| tools_llm | 176 | native |
| writes | 42 | partial |

| Début | Fin | Modèle | Fournisseur | Raisonnement |
| --- | --- | --- | --- | --- |
| 2026-11-11T11:59:00.350000+00:00 | 2026-11-11T13:05:01.258000+00:00 | gpt-6.1-sol | openai | medium |


<!-- CAB_SGS_SESSIONS_V1
{
  "format": "cab-sgs-1",
  "sessions": [
    {
      "contribution": {
        "agents": [
          {
            "agent": "codex",
            "model": "gpt-6.1-sol",
            "reasoning": "medium",
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
            "evidence": [
              {
                "line": 1,
                "note": "Écart Git de production avant rapport ; DEVOPS.md préexistant exclu."
              }
            ],
            "reason": null,
            "state": "known",
            "value": "80"
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
            "evidence": [
              {
                "line": 1,
                "note": "Bilan final documenté : 1 347 cas dont 2 ignorés ; 9 tâches ; 48 Bash et 13 Python ; OpenSpec strict final."
              }
            ],
            "reason": null,
            "state": "known",
            "value": "0"
          },
          "openspec_strict_success": {
            "evidence": [
              {
                "line": 1,
                "note": "Bilan final documenté : 1 347 cas dont 2 ignorés ; 9 tâches ; 48 Bash et 13 Python ; OpenSpec strict final."
              }
            ],
            "reason": null,
            "state": "known",
            "value": "1"
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
            "evidence": [
              {
                "line": 1,
                "note": "Bilan final documenté : 1 347 cas dont 2 ignorés ; 9 tâches ; 48 Bash et 13 Python ; OpenSpec strict final."
              }
            ],
            "reason": null,
            "state": "known",
            "value": "61"
          },
          "tasks": {
            "evidence": [
              {
                "line": 1,
                "note": "Bilan final documenté : 1 347 cas dont 2 ignorés ; 9 tâches ; 48 Bash et 13 Python ; OpenSpec strict final."
              }
            ],
            "reason": null,
            "state": "known",
            "value": "9"
          },
          "tests": {
            "evidence": [
              {
                "line": 1,
                "note": "Bilan final documenté : 1 347 cas dont 2 ignorés ; 9 tâches ; 48 Bash et 13 Python ; OpenSpec strict final."
              }
            ],
            "reason": null,
            "state": "known",
            "value": "1345"
          },
          "tests_failure": {
            "evidence": [
              {
                "line": 1,
                "note": "Bilan final documenté : 1 347 cas dont 2 ignorés ; 9 tâches ; 48 Bash et 13 Python ; OpenSpec strict final."
              }
            ],
            "reason": null,
            "state": "known",
            "value": "0"
          },
          "tests_success": {
            "evidence": [
              {
                "line": 1,
                "note": "Bilan final documenté : 1 347 cas dont 2 ignorés ; 9 tâches ; 48 Bash et 13 Python ; OpenSpec strict final."
              }
            ],
            "reason": null,
            "state": "known",
            "value": "1345"
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
            "evidence": [],
            "reason": "Mesure absente ou périmètre exhaustif non identifiable",
            "state": "unavailable",
            "value": null
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
            "proof": "Conversation ; proposal.md et inventory.md.",
            "value": "SCM et prérequis bureau explicitement validés"
          }
        ],
        "2": [
          {
            "label": "Suite finale",
            "proof": "unittest discover -s tests sur le code final.",
            "value": "1 347 tests dont 2 ignorés, 0 échec ; 184,610 s"
          }
        ],
        "3": [
          {
            "label": "Recettes et variables",
            "proof": "Tests de chargement et empreinte des blocs protégés dans tasks.md.",
            "value": "23 recettes GLOBAL, 18 variables de sources et 22 blocs retirés"
          }
        ],
        "4": [
          {
            "label": "Validation",
            "proof": "Commandes finales, simulation et validation après archive.",
            "value": "48 bash -n/ShellCheck, 13 py_compile ; 121 spécifications strictes"
          },
          {
            "label": "Debian",
            "proof": "Conteneurs dédiés supprimés ; preuves tasks.md.",
            "value": "Cycle jsvc, indépendance firmware, prérequis bureau idempotent et Zsh préservé"
          }
        ],
        "5": [
          {
            "label": "Sources",
            "proof": "Aucune mesure web exhaustive ajoutée aux compteurs natifs.",
            "value": "Code local, manuel APT, métadonnées APT et références Git"
          }
        ],
        "6": [
          {
            "label": "Suivi",
            "proof": "Même binding/session que le RUN SCM-apt-sources-recipes.",
            "value": "SGS 2.7.1 et snapshot natif gelé"
          }
        ]
      },
      "id": "01a1c6d4-6541-7fb1-82f3-997b307df2a2",
      "input_sha256": "2805313052f315649270db3c9b955de1a2828878aa5cacc58161e913c7b56dff",
      "native_telemetry": {
        "format": "cab-native-sgs-1",
        "sessions": [
          {
            "agent": "codex",
            "binding": "codex-19dc91ea4f25c04813c657a9ba4c754e83090294083bb9222f4a0e02ac150380",
            "cab_direct": true,
            "change": "declare-apt-sources-and-software-recipes",
            "collector": {
              "source": "codex-native",
              "status": "collecting"
            },
            "coverage": {
              "ccab_claimed": "unavailable",
              "ccab_open": "unavailable",
              "ccab_resolved_retained": "unavailable",
              "ccab_total_retained": "unavailable",
              "command_wall_seconds": "native",
              "commands": "native",
              "commands_api": "unavailable",
              "commands_failure": "native",
              "commands_success": "native",
              "compactions": "unavailable",
              "cost_usd": "unavailable",
              "duration_seconds": "unavailable",
              "files_touched": "partial",
              "generation_seconds": "unavailable",
              "message_span_seconds": "native",
              "messages": "native",
              "messages_assistant": "native",
              "messages_llm": "native",
              "messages_user": "native",
              "permissions": "unavailable",
              "preparation_seconds": "unavailable",
              "reasoning_span_seconds": "native",
              "tests": "unavailable",
              "tokens_cache_read": "native",
              "tokens_cache_write": "native",
              "tokens_input": "native",
              "tokens_output": "native",
              "tokens_reasoning": "native",
              "tokens_total": "native",
              "tool_wall_seconds": "native",
              "tools": "native",
              "tools_llm": "native",
              "ttft_seconds": "unavailable",
              "update_cutover_seconds": "unavailable",
              "update_preparation_seconds": "unavailable",
              "wait_seconds": "unavailable",
              "web": "unavailable",
              "web_open": "unavailable",
              "web_search": "unavailable",
              "writes": "partial"
            },
            "ended_at": "2026-11-11T13:05:01.258000+00:00",
            "events": 849,
            "host": "hvp1",
            "instance": "codex-01a1c6d4-6541-7fb1-82f3-997b307df2a2-uid1000",
            "metrics": {
              "command_wall_seconds": "1121.778",
              "commands": "149",
              "commands_failure": "13",
              "commands_success": "136",
              "files_touched": "27",
              "message_span_seconds": "27.548",
              "messages": "20",
              "messages_assistant": "18",
              "messages_llm": "25",
              "messages_user": "2",
              "reasoning_span_seconds": "2216.972",
              "tokens_cache_read": "84385792",
              "tokens_cache_write": "0",
              "tokens_input": "84504351",
              "tokens_output": "116818",
              "tokens_reasoning": "63337",
              "tokens_total": "84621169",
              "tool_wall_seconds": "30.056",
              "tools": "181",
              "tools_llm": "176",
              "writes": "42"
            },
            "mode": "direct",
            "models": [
              {
                "from": "2026-11-11T11:59:00.350000+00:00",
                "model": {
                  "name": "gpt-6.1-sol",
                  "provider": "openai",
                  "reasoning": "medium"
                },
                "source": "codex-native",
                "until": "2026-11-11T13:05:01.258000+00:00"
              }
            ],
            "project": "/home/devops/datas/diu",
            "role": "coder",
            "run": "SCM-apt-sources-recipes",
            "session": "01a1c6d4-6541-7fb1-82f3-997b307df2a2",
            "started_at": "2026-11-11T11:58:59.871Z"
          }
        ]
      },
      "notes": {
        "1": [
          "Codage direct sans orchestrateur. La fenêtre native débute après exploration ; les totaux du change non établis restent indisponibles."
        ],
        "6": [
          "Archive et spécifications vérifiées ; CICD 1.3.8 prévue après rapport. Tous les logiciels externes ne sont pas qualifiés par installation réelle."
        ]
      },
      "scope": "cumulative",
      "state": "archived",
      "tables": {
        "3": [
          {
            "columns": [
              "Chemin relatif",
              "Attribution"
            ],
            "rows": [
              [
                "CHANGELOG.md",
                "Production du change"
              ],
              [
                "DEVELOPMENT_MAP.md",
                "Production du change"
              ],
              [
                "DEVOPS.md",
                "Préexistant conservé"
              ],
              [
                "README.md",
                "Production du change"
              ],
              [
                "TECHNICAL.md",
                "Production du change"
              ],
              [
                "lib/diu-help.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/diu/diu_apt_repository_fd.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_apache2.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_chatgpt.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_crowdsec_agent.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_crowdsec_bouncer.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_fastfetch.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_jsvc.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_lemonldap.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_mongodb.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_omada.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_openjdk.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_openvswitch.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_postfix.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_postgresql.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_qemu_guest_agent.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_ssh_server.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_syncthing.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_syslog_client.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_syslog_server.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_wazuh_agent.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_wazuh_server.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_webmin.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_zoom.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/softwares/desired_apt_zsh.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/system/system_apt_debian_backport.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/system/system_apt_debian_contrib.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/system/system_apt_debian_nonfrfee.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/system/system_apt_debian_nonfrfee_firmware.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/system/system_apt_debian_sources.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/system/system_apt_debian_updates.sh",
                "Production du change"
              ],
              [
                "modules/diu/variables/system/system_apt_unofficial.sh",
                "Production du change"
              ],
              [
                "modules/softwares/apt-configuration.sh",
                "Production du change"
              ],
              [
                "modules/softwares/apt-convergence.sh",
                "Production du change"
              ],
              [
                "modules/softwares/apt-management.sh",
                "Production du change"
              ],
              [
                "modules/softwares/apt-recipes.sh",
                "Production du change"
              ],
              [
                "modules/softwares/apt-state.sh",
                "Production du change"
              ],
              [
                "modules/softwares/bootstrap.sh",
                "Production du change"
              ],
              [
                "modules/softwares/crowdsec-hooks.sh",
                "Production du change"
              ],
              [
                "modules/softwares/crowdsec-state.sh",
                "Production du change"
              ],
              [
                "modules/softwares/global-declarations.sh",
                "Production du change"
              ],
              [
                "modules/softwares/syslog-hooks.sh",
                "Production du change"
              ],
              [
                "modules/softwares/syslog-state.sh",
                "Production du change"
              ],
              [
                "modules/softwares/zsh_configuration.py",
                "Production du change"
              ],
              [
                "modules/system/apt-source-state.sh",
                "Production du change"
              ],
              [
                "modules/system/apt.sh",
                "Production du change"
              ],
              [
                "modules/system/apt_sources.py",
                "Production du change"
              ],
              [
                "modules/system/infos.sh",
                "Production du change"
              ],
              [
                "modules/system/software-versions.sh",
                "Production du change"
              ],
              [
                "openspec/BATCH_CODES.md",
                "Production du change"
              ],
              [
                "openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/.openspec.yaml",
                "Production du change"
              ],
              [
                "openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/design.md",
                "Production du change"
              ],
              [
                "openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/inventory.md",
                "Production du change"
              ],
              [
                "openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/proposal.md",
                "Production du change"
              ],
              [
                "openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/review.md",
                "Production du change"
              ],
              [
                "openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/specs/apt-software-declarations/spec.md",
                "Production du change"
              ],
              [
                "openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/specs/apt-source-initialization/spec.md",
                "Production du change"
              ],
              [
                "openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/specs/software-management/spec.md",
                "Production du change"
              ],
              [
                "openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/specs/system-debian-apt/spec.md",
                "Production du change"
              ],
              [
                "openspec/changes/archive/2026-11-11-declare-apt-sources-and-software-recipes/tasks.md",
                "Production du change"
              ],
              [
                "openspec/specs/apt-software-declarations/spec.md",
                "Production du change"
              ],
              [
                "openspec/specs/apt-source-initialization/spec.md",
                "Production du change"
              ],
              [
                "openspec/specs/software-management/spec.md",
                "Production du change"
              ],
              [
                "openspec/specs/system-debian-apt/spec.md",
                "Production du change"
              ],
              [
                "root-install-debian.sh",
                "Production du change"
              ],
              [
                "tests/test_apt_recipe_sources.py",
                "Production du change"
              ],
              [
                "tests/test_apt_source_initialization.py",
                "Production du change"
              ],
              [
                "tests/test_crowdsec_api_key.py",
                "Production du change"
              ],
              [
                "tests/test_diu_command_links.py",
                "Production du change"
              ],
              [
                "tests/test_module_infos.py",
                "Production du change"
              ],
              [
                "tests/test_root_shellcheck.py",
                "Production du change"
              ],
              [
                "tests/test_software_apt_convergence.py",
                "Production du change"
              ],
              [
                "tests/test_software_global_declarations.py",
                "Production du change"
              ],
              [
                "tests/test_software_zsh_configuration.py",
                "Production du change"
              ],
              [
                "tests/test_system_apt_unofficial.py",
                "Production du change"
              ],
              [
                "tests/test_system_proxy.py",
                "Production du change"
              ]
            ],
            "title": "Fichiers de la livraison SCM"
          }
        ]
      }
    }
  ]
}
-->

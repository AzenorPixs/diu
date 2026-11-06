## Décisions
Retirer `softwares_update` et le report `DIU_UPDATE_DEFER_SOFTWARES` du seul orchestrateur universel. Le module système gère lui-même Codex CLI selon ses conditions existantes. Préserver la priorité d'erreur projects puis DIU et le fonctionnement direct de softwares. Le retour à l'ancien comportement exige une modification inverse du code et des spécifications.

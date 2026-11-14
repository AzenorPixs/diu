## REMOVED Requirements

### Requirement: Détection d'une release OpenCode V2

**Reason**: OpenCode n'est plus géré comme outil du domicile DevOps.
**Migration**: Gérer le CLI système avec la recette OpenCode du moteur GitHub.

### Requirement: Mise à jour OpenCode uniquement vers une V2 plus récente

**Reason**: L'installation DevOps conditionnée par `OPENCODE=1` est retirée.
**Migration**: Utiliser `diu softwares install|update github opencode`.

### Requirement: Échec de détection sans installation

**Reason**: Le parcours d'installation DevOps conditionnel est retiré.
**Migration**: La recette GitHub valide la release V2 et le digest avant toute mutation.

### Requirement: Préservation du périmètre d'installation DevOps

**Reason**: OpenCode n'est plus un outil installé ni inventorié sous le compte DevOps.
**Migration**: L'état désiré du logiciel système est `SOFTWARE_GITHUB_OPENCODE`.

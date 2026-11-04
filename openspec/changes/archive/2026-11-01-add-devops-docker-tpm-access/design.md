# Design

## Context

Voir `proposal.md` pour le motif. Le rendu Docker est centralisé dans `projects_template_devops_section`; la génération partagée l’utilise pour les parcours individuels, groupés et de création.

## Goals / Non-Goals

**Goals:** ajouter une mention statique après la référence d’image Docker et avant la puce d’autorisation.

**Non-Goals:** ajouter une détection dynamique du TPM, transmettre un périphérique dans les commandes Docker de production, modifier les permissions ou qualifier les environnements futurs.

## Decisions

Ajouter `Accès TPM OK` dans la branche Docker du helper de rendu commun. Étendre les assertions de structure déjà présentes pour couvrir les six puces, leur ordre et l’omission de toute la rubrique lorsque Docker est désactivé. Le test matériel effectué pour cette demande passe explicitement `/dev/tpmrm0` au conteneur ; le générateur reste sans sonde matérielle.

## Risks / Trade-offs

La mention est une référence documentaire fixe et ne revalide pas le TPM lors des générations futures. Elle reflète le contexte de test configuré pour ce document ; elle ne garantit pas l’accès sur une autre machine ni après un changement de configuration. Le retour arrière consiste à retirer la puce et ses assertions.

# Déplacer les contrôles CrowdSec vers le scope logiciels

## Pourquoi

Les contrôles CrowdSec concernent des composants installés par APT, mais leurs
valeurs sont actuellement réparties entre la configuration système et les
variables historiques. Leur regroupement dans le scope logiciels supprime la
variable non définie à l'installation et rend le dépôt, l'agent et le bouncer
cohérents.

## Changements

- Déclarer `SOFTWARES_APT_CROWDSEC`,
  `SOFTWARES_APT_CROWDSEC_AGENT`, `SOFTWARES_APT_CROWDSEC_BOUNCER` et
  `SOFTWARES_CROWDSEC_BOUNCER_API_KEY` dans `softwares.env`.
- Migrer les anciennes valeurs du dépôt, de l'agent et du bouncer en
  préservant exactement `0` ou `1` et la priorité des nouvelles valeurs;
  transférer la clé API de manière opaque et sécuriser le fichier.
- Configurer le dépôt CrowdSec via son nouveau contrôle et installer les
  paquets agent et bouncer avec APT.

## Hors périmètre

- Modifier la configuration ou les identifiants secrets du bouncer.
- Modifier la politique de service, les collections ou les règles CrowdSec.

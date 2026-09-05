# Design: Module software et mises à jour

## Context

Le point d'entrée reste `root-install-debian.sh`. Le dispatch actuel appelle
`update_diu` pour `update` sans distinguer les arguments supplémentaires.
L'architecture prévoit `modules/softwares/` et des fonctions génériques dans
`lib/packages.sh`. Aucun déplacement de code sans rapport n'est requis.

## Decisions

### 1. Séparer action, moteur et logiciel

La grammaire est `rid <action> <moteur> [<SOFTWARE>]`. `install` et `remove`
exigent un logiciel ; `update` accepte son absence pour traiter tout le moteur.
Sans moteur, seul `rid update` est défini : il déclenche l'orchestration globale.
`ri update deb` est interprété comme une coquille, sans création d'alias `ri`.

### 2. Donner un sens DIU aux noms de moteurs

`deb` désigne les paquets officiels Debian. `apt` désigne les logiciels tiers,
même lorsqu'une recette sans dépôt n'utilise pas directement APT.
Ces noms ne désignent donc pas deux outils système distincts.
Le moteur `deb` doit contrôler l'origine des versions sélectionnées ; lancer
une mise à jour APT générale ne suffit pas à garantir le périmètre officiel.
Les dépendances doivent respecter ce même périmètre.

### 3. Décrire la dépendance à un dépôt

Pour chaque logiciel tiers reconnu, DIU doit connaître explicitement si un
 dépôt est requis. Cette information relève de la définition du logiciel et
ne nécessite pas de question interactive à chaque invocation.
Avec dépôt, l'installation délègue sa préparation au futur moteur DIU, puis
procède à l'installation du paquet tiers. Sans dépôt, les opérations appellent
chacune la fonction spécifique correspondante du logiciel.
La forme des définitions et les noms des fonctions seront fixés lors de
l'implémentation ; aucune nouvelle variable de configuration n'est imposée ici.

### 4. Composer les mises à jour

Chaque module expose sa participation à la mise à jour globale et prend en
charge ses sous-fonctions de mise à jour. L'orchestrateur ne doit pas appeler
deux fois une même opération par plusieurs chemins.
Le module software délègue aux moteurs disponibles, puis aux logiciels relevant
de chacun. Les logiciels absents ne sont pas installés par une mise à jour.
Le moteur `apt` futur ne sera annoncé comme disponible qu'une fois implémenté.
Un module présent sans traitement de mise à jour doit être signalé comme non
applicable ou non pris en charge, jamais présenté comme mis à jour.

### 5. Propager les résultats

Les erreurs de syntaxe sont détectées avant toute mutation. Les échecs APT,
les recettes manquantes et les dépôts indisponibles produisent un diagnostic
et un code non nul. Une mise à jour globale fournit un bilan par composant et
retourne un code non nul si une opération requise échoue.

## Séquencement retenu pour la première étape

- Ordre déterministe des participants, respectant leurs dépendances.
- Poursuite des mises à jour indépendantes après un échec ; opérations dépendantes
  marquées comme bloquées.
- Mise à jour de DIU lui-même en dernier pour éviter de remplacer le code utilisé
  par les autres opérations pendant leur exécution.
- Désinstallation sans purge ni suppression automatique des dépendances.

## Politique du moteur deb

Les index existants identifient les dépôts portant l'origine `Debian` pour le
nom de code installé, sa suite `-updates` et sa suite `-security`. Le moteur
recrée temporairement une liste de sources limitée à ces dépôts, avec le
trousseau `/usr/share/keyrings/debian-archive-keyring.gpg`, puis actualise des
index isolés. Il conserve la configuration APT persistante et les préférences
locales. Les backports et les autres versions de Debian sont exclus.

La simulation préalable contrôle les versions installées par le solveur et les
suppressions induites. Une version installée présente dans les index officiels
isolés ou dans les anciens index officiels est reconnue ; une version dont
l'origine n'est plus vérifiable est refusée. Cette présence atteste de la
disponibilité officielle de la version, pas de l'historique de téléchargement
que dpkg ne conserve pas. Un paquet sans candidat officiel est signalé comme
non applicable lors du parcours global. Une origine ambiguë bloque le paquet
et entraîne un bilan en échec, même si les autres paquets ont été traités.

Les mises à jour utilisent `--only-upgrade` pour préserver les marques
automatique/manuelle des paquets et `--no-remove` pour éviter les suppressions.
La confirmation habituelle d'APT est conservée. Aucun paquet n'est purgé.
Les dépôts doivent disposer de métadonnées locales initiales : leur absence
produit un diagnostic demandant l'actualisation des index APT.

## Participants actuels

- `softwares/deb` : mises à jour officielles.
- `ia/hermes` : fonction `update_agent_hermes` si le fichier `compose.yml` est
  présent dans le répertoire retourné par `_hermes_dir`, même si le service est arrêté.
- `diu` : `update_diu`, en dernier et dans un sous-shell pour confiner son `exec`.
- `desktop`, `environment`, `projects`, `system` : aucun traitement de mise à
  jour disponible, état annoncé explicitement.
- `softwares/apt` : moteur futur, indisponibilité annoncée.

`config_update` et `git_update` gèrent la configuration et ne sont pas des
mises à jour logicielles. Le chemin ciblé `rid update diu`, déjà annoncé dans
l'aide, reste disponible. Aucun parcours ne lance automatiquement d'opération Git.

## Points réservés à l'étape apt
- Correspondance entre identifiants logiciels tiers, paquets et recettes.
- Interface exacte du futur moteur de dépôts et politique de conservation des
  dépôts lors d'une désinstallation.

## Validation

### Mise à jour des images Docker

Le module Docker fournit une fonction générique `ensure_docker_image` prenant
une image et une politique (`never`, `check` ou `always`). La politique passée
en argument est prioritaire et aucune variable globale historique ne doit être
nécessaire. Les modules logiciels appellent cette fonction avec leur variable
d'image et leur variable de politique propres. Hermes utilise donc
`DOCKER_IMAGE_HERMES` et `DOCKER_IMAGE_HERMES_UPDATE_POLICY`.

Les tests devront simuler APT, les recettes et les participants globaux, sans
modifier les logiciels de la machine. Ils devront vérifier les arguments,
l'isolation des moteurs, les appels, les échecs et la non-duplication.
Les scripts Bash modifiés devront passer `bash -n` et `shellcheck`.

## Fichiers et validation de la première étape

- `modules/softwares/software.sh` : validation et routage des actions.
- `modules/softwares/deb.sh` : contexte APT officiel isolé et transactions.
- `modules/diu/update-all.sh` : orchestration et bilan.
- `modules/diu/update.sh` : traitement explicite des échecs de lecture dpkg,
  nécessaire lorsque la fonction est appelée dans un test de statut.
- `root-install-debian.sh` : chargement, dispatch et aide.
- `tests/test_software.py` : tests sans installation de paquets.

Référence technique : [manuel officiel apt-get Debian](https://manpages.debian.org/trixie/apt/apt-get.8.en.html).

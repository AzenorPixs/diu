VARIABLES.md


Les VARIABLES GLOBALES sont définit par leurs attributs : 

Configuration : STATIC / DYNAMIC

État : ENABLE / DISABLE

Scope :  DESKTOP / DEVOPS / DIU / DOCKER / ENVIRONNEMENT / IA / PROJECTS / SOFTWARES / SYSTEM

Valeur par défault : 

Fonction de génération : (Pour les VARIABLES GLOBALES DYNAMIC)


En fin de génération des variables STATIC et DYNAMIC les fichiers variables de chaque scope dans le dossier config seront retriés par ordre alphabétique.


Les VARIABLES GLOBALES sont générés par deux mécanismes.

1. Mécanisme de génération des VARIABLES GLOBALES STATIQUE, et leurs enregistrement dans leur SCOPE dédié si non existente.

  Les variables STATIC auront une valeur par défault attribuée, si la variable n'existe pas.

  La variable sera enregistrée dans le fichier SCOPE correspondant dans le dossier config/{scope de la variables}.sh

  ├── config
  │   ├── desktop.env
  │   ├── devops.env
  │   ├── diu.env
  │   ├── docker.env
  │   ├── environnements.env
  │   ├── ia.env
  │   ├── projects.env
  │   ├── softwares.env
  │   ├── system.env
  │   └── states

2. Mécanisme de génration des VARIABLES GLOBALES DYNAMIC toujours exécuté à chaque itération du DIU.

Dans le cas d'une variable DYNAMIC une fonction sera lié à cette VARIABLE pour sa génération.

Une valeur par défault sera attribuée si la fonction de génération échoue.

Les attributs d'une VARIABLE seront déclarés par un fichier unique en nom_de_la_variable.sh placé dans le dossier modules/diu/variables/{scope de la variables}

Tous les fichiers de chaque SCOPE de variable seront découvert par une boucle WHILE WEND, et exécuté si bien que des fichier variables peuvent être rajouté sans toucher au code du DIU.


├── modules
│   ├── diu
│   │   ├── config.sh
│   │   ├── update.sh
│   │   └── variables
│   │         ├── desktop
│   │         ├── diu
│   │         ├── devops
│   │         ├── docker
│   │         ├── environnements
│   │         ├── ia
│   │         ├── projects
│   │         ├── softwares
│   │         └── system

L'ancien fichier variables.sh sera progressivement abandonné.


Les ficiers unitaires de chaque VARIABLE GLOBALE auront ce modèle : modules/diu/variables/diu/DIU_VERSION.sh

config = STATIC
state = ENABLE
scope = DIU

Si State = ENABLE
Alors
  Si NAME_VARIABLE n'existe pas
  Alors
    Si VARIABLE STATIC
    Alors
      export NAME_VARIABLE = "valeur par défault"
      enregistrement dans le fichier config/diu.env
      fin
    Autrement
      export NAME_VARIABLE = variable_generator
      fin
  Autrement
    Varaiable déjà existente
    fin
Autrement
  fin

variable_generator () {
...
}


Le fichier config.sh portera à lui seul tous le mécanisme de génération et de vérifications des VARIABLES GLOBALES STATIC et DYNAMIC

1. Il chargera la configuration existente (Déjà Initialisée)--> config_load

2. Il Génerera la configuration des variables absentes et la configuration des variables dynamique --> config_generator

3 . Il trira chaque fichier *.env de la config enregistré par ordre alphabétique --> config_sort


les fonctions config_load et config_generator pourront être de nouveau appelés par le DIU par une fonction config_update


# Chemins utilisés par Kube seed

## SETTINGS_SOURCE

La variable ${SETTINGS_SOURCE} comprend le chemin contenant les sources du projet (repo git). Le contenu de ce répertoire ne doit pas être modifié à la main, et n'est mis à jour que par git

## SETTINGS_STORAGE

La variable ${SETTINGS_STORAGE} comprend le chemin où l'application va sauvgarder toutes les données nécessires au fonctionnement (par défaut, ${HOME}/seedbox)

Les sous répertoires sont :

- app_persos : permet de stocker des yml personnalisés pour lancer des apps non présentes dans l'application, ou pour surcharger certaines infos. Le format doit respecter le contenu de **examples/nouvelle_appli.yml**
- app_settings : l'endroit où sont stockés tous les réglages des applications, un répertoire par application 
- backup : l'endroit où sont stockés les backups locaux
- k3s : fichiers de conf k3s 
- local (uniquement si utilisation de rclone) : l'endroit  où sont téléchargés/stockés les fichiers avant upload. Cloudplow va vider ce répertoire au moment de l'upoad vers rclone
- logs: je vous laisse deviner
- Medias : emplacement final des fichiers multimedias. Si utilisation de rclone, c'est un mergerfs entre "local" et "rclone"
- rclone (uniquement si utilisation de rclone) : point de montage de rclone
- venv : stockage du virtualenv nécessaire au fonctionnement de kubeseed

## Autres

- ${HOME}/.config/kubeseed : permet de stocker certaines informations sur l'état de l'application (variables d'environnement, patches installés, ...)
- /var/lib/rancher : répertoire de stockage pour k3s
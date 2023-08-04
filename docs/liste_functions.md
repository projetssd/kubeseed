layout: post
title: Liste des functions utilisable
---
# Index des functions utilisables en général

Voici une petite liste, la totalité des fonctions n'est pas utilisable par le commun des mortels.<br>
Ne fonctionne que si kubeseed est installé complètement est sans bavure ;)

**__Cette liste peut-être utile:__**

| Nom de la function          | Description |
|:----------------------------|:------------|
| ks_cloudplow_upload         | Force l'upload de cloudplow en dehors des heures prévus par le fichier de config |
| ks_generate_dashboard_token | Génère le token permettant l'accès au dashboard de K3S, ce token est valable 1H |
| ks_get_from_account_yml     | Permet de récuperer une valeur dans le fichier all.yaml, on veut le domaine alors ks_get_from_account_yml user.domain |
| ks_get_system_info          | Utile à des fins de debug si un Admin vous le demande |
| ks_manage_account_yml       | Mode expert, permet de remplacer une valeur dans la all.yml, ks_get_from_account_yml applis.sonarr.auth 3 permet de remplacer par exemple l'authentification basique par aucune notification |
| ks_stocke_public_ip         | Mode expert, permet de remplacer les valeurs des ips stockées dans le all.yml, uniquement a la demande d'un admin |
| ks_launch_service           | Permet de lancer une application présente dans le scripts ou dans /seedbox/app_persos/nomdelappli.yml sans passer par le menu sous la forme de ks_launch_service nomdelappli |
| ks_delete_deployment        | Permet de supprimer une application du script ou app_persos sans passer par le menu |
| ks_restart_deployment       | Permet de restart une application, ks_restart_deployment sonarr permet un restart de sonarr |

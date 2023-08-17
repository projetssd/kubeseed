---
layout: post
title: Heimdall
---
Heimdall en action : [https://youtu.be/GXnnMAxPzMc](https://youtu.be/GXnnMAxPzMc)
![Heimdall demo animation](https://i.imgur.com/MrC4QpN.gif)
* * *

### Ajout d'une application avec retour des informations
Un exemple avec **Sonarr** :
#### En ssh, récupérer l'url interne : 
`kubectl describe ingress ing-sonarr`
```
Name:             ing-sonarr
Labels:           app=sonarr
                  ksapp=sonarr
Namespace:        kubeseed
Address:          xxxx
Ingress Class:    <none>
Default backend:  <default>
TLS:
  sonarr-tls terminates sonarr.ndd.fr
Rules:
  Host               Path  Backends
  ----               ----  --------
  sonarr.ndd.fr
                     /   sonarr:8989 (10.42.0.201:8989)
Annotations:         cert-manager.io/cluster-issuer: letsencrypt-prod
                     kubernetes.io/ingress.class: traefik
                     traefik.ingress.kubernetes.io/router.middlewares: kubeseed-oauth@kubernetescrd, default-redirect-https@kubernetescrd
Events:              <none>
```

On récupère l'url `sonarr:8989`

Note : on peut aussi faire 
```kubectl describe ingress ing-sonarr | grep -oP '/\s+\K[^ (]+'``` 
et changer sonarr par le service souhaité.


#### Compléter 
- Ajouter une application : 
	- Nom de l'application : Sonarr
	- URL : https://sonarr.ndd.fr
- Config (Optionnel) : **Actif**. *Essentiel pour avoir les retours (Le service Heimdall peut communiquer avec le service Sonarr*)
	- URL : **sonarr:8989**
	- Clé API si demandée : voir dans l'application (Sonarr, Radarr...)
	- Si **Plex** : Plex token : en ssh, `ks_get_from_account_yml plex.token` et récupérer le token

Résultat : 
![image](https://i.imgur.com/2nSfbNJ.png)

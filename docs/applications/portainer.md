---
layout: post
title: Portainer
---

Pour connecter portainer à votre cluster, une fois que l'application est installée :

Aller dans **add environment** => **kubernetesjere**

Il va indiquer une commande à lancer sur le serveur :

```
kubectl apply -f https://downloads.portainer.io/ce2-18/portainer-agent-k8s-lb.yaml
```

Passer cette commande, et attendre quelques instants, puis faire

``` 
kubectl get svc -A | grep portainer | grep 9001
```

On va voir une ligne qui ressemble à ça : 

```
portainer      portainer-agent      LoadBalancer   10.43.58.132    xxx.xxx.xxx.xxx   9001:32290/TCP               123d
```

Dans portainer, l'adresse du cluster sera 10.43.58.132:9001 (remplacer l'adresse ip par celle obtenue au dessus), et nom, mettez ce que vous voulez.


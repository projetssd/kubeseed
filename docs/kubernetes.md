---
layout: post
title: Kubernetes
---
## Implémentation de kubernetes pour Kubeseed

Pour Kubeseed, l'infra kubernetes est constitué d'un seul noeud, installé avec [k3s](https://k3s.io/). Cela permet d'avoir un cluster Kubernetes rapidement et simplement.

Kubeseed tourne sur un cluster d'un seul noeud, et n'est donc pas adapté pour de la haute disponibilité.

## La commande kubectl

La commande kubectl est disponible pour l'utilisateur qui a installé la seedbox.

Par exemple, pour avoir la liste des déploiements du namespace kubeseed :

```
kubectl get deployments
```

Par défaut, l'autocomplétion fonctionne, vous pouvez taper "tab" pour afficher les différentes possibilités (liste des namespaces, des objets, ...).
Le namespace par défaut est "kubeseed"

## Génération d'un jeton pour le dashboard

Le dashboard Kubernetes permet d'avoir un oeil sur votre infrastructure. Afin de pouvoir se loguer, vous devez générer un jeton (token).

Cela peut se faire soit depuis le menu (Gestion => Gestion Kubernetes => générer un jeton pour le dashboard), soit en lançant la commande **ks_generate_dashboard_token**

Lors de l'utilisation du dashboard, pensez à choisir le bon namespace (kubeseed)

## Notions kubernetes

Une appli kubeseed est en général composée de trois éléments (les puristes de k8s, tapez pas !):

- un deployment => un ensemble de pods (dans kubeseed, un deployment = 1 pod) avec diverses règles. Le déployement porte le nom de l'application
- un pod => c'est un ensemble de containers. Dans le cas de Kubeseed, 1 pod = 1 container. Les pods ne peuvent pas communiquer entre eux ni avec l'extérieur. Le pod a un nom qui commence par le nom de l'application, suivi d'une chaine de caractère déterminé par k8s.
- un service => c'est ce qui permet le lien réseau entre un pod et le réseau interne de Kuberenetes. Ca permet aux pods de dialoguer entre eux. Dans kubeseed, le service a le même nom que le déploiement (radarr, sonarr...). Quand rutorrent veut parler à radarr, il appelle le service radarr (et non le container radarr comme dans docker)
- un ingress => c'est une règle entrante, basée sur une url, qui fait le lien entre le monde extérieur et un service (et donc indirectement un pod). C'est par là qu'on indique que radarr.ndd.fr doit être redirigé vers le service radarr, et donc vers le pod radarr-xxxxx

Certaines applications vont avoir des services complémentaires (c'est le cas de rutorrent qui va avoir un service qui va lui permettre d'accepter les requêtes venant de l'extérieur sur le port 3000), ou bien des objetc complémentaires (les bases de données vont avoir un objet NetworkPolicy, qui va limiter les communications uniquement au pod maitre de l'application par exemple)
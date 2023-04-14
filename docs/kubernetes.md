# Kubernetes

## Implémentation de kubernetes pour Kubeseed

Pour Kubeseed, l'infra kubernetes est constitué d'un seul noeud, installé avec [k3s](https://k3s.io/). Cela permet d'avoir un cluster Kubernetes rapidement et simplement.

Kubeseed tourne sur un cluster d'un seul noeud, et n'est donc pas adapté pour de la haute disponibilité.

## La commande kubectl

La commande kubectl est disponible pour l'utilisateur qui a installé la seedbox.

Par exemple, pour avoir la liste des déploiements du namespace kubeseed :

```
kubectl -n kubeseed get deployments
```

Par défaut, l'autocomplétion fonctionne, vous pouvez taper "tab" pour afficher les différentes possibilités (liste des namespaces, des objets, ...)

## Génération d'un jeton pour le dashboard

Le dashboard Kubernetes permet d'avoir un oeil sur votre infrastructure. Afin de pouvoir se loguer, vous devez générer un jeton (token).

Cela peut se faire soit depuis le menu (Gestion => Gestion Kubernetes => générer un jeton pour le dashboard), soit en lançant la commande **ks_generate_token**
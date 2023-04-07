# Utilisation de kubernetes

## La commande kubectl

La commande kubectl est disponible pour l'utilisateur qui a installé la seedbox.

Pour avoir la liste des déploiements du namespace kubeseed :

```
kubectl -n kubeseed get deployments
```

Par défaut, l'autocomplétion fonctionne, vous pouvez taper "tab" pour afficher les différentes possibilités (liste des namespaces, des objets, ...)
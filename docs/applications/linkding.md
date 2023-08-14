---
layout: post
title: linkding
---

Pour créer un identifiant super utilisateur : 

Une commande à lancer (tout copier-coller): 

```
kubectl exec -it $(kubectl get pods -o custom-columns=NAME:.metadata.name | grep linkding) -- python manage.py createsuperuser

```
Compléter username, email, password, qui seront les identifiants du superuser

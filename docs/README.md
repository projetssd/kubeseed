# Kubeseed, c'est quoi ? 

Kubeseed est un projet de seedbox et autres outils tournant sur un moteur Kubernetes. L'implémentation qui a été choisie est [k3s](https://k3s.io/)

# Comment l'installer 

Vous avez besoin : 
- d'un serveur en debian 11 fraîchement installé
- d'un nom de domaine

Non obligatoire mais conseillé : l'utilisation de cloudflare. Cela permet les enregistrements automatiques des sous domaines.

A minima, les ports 80 et 443 doivent être accessibles. Certaines autres ports devront être accessibles selon les outils installés :
- 32400 pour plex
- 30000 pour rutorrent
- etc...

Avec ces outils : 

```
git clone https://github.com/projetssd/kubeseed.git
cd kubeseed
./seedbox.sh
```

et laissez vous guider...

[test de lien](kubernetes.md)
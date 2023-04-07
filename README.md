# 
Kubeseed
Kubeseed - uses kubernetes for containers

# PROJET EN COURS D'ECRITURE - NE PAS UTILISER EN L'ETAT

A installer sur Debian 11 EXCLUSIVEMENT (travaux en cours pour rendre compatible)

## Prérequis : 
* Un serveur avec accès internet. A minima les ports 80 et 443 doivent être accessibles (d'autres ports pourront être nécessaires pour d'autres appli, 32400 pour Plex, 30000 pour rutorrent, etc...)
* Un nom de domaine
* Optionnel mais fortement recommandé : faire gérer son nom de domaine par cloudflare pour automatiser les entrées dns

Le serveur doit avoir les paquets git et sudo installés

## Procédure

A lancer avec un user qui n'est pas root, mais qui a les droits sudo all

```
git clone https://github.com/projetssd/kubeseed.git
cd kubeseed
./seedbox.sh
```

et se laisser guider

# Dévelopeurs






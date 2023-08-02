# Kubeseed

Kubeseed - uses kubernetes for containers

# RELEASE CANDIDATE PROJECT - USE AT YOUR OWN RISKS

/!\ ENGLISH TRANSLATORS WANTED /!\ 

To be installed on a fresh Debian 11 or 12 (Ubuntu 22.04 should be ok, but not fully tested)

## Prerequisistes

* a server with internet access. At least, ports 80 and 443 must be available (other ports could be necesseray depending on other applications, 32400 for plex, 30000 for rutorrent...)
* a domain name
* optionnal but recommended : using cloudflare to manage his doamin name

Server should have git and sudo installed (apt install git sudo)

## Steps

To be used with a user with sudo rights (not root)

```
git clone https://github.com/projetssd/kubeseed.git
cd kubeseed
./seedbox.sh
```

Full documentation (french only for now) [here](https://projetssd.github.io/kubeseed/)

# PROJET EN RELEASE CANDIDATE - UTILISEZ A VOS RISQUES ET PERILS

test
A installer sur Debian 11 ou 12 (Ubuntu 22.04 compatible mais non testé)

## Prérequis : 
* Un serveur avec accès internet. A minima les ports 80 et 443 doivent être accessibles (d'autres ports pourront être nécessaires pour d'autres appli, 32400 pour Plex, 30000 pour rutorrent, etc...)
* Un nom de domaine
* Optionnel mais fortement recommandé : faire gérer son nom de domaine par cloudflare pour automatiser les entrées dns

Le serveur doit avoir les paquets git et sudo installés (apt install git sudo)

## Procédure

A lancer avec un user qui n'est pas root, mais qui a les droits sudo all

```
git clone https://github.com/projetssd/kubeseed.git
cd kubeseed
./seedbox.sh
```

et se laisser guider

La documentation complète se trouve [ici](https://projetssd.github.io/kubeseed/)






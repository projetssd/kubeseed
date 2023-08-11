---
layout: post
title: Loki et promtail
---

Promtail et Loki permettent de lire les logs dans grafana.

Prérequis : avoir installé grafana

## Méthode

```
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm upgrade --install loki grafana/loki-distributed -n kubeseed
helm show values grafana/promtail > promtail-overrides.yaml
```

Editer le fichier promtail-overrides.yaml

Aux alentours de la ligne 410, remplacer

``` 
- url: http://loki-gateway/loki/api/v1/push
```

par

```
- url: http://loki-loki-distributed-gateway/loki/api/v1/push
```

(attention à l'indentation, c'est du yaml !)

Sauvegarder, puis

```
helm upgrade --install --values promtail-overrides.yaml promtail grafana/promtail -n kubeseed
```

## Dans grafana

Entrer une nouvelle source de données :

Loki, url = http://loki-loki-distributed-gateway

Importer le dashboard n°15141, et choisir la source "loki"
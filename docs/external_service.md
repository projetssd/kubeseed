---
layout: post
title: Service externe
---
Le but est que kubernetes accepte les connexions et renvoie vers un service qui n'est pas géré par lui

## Prérequis

Avoir une entrée dns (cloudflare ou autre) avec le bon fqdn qui pointe vers le serveur kubeseed

## Création

Créer le fichier **external.yml**
```
kind: Service
apiVersion: v1
metadata:
  name: external-service
  labels:
    app: externalservice
    ksapp: externalservice
spec:
  ports:
  - protocol: TCP
    port: 80 # Mettre le port de ton appli

---

kind: Endpoints
apiVersion: v1
metadata:
  name: external-service
  labels:
    app: externalservice
    ksapp: externalservice
subsets:
- addresses:
  - ip: 1.2.3.4 # Mettre l'ip de ton appli (ou l'ip publique du node si le service tourne sur le node)
  ports:
  - port: 80 # Mettre le port de ton appli
---
kind: Ingress
apiVersion: networking.k8s.io/v1
metadata:
  name: ing-externalservice
  namespace: kubeseed
  labels:
    app: externalservice
    ksapp: externalservice
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    kubernetes.io/ingress.class: traefik
    traefik.ingress.kubernetes.io/router.middlewares: default-redirect-https@kubernetescrd
spec:
  tls:
    - hosts:
        - xxxxxx.ndd.tld # Mettre ici le fqdn d'accès
      secretName: externalservice-tls
  rules:
    - host: xxxxxx.ndd.tld # Mettre ici le fqdn d'accès
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: external-service
                port:
                  number: 80 # Mettre le port de ton appli


```

Modifier les données nécessaires (ip, port, et fqdn),

puis

```
kubectl apply -f external.yml
```

Vous pouvez personnaliser les noms et labels external-service et externalservice. Ils doivent correspondre entre tous les éléments (service, ingress et endpoint)

## Suppression

```
kubectl delete -f external.yml
```

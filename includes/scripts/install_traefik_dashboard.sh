#!/bin/bash
################################################
# Installation et configuration du
# dashboard Kubernetes
################################################
source "${SETTINGS_SOURCE}/includes/functions.sh"
source "${SETTINGS_SOURCE}/includes/variables.sh"
#
ks_log_statusbar "Installation du dashboard Traefik"
ks_get_and_store_info  "applis.traefik.subdomain" "Sous domaine pour traefik" UNCHECK "traefik"
ks_get_and_store_info  "applis.traefik.auth" "Authentification pour traefik - 1 => basique (défaut) | 2 => oauth | 3 => aucune" UNCHECK 1
ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/cloudflare_domain.yml" -e "subdomain=$(ks_get_from_account_yml applis.traefik.subdomain)"
ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/k3s_create_secret.yml"
ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/traefik_dashboard.yml"
echo "==================================="
echo "Le dashboard est accessible à l'adresse https://$(ks_get_from_account_yml applis.traefik.subdomain).$(ks_get_from_account_yml user.domain)/dashboard/"

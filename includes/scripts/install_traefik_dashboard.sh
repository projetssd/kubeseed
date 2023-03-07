#!/bin/bash
################################################
# Installation et configuration du
# dashboard Kubernetes
################################################
source "${SETTINGS_SOURCE}/includes/functions.sh"
source "${SETTINGS_SOURCE}/includes/variables.sh"
#
ks_log_statusbar "Installation du dashboard Traefik"
read -rp $'\e[33mQuel sous domaine pour le dashboard Traefik [traefik]\e[0m :' traefik_domain
traefik_domain=${dtraefik_domain:-traefik}
ks_manage_account_yml applis.traefik.domain "${traefik_domain}"
ks_auth_unitaire traefik
ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/cloudflare_domain.yml" -e "subdomain=${traefik_domain}"
ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/k3s_create_secret.yml"
ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/traefik_dashboard.yml"
echo "==================================="
echo "Le dashboard est accessible à l'adresse https://${traefik_domain}.$(ks_get_from_account_yml user.domain)/dashboard/"

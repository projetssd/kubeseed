#!/bin/bash
################################################
# Installation et configuration du
# dashboard Kubernetes
################################################
source "${SETTINGS_SOURCE}/includes/functions.sh"
source "${SETTINGS_SOURCE}/includes/variables.sh"
#
ks_log_statusbar "Installation du dashboard K3S"
ks_get_and_store_info  "applis.dashboard.domain" "Quel sous domaine pour le dashboard kubernetes" KS_DASHBOARD_SUBDOMAIN "dashboard"

ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/cloudflare_domain.yml" -e "subdomain=$(ks_get_from_account_yml applis.dashboard.domain)"
GITHUB_URL=https://github.com/kubernetes/dashboard/releases
VERSION_KUBE_DASHBOARD=$(curl -w '%{url_effective}' -I -L -s -S ${GITHUB_URL}/latest -o /dev/null | sed -e 's|.*/||')
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v3.0.0-alpha0/charts/kubernetes-dashboard.yaml
ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/configure_dashboard.yml"
echo "==================================="
echo "Le dashboard est accessible à l'adresse https://$(ks_get_from_account_yml applis.dashboard.domain).$(ks_get_from_account_yml user.domain)"
echo "Vous pourrez générer un jeton plus tard pour vous y connecter"
#!/bin/bash
################################################
# Installation et configuration du
# dashboard Kubernetes
################################################
source ${SETTINGS_SOURCE}/includes/functions.sh
source ${SETTINGS_SOURCE}/includes/variables.sh
#
ks_log_statusbar "Installation du dashboard K3S"
read -rp $'\e[33mQuel sous domaine pour le dashboard kubernetes [dashboard]\e[0m :' dashboard_domain
dashboard_domain=${dashboard_domain:-dashboard}
ks_manage_account_yml appli.dashboard.domain ${dashboard_domain}
ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/cloudflare_domain.yml" -e "${dashboard_domain}"
GITHUB_URL=https://github.com/kubernetes/dashboard/releases
VERSION_KUBE_DASHBOARD=$(curl -w '%{url_effective}' -I -L -s -S ${GITHUB_URL}/latest -o /dev/null | sed -e 's|.*/||')
kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/${VERSION_KUBE_DASHBOARD}/aio/deploy/recommended.yaml
ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/configure_dashboard.yml"
echo "==================================="
echo "Le dashboard est accessible à l'adresse https://${dashboard_domain}.$(ks_get_from_account_yml user.domain)"
echo "Vous pourrez générer un jeton plus tard pour vous y connecter"
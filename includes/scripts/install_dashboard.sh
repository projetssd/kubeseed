#!/bin/bash
################################################
# Installation et configuration du
# dashboard Kubernetes
################################################
source ${SETTINGS_SOURCE}/includes/functions.sh
source ${SETTINGS_SOURCE}/includes/variables.sh
#
ks_log_statusbar "Installation du dashboard K3S"
GITHUB_URL=https://github.com/kubernetes/dashboard/releases
VERSION_KUBE_DASHBOARD=$(curl -w '%{url_effective}' -I -L -s -S ${GITHUB_URL}/latest -o /dev/null | sed -e 's|.*/||')
kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/${VERSION_KUBE_DASHBOARD}/aio/deploy/recommended.yaml
ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/configure_dashboard.yml"
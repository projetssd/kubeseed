#!/bin/bash


# Si le fichier n'existe pas, on ne fait rien
if [ -f "${HOME}/.config/kubeseed/env" ]; then
  source "${HOME}/.config/kubeseed/env"
  export VENV_DIR=${SETTINGS_STORAGE}/venv/ks
  export PATH="$HOME/.local/bin:$PATH"
  # On rentre dans le venv
  source ${VENV_DIR}/bin/activate
  # On charge les variables
  source ${SETTINGS_SOURCE}/includes/variables.sh
  # On charge les fonctions
  source ${SETTINGS_SOURCE}/includes/functions.sh
  # On charge les fonctions qui sont lancées par le menu
  #source ${SETTINGS_SOURCE}/includes/menus.sh

  PYTHONPATH=${VENV_DIR}/lib/$(ls ${VENV_DIR}/lib)/site-packages
  export PYTHONPATH
  # le fonction nous a probablement fait sortir du venv, on le recharge
  source ${VENV_DIR}/bin/activate
  # autocompletion kubectl
  source <(kubectl completion bash)
  kubectl config set-context --current --namespace=kubeseed
fi



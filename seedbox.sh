#!/bin/bash

##################################################
# Kubeseed
##################################################
# Crée le 23/02/2023 par Merrick
##################################################

################################################
# TEST ROOT USER
if [ "$USER" == "root" ]; then
  source "includes/variables.sh"
  echo -e "${CCYAN}-----------------------${CEND}"
  echo -e "${CCYAN}[  $(gettext "Lancement en root")  ]${CEND}"
  echo -e "${CCYAN}-----------------------${CEND}"
  echo -e "${CCYAN} $(gettext "KubeSeed ne doit pas être lancé en root ou en sudo")${CEND}"
  echo -e "${CCYAN}-----------------------${CEND}"
  exit 1
fi

# on change tout de suite le path pour la suite
export PATH="$HOME/.local/bin:$PATH"
# sauvegarde de l'IFS
export IFSORIGIN="${IFS}"

# Absolute path to this script.
CURRENT_SCRIPT=$(readlink -f "$0")
# Absolute path this script is in.
SETTINGS_SOURCE=$(dirname "$CURRENT_SCRIPT")
export SETTINGS_SOURCE
cd "${SETTINGS_SOURCE}"

source "${SETTINGS_SOURCE}/includes/variables.sh"
source "${SETTINGS_SOURCE}/includes/functions.sh"
# source "${SETTINGS_SOURCE}/includes/menus.sh"

#
# Maintenant, on a toutes les infos
#

if [ ! -f "${HOME}/.config/kubeseed/installed" ]; then
  # kubeseed v3 n'est pas installé
  clear
  ks_install | tee "${SETTINGS_STORAGE}/logs/install.log"
fi

# on contre le bug de debian et du venv qui ne trouve pas les paquets installés par galaxy
source "${VENV_DIR}/bin/activate"
temppath=$(ls ${VENV_DIR}/lib)
pythonpath=${VENV_DIR}/lib/${temppath}/site-packages
export PYTHONPATH=${pythonpath}

clear

#update_logrotate
ks_log_statusbar "Check de la dernière version sur git"
git_branch=$(git rev-parse --abbrev-ref HEAD)
if [ "${git_branch}" == 'main' ]; then
  cd "${SETTINGS_SOURCE}"
  git fetch >>/dev/null 2>&1
  current_hash=$(git rev-parse HEAD)
  distant_hash=$(git rev-parse main@{upstream})
  if [ "${current_hash}" != "${distant_hash}" ]; then
    echo "==============================================="
    echo "= Il existe une mise à jour"
    echo "= Pour le faire, sortez du script, puis tapez"
    echo "= git pull"
    echo "==============================================="
    ks_pause
  fi
else
  echo "==============================================="
  echo "= Attention, vous n'êtes pas sur la branche main !"
  echo "= Pour repasser sur main, sortez du script, puis tapez "
  echo "= git checkout main"
  echo "==============================================="
  ks_pause
fi

ks_log_statusbar "Application des patchs de livraison"
apply_patches

unset_window
clear

#####################################################
# On finit de setter les variables
# On ressource l'environnement
source "${SETTINGS_SOURCE}/profile.sh"
ks_logo
echo "============================================="
# Affichage du memnu, commande python
python "${SETTINGS_SOURCE}/includes/scripts/menu.py"

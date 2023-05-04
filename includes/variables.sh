## PARAMETRES

CSI="\033["
CEND="${CSI}0m"
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CPURPLE="${CSI}1;35m"
CCYAN="${CSI}1;36m"
RED='\e[0;31m'
GREEN='\033[0;32m'
BLUEDARK='\033[0;34m'
BLUE='\e[0;36m'
YELLOW='\e[0;33m'
BWHITE='\e[1;37m'
NC='\033[0m'
DATE=$(date +%d/%m/%Y-%H:%M:%S)
IPADDRESS=$(hostname -I | cut -d\  -f1)
CURRENTDIR="$PWD"
export NEWT_COLORS='
  window=,white
  border=green,blue
  textbox=black,white
'

# A partir de là, on va chercher les variables nécessaires

if [ ! -f "${HOME}/.config/kubeseed/env" ]; then
  # pas de fichier d'environnement

  # Si on est là, c'est que rien n'est installé, on va poser les questions*
  mkdir -p "${HOME}/.config/kubeseed/"
  # on prend le répertoire courant pour la source
  sourcedir=$(dirname "$(readlink -f "$0")")
  export SETTINGS_SOURCE=${sourcedir}
  echo "SETTINGS_SOURCE=${sourcedir}" >>"${HOME}/.config/kubeseed/env"
  read -p "Dans quel répertoire voulez vous stocker les réglages des containers ? (défaut : ${HOME}/seedbox) " destdir
  destdir=${destdir:-${HOME}/seedbox}
  export SETTINGS_STORAGE=${destdir}
  echo "SETTINGS_STORAGE=${destdir}/" >>"${HOME}/.config/kubeseed/env"
  mkdir -p "${SETTINGS_STORAGE}/logs"

else
  source "${HOME}/.config/kubeseed/env"
fi

export SETTINGS_SOURCE=${SETTINGS_SOURCE}
export SETTINGS_STORAGE=${SETTINGS_STORAGE}
export VENV_DIR=${SETTINGS_STORAGE}/venv/ks
export ANSIBLE_VARS=${HOME}/.ansible/inventories/group_vars/all.yml
export KUBECONFIG=${HOME}/seedbox/k3s/k3s.yaml
if [ -f "${VENV_DIR}/bin/activate" ]; then
  temppath=$(ls ${VENV_DIR}/lib)
  pythonpath=${VENV_DIR}/lib/${temppath}/site-packages
  export PYTHONPATH=${pythonpath}
fi
# On risque d'avoir besoin de ces variables d'environnement par la suite
export MYUID=$(id -u)
export MYGID=$(id -g)
export MYGIDNAME=$(id -gn)
# Rclone
export RCLONE_MNT_DIR="${HOME}/seedbox/rclone"
# app settings
export APP_SETTINGS="${SETTINGS_STORAGE}/app_settings"
# Internationalization
export TEXTDOMAIN=ks
export TEXTDOMAINDIR="${SETTINGS_SOURCE}/i18n"

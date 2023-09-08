#!/bin/bash

source "${SETTINGS_SOURCE}/includes/functions.sh"
# shellcheck source=${BASEDIR}/includes/variables.sh
source "${SETTINGS_SOURCE}/includes/variables.sh"

echo "####################################################"
echo "# ATTENTION                                        #"
echo "####################################################"
echo "# Avec les nouvelles versions de rclone,           #"
echo "# il n'est plus possible de générer le rclone.conf #"
echo "# depuis le serveur                                #"
echo "#==================================================#"
echo "# Assurez vous d'avoir un rclone.conf existant     #"
echo "# avant de continuer                               #"
echo "####################################################"
ks_pause

mkdir -p "${HOME}/.config/rclone"
RCLONE_CONFIG_FILE="${HOME}/.config/rclone/rclone.conf"


function paste() {
  echo -e "${YELLOW}\nColler le contenu de rclone.conf avec le clic droit, et taper ${CCYAN}STOP${CEND}${YELLOW} pour poursuivre le script.\n${NC}"
  while :; do
    read -p "" EXCLUDEPATH
    if [[ "$EXCLUDEPATH" = "STOP" ]] || [[ "$EXCLUDEPATH" = "stop" ]]; then
      break
    fi
    echo "$EXCLUDEPATH" >>${RCLONE_CONFIG_FILE}
  done
  sed -n -i '1h; 1!H; ${x; s/\n*$//; p}' ${RCLONE_CONFIG_FILE} >/dev/null 2>&1
  echo ""
}

function detection() {
  #clear
  echo ""
  echo -e "${CCYAN}Choisir le remote :${CEND}"
  echo ""

  rm -f /tmp/choix_crypt
  "${SETTINGS_SOURCE}/includes/scripts/rclone_list_drives.py"
  remotecrypt=$(cat /tmp/choix_crypt)
  rm -f /tmp/choix_crypt
}

function verif() {
  detection
  ks_manage_account_yml rclone.remote $remotecrypt
  exit
}

function menu() {

  if [ ! -e "$rclone" ]; then
    curl https://rclone.org/install.sh | sudo bash
  fi
  echo ""

  echo -e "${CCYAN}Gestion du rclone.conf${CEND}"
  echo -e "${CGREEN}${CEND}"
  echo -e "${CGREEN}   1) Copier/coller un rclone.conf déjà existant ${CEND}"
  echo -e "${CGREEN}   2) rclone.conf déjà existant sur le serveur --> ${RCLONE_CONFIG_FILE}${CEND}"

  echo -e ""

  read -p "Votre choix [1-2]: " CHOICE

  case $CHOICE in
  1) ## Copier/coller un rclone.conf déjà existant
    paste
    verif
    ;;
  2) ## Création rclone.conf
    verif
    ;;
  esac
}


menu


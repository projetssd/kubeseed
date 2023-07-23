#!/bin/bash
##########

function ks_logo() {

  color1='\033[1;31m' # Bold RED
  color2='\033[1;35m' # Bold PURPLE
  color3='\033[0;33m' # Regular YELLOW
  nocolor='\033[0m'   # no color
  colorp='\033[1;34m' # Bold BLUE
  colora='\033[1;32m' # Bold GREEN
  projetname='KubeSeed'
  authors="$(gettext "Auteur"): Merrick"
  printf " \n"
  printf " ${colorp} ██╗  ██╗${colora}██╗   ██╗██████╗ ███████╗${colorp}███████╗${colora}███████╗███████╗██████╗ ${nocolor}\n"
  printf " ${colorp} ██║ ██╔╝${colora}██║   ██║██╔══██╗██╔════╝${colorp}██╔════╝${colora}██╔════╝██╔════╝██╔══██╗${nocolor}\n"
  printf " ${colorp} █████╔╝ ${colora}██║   ██║██████╔╝█████╗  ${colorp}███████╗${colora}█████╗  █████╗  ██║  ██║${nocolor}\n"
  printf " ${colorp} ██╔═██╗ ${colora}██║   ██║██╔══██╗██╔══╝  ${colorp}╚════██║${colora}██╔══╝  ██╔══╝  ██║  ██║${nocolor}\n"
  printf " ${colorp} ██║  ██╗${colora}╚██████╔╝██████╔╝███████╗${colorp}███████║${colora}███████╗███████╗██████╔╝${nocolor}\n"
  printf " ${colorp} ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝╚══════╝╚${colorp}══════╝╚${colora}══════╝╚═════╝ ${nocolor}\n"
  printf "${colorp}${projetname}${nocolor} - ${colora}${authors}${nocolor}\n"
  printf "${color3}$(lsb_release -sd)${nocolor}"
  printf "${color3}$(uname -srmo) - Uptime: $(/usr/bin/uptime -p)${nocolor}\n"
}

function ks_install_oauth() {
  #######################################
  # Récupère les infos oauth
  #######################################

  echo -e "${BLUE}### Google OAuth2 avec Traefik – Secure SSO pour les services Docker ###${NC}"
  echo ""
  echo -e "${CCYAN}------------------------------------------------------------------${CEND}"
  echo -e "${CCYAN}    Protocole d'identification via Google OAuth2		   ${CEND}"
  echo -e "${CCYAN}    Securisation SSO pour les services Docker			   ${CEND}"
  echo -e "${CCYAN}------------------------------------------------------------------${CEND}"
  echo ""
  echo -e "${CRED}-------------------------------------------------------------------${CEND}"
  echo -e "${CRED}    /!\ IMPORTANT: Au préalable créer un projet et vos identifiants${CEND}"
  echo -e "${CRED}    https://github.com/projetssd/ssdv2/wiki/Google-OAuth /!\ 		   ${CEND}"
  echo -e "${CRED}-------------------------------------------------------------------${CEND}"
  echo ""
  read -rp $'\e[33mSouhaitez vous sécuriser vos Applis avec Google OAuth2 ? (o/n)\e[0m :' OUI

  if [[ "$OUI" == "o" ]] || [[ "$OUI" == "O" ]]; then

    ks_get_and_store_info "oauth.client_id" "Oauth_client" UNCHECK
    ks_get_and_store_info "oauth.client_secret" "Oauth_secret" UNCHECK
    ks_get_and_store_info "oauth.account" "Compte Gmail utilisé(s), séparés d'une virgule si plusieurs" UNCHECK

    openssl=$(openssl rand -hex 16)
    ks_manage_account_yml oauth.secret "$openssl"
    ks_manage_account_yml applis.oauth.subdomain oauth
    echo ""
    echo -e "${CRED}---------------------------------------------------------------${CEND}"
    echo -e "${CCYAN}    IMPORTANT:	Avant la 1ere connexion			       ${CEND}"
    echo -e "${CCYAN}    		- Nettoyer l'historique de votre navigateur    ${CEND}"
    echo -e "${CCYAN}    		- déconnection de tout compte google	       ${CEND}"
    echo -e "${CRED}---------------------------------------------------------------${CEND}"
    echo ""
    echo -e "\nAppuyer sur ${CCYAN}[ENTREE]${CEND} pour continuer..."
    read -r
    ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/deploy_oauth.yml"
    echo "==============================================="
    echo "= Choisissez les applications à réinitialiser ="
    python3 "${SETTINGS_SOURCE}/includes/scripts/generique_python.py" choix_reinit_appli
  fi

  echo ""
}

function ks_install_sauvegarde() {
  #configuration Sauvegarde
  echo -e "${BLUE}### BACKUP ###${NC}"
  echo -e " ${BWHITE}* Mise en place Sauvegarde${NC}"
  ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/install_backup.yml"
  ks_checking_errors $?
  echo ""
}

function ks_debug() {
  echo "### DEBUG ${1}"
  pause
}

function ks_update_logrotate() {
  ansible-playbook "${SETTINGS_SOURCE}/includes/config/playbooks/logrotate.yml"
}

function ks_install_autoscan() {
  #configuration autoscan avec ansible
  echo -e "${BLUE}### AUTOSCAN ###${NC}"
  echo -e " ${BWHITE}* Installation autoscan${NC}"
  ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/autoscan.yml"
}

function ks_install_cloudplow() {
  echo -e "${BLUE}### CLOUDPLOW ###${NC}"
  echo -e " ${BWHITE}* Installation cloudplow${NC}"
  ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/cloudplow.yml"
}

function ks_check_dir() {
  if [[ $1 != "${SETTINGS_SOURCE}" ]]; then
    # shellcheck disable=SC2164
    cd "${SETTINGS_SOURCE}"
  fi
}

function ks_create_dir() {
  ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/create_directory.yml" \
    --extra-vars '{"DIRECTORY":"'${1}'"}'
}

function ks_conf_dir() {
  ks_create_dir "${SETTINGS_STORAGE}"
}

function ks_create_file() {
  TMPMYUID=$(whoami)
  MYGID=$(id -g)
  ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/create_file.yml" \
    --extra-vars '{"FILE":"'${1}'","UID":"'${TMPMYUID}'","GID":"'${MYGID}'"}'
}

function ks_change_file_owner() {
  ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/chown_file.yml" \
    --extra-vars '{"FILE":"'${1}'"}'

}

function ks_make_dir_writable() {
  ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/change_rights.yml" \
    --extra-vars '{"DIRECTORY":"'${1}'"}'

}

function ks_checking_errors() {
  if [[ "$1" == "0" ]]; then
    echo -e "	${GREEN}--> Operation success !${NC}"
    CURRENT_ERROR=0
  else
    echo -e "	${RED}--> Operation failed !${NC}"
    CURRENT_ERROR=1
  fi
}

function ks_install_fail2ban() {
  echo -e "${BLUE}### FAIL2BAN ###${NC}"
  ansible-playbook "${SETTINGS_SOURCE}/includes/config/roles/fail2ban/tasks/main.yml"
  ks_checking_errors $?
  echo ""
}

function ks_install_rclone() {
  curl https://rclone.org/install.sh | sudo bash
  echo -e "${BLUE}### RCLONE ###${NC}"
  fusermount -uz "${RCLONE_MNT_DIR}" >>/dev/null 2>&1
  ks_create_dir "${RCLONE_MNT_DIR}"
  "${SETTINGS_SOURCE}/includes/scripts/rclone.sh"
  ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/rclone.yml"
  ks_checking_errors $?
  echo ""
}

function ks_mergerfs() {
  echo -e "${BLUE}### Unionfs-Fuse ###${NC}"
  echo -e " ${BWHITE}* Installation Mergerfs${NC}"
  ks_create_dir "${HOME}/seedbox/Medias"
  sudo apt install -y mergerfs
  ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/mergerfs.yml"
  echo ""
}

function ks_launch_service() {

  line=$1

  if [ "${line}" == "plex" ]; then
    "${SETTINGS_SOURCE}/includes/scripts/plex_token.sh"
  fi

  ks_log_write "Installation de ${line}"
  error=0
  ks_get_and_store_info "applis.${line}.subdomain" "Sous domaine pour ${line}" UNCHECK "${line}"
  ks_get_and_store_info "applis.${line}.auth" "Authentification ${line} - 1 => basique (défaut) | 2 => oauth | 3 => aucune" UNCHECK 1

  # On est dans le cas générique
  # on regarde s'i y a un playbook existant

  if [[ -f "${SETTINGS_STORAGE}/app_persos/${line}.yml" ]]; then
    # il y a déjà un playbook "perso", on le lance
    ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/launch_service.yml" --extra-vars "var_file=${SETTINGS_STORAGE}/app_persos/${line}.yml"

  elif [[ -f "${SETTINGS_SOURCE}/containers/${line}.yml" ]]; then
    # puis on lance le générique avec ce qu'on vient de copier
    ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/launch_service.yml" --extra-vars "var_file=${SETTINGS_SOURCE}/containers/${line}.yml"
  else
    ks_log_write "Aucun fichier de configuration trouvé dans les sources, abandon"
    error=1
  fi
}

function ks_pause() {
  echo ""
  echo -e "${YELLOW}###  -->APPUYER SUR ENTREE POUR CONTINUER<--  ###${NC}"
  read
  echo ""
}

function ks_manage_account_yml() {
  # usage
  # ks_manage_account_yml key value
  # key séparées par des points (par exemple user.name ou sub.application.subdomain)
  # pour supprimer une clé, il faut que le value soit égale à un espace
  # ex : ks_manage_account_yml sub.toto.toto toto => va créer la clé sub.toto.toto et lui mettre à la valeur toto
  # ex : ks_manage_account_yml sub.toto.toto " " => va supprimer la clé sub.toto.toto et toutes les sous clés
  if [ -f "${SETTINGS_STORAGE}/.account.lock" ]; then
    echo "Fichier account locké, impossible de continuer"
    echo "----------------------------------------------"
    echo "Présence du fichier ${SETTINGS_STORAGE}/.account.lock"
    exit 1
  else
    touch "${SETTINGS_STORAGE}/.account.lock"
    ansible-vault decrypt "${ANSIBLE_VARS}" >/dev/null 2>&1
    if [ "${2}" = " " ]; then
      ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/manage_account_yml.yml" -e "account_key=${1} account_value=${2}  state=absent"
    else
      ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/manage_account_yml.yml" -e "account_key=${1} account_value=${2} state=present"
    fi
    ansible-vault encrypt "${ANSIBLE_VARS}" >/dev/null 2>&1
    rm -f "${SETTINGS_STORAGE}/.account.lock"
  fi
}

function ks_get_from_account_yml() {
  tempresult=$(ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/get_var.yml" -e myvar="${1}" | grep "##RESULT##" | awk -F'##RESULT##' '{print $2}' | xargs)
  if [ -z "$tempresult" ]; then
    tempresult=notfound
  fi
  echo $tempresult
}

function ks_install() {

  # on regarde s'il un fichier kickstart
  if [ -f "${SETTINGS_SOURCE}/kickstart" ]; then
    echo "fichier kickstart trouvé"
    source "${SETTINGS_SOURCE}/kickstart"
  fi

  sudo chown -R "${USER}:" "${SETTINGS_SOURCE}"

  # mise en place du sudo sans password
  if [ ! -f "/etc/sudoers.d/${USER}" ]; then
    echo "${USER} ALL=(ALL) NOPASSWD:ALL" | sudo tee "/etc/sudoers.d/${USER}"
  fi

  echo "Certains composants doivent encore être installés/réglés"
  echo "Cette opération va prendre plusieurs minutes selon votre système "
  echo "=================================================================="
  read -p "Appuyez sur entrée pour continuer, ou ctrl+c pour sortir"
  echo "=================================================================="
####
#  ks_log_statusbar "Gestion du source list"
#  version_ok=0
#  if grep "NAME=" /etc/os-release | grep -qi debian; then
#    # Debian
#    if grep "VERSION_ID=" /etc/os-release | grep -q 11; then
#      sudo mv /etc/apt/sources.list /etc/apt/sources.list.before_kubeseed
#      sudo cp "${SETTINGS_SOURCE}/includes/files/debian11.sources.list" /etc/apt/sources.list
#      version_ok=1
#    else
#      echo "Kubeseed n'est pour l'instant compatible qu'avec la version 11 de Debian"
#      exit 1
#    fi
#  fi
#
#  if grep "NAME=" /etc/os-release | grep -qi ubuntu; then
#    # Debian
#    if grep "VERSION_ID=" /etc/os-release | grep -q "22.04"; then
#      sudo mv /etc/apt/sources.list /etc/apt/sources.list.before_kubeseed
#      sudo cp "${SETTINGS_SOURCE}/includes/files/ubuntu2204.sources.list" /etc/apt/sources.list
#      version_ok=1
#    else
#      echo "Kubeseed n'est pour l'instant compatible qu'avec la version 22.04 d'Ubuntu'"
#      exit 1
#    fi
#  fi
#
#  if [ ${version_ok} == 0 ]; then
#    echo "Aucune version compatible pour l'installation, abandon..."
#    exit 1
#  fi
####

  ks_log_statusbar "Gestion du source list"
  version_ok=0

  # Récupérer les informations sur la distribution
  distro=$(grep "NAME=" /etc/os-release | grep -oP '(?<=\").*(?=\")')
  version=$(grep "VERSION_ID=" /etc/os-release | grep -oP '(?<=\").*(?=\")')

  # Fonction pour changer le sources.list et marquer la version comme compatible
  change_sources_list() {
      sudo mv /etc/apt/sources.list /etc/apt/sources.list.before_kubeseed
      sudo cp "${SETTINGS_SOURCE}/includes/files/${1}" /etc/apt/sources.list
      version_ok=1
  }

  if [ "$distro" == "Debian" ]; then
      if [ "$version" == "11" ]; then
          change_sources_list "debian11.sources.list"
      elif [ "$version" == "12" ]; then
          change_sources_list "debian12.sources.list"
      else
          echo "Kubeseed n'est compatible qu'avec Debian 11 et Debian 12 pour l'instant."
          exit 1
      fi
  fi

  if [ "$distro" == "Ubuntu" ]; then
      if [ "$version" == "22.04" ]; then
          change_sources_list "ubuntu2204.sources.list"
      else
          echo "Kubeseed n'est compatible qu'avec Ubuntu 22.04 pour l'instant."
          exit 1
      fi
  fi

  if [ "$version_ok" -eq 0 ]; then
      echo "Aucune version compatible pour l'installation, abandon..."
      exit 1
  fi
  ks_pause
  ks_log_statusbar "Mise à jour du systeme"
  sudo apt update

  ks_log_statusbar "Installation des paquets systeme"
  sudo apt-get install -y \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3-dev \
    python3-pip \
    python3-venv \
    apache2-utils \
    dnsutils \
    python3-apt \
    python3-venv \
    python-apt-doc \
    python-apt-common \
    ca-certificates \
    curl \
    gnupg \
    software-properties-common \
    apt-transport-https \
    lsb-release \
    python3-kubernetes \
    fuse3 \
    bash-completion \
    gettext

  sudo rm -f /usr/bin/python

  sudo ln -s /usr/bin/python3 /usr/bin/python

  # création d'un vault_pass vide
  if [ ! -f "${HOME}/.vault_pass" ]; then
    mypass=$(
      tr -dc A-Za-z0-9 </dev/urandom | head -c 25
      echo ''
    )
    echo "$mypass" >"${HOME}/.vault_pass"
  fi

  # création d'un virtualenv
  ks_log_statusbar "Création du virtualenv"
  echo "=================================================================="
  echo "Création du virtualenv"
  mkdir -p "${VENV_DIR}"
  python3 -m venv "${SETTINGS_STORAGE}/venv/ks"

  # activation du venv
  source "${VENV_DIR}/bin/activate"

  temppath=$(ls "${VENV_DIR}/lib")
  pythonpath="${VENV_DIR}/lib/${temppath}/site-packages"
  export PYTHONPATH="${pythonpath}"

  ## PIP
  ks_log_statusbar "Installation/upgrade de pip"
  python3 -m pip install --disable-pip-version-check --upgrade --force-reinstall pip
  ks_log_statusbar "Installation des paquets python"
  pip install wheel
  pip install ansible \
    docker \
    shyaml \
    netaddr \
    dnspython \
    configparser \
    kubernetes \
    inquirer \
    pyyaml \
    ansible-runner \
    simple-term-menu

  mkdir -p ~/.ansible/inventories

  ###################################
  # Configuration ansible
  # Pour le user courant uniquement
  ###################################
  mkdir -p /etc/ansible/inventories/ 1>/dev/null 2>&1
  cat <<EOF >~/.ansible/inventories/local
  [local]
  127.0.0.1 ansible_connection=local
EOF

  cat <<EOF >~/.ansible.cfg
  [defaults]
  command_warnings = False
  callback_whitelist = profile_tasks
  deprecation_warnings=False
  inventory = ~/.ansible/inventories/local
  interpreter_python=/usr/bin/python3
  vault_password_file = ~/.vault_pass
  log_path=${SETTINGS_STORAGE}/logs/ansible.log
EOF

  ##################################################
  # Account.yml
  mkdir -p "${SETTINGS_STORAGE}/logs"
  mkdir -p "${SETTINGS_STORAGE}/app_persos"
  ks_create_dir "${SETTINGS_STORAGE}/app_settings"
  if [ ! -f "${ANSIBLE_VARS}" ]; then
    mkdir -p "${HOME}/.ansible/inventories/group_vars"
    cp "${SETTINGS_SOURCE}/includes/files/account.yml" "${ANSIBLE_VARS}"
  fi

  if [[ -d "${HOME}/.cache" ]]; then
    sudo chown -R "${USER}": "${HOME}/.cache"
  fi
  if [[ -d "${HOME}/.local" ]]; then
    sudo chown -R "${USER}": "${HOME}/.local"
  fi
  if [[ -d "${HOME}/.ansible" ]]; then
    sudo chown -R "${USER}": "${HOME}/.ansible"
  fi

  # on contre le bug de debian et du venv qui ne trouve pas les paquets installés par galaxy
  temppath=$(ls "${VENV_DIR}/lib")
  pythonpath=${VENV_DIR}/lib/${temppath}/site-packages
  export PYTHONPATH=${pythonpath}

  # installation des dépendances
  ks_log_statusbar "Installation des paquets galaxy"
  ansible-galaxy install -r "${SETTINGS_SOURCE}/requirements.yml"

  ks_manage_account_yml settings.storage "${SETTINGS_STORAGE}"
  ks_manage_account_yml settings.source "${SETTINGS_SOURCE}"

  # On vérifie que le user ait bien les droits d'écriture
  ks_make_dir_writable "${SETTINGS_SOURCE}"
  # On crée le conf dir (par défaut /opt/seedbox) s'il n'existe pas
  ks_conf_dir

  # Gestion des IP
  ks_log_statusbar "Stockage des ip publiques"
  ks_stocke_public_ip

  # Logrotate
  ks_log_statusbar "Gestion du logrotate"
  ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/logrotate.yml"

  #  On part à la pêche aux infos....
  ks_log_statusbar "Gestion des infos utilisateur"

  "${SETTINGS_SOURCE}/includes/scripts/get_infos.sh"

  # Installation de k3s
  ks_log_statusbar "Installation de K3S"
  echo "Installation de K3S"
  curl -sfL https://get.k3s.io | sudo sh -
  mkdir -p "${SETTINGS_STORAGE}/k3s"
  sudo cp /etc/rancher/k3s/k3s.yaml "${SETTINGS_STORAGE}/k3s"
  sudo chown "${USER}:" "${SETTINGS_STORAGE}/k3s/k3s.yaml"
  export KUBECONFIG="${SETTINGS_STORAGE}/k3s/k3s.yaml"
  ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/k3s_create_namespace.yml" -e ns=kubeseed

  # Letsencrypt
  ks_log_statusbar "Installation du mode letsencrypt"
  ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/k3s_create_namespace.yml" -e ns=cert-manager
  kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.yaml
  ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/letsencrypt.yml"

  # Création auth basique
  ks_log_statusbar "Création auth basique"
  ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/k3s_create_secret.yml"

  # Dashboard traefik
  ks_log_statusbar "Installation du dashboard Traefik"
  "${SETTINGS_SOURCE}/includes/scripts/install_traefik_dashboard.sh"
  ks_pause

  ks_log_statusbar "Configuration du module letsencrypt avec traefik"
  kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.yaml
  ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/letsencrypt.yml"

  # Installation dashboard
  ks_log_statusbar "Installation du dashboard Kubernetes"
  "${SETTINGS_SOURCE}/includes/scripts/install_dashboard.sh"
  ks_pause

  # Installation rclone
  ks_log_statusbar "Installation/configuration de rclone"
  ks_create_dir "${SETTINGS_STORAGE}/local"
  ks_create_dir "${SETTINGS_STORAGE}/Medias"
  read -rp "Voulez vous utiliser rclone ? [O] : " INSTALL_RCLONE
  INSTALL_RCLONE=${INSTALL_RCLONE:-O}
  if [[ ${INSTALL_RCLONE} == "O" || ${INSTALL_RCLONE} == "o" ]]; then
    ks_manage_account_yml rclone.usage 1
    ks_install_rclone
    ks_log_statusbar "Configuration de mergerfs"
    ks_mergerfs
  else
    ks_manage_account_yml rclone.usage 0
  fi

  # mise en place de la sauvegarde
  ks_log_statusbar "Mise en place de la sauvegarde"
  ks_install_sauvegarde

  # on stocke les patchs pour ne pas les appliquer
  for patch in $(ls ${SETTINGS_SOURCE}/patches); do
    echo "${patch}" >>"${HOME}/.config/kubeseed/patches"
  done

  if [ -f "${SETTINGS_SOURCE}/kickstart" ]; then
    rm -f "${SETTINGS_SOURCE}/kickstart"
  fi

  ks_log_statusbar "Lancement de la première sauvegarde après installation"
  sudo /usr/local/bin/backup
  echo "Une première sauvegarde de l'installation a été faite dans ${SETTINGS_STORAGE}/backup. Si vous souhaitez la conserver, merci de l'archiver"
  ks_pause


  touch "${HOME}/.config/kubeseed/installed"
  ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/install_env_at_start.yml"
  unset_window
  clear
  echo "Installation terminée"
  read -p "Appuyez sur entrée pour continuer, ou ctrl+c pour sortir"
}

function ks_log_write() {
  DATE=$(date +'%F %T')
  FILE="${SETTINGS_STORAGE}/logs/seedbox.log"
  echo "${DATE} - ${1}" >>"${FILE}"
  echo "${1}"
}

function ks_stocke_public_ip() {
  echo "Stockage des adresses ip publiques"
  IPV4=$(curl -4 https://ip4.mn83.fr)
  echo "IPV4 = ${IPV4}"
  ks_manage_account_yml network.ipv4 "${IPV4}"
  IPV6=$(curl -6 https://ip6.mn83.fr)
  if [ $? -eq 0 ]; then
    echo "IPV6 = ${IPV6}"
    ks_manage_account_yml network.ipv6 "a[${IPV6}]"
  else
    echo "Aucune adresse ipv6 trouvée"
  fi
}

function ks_install_environnement() {
  clear
  echo ""
  source "${SETTINGS_SOURCE}/profile.sh"
  ansible-playbook "${SETTINGS_SOURCE}/includes/config/roles/user_environment/tasks/main.yml"
  echo "Pour bénéficer des changements, vous devez vous déconnecter/reconnecter"
  ks_pause
}

set_window() {
  LINES=$(tput lines)
  COLS=$(tput cols)

  # Create a virtual window that is two lines smaller at the bottom.
  tput csr 0 $(($LINES - 3))
}

unset_window() {
  LINES=$(tput lines)
  COLS=$(tput cols)

  tput csr 0 $(($LINES))
}

ks_log_statusbar() {
  COLS=$(tput cols)
  # si en debug
  if [ -n "$KS_DEBUG" ]; then
    echo "###### MODE DEBUG ######"
    ks_pause
  fi
  clear
  set_window
  # Move cursor to last line in your screen
  tput cup $(($LINES - 2)) 0
  for ((i = 0; i <= ${COLS}; i++)); do
    echo -n "="
  done
  echo -e "\n"
  echo -en "===== $1 ====="

  # Move cursor to home position, back in virtual window
  tput cup 0 0
}

function ks_choix_appli_lance() {
  python3 "${SETTINGS_SOURCE}/includes/scripts/generique_python.py" choix_appli_lance
}

function ks_restart_deployment() {
  kubectl rollout restart deployment "${1}" -n kubeseed
}

function ks_delete_deployment() {
  kubectl -n kubeseed delete deployment,service,ingress -l ksapp="${1}"
  ks_manage_account_yml "applis.${1}" " "
}

function ks_reinit_deployment() {
  ks_manage_account_yml "applis.${1}" " "
  ks_launch_service "${1}"
}

function ks_generate_dashboard_token() {
  kubectl -n kubernetes-dashboard create token admin-user
}

function ks_get_and_store_info() {
  # Get and store the info for all.yml
  # $1 = the key in all.yml
  # $2 = Text (one line)
  # $3 = The var to look for if set (if UNCHECK, do not use)
  # $4 (optional) = default value
  my_key=$1
  my_text=$2
  my_var=$3
  complement=""
  if [ $# -eq 4 ]; then
    complement=" [${4}] "
  fi
  TEMP_VAR=$(ks_get_from_account_yml "${my_key}")
  if [ "${TEMP_VAR}" == notfound ]; then
    if [ "${my_var}" != "UNCHECK" ]; then
      if [ -n "${!my_var}" ]; then
        echo -e "${my_key} déjà renseigné dans le fichier kickstart (variable ${my_var} )"
        my_value=${!my_var}
      else
        read -rp "${my_text} ${complement}: " my_value </dev/tty
      fi
    else
      read -rp "${my_text} ${complement}: " my_value </dev/tty
    fi
    # test if variable par défaut passée
    if [ $# -eq 4 ]; then
      if [ -z "${my_value}" ]; then
        my_value="${4}"
      fi
    fi
    ks_manage_account_yml "${my_key}" "${my_value}"
  else
    echo -e "${BLUE}${my_key} déjà renseigné dans all.yml${CEND}"
  fi
}

function ks_cloudplow_upload() {
  kubectl -n kubeseed exec --stdin --tty $(kubectl get pods -n kubeseed | grep cloudplow | grep Running | awk '{print $1}') -- cloudplow upload
}

function apply_patches() {
  touch "${HOME}/.config/kubeseed/patches"
  for patch in $(ls ${SETTINGS_SOURCE}/patches); do
    if grep -q "${patch}" "${HOME}/.config/kubeseed/patches"; then
      # parch déjà appliqué, on ne fait rien
      :
    else
      # on applique le patch
      bash "${SETTINGS_SOURCE}/patches/${patch}"
      echo "${patch}" >>"${HOME}/.config/kubeseed/patches"
    fi
  done
}

function ks_install_helm() {
  curl -fsSL -o /tmp/get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
  chmod 755 /tmp/get_helm.sh
  bash /tmp/get_helm.sh
}

function ks_install_prometheus() {
  echo "#########################################################"
  echo "# Prometheus"
  echo "# Prometheus va être installé et récolter les metriques"
  echo "# pour le cluster Kubernetes automatiquement "
  echo "#########################################################"
  ks_pause
  ks_install_helm
  helm repo add prometheus https://prometheus-community.github.io/helm-charts
  help repo update
  ks_get_and_store_info "applis.prometheus.subdomain" "Sous domaine pour prometheus" UNCHECK "prometheus"
  ks_get_and_store_info "applis.prometheus.auth" "Authentification prometheus - 1 => basique (défaut) | 2 => oauth | 3 => aucune" UNCHECK 1
  ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/install_prometheus.yml"
}

function ks_get_system_info() {
  domain=$(ks_get_from_account_yml user.domain)
  ipv4=$(ks_get_from_account_yml network.ipv4)
  ipv6=$(ks_get_from_account_yml network.ipv6)
  kubectl version | sed "s/${domain}/**masked domain**/g" | sed "s/${ipv4}/**masked ipv4**/g" | sed "s/${ipv6}/**masked ipv6**/g"
  k3s --version | sed "s/${domain}/**masked domain**/g" | sed "s/${ipv4}/**masked ipv4**/g" | sed "s/${ipv6}/**masked ipv6**/g"
  kubectl describe node $(kubectl get nodes | grep -v NAME | awk '{print $1}') | sed "s/${domain}/**masked domain**/g" | sed "s/${ipv4}/**masked ipv4**/g" | sed "s/${ipv6}/**masked ipv6**/g"
  kubectl get pods -A | sed "s/${domain}/**masked domain**/g" | sed "s/${ipv4}/**masked ipv4**/g" | sed "s/${ipv6}/**masked ipv6**/g"
  kubectl get deployments -A | sed "s/${domain}/**masked domain**/g" | sed "s/${ipv4}/**masked ipv4**/g" | sed "s/${ipv6}/**masked ipv6**/g"
  kubectl get ing -A | sed "s/${domain}/**masked domain**/g" | sed "s/${ipv4}/**masked ipv4**/g" | sed "s/${ipv6}/**masked ipv6**/g"
}

function ks_generate_translation() {
  for f in ${SETTINGS_SOURCE}/i18n/*.po; do
    [[ -e "$f" ]] || break # handle the case of no *.po files
    temp=$(basename $f)
    short="${temp:0:2}"
    mkdir -p "i18n/${short}/LC_MESSAGES"
    msgfmt -o "${SETTINGS_SOURCE}/i18n/${short}/LC_MESSAGES/ks.mo" "${SETTINGS_SOURCE}/i18n/${short}.po"
    echo "$(gettext "Generation") ${short} $(gettext "terminée")"
  done
  echo " == $(gettext "Génération des traductions terminées") =="
}

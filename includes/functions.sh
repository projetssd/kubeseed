#!/bin/bash
##########

function ks_logo() {

  color1='\033[1;31m' # Bold RED
  color2='\033[1;35m' # Bold PURPLE
  color3='\033[0;33m' # Regular YELLOW
  nocolor='\033[0m'   # no color
  colorp='\033[1;34m' # Bold BLUE
  colora='\033[1;32m' # Bold GREEN
  projetname='SSD - V3'
  authors='Authors: Merrick'

  printf " \n"
  printf " ${color1}███████╗ ${color2}███████╗ ${color3}██████╗  ${colorp}${projetname}${nocolor}\n"
  printf " ${color1}██╔════╝ ${color2}██╔════╝ ${color3}██╔══██╗ ${colora}${authors}${nocolor}\n"
  printf " ${color1}███████╗ ${color2}███████╗ ${color3}██║  ██║ ${nocolor}\n"
  printf " ${color1}╚════██║ ${color2}╚════██║ ${color3}██║  ██║ $(uname -srmo)${nocolor}\n"
  printf " ${color1}███████║ ${color2}███████║ ${color3}██████╔╝ $(lsb_release -sd)${nocolor}\n"
  printf " ${color1}╚══════╝ ${color2}╚══════╝ ${color3}╚═════╝  ${nocolor}Uptime: $(/usr/bin/uptime -p)${nocolor}\n"
  printf " \n"

}



function ks_get_cloudflare_infos() {
  #####################################
  # Récupère les infos de cloudflare
  # Pour utilisation ultérieure
  ######################################
  echo -e "${BLUE}### Gestion des DNS ###${NC}"
  echo ""
  echo -e "${CCYAN}------------------------------------------------------------------${CEND}"
  echo -e "${CCYAN}   CloudFlare protège et accélère les sites internet.             ${CEND}"
  echo -e "${CCYAN}   CloudFlare optimise automatiquement la déliverabilité          ${CEND}"
  echo -e "${CCYAN}   de vos pages web afin de diminuer le temps de chargement       ${CEND}"
  echo -e "${CCYAN}   et d’améliorer les performances. CloudFlare bloque aussi       ${CEND}"
  echo -e "${CCYAN}   les menaces et empêche certains robots illégitimes de          ${CEND}"
  echo -e "${CCYAN}   consommer votre bande passante et les ressources serveur.      ${CEND}"
  echo -e "${CCYAN}------------------------------------------------------------------${CEND}"
  echo ""
  read -rp $'\e[33mSouhaitez vous utiliser les DNS Cloudflare ? (o/n)\e[0m :' OUI

  if [[ "$OUI" == "o" ]] || [[ "$OUI" == "O" ]]; then

    if [ -z "$cloud_email" ] || [ -z "$cloud_api" ]; then
      cloud_email=$1
      cloud_api=$2
    fi

    while [ -z "$cloud_email" ]; do
      echo >&2 -n -e "${BWHITE}Votre Email Cloudflare: ${CEND}"
      read cloud_email
      ks_manage_account_yml cloudflare.login "$cloud_email"
      update_seedbox_param "cf_login" $cloud_email
    done

    while [ -z "$cloud_api" ]; do
      echo >&2 -n -e "${BWHITE}Votre API Cloudflare: ${CEND}"
      read cloud_api
      ks_manage_account_yml cloudflare.api "$cloud_api"
    done
  fi
  echo ""
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
  echo -e "${CRED}    https://github.com/laster13/patxav/wiki /!\ 		   ${CEND}"
  echo -e "${CRED}-------------------------------------------------------------------${CEND}"
  echo ""
  read -rp $'\e[33mSouhaitez vous sécuriser vos Applis avec Google OAuth2 ? (o/n)\e[0m :' OUI

  if [[ "$OUI" == "o" ]] || [[ "$OUI" == "O" ]]; then
    if [ -z "$oauth_client" ] || [ -z "$oauth_secret" ] || [ -z "$email" ]; then
      oauth_client=$1
      oauth_secret=$2
      email=$3
    fi

    while [ -z "$oauth_client" ]; do
      echo >&2 -n -e "${BWHITE}Oauth_client: ${CEND}"
      read oauth_client
      ks_manage_account_yml oauth.client "$oauth_client"
    done

    while [ -z "$oauth_secret" ]; do
      echo >&2 -n -e "${BWHITE}Oauth_secret: ${CEND}"
      read oauth_secret
      ks_manage_account_yml oauth.secret "$oauth_secret"
    done

    while [ -z "$email" ]; do
      echo >&2 -n -e "${BWHITE}Compte Gmail utilisé(s), séparés d'une virgule si plusieurs: ${CEND}"
      read email
      ks_manage_account_yml oauth.account "$email"
    done

    openssl=$(openssl rand -hex 16)
    ks_manage_account_yml oauth.openssl "$openssl"

    echo ""
    echo -e "${CRED}---------------------------------------------------------------${CEND}"
    echo -e "${CCYAN}    IMPORTANT:	Avant la 1ere connexion			       ${CEND}"
    echo -e "${CCYAN}    		- Nettoyer l'historique de votre navigateur    ${CEND}"
    echo -e "${CCYAN}    		- déconnection de tout compte google	       ${CEND}"
    echo -e "${CRED}---------------------------------------------------------------${CEND}"
    echo ""
    echo -e "\nAppuyer sur ${CCYAN}[ENTREE]${CEND} pour continuer..."
    read -r
  fi

  echo ""
}

function ks_install_rtorrent_cleaner() {
  #configuration de rtorrent-cleaner avec ansible
  echo -e "${BLUE}### RTORRENT-CLEANER ###${NC}"
  echo ""
  echo -e " ${BWHITE}* Installation RTORRENT-CLEANER${NC}"

  ## choix de l'utilisateur
  #SEEDUSER=$(ls ${SETTINGS_STORAGE}/media* | cut -d '-' -f2)
  sudo cp -r ${SETTINGS_SOURCE}/includes/config/rtorrent-cleaner/rtorrent-cleaner /usr/local/bin
  sudo sed -i "s|%SEEDUSER%|${USER}|g" /usr/local/bin/rtorrent-cleaner
  sudo sed -i "s|%SETTINGS_STORAGE%|${SETTINGS_STORAGE}|g" /usr/local/bin/rtorrent-cleaner
}

function ks_install_sauvegarde() {
  #configuration Sauvegarde
  echo -e "${BLUE}### BACKUP ###${NC}"
  echo -e " ${BWHITE}* Mise en place Sauvegarde${NC}"
  ansible-playbook ${SETTINGS_SOURCE}/includes/config/roles/backup/tasks/main.yml
  checking_errors $?
  echo ""
}

function ks_debug() {
  echo "### DEBUG ${1}"
  pause
}

function ks_install_plex_dupefinder() {
  #configuration plex_dupefinder avec ansible
  echo -e "${BLUE}### PLEX_DUPEFINDER ###${NC}"
  echo -e " ${BWHITE}* Installation plex_dupefinder${NC}"
  ansible-playbook ${SETTINGS_SOURCE}/includes/config/roles/plex_dupefinder/tasks/main.yml
  checking_errors $?
}

function ks_install_traktarr() {
  ##configuration traktarr avec ansible
  echo -e "${BLUE}### TRAKTARR ###${NC}"
  echo -e " ${BWHITE}* Installation traktarr${NC}"
  ansible-playbook ${SETTINGS_SOURCE}/includes/config/roles/traktarr/tasks/main.yml
  checking_errors $?
}

function ks_update_logrotate() {
  ansible-playbook ${SETTINGS_SOURCE}/includes/config/playbooks/logrotate.yml
}

function ks_install_autoscan() {
  #configuration autoscan avec ansible
  echo -e "${BLUE}### AUTOSCAN ###${NC}"
  echo -e " ${BWHITE}* Installation autoscan${NC}"
  ansible-playbook ${SETTINGS_SOURCE}/includes/config/roles/autoscan/tasks/main.yml
  checking_errors $?
}

function ks_install_cloudplow() {
  #configuration plex_autoscan avec ansible
  echo -e "${BLUE}### CLOUDPLOW ###${NC}"
  echo -e " ${BWHITE}* Installation cloudplow${NC}"
  ansible-playbook ${SETTINGS_SOURCE}/includes/config/roles/cloudplow/tasks/main.yml
  sudo chown -R ${USER} ${HOME}/scripts/cloudplow
  checking_errors $?
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

function ks_install_watchtower() {
  echo -e "${BLUE}### WATCHTOWER ###${NC}"
  echo -e " ${BWHITE}* Installation Watchtower${NC}"
  ansible-playbook ${SETTINGS_SOURCE}/includes/dockerapps/watchtower.yml
  ks_checking_errors $?
  echo ""
}

function ks_install_rclone() {
  echo -e "${BLUE}### RCLONE ###${NC}"
  fusermount -uz /mnt/rclone >>/dev/null 2>&1
  ks_create_dir /mnt/rclone
  ks_create_dir /mnt/rclone/${USER}
  ${SETTINGS_SOURCE}/includes/config/scripts/rclone.sh
  ansible-playbook ${SETTINGS_SOURCE}/includes/config/roles/rclone/tasks/main.yml
  ks_checking_errors $?
  echo ""
}

function ks_unionfs_fuse() {
  echo -e "${BLUE}### Unionfs-Fuse ###${NC}"
  echo -e " ${BWHITE}* Installation Mergerfs${NC}"
  ansible-playbook ${SETTINGS_SOURCE}/includes/config/roles/unionfs/tasks/main.yml
  ks_checking_errors $?
  echo ""
}

function ks_subdomain_unitaire() {
  line=$1
  echo ""
  read -rp $'\e\033[1;37m --> Personnaliser le sous domaines pour '${line}' : (o/N) ? ' OUI
  echo ""
  if [[ "$OUI" == "o" ]] || [[ "$OUI" == "O" ]]; then
    echo -e " ${CRED}--> NE PAS SAISIR LE NOM DE DOMAINE - LES POINTS NE SONT PAS ACCEPTES${NC}"
    echo ""

    read -rp $'\e[32m* Sous domaine pour\e[0m '${line}': ' SUBDOMAIN

  else
    SUBDOMAIN=${line}
  fi
  ks_manage_account_yml sub.${line}.${line} $SUBDOMAIN
}

function ks_auth_unitaire() {
  line=$1
  echo ""

  read -rp $'\e\033[1;37m --> Authentification '${line}' [ Enter ] 1 => basique (défaut) | 2 => oauth | 3 => authelia | 4 => aucune: ' AUTH

  case $AUTH in
  1)
    TYPE_AUTH=basique
    ;;

  2)
    TYPE_AUTH=oauth
    ;;

  3)
    TYPE_AUTH=authelia

    ;;

  4)
    TYPE_AUTH=aucune
    ;;

  *)
    TYPE_AUTH=basique
    echo "Pas de choix sélectionné, on passe sur une auth basique"

    ;;
  esac

  ks_manage_account_yml sub.${line}.auth ${TYPE_AUTH}

}

function ks_define_parameters() {
  echo -e "${BLUE}### INFORMATIONS UTILISATEURS ###${NC}"

  create_user
  CONTACTEMAIL=$(
    whiptail --title "Adresse Email" --inputbox \
      "Merci de taper votre adresse Email :" 7 50 3>&1 1>&2 2>&3
  )
  ks_manage_account_yml user.mail $CONTACTEMAIL

  DOMAIN=$(
    whiptail --title "Votre nom de Domaine" --inputbox \
      "Merci de taper votre nom de Domaine (exemple: nomdedomaine.fr) :" 7 50 3>&1 1>&2 2>&3
  )
  ks_manage_account_yml user.domain $DOMAIN
  echo ""
}

function ks_create_user_non_systeme() {
  # nouvelle version de define_parameters()
  echo -e "${BLUE}### INFORMATIONS UTILISATEURS ###${NC}"

  #  SEEDUSER=$(whiptail --title "Administrateur" --inputbox \
  #    "Nom d'Administrateur de la Seedbox :" 7 50 3>&1 1>&2 2>&3)
  #  [[ "$?" == 1 ]] && script_plexdrive
  PASSWORD=$(
    whiptail --title "Password" --passwordbox \
      "Mot de passe :" 7 50 3>&1 1>&2 2>&3
  )

  ks_manage_account_yml user.htpwd $(htpasswd -nb ${USER} $PASSWORD)
  ks_manage_account_yml user.name ${USER}
  ks_manage_account_yml user.pass $PASSWORD
  ks_manage_account_yml user.userid $(id -u)
  ks_manage_account_yml user.groupid $(id -g)

  update_seedbox_param "name" "${user}"
  update_seedbox_param "userid" "$(id -u)"
  update_seedbox_param "groupid" "$(id -g)"
  update_seedbox_param "htpwd" "${htpwd}"

  CONTACTEMAIL=$(
    whiptail --title "Adresse Email" --inputbox \
      "Merci de taper votre adresse Email :" 7 50 3>&1 1>&2 2>&3
  )
  ks_manage_account_yml user.mail "${CONTACTEMAIL}"
  update_seedbox_param "mail" "${CONTACTEMAIL}"

  DOMAIN=$(
    whiptail --title "Votre nom de Domaine" --inputbox \
      "Merci de taper votre nom de Domaine (exemple: nomdedomaine.fr) :" 7 50 3>&1 1>&2 2>&3
  )
  ks_manage_account_yml user.domain "${DOMAIN}"
  update_seedbox_param "domain" "${DOMAIN}"
  echo ""
  return
}

function ks_choose_services() {
  echo -e "${BLUE}### SERVICES ###${NC}"
  echo "DEBUG ${SERVICESAVAILABLE}"
  echo -e " ${BWHITE}--> Services en cours d'installation : ${NC}"
  rm -Rf "${SERVICESPERUSER}" >/dev/null 2>&1
  menuservices="/tmp/menuservices.txt"
  if [[ -e "${menuservices}" ]]; then
    rm "${menuservices}"
  fi

  for app in $(cat ${SERVICESAVAILABLE}); do
    service=$(echo ${app} | cut -d\- -f1)
    desc=$(echo ${app} | cut -d\- -f2)
    echo "${service} ${desc} off" >>/tmp/menuservices.txt
  done
  SERVICESTOINSTALL=$(
    whiptail --title "Gestion des Applications" --checklist \
      "Appuyer sur la barre espace pour la sélection" 28 64 21 \
      $(cat /tmp/menuservices.txt) 3>&1 1>&2 2>&3
  )
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
    rm /tmp/menuservices.txt
    touch $SERVICESPERUSER
    for APPDOCKER in $SERVICESTOINSTALL; do
      echo -e "	${GREEN}* $(echo $APPDOCKER | tr -d '"')${NC}"
      echo $(echo ${APPDOCKER,,} | tr -d '"') >>"${SERVICESPERUSER}"
    done
  else
    return
  fi
}

function ks_choose_other_services() {
  echo -e "${BLUE}### SERVICES ###${NC}"
  echo -e " ${BWHITE}--> Services en cours d'installation : ${NC}"
  rm -Rf "${SERVICESPERUSER}" >/dev/null 2>&1
  menuservices="/tmp/menuservices.txt"
  if [[ -e "${menuservices}" ]]; then
    rm /tmp/menuservices.txt
  fi

  for app in $(cat "${SETTINGS_SOURCE}/includes/config/other-services-available"); do
    service=$(echo "${app}" | cut -d\- -f1)
    desc=$(echo "${app}" | cut -d\- -f2)
    echo "${service} ${desc} off" >>/tmp/menuservices.txt
  done
  SERVICESTOINSTALL=$(
    whiptail --title "Gestion des Applications" --checklist \
      "Appuyer sur la barre espace pour la sélection" 28 64 21 \
      $(cat /tmp/menuservices.txt) 3>&1 1>&2 2>&3
  )
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
    rm /tmp/menuservices.txt
    touch "${SERVICESPERUSER}"
    for APPDOCKER in $SERVICESTOINSTALL; do
      echo -e "	${GREEN}* $(echo "${APPDOCKER}" | tr -d '"')${NC}"
      echo $(echo "${APPDOCKER,,}" | tr -d '"') >>"${SERVICESPERUSER}"
    done
  else
    return
  fi
}

function ks_choose_media_folder_classique() {
  echo -e "${BLUE}### DOSSIERS MEDIAS ###${NC}"
  echo -e " ${BWHITE}--> Création des dossiers Medias : ${NC}"
  mkdir -p "${HOME}/filebot"
  mkdir -p "${HOME}/local/{Films,Series,Musiques,Animes}"
  ks_checking_errors $?
  echo ""
}

function ks_install_services() {
  if [ -f "$SERVICESPERUSER" ]; then

    if [[ ! -d "${SETTINGS_STORAGE}/conf" ]]; then
      mkdir -p "${SETTINGS_STORAGE}/conf" >/dev/null 2>&1
    fi

    if [[ ! -d "${SETTINGS_STORAGE}/vars" ]]; then
      mkdir -p "${SETTINGS_STORAGE}/vars" >/dev/null 2>&1
    fi

    ks_create_file "${SETTINGS_STORAGE}/temp.txt"

    ## préparation installation
    #for line in $(grep -l 2 ${SETTINGS_STORAGE}/status/*); do
    #  basename=$(basename "${line}")
    #  launch_service "${basename}"
    #done

    for line in $(cat $SERVICESPERUSER); do
      launch_service "${line}"
    done
  fi
}

function ks_launch_service() {

  line=$1

  log_write "Installation de ${line}"
  error=0
  tempsubdomain=$(ks_get_from_account_yml sub.${line}.${line})
  if [ "${tempsubdomain}" = notfound ]; then
    ks_subdomain_unitaire ${line}
  fi
  tempauth=$(ks_get_from_account_yml sub.${line}.auth)
  if [ "${tempauth}" = notfound ]; then
    ks_auth_unitaire ${line}
  fi

  if [[ "${line}" == "plex" ]]; then
    echo ""
    echo -e "${BLUE}### CONFIG POST COMPOSE PLEX ###${NC}"
    echo -e " ${BWHITE}* Processing plex config file...${NC}"
    echo ""
    echo -e " ${GREEN}ATTENTION IMPORTANT - NE PAS FAIRE D'ERREUR - SINON DESINSTALLER ET REINSTALLER${NC}"
    "${SETTINGS_SOURCE}/includes/config/roles/plex_autoscan/plex_token.sh"

    choose_media_folder_plexdrive
    if [[ -f "${SETTINGS_STORAGE}/conf/plex.yml" ]]; then
      :
    else
      cp "${SETTINGS_SOURCE}/includes/dockerapps/plex.yml" "${SETTINGS_STORAGE}/conf/plex.yml" >/dev/null 2>&1
    fi
    ansible-playbook "${SETTINGS_STORAGE}/conf/plex.yml"
    echo "2" >"${SETTINGS_STORAGE}/status/plex"
  else
    # On est dans le cas générique
    # on regarde s'i y a un playbook existant

    if [[ -f "${SETTINGS_STORAGE}/conf/${line}.yml" ]]; then
      # il y a déjà un playbook "perso", on le lance
      ansible-playbook "${SETTINGS_STORAGE}/conf/${line}.yml"
    elif [[ -f "${SETTINGS_STORAGE}/vars/${line}.yml" ]]; then
      # il y a des variables persos, on les lance
      ansible-playbook "${SETTINGS_SOURCE}/includes/dockerapps/generique.yml" --extra-vars "@${SETTINGS_STORAGE}/vars/${line}.yml"

    elif [[ -f "${SETTINGS_SOURCE}/includes/dockerapps/${line}.yml" ]]; then
      # pas de playbook perso ni de vars perso
      # puis on le lance
      ansible-playbook "${SETTINGS_SOURCE}/includes/dockerapps/${line}.yml"
    elif [[ -f "${SETTINGS_SOURCE}/includes/dockerapps/vars/${line}.yml" ]]; then
      # puis on lance le générique avec ce qu'on vient de copier
      ansible-playbook "${SETTINGS_SOURCE}/includes/dockerapps/generique.yml" --extra-vars "@${SETTINGS_SOURCE}/includes/dockerapps/vars/${line}.yml"
    else
      log_write "Aucun fichier de configuration trouvé dans les sources, abandon"
      error=1
    fi
  fi
  if [ ${error} = 0 ]; then
    temp_subdomain=$(ks_get_from_account_yml "sub.${line}.${line}")
    DOMAIN=$(ks_get_from_account_yml user.domain)
    echo "2" >"${SETTINGS_STORAGE}/status/${line}"

    FQDNTMP="${temp_subdomain}.$DOMAIN"

  fi
  FQDNTMP=""
}

function ks_copie_yml() {
  echo "#########################################################"
  echo "# ATTENTION                                             #"
  echo "# Cette fonction va copier les fichiers yml choisis     #"
  echo "# Afin de pouvoir les personnaliser                     #"
  echo "# Mais ne lancera pas les services associés             #"
  echo "#########################################################"
  ks_choose_services
  for line in $(cat $SERVICESPERUSER); do
    copie_yml_unit "${line}"
  done
  ks_choose_other_services
  for line in $(cat $SERVICESPERUSER); do
    copie_yml_unit "${line}"
  done
}

function copie_yml_unit() {

  if [[ -f "${SETTINGS_SOURCE}/includes/dockerapps/${line}.yml" ]]; then
    # Il y a un playbook spécifique pour cette appli, on le copie
    cp "${SETTINGS_SOURCE}/includes/dockerapps/${line}.yml" "${SETTINGS_STORAGE}/conf/${line}.yml"
  elif [[ -f "${SETTINGS_SOURCE}/includes/dockerapps/vars/${line}.yml" ]]; then
    # on copie les variables pour le user
    cp "${SETTINGS_SOURCE}/includes/dockerapps/vars/${line}.yml" "${SETTINGS_STORAGE}/vars/${line}.yml"
  else
    log_write "Aucun fichier de configuration trouvé dans les sources, abandon"
  fi
}

function ks_manage_apps() {
  echo -e "${BLUE}##########################################${NC}"
  echo -e "${BLUE}###          GESTION DES APPLIS        ###${NC}"
  echo -e "${BLUE}##########################################${NC}"

  ansible-playbook ${SETTINGS_SOURCE}/includes/dockerapps/templates/ansible/ansible.yml

}

function ks_suppression_appli() {

  sousdomaine=$(ks_get_from_account_yml sub.${APPSELECTED}.${APPSELECTED})
  domaine=$(ks_get_from_account_yml user.domain)

  APPSELECTED=$1
  DELETE=0
  if [[ $# -eq 2 ]]; then
    if [ "$2" = "1" ]; then
      DELETE=1
    fi
  fi
  ks_manage_account_yml sub.${APPSELECTED} " "

  docker rm -f "$APPSELECTED" >/dev/null 2>&1
  if [ $DELETE -eq 1 ]; then
    log_write "Suppresion de ${APPSELECTED}, données supprimées"
    sudo rm -rf ${SETTINGS_STORAGE}/docker/${USER}/$APPSELECTED
  else
    log_write "Suppresion de ${APPSELECTED}, données conservées"
  fi

  rm ${SETTINGS_STORAGE}/conf/$APPSELECTED.yml >/dev/null 2>&1
  rm ${SETTINGS_STORAGE}/vars/$APPSELECTED.yml >/dev/null 2>&1
  echo "0" >${SETTINGS_STORAGE}/status/$APPSELECTED

  case $APPSELECTED in
  seafile)
    docker rm -f memcached >/dev/null 2>&1
    ;;
  varken)
    docker rm -f influxdb telegraf grafana >/dev/null 2>&1
    if [ $DELETE -eq 1 ]; then
      sudo rm -rf ${SETTINGS_STORAGE}/docker/${USER}/telegraf
      sudo rm -rf ${SETTINGS_STORAGE}/docker/${USER}/grafana
      sudo rm -rf ${SETTINGS_STORAGE}/docker/${USER}/influxdb
    fi
    ;;
  jitsi)
    docker rm -f prosody jicofo jvb
    rm -rf ${SETTINGS_STORAGE}/docker/${USER}/.jitsi-meet-cfg
    ;;
  nextcloud)
    docker rm -f collabora coturn office
    rm -rf ${SETTINGS_STORAGE}/docker/${USER}/coturn
    ;;
  rtorrentvpn)
    rm ${SETTINGS_STORAGE}/conf/rutorrent-vpn.yml
    ;;
  jackett)
    docker rm -f flaresolverr >/dev/null 2>&1
    ;;
  petio)
    docker rm -f mongo >/dev/null 2>&1
    ;;
  vinkunja)
    docker rm -f vikunja-api >/dev/null 2>&1
    ;;
  esac

  if docker ps | grep -q db-$APPSELECTED; then
    docker rm -f db-$APPSELECTED >/dev/null 2>&1
  fi

  if docker ps | grep -q redis-$APPSELECTED; then
    docker rm -f redis-$APPSELECTED >/dev/null 2>&1
  fi

  if docker ps | grep -q memcached-$APPSELECTED; then
    docker rm -f memcached-$APPSELECTED >/dev/null 2>&1
  fi

  ks_checking_errors $?

  ansible-playbook -e pgrole=${APPSELECTED} ${SETTINGS_SOURCE}/includes/config/playbooks/remove_cf_record.yml

  echo""
  echo -e "${BLUE}### $APPSELECTED a été supprimé ###${NC}"
  echo ""

  req1="delete from applications where name='"
  req2="'"
  req=${req1}${APPSELECTED}${req2}
  sqlite3 ${SETTINGS_SOURCE}/kubeseeddb <<EOF
$req

EOF

}

function ks_pause() {
  echo ""
  echo -e "${YELLOW}###  -->APPUYER SUR ENTREE POUR CONTINUER<--  ###${NC}"
  read
  echo ""
}

ks_select_seedbox_param() {
  if [ ! -f ${SETTINGS_SOURCE}/kubeseeddb ]; then
    # le fichier de base de données n'est pas là
    # on sort avant de faire une requête, sinon il va se créer
    # et les tests ne seront pas bons
    return 0
  fi
  request="select value from seedbox_params where param ='"${1}"'"
  RETURN=$(sqlite3 ${SETTINGS_SOURCE}/kubeseeddb "${request}")
  if [ $? != 0 ]; then
    echo 0
  else
    echo $RETURN
  fi

}

function ks_update_seedbox_param() {
  # shellcheck disable=SC2027
  request="replace into seedbox_params (param,value) values ('"${1}"','"${2}"')"
  sqlite3 "${SETTINGS_SOURCE}/kubeseeddb" "${request}"
}

function ks_manage_account_yml() {
  # usage
  # ks_manage_account_yml key value
  # key séparées par des points (par exemple user.name ou sub.application.subdomain)
  # pour supprimer une clé, il faut que le value soit égale à un espace
  # ex : ks_manage_account_yml sub.toto.toto toto => va créer la clé sub.toto.toto et lui mettre à la valeur toto
  # ex : ks_manage_account_yml sub.toto.toto " " => va supprimer la clé sub.toto.toto et toutes les sous clés
  if [ -f ${SETTINGS_STORAGE}/.account.lock ]; then
    echo "Fichier account locké, impossible de continuer"
    echo "----------------------------------------------"
    echo "Présence du fichier ${SETTINGS_STORAGE}/.account.lock"
    exit 1
  else
    touch ${SETTINGS_STORAGE}/.account.lock
    ansible-vault decrypt "${ANSIBLE_VARS}" >/dev/null 2>&1
    if [ "${2}" = " " ]; then
      ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/manage_account_yml.yml" -e "account_key=${1} account_value=${2}  state=absent"
    else
      ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/manage_account_yml.yml" -e "account_key=${1} account_value=${2} state=present"
    fi
    ansible-vault encrypt "${ANSIBLE_VARS}l" >/dev/null 2>&1
    rm -f ${SETTINGS_STORAGE}/.account.lock
  fi
}

function ks_get_from_account_yml() {
  tempresult=$(ansible-playbook ${SETTINGS_SOURCE}/includes/playbooks/get_var.yml -e myvar=$1 -e tempfile=${tempfile} | grep "##RESULT##" | awk -F'##RESULT##' '{print $2}' | xargs)
  if [ -z "$tempresult" ]; then
    tempresult=notfound
  fi
  echo $tempresult
}

function ks_install() {

  sudo chown -R ${USER}: ${SETTINGS_SOURCE}/

  # mise en place du sudo sans password
  if [ ! -f /etc/sudoers.d/${USER} ]; then
    echo "${USER} ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/${USER}
  fi

  echo "Certains composants doivent encore être installés/réglés"
  echo "Cette opération va prendre plusieurs minutes selon votre système "
  echo "=================================================================="
  read -p "Appuyez sur entrée pour continuer, ou ctrl+c pour sortir"
  echo "=================================================================="
  echo "Installation des paquets systeme"

  sudo apt update

  sudo apt-get install -y --reinstall \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3-dev \
    python3-pip \
    python-dev \
    python3-venv \
    sqlite3 \
    apache2-utils \
    dnsutils \
    python3-apt-dbg \
    python3-apt \
    python-apt-doc \
    python-apt-common \
    ca-certificates \
    curl \
    gnupg \
    software-properties-common \
    apt-transport-https \
    lsb-release

  sudo rm -f /usr/bin/python

  sudo ln -s /usr/bin/python3 /usr/bin/python

  cat <<EOF >/etc/logrotate.d/ansible
${SETTINGS_SOURCE}/logs/*.log {
  rotate 7
  daily
  compress
  missingok
}
EOF

  # création d'un vault_pass vide

  if [ ! -f "${HOME}/.vault_pass" ]; then
    mypass=$(
      tr -dc A-Za-z0-9 </dev/urandom | head -c 25
      echo ''
    )
    echo "$mypass" >"${HOME}/.vault_pass"
  fi

  # création d'un virtualenv
  echo "=================================================================="
  echo "Création du virtualenv"
  mkdir -p "${VENV_DIR}"
  python3 -m venv "${SETTINGS_STORAGE}/venv/ks"

  # activation du venv
  source "${VENV_DIR}/bin/activate"

  temppath=$(ls ${VENV_DIR}/lib)
  pythonpath=${VENV_DIR}/lib/${temppath}/site-packages
  export PYTHONPATH=${pythonpath}

  echo "=================================================================="
  echo "Installation des paquets python"
  ## Constants
  python3 -m pip install --disable-pip-version-check --upgrade --force-reinstall pip
  pip install wheel
  pip install ansible \
    docker \
    shyaml \
    netaddr \
    dnspython \
    configparser

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

  echo "Création de la configuration en cours"
  # On créé la database
  sqlite3 "${SETTINGS_SOURCE}/kubeseeddb" <<EOF
    create table seedbox_params(param varchar(50) PRIMARY KEY, value varchar(50));
    replace into seedbox_params (param,value) values ('installed',0);
    create table applications(name varchar(50) PRIMARY KEY,
      status integer,
      subdomain varchar(50),
      port integer);
    create table applications_params (appname varchar(50),
      param varachar(50),
      value varchar(50),
      FOREIGN KEY(appname) REFERENCES applications(name));
EOF

  ##################################################
  # Account.yml
  mkdir -p "${SETTINGS_STORAGE}/logs"
  ks_create_dir "${SETTINGS_STORAGE}"
  ks_create_dir "${SETTINGS_STORAGE}/variables"
  ks_create_dir "${SETTINGS_STORAGE}/conf"
  ks_create_dir "${SETTINGS_STORAGE}/vars"
  if [ ! -f "${ANSIBLE_VARS}" ]; then
    mkdir -p "${HOME}/.ansible/inventories/group_vars"
    cp "${SETTINGS_SOURCE}/includes/config/account.yml" "${ANSIBLE_VARS}"
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

  touch "${SETTINGS_SOURCE}/.prerequis.lock"

    source "${VENV_DIR}/bin/activate"
  # on contre le bug de debian et du venv qui ne trouve pas les paquets installés par galaxy
  temppath=$(ls ${VENV_DIR}/lib)
  pythonpath=${VENV_DIR}/lib/${temppath}/site-packages
  export PYTHONPATH=${pythonpath}
  # toutes les installs communes
  # installation des dépendances, permet de créer les docker network via ansible
  ansible-galaxy collection install community.general
  #ansible-galaxy collection install community.docker
  # dépendence permettant de gérer les fichiers yml
  ansible-galaxy install kwoodson.yedit

  ks_manage_account_yml settings.storage "${SETTINGS_STORAGE}"
  ks_manage_account_yml settings.source "${SETTINGS_SOURCE}"

  # On vérifie que le user ait bien les droits d'écriture
  ks_make_dir_writable "${SETTINGS_SOURCE}"
  # on vérifie que le user ait bien les droits d'écriture dans la db
  ks_change_file_owner "${SETTINGS_SOURCE}/kubeseeddb"
  # On crée le conf dir (par défaut /opt/seedbox) s'il n'existe pas
  ks_conf_dir

  ks_stocke_public_ip
  # On part à la pêche aux infos....
  ${SETTINGS_SOURCE}/includes/scripts/get_infos.sh
  ${SETTINGS_SOURCE}/includes/scripts/get_infos.sh
  ks_pause
  echo ""
  # On crée les fichier de status à 0
  # shellcheck disable=SC2162
  echo "Les composants sont maintenants tous installés/réglés, poursuite de l'installation"

  read -p "Appuyez sur entrée pour continuer, ou ctrl+c pour sortir"

  # fin du venv
}

function ks_log_write() {
  DATE=$(date +'%F %T')
  FILE=${SETTINGS_SOURCE}/logs/seedbox.log
  echo "${DATE} - ${1}" >>${FILE}
  echo "${1}"
}

function ks_stocke_public_ip() {
  echo "Stockage des adresses ip publiques"
  IPV4=$(curl -4 https://ip.mn83.fr)
  echo "IPV4 = ${IPV4}"
  ks_manage_account_yml network.ipv4 ${IPV4}
  #IPV6=$(dig @resolver1.ipv6-sandbox.opendns.com AAAA myip.opendns.com +short -6)
  IPV6=$(curl -6 https://ip.mn83.fr)
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

function ks_debug_menu() {
  if [ -z "$OLDIFS" ]; then
    OLDIFS=${IFS}
  fi
  IFS=$'\n'
  start_menu="is null"
  precedent=""
  if [[ $# -ne 0 ]]; then
    if [ -z "$1" ]; then
      :
    else
      start_menu="=${1}"
      precedent="${1}"
    fi
  fi

  ## chargement des menus
  request="select * from menu where parent_id ${start_menu}"
  sqlite3 "${SETTINGS_SOURCE}/menu" "${request}" | while read -a db_select; do
    texte_sep=""
    IFS='|'
    read -ra db_select2 <<<"$db_select"
    separateur=$(calcul_niveau_menu "${db_select2[0]}")
    IFS=$'\n'
    for i in $(seq 1 ${separateur}); do
      texte_sep="${texte_sep} ==> "
    done

    echo -e "${texte_sep}${db_select2[0]}-${db_select2[3]}) ${db_select2[1]} | ${db_select2[4]}"

    # on regarde s'il y a des menus enfants
    request_cpt="select count(*) from menu where parent_id = ${db_select2[0]}"
    cpt=$(sqlite3 ${SETTINGS_SOURCE}/menu "$request_cpt")
    if [ "${cpt}" -eq 0 ]; then
      # pas de sous menu, on va rester sur le même
      :
    else
      ks_debug_menu "${db_select2[0]}"

    fi
    IFS=$'\n'
  done

  IFS=${OLDFIFS}
}

function ks_calcul_niveau_menu() {
  if [[ $# -ne 0 ]]; then
    niveau=${2}
    if [ -z $niveau ]; then
      niveau=1
    fi
    depart="${1}"
    request_cpt="select parent_id from menu where id = ${depart}"
    parent=$(sqlite3 "${SETTINGS_SOURCE}/menu" "$request_cpt")
    if [ -z "$parent" ]; then

      echo $niveau
    else
      request_cpt="select count(*) from menu where parent_id = ${parent}"
      cpt=$(sqlite3 ${SETTINGS_SOURCE}/menu "$request_cpt")
      if [ "${cpt}" -eq 0 ]; then
        echo $niveau
      else
        niveau=$((niveau + 1))
        request_cpt="select parent_id from menu where id = ${depart}"
        parent2=$(sqlite3 ${SETTINGS_SOURCE}/menu "$request_cpt")
        if [ -z "$parent2" ]; then
          echo $niveau
        fi
        niveau=$(ks_calcul_niveau_menu ${parent} ${niveau})
      fi
      echo $niveau
    fi
  else
    echo 0
  fi
}

function ks_affiche_menu_db() {
  if [ -z "$OLDIFS" ]; then
    OLDIFS=${IFS}
  fi
  IFS=$'\n'
  echo -e "${CGREEN}${CEND}"
  start_menu="is null"
  texte_sortie="Sortie du script"
  precedent=""
  if [[ $# -eq 1 ]]; then
    if [ -z "$1" ]; then
      :
    else
      start_menu="=${1}"
      texte_sortie="Menu précédent"
      precedent="${1}"
    fi
  fi
  clear
  ks_logo
  ## chargement des menus
  request="select * from menu where parent_id ${start_menu}"
  sqlite3 "${SETTINGS_SOURCE}/menu" "${request}" | while read -a db_select; do
    IFS='|'
    read -ra db_select2 <<<"$db_select"
    echo -e "${CGREEN}   ${db_select2[3]}) ${db_select2[1]}${CEND}"
    IFS=$'\n'
  done
  echo -e "${CGREEN}---------------------------------------${CEND}"
  if [ "${precedent}" = "" ]; then
    :
  else
    echo -e "${CGREEN}   H) Retour au menu principal${CEND}"
    echo -e "${CGREEN}   B) Retour au menu précédent${CEND}"
  fi
  echo -e "${CGREEN}   Q) Quitter${CEND}"
  echo -e "${CGREEN}---------------------------------------${CEND}"
  read -p "Votre choix : " PORT_CHOICE

  if [ "${PORT_CHOICE,,}" == "b" ]; then

    request2="select parent_id from menu where id ${start_menu}"
    newchoice=$(sqlite3 ${SETTINGS_SOURCE}/menu $request2)
    ks_affiche_menu_db ${newchoice}
  elif [ "${PORT_CHOICE,,}" == "q" ]; then
    exit 0
  elif [ "${PORT_CHOICE,,}" == "h" ]; then
    # retour au début
    ks_affiche_menu_db
  else
    # on va voir s'il y a une action à faire
    request_action="select action from menu where parent_id ${start_menu} and ordre = ${PORT_CHOICE}"
    action=$(sqlite3 ${SETTINGS_SOURCE}/menu "$request_action")
    if [ -z "$action" ]; then
      : # pas d'action à effectuer
    else
      # on va lancer la fonction qui a été chargée
      IFS=${OLDIFS}
      ${action}
    fi

    req_new_choice="select id from menu where parent_id ${start_menu} and ordre = ${PORT_CHOICE}"
    newchoice=$(sqlite3 ${SETTINGS_SOURCE}/menu "${req_new_choice}")
    request_cpt="select count(*) from menu where parent_id = ${newchoice}"
    cpt=$(sqlite3 ${SETTINGS_SOURCE}/menu "$request_cpt")
    if [ "${cpt}" -eq 0 ]; then
      # pas de sous menu, on va rester sur le même
      newchoice=${precedent}
    fi
    ks_affiche_menu_db ${newchoice}

  fi
  IFS=${OLDFIFS}
}

function ks_log_statusbar() {
  tput sc                           #save the current cursor position
  tput cup $(($(tput lines) - 2)) 3 # go to last line
  tput ed
  tput cup $(($(tput lines) - 1)) 3 # go to last line
  echo $1
  tput rc # bring the cursor back to the last saved position
}

function ks_choix_appli_sauvegarde() {
  touch $SERVICESPERUSER
  TABSERVICES=()
  for SERVICEACTIVATED in $(docker ps --format "{{.Names}}"); do
    SERVICE=$(echo $SERVICEACTIVATED | cut -d\. -f1)
    TABSERVICES+=(${SERVICE//\"/} " ")
  done

  line=$(
    whiptail --title "App Manager" --menu \
      "Sélectionner le container à sauvegarder" 19 45 11 \
      "${TABSERVICES[@]}" 3>&1 1>&2 2>&3
  )
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
    sauve_one_appli ${line}
  fi
}

function ks_sauve_one_appli() {
  #############################
  # Parametres :
  # $1 = nom de l'appli
  # $2 ((optionnel) : nombre de backups à garder
  # si $2 = 0 => pas de suppression des vieux backups
  # si $2 non renseigné, on reste à 3 backups à garder
  ##############################

  # Définition des variables de couleurs
  CSI="\033["
  CEND="${CSI}0m"
  CRED="${CSI}1;31m"
  CGREEN="${CSI}1;32m"
  CYELLOW="${CSI}1;33m"
  CCYAN="${CSI}0;36m"

  # Variables
  remote=$(ks_get_from_account_yml rclone.remote)
  APPLI=$1

  NB_MAX_BACKUP=3
  ALL_RETENTION=0
  if [ $# == 2 ]; then
    if [ "$2" == 0 ]; then
      ALL_RETENTION=1
    else
      NB_MAX_BACKUP=$2
    fi
  fi
  SOURCE_DIR="${SETTINGS_STORAGE}/docker/${USER}"
  remote_backups=BACKUPS

  echo "Sauvegarde de l'application $1"
  if [ $ALL_RETENTION -eq 0 ]; then
    echo "Nombre de backups à garder : $NB_MAX_BACKUP"
  else
    echo "Pas de suppression des vieux backups"
  fi

  CDAY=$(date +%Y%m%d-%H%M)
  BACKUP_PARTITION=/var/backup/local
  #BACKUP_FOLDER=$BACKUP_PARTITION/$APPLI-$CDAY
  ARCHIVE=$APPLI-$CDAY.tar.gz

  echo ""
  echo -e "${CRED}-------------------------------------------------------${CEND}"
  echo -e "${CRED} /!\ ATTENTION : SAUVEGARDE DE ${APPLI} IMMINENTE /!\ ${CEND}"
  echo -e "${CRED}-------------------------------------------------------${CEND}"

  # Stop Plex
  echo -e "${CCYAN}> Arrêt de ${APPLI}${CEND}"
  #docker stop `docker ps -q`
  docker stop ${APPLI}
  sleep 5

  echo ""
  echo -e "${CCYAN}#########################################################${CEND}"
  echo ""
  echo -e "${CCYAN}          DEMARRAGE DU SCRIPT DE SAUVEGARDE              ${CEND}"
  echo ""
  echo -e "${CCYAN}#########################################################${CEND}"
  echo ""

  echo -e "${CCYAN}> Création de l'archive${CEND}"
  sudo tar -I pigz -cf $BACKUP_PARTITION/$ARCHIVE -P $SOURCE_DIR/$APPLI
  sleep 2s

  # Si une erreur survient lors de la compression
  if [[ -s "$ERROR_FILE" ]]; then
    echo -e "\n${CRED}/!\ ERREUR: Echec de la compression des fichiers système.${CEND}" | tee -a $LOG_FILE
    echo -e "" | tee -a $LOG_FILE
    exit 1
  fi

  # Restart Plex
  echo -e "${CCYAN}> Lancement de ${APPLI}${CEND}"
  docker start $APPLI
  sleep 5

  echo -e "${CCYAN}> Envoie Archive vers Google Drive${CEND}"
  # Envoie Archive vers Google Drive
  rclone --config "/home/${USER}/.config/rclone/rclone.conf" copy "$BACKUP_PARTITION/$ARCHIVE" "${remote}:/${USER}/${remote_backups}/" -v --progress

  # Nombre de sauvegardes effectuées
  nbBackup=$(find $BACKUP_PARTITION -type f -name $APPLI-* | wc -l)
  if [ $ALL_RETENTION -eq 0 ]; then
    if [[ "$nbBackup" -gt "$NB_MAX_BACKUP" ]]; then

      # Archive la plus ancienne
      oldestBackupPath=$(find $BACKUP_PARTITION -type f -name $APPLI-* -printf '%T+ %p\n' | sort | head -n 1 | awk '{print $2}')
      oldestBackupFile=$(find $BACKUP_PARTITION -type f -name $APPLI-* -printf '%T+ %p\n' | sort | head -n 1 | awk '{split($0,a,/\//); print a[5]}')

      # Suppression du répertoire du backup
      rm -rf "$oldestBackupPath"

      # Suppression Archive Google Drive
      echo -e "${CCYAN}> Suppression de l'archive la plus ancienne${CEND}"
      rclone --config "/home/${USER}/.config/rclone/rclone.conf" purge "$remote:/$remote_backups/$oldestBackupFile" -v --log-file=/var/log/backup.log
    fi
  fi
  echo ""
  echo -e "${CRED}-------------------------------------------------------${CEND}"
  echo -e "${CRED}        SAUVEGARDE ${APPLI}  TERMINEE                 ${CEND}"
  echo -e "${CRED}-------------------------------------------------------${CEND}"

}

function ks_change_password() {
  echo "#############################################"
  echo "Cette procédure va redéarrer traefik "
  echo "Pendant cette opération, les interfaces web seront inaccessibles"
  read -rp $'\e[33mSaisissez le nouveau password\e[0m : ' NEWPASS
  ks_manage_account_yml user.pass "${NEWPASS}"
  ks_manage_account_yml user.htpwd $(htpasswd -nb ${USER} ${NEWPASS})
  docker rm -f traefik
  ks_launch_service traefik
}

function ks_relance_container() {
  touch $SERVICESPERUSER
  TABSERVICES=()
  for SERVICEACTIVATED in $(docker ps --format "{{.Names}}"); do
    SERVICE=$(echo $SERVICEACTIVATED | cut -d\. -f1)
    TABSERVICES+=(${SERVICE//\"/} " ")
  done
  line=$(
    whiptail --title "App Manager" --menu \
      "Sélectionner le container à réinitialiser" 19 45 11 \
      "${TABSERVICES[@]}" 3>&1 1>&2 2>&3
  )
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
    ks_log_write "Relance du container ${line}"
    echo "###############################################"
    echo "# Relance du container ${line} "
    echo "###############################################"
    docker rm -f ${line}
    ks_launch_service ${line}
  fi
}

function ks_install_plextraktsync() {
  ansible-playbook ${SETTINGS_SOURCE}/includes/config/roles/plextraktsync/tasks/main.yml
  echo "Préparation pour le premier lancement de configuration"
  echo "Assurez vous d'avoir les api Trakt avant de continuer (https://trakt.tv/oauth/applications/new)"
  ks_pause
  /usr/local/bin/plextraktsync
  echo "L'outil est installé et se lancera automatiquement toutes les heures"
  ks_pause
}

function ks_install_block_public_tracker() {
  echo "Block_public_tracker va bloquer les trackers publics (piratebay, etc...) sur votre machine au niveau réseau"
  echo "Ces trackers ne seront plus accessibles"
  echo "Appuyez sur entrée pour continer, ou ctrl+C pour sortir"
  ks_pause
  ansible-playbook ${SETTINGS_SOURCE}/includes/config/playbooks/block_public_tracker.yml
  echo "Block_public_tracker a été installé avec succès"
  ks_pause
}

function ks_relance_tous_services() {
  sqlite3 ${SETTINGS_SOURCE}/kubeseeddb <<EOF >$SERVICESPERUSER
select name from applications;
EOF

  ks_install_services
}

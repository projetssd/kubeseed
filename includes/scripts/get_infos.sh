#!/bin/bash
########################################
# Gestion des services SSD
########################################
#
# Permet de récupérer des infos
# qui seront traitées par la suite
# TODO : a voir si on passe des parametres
# pour dire quelle info on veut ?
########################################

source ${SETTINGS_SOURCE}/includes/functions.sh
source ${SETTINGS_SOURCE}/includes/variables.sh

echo -e "${BLUE}### INFORMATIONS UTILISATEURS ###${NC}"

if [ ! -f ${ANSIBLE_VARS} ]; then
  mkdir -p "${HOME}/.ansible/inventories/group_vars"
  cp ${SETTINGS_SOURCE}/includes/files/account.yml ${ANSIBLE_VARS}
fi

echo ""
echo -e "${BLUE}L'utilisateur et mot de passe demandés${NC}"
echo -e "${BLUE}serviront à vous authentifier sur les différents services en mode web${NC}"

USERNAME=$(ks_get_from_account_yml user.name)
if [ ${USERNAME} == notfound ]; then
  ks_manage_account_yml user.name "${USER}"
  ks_update_seedbox_param "name" ${USER}
else
  echo -e "${BLUE}Username déjà renseigné${CEND}"
  user=${USERNAME}
fi

PASSWORD=$(ks_get_from_account_yml user.pass)
if [ ${PASSWORD} == notfound ]; then
  read -p $'\e[32m↘️ Mot de passe | Appuyer sur [Enter]: \e[0m' pass </dev/tty
  ks_manage_account_yml user.pass "$pass"
else
  echo -e "${BLUE}Password déjà renseigné${CEND}"
  pass=${PASSWORD}
fi

MAIL=$(ks_get_from_account_yml user.mail)
if [ ${MAIL} == notfound ]; then
  read -p $'\e[32m↘️ Mail | Appuyer sur [Enter]: \e[0m' mail </dev/tty
  ks_update_seedbox_param "mail" $mail
  ks_manage_account_yml user.mail $mail
else
  echo -e "${BLUE}Email déjà renseigné${CEND}"
fi

DOMAINE=$(ks_get_from_account_yml user.domain)
if [ ${DOMAINE} == notfound ]; then
  read -p $'\e[32m↘️ Domaine | Appuyer sur [Enter]: \e[0m' domain </dev/tty
  ks_manage_account_yml user.domain "$domain"
  ks_update_seedbox_param "domain" $domain
else
  echo -e "${BLUE}Domaine déjà renseigné${CEND}"
fi

CLOUD_EMAIL=$(ks_get_from_account_yml cloudflare.login)
if [ "$CLOUD_EMAIL" == notfound ]; then
  while [ -z "$cloud_email" ]; do
    echo >&2 -n -e "${BWHITE}Votre Email Cloudflare: ${CEND}"
    read cloud_email

  done
  ks_manage_account_yml cloudflare.login "$cloud_email"
else
  echo -e "${BLUE}Cloudflare login déjà renseigné${CEND}"
fi
CLOUD_API=$(ks_get_from_account_yml cloudflare.api)
if [ "$CLOUD_API" == notfound ]; then
  while [ -z "$cloud_api" ]; do
    echo >&2 -n -e "${BWHITE}Votre API Cloudflare: ${CEND}"
    read cloud_api

  done
  ks_manage_account_yml cloudflare.api "$cloud_api"
else
  echo -e "${BLUE}Cloudflare api déjà renseigné${CEND}"
fi
# On met le ssl CF à full
ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/cf_force_full_ssl.yml"

# creation utilisateur
userid=$(id -u)
grpid=$(id -g)

# on reprend les valeurs du account.yml, juste au cas où
user=$(ks_get_from_account_yml user.name)
pass=$(ks_get_from_account_yml user.pass)

ks_manage_account_yml user.htpwd $(htpasswd -nb $user $pass)

ks_manage_account_yml user.userid "$userid"
ks_manage_account_yml user.groupid "$grpid"

#!/bin/bash
########################################
# Gestion des infos Kubeseed
########################################
# Permet de récupérer des infos
# qui seront traitées par la suite
########################################

source "${SETTINGS_SOURCE}/includes/functions.sh"
source "${SETTINGS_SOURCE}/includes/variables.sh"


echo -e "${BLUE}### INFORMATIONS UTILISATEURS ###${NC}"

if [ ! -f "${ANSIBLE_VARS}" ]; then
  mkdir -p "${HOME}/.ansible/inventories/group_vars"
  cp "${SETTINGS_SOURCE}/includes/files/account.yml" "${ANSIBLE_VARS}"
fi

echo ""
echo -e "${BLUE}L'utilisateur et mot de passe demandés${NC}"
echo -e "${BLUE}serviront à vous authentifier sur les différents services en mode web${NC}"

USERNAME=$(ks_get_from_account_yml user.name)
if [ "${USERNAME}" == notfound ]; then
  ks_manage_account_yml user.name "${USER}"
else
  echo -e "${BLUE}Username déjà renseigné${CEND}"
  user=${USERNAME}
fi

PASSWORD=$(ks_get_from_account_yml user.pass)
if [ "${PASSWORD}" == notfound ]; then
  if [ -n "$KS_PASSWORD" ]; then
    echo -e "${BLUE}Password déjà renseigné dans le fichier kickstart${CEND}"
    pass=${KS_PASSWORD}
  else
    read -p $'\e[32m↘️ Mot de passe | Appuyer sur [Enter]: \e[0m' pass </dev/tty
  fi
  ks_manage_account_yml user.pass "$pass"
else
  echo -e "${BLUE}Password déjà renseigné${CEND}"
  pass=${PASSWORD}
fi

MAIL=$(ks_get_from_account_yml user.mail)
if [ ${MAIL} == notfound ]; then
  if [ -n "$KS_MAIL" ]; then
    echo -e "${BLUE}Mail déjà renseigné dans le fichier kickstart${CEND}"
    mail="${KS_MAIL}"
  else
    read -p $'\e[32m↘️ Mail | Appuyer sur [Enter]: \e[0m' mail </dev/tty
  fi
  ks_manage_account_yml user.mail $mail
else
  echo -e "${BLUE}Email déjà renseigné${CEND}"
fi

DOMAINE=$(ks_get_from_account_yml user.domain)
if [ "${DOMAINE}" == notfound ]; then
  if [ -n "$KS_DOMAIN" ]; then
    echo -e "${BLUE}Domaine déjà renseigné dans le fichier kickstart${CEND}"
    domain="${KS_DOMAIN}"
  else
    read -p $'\e[32m↘️ Domaine | Appuyer sur [Enter]: \e[0m' domain </dev/tty
  fi
  ks_manage_account_yml user.domain "$domain"
else
  echo -e "${BLUE}Domaine déjà renseigné${CEND}"
fi

CLOUD_EMAIL=$(ks_get_from_account_yml cloudflare.login)
if [ "$CLOUD_EMAIL" == notfound ]; then
  if [ -n "$KS_CF_MAIL" ]; then
    echo -e "${BLUE}Mail cloudflare déjà renseigné dans le fichier kickstart${CEND}"
    cloud_email="${KS_CF_MAIL}"
  else
    echo >&2 -n -e "${BWHITE}Votre Email Cloudflare: ${CEND}"
    read cloud_email
  fi

  ks_manage_account_yml cloudflare.login "$cloud_email"
else
  echo -e "${BLUE}Cloudflare login déjà renseigné${CEND}"
fi

CLOUD_API=$(ks_get_from_account_yml cloudflare.api)
if [ "$CLOUD_API" == notfound ]; then
  if [ -n "$KS_CF_API" ]; then
    echo -e "${BLUE}API cloudflare déjà renseigné dans le fichier kickstart${CEND}"
    cloud_api="${KS_CF_API}"
  else
    echo >&2 -n -e "${BWHITE}Votre API Cloudflare: ${CEND}"
    read cloud_api
  fi
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

ks_manage_account_yml user.k3s_secret $(htpasswd -nb $user $pass | openssl base64)

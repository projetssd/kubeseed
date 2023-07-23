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

ks_get_and_store_info "user.pass" "Mot de passe" KS_PASSWORD
ks_get_and_store_info "user.mail" "Adresse mail" KS_MAIL
ks_get_and_store_info "user.domain" "Domaine" KS_DOMAIN
### CLOUDFLARE ###
#ks_manage_account_yml dns.usage N
ks_get_and_store_info "cloudflare.usage" "Voulez vous utiliser cloudflare ? [O/N]" KS_CF_USAGE O
cloudflare_usage=$(ks_get_from_account_yml cloudflare.usage)
if [ "${cloudflare_usage}" == "O" ]; then
  ks_get_and_store_info "cloudflare.login" "Votre Email cloudflare" KS_CF_MAIL
  ks_get_and_store_info "cloudflare.api" "Votre API cloudflare" KS_CF_API
  # On met le ssl CF à full
  ansible-playbook "${SETTINGS_SOURCE}/includes/playbooks/cf_force_full_ssl.yml"
else
  ###################
  ### PDNS / NSUPDATE
  ks_get_and_store_info "dns.usage" "Voulez vous utilise nsupdate ? [O/N]" KS_NS_USAGE O
  ns_usage=$(ks_get_from_account_yml ns.usage)
  if [ "${ns_usage}" == "O" ]; then
    ks_get_and_store_info "dns.algo" "algo nsupdate" KS_NS_ALGO
    ks_get_and_store_info "dns.keyname" "keyname" KS_NS_KEYNAME
    ks_get_and_store_info "dns.keysecret" "keysecret" KS_NS_KEYSECRET
    ks_get_and_store_info "dns.server" "ip serveur ns" KS_NS_SERVER
  fi
  ###################
fi

# creation utilisateur
userid=$(id -u)
grpid=$(id -g)

# on reprend les valeurs du account.yml, juste au cas où
user=$(ks_get_from_account_yml user.name)
pass=$(ks_get_from_account_yml user.pass)

ks_manage_account_yml user.htpwd $(htpasswd -nb "${user}" "${pass}")

ks_manage_account_yml user.userid "$userid"
ks_manage_account_yml user.groupid "$grpid"

ks_manage_account_yml user.k3s_secret $(htpasswd -nb "${user}" "${pass}" | openssl base64)

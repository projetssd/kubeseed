#!/bin/bash
#source "${SETTINGS_SOURCE}/profile.sh"
source "${SETTINGS_SOURCE}/includes/functions.sh"
## shellcheck source=${BASEDIR}/includes/variables.sh
source "${SETTINGS_SOURCE}/includes/variables.sh"

#########################################################################
# Title:         Retrieve Plex Token                                    #
# Author(s):     Werner Beroux (https://github.com/wernight)            #
# URL:           https://github.com/wernight/docker-plex-media-server   #
# Description:   Prompts for Plex login and prints Plex access token.   #
#########################################################################
#                           MIT License                                 #
#########################################################################


ks_get_and_store_info  "plex.ident" "Votre login Plex (e-mail or username)" UNCHECK

ks_get_and_store_info  "plex.sesame" "Votre password Plex" UNCHECK

>&2 echo 'Retrieving a X-Plex-Token using Plex login/password ...'


curl -qu "$(ks_get_from_account_yml plex.ident)":"$(ks_get_from_account_yml plex.sesame)" 'https://plex.tv/users/sign_in.xml' \
    -X POST -H 'X-Plex-Device-Name: PlexMediaServer' \
    -H 'X-Plex-Provides: server' \
    -H 'X-Plex-Version: 0.9' \
    -H 'X-Plex-Platform-Version: 0.9' \
    -H 'X-Plex-Platform: xcid' \
    -H 'X-Plex-Product: Plex Media Server'\
    -H 'X-Plex-Device: Linux'\
    -H 'X-Plex-Client-Identifier: XXXX' --compressed >/tmp/plex_sign_in
X_PLEX_TOKEN=$(sed -n 's/.*<authentication-token>\(.*\)<\/authentication-token>.*/\1/p' /tmp/plex_sign_in)
if [ -z "$X_PLEX_TOKEN" ]; then
    cat /tmp/plex_sign_in
    rm -f /tmp/plex_sign_in
    >&2 echo 'Failed to retrieve the X-Plex-Token.'
    exit 0
else
  ks_manage_account_yml plex.token "${X_PLEX_TOKEN}"
fi

rm -f /tmp/plex_sign_in

echo "${X_PLEX_TOKEN}"

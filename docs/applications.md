# Comment ajouter une application à ma seedbox

Il faut ajouter un fichier yml au répertoire ${SETTINGS_STORAGE}/app_persos/. Le modèle à utiliser se trouve dans **examples/nouvelle_appli.yml**

Si vous ajouter un fichier qui porte le même nom qu'une appli "officielle" de Kubeseed, c'est votre fichier qui sera pris en compte au moment du lancement et non plus le fichier fourni avec Kubeseed.

# Changer la configuration d'une application

Pour changer l'url d'une application ou son mode d'authentification, il suffit de la désinstaller/réinstaller. Les données de cette aplication ne sont pas effacées, et à l'installation, il vous sera demandé le sous domaine ainsi que le mode d'authentification à utiliser.


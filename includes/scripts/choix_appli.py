import subprocess
import os
import kubeseed

answers = kubeseed.choix_appli_lance()

for my_appli in answers['applications']:
    subprocess.run([os.environ['SETTINGS_SOURCE'] + "/includes/scripts/generique.sh", "ks_launch_service", my_appli])
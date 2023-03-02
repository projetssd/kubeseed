#!/usr/bin/env python3

import inquirer
import os
import yaml
from yaml.loader import SafeLoader
import subprocess


list_applis = []
basepath = os.environ['SETTINGS_SOURCE'] + '/containers/'

for entry in os.listdir(basepath):
    if os.path.isfile(os.path.join(basepath, entry)):
        # on a un fichier
        if entry.endswith('.yml'):
            # C'est un fichier yaml
            with open(basepath + entry) as f:
                data = yaml.load(f, Loader=SafeLoader)
                application = data['application']
                # on gère le cas où il n'y a pas de description
                try:
                    description = data['description']
                except:
                    description = data['application']

            list_applis.append((application + ' - ' + description, application))    


questions = [
  inquirer.Checkbox('applications',
                    message="Sélectionner les applications à installer",
                    choices=list_applis,
                    ),
]
answers = inquirer.prompt(questions)

print(answers)
for my_appli in answers[']applications']:
    subprocess.run(["ks_launch_service",my_appli])
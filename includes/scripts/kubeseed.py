import inquirer
import os
import yaml
import ansible_runner
import sys
import subprocess
from yaml.loader import SafeLoader

settings_source = os.environ['SETTINGS_SOURCE']


def choix_appli_lance():
    list_applis = []
    basepath = settings_source + '/containers/'

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
    lance_applis(inquirer.prompt(questions)['applications'])


def get_from_account_yml(myinput):
    out, err, rc = ansible_runner.run_command(executable_cmd='ansible-playbook',
                                              cmdline_args=[settings_source + '/includes/playbooks/get_var.yml', '-e',
                                                            'myvar=' + myinput],
                                              output_fd=sys.stdout,
                                              error_fd=sys.stderr,
                                              quiet=True
                                              )
    split_output = out.split("##RESULT##")
    result = (split_output[1])
    if result:
        return result
    else:
        return "notfound"


def lance_applis(list_applis):
    for my_appli in list_applis:
        subprocess.run(
            [os.environ['SETTINGS_SOURCE'] + "/includes/scripts/generique.sh", "ks_launch_service", my_appli])

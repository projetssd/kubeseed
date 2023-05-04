import os
import sys
import subprocess
# gestion des questions/checkboxes
import inquirer
# lancement de playbooks
import ansible_runner
# lecture des yml
import yaml
from yaml.loader import SafeLoader
# menus
from simple_term_menu import TerminalMenu
# Kubernetes
from kubernetes import client, config
# Traductions
import gettext

settings_source = os.environ['SETTINGS_SOURCE']
settings_storage = os.environ['SETTINGS_STORAGE']
generique_bash = settings_source + "/includes/scripts/generique.sh"

gettext.bindtextdomain('ks', settings_source + '/i18n')
gettext.textdomain('ks')
_ = gettext.gettext


def choix_appli_lance():
    """
    Affiche une liste de choix (checkbox) des applis à installer
    Installe les applis choisies une à une
    """
    list_applis = []
    basepath = settings_source + '/containers/'
    persopath = settings_storage + '/app_persos/'
    # On fait la liste des applis officielles
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
                # On crée un tuple (appli - desc, appli)
                list_applis.append((application + ' - ' + description, application))
    # On fait la liste des applis persos
    for entry in os.listdir(persopath):
        if os.path.isfile(os.path.join(persopath, entry)):
            # on a un fichier
            if entry.endswith('.yml'):
                # C'est un fichier yaml
                with open(basepath + entry) as f:
                    data = yaml.load(f, Loader=SafeLoader)
                    application = data['application']
                    # on gère le cas où il n'y a pas de description

                    try:
                        old_description = data['description']
                    except:
                        old_description = data['application']
                    description = '[PERSO] - ' + old_description
                # On regarde si on a déjà cette appli dans la première liste
                if (application + ' - ' + old_description, application) in list_applis:
                    list_applis.remove((application + ' - ' + old_description, application))
                # On crée un tuple (appli - desc, appli)
                list_applis.append((application + ' - ' + description, application))
    # On trie la liste par ordre alpha
    list_applis.sort()
    questions = [
        inquirer.Checkbox('applications',
                          message=_("Sélectionner les applications à") + " " + _("installer"),
                          choices=list_applis,
                          ),
    ]
    lance_applis(inquirer.prompt(questions)['applications'])


def get_from_account_yml(myinput):
    """
    Pour récupérer une variable du all.yml en python pur
    """
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
    """
    Lance une liste d'applis (passe par le générique bash pour utiliser une fonction)
    """
    for my_appli in list_applis:
        subprocess.run(
            [generique_bash, "ks_launch_service", my_appli])


def create_menu(mylist):
    menu_list = [_('Menu principal'), ""]
    for element in mylist:
        menu_list.append(_(element['menu']))
    terminal_menu = TerminalMenu(menu_list,
                                 title=_("Menu KubeSeed") + "\n\n" + _(
                                     "Appuyez sur echap pour sortir") + "\n=============================================",
                                 skip_empty_entries=True)
    menu_entry_index = terminal_menu.show()
    # le menu_entry_index est l'index choisi
    if menu_entry_index is None:
        print(_('Sortie sur echap'))
        exit()
    if menu_entry_index == 0:
        menu_principal()
    else:
        menu_entry_index = menu_entry_index - 2
        type_dest = mylist[menu_entry_index]['type_dest']
        if type_dest == "sousmenu":
            create_menu(mylist[menu_entry_index]['sousmenu'])
        else:
            if type_dest == "bash":
                subprocess.run(
                    [settings_source + "/includes/scripts/generique.sh", mylist[menu_entry_index]['dest']])

            if type_dest == "python":
                eval(mylist[menu_entry_index]['dest'] + '()')
        input(_("Appuyez sur une touche pour continuer") + "...")
        create_menu(mylist)


def menu_principal():
    # on charge les valeurs du menu
    with open(settings_source + '/includes/menu.yml') as f:
        datamenu = yaml.load(f, Loader=SafeLoader)

    create_menu(datamenu)


def list_deployments():
    output_list = []
    config.load_kube_config(config_file=settings_storage + '/k3s/k3s.yaml')
    apis_api = client.AppsV1Api()
    resp = apis_api.list_namespaced_deployment(namespace="kubeseed")
    for item in resp.items:
        if not item.metadata.name.startswith('db.'):
            output_list.append(item.metadata.name)
    return output_list


def restart_deployment(list_deployment):
    for deployment in list_deployment:
        subprocess.run(
            [generique_bash, "ks_restart_deployment", deployment])


def lance_appli(list_deployment):
    for deployment in list_deployment:
        subprocess.run(
            [generique_bash, "ks_launch_service", deployment])


def delete_deployment(list_deployment):
    for deployment in list_deployment:
        subprocess.run(
            [generique_bash, "ks_delete_deployment", deployment])


def reinit_deployment(list_deployment):
    for deployment in list_deployment:
        subprocess.run(
            [generique_bash, "ks_reinit_deployment", deployment])


def choix_running_appli(complement_texte):
    list_applis = list_deployments()
    list_applis.sort()
    questions = [
        inquirer.Checkbox('applications',
                          message=_("Sélectionner les applications à") + " " +
                                  complement_texte + " - " + _("entrée pour valider"),
                          choices=list_applis,
                          ),
    ]
    result = inquirer.prompt(questions)['applications']
    return result


def choix_restart_appli():
    """
    Affiche une liste de choix (checkbox) des applis à installer
    Installe les applis choisies une à une
    """
    result = choix_running_appli(_("redémarrer"))
    restart_deployment(result)


def choix_delete_appli():
    """
    Affiche une liste de choix (checkbox) des applis à installer
    Installe les applis choisies une à une
    """
    result = choix_running_appli(_("désinstaller"))
    delete_deployment(result)


def choix_reinit_appli():
    """
    Affiche une liste de choix (checkbox) des applis à installer
    Installe les applis choisies une à une
    """
    result = choix_running_appli(_("réinitialiser"))
    reinit_deployment(result)

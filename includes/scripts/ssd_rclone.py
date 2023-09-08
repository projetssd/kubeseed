#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Bibliotheques pour gérer les fonctions python
d'interaction avec rclone pour ssd
"""
import configparser
import os

rclone_config_file = os.environ['HOME'] + '/.config/rclone/rclone.conf'



    

def detect_all_remotes():
    """
    Fonction de choix d'un google drive
    Génère une liste des gd
    """
    config = configparser.ConfigParser()
    config.read(rclone_config_file)

    mytd = [] 
    for section in config.sections():
        mytd.append(section)
    return mytd

def valide_choix_remote():
    """
    Juste la fonction d'input
    teste si on a bien un integer, si oui, le retourne
    sinon, revient sur elle même
    :return: integer
    """
    mystockage = input("Choisir le stockage principal associé à la seedbox : ")
    try:
        mystockage = int(mystockage)
        return mystockage
    except:
        valide_choix_remote()


def recherche_crypt(myremote):
    """
    Recherche si un remote de type crypt existe
    pour le remote donné en parametre
    :param myremote: nom du remote
    :return: remote chiffré associé
    """
    config = configparser.ConfigParser()
    config.read(rclone_config_file)
    for section in config.sections():
        if config[section]['type'] == 'crypt':
            if myremote in config[section]['remote']:
                return section
                print(section)
    return False


def get_id_teamdrive(myremote):
    """
    Cherche l'id du teamdrive associé au remote
    :param myremote: nom du remote
    :return: nom du team drive|False
    """
    config = configparser.ConfigParser()
    config.read(rclone_config_file)
    try:
        id_teamdrive = config[myremote]['team_drive']
    except:
        id_teamdrive = ""
    f2 = open("/tmp/id_teamdrive", "a")
    f2.write(id_teamdrive)
    f2.close()


def affiche_drive(drives):
    """&
    Affiche la liste des drives, et demande au user de choisir
    :param drives: liste de remotes
    :return:
    """
    dict_td = {}
    print("-------------------------------")
    for (i, item) in enumerate(drives, start=1):
        print(i, item)
        dict_td[i] = item

    stockage = 0
    print("")

    stockage = valide_choix_remote()
    while stockage not in dict_td:
        stockage = valide_choix_remote()
    remote = dict_td[stockage]
    print("Source sélectionnée : " + remote)

    get_id_teamdrive(remote)

    # Recherche d'un remote de type crypt associé



    f = open("/tmp/choix_crypt", "a")
    f.write(remote)
    f.close()

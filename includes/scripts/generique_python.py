import sys
import kubeseed

"""
CE script sert à lancer une fonction pyehon depuis bash
il faut que la fonction se trouve dans kubeseed.py
"""

eval('kubeseed.' + sys.argv[1] + '()')

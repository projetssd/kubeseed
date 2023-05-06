# Comment ajouter/modifier une traduction

Par défaut, Kubeseed est en français. Certains éléments peuvent être traduits pour prendre en charge la langue du système ou de l'utilisateur (visible par la commande **locale** dans un terminal).

Si un élément n'est pas traduit, il sera affiché en français par défaut.

## Fichier .po

Il faut commencer par générer (pour une nouvelle traduction) ou modifier (pour une traduction existante) un fichier i18n/xx.po (xx étant le langage que l'on veut modifier)

Par défaut, pas besoin de fr.po, le programme étant en français par défaut.

Une fois le fichier créé, il faut lancer la commande **ks_generate_translation** qui va générer les fichiers .mo au bon endroit. Ces fichiers doivent ensuite être ajoutés au git et poussés sur le repo (soit directement pour les devs internes, soit au moyen d'une pull request)

## Modification des appels

### Dans les fichiers bash/scripts

Au lieu de faire 

```shell
echo "Lancement en root"
```

il faut faire 

```shell 
echo "$(gettext "Lancement en root")"
```

Pour que la traduction soit prise en compte.

### Dans les scripts python

Il faut remplacer les variables ou les textes par _("xxxxx")

Par exemple 

```python  
print("Menu principal")
```

devient

```python 
print(_("Menu principal"))
```
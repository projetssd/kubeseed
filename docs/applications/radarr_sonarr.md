## Radarr / Sonarr

### Authentification

Il est conseillé de ne pas mettre d'authentification pour ces applis dans kubeseed, et ensuite de mettre une authentification de type Basic (Brower popup) dans l'outil (menu Settings => general => security)
![image](https://user-images.githubusercontent.com/3830148/236147092-b22a7470-c48e-4df9-a938-c69feb486b47.png)

Cela permettra d'utiliser des outils tiers comme des applis portables
NB : Les nouvelles versions des *arrs force la mise en place d'une authentification gérée par le ARR en question, le fait de ne pas mettre d'auth par kubeseed permet d'éviter des loops d'auth.

### Connexion à rutorrent

![image](https://user-images.githubusercontent.com/3830148/236146740-a5496dd2-7130-432f-98c1-4c2cb710ba9a.png)

### Remote paths

Dans settings => downbload clients => remote path mappings

![image](https://user-images.githubusercontent.com/3830148/236147591-1571cc91-192e-4e7e-b4df-0a9541299fc8.png)

### Import manuel

Vous avez téléchargez du contenu avant de le mettre en surveillance dans *arr ou vous avez une erreur à l'importation.

Alors vous devez utilisez la fonction "manual import" :

Il faut utiliser le chemin vers le dossier contenant vos données (attention vous devez utilisez le chemin "Medias"
Ensuite "interactive import" et enfin vous pouvez sélectionner les fichiers à importés en ayant pris soins de cocher selon vos besoins "hardlink ou "move"

![image](https://user-images.githubusercontent.com/3830148/236148214-f224f5ba-1cd2-4ca4-81c7-45157f3d9ffd.png)


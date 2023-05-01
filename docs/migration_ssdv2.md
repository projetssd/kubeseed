# Migration depuis ssd v2

Il n'y a pas de procédure automatisée de migration depuis [ssdv2](https://github.com/projetssd/ssdv2), les opérations doivent se faire à la main.

## Dans le cas d'utilisation de rclone/google drive

Il est recommandé de faire ces actions AVANT d'installer la première application

> :warning: **Attention**: ces actions manuelles peuvent être écrasées en cas de réinstallation d'application ou de mise à jour

### rclone.service

Il faut éditer le fichier **/etc/systemd/system/rclone.service** pour ajouter le nom de l'ancien user au niveau du point de montage

La partie
```
ExecStart=/usr/bin/rclone mount -vv \
  --config=/home/steph/.config/rclone/rclone.conf \
  --allow-other --gid 1000 --uid 1000 \
  --allow-non-empty \
  --vfs-cache-mode full \
  --vfs-cache-max-size 150G \
  --cache-dir=/home/steph/.config/rclone/cache \
  seedbox_crypt: \
  /home/steph/seedbox/rclone
```

devient par exemple

``` 
ExecStart=/usr/bin/rclone mount -vv \
  --config=/home/steph/.config/rclone/rclone.conf \
  --allow-other --gid 1000 --uid 1000 \
  --allow-non-empty \
  --vfs-cache-mode full \
  --vfs-cache-max-size 150G \
  --cache-dir=/home/steph/.config/rclone/cache \
  seedbox_crypt:/seed \ # <== changement ICI
  /home/steph/seedbox/rclone
```

Après ça

```
sudo systemctl restart rclone
sudo systemctl restart mergerfs
```

## cloudplow

Il faut modifier le fichier **${SETTINGS_STORAGE}/app_settings/cloudplow/config.json** pour ajouter le nom de l'ancien user

```
"upload_remote": "seedbox_crypt:"
```

devient

```
"upload_remote": "seedbox_crypt:/seed"
```

Après ça

```
ks_restart_deployment cloudplow
```

## Backup

Il faut éditer le fichier **/usr/local/bin/backup**

``` 
rclone --config "/home/steph/.config/rclone/rclone.conf" copy "$BACKUP_FOLDER" "seedbox_crypt:/$remote_backups/backup-$CDAY" --progress
```

devient

``` 
rclone --config "/home/steph/.config/rclone/rclone.conf" copy "$BACKUP_FOLDER" "seedbox_crypt:/seed/$remote_backups/backup-$CDAY" --progress
```
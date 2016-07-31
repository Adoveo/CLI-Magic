#!/bin/bash
CONFIG_PATH="/volume1/backup/scripts/config/"
EXCLUDE_PATH="/volume1/backup/scripts/excludes/"

if [ -z "$1" ];then
  echo "Vous devez passer un fichier de config en argument"
  exit;
else
  if [ -f "$1" ];then
    source $1
  else
    if [ -f "$CONFIG_PATH$1" ];then
      source "$CONFIG_PATH$1"
    else
      echo "Le fichier de config n'existe pas"
      exit;
    fi
  fi
fi

if [ -f "$EXCLUDE_PATH$EXCLUDE_FILE" ];then
  EXCLUDE_COMMANDE=" --exclude-from=$EXCLUDE_PATH$EXCLUDE_FILE";
else
  EXCLUDE_COMMANDE="";
fi

for i in `seq $NB_DAYS_TO_KEEP -1 1`;
do
  OLD=$((i-1))
  rm "$BACKUP_LOCAL_PATH/backup.$i" -Rf
  mv "$BACKUP_LOCAL_PATH/backup.$OLD" "$BACKUP_LOCAL_PATH/backup.$i"
done

rsync -avPtze "ssh -p $SSH_PORT" "$USER@$SERVER:$REMOTE_PATH_TO_BACKUP/" "$BACKUP_LOCAL_PATH/backup.0/" --link-dest="$BACKUP_LOCAL_PATH/backup.1" --delete $EXCLUDE_COMMANDE

touch "$BACKUP_LOCAL_PATH/backup.0"

chown kgaut:users -R "$BACKUP_LOCAL_PATH/backup.0"
chmod ug+x "$BACKUP_LOCAL_PATH/backup.0"
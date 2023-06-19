#!/bin/bash

# Function to generate the backup filename with an index
generate_backup_filename() {
  BACKUP_INDEX=1
  BACKUP_FILENAME="gnome_settings_old_$BACKUP_INDEX"
  while [ -f "$BACKUP_FILENAME" ]; do
    ((BACKUP_INDEX++))
    BACKUP_FILENAME="gnome_settings_old_$BACKUP_INDEX"
  done
}

# Function to display the help message
display_help() {
  echo "Usage: $0 [load/backup] [filename]"
  echo "Options:"
  echo "  load     : Load gnome settings from backup (default: load from default file)"
  echo "  backup   : Make a backup of gnome settings (default: use default filename)"
  echo "  filename : Specify the filename for backup/restore (optional)"
  echo "  -h, --help : Display this help message"
  exit 0
}

# Check if -h or --help argument is passed, display help message and exit
if [[ "$*" == *"-h"* || "$*" == *"--help"* ]]; then
  display_help
fi

# Ask the user whether to make a backup or load a backup if no arguments are provided
if [[ ! $1 ]]; then
  printf "\n"
  echo "Choose an option:"
  echo "1. Make a backup of gnome settings"
  echo "2. Load gnome settings from backup"
  read -p "Enter your choice: " CHOICE
  printf "\n"
fi

# Determine the action and filename based on command-line arguments or user input
ACTION="load"
FILENAME=".gnome_settings"

if [[ $1 == "backup" || $CHOICE == 1 ]]; then
  ACTION="backup"
fi

if [[ $2 ]]; then
  FILENAME="$2"
fi

if [[ $ACTION == "backup" ]]; then
  ### Make a backup of gnome settings
  if [ -f "$FILENAME" ]; then
    generate_backup_filename
    mv "$FILENAME" "$BACKUP_FILENAME"
    echo "Existing $FILENAME renamed to $BACKUP_FILENAME"
  fi
  dconf dump / > "$FILENAME"
  echo "Gnome settings backed up successfully."
else
  ### Load gnome settings from backup
  if [ -f "$FILENAME" ]; then
    dconf load -f / < "$FILENAME"
    echo "Settings loaded successfully."
  else
    echo "Error: Backup file not found."
    exit 1
  fi
fi

### Restart the GNOME Shell to apply the changes
if dbus-send --type=method_call --dest=org.gnome.Shell /org/gnome/Shell org.gnome.Shell.Eval "string:'global.reexec_self();'"; then
  echo "$0: Finished setting up."
else
  echo "Error restarting GNOME Shell."
fi

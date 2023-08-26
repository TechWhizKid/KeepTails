#!/bin/bash

# Default filenames and paths
DEFAULT_FILENAME=".gnome_settings"
BACKUP_PREFIX="gnome_settings_old"

# Function to generate a unique backup filename
generate_backup_filename() {
  local backup_index=1
  local backup_filename="${BACKUP_PREFIX}_${backup_index}"
  
  while [ -f "$backup_filename" ]; do
    ((backup_index++))
    backup_filename="${BACKUP_PREFIX}_${backup_index}"
  done
  
  echo "$backup_filename"
}

# Function to display the help message
display_help() {
  cat << EOF
Usage: $0 [load/backup] [filename]
Options:
  load        : Load gnome settings from backup (default: load from default file)
  backup      : Make a backup of gnome settings (default: use default filename)
  filename    : Specify the filename for backup/restore (optional)
  -h, --help  : Display this help message
EOF
  exit 0
}

# Function to handle errors
handle_error() {
  echo "Error: $1" >&2
  exit 1
}

# Check for help argument
if [[ "$*" == *"-h"* || "$*" == *"--help"* ]]; then
  display_help
fi

# Ask for user input if no arguments are provided
if [[ ! $1 ]]; then
  PS3="Choose an option and press 'Enter': "
  options=("Make a backup of gnome settings" "Load gnome settings from backup")
  select CHOICE in "${options[@]}"; do
    case $REPLY in
      1) ACTION="backup"; break ;;
      2) ACTION="load"; break ;;
      *) echo "Invalid choice, please select 1 or 2." ;;
    esac
  done

  # Prompt for filename only in interactive mode
  if [[ $ACTION ]]; then
    read -rp "Enter filename (press Enter to use default): " input_filename
    FILENAME="${input_filename:-$DEFAULT_FILENAME}"

    if [[ $ACTION == "backup" ]]; then
      # Make a backup of gnome settings
      if [ -f "$FILENAME" ]; then
        backup_filename=$(generate_backup_filename)
        mv "$FILENAME" "$backup_filename" || handle_error "Failed to rename file"
        echo "Existing $FILENAME renamed to $backup_filename"
      fi
      dconf dump / > "$FILENAME" || handle_error "Failed to create backup"
      echo "Gnome settings backed up successfully to file: $FILENAME."
      exit 0
    else
      # Load gnome settings from backup
      if [ -f "$FILENAME" ]; then
        dconf load -f / < "$FILENAME" || handle_error "Failed to load settings from backup"
        echo "Settings loaded successfully from file: $FILENAME."
        exit 0
      else
        handle_error "Backup file not found."
      fi
    fi
  fi
fi

# Set action and filename based on input
ACTION="${1:-$ACTION}"
FILENAME="${2:-$DEFAULT_FILENAME}"

if [[ $ACTION == "backup" ]]; then
  # Make a backup of gnome settings
  if [ -f "$FILENAME" ]; then
    backup_filename=$(generate_backup_filename)
    mv "$FILENAME" "$backup_filename" || handle_error "Failed to rename file"
    echo "Existing $FILENAME renamed to $backup_filename"
  fi
  dconf dump / > "$FILENAME" || handle_error "Failed to create backup"
  echo "Gnome settings backed up successfully to file: $FILENAME."
else
  # Load gnome settings from backup
  if [ -f "$FILENAME" ]; then
    dconf load -f / < "$FILENAME" || handle_error "Failed to load settings from backup"
    echo "Settings loaded successfully from file: $FILENAME."
  else
    handle_error "Backup file not found."
  fi
fi

# Restart the GNOME Shell to apply changes
if dbus-send --type=method_call --dest=org.gnome.Shell /org/gnome/Shell org.gnome.Shell.Eval "string:'global.reexec_self();'"; then
  echo "$0: Finished setting up."
else
  handle_error "Error restarting GNOME Shell."
fi

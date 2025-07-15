#!/usr/bin/env bash

# Default values
extract_to_dir=false
file_arg_index=1
undo_mode=false

# Check for flags
case "$1" in
  -d|--d|--directory)
    extract_to_dir=true
    file_arg_index=2
    ;;
  -u|--undo)
    undo_mode=true
    file_arg_index=2
    ;;
esac

# Get the target from the arguments
target="${!file_arg_index}"

# Check if a target was provided
if [ -z "$target" ]; then
  echo "Usage: $(basename "$0") [-d|--d|--directory] <file-to-extract>"
  echo "       $(basename "$0") [-u|--undo] <directory-to-remove>"
  exit 1
fi

# Undo mode logic
if [ "$undo_mode" = true ]; then
  if [ ! -d "$target" ]; then
    echo "Error: Directory '$target' not found."
    exit 1
  fi
  read -p "Are you sure you want to permanently delete '$target' and all its contents? (y/N) " confirmation
  if [[ "$confirmation" == "y" || "$confirmation" == "Y" ]]; then
    rm -rf "$target"
    echo "Directory '$target' has been deleted."
  else
    echo "Undo operation cancelled."
  fi
  exit 0
fi

# Check if the file actually exists
if [ ! -f "$target" ]; then
  echo "Error: File '$target' not found."
  exit 1
fi

# Set up extraction destination
destination="."
if [ "$extract_to_dir" = true ]; then
  # Create directory name from filename without extension
  directory_name="${target%%.*}"
  mkdir -p "$directory_name"
  destination="$directory_name"
fi

# Extraction logic
case "$target" in
  *.tar.bz2|*.tbz2) tar xvjf "$target" -C "$destination"    ;;
  *.tar.gz|*.tgz)   tar xvzf "$target" -C "$destination"    ;;
  *.tar.xz)         tar xvJf "$target" -C "$destination"    ;;
  *.tar)            tar xvf "$target" -C "$destination"     ;;
  *.zip)            unzip "$target" -d "$destination"       ;;
  *.rar)            unrar x "$target" "$destination/"     ;;
  *.gz)             gunzip -c "$target" > "$destination/$(basename "$target" .gz)" ;;
  *.bz2)            bunzip2 -c "$target" > "$destination/$(basename "$target" .bz2)" ;;
  *.xz)             unxz -c "$target" > "$destination/$(basename "$target" .xz)" ;;
  *.7z)             7z x "$target" -o"$destination"        ;;
  *)
    echo "Error: Don't know how to extract '$target'"
    exit 1
    ;;
esac

if [ "$extract_to_dir" = true ]; then
    echo "'$target' extracted successfully to '$destination'."
else
    echo "'$target' extracted successfully."
fi

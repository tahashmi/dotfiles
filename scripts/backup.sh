#!/bin/bash
# Backup system configurations

# Create the backup by the following command, see help for detail
# Note it will also delete the files which are deleted from source dir.
# This is achieved by --delete-exclude option to rsync
# backup.sh c

# Source Directory (should be root (/) as include and exclude files use full paths)
src_dir="/"
 
# Destination Parent Directory (for testing)
# dsp_dir="/home/iashraf/rough_work/backupTest/dst"
# Destination Parent Directory (my external usb disk)
dsp_dir="/media/iashraf/myPassport1G"

# Destination Directory (if multiple backups with date etc)
# comp="${HOSTNAME}"; dist="arch"; type="sysc"; date="$(date "+%F")"
# dst_dir="$dsp_dir"/"$comp"_"$date"_"$type"

# Destination Directory (a single backup)
dst_dir="$dsp_dir"/"BackupTRI"
 
# Include, exclude, and note file locations
# incl_file="${0}"-inc.txt
# incl_file="/home/iashraf/scripts_misc/backup-inc.txt"
incl_file="/home/iashraf/dotfiles/scripts/backup-inc.txt"
# excl_file="${0}"-exc.txt
# excl_file="/home/iashraf/scripts_misc/backup-exc.txt"
excl_file="/home/iashraf/dotfiles/scripts/backup-exc.txt"
# Source, Destination Parent Directories existence check
srd_dir_chk () {
for d in "$src_dir" "$dsp_dir"; do
  if [ ! -d "$d" ]; then
    echo " Directory "$d" doesn't exist." && exit
  else
    echo " Directory "$d" exists."
  fi
done
}
 
# Destination Directory existence check and creation
dst_dir_crt () {
if [ ! -d "$dst_dir" ]; then
  mkdir "$dst_dir"
  echo " Created destination directory "$dst_dir""
else
  echo " Destination directory "$comp"_"$date"_"$type" already exists."
fi
}
 
# ls -d -1 $PWD/*  can be used to make a list
scrp_help () {
echo " ${0##*/} <i|e|c> - backup configurations
  i - add to the include list a file or folder
  e - add to the exclude list a file or folder or regexp pattern
  c - create backup"
}
 
case $1 in
  i ) # Add to include list file or folder
      shift
      for f in "$@"; do
        # Check if selection(s) exist
        if [ ! -e "$f" ]; then
          echo " File \""$f"\" does not exist."
          continue
        fi
        # Append file/folder to include list
        full_path=$(readlink -f "$f")
        # `readlink -f` chomps trailing slash, if exists append
        [[ $(echo "$f" | rev | cut -b1) = / ]] && \
        full_path="$full_path/"
        echo "$full_path" >> "$incl_file" && \
        echo " Added \""$f"\" to ${incl_file##*/} include file."
      done
      # Sort entries, erase duplicates
      sort -u "$incl_file" -o "$incl_file" ;;
  e ) # Add to exclude list file or folder
      shift
      for f in "$@"; do
        # Check if selection(s) exist
        if [ ! -e "$f" ]; then
          echo " File \""$f"\" does not exist."
          continue
        fi
        # Append file/folder to include list
        full_path=$(readlink -f "$f")
        # `readlink -f` chomps trailing slash, if exists append
        [[ $(echo "$f" | rev | cut -b1) = / ]] && \
        full_path="$full_path/"
        echo "$full_path" >> "$excl_file" && \
        echo " Added \""$f"\" to ${excl_file##*/} exclude file."
      done
      # Sort entries, erase duplicates
      sort -u "$excl_file" -o "$excl_file" ;;
  c ) # Backup configurations
		startTime=
      srd_dir_chk
      dst_dir_crt
      time rsync -arxS --delete-excluded --files-from="$incl_file" --exclude-from="$excl_file" "$src_dir" "$dst_dir" ;;
  * ) # Display usage if no parameters give
      scrp_help ;;
esac

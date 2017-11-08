#!/bin/bash
if [ "$#" -ne 3 ]; then
  # only proceed if all parameters are given
  echo "Changing the GID of a group and modify ownership of its files and directories."
  echo "Usage: changeGID.sh [groupname] [oldGID] [newGID]" >&2
  exit 1
fi
 
# ask for confirmation
read -p "Changing the GID of group '$1' from $2 to $3. Proceed (y/n)? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  # check group
  GROUPEXISTS=$(cat /etc/group | grep -e "$1:[^:]*:$2" | wc -l)
  if [ "$GROUPEXISTS" -ne 1 ]; then
    echo "Group '$1' with GID $2 not found in /etc/group"
    echo "Aborted"
    exit 1
  fi
  # check if new GID is already in use
  GIDEXISTS=$(cat /etc/group | grep -e "[^:]*:[^:]*:$3" | wc -l)
  if [ "$GIDEXISTS" -ne 0 ]; then
    echo "GID $3 already exists."
    echo "Aborted"
    exit 1
  fi
  # modify GID, change ownership 
  groupmod -g $3 $1
  chown --changes --silent --no-dereference --recursive --from=:$2 :$3 /
  exit 0
fi
 
echo "Aborted"
exit 1

#!/bin/bash
######################################################
# wrapper to transfer specified file to remote server
# setup with keygen.sh https://github.com/centminmod/keygen
# written by George Liu (eva2000) centminmod.com
######################################################
# variables
#############
DT=$(date +"%d%m%y-%H%M%S")
REMOTEIPS=''

######################################################
# functions
#############

remote_sync() {
  f="$1"
  rip="$2"
  rport="$3"
  k="$4"
  rdir="$5"
  echo
  echo "transfer $f to root@${rip}:${rdir}"
  echo "rsync -avzi --progress --stats -e "ssh -p "${rport}" -i /root/.ssh/${k}" "$f" root@${rip}:${rdir}"
  rsync -avzi --progress --stats -e "ssh -p "${rport}" -i /root/.ssh/${k}" "$f" root@${rip}:${rdir}
  echo
  echo "check remote root@${rip}:${rdir}"
  echo "ssh -p "${rport}" -i /root/.ssh/${k} root@${rip} ls -lah ${rdir}"
  ssh -p "${rport}" -i /root/.ssh/${k} root@${rip} ls -lah ${rdir}
  echo
}


######################################################
file="$1"
remoteip="$2"
remoteport="$3"
keyname="$4"
remotedir="$5"

if [[ -z "$file" || -z "$remoteip" || -z "$remoteport" || ! -f "/root/.ssh/${keyname}" || -z "$remotedir" ]]; then
  echo
  echo "usage:"
  echo
  echo "$0 filename remoteip_addr remoteip_port sshkeyname remote_directory"
  echo
else
  remote_sync "$file" "$remoteip" "$remoteport" "$keyname" "$remotedir"
fi
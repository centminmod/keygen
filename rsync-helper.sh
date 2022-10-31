#!/bin/bash
#####################################################
# set locale temporarily to english
# due to some non-english locale issues
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
# disable systemd pager so it doesn't pipe systemctl output to less
export SYSTEMD_PAGER=''
#####################################################
# rsync-helper.sh interactive tool to generate a
# rsync command for remote transfers
#####################################################
DT=$(date +"%d%m%y-%H%M%S")
SCRIPTDIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"

SHOW_WARNINGS='n'
#####################################################
if [ ! -f /usr/bin/sshpass ]; then
  yum -y -q install sshpass
fi
if [ ! -f /usr/bin/rsync ]; then
  yum -y -q install rsync
fi
# variables to set in rsync-helper.ini as override variables
#
# rsync_privatekey=
# rsync_remoteuser=
# rsync_remotepass=
# rsync_remoteip=
# rsync_remoteport=
# rsync_sourcedir=
# rsync_remotedir=
#
if [ -f "${SCRIPTDIR}/rsync-helper.ini" ]; then
  source "${SCRIPTDIR}/rsync-helper.ini"
fi
if [ -f "/etc/centminmod/rsync-helper.ini" ]; then
  source "/etc/centminmod/rsync-helper.ini"
fi

rsync_transfer() {
  dryrun=$1
  privatekey=$2
  remoteuser=$3
  remoteip=$4
  remoteport=$5
  sourcedir=$6
  remotedir=$7
  if [[ "$dryrun" = [yY] ]]; then
    dryrun_opt='n'
  else
    dryrun_opt=""
  fi
  if [ -f $privatekey ]; then
    echo "rsync -avzi${dryrun_opt} --progress --stats -e \"ssh -p $remoteport -T -c aes128-gcm@openssh.com,aes256-gcm@openssh.com,chacha20-poly1305@openssh.com -o Compression=no -o StrictHostKeyChecking=no -x -i ${privatekey}\" ${sourcedir} ${remoteuser}@${remoteip}:${remotedir}"
  else
    echo "sshpass -p '$privatekey' rsync -avzi${dryrun_opt} --progress --stats -e \"ssh -p $remoteport -T -c aes128-gcm@openssh.com,aes256-gcm@openssh.com,chacha20-poly1305@openssh.com -o Compression=no -o StrictHostKeyChecking=no -x\" ${sourcedir} ${remoteuser}@${remoteip}:${remotedir}"
  fi
}

gen_key() {
  remoteuser=$1
  remotehost=$2
  remoteport=$3
  sshpassword=$4
  KEYNAME='cmmtransfer'
  KEYOPT='-t ed25519'
  echo "Generating SSH public/private key..."
  # Generate actual SSH Key Private + Public Key Pairs
  ssh-keygen $KEYOPT -N "" -f $HOME/.ssh/${KEYNAME}.key -C "cmmtransferkey"
  # SSH Key Fingerprint
  # ssh-keygen -lf $HOME/.ssh/${KEYNAME}.key.pub
  # SSH Public Key
  # cat "$HOME/.ssh/${KEYNAME}.key.pub"
  # Transfer SSH Public Key to remote server, you'd be prompted for 
  # remote server's root user password once time for this command
  echo "--------------------------------------------------------------------------------"
  echo "Run this command to copy the generated SSH public key for setup"
  echo "on remote server at: $remoteuser@$remotehost -p $remoteport"
  echo "--------------------------------------------------------------------------------"
  echo
  if [ -n "$sshpassword" ]; then
    echo "sshpass -p \"$sshpassword\" ssh-copy-id -o StrictHostKeyChecking=no -i $HOME/.ssh/${KEYNAME}.key.pub $remoteuser@$remotehost -p $remoteport"
    echo
    sshpass -p "$sshpassword" ssh-copy-id -o StrictHostKeyChecking=no -i $HOME/.ssh/${KEYNAME}.key.pub $remoteuser@$remotehost -p $remoteport
    export input_loginpass="$HOME/.ssh/${KEYNAME}.key"
  else
    echo "ssh-copy-id -o StrictHostKeyChecking=no -i $HOME/.ssh/${KEYNAME}.key.pub $remoteuser@$remotehost -p $remoteport"
  fi
  echo "--------------------------------------------------------------------------------"
  echo "After running ssh-copy-id, you will be able to SSH into remote server using command:"
  echo "--------------------------------------------------------------------------------"
  echo
  echo "ssh -o 'StrictHostKeyChecking=no' -p '$remoteport' '$remoteuser@$remotehost' -i $HOME/.ssh/${KEYNAME}.key"
  echo
}

rsync_gen() {
  echo
  echo "--------------------------------------------------------------------------------"
  echo "   Notes:"
  echo "--------------------------------------------------------------------------------"
  echo "Below questions will help you generate the required rsync comand line which"
  echo "you can then run to transfer local data to a remote server of your choice"
  echo
  echo "You will need to have the below info ready to answer the required questions:"
  echo
  echo "1. Your remote server's SSH login credentials"
  echo "   - your remote server root or user username/password"
  echo "   - or your SSH public/private key location on server"
  echo "   - your remote server's primary IP address"
  echo "   - your remote server's SSH port number i.e. 22 is default"
  echo "2. The full path to your source directory or file you want to transfer from"
  echo "3. The full path to your destination directory name you want to transfer to"
  echo "4. Optionally: decide if you want SSH public/private key generated for you"
  if [[ "$SHOW_WARNINGS" = [yY] ]]; then
    echo
    echo "--------------------------------------------------------------------------------"
    echo "   Warnings:"
    echo "--------------------------------------------------------------------------------"
    echo "1. Pay attention to destination directory name you want to transfer to"
    echo "   If you set it to a directory that already exists, you can overwrite"
    echo "   existing files within destination directory. If unsure, set destination"
    echo "   directory name to a new directory name. You can always transfer files later"
    echo "   on remote server to the right final destination directory."
  fi
  echo
  read -ep "Do you want to continue to generate your rsync command line? [y/n] : " continue_rsync
  echo
  if [[ "$continue_rsync" != [yY] ]]; then
    exit
  else
    read -ep "Does your remote server use passwords or SSH keys for SSH login? [p/k/both/unsure] : " input_login
    if [[ ! "$(echo $input_login | egrep 'p|k|both|unsure')" ]]; then
      echo
      echo "error: invalid input"
      echo
      echo "valid input options are: p, k, both, unsure"
      echo
      read -ep "Does your remote server use passwords or SSH keys for SSH login? [p/k/both/unsure] : " input_login
    fi
    read -ep "What is your remote server's primary IP address? " -i "$rsync_remoteip" input_loginip
    read -ep "What is your remote server's SSH port number? i.e. 22 : " -i "$rsync_remoteport" input_loginport
    read -ep "What is your remote server's SSH login username? i.e. root : " -i "$rsync_remoteuser" input_loginuser
    if [[ "$input_login" = 'both' || "$input_login" = 'unsure' ]]; then
      read -ep "What is your remote server's user = $input_loginuser password? " -i "$rsync_remotepass" input_loginpass
      read -ep "Does the user = $input_loginuser already have an existing SSH private key? [y/n] : " input_existing_key
      if [[ "$input_existing_key" = [yY] ]]; then
        read -ep "Full path to your remote server's user = $input_loginuser SSH private key? " -i "$rsync_privatekey" input_loginpass
      else
        read -ep "Do you want to generate a custom SSH private/public key for $input_loginuser? [y/n] : " input_genkey
        if [[ "$input_genkey" = [yY] ]]; then
          gen_key $input_loginuser $input_loginip $input_loginport $input_loginpass
        fi
      fi
    elif [[ "$input_login" = 'p' ]]; then
      read -ep "What is your remote server's user = $input_loginuser password? " -i "$rsync_remotepass" input_loginpass
    elif [[ "$input_login" = 'k' ]]; then
      read -ep "Does the user = $input_loginuser already have an existing SSH private key? [y/n] : " input_existing_key
      if [[ "$input_existing_key" = [yY] ]]; then
        read -ep "Full path to your remote server's user = $input_loginuser SSH private key? " -i "$rsync_privatekey" input_loginpass
      else
        read -ep "Do you want to generate a custom SSH private/public key for $input_loginuser? [y/n] : " input_genkey
        if [[ "$input_genkey" = [yY] ]]; then
          gen_key $input_loginuser $input_loginip $input_loginport
        fi
      fi
    fi
    echo
    echo "If source is a directory, whether it ends in forward slash or not matters"
    echo "/path/to/sourcedir/ will copy files within the source directory itself"
    echo "/path/to/sourcedir without ending slash will copy the source directory itself"
    echo
    read -ep "Full path to source directory or file you want to transfer? " -i "$rsync_sourcedir" input_source
    read -ep "Full path to remote server destination directory to save files to? " -i "$rsync_remotedir" input_destination
    echo
    echo "--------------------------------------------------------------------------------"
    echo "Generated rsync dry run only command:"
    echo "--------------------------------------------------------------------------------"
    rsync_transfer y $input_loginpass $input_loginuser $input_loginip $input_loginport $input_source ${input_destination}
    echo
    echo "--------------------------------------------------------------------------------"
    echo "Generated rsync live run only command:"
    echo "--------------------------------------------------------------------------------"
    rsync_transfer n $input_loginpass $input_loginuser $input_loginip $input_loginport $input_source ${input_destination}
    echo
  fi

}

rsync_gen
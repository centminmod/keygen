#!/bin/bash
################################################################
# ssh private key pair generator for centminmod.com lemp stacks
# 
# http://crypto.stackexchange.com/questions/2482/how-strong-is-the-ecdsa-algorithm
################################################################
# ssh-keygen -t rsa or ecdsa
KEYTYPE='rsa'
KEYNAME='my1'

RSA_KEYLENTGH='4096'
ECDSA_KEYLENTGH='256'
################################################################

if [ ! -d "$HOME/.ssh" ]; then
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
fi

if [ ! -f /usr/bin/sshpass ]; then
  yum -q -y install sshpass >/dev/null 2>&1
  SSHPASS='y'
elif [ -f /usr/bin/sshpass ]; then
  SSHPASS='y'
fi

keygen() {
    _keytype=$_input_keytype
    _remoteh=$_input_remoteh
    _remotep=$_input_remotep
    _remoteu=$_input_remoteu
    _comment=$_input_comment
    _sshpass=$_input_sshpass
    if [[ $_keytype = 'rsa' ]]; then
      KEYTYPE=$_keytype
      KEYOPT="-t rsa -b $RSA_KEYLENTGH"
    elif [[ $_keytype = 'ecdsa' ]]; then
      KEYTYPE=$_keytype
      KEYOPT="-t ecdsa -b $ECDSA_KEYLENTGH"
    elif [[ $_keytype = 'ed25519' ]]; then
      # openssh 6.7+ supports curve25519-sha256 cipher
      KEYTYPE=$_keytype
      KEYOPT='-t ed25519'
    elif [ -z $_keytype ]; then
      KEYTYPE="$KEYTYPE"
        if [[ "$KEYTYPE" = 'rsa' ]]; then
            KEYOPT="-t rsa -b $RSA_KEYLENTGH"
        elif [[ "$KEYTYPE" = 'ecdsa' ]]; then
            KEYOPT="-t ecdsa -b $ECDSA_KEYLENTGH"
        elif [[ "$KEYTYPE" = 'ed25519' ]]; then
            # openssh 6.7+ supports curve25519-sha256 cipher
            KEYOPT='-t ed25519'    
        fi
    fi
    echo
    echo "-------------------------------------------------------------------"
    echo "Generating Private Key Pair..."
    echo "-------------------------------------------------------------------"
    while [ -f "$HOME/.ssh/${KEYNAME}.key" ]; do
        NUM=$(echo $KEYNAME | awk -F 'y' '{print $2}')
        INCREMENT=$(echo $(($NUM+1)))
        KEYNAME="my${INCREMENT}"
    done
    if [ -z $_comment ]; then
      read -ep "enter comment description for key: " keycomment
    else
      keycomment=$_comment
    fi
    echo "ssh-keygen $KEYOPT -N "" -f $HOME/.ssh/${KEYNAME}.key -C "$keycomment""
    ssh-keygen $KEYOPT -N "" -f $HOME/.ssh/${KEYNAME}.key -C "$keycomment"

    echo
    echo "-------------------------------------------------------------------"
    echo "${KEYNAME}.key.pub public key"
    echo "-------------------------------------------------------------------"
    echo "ssh-keygen -lf $HOME/.ssh/${KEYNAME}.key.pub"
    echo "[size --------------- fingerprint ---------------     - comment - type]"
    echo " $(ssh-keygen -lf $HOME/.ssh/${KEYNAME}.key.pub)"
    
    echo
    echo "cat $HOME/.ssh/${KEYNAME}.key.pub"
    cat "$HOME/.ssh/${KEYNAME}.key.pub"
    
    echo
    echo "-------------------------------------------------------------------"
    echo "$HOME/.ssh contents" 
    echo "-------------------------------------------------------------------"
    ls -lahrt "$HOME/.ssh"

    echo
    echo "-------------------------------------------------------------------"
    echo "Transfering ${KEYNAME}.key.pub to remote host"
    echo "-------------------------------------------------------------------"
    if [ -z $_remoteh ]; then
      read -ep "enter remote ip address or hostname: " remotehost
    else
      remotehost=$_remoteh
    fi
    if [ -z $_remotep ]; then
      read -ep "enter remote ip/host port number i.e. 22: " remoteport
    else
      remoteport=$_remotep
    fi
    if [ -z $_remoteu ]; then
      read -ep "enter remote ip/host username i.e. root: " remoteuser
    else
      remoteuser=$_remoteu
    fi
    if [[ "$SSHPASS" = [yY] ]]; then
      if [ -z $_sshpass ]; then
        read -ep "enter remote ip/host username SSH password: " sshpassword
      else
        sshpassword=$_sshpass
      fi
    fi
    if [[ "$(ping -c1 $remotehost -W 2 >/dev/null 2>&1; echo $?)" = '0' ]]; then
        VALIDREMOTE=y
    echo
    echo "-------------------------------------------------------------------"
    echo "you MAYBE prompted for remote ip/host password"
    echo "enter below command to copy key to remote ip/host"
    echo "-------------------------------------------------------------------"
    echo 
    else
    echo
    echo "-------------------------------------------------------------------"
    echo "enter below command to copy key to remote ip/host"
    echo "-------------------------------------------------------------------"
    echo 
    fi
    if [[ "$SSHPASS" = [yY] ]]; then
      echo "sshpass -p "$sshpassword" ssh-copy-id -o StrictHostKeyChecking=no -i $HOME/.ssh/${KEYNAME}.key.pub $remoteuser@$remotehost -p $remoteport"
    else
      echo "ssh-copy-id -i $HOME/.ssh/${KEYNAME}.key.pub $remoteuser@$remotehost -p $remoteport"
    fi
    if [[ "$VALIDREMOTE" = 'y' ]]; then
      pushd "$HOME/.ssh" >/dev/null 2>&1
      if [[ "$SSHPASS" = [yY] ]]; then
        sshpass -p "$sshpassword" ssh-copy-id -o StrictHostKeyChecking=no -i $HOME/.ssh/${KEYNAME}.key.pub "$remoteuser@$remotehost" -p "$remoteport"
      else  
        ssh-copy-id -i $HOME/.ssh/${KEYNAME}.key.pub "$remoteuser@$remotehost" -p "$remoteport"
      fi
      SSHCOPYERR=$?
      popd >/dev/null 2>&1
    fi

    if [[ "$VALIDREMOTE" = 'y' && "$SSHCOPYERR" = '0' ]]; then
      echo
      echo "-------------------------------------------------------------------"
      echo "Testing connection"
      echo "-------------------------------------------------------------------"
      echo
      echo "ssh $remoteuser@$remotehost -p $remoteport -i $HOME/.ssh/${KEYNAME}.key \"uname -a\""
      ssh "$remoteuser@$remotehost" -p "$remoteport" -i $HOME/.ssh/${KEYNAME}.key "uname -a"

      echo
      echo "-------------------------------------------------------------------"
      echo "Setup source server file ${HOME}/.ssh/config"
      echo "-------------------------------------------------------------------"
      echo
      echo "Add to ${HOME}/.ssh/config:"
      echo
      echo "Host ${remotehost}-${KEYNAME}"
      echo "  Hostname $remotehost"
      echo "  Port $remoteport"
      echo "  IdentityFile $HOME/.ssh/${KEYNAME}.key"
      echo "  User $(id -u -n)"
      echo
      echo "-------------------------------------------------------------------"
      echo "Once ${HOME}/.ssh/config entry added, can connect via Host label:"
      echo " ${remotehost}-${KEYNAME}"
      echo "-------------------------------------------------------------------"
      echo
      echo "ssh ${remotehost}-${KEYNAME}"
    fi
    echo
    echo "-------------------------------------------------------------------"
}

case "$1" in
    gen )
    _input_keytype=$2
    _input_remoteh=$3
    _input_remotep=$4
    _input_remoteu=$5
    _input_comment=$6
    _input_sshpass=$7
    keygen
        ;;
    * )
    echo "  $0 {gen}"
    echo "  $0 {gen} keytype remoteip remoteport remoteuser keycomment remotessh_password"
    echo
    echo "  keytype supported: rsa, ecdsa, ed25519"
        ;;
esac
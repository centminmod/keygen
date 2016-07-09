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

if [ ! -d ~/.ssh ]; then
  mkdir -p ~/.ssh
  chmod 700 ~/.ssh
fi

keygen() {
    _keytype=$1
    if [[ "$_keytype" = 'rsa' ]]; then
      KEYTYPE="$_keytype"
      KEYOPT="-t rsa -b $RSA_KEYLENTGH"
    elif [[ "$_keytype" = 'ecdsa' ]]; then
      KEYTYPE="$_keytype"
      KEYOPT="-t ecdsa -b $ECDSA_KEYLENTGH"
    elif [[ "$_keytype" = 'ed25519' ]]; then
      # openssh 6.7+ supports curve25519-sha256 cipher
      KEYTYPE="$_keytype"
      KEYOPT='-t ed25519'
    elif [[ -z "$_keytype" ]]; then
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
    read -ep "enter comment description for key: " keycomment
    ssh-keygen $KEYOPT -N "" -f ~/.ssh/${KEYNAME}.key -C "$keycomment"

    echo
    echo "-------------------------------------------------------------------"
    echo "${KEYNAME}.key.pub public key"
    echo "-------------------------------------------------------------------"
    echo "ssh-keygen -lf ~/.ssh/${KEYNAME}.key.pub"
    echo "[size --------------- fingerprint ---------------    - comment - type]"
    ssh-keygen -lf ~/.ssh/${KEYNAME}.key.pub
    
    echo
    echo "cat ~/.ssh/${KEYNAME}.key.pub"
    cat ~/.ssh/${KEYNAME}.key.pub
    
    echo
    echo "-------------------------------------------------------------------"
    echo "~/.ssh contents" 
    echo "-------------------------------------------------------------------"
    ls -lahrt ~/.ssh

    echo
    echo "-------------------------------------------------------------------"
    echo "transfering ${KEYNAME}.key.pub to remote host"
    echo "-------------------------------------------------------------------"
    read -ep "enter remote ip address or hostname: " remotehost
    read -ep "enter remote ip/host port number i.e. 22: " remoteport
    read -ep "enter remote ip/host username i.e. root: " remoteuser

    if [[ "$(ping -c1 $remotehost -W 2 >/dev/null 2>&1; echo $?)" = '0' ]]; then
        VALIDREMOTE=y
    echo
    echo "-------------------------------------------------------------------"
    echo "you'll be prompted for remote ip/host password"
    echo "-------------------------------------------------------------------"
    echo 
    else
    echo
    echo "-------------------------------------------------------------------"
    echo "command to copy key to remote ip/host"
    echo "-------------------------------------------------------------------"
    echo 
    fi
    echo "ssh-copy-id -i ~/.ssh/${KEYNAME}.key $remoteuser@$remotehost -p $remoteport"
    if [[ "$VALIDREMOTE" = 'y' ]]; then
      ssh-copy-id -i "~/.ssh/${KEYNAME}.key" "$remoteuser@$remotehost" -p "$remoteport"
    fi

    if [[ "$VALIDREMOTE" = 'y' ]]; then
      echo
      echo "-------------------------------------------------------------------"
      echo "testing connection"
      echo "-------------------------------------------------------------------"
      echo
      echo "ssh $remoteuser@$remotehost -p $remoteport -i ~/.ssh/${KEYNAME}.key"
      ssh "$remoteuser@$remotehost" -p "$remoteport" -i "~/.ssh/${KEYNAME}.key"
    fi
    echo
    echo "-------------------------------------------------------------------"
}

keygen
#!/bin/bash
################################################################
# ssh private key pair generator for centminmod.com lemp stacks
################################################################
KEYNAME='my1'

keygen() {
    echo
    echo "-------------------------------------------------------------------"
    echo "Generating Private Key Pair..."
    echo "-------------------------------------------------------------------"
    ssh-keygen -t rsa -N "" -f ~/.ssh/${KEYNAME}.key

    echo
    echo "-------------------------------------------------------------------"
    echo "${KEYNAME}.key.pub public key"
    echo "-------------------------------------------------------------------"
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

    echo
    echo "-------------------------------------------------------------------"
    echo "you'll be prompted for remote ip/host password"
    echo "-------------------------------------------------------------------"
    echo 
    echo "ssh-copy-id -i ~/.ssh/${KEYNAME}.key $remoteuser@$remotehost -p $remoteport"
    ssh-copy-id -i ~/.ssh/${KEYNAME}.key $remoteuser@$remotehost -p $remoteport

    echo
    echo "-------------------------------------------------------------------"
    echo "testing connection"
    echo "-------------------------------------------------------------------"
    echo
    echo "ssh $remoteuser@$remotehost -p $remoteport -i ~/.ssh/${KEYNAME}.key"
    ssh $remoteuser@$remotehost -p $remoteport -i ~/.ssh/${KEYNAME}.key

    echo
    echo "-------------------------------------------------------------------"
}

keygen
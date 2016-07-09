usage

    ./keygen.sh
    keygen.sh {gen}
    keygen.sh {gen} keytype remoteip remoteport remoteuser keycomment
    
    keytype supported: rsa, ecdsa, ed25519

unattended mode

generata rsa key pair

    keygen.sh gen rsa 1.1.1.1 22 root comment

generate ecdsa key pair

    keygen.sh gen ecdsa 1.1.1.1 22 root comment

generate ed25519 key pair

    keygen.sh gen ed25519 1.1.1.1 22 root comment


ssh private rsa or ecdsa key pair generator

example for ssh-keygen with ed25519 ciphers on CentOS 6.7 with OpenSSH 5.3 updated to OpenSSH 7.1p1

    ssh-keygen $KEYOPT -N "" -f ~/.ssh/${KEYNAME}.key

    Generating public/private ed25519 key pair.
    Created directory '/root/.ssh'.
    Your identification has been saved in /root/.ssh/my1.key.
    Your public key has been saved in /root/.ssh/my1.key.pub.
    The key fingerprint is:
    SHA256:6ZpM8wtpqGtOMMZgYyEuLNHCQKTY/eMynLAyRqj9/cY root@hostname
    The key's randomart image is:
    +--[ED25519 256]--+
    |O=               |
    |B+o.             |
    |*B. .            |
    |O .  .   .       |
    |++.   o S        |
    |++ + + +         |
    |+.+ * B..        |
    |.+.o B *E        |
    | o+.. =o+.       |
    +----[SHA256]-----+

example ecdsa key connection to REMOTEIP

    ssh $remoteuser@$remotehost -p $remoteport -i ~/.ssh/${KEYNAME}.key -v
    
    OpenSSH_6.6.1, OpenSSL 1.0.1e-fips 11 Feb 2013
    debug1: Reading configuration data /etc/ssh/ssh_config
    debug1: /etc/ssh/ssh_config line 56: Applying options for *
    debug1: Connecting to REMOTEIP [REMOTEIP] port 22.
    debug1: Connection established.
    debug1: permanently_set_uid: 0/0
    debug1: identity file /root/.ssh/my1.key type 3
    debug1: identity file /root/.ssh/my1.key-cert type -1
    debug1: Enabling compatibility mode for protocol 2.0
    debug1: Local version string SSH-2.0-OpenSSH_6.6.1
    debug1: Remote protocol version 2.0, remote software version OpenSSH_5.3
    debug1: match: OpenSSH_5.3 pat OpenSSH_5* compat 0x0c000000
    debug1: SSH2_MSG_KEXINIT sent
    debug1: SSH2_MSG_KEXINIT received
    debug1: kex: server->client aes128-ctr hmac-md5 none
    debug1: kex: client->server aes128-ctr hmac-md5 none
    debug1: kex: diffie-hellman-group-exchange-sha256 need=16 dh_need=16
    debug1: kex: diffie-hellman-group-exchange-sha256 need=16 dh_need=16
    debug1: SSH2_MSG_KEX_DH_GEX_REQUEST(1024<3072<8192) sent
    debug1: expecting SSH2_MSG_KEX_DH_GEX_GROUP
    debug1: SSH2_MSG_KEX_DH_GEX_INIT sent
    debug1: expecting SSH2_MSG_KEX_DH_GEX_REPLY
    debug1: Server host key: RSA b5:8f:a7:91:5b:07:b0:8b:cd:f6:34:5d:e5:1c:d9:01
    debug1: Host 'REMOTEIP' is known and matches the RSA host key.
    debug1: Found key in /root/.ssh/known_hosts:1
    debug1: ssh_rsa_verify: signature correct
    debug1: SSH2_MSG_NEWKEYS sent
    debug1: expecting SSH2_MSG_NEWKEYS
    debug1: SSH2_MSG_NEWKEYS received
    debug1: Roaming not allowed by server
    debug1: SSH2_MSG_SERVICE_REQUEST sent
    debug1: SSH2_MSG_SERVICE_ACCEPT received
    debug1: Authentications that can continue: publickey,password
    debug1: Next authentication method: publickey
    debug1: Offering RSA public key: DO1
    debug1: Authentications that can continue: publickey,password
    debug1: Offering ECDSA public key: /root/.ssh/my1.key
    debug1: Server accepts key: pkalg ecdsa-sha2-nistp521 blen 172
    debug1: key_parse_private2: missing begin marker
    debug1: read PEM private key done: type ECDSA
    debug1: Authentication succeeded (publickey).
    Authenticated to REMOTEIP ([REMOTEIP]:22).
    debug1: channel 0: new [client-session]
    debug1: Requesting no-more-sessions@openssh.com
    debug1: Entering interactive session.
    debug1: Sending environment.
    debug1: Sending env LANG = en_US.UTF-8
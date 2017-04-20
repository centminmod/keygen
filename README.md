usage
===

You can use `gen` command to generate SSH key pairs or use `rotatekeys` command to rotate an existing SSH key

Where remote server's SSH password is optionally set via `remotessh_password`

    ./keygen.sh 
    -------------------------------------------------------------------------
    ./keygen.sh {gen}
    ./keygen.sh {gen} keytype remoteip remoteport remoteuser keycomment
    
    or
    
    ./keygen.sh {gen} keytype remoteip remoteport remoteuser keycomment remotessh_password
    
    -------------------------------------------------------------------------
    ./keygen.sh {rotatekeys}
    ./keygen.sh {rotatekeys} keytype remoteip remoteport remoteuser keycomment keyname
    
    -------------------------------------------------------------------------
    keytype supported: rsa, ecdsa, ed25519

unattended mode
===

If you do not pass on command line the last argument for `remotessh_password` for SSH user password, then when you run `keygen.sh` unattended at `ssh-copy-id` step you will be prompted for remote SSH user's SSH password for one time only to setup remote server's `authorized_keys` file. If you pass `remotessh_password` on command line, at `ssh-copy-id` step you will not be asked for SSH user's SSH password as `keygen.sh` installs and sets up `sshpass` to handle input for SSH password without user input.

Running unattended mode will also attempt to copy the generated public key over to the defined remote server's `$HOME/.ssh/authorized_keys` file so prompt you to do a one time login to the remote server via the password (only if you do not pass `remotessh_password` on command line). Then it will do a test ssh connection to the remote server using the newly generated key pair.

You'll end up with private and public key files named my`X` where `X` is a number which would increment automatically if you re-run this command on same server.

* private key at `$HOME/.ssh/my1.key`
* public key at `$HOME/.ssh/my1.key.pub`

Where:

* `1.1.1.1` is remote server IP
* `22` is remote server SSH port
* `root` is username for remote SSH user
* `comment` is unique identifying name i.e. `mykey@clienthostname` for setting up a Shell aliases further below. Also helps you to revoke the ssh key matching on this `comment`
* `remotessh_password` for SSH user password,

To generate rsa key pair where `comment` is a unique identifier for your generated key i.e. `mykey@clienthostname` and you pass the remote SSH user's SSH password via `remotessh_password` at `ssh-copy-id` step

    keygen.sh gen rsa 1.1.1.1 22 root comment remotessh_password

To generate rsa key pair where `comment` is a unique identifier for your generated key i.e. `mykey@clienthostname` without `remotessh_password`. At `ssh-copy-id` step you will be prompted for remote SSH user's SSH password

    keygen.sh gen rsa 1.1.1.1 22 root comment

To generate ecdsa key pair where `comment` is a unique identifier for your generated key i.e. `mykey@clienthostname` without `remotessh_password`. At `ssh-copy-id` step you will be prompted for remote SSH user's SSH password

    keygen.sh gen ecdsa 1.1.1.1 22 root comment

To generate ed25519 key pair where `comment` is a unique identifier for your generated key i.e. `mykey@clienthostname` without `remotessh_password`. At `ssh-copy-id` step you will be prompted for remote SSH user's SSH password

    keygen.sh gen ed25519 1.1.1.1 22 root comment

Once run is complete, you'll now be able to ssh into remote server with just specifying the path to your private key you generated

    ssh root@remoteip -p 22 -i ~/.ssh/my1.key

Output also lists instructions for setting up `~/.ssh/config` for Shell aliases where `mykey@clienthostname` is your `comment` defined above.

    -------------------------------------------------------------------
    Setup source server file /root/.ssh/config
    -------------------------------------------------------------------
    
    Add to /root/.ssh/config:
    
    Host mykey@clienthostname
      Hostname 1.1.1.1
      Port 22
      IdentityFile /root/.ssh/my1.key
      User root
    
    -------------------------------------------------------------------
    Once /root/.ssh/config entry added, can connect via Host label:
     mykey@clienthostname
    -------------------------------------------------------------------

    ssh mykey@clienthostname

So you'll be able to ssh into remote server via SSH shell alias for Host label

    ssh mykey@clienthostname

Removing public key from remote server
===

To revoke a public key from your remote server so that the source data server can not connect to the remote server anymore, you need to remove the generated public key from remote server's `/root/.ssh/authorized_keys` file. You can use the comment i.e. `mykey@clienthostname` as a filter for sed deletion of the line.

On remote server run command where `mykey@clienthostname` is your comment you specified when you generated your key pair.

    sed -i '/mykey@clienthostname$/d' /root/.ssh/authorized_keys 

If you setup a SSH aliase in `~/.ssh/config`, then you also need to remove the entry for `mykey@clienthostname`

Rotate Existing SSH Key
===

New `rotatekeys` command allows you to rotate an existing SSH key both on local and remote server end. This assumes you are running `keygen.sh` on the same server that initially generated the existing SSH key on the server via `gen` command

generated with (where remoter ssh root password = `remotessh_password`)

    ./keygen.sh {gen} keytype remoteip remoteport remoteuser keycomment remotessh_password

rotated with

    ./keygen.sh {rotatekeys} keytype remoteip remoteport remoteuser keycomment keyname

**Example:**

generated with (where comment = `mykey@clienthostname` and where remoter ssh root password = `remotessh_password`)

    ./keygen.sh gen rsa 1.1.1.1 22 root mykey@clienthostname remotessh_password

resulting in key = `my1.key` so keyname = `my1`

    -------------------------------------------------------------------
    /root/.ssh contents
    -------------------------------------------------------------------
    total 12K
    dr-xr-x---. 8 root root 4.0K Apr 20 17:14 ..
    -rw-------  1 root root 3.2K Apr 20 17:17 my1.key
    -rw-r--r--  1 root root  736 Apr 20 17:17 my1.key.pub
    drwx------  2 root root   38 Apr 20 17:17 .

rotated with indentifying keyname = `my1`

    ./keygen.sh rotatekeys rsa 1.1.1.1 22 root mykey@clienthostname my1

full output

    ./keygen.sh rotatekeys rsa 1.1.1.1 22 root mykey@clienthostname my1
    
    -------------------------------------------------------------------
    Rotating Private Key Pair...
    -------------------------------------------------------------------
    ssh-keygen -t rsa -b 4096 -N  -f /root/.ssh/my1.key -C my1comment
    Generating public/private rsa key pair.
    Your identification has been saved in /root/.ssh/my1.key.
    Your public key has been saved in /root/.ssh/my1.key.pub.
    The key fingerprint is:
    9c:8b:f7:74:44:27:79:6b:36:3b:29:e7:98:c2:3f:5e my1comment
    The key's randomart image is:
    +--[ RSA 4096]----+
    |                 |
    |             .   |
    |            + o  |
    |       . . . + . |
    |        S   . =  |
    |       . . . o + |
    |      . o.. o E  |
    |       . oo..B . |
    |          .+=..  |
    +-----------------+
    
    -------------------------------------------------------------------
    my1.key.pub public key
    -------------------------------------------------------------------
    ssh-keygen -lf /root/.ssh/my1.key.pub
    [size --------------- fingerprint ---------------     - comment - type]
    4096 9c:8b:f7:74:44:27:79:6b:36:3b:29:e7:98:c2:3f:5e  my1comment (RSA)
    
    cat /root/.ssh/my1.key.pub
    ssh-rsa AAAAB3NzaC1..NEW..w== my1comment
    
    -------------------------------------------------------------------
    /root/.ssh contents
    -------------------------------------------------------------------
    total 24K
    dr-xr-x---. 8 root root 4.0K Apr 20 17:14 ..
    -rw-r--r--  1 root root  175 Apr 20 17:17 known_hosts
    -rw-r--r--  1 root root  736 Apr 20 17:17 my1-old.key.pub
    -rw-------  1 root root 3.2K Apr 20 17:17 my1-old.key
    -rw-r--r--  1 root root  736 Apr 20 17:30 my1.key.pub
    -rw-------  1 root root 3.2K Apr 20 17:30 my1.key
    drwx------  2 root root   96 Apr 20 17:30 .
    
    -------------------------------------------------------------------
    Transfering my1.key.pub to remote host
    -------------------------------------------------------------------
    
    -------------------------------------------------------------------
    you MAYBE prompted for remote ip/host password
    enter below command to copy key to remote ip/host
    -------------------------------------------------------------------
    
    rotate and replace old public key from remote: root@1.1.1.1
    ssh root@1.1.1.1 -p 22 -i /root/.ssh/my1-old.key "sed -i 's|ssh-rsa AAAAB3NzaC1..OLD...gw== my1comment|ssh-rsa AAAAB3NzaC1..NEW..w== my1comment|' /root/.ssh/authorized_keys"
    
    
    -------------------------------------------------------------------
    Testing connection
    -------------------------------------------------------------------
    
    ssh root@1.1.1.1 -p 22 -i /root/.ssh/my1.key "uname -a"
    Linux remote.localdomain 2.6.32-642.13.1.el6.x86_64 #1 SMP Wed Jan 11 20:56:24 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux
    
    -------------------------------------------------------------------
    Setup source server file /root/.ssh/config
    -------------------------------------------------------------------
    
    Add to /root/.ssh/config:
    
    Host my1
    Hostname 1.1.1.1
    Port 22
    IdentityFile /root/.ssh/my1.key
    User root
    
    -------------------------------------------------------------------
    Once /root/.ssh/config entry added, can connect via Host label:
    my1
    -------------------------------------------------------------------
    
    ssh my1
    
    -------------------------------------------------------------------
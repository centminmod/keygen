* [With both SSH password & SSH key Logins](#with-both-ssh-password--ssh-key-logins)
* [With both SSH password & SSH key Login Auto Generated](#with-both-ssh-password--ssh-key-login-auto-generated)
  * [dry run rsync](#dry-run-rsync)

# With both SSH password & SSH key Logins

And `SHOW_WARNINGS='y'` set.

```
./rsync-helper.sh 

--------------------------------------------------------------------------------
   Notes:
--------------------------------------------------------------------------------
Below questions will help you generate the required rsync comand line which
you can then run to transfer local data to a remote server of your choice

You will need to have the below info ready to answer the required questions:

1. Your remote server's SSH login credentials
   - your remote server root or user username/password
   - or your SSH public/private key location on server
   - your remote server's primary IP address
   - your remote server's SSH port number i.e. 22 is default
2. The full path to your source directory or file you want to transfer from
3. The full path to your destination directory name you want to transfer to
4. Optionally: decide if you want SSH public/private key generated for you

--------------------------------------------------------------------------------
   Warnings:
--------------------------------------------------------------------------------
1. Pay attention to destination directory name you want to transfer to
   If you set it to a directory that already exists, you can overwrite
   existing files within destination directory. If unsure, set destination
   directory name to a new directory name. You can always transfer files later
   on remote server to the right final destination directory.

Do you want to continue to generate your rsync command line? [y/n] : y

Does your remote server use passwords or SSH keys for SSH login? [p/k/both/unsure] : both
What is your remote server's primary IP address? 111.222.333.444
What is your remote server's SSH port number? i.e. 22 : 22
What is your remote server's SSH login username? i.e. root : root
What is your remote server's user = root password? ROOT_PASSWORD
Does the user = root already have an existing SSH private key? [y/n] : y
Full path to your remote server's user = root SSH private key? /root/.ssh/cmmtransfer.key

If source is a directory, whether it ends in forward slash or not matters
/path/to/sourcedir/ will copy files within the source directory itself
/path/to/sourcedir without ending slash will copy the source directory itself

Full path to source directory or file you want to transfer? /path/to/myfile.tar
Full path to remote server destination directory to save files to? /home/destination_dir

--------------------------------------------------------------------------------
Generated rsync dry run only command:
--------------------------------------------------------------------------------
rsync -avzin --progress --stats -e "ssh -p 22 -T -c aes128-gcm@openssh.com,aes256-gcm@openssh.com,chacha20-poly1305@openssh.com -o Compression=no -o StrictHostKeyChecking=no -x -i /root/.ssh/cmmtransfer.key" /path/to/myfile.tar root@111.222.333.444:/home/destination_dir

--------------------------------------------------------------------------------
Generated rsync live run only command:
--------------------------------------------------------------------------------
rsync -avzi --progress --stats -e "ssh -p 22 -T -c aes128-gcm@openssh.com,aes256-gcm@openssh.com,chacha20-poly1305@openssh.com -o Compression=no -o StrictHostKeyChecking=no -x -i /root/.ssh/cmmtransfer.key" /path/to/myfile.tar root@111.222.333.444:/home/destination_dir
```

# With both SSH password & SSH key Login Auto Generated

And `SHOW_WARNINGS='n'` set.

```
./rsync-helper.sh 

--------------------------------------------------------------------------------
   Notes:
--------------------------------------------------------------------------------
Below questions will help you generate the required rsync comand line which
you can then run to transfer local data to a remote server of your choice

You will need to have the below info ready to answer the required questions:

1. Your remote server's SSH login credentials
   - your remote server root or user username/password
   - or your SSH public/private key location on server
   - your remote server's primary IP address
   - your remote server's SSH port number i.e. 22 is default
2. The full path to your source directory or file you want to transfer from
3. The full path to your destination directory name you want to transfer to
4. Optionally: decide if you want SSH public/private key generated for you

Do you want to continue to generate your rsync command line? [y/n] : y

Does your remote server use passwords or SSH keys for SSH login? [p/k/both/unsure] : unsure
What is your remote server's primary IP address? 111.222.333.444
What is your remote server's SSH port number? i.e. 22 : 22
What is your remote server's SSH login username? i.e. root : root
What is your remote server's user = root password? ROOT_PASSWORD
Does the user = root already have an existing SSH private key? [y/n] : n
Do you want to generate a custom SSH private/public key for root? [y/n] : y
Generating SSH public/private key...
Generating public/private ed25519 key pair.
/root/.ssh/cmmtransfer.key already exists.
Overwrite (y/n)? y
Your identification has been saved in /root/.ssh/cmmtransfer.key.
Your public key has been saved in /root/.ssh/cmmtransfer.key.pub.
The key fingerprint is:
SHA256:JiHCu6toHMk0ihBRsMQznDsJABUA69FdgtrBjNTTM0g cmmtransferkey
The key's randomart image is:
+--[ED25519 256]--+
|#O@E+. .         |
|+@.O.+o          |
|+oX.+.+          |
|oB.+ . .         |
|*.=   . S        |
|o+ .   o         |
|. o              |
|.o .             |
|+..              |
+----[SHA256]-----+
--------------------------------------------------------------------------------
Run this command to copy the generated SSH public key for setup
on remote server at: root@111.222.333.444 -p 22
--------------------------------------------------------------------------------

sshpass -p "ROOT_PASSWORD" ssh-copy-id -o StrictHostKeyChecking=no -i /root/.ssh/cmmtransfer.key.pub root@111.222.333.444 -p 22

/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/root/.ssh/cmmtransfer.key.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh -o 'StrictHostKeyChecking=no' -p '22' 'root@111.222.333.444'"
and check to make sure that only the key(s) you wanted were added.

--------------------------------------------------------------------------------
After running ssh-copy-id, you will be able to SSH into remote server using command:
--------------------------------------------------------------------------------

ssh -o 'StrictHostKeyChecking=no' -p '22' 'root@111.222.333.444' -i /root/.ssh/cmmtransfer.key


If source is a directory, whether it ends in forward slash or not matters
/path/to/sourcedir/ will copy files within the source directory itself
/path/to/sourcedir without ending slash will copy the source directory itself

Full path to source directory or file you want to transfer? /path/to/myfile.tar
Full path to remote server destination directory to save files to? /home/destination_dir


--------------------------------------------------------------------------------
setup CSF Firewall outbound TCP connection in /etc/csf/csf.allow
--------------------------------------------------------------------------------
add:

tcp|out|d=22|d=111.222.333.444 # rsync-helper

--------------------------------------------------------------------------------
Generated rsync dry run only command:
--------------------------------------------------------------------------------
rsync -avzin --progress --stats -e "ssh -p 22 -T -c aes128-gcm@openssh.com,aes256-gcm@openssh.com,chacha20-poly1305@openssh.com -o Compression=no -o StrictHostKeyChecking=no -x -i /root/.ssh/cmmtransfer.key" /path/to/myfile.tar root@111.222.333.444:/home/destination_dir

--------------------------------------------------------------------------------
Generated rsync live run only command:
--------------------------------------------------------------------------------
rsync -avzi --progress --stats -e "ssh -p 22 -T -c aes128-gcm@openssh.com,aes256-gcm@openssh.com,chacha20-poly1305@openssh.com -o Compression=no -o StrictHostKeyChecking=no -x -i /root/.ssh/cmmtransfer.key" /path/to/myfile.tar root@111.222.333.444:/home/destination_dir
```

# dry run rsync

```
rsync -avzin --progress --stats -e "ssh -p 22 -T -c aes128-gcm@openssh.com,aes256-gcm@openssh.com,chacha20-poly1305@openssh.com -o Compression=no -o StrictHostKeyChecking=no -x -i /root/.ssh/cmmtransfer.key" /path/to/myfile.tar root@111.222.333.444:/home/destination_dir
sending incremental file list
<f+++++++++ myfile.tar

Number of files: 1 (reg: 1)
Number of created files: 1 (reg: 1)
Number of deleted files: 0
Number of regular files transferred: 1
Total file size: 9,334 bytes
Total transferred file size: 9,334 bytes
Literal data: 0 bytes
Matched data: 0 bytes
File list size: 0
File list generation time: 0.001 seconds
File list transfer time: 0.000 seconds
Total bytes sent: 56
Total bytes received: 19

sent 56 bytes  received 19 bytes  150.00 bytes/sec
total size is 9,334  speedup is 124.45 (DRY RUN)
```
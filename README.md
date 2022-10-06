# Sepulcher [![Actions Status](https://github.com/Fullaxx/sepulcher/workflows/CI/badge.svg)](https://github.com/Fullaxx/sepulcher/actions)
A docker tomb for your encrypted messages built from
* [OpenSSL](https://www.openssl.org/)
* [webstore](https://github.com/Fullaxx/webstore)
* [CHAOSgen](https://github.com/Fullaxx/CHAOSgen)

## About this Software
Sepulcher is designed for those who want full control over their communications.
It provides an alternative to typical key/message distribution methods.
For example, maybe you don't want your public key made available to the everyone.
Maybe you want to distribute a different set of keys to different recipients.
Maybe you don't want all your encrypted communications left in someone else's mailbox until the end of time.
Sepulcher facilitates the distribution of encrypted data on systems that you control.

## Base Docker Image
[Ubuntu](https://hub.docker.com/_/ubuntu) 20.04 (x64)

## Get the image from Docker Hub or build it yourself
```
docker pull fullaxx/sepulcher
docker build -t="fullaxx/sepulcher" github.com/Fullaxx/sepulcher
```

## Launch Sepulcher Docker Container (HTTPS mode)
<code>KSHOST</code> and <code>KSPORT</code> are the ENV variables to specify the webstore service for key transmission/retrieval. \
<code>MSHOST</code> and <code>MSPORT</code> are the ENV variables to specify the webstore service for message transmission/retrieval. \
<code>KSSEC</code> and <code>MSSEC</code> indicate that HTTPS must be used to negotiate with the services. \
The following will use the webstore services at https://keys.dspi.org:443 and https://msgs.dspi.org:443
```
docker run -it \
-e KSHOST=keys.dspi.org -e KSPORT=443 -e KSSEC=1 \
-e MSHOST=msgs.dspi.org -e MSPORT=443 -e MSSEC=1 \
-v /srv/docker/sepulcher/data:/data \
fullaxx/sepulcher
```

## Launch Sepulcher Docker Container (HTTP mode)
<code>KSHOST</code> and <code>KSPORT</code> are the ENV variables to specify the webstore service for key transmission/retrieval. \
<code>MSHOST</code> and <code>MSPORT</code> are the ENV variables to specify the webstore service for message transmission/retrieval. \
The following will use the webstore services at http://keys.dspi.org:80 and http://msgs.dspi.org:80
```
docker run -it \
-e KSHOST=keys.dspi.org -e KSPORT=80 \
-e MSHOST=msgs.dspi.org -e MSPORT=80 \
-v /srv/docker/sepulcher/data:/data \
fullaxx/sepulcher
```

## Step 1: Publish your Identity
publish_identity.sh will generate your private key and create your public certificate. \
The first argument is the amount of days that your certificate is valid. \
Once your identity is created, it will publish your certificate to the keyserver. \
An Identity Token is printed so that others can retrieve your identity. \
Alice can publish her identity and give out her Identity Token like so:
```
publish_identity.sh 30
```
The above command will output something like this:
```
Private Key: private.key
Public ID: public.id
Identity Token: 4c4d93788ee46605c98596abc6a36a55ae74a42f5474b15929b38bf9baca32cd
```

## Step 2: Retrieve another Identity
retrieve_identity.sh will retrieve the identity for a specified user. \
This script will take a Name as the first argument. \
The Identity Token that was generated in Step 1 by the sender will be provided as an ENV variable. \
Bob will retrieve the identity and name it Alice:
```
IDTOKEN="4c4d93788ee46605c98596abc6a36a55ae74a42f5474b15929b38bf9baca32cd" \
retrieve_identity.sh Alice
```
The above command will output something like this:
```
Identity Saved for Alice: Alice/public.id
```

## Step 3: Encrypt and Post a file
post_file.sh will encrypt and post a file for a specified user. \
In order to encrypt a file to Bob, you must have an identity for Bob. (Step 2) \
After posting, the CipherText Token can be given to the recipient so they can retrieve the encrypted file. \
Alice will post a file for Bob and give him the CipherText Token like so:
```
post_file.sh Bob msg_to_Bob.txt
```
The above command will output something like this:
```
CipherText Token: 2a077b723c44af935c28b3e8bd5aa1e4c2ccf54b6e7f19a229b9cb192261dc3327f1a8bc31886e944f4c02087daec87365b150f96c4ad0ed22556f317e6390b2
```

## Step 4: Get and Decrypt a message
Bob will use get_file.sh to retrieve and decrypt the file from Alice. \
This script will take the name of the sender as the first argument and the plaintext file to create as the second. \
The CipherText Token that was generated in Step 3 by the sender will be provided as an ENV variable. \
After download, it will validate that the encrypted file was sent by Alice. \
If true, it will decrypt the message. \
After decryption, it will validate that the plaintext file was also sent by Alice. \
Bob will run get_file.sh like so:
```
CTTOKEN="2a077b723c44af935c28b3e8bd5aa1e4c2ccf54b6e7f19a229b9cb192261dc3327f1a8bc31886e944f4c02087daec87365b150f96c4ad0ed22556f317e6390b2" \
get_file.sh Alice my_msg.txt
```
The above command will output something like this:
```
Validating Ciphertext with Alice/public.key ... Verified OK
my_msg.txt Decrypted Successfully!
Validating Plaintext with Alice/public.key ... Verified OK
```

## Symmetric Encryption for group communications
While the above is great for point-to-point communications, you may want to be able to easily send encrypted files to a group of recipients.
Symmetric encryption with a set of shared secret keys is a great way to mass-distribute encrypted files.
There are many ways to generate key files, but in this example we are going to use keygen from CHAOSgen.
This command will generate 1000 binary keys of 1000 random bytes each.
You can use the methods described above to distribute a tarball of keys that will be available for future encrypted communications.
These keys will be fed to the scripts sym_encrypt.sh and sym_decrypt.sh to facilitate the symmetric encryption operations.
```
mkdir keys
gen_chaos_keys.sh 1000 1000 keys
```
After key generation and distribution is complete, use the following to encrypt/decrypt with shared secret keys. \
For added security, shred any key after it gets used. Never use the same key twice. \
Actions for the sender:
```
sym_encrypt.sh files.tar files.enc keys/042.bin
shred -n 9 -u keys/042.bin
```
Actions for any recipient:
```
sym_decrypt.sh files.enc files.tar keys/042.bin
shred -n 9 -u keys/042.bin
```

## More Info
* Howto Run [Sepulcher Server-Side Components](https://github.com/Fullaxx/sepulcher/blob/master/SERVERSIDE.md)

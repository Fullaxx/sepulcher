# Sepulcher
A docker tomb for your encrypted messages built from
* [webstore](https://github.com/Fullaxx/webstore)
* [OpenSSL](https://www.openssl.org/)

## About this Software
Sepulcher is designed for those who want full control over their communications.
It provides an alternative to typical key/message distribution methods.
For example, maybe you don't want your public key made available to the everyone.
Maybe you want to distribute a different set of keys to different recipients.
Maybe you don't want all your encrypted communications left in your inbox until the end of time.
Sepulcher facilitates the distribution of encrypted data on systems that you control.

## Base Docker Image
[Ubuntu](https://hub.docker.com/_/ubuntu) 20.04 (x64)

## Get the image from Docker Hub or build it yourself
```
docker pull fullaxx/sepulcher
docker build -t="fullaxx/sepulcher" github.com/Fullaxx/sepulcher
```

## Launch Sepulcher Docker Container
```
docker run -it \
-v /srv/docker/alice/xfer:/root/xfer \
fullaxx/sepulcher
```

## Step 1: Publish your Identity
publish_identity.sh will generate your private key and create your public certificate. \
Once your identity is created, it will publish your certificate to the keyserver. \
A Cert Token is printed so that other can retrieve your identity.
```
# publish_identity.sh 30
Cert Token: 4c4d93788ee46605c98596abc6a36a55ae74a42f5474b15929b38bf9baca32cd
```

## Step 2: Retrieve another Identity
retrieve_identity.sh will retrieve the certificate for a specified user. \
This script will take a Name and the Cert Token that was generated in Step 1 by said user.
```
# retrieve_identity.sh Alice 4c4d93788ee46605c98596abc6a36a55ae74a42f5474b15929b38bf9baca32cd
-rw-r--r-- 1 root root 3361 Feb  2 13:21 Alice/public.crt
```

## Step 3: Encrypt and Post a message
post_file.sh will encrypt and post a message for a specified user. \
In order to encrypt a message for Bob, you must have a certificate for Bob. (Step 2) \
The CipherText Token can be given to said user so they can retrieve the encryped message.
```
# post_file.sh Bob message.txt
CipherText Token: 2a077b723c44af935c28b3e8bd5aa1e4c2ccf54b6e7f19a229b9cb192261dc3327f1a8bc31886e944f4c02087daec87365b150f96c4ad0ed22556f317e6390b2
```

## Step 4: Get and Decrypt a message
Bob will use the CipherText Token he got from Alice to retrieve and decrypt the message.
```
# get_file.sh 2a077b723c44af935c28b3e8bd5aa1e4c2ccf54b6e7f19a229b9cb192261dc3327f1a8bc31886e944f4c02087daec87365b150f96c4ad0ed22556f317e6390b2 new.txt
```

## More Info
* Howto Run [Sepulcher Server-Side Components](https://github.com/Fullaxx/sepulcher/blob/master/SERVERSIDE.md)

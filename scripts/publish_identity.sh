#!/bin/bash

bail()
{
  echo "$1"
  exit 1
}

OSSLBIN=`which openssl`
if [ "$?" != "0" ]; then
  bail "openssl not found!"
fi

set -e

if [ -z "$1" ]; then
  bail "$0: <DAYS>"
fi
DAYS="$1"

if [ ! -d me ]; then
  mkdir me
fi

if [ ! -f me/private.key ]; then
  ${OSSLBIN} genrsa -aes256 -out me/private.key 8192
fi

# Unnecessary Right Now
#if [ ! -f me/public.key ]; then
#  ${OSSLBIN} rsa -in me/private.key -pubout -out me/public.key
#fi

if [ ! -f me/public.crt ]; then
  ${OSSLBIN} req -x509 -new -days ${DAYS} -key me/private.key -out me/public.crt -subj "/C=XX/ST=Freedom/L=Ether/O=Sepulcher/CN=MYNAME"
fi

CERTTOKEN=`ws_post.exe -s -c -v -H keys.dspi.org -P 443 -a 4 -f me/public.crt | grep 'Token:' | awk '{print $2}'`
echo "Cert Token: ${CERTTOKEN}"

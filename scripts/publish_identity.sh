#!/bin/bash

bail()
{
  >&2 echo "$1"
  exit 1
}

if [ -z "${KSHOST}" ]; then
  bail "KSHOST is not set!"
fi

if [ -z "${KSPORT}" ]; then
  bail "KSPORT is not set!"
fi

OSSLBIN=`which openssl`
if [ "$?" != "0" ]; then
  bail "openssl not found!"
fi

set -e

unset SECFLAG
if [ "${KSSEC}" == "1" ]; then
  SECFLAG="-s"
fi

if [ -z "$1" ]; then
  bail "$0: <DAYS>"
fi
DAYS="$1"

PRIVATEKEY="private.key"
if [ ! -f ${PRIVATEKEY} ]; then
  echo "Generating Private Key ..."
  ${OSSLBIN} genrsa -aes256 -out ${PRIVATEKEY} 8192
fi

PUBLICKEY="public.key"
if [ ! -f ${PUBLICKEY} ]; then
  echo "Saving Public Key ..."
  ${OSSLBIN} rsa -in ${PRIVATEKEY} -pubout -out ${PUBLICKEY}
fi

PUBCERT="public.crt"
if [ ! -f ${PUBCERT} ]; then
  echo "Creating Certificate ..."
  ${OSSLBIN} req -x509 -new -days ${DAYS} -key ${PRIVATEKEY} -out ${PUBCERT} -subj "/C=XX/ST=Freedom/L=Ether/O=Sepulcher/CN=NONAME"
fi

PUBID="public.id"
wrap_id.exe ${PUBLICKEY} ${PUBCERT} >${PUBID}
rm ${PUBLICKEY} ${PUBCERT}

ws_post.exe ${SECFLAG} -c -v -H ${KSHOST} -P ${KSPORT} -a 4 -f ${PUBID} >/tmp/post.id.out
CERTTOKEN=`grep 'Token:' /tmp/post.id.out | awk '{print $2}'`
echo "Private Key: ${PRIVATEKEY}"
echo "Public ID: ${PUBID}"
echo "Identity Token: ${CERTTOKEN}"

# Clean Up
rm /tmp/post.id.out

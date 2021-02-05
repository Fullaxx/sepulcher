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

if [ ! -d me ]; then
  mkdir me
fi

PRIVATEKEY="me/private.key"
if [ ! -f ${PRIVATEKEY} ]; then
  ${OSSLBIN} genrsa -aes256 -out ${PRIVATEKEY} 8192
fi

# Unnecessary Right Now
#if [ ! -f me/public.key ]; then
#  ${OSSLBIN} rsa -in ${PRIVATEKEY} -pubout -out me/public.key
#fi

PUBCERT="me/public.crt"
if [ ! -f ${PUBCERT} ]; then
  ${OSSLBIN} req -x509 -new -days ${DAYS} -key ${PRIVATEKEY} -out ${PUBCERT} -subj "/C=XX/ST=Freedom/L=Ether/O=Sepulcher/CN=MYNAME"
fi

CERTTOKEN=`ws_post.exe ${SECFLAG} -c -v -H ${KSHOST} -P ${KSPORT} -a 4 -f ${PUBCERT} | grep 'Token:' | awk '{print $2}'`
echo "Private Key: ${PRIVATEKEY}"
echo "Public Cert: ${PUBCERT}"
echo "Cert Token: ${CERTTOKEN}"

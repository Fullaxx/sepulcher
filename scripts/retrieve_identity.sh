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

unset SECFLAG
if [ "${KSSEC}" == "1" ]; then
  SECFLAG="-s"
fi

if [ -z "$1" ]; then
  bail "$0: <NAME> <CERTTOKEN>"
fi

if [ -z "$2" ]; then
  bail "$0: <NAME> <CERTTOKEN>"
fi

NAME="$1"
TOKEN="$2"

if [ ! -d ${NAME} ]; then
  mkdir ${NAME}
fi

CERT="${NAME}/public.crt"
ws_get.exe ${SECFLAG} -H ${KSHOST} -P ${KSPORT} -t ${TOKEN} -f ${CERT}
echo "Identity Saved for ${NAME}: ${CERT}"

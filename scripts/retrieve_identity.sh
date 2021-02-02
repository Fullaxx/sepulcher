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

ws_get.exe -s -H keys.dspi.org -P 443 -t ${TOKEN} -f ${CERT}
ls -l ${CERT}

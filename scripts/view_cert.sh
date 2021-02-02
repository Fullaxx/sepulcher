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
  bail "$0: <NAME>"
fi

NAME="$1"

if [ ! -d ${NAME} ]; then
  bail "${NAME} does not exist!"
fi

CERT="${NAME}/public.crt"
if [ ! -f ${CERT} ]; then
  bail "${CERT} does not exist!"
fi

if [ ! -r ${CERT} ]; then
  bail "${CERT} is not readable!"
fi

# View the Certificate
${OSSLBIN} x509 -noout -text -in ${CERT}

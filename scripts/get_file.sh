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
  bail "$0: <CTTOKEN> <PTFILE>"
fi

if [ -z "$2" ]; then
  bail "$0: <CTTOKEN> <PTFILE>"
fi

CTTOKEN="$1"
PTFILE="$2"

if [ ! -r me/private.key ]; then
  bail "me/private.key is not readable!"
fi

if [ -f ${PTFILE} ]; then
  bail "${PTFILE} already exists!"
fi

CTFILE=`mktemp`
ws_get.exe -s -H msgs.dspi.org -P 443 -t ${CTTOKEN} -f ${CTFILE}
${OSSLBIN} smime -decrypt -binary -in ${CTFILE} -inform DER -out ${PTFILE} -inkey me/private.key
rm -f ${CTFILE}

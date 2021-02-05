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
if [ "${MSSEC}" == "1" ]; then
  SECFLAG="-s"
fi

if [ -z "$1" ]; then
  bail "$0: <CTTOKEN> <PTFILE>"
fi

if [ -z "$2" ]; then
  bail "$0: <CTTOKEN> <PTFILE>"
fi

CTTOKEN="$1"
PTFILE="$2"

PRIVATEKEY="me/private.key"
if [ ! -r ${PRIVATEKEY} ]; then
  bail "${PRIVATEKEY} is not readable!"
fi

if [ -f ${PTFILE} ]; then
  bail "${PTFILE} already exists!"
fi

CTFILE=`mktemp`
ws_get.exe ${SECFLAG} -H ${MSHOST} -P ${MSPORT} -t ${CTTOKEN} -f ${CTFILE}
${OSSLBIN} smime -decrypt -binary -in ${CTFILE} -inform DER -out ${PTFILE} -inkey ${PRIVATEKEY}
echo "${PTFILE} Decrypted Successfully!"
rm -f ${CTFILE}

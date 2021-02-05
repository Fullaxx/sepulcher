
#!/bin/bash

bail()
{
  >&2 echo "$1"
  exit 1
}

if [ -z "${MSHOST}" ]; then
  bail "MSHOST is not set!"
fi

if [ -z "${MSPORT}" ]; then
  bail "MSHOST is not set!"
fi

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
  bail "$0: <NAME> <FILE>"
fi

if [ -z "$2" ]; then
  bail "$0: <NAME> <FILE>"
fi

NAME="$1"
PTFILE="$2"

if [ ! -d ${NAME} ]; then
  bail "${NAME} not found!"
fi

CERT="${NAME}/public.crt"
if [ ! -r ${CERT} ]; then
  bail "${CERT} not found!"
fi

if [ ! -f ${PTFILE} ]; then
  bail "${PTFILE} is not a file!"
fi

if [ ! -r ${PTFILE} ]; then
  bail "${PTFILE} is not readable!"
fi

CTFILE=`mktemp`
${OSSLBIN} smime -encrypt -binary -aes-256-cbc -in ${PTFILE} -out ${CTFILE} -outform DER ${CERT}
CTTOKEN=`ws_post.exe ${SECFLAG} -c -v -H ${MSHOST} -P ${MSPORT} -a 6 -f ${CTFILE} | grep 'Token:' | awk '{print $2}'`
echo "${CTFILE} Posted Successfully!"
echo "CipherText Token: ${CTTOKEN}"
rm -f ${CTFILE}

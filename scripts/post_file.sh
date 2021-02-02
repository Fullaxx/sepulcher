
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

if [ ! -r ${NAME}/public.crt ]; then
  bail "${NAME}/public.crt not found!"
fi
CERT="${NAME}/public.crt"

if [ ! -f ${PTFILE} ]; then
  bail "${PTFILE} is not a file!"
fi

if [ ! -r ${PTFILE} ]; then
  bail "${PTFILE} is not readable!"
fi
CTFILE=`mktemp`

${OSSLBIN} smime -encrypt -binary -aes-256-cbc -in ${PTFILE} -out ${CTFILE} -outform DER ${CERT}
CTTOKEN=`ws_post.exe -s -c -v -H msgs.dspi.org -P 443 -a 6 -f ${CTFILE} | grep 'Token:' | awk '{print $2}'`
echo "CipherText Token: ${CTTOKEN}"
rm -f ${CTFILE}

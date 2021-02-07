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

if [ -z "${IDTOKEN}" ]; then
  bail "IDTOKEN is not set!"
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
  bail "$0: <NAME>"
fi

NAME="$1"

if [ ! -d ${NAME} ]; then
  mkdir ${NAME}
fi

PUBID="${NAME}/public.id"
ws_get.exe ${SECFLAG} -H ${KSHOST} -P ${KSPORT} -t ${IDTOKEN} -f ${PUBID}
echo "Identity Saved for ${NAME}: ${PUBID}"

# Extract the public.key for signature checking
extract_id.exe ${PUBID} ${NAME}
rm ${NAME}/public.crt

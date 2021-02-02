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
  bail "$0: <FILENAME> [BYTES]"
fi

FILENAME="$1"

if [ -n "$2" ]; then
  BYTES="$2"
else
  BYTES="8192"
fi

if [ -e ${FILENAME} ]; then
  bail "${FILENAME} exists!"
fi

# Generate a keyfile
${OSSLBIN} rand ${BYTES} >${FILENAME}

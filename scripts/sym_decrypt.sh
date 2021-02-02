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
  bail "$0: <CTFILE> <PTFILE> <KEYFILE>"
fi

CTFILE="$1"
PTFILE="$2"
KEYFILE="$3"

if [ ! -f ${CTFILE} ]; then
  bail "${CTFILE} is not a file!"
fi

if [ -e ${PTFILE} ]; then
  bail "${PTFILE} exists!"
fi

if [ ! -f ${KEYFILE} ]; then
  bail "${KEYFILE} is not a file!"
fi

# Decrypt a file
openssl enc -d -aes-256-cbc -md sha512 -pbkdf2 -iter 100000 -salt -in ${CTFILE} -out ${PTFILE} -pass file:${KEYFILE}

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
  bail "$0: <PTFILE> <CTFILE> <KEYFILE>"
fi

PTFILE="$1"
CTFILE="$2"
KEYFILE="$3"

if [ ! -f ${PTFILE} ]; then
  bail "${PTFILE} is not a file!"
fi

if [ -e ${CTFILE} ]; then
  bail "${CTFILE} exists!"
fi

if [ ! -f ${KEYFILE} ]; then
  bail "${KEYFILE} is not a file!"
fi

# Encrypt a file
openssl enc -e -aes-256-cbc -salt -md sha512 -pbkdf2 -iter 100000 -in ${PTFILE} -out ${CTFILE} -pass file:${KEYFILE}

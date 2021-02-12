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

if [ -z "${CTTOKEN}" ]; then
  bail "CTTOKEN is not set!"
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
  bail "$0: <NAME> <PTFILE>"
fi

if [ -z "$2" ]; then
  bail "$0: <NAME> <PTFILE>"
fi

NAME="$1"
PTFILE="$2"

PRIVATEKEY="private.key"
if [ ! -r ${PRIVATEKEY} ]; then
  bail "${PRIVATEKEY} is not readable!"
fi

if [ ! -d ${NAME} ]; then
  bail "${NAME} does not exist!"
fi

SENDERPUBKEY="${NAME}/public.key"
if [ ! -r ${SENDERPUBKEY} ]; then
  bail "${SENDERPUBKEY} is not readable!"
fi

if [ -f ${PTFILE} ]; then
  bail "${PTFILE} already exists!"
fi

# Download our encrypted bundle
TEMPDIR=`mktemp -d`
ws_get.exe ${SECFLAG} -H ${MSHOST} -P ${MSPORT} -t ${CTTOKEN} -f ${TEMPDIR}/bundle.enc

# Unwrap encrypted bundle and validate signatures
extract_file.exe ${TEMPDIR}/bundle.enc ${TEMPDIR}

CTSIGN="${TEMPDIR}/ct.sign"
CTFILE="${TEMPDIR}/ct.data"
PTSIGN="${TEMPDIR}/pt.sign"

# Validate Ciphertext
echo -n "Validating Ciphertext with ${SENDERPUBKEY} ... "
${OSSLBIN} dgst -sha512 -verify ${SENDERPUBKEY} -signature ${CTSIGN} ${CTFILE}

# Decrypt Ciphertext (DER not PEM)
echo "Using ${PRIVATEKEY} to Decrypt Ciphertext ..."
${OSSLBIN} smime -decrypt -binary -inform DER -in ${CTFILE} -out ${PTFILE} -inkey ${PRIVATEKEY}
echo "${PTFILE} Decrypted Successfully!"

# Validate Plaintext
echo -n "Validating Plaintext with ${SENDERPUBKEY} ... "
${OSSLBIN} dgst -sha512 -verify ${SENDERPUBKEY} -signature ${PTSIGN} ${PTFILE}

# Clean Up
rm -r ${TEMPDIR}

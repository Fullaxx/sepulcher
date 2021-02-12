
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

PRIVATEKEY="private.key"
if [ ! -r ${PRIVATEKEY} ]; then
  bail "${PRIVATEKEY} is not readable!"
fi

if [ ! -d ${NAME} ]; then
  bail "${NAME} not found!"
fi

PUBID="${NAME}/public.id"
if [ ! -r ${PUBID} ]; then
  bail "${PUBID} not found!"
fi

if [ ! -f ${PTFILE} ]; then
  bail "${PTFILE} is not a file!"
fi

if [ ! -r ${PTFILE} ]; then
  bail "${PTFILE} is not readable!"
fi

# extract PUBCERT from recipient's public.id
TEMPDIR=`mktemp -d`
extract_id.exe ${PUBID} ${TEMPDIR}
CERT="${TEMPDIR}/public.crt"
if [ ! -r ${CERT} ]; then
  bail "${CERT} is not readable!"
fi

# Create Digest of Plaintext File
PTSIGN="${TEMPDIR}/pt.sign"
echo "Using ${PRIVATEKEY} to Sign Plaintext ..."
${OSSLBIN} dgst -sha512 -sign ${PRIVATEKEY} -out ${PTSIGN} ${PTFILE}

# Encrypt Plaintext (DER not PEM)
CTFILE="${TEMPDIR}/ct.data"
echo "Encrypting Plaintext ..."
${OSSLBIN} smime -encrypt -binary -aes-256-cbc -outform DER -in ${PTFILE} -out ${CTFILE} ${CERT}

# Create Digest of Ciphertext
CTSIGN="${TEMPDIR}/ct.sign"
echo "Using ${PRIVATEKEY} to Sign Ciphertext ..."
${OSSLBIN} dgst -sha512 -sign ${PRIVATEKEY} -out ${CTSIGN} ${CTFILE}

# Bundle our encrypted file and digest
ENCRYPTEDBUNDLE="${TEMPDIR}/bundle.enc"
wrap_file.exe ${PTSIGN} ${CTFILE} ${CTSIGN} >${ENCRYPTEDBUNDLE}

ws_post.exe ${SECFLAG} -c -v -H ${MSHOST} -P ${MSPORT} -a 6 -f ${ENCRYPTEDBUNDLE} >/tmp/post.ct.out
CTTOKEN=`grep 'Token:' /tmp/post.ct.out | awk '{print $2}'`
echo "${PTFILE} Encrypted and Posted Successfully!"
echo "CipherText Token: ${CTTOKEN}"

# Clean Up
rm -r ${TEMPDIR} /tmp/post.ct.out

#!/bin/bash

set -e

openssl genrsa -out Aprivate.key 8192
openssl rsa -in Aprivate.key -pubout -out Apublic.key
openssl req -x509 -new -days 1 -key Aprivate.key -out Apublic.crt -subj "/C=XX/ST=Freedom/L=Ether/O=Sepulcher/CN=ALICE"

openssl genrsa -out Bprivate.key 8192
openssl rsa -in Bprivate.key -pubout -out Bpublic.key
openssl req -x509 -new -days 1 -key Bprivate.key -out Bpublic.crt -subj "/C=XX/ST=Freedom/L=Ether/O=Sepulcher/CN=BOB"

cat ../src/* >allcode.txt
sha256sum allcode.txt

# A sending file to B
openssl dgst -sha512 -sign Aprivate.key -out allcode.pt.sign allcode.txt
openssl smime -encrypt -binary -aes-256-cbc -outform DER -in allcode.txt -out allcode.der Bpublic.crt
openssl dgst -sha512 -sign Aprivate.key -out allcode.ct.sign allcode.der

# B checking/decrypting file from A
openssl dgst -sha512 -verify Apublic.key -signature allcode.ct.sign allcode.der
openssl smime -decrypt -binary -inform DER -in allcode.der -out allcode2.txt -inkey Bprivate.key
openssl dgst -sha512 -verify Apublic.key -signature allcode.pt.sign allcode2.txt

sha256sum allcode2.txt
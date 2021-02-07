#!/bin/bash

set -e

rm -rf transfer *.txt *.id *.key *.crt *.sign *.enc *.der

( cd ../src/ && ./compile.sh )

# Create A Identity
openssl genrsa -out Aprivate.key 8192
openssl rsa -in Aprivate.key -pubout -out Apublic.key
openssl req -x509 -new -days 1 -key Aprivate.key -out Apublic.crt -subj "/C=XX/ST=Freedom/L=Ether/O=Sepulcher/CN=ALICE"
../src/wrap_id.exe Apublic.key Apublic.crt >A.id

# Create B Identity
openssl genrsa -out Bprivate.key 8192
openssl rsa -in Bprivate.key -pubout -out Bpublic.key
openssl req -x509 -new -days 1 -key Bprivate.key -out Bpublic.crt -subj "/C=XX/ST=Freedom/L=Ether/O=Sepulcher/CN=BOB"
../src/wrap_id.exe Bpublic.key Bpublic.crt >B.id

# Create Plaintext
cat ../src/* >allcode.txt
sha256sum allcode.txt

# A sending file to B
openssl dgst -sha512 -sign Aprivate.key -out allcode.pt.sign allcode.txt
openssl smime -encrypt -binary -aes-256-cbc -outform DER -in allcode.txt -out allcode.der Bpublic.crt
openssl dgst -sha512 -sign Aprivate.key -out allcode.ct.sign allcode.der
../src/wrap_file.exe allcode.pt.sign allcode.der allcode.ct.sign > AtoB.bundle.enc

# B checking/decrypting file from A
mkdir transfer
../src/extract_id.exe A.id transfer
../src/extract_file.exe AtoB.bundle.enc transfer
openssl dgst -sha512 -verify transfer/public.key -signature transfer/ct.sign transfer/ct.data
openssl smime -decrypt -binary -inform DER -in transfer/ct.data -out allcode2.txt -inkey Bprivate.key
openssl dgst -sha512 -verify transfer/public.key -signature transfer/pt.sign allcode2.txt

sha256sum allcode2.txt

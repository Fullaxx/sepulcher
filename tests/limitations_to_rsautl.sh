# https://www.czeskis.com/random/openssl-encrypt-file.html
# https://raymii.org/s/tutorials/Encrypt_and_decrypt_files_to_public_keys_via_the_OpenSSL_Command_Line.html

set -e

rm -f *.bin *.key *.enc *.dec
SECRETFILE="test_all_ops.sh"

openssl genrsa -out private.key 8192
openssl rsa -in private.key -pubout -out public.key

# with an 8192-bit RSA key
# (1013*8) is the largest number we can "encrypt" directly with RSA
# SIZE="1013"
SIZE="1014"

KEYFILE="key${SIZE}.bin"
openssl rand ${SIZE} >${KEYFILE}

openssl rsautl -encrypt -inkey public.key -pubin -in ${KEYFILE} -out ${KEYFILE}.enc
openssl enc -e -aes-256-cbc -salt -md sha512 -pbkdf2 -iter 100000 -in ${SECRETFILE} -out ${SECRETFILE}.enc -pass file:${KEYFILE}

openssl rsautl -decrypt -inkey private.key -in ${KEYFILE}.enc -out ${KEYFILE}.dec
openssl enc -d -aes-256-cbc -salt -md sha512 -pbkdf2 -iter 100000 -in ${SECRETFILE}.enc -out ${SECRETFILE}.dec -pass file:${KEYFILE}.dec

sha256sum ${KEYFILE} ${KEYFILE}.dec
sha256sum ${SECRETFILE} ${SECRETFILE}.dec

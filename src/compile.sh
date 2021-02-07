#!/bin/bash

set -e

OPT="-O2"
DBG="-ggdb3 -DDEBUG"
CFLAGS="-Wall -ansi"
OPTCFLAGS="${CFLAGS} ${OPT}"
DBGCFLAGS="${CFLAGS} ${DBG}"

rm -f *.exe *.dbg

gcc ${OPTCFLAGS} wrap_id.c pem.c cJSON.c -o wrap_id.exe
gcc ${DBGCFLAGS} wrap_id.c pem.c cJSON.c -o wrap_id.dbg

gcc ${OPTCFLAGS} extract_id.c cJSON.c futils.c -o extract_id.exe
gcc ${DBGCFLAGS} extract_id.c cJSON.c futils.c -o extract_id.dbg

gcc ${OPTCFLAGS} wrap_file.c cJSON.c -o wrap_file.exe
gcc ${DBGCFLAGS} wrap_file.c cJSON.c -o wrap_file.dbg

gcc ${OPTCFLAGS} extract_file.c cJSON.c futils.c -o extract_file.exe
gcc ${DBGCFLAGS} extract_file.c cJSON.c futils.c -o extract_file.dbg

strip *.exe

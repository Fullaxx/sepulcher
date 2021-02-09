#!/bin/bash

set -e

bail()
{
  echo "$1"
  exit 1
}

filenum()
{
  local RETVAL
  if [ $2 -gt 100000000 ]; then
    RETVAL=`echo $1 | awk '{printf("%09d", $1)}'`
  elif [ $2 -gt 10000000 ]; then
    RETVAL=`echo $1 | awk '{printf("%08d", $1)}'`
  elif [ $2 -gt 1000000 ]; then
    RETVAL=`echo $1 | awk '{printf("%07d", $1)}'`
  elif [ $2 -gt 100000 ]; then
    RETVAL=`echo $1 | awk '{printf("%06d", $1)}'`
  elif [ $2 -gt 10000 ]; then
    RETVAL=`echo $1 | awk '{printf("%05d", $1)}'`
  elif [ $2 -gt 1000 ]; then
    RETVAL=`echo $1 | awk '{printf("%04d", $1)}'`
  elif [ $2 -gt 100 ]; then
    RETVAL=`echo $1 | awk '{printf("%03d", $1)}'`
  elif [ $2 -gt 10 ]; then
    RETVAL=`echo $1 | awk '{printf("%02d", $1)}'`
  else
    RETVAL="$1"
  fi
  echo ${RETVAL}
}

if [ -z "$1" ]; then
  bail "$0: <NUMKEYS> <SIZE> [DIR]"
fi
NUMKEYS="$1"

if [ -z "$2" ]; then
  bail "$0: <NUMKEYS> <SIZE> [DIR]"
fi
SIZE="$2"

DIR="."
if [ -n "$3" ]; then
  DIR="$3"
  if [ ! -d "${DIR}" ]; then
    bail "${DIR} is not a directory!"
  fi
fi

CPUS="1"
HWCORES=`nproc`
if [ ${HWCORES} -gt 3 ]; then
  CPUS=$(( ${HWCORES}-3 ))
fi

COUNT="0"
while [ ${COUNT} -lt ${NUMKEYS} ]; do
  NUMBER=$(filenum ${COUNT} ${NUMKEYS})
  FILENAME="${DIR}/${NUMBER}.bin"
  echo "Creating ${FILENAME} ..."
  chaos_keygen.exe -f ${FILENAME} -b ${SIZE} -n ${CPUS}
  COUNT=$(( COUNT + 1 ))
done

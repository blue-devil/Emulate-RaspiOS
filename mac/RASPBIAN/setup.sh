#!/bin/bash

#echo -e "${0} ${1}"

usage() {
    echo -e "Usage: ${0} <download_url>"
    exit
}

if [[ "${1}" = "-h" ]] || [[ "${1}" = "--help" ]] || [[ $# -eq 0 ]]; then
    usage
fi

URL=${1}
IMGARC="${URL##*/}"
EXT="${IMGARC##*.}"
IMG="${IMGARC%.*}"
TMP="temp"

# Download image
wget ${URL}

# Download kernel
wget https://raw.githubusercontent.com/dhruvvyas90/qemu-rpi-kernel/master/kernel-qemu-4.4.34-jessie

# unzip and delete archive
unzip ${IMGARC}
#rm ${IMGARC}

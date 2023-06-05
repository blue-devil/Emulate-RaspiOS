#!/bin/bash

usage() {
    echo -e "Usage: ${0} <raspbian_image_file.bin>"
    exit
}

# check operating system
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "[+] Linux running"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "[+] macOS running"
else
    echo "[-] This script only works on Linux and macOS"
    usage
fi

# check commandline parameters
if [[ "${1}" = "-h" ]] || [[ "${1}" = "--help" ]]  || [[ $# -eq 0 ]] ; then
    usage
fi

IMG=${1}

qemu-system-arm \
-kernel kernel-qemu-4.4.34-jessie \
-cpu arm1176 \
-m 256 \
-M versatilepb \
-nographic \
-append "console=ttyAMA0 root=/dev/sda2 rootfstype=ext4 rw" \
-drive file=${IMG},format=raw \
-net nic \
-net user,hostfwd=tcp::5022-:22

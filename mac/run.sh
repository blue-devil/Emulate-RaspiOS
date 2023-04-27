#!/bin/bash

usage() {
    echo -e "Usage: ${0} <raspios_image_file.qcow2>"
    exit
}

# check commandline parameters
if [[ "${1}" = "-h" ]] || [[ "${1}" = "--help" ]]  || [[ $# -eq 0 ]] ; then
    usage
fi

QCW=${1}

qemu-system-aarch64 \
-m 1024 \
-M raspi3b \
-kernel kernel8.img \
-dtb bcm2710-rpi-3-b-plus.dtb \
-sd ${QCW} \
-append "console=ttyAMA0 root=/dev/mmcblk0p2 rw rootwait rootfstype=ext4" \
-nographic \
-device usb-net,netdev=net0 \
-netdev user,id=net0,hostfwd=tcp::5555-:22

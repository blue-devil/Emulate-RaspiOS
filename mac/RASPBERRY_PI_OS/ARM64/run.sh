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
-m 1G \
-M raspi3b \
-smp 4 \
-usb \
-device usb-mouse \
-device usb-kbd \
-device 'usb-net,netdev=net0' \
-netdev 'user,id=net0,hostfwd=tcp::5555-:22' \
-drive "file=${QCW},index=0,format=raw" \
-dtb bcm2710-rpi-3-b-plus.dtb \
-kernel kernel8.img \
-append 'rw earlyprintk loglevel=8 console=ttyAMA0,115200 dwc_otg.lpm_enable=0 root=/dev/mmcblk0p2 rootdelay=1' \
-no-reboot \
-nographic

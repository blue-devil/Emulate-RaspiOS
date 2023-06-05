#!/bin/bash

usage() {
    echo -e "Usage: ${0} <raspios_arm64_image_file.img>"
    exit
}

# check commandline parameters
if [[ "${1}" = "-h" ]] || [[ "${1}" = "--help" ]]  || [[ $# -eq 0 ]] ; then
    usage
fi

#######################################
# Global Variables
# Edit global variable for your needs
#######################################

MEM="1G"
MCH="raspi3b"
SMP="4"
IMG=${1}
DTB="bcm2710-rpi-3-b-plus.dtb"
KRN="kernel8.img"

qemu-system-aarch64 \
-m ${MEM} \
-M ${MCH} \
-smp ${SMP} \
-usb \
-device usb-mouse \
-device usb-kbd \
-device 'usb-net,netdev=net0' \
-netdev 'user,id=net0,hostfwd=tcp::5555-:22' \
-drive "file=${IMG},index=0,format=raw" \
-dtb ${DTB} \
-kernel ${KRN} \
-append 'rw earlyprintk loglevel=8 console=ttyAMA0,115200 dwc_otg.lpm_enable=0 root=/dev/mmcblk0p2 rootdelay=1' \
-no-reboot \
-nographic

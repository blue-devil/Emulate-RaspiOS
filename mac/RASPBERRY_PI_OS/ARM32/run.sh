#!/bin/bash

usage() {
    echo -e "Usage: ${0} <raspios_armhf_image_file.img>"
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

CPU="arm1176"
MEM="1G"
MCH="raspi3b"
MCH2="versatilepb"
SMP="4"
IMG=${1}
DTB="bcm2710-rpi-3-b-plus.dtb"
DTB2="versatile-pb-bullseye-5.10.63.dtb"
KRN="kernel8.img"
KRN2="kernel-qemu-5.10.63-bullseye"

#qemu-system-arm \
#-cpu ${CPU} \
#-m ${MEM} \
#-M ${MCH} \
#-drive "file=${IMG},if=none,index=0,media=disk,format=raw,id=disk0" \
#-device "virtio-blk-pci,drive=disk0,disable-modern=on,disable-legacy=off" \
#-net "user,hostfwd=tcp::5545-:22" \
#-net nic \
#-dtb ${DTB} \
#-kernel ${KRN} \
#-append "root=/dev/vda panic=1" \
#-no-reboot \
#-nographic

#qemu-system-arm \
#-kernel kernel-qemu-5.10.63-bullseye \
#-cpu arm1176 \
#-m 256 \
#-M versatilepb \
#-nographic \
#-append "console=ttyAMA0 root=/dev/sda2 rootfstype=ext4 rw" \
#-drive file=2023-05-03-raspios-bullseye-armhf-lite.img,format=raw \
#-net nic \
#-net user,hostfwd=tcp::5545-:22

qemu-system-aarch64 \
-m ${MEM} \
-M ${MCH} \
-smp ${SMP} \
-usb \
-device usb-mouse \
-device usb-kbd \
-device 'usb-net,netdev=net0' \
-netdev 'user,id=net0,hostfwd=tcp::5545-:22' \
-drive "file=${IMG},index=0,format=raw" \
-dtb ${DTB} \
-kernel ${KRN} \
-append 'rw earlyprintk loglevel=8 console=ttyAMA0,115200 dwc_otg.lpm_enable=0 root=/dev/mmcblk0p2 rootdelay=1' \
-no-reboot \
-nographic

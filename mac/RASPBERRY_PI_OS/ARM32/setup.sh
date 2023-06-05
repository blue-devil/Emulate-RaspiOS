#!/bin/bash

# Color constanst for bash
NBLA='\033[0;30m'   # Normal Black
NRED='\033[0;31m'   # Normal Red
NGRE='\033[0;32m'   # Normal Green
NYEL='\033[0;33m'   # Normal Yellow
NBLU='\033[0;34m'   # Normal Blue
NPUR='\033[0;35m'   # Normal Purple
NCYA='\033[0;36m'   # Normal Cyan
NWHI='\033[0;37m'   # Normal White

BBLA='\033[1;30m'   # Bolder Black
BRED='\033[1;31m'   # Bolder Red
BGRE='\033[1;32m'   # Bolder Green
BYEL='\033[1;33m'   # Bolder Yellow
BBLU='\033[1;34m'   # Bolder Blue
BPUR='\033[1;35m'   # Bolder Purple
BCYA='\033[1;36m'   # Bolder Cyan
BWHI='\033[1;37m'   # Bolder White

RSET='\033[0m'      # Text Reset

# echoes bolder blue
function echo_nblu(){
    echo -e "${NBLU}$1${RSET}"
}

function echo_ngre(){
    echo -e "${NGRE}$1${RSET}"
}

function echo_nred(){
    echo -e "${NRED}$1${RSET}"
}

function echo_nyel(){
    echo -e "${NYEL}$1${RSET}"
}

usage() {
    echo -e "Usage: ${0} <download_url>"
    exit
}

if [[ "${1}" = "-h" ]] || [[ "${1}" = "--help" ]] || [[ $# -eq 0 ]]; then
    usage
fi

banner="
       ╔═════════════════════════════════════════════════════════╗      
 ┌─────╢◀     RASPBERRY Pi OS x32 DOWNLOAD AND SETUP SCRIPT     ▶╟─────┐
 │     ╚═════════════════════════════════════════════════════════╝     │
 │    ┌───────┬───────┬───────┐                                        │
 │    │░░ ░▒▒▓│ ░░ ▒▒▓│ ░  ▒▒▓│  Author : Blue DeviL                   │
 │    │░┌─────┤ ░░ ┌──┴─┐  ▒┌─┘  E-mail : bluedevil.SCT@gmail.com      │
 │    │ └─────┤ ░░ │    │  ▒│    Date   : 06/06/2023                   │
 │    └─────┐▒│ ░░ │    │  ▒│    WEB    : github.com/blue-devil        │
 │    ┌─────┘▒│ ░░ └──┐ │ ░▒│    ╔════════════════════════════════╗    │
 │    │   ░░▒▓│ ░░▒▒▓█│ │ ▓▒│    ║   Freedom, doesn't come from   ╟────┤
 │    │ ░░▒▒▓█│ ░░▒▒▓▓│ │░▓█│    ║●     second-hand thoughts.    ●╟────┤
 │    └───────┴───────┘ └───┘    ╚════════════════════════════════╝    │
 └─────────────────────────────────────────────────────────────────────┘"
echo_nyel "${banner}"

#######################################
# Global Variables
# Edit global variable for your needs
#######################################

URL=${1}
IMGARC="${URL##*/}"
EXT="${IMGARC##*.}"
IMG="${IMGARC%.*}"
QCW="${IMG%.*}.qcow2"
TMP="temp"
SZE="8G"
echo -e ${QCW}

# Download image
function download_image(){
    echo_ngre "[+] Downloading ${URL}"

    wget ${URL}
}

# decompress and delete archive
function decompress_img_archive(){
    echo_ngre "[+] Decompress and delete archive"

    unxz ${IMGARC}
    # When using unxz we do not need to delete xz archive
    #rm ${IMGARC}
}

# make a temp dir
function create_temp_dir(){
    echo_ngre "[+] Creating temp directory..."

    mkdir ${TMP}
}

# mount image
function mount_image(){
    echo_ngre "[+] Mounting image: ${IMG}"

    hdiutil mount ${IMG} -mountpoint ${TMP}
}

# copy dtb files
function copy_dtb_files(){
    echo_ngre "[+] Copying DTB files..."

    cp ${TMP}/*.dtb .
}

# copy kernel image
function copy_kernel(){
    echo_ngre "[+] Copying kernel image..."

    cp ${TMP}/kernel*.img .
}

# add user pi and its password raspberry
function add_user_and_pw(){
    echo_ngre "[+] Adding user as 'pi' and password 'raspberry'"

    echo 'pi:$6$6jHfJHU59JxxUfOS$k9natRNnu0AaeS/S9/IeVgSkwkYAjwJfGuYfnwsUoBxlNocOn.5yIdLRdSeHRiw8EWbbfwNSgx9/vUhu0NqF50' > ${TMP}/userconf
}

# add parameter to load the usb ethernet drivers
function add_param2cmdline(){
    echo_ngre "[+] Adding cmdline parameters for ethernet drivers"

    sed -i '' 's/rootwait/rootwait modules-load=dwc2,g_ether/' ${TMP}/cmdline.txt
}

# unmount img
function unmount_img(){
    echo_ngre "[+] Unmounting image..."

    hdiutil unmount ${TMP}
}

# convert img to qcow2
function convert_img2qcow2(){
    echo_ngre "[+] Converting img to qcow2:"

    qemu-img convert -f raw -O qcow2 ${IMG} ${QCW}

    # resize image to 8G
    echo_ngre "[+] Resizing qcow2 image to ${SZE}"
    qemu-img resize ${QCW} ${SZE}
}

function resize_img(){
    echo_ngre "[+] Resizing img to ${SZE}"

    qemu-img resize -f raw ${IMG} ${SZE}
}

function cleanup(){
    echo_ngre "[+] Cleaning unneeded file and directories"

    rm -r ${TMP}
}

function setup(){
    download_image
    decompress_img_archive
    create_temp_dir
    mount_image
    copy_dtb_files
    copy_kernel
    add_user_and_pw
    add_param2cmdline
    unmount_img
    convert_img2qcow2
    resize_img
    cleanup
}

setup

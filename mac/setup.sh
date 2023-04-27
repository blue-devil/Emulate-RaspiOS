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
QCW="${IMG%.*}.qcow2"
TMP="temp"
echo -e ${QCW}
# Download image
wget ${URL}

# decompress and delete archive
unxz ${IMGARC}
# When using unxz we do not need to delete xz archive
#rm ${IMGARC}

# make a temp dir
mkdir ${TMP}

# mount image
hdiutil mount ${IMG} -mountpoint ${TMP}

# copy dtb files
cp ${TMP}/*.dtb .

# copy kernel image
cp ${TMP}/kernel*.img .

# add user pi and its password raspberry
echo 'pi:$6$6jHfJHU59JxxUfOS$k9natRNnu0AaeS/S9/IeVgSkwkYAjwJfGuYfnwsUoBxlNocOn.5yIdLRdSeHRiw8EWbbfwNSgx9/vUhu0NqF50' > ${TMP}/userconf

# add parameter to load the usb ethernet drivers
sed -i '' 's/rootwait/rootwait modules-load=dwc2,g_ether/' ${TMP}/cmdline.txt

# unmount img
hdiutil unmount ${TMP}

# convert img to qcow2
qemu-img convert -f raw -O qcow2 ${IMG} ${QCW}

# resize image to 8G
qemu-img resize ${QCW} 8G

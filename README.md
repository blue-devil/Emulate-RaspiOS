# Raspbian on QEMU

## Raspbian x32 (Jessie)

In this emulation we are going to emulate an old raspbian version:

- [Raspbian Lite - Jessie (x32)][web-rpi-jessie-lite-32]
- [Kernel QEMU v4.4.34 - Jessie (x32)][web-rpi-jessie-lite-32-kernel]

macOS (QEMU emulation with GUI):

```txt
qemu-system-arm \
-kernel kernel-qemu-4.4.34-jessie \
-cpu arm1176 \
-m 256 \
-M versatilepb \
-serial stdio \
-append "root=/dev/sda2 rootfstype=ext4 rw" \
-drive file=2017-04-10-raspbian-jessie.img,format=raw \
-net nic \
-net user,hostfwd=tcp::5022-:22
```

macOS (QEMU emulation without GUI):

```txt
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
```

Linux (QEMU emulation with GUI):

```txt
sudo qemu-system-arm \
-kernel kernel-qemu-4.4.34-jessie \
-cpu arm1176 \
-m 256 \
-M versatilepb \
-serial stdio \
-append "root=/dev/sda2 rootfstype=ext4 rw" \
-drive file=2017-04-10-raspbian-jessie.img,format=raw \
-net nic \
-net user,hostfwd=tcp::5022-:22 \
-net tap,ifname=vnet0,script=no,downscript=no
```

## Raspios Lite ARM64 (Bullseye) on QEMU

macOS

Requirements

```txt
brew install qemu xz
```

Below is the order of preparation of image before running with
`qemu-system-aarch64`

```txt
# Download image
wget https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2023-02-22/2023-02-21-raspios-bullseye-arm64-lite.img.xz

# decompress and delete archive
xz -d 2023-02-21-raspios-bullseye-arm64-lite.img.xz
rm 2023-02-21-raspios-bullseye-arm64-lite.img.xz

# make a temp dir
mkdir temp

# mount image
hdiutil mount 2023-02-21-raspios-bullseye-arm64-lite.img -mountpoint temp

# copy dtb files
cp temp/*.dtb .

# copy kernel image
cp temp/kernel*.img

# add user pi and its password raspberry
echo 'pi:$6$6jHfJHU59JxxUfOS$k9natRNnu0AaeS/S9/IeVgSkwkYAjwJfGuYfnwsUoBxlNocOn.5yIdLRdSeHRiw8EWbbfwNSgx9/vUhu0NqF50' > temp/userconf

# add parameter to load the usb ethernet drivers
sed -i '' 's/rootwait/rootwait modules-load=dwc2,g_ether/' temp/cmdline.txt

# unmount img
hdiutil unmount temp

# convert img to qcow2
qemu-img convert -f raw -O qcow2 2023-02-21-raspios-bullseye-arm64-lite.img 2023-02-21-raspios-bullseye-arm64-lite.qcow2

# resize image to 8G
qemu-img resize 2023-02-21-raspios-bullseye-arm64-lite.qcow2 8g
```

```txt
qemu-system-aarch64 \
-m 1024 \
-M raspi3b \
-kernel kernel8.img \
-dtb bcm2710-rpi-3-b-plus.dtb \
-sd 2023-02-21-raspios-bullseye-arm64-lite.qcow2 \
-append "console=ttyAMA0 root=/dev/mmcblk0p2 rw rootwait rootfstype=ext4" \
-nographic \
-device usb-net,netdev=net0 \
-netdev user,id=net0,hostfwd=tcp::5555-:22
```

```txt
qemu-system-aarch64 \
-m 1024 \
-M raspi3b \
-kernel kernel8.img \
-dtb bcm2710-rpi-3-b-plus.dtb \
-sd 2023-02-21-raspios-bullseye-arm64-lite.qcow2 \
-append "console=ttyAMA0 root=/dev/mmcblk0p2 rw rootwait rootfstype=ext4" \
-nographic \
-device usb-net,netdev=net0 \
-netdev user,id=net0,hostfwd=tcp::5555-:22
```

After successfully login with credentials `pi:raspberry` we should manually
start ssh service:

```txt
sudo service ssh start
```

Now we can ssh to our qemu machine or send/get files with scp:

```txt
# connect with ssh
ssh pi@127.0.0.1 -p 5555

# send file via scp
scp -P5555 Downloads/rasp.md pi@127.0.0.1:/home/pi

# retrieve file via scp
scp -P5555 pi@127.0.0.1:/home/pi/asd.txt .
```

## Resources

- [Official Raspberry PI OS Images Download][web-rpi-dl]
- [Qemu kernel for emulating Rpi on QEMU][web-gh-qemu-rpi-kernel]
- [Azeria - Raspberry Pi on QEMU][web-azeria-rpionqemu]
- [StackOverflow - QEMU kernel for raspberry pi 3 with networking and virtio support][web-so-qemu-rpi3]
- [Reddit - Guide to emulate raspios buster][web-reddit-qemu-bullseye]

[web-gh-qemu-rpi-kernel]: https://github.com/dhruvvyas90/qemu-rpi-kernel
[web-azeria-rpionqemu]: https://azeria-labs.com/emulate-raspberry-pi-with-qemu/
[web-rpi-dl]: https://downloads.raspberrypi.org/
[web-so-qemu-rpi3]: https://stackoverflow.com/questions/61562014/qemu-kernel-for-raspberry-pi-3-with-networking-and-virtio-support
[web-reddit-qemu-bullseye]: https://www.reddit.com/r/qemu_kvm/comments/10my3rq/guides_to_emulate_a_raspberry_pi_os_buster/
[web-rpi-jessie-lite-32]: https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2017-04-10/2017-04-10-raspbian-jessie-lite.zip
[web-rpi-jessie-lite-32-kernel]: https://github.com/dhruvvyas90/qemu-rpi-kernel/blob/master/kernel-qemu-4.4.34-jessie

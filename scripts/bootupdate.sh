#!/bin/bash
set -eux
rm -rf /boot/*old
cp /boot/vmlinuz* /efi/EFI/Linux/kernel.new.efi
cp /boot/initramfs* /efi/EFI/Linux/initramfs.new.img
cp /boot/System.map* /efi/EFI/Linux/System.new.map
if [ -f /boot/intel-uc.img ]; then
    cp /boot/intel-uc.img /efi/EFI/Linux/intel-uc.new.img
fi
if [ -f /boot/amd-uc.img ]; then
    cp /boot/amd-uc.img /efi/EFI/Linux/amd-uc.new.img
fi
mv /efi/EFI/Linux/kernel.efi /efi/EFI/Linux/kernel.backup.efi
mv /efi/EFI/Linux/initramfs.img /efi/EFI/Linux/initramfs.backup.img
mv /efi/EFI/Linux/System.map /efi/EFI/Linux/System.backup.map
mv /efi/EFI/Linux/kernel.new.efi /efi/EFI/Linux/kernel.efi
mv /efi/EFI/Linux/initramfs.new.img /efi/EFI/Linux/initramfs.img
mv /efi/EFI/Linux/System.new.map /efi/EFI/Linux/System.map
if [ -f /efi/EFI/Linux/intel-uc.new.img ]; then
    if [ -f /efi/EFI/Linux/intel-uc.img ]; then
        mv /efi/EFI/Linux/intel-uc.img /efi/EFI/Linux/intel-uc.backup.img
    fi
    mv /efi/EFI/Linux/intel-uc.new.img /efi/EFI/Linux/intel-uc.img
fi
if [ -f /efi/EFI/Linux/amd-uc.new.img ]; then
    if [ -f /efi/EFI/Linux/amd-uc.img ]; then
        mv /efi/EFI/Linux/amd-uc.img /efi/EFI/Linux/amd-uc.backup.img
    fi
    mv /efi/EFI/Linux/amd-uc.new.img /efi/EFI/Linux/amd-uc.img
fi
#sbsign /efi/EFI/Linux/kernel.efi --cert /certs/kernel.pem --key /certs/kernel.pem --out /efi/EFI/Linux/kernel.efi

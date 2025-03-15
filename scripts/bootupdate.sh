#!/bin/bash
set -eux
rm -rf /boot/*old
cp /boot/vmlinuz* /efi/EFI/Linux/kernel.new.efi
cp /boot/initramfs* /efi/EFI/Linux/initramfs.new.img
cp /boot/System.map* /efi/EFI/Linux/System.new.map
mv /efi/EFI/Linux/kernel.efi /efi/EFI/Linux/kernel.backup.efi
mv /efi/EFI/Linux/initramfs.img /efi/EFI/Linux/initramfs.backup.img
mv /efi/EFI/Linux/System.map /efi/EFI/Linux/System.backup.map
mv /efi/EFI/Linux/kernel.new.efi /efi/EFI/Linux/kernel.efi
mv /efi/EFI/Linux/initramfs.new.img /efi/EFI/Linux/initramfs.img
mv /efi/EFI/Linux/System.new.map /efi/EFI/Linux/System.map
#sbsign /efi/EFI/Linux/kernel.efi --cert /certs/kernel.pem --key /certs/kernel.pem --out /efi/EFI/Linux/kernel.efi

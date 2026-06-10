#!/bin/bash
set -eux
efibootmgr -c -d /dev/nvme0n1 -p 1 -L "Gentoo" -l "\EFI\Linux\kernel.efi" -u "root=UUID=eec65254-5885-4bef-97ab-f8727997dc97 initrd=\EFI\Linux\initramfs.img net.ifnames=0"

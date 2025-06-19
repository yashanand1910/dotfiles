#!/bin/bash
set -eux
efibootmgr -c -d /dev/nvme0n1 -p 1 -L "Gentoo" -l "\EFI\Linux\kernel.efi" -u "root=UUID=1b20a33a-8828-4ad2-9603-4143d27d77ca initrd=\EFI\Linux\initramfs.img net.ifnames=0"

#!/bin/bash
# Stage a built kernel from /boot onto the ESP as version-independent EFI-stub
# files, rotating one backup generation. Selects files by explicit kernel
# version (newest in /boot, or $1), so multiple installed versions can't
# break the copy like a bare vmlinuz* glob does.
set -eu

BOOT=${BOOT:-/boot}
ESP_MOUNT=${ESP_MOUNT:-/efi}
ESP=$ESP_MOUNT/EFI/Linux

if [ $# -ge 1 ]; then
    KVER=$1
else
    KVER=$(ls "$BOOT" | sed -n 's/^vmlinuz-//p' | grep -v '\.old$' | sort -V | tail -n1)
fi
[ -n "${KVER:-}" ] || { echo "error: no vmlinuz-* in $BOOT" >&2; exit 1; }

KERNEL=$BOOT/vmlinuz-$KVER
INITRAMFS=$BOOT/initramfs-$KVER.img
SYSMAP=$BOOT/System.map-$KVER
for f in "$KERNEL" "$INITRAMFS" "$SYSMAP"; do
    [ -f "$f" ] || { echo "error: missing $f" >&2; exit 1; }
done

if [ "${BOOTUPDATE_NO_MOUNT_CHECK:-0}" != 1 ]; then
    mountpoint -q "$ESP_MOUNT" || { echo "error: $ESP_MOUNT not mounted" >&2; exit 1; }
fi
[ -d "$ESP" ] || { echo "error: $ESP does not exist" >&2; exit 1; }

# Fully stage the new files before touching the live ones, so an interrupted
# run never leaves the ESP without a bootable kernel/initramfs pair.
cp "$KERNEL" "$ESP/kernel.new.efi"
cp "$INITRAMFS" "$ESP/initramfs.new.img"
cp "$SYSMAP" "$ESP/System.new.map"
#sbsign "$ESP/kernel.new.efi" --cert /certs/kernel.pem --key /certs/kernel.pem --out "$ESP/kernel.new.efi"
sync

swap() { # new current backup
    [ ! -f "$ESP/$2" ] || mv "$ESP/$2" "$ESP/$3"
    mv "$ESP/$1" "$ESP/$2"
}
swap kernel.new.efi kernel.efi kernel.backup.efi
swap initramfs.new.img initramfs.img initramfs.backup.img
swap System.new.map System.map System.backup.map
sync

rm -f "$BOOT"/*.old

stale=$(ls "$BOOT" | sed -n 's/^vmlinuz-//p' | grep -vx "$KVER" || true)
[ -z "$stale" ] || echo "note: other kernel versions still in $BOOT:" $stale

echo "staged $KVER -> $ESP (previous kernel kept as kernel.backup.efi)"

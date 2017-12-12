#!/bin/sh

#disable on hyperv (quiet mode has problems with hyper-v graphics)
#sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet\"/GRUB_CMDLINE_LINUX_DEFAULT=\"\"/g' /etc/default/grub 
#update-grub

# gen 2 EFI fix - see https://docs.microsoft.com/en-us/windows-server/virtualization/hyper-v/supported-ubuntu-virtual-machines-on-hyper-v
cp -r /boot/efi/EFI/ubuntu/ /boot/efi/EFI/boot
mv /boot/efi/EFI/boot/shimx64.efi /boot/efi/EFI/boot/bootx64.efi
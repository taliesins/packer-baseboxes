#!/bin/sh

# Mount setup file
mkdir -p /mnt/vmware
mount -o loop /home/vagrant/linux.iso /mnt/vmware

# Extract setup file
cd /tmp
tar xzf /mnt/vmware/VMwareTools-*.tar.gz

# Unmount setup file
umount /mnt/vmware
rm -f /home/vagrant/linux.iso

# Execute setup
/tmp/vmware-tools-distrib/vmware-install.pl --default

# Clean
rm -fr /tmp/vmware-tools-distrib

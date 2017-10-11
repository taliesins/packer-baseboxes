#!/bin/sh

# Clean up
purge-old-kernels
apt-get -y remove dkms 
apt-get -y autoremove --purge
apt-get -y clean

# Remove temporary files
rm -rf /tmp/*

# Zero out free space
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

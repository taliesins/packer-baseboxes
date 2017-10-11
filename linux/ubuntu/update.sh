#!/bin/sh

# Update the box
apt-get -y update
apt-get -y upgrade

# Install dependencies
apt-get -y install dkms
apt-get -y install nfs-common
apt-get -y install byobu
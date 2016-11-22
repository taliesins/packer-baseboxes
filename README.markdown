Packer-BaseBoxes
================
 
# LICENSE
Apache 2.0 - see LICENSE.txt

# Running HyperV builds

Until HyperV builder is included in Packer, the latest version with Hyper-V support can be found at: [https://dl.bintray.com/taliesins/Packer/](https://dl.bintray.com/taliesins/Packer/). Download Nuget package with HyperV in it. Unzip Nuget package to get Packer.exe.

Source for Packer with HyperV can be found at: [https://github.com/mitchellh/packer/pull/2576](https://github.com/mitchellh/packer/pull/2576)

# Approach

Every attempt has been made to minimize the size of the baseboxes to ensure that they can be deployed as quick as possible. The assumption is that the latest updates are to be applied when creating a basebox. 

Windows baseboxes are also sysprepped so they should be safe to spin up.

# Templates
* Windows Server 2012
 * HyperV
 * Virtual Box
 * Vmware
 * VSphere via Vmware
 * VSphere directly
* Windows 10
 * HyperV
 * Virtual Box
 * Vmware
 * VSphere via Vmware
 * VSphere directly
* Ubuntu 14.04
 * HyperV
 * Virtual Box
 * Vmware
 * VSphere via Vmware
 * VSphere directly
* Ubuntu 15.04
 * HyperV
 * Virtual Box
 * Vmware
 * VSphere via Vmware
 * VSphere directly

## Source
Clone to repository locally: `git clone git@github.com:taliesins/packer-baseboxes.git`


variable "cpu" {
  type    = string
  default = "2"
}

variable "disk_size" {
  type    = string
  default = "21440"
}

variable "hyperv_switchname" {
  type    = string
  default = "${env("hyperv_switchname")}"
}

variable "iso_checksum" {
  type    = string
  default = "8c5fc24894394035402f66f3824beb7234b757dd2b5531379cb310cedfdf0996"
}

variable "iso_checksum_type" {
  type    = string
  default = "sha256"
}

variable "iso_url" {
  type    = string
  default = "http://cdimage.ubuntu.com/ubuntu/releases/bionic/release/ubuntu-18.04.5-server-amd64.iso"
}

variable "password" {
  type    = string
  default = "vagrant"
}

variable "ram_size" {
  type    = string
  default = "2048"
}

variable "username" {
  type    = string
  default = "vagrant"
}

variable "vm_name" {
  type    = string
  default = "ubuntu-bionic"
}

source "hyperv-iso" "ubuntu" {
  boot_command         = [
    "<esc><wait10><esc><esc><enter><wait>",
    "set gfxpayload=1024x768<enter>",
    "linux /install/vmlinuz ",
    "preseed/url=http://{{.HTTPIP}}:{{.HTTPPort}}/18.04/preseed.cfg ",
    "debian-installer=en_US.UTF-8 auto locale=en_US.UTF-8 kbd-chooser/method=us ",
    "hostname={{.Name}} ",
    "fb=false debconf/frontend=noninteractive ",
    "keyboard-configuration/modelcode=SKIP keyboard-configuration/layout=USA ",
    "keyboard-configuration/variant=USA console-setup/ask_detect=false <enter>",
    "initrd /install/initrd.gz<enter>",
    "boot<enter>"
  ]

  boot_wait            = "5s"
  communicator         = "ssh"
  cpus                 = "${var.cpu}"
  disk_size            = "${var.disk_size}"
  enable_secure_boot   = false
  generation           = 2
  guest_additions_mode = "disable"
  http_directory       = "./linux/ubuntu/http/"
  iso_checksum         = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url              = "${var.iso_url}"
  memory               = "${var.ram_size}"
  shutdown_command     = "echo 'vagrant' | sudo -S -E shutdown -P now"
  ssh_password         = "${var.password}"
  ssh_timeout          = "4h"
  ssh_username         = "${var.username}"
  switch_name          = "${var.hyperv_switchname}"
  vm_name              = "${var.vm_name}"
}

build {
  sources = ["source.hyperv-iso.ubuntu"]

  provisioner "shell" {
    execute_command = "echo 'vagrant' | sudo -S -E sh {{ .Path }}"
    scripts         = [
      "./linux/ubuntu/update.sh", 
      "./linux/ubuntu/network.sh", 
      "./linux/common/vagrant.sh", 
      "./linux/common/chef.sh", 
      "./linux/common/motd.sh", 
      "./linux/ubuntu/cleanup.sh"
    ]
  }

  post-processor "vagrant" {
    keep_input_artifact = true
    output              = "${source.type}_ubuntu-18.04_chef.box"
  }
}

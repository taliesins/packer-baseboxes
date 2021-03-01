
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
  default = "d1f2bf834bbe9bb43faf16f9be992a6f3935e65be0edece1dee2aa6eb1767423"
}

variable "iso_checksum_type" {
  type    = string
  default = "sha256"
}

variable "iso_url" {
  type    = string
  default = "https://releases.ubuntu.com/focal/ubuntu-20.04.2-live-server-amd64.iso"
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
  default = "ubuntu-focal"
}

source "hyperv-iso" "ubuntu" {
  boot_command         = [
    "<esc><esc><esc><wait>",
    "set gfxpayload=1024x768<enter>",
    "linux /casper/vmlinuz ",
    "autoinstall \"ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/\" ",
    "hostname={{.Name}} ",
    "boot=casper fsck.mode=skip auto=true noprompt noeject",
    "<enter>",
    "initrd /casper/initrd<enter>",
    "boot<enter>"
  ]

  boot_wait            = "5s"
  communicator         = "ssh"
  cpus                 = "${var.cpu}"
  disk_size            = "${var.disk_size}"
  enable_secure_boot   = false
  generation           = 2
  guest_additions_mode = "disable"
  http_directory       = "./linux/ubuntu/http/20.04/"
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
    output              = "${source.type}_ubuntu-20.04_chef.box"
  }
}

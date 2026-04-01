packer {
  required_plugins {
    virtualbox = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

source "virtualbox-iso" "debian" {
  iso_url      = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-13.4.0-amd64-netinst.iso"
  iso_checksum = "sha256:0b813535dd76f2ea96eff908c65e8521512c92a0631fd41c95756ffd7d4896dc"
  ssh_username = "vagrant"
  ssh_password = "vagrant"
  ssh_timeout  = "20m"

  cpus   = 1    # mehr als 1 CPU
  memory = 2048 # mindestens 2 GB RAM

  guest_additions_mode = "attach"
  guest_os_type        = "Debian_64"
  disk_size            = 20480 # Größe in MB
  hard_drive_discard   = true
  boot_command = [
    "<esc><wait>",
    "auto url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
    "<enter>"
  ]
  boot_wait        = "5s"
  http_directory   = "http"
  shutdown_command = "sudo shutdown -P now"
  keep_registered  = true
  vm_name = "debian-minimal-vdi"
}

build {
  sources = ["source.virtualbox-iso.debian"]

}


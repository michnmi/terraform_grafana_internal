terraform {
  required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~>0.6"
    }
  }
}

provider "libvirt" {
  alias = "vmhost01"
  uri   = "qemu+ssh://jenkins_automation@vmhost01/system?keyfile=../id_ed25519_jenkins"
  # uri   = "qemu+ssh://michnmi@vmhost01/system"
}

provider "libvirt" {
  alias = "vmhost02"
  uri   = "qemu+ssh://jenkins_automation@vmhost02/system?keyfile=../id_ed25519_jenkins"
  # uri   = "qemu+ssh://vmhost02/system"
}

provider "libvirt" {
  alias = "vmhost03"
  uri   = "qemu+ssh://jenkins_automation@vmhost03/system?keyfile=../id_ed25519_jenkins"
  # uri   = "qemu+ssh://vmhost03/system"
}

variable "env" {
  type = string
}

resource "libvirt_volume" "grafana" {
  provider         = libvirt.vmhost01
  name             = "grafana-${var.env}.qcow2"
  pool             = var.env
  base_volume_name = "grafana-base.qcow2"
  format           = "qcow2"
  base_volume_pool = var.env
}

resource "libvirt_domain" "grafana" {
  provider  = libvirt.vmhost01
  name      = "grafana-${var.env}"
  memory    = "768"
  vcpu      = 2
  autostart = true

  // The MAC here is given an IP through mikrotik
  network_interface {
    macvtap  = "enp0s25"
    mac      = "52:54:00:EA:17:57"
    hostname = "grafana-${var.env}"
  }

  network_interface {
    // network_id = libvirt_network.default.id
    network_name = "default"
  }

  disk {
    volume_id = libvirt_volume.grafana.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = 0
  }

}

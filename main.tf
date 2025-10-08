resource "proxmox_vm_qemu" "k8s-master-pve" {
  name        = "master-1"
  target_node = "pve"
  provider    = proxmox
  onboot      = true
  clone       = "ubuntu-template"
  agent       = 1
  os_type     = "cloud-init"
  cores       = 2
  sockets     = 1
  numa        = true
  cpu         = "host"
  memory      = 4096
  scsihw      = "virtio-scsi-single"
  bootdisk    = "scsi0"

  serial {
    id   = 0
    type = "socket"
  }

  network {
    bridge   = "vmbr0"
    firewall = false
    model    = "virtio"
  }

  lifecycle {
    ignore_changes = [
      disk,
      vm_state,
      sshkeys
    ]
  }

  ipconfig0 = "ip=192.168.0.101/24,gw=${var.gateway}"
  ssh_user  = "ubuntu"
  sshkeys   = file(var.ssh_key_path)
}

resource "proxmox_vm_qemu" "k8s-master-pve2" {
  name        = "master-2"
  target_node = "pve2"
  provider    = proxmox.pve2
  onboot      = true
  clone       = "ubuntu-template"
  agent       = 1
  os_type     = "cloud-init"
  cores       = 2
  sockets     = 1
  numa        = true
  cpu         = "host"
  memory      = 4096
  scsihw      = "virtio-scsi-single"
  bootdisk    = "scsi0"

  serial {
    id   = 0
    type = "socket"
  }

  network {
    bridge   = "vmbr0"
    firewall = false
    model    = "virtio"
  }

  lifecycle {
    ignore_changes = [
      disk,
      vm_state,
      sshkeys
    ]
  }

  ipconfig0 = "ip=192.168.0.102/24,gw=${var.gateway}"
  ssh_user  = "ubuntu"
  sshkeys   = file(var.ssh_key_path)
}

resource "null_resource" "k8s-master-utm3" {
  triggers = {
    always_run = "${timestamp()}"
  }
}

resource "null_resource" "k8s-worker-utm3" {
  triggers = {
    always_run = "${timestamp()}"
  }
}

resource "null_resource" "k8s-worker-utm4" {
  triggers = {
    always_run = "${timestamp()}"
  }
}

resource "null_resource" "k8s-lb-utm3" {
  triggers = {
    always_run = "${timestamp()}"
  }
}

resource "proxmox_vm_qemu" "k8s-worker-pve" {
  count       = 3
  name        = "worker-pve-${count.index + 1}"
  target_node = "pve"
  provider    = proxmox

  onboot   = true
  clone    = "worker-template"
  agent    = 1
  os_type  = "cloud-init"
  cores    = 4
  sockets  = 2
  numa     = true
  cpu      = "host"
  memory   = 12284
  scsihw   = "virtio-scsi-single"
  bootdisk = "scsi0"

  serial {
    id   = 0
    type = "socket"
  }

  network {
    bridge   = "vmbr0"
    firewall = false
    model    = "virtio"
  }

  lifecycle {
    ignore_changes = [
      disk,
      vm_state,
      sshkeys
    ]
  }

  ipconfig0 = "ip=192.168.0.${count.index + 110}/24,gw=${var.gateway}"
  ssh_user  = "ubuntu"
  sshkeys   = file(var.ssh_key_path)
}

resource "proxmox_vm_qemu" "k8s-worker-pve2" {
  count       = 2
  name        = "worker-pve2-${count.index + 1}"
  target_node = "pve2"
  provider    = proxmox.pve2

  onboot   = true
  clone    = "worker-template"
  agent    = 1
  os_type  = "cloud-init"
  cores    = 4
  sockets  = 1
  numa     = true
  cpu      = "host"
  memory   = 6094
  scsihw   = "virtio-scsi-single"
  bootdisk = "scsi0"

  serial {
    id   = 0
    type = "socket"
  }

  network {
    bridge   = "vmbr0"
    firewall = false
    model    = "virtio"
  }

  lifecycle {
    ignore_changes = [
      disk,
      vm_state,
      sshkeys
    ]
  }

  ipconfig0 = "ip=192.168.0.${count.index + 115}/24,gw=${var.gateway}"
  ssh_user  = "ubuntu"
  sshkeys   = file(var.ssh_key_path)
}

resource "proxmox_vm_qemu" "lb-pve" {
  name        = "lb-1"
  target_node = "pve"
  provider    = proxmox
  onboot      = true
  clone       = "ubuntu-template"
  agent       = 1
  os_type     = "cloud-init"
  cores       = 2
  sockets     = 1
  numa        = true
  cpu         = "host"
  memory      = 2048
  scsihw      = "virtio-scsi-single"
  bootdisk    = "scsi0"

  serial {
    id   = 0
    type = "socket"
  }

  network {
    bridge   = "vmbr0"
    firewall = false
    model    = "virtio"
  }

  lifecycle {
    ignore_changes = [
      disk,
      vm_state,
      sshkeys
    ]
  }

  ipconfig0 = "ip=192.168.0.150/24,gw=${var.gateway}"
  ssh_user  = "ubuntu"
  sshkeys   = file(var.ssh_key_path)
}

resource "proxmox_vm_qemu" "lb-pve2" {
  name        = "lb-2"
  target_node = "pve2"
  provider    = proxmox.pve2
  onboot      = true
  clone       = "ubuntu-template"
  agent       = 1
  os_type     = "cloud-init"
  cores       = 2
  sockets     = 1
  numa        = true
  cpu         = "host"
  memory      = 2048
  scsihw      = "virtio-scsi-single"
  bootdisk    = "scsi0"

  serial {
    id   = 0
    type = "socket"
  }

  network {
    bridge   = "vmbr0"
    firewall = false
    model    = "virtio"
  }

  lifecycle {
    ignore_changes = [
      disk,
      vm_state,
      sshkeys
    ]
  }

  ipconfig0 = "ip=192.168.0.151/24,gw=${var.gateway}"
  ssh_user  = "ubuntu"
  sshkeys   = file(var.ssh_key_path)
}

resource "null_resource" "ansible_provisioner" {
  triggers = {
    always_run = "${timestamp()}"
    vm_ids = join(",", flatten([
      [proxmox_vm_qemu.k8s-master-pve.id, proxmox_vm_qemu.k8s-master-pve2.id, null_resource.k8s-master-utm3.id],
      [null_resource.k8s-worker-utm3.id, null_resource.k8s-worker-utm4.id],
      proxmox_vm_qemu.k8s-worker-pve[*].id,
      proxmox_vm_qemu.k8s-worker-pve2[*].id,
      [proxmox_vm_qemu.lb-pve.id, proxmox_vm_qemu.lb-pve2.id, null_resource.k8s-lb-utm3.id]
    ]))
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "[k8s_masters]" > inventory.ini
      echo "master-1 ansible_host=192.168.0.101 ansible_user=ubuntu ansible_ssh_private_key_file=~/Projects/.ssh/id_ed25519" >> inventory.ini
      echo "master-2 ansible_host=192.168.0.102 ansible_user=ubuntu ansible_ssh_private_key_file=~/Projects/.ssh/id_ed25519" >> inventory.ini
      echo "master-3 ansible_host=192.168.0.103 ansible_user=ubuntu ansible_ssh_private_key_file=~/Projects/.ssh/id_ed25519" >> inventory.ini
      echo "" >> inventory.ini
      echo "[k8s_workers]" >> inventory.ini
      echo "worker-pve-1 ansible_host=192.168.0.110 ansible_user=ubuntu ansible_ssh_private_key_file=~/Projects/.ssh/id_ed25519" >> inventory.ini
      echo "worker-pve-2 ansible_host=192.168.0.111 ansible_user=ubuntu ansible_ssh_private_key_file=~/Projects/.ssh/id_ed25519" >> inventory.ini
      echo "worker-pve-3 ansible_host=192.168.0.112 ansible_user=ubuntu ansible_ssh_private_key_file=~/Projects/.ssh/id_ed25519" >> inventory.ini
      echo "worker-pve2-1 ansible_host=192.168.0.115 ansible_user=ubuntu ansible_ssh_private_key_file=~/Projects/.ssh/id_ed25519" >> inventory.ini
      echo "worker-pve2-2 ansible_host=192.168.0.116 ansible_user=ubuntu ansible_ssh_private_key_file=~/Projects/.ssh/id_ed25519" >> inventory.ini
      echo "worker-utm-3 ansible_host=192.168.0.120 ansible_user=ubuntu ansible_ssh_private_key_file=~/Projects/.ssh/id_ed25519" >> inventory.ini
      echo "worker-utm-4 ansible_host=192.168.0.121 ansible_user=ubuntu ansible_ssh_private_key_file=~/Projects/.ssh/id_ed25519" >> inventory.ini
      echo "" >> inventory.ini
      echo "[load_balancers]" >> inventory.ini
      echo "lb-1 ansible_host=192.168.0.150 ansible_user=ubuntu ansible_ssh_private_key_file=~/Projects/.ssh/id_ed25519" >> inventory.ini
      echo "lb-2 ansible_host=192.168.0.151 ansible_user=ubuntu ansible_ssh_private_key_file=~/Projects/.ssh/id_ed25519" >> inventory.ini
      echo "lb-utm-3 ansible_host=192.168.0.155 ansible_user=ubuntu ansible_ssh_private_key_file=~/Projects/.ssh/id_ed25519" >> inventory.ini
      echo "" >> inventory.ini
      echo "[k8s_cluster:children]" >> inventory.ini
      echo "k8s_masters" >> inventory.ini
      echo "k8s_workers" >> inventory.ini
    EOT
  }

  provisioner "local-exec" {
    command = "ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook -i inventory.ini ansible/main.yml"
  }

  depends_on = [
    proxmox_vm_qemu.k8s-master-pve,
    proxmox_vm_qemu.k8s-master-pve2,
    null_resource.k8s-master-utm3,
    null_resource.k8s-worker-utm3,
    null_resource.k8s-worker-utm4,
    null_resource.k8s-lb-utm3,
    proxmox_vm_qemu.k8s-worker-pve,
    proxmox_vm_qemu.k8s-worker-pve2,
    proxmox_vm_qemu.lb-pve,
    proxmox_vm_qemu.lb-pve2
  ]
}

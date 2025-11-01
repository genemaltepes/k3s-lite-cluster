output "vm_ips" {
  description = "IP addresses of all VMs"
  value = {
    for k, v in proxmox_vm_qemu.vms : k => v.default_ipv4_address
  }
}

output "vm_ids" {
  description = "VM IDs"
  value = {
    for k, v in proxmox_vm_qemu.vms : k => v.vmid
  }
}

output "ansible_inventory_path" {
  description = "Path to generated Ansible inventory"
  value       = local_file.ansible_inventory.filename
}

output "deployment_summary" {
  description = "Deployment summary"
  value = <<-EOT
    ╔═══════════════════════════════════════════════════════╗
    ║           K3S TEST Cluster Infrastructure             ║
    ╠═══════════════════════════════════════════════════════╣
    ║                                                       ║
    ║                                                       ║
    ║ Masters:                                              ║
    ║   - master1: 192.168.1.171                            ║
    ║                                                       ║
    ║                                                       ║
    ║ Workers:                                              ║
    ║   - worker1: 192.168.1.172                            ║
    ║                                                       ║
    ║                                                       ║
    ║                                                       ║
    ║                                                       ║
    ║ Next Steps:                                           ║
    ║                                                       ║
    ║   ansible-playbook -i inventory.yml site.yml          ║
    ╚═══════════════════════════════════════════════════════╝
  EOT
}

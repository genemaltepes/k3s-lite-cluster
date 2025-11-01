all:
  vars:
    ansible_user: ${ansible_user}
    ansible_become: true
    ansible_ssh_private_key_file: ~/.ssh/id_ed25519
    ansible_python_interpreter: /usr/bin/python3
    k3s_version: v1.33.5+k3s1
    k3s_cluster_cidr: 10.42.0.0/16
    k3s_service_cidr: 10.43.0.0/16
        
  children:
    masters:
      hosts:
%{ for k, v in vms ~}
%{ if startswith(k, "master") ~}
        ${k}:
          ansible_host: ${v.ip}
          node_ip: ${v.ip}
%{ endif ~}
%{ endfor ~}
      vars:
        node_type: master
        
    workers:
      hosts:
%{ for k, v in vms ~}
%{ if startswith(k, "worker") ~}
        ${k}:
          ansible_host: ${v.ip}
          node_ip: ${v.ip}
%{ endif ~}
%{ endfor ~}
      vars:
        node_type: worker
        
    k3s_cluster:
      children:
        masters:
        workers:
        
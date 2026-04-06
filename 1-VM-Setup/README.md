ToDos quality:
- proper tagging of ansible plays
- move kubectl, repo and so on to kubernetes role
- ansible-lint fixes
- make sure Ansible runs are idempotent

TASK [kubernetes : Restart kubelet]
TASK [kubernetes : Read sysctl configs]
TASK [kubernetes : Generate join command]

- build own image(s)
- documentation ;)


ToDos features:
- make ansible and playbooks available on management host
- split common role and make features more generic (proxmox prep)
- make sure the playbooks are working with Ubuntu and Rocky
- sshd hardening
- make sure if works with qemu, too -> plugin required (quick win)
- store ansible inventory on management host
- change directory structure to be more generic (vagrant install vs proxmox)

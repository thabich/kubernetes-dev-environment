#!/usr/bin/env python3
import os

LEASE_FILE = "/var/lib/misc/dnsmasq.leases"
STATIC_CONF = "/etc/dnsmasq.d/static_leases.conf"

def get_current_static_macs():
    if not os.path.exists(STATIC_CONF):
        return set()
    with open(STATIC_CONF, 'r') as f:
        return {line.split(',')[0].split('=')[-1] for line in f if 'dhcp-host' in line}

def freeze_leases():
    static_macs = get_current_static_macs()
    new_entries = []

    if not os.path.exists(LEASE_FILE):
        return

    with open(LEASE_FILE, 'r') as f:
        for line in f:
            # Format: timestamp mac ip hostname client-id
            parts = line.strip().split()
            if len(parts) >= 4:
                _, mac, ip, hostname = parts[:4]
                if mac not in static_macs and hostname != "*":
                    new_entries.append(f"dhcp-host={mac},{hostname},{ip}\n")

    if new_entries:
        with open(STATIC_CONF, 'a') as f:
            f.writelines(new_entries)
        # Nur neustarten, wenn sich was geändert hat
        os.system("systemctl reload dnsmasq")

if __name__ == "__main__":
    freeze_leases()

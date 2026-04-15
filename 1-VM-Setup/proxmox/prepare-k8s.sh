#!/bin/bash
set -xe
K8S_REPO_VERSION="v1.35"

# Do not install docs and man pages
cat <<EOF > /etc/dpkg/dpkg.cfg.d/01_nodoc
path-exclude /usr/share/doc/*
path-exclude /usr/share/man/*
path-exclude /usr/share/groff/*
path-exclude /usr/share/info/*
path-exclude /usr/share/lintian/*
path-exclude /usr/share/linda/*
EOF

echo "man-db man-db/auto-update boolean false" | debconf-set-selections

# Base install
apt-get update
apt-get install -y apt-transport-https ca-certificates curl socat conntrack gpg qemu-guest-agent
systemctl enable qemu-guest-agent

# Prepare Repos
mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
curl -fsSL "https://pkgs.k8s.io/core:/stable:/${K8S_REPO_VERSION}/deb/Release.key" | gpg --batch --yes --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${K8S_REPO_VERSION}/deb/ /" > /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y containerd.io kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# Fix config
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
sed -i 's/disabled_plugins = \[.*"cri".*\]/disabled_plugins = []/g' /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

# Network/Kernel settings
echo "br_netfilter" > /etc/modules-load.d/br_netfilter.conf
cat <<EOF > /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
EOF


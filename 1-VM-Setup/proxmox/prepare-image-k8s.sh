#!/bin/bash
set -e
VM_ID=9001
TMP_ID=9002
VM_NAME="debian-13-k8s-template"
STORAGE="local-lvm"
CLOUD_INIT_STORAGE="cloud-init"
IMAGE_PATH="/tmp/debian-13-generic-amd64.qcow2"
DOWNLOAD_URL="https://chuangtzu.ftp.acc.umu.se/images/cloud/trixie/latest/debian-13-generic-amd64.qcow2"
HW_CORES=2
HW_SOCKETS=1 
HW_MEM=2048
HW_BRIDGE=hznet


# Get base image
curl -vL -o "${IMAGE_PATH}" ${DOWNLOAD_URL}

# Install packages and fix configs
virt-customize -v -a "${IMAGE_PATH}" \
  --network \
  --run "prepare-k8s.sh" \

# Cleanup
virt-sysprep -a "${IMAGE_PATH}"
virt-sparsify --in-place "${IMAGE_PATH}"

# Cleanup remaining old tmp images if any
qm destroy "${TMP_ID}" || true

# Create VM
# --ostype l26 (Linux 2.6 - 6.x)
# --agent 1 (activate QEMU Guest Agent)
qm create "${TMP_ID}" --name "${VM_NAME}-tmp" \
   --memory "${HW_MEM}" \
   --cores "${HW_CORES}" \
   --sockets "${HW_SOCKETS}" \
   --net0 "virtio,bridge=${HW_BRIDGE}" \
   --ostype l26 \
   --agent 1

# Import Image
qm disk import "${TMP_ID}" "${IMAGE_PATH}" "${STORAGE}" --format qcow2 
qm set "${TMP_ID}" --scsihw virtio-scsi-pci --scsi0 "${STORAGE}:vm-${TMP_ID}-disk-0"

# Set boot order, net0 for a fix in related to capmox

qm set ${TMP_ID} --boot order="scsi0;net0"



# Delete old template, and create new one on it's place
qm destroy "${VM_ID}" || true
qm clone "${TMP_ID}" "${VM_ID}" --name "${VM_NAME}" --full 1
qm destroy "${TMP_ID}" || true


# Create dummy cloud init device (doing it here, otherwise it's marked with size=4M)
qm set "${VM_ID}" --ide0 ${CLOUD_INIT_STORAGE}:cloudinit

qm template "${VM_ID}"

echo "Finished creation of ne K8S Image"

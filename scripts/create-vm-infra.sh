#!/usr/bin/env bash

VMXML_DIR=/root/ocp-deployment/libvirt-xml


vm_vol_is_active=$(virsh pool-list --all | awk '$1 ~ /vg_vm/ {print $0}' | grep -c active)

if [[ "$vm_vol_is_active" -eq 0 ]]; then
 virsh pool-start vg_vm
fi

# Create disks
virsh vol-create-as vg_vm master0-root --capacity 60G --allocation 60G
virsh vol-create-as vg_vm master1-root --capacity 60G --allocation 60G
virsh vol-create-as vg_vm master2-root --capacity 60G --allocation 60G

virsh vol-create-as vg_vm ocs0-root --capacity 60G --allocation 60G
virsh vol-create-as vg_vm ocs1-root --capacity 60G --allocation 60G
virsh vol-create-as vg_vm ocs2-root --capacity 60G --allocation 60G

virsh vol-create-as vg_vm ocs0-data0 --capacity 60G --allocation 60G
virsh vol-create-as vg_vm ocs0-data1 --capacity 60G --allocation 60G
virsh vol-create-as vg_vm ocs0-data2 --capacity 60G --allocation 60G

virsh vol-create-as vg_vm ocs1-data0 --capacity 60G --allocation 60G
virsh vol-create-as vg_vm ocs1-data1 --capacity 60G --allocation 60G
virsh vol-create-as vg_vm ocs1-data2 --capacity 60G --allocation 60G

virsh vol-create-as vg_vm ocs2-data0 --capacity 60G --allocation 60G
virsh vol-create-as vg_vm ocs2-data1 --capacity 60G --allocation 60G
virsh vol-create-as vg_vm ocs2-data2 --capacity 60G --allocation 60G


# Define machines
for VM in master{0,1,2} ocs{0,1,2}
  do
     virsh define --file $VMXML_DIR/$VM.xml
     virsh autostart $VM
  done

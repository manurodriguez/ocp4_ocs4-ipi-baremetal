#!/usr/bin/env bash

# Let the user know that this will destroy the environment
ANSWER=YES

if virsh list --all | egrep -q  'master|ocs'
then
  unset ANSWER
  echo '*** WARNING ***'
  echo 'This procedure will destroy the environment you currently have'
  echo 'Type uppercase YES if you understand this and want to proceed'
  read -p 'Your answer > ' ANSWER
fi

[ "${ANSWER}" != "YES" ] && exit 1


# Delete and undefine master nodes
for VM in master{0,1,2}
  do
     virsh destroy $VM
     virsh undefine $VM
     virsh vol-delete --pool vg_vm $VM-root
  done


# Delete and undefine worker nodes
for VM in ocs{0,1,2}
  do
     virsh destroy $VM
     virsh undefine $VM
     virsh vol-delete --pool vg_vm $VM-root
     virsh vol-delete --pool vg_vm $VM-data
  done

#!/usr/bin/env bash

# Stop VMs vbmc agent
for VM in master{0,1,2} ocs{0,1,2}
  do
    /usr/local/bin/vbmc stop $VM
  done


# Remove VMs from vbmc
for VM in master{0,1,2} ocs{0,1,2}
  do
    /usr/local/bin/vbmc delete $VM
  done

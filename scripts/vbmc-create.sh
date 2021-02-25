#!/usr/bin/env bash

# Add VMs to vbmc
/usr/local/bin/vbmc add master0 --port 6220
/usr/local/bin/vbmc add master1 --port 6221
/usr/local/bin/vbmc add master2 --port 6222
/usr/local/bin/vbmc add ocs0 --port 6230
/usr/local/bin/vbmc add ocs1 --port 6231
/usr/local/bin/vbmc add ocs2 --port 6232


# Start VMs vbmc agent
/usr/local/bin/vbmc start master0
/usr/local/bin/vbmc start master1
/usr/local/bin/vbmc start master2
/usr/local/bin/vbmc start ocs0
/usr/local/bin/vbmc start ocs1
/usr/local/bin/vbmc start ocs2

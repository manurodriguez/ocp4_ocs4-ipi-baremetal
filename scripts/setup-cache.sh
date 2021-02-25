#!/usr/bin/env bash

sudo firewall-cmd --add-port=8080/tcp --zone=libvirt --permanent
sudo firewall-cmd --add-port=8080/tcp --zone=libvirt
sudo dnf install -y podman
mkdir /home/kni/rhcos_image_cache
sudo semanage fcontext -a -t httpd_sys_content_t "/home/kni/rhcos_image_cache(/.*)?"
sudo restorecon -Rv rhcos_image_cache/
ls -Z /home/kni/rhcos_image_cache
podman run -d --name rhcos_image_cache -v /home/kni/rhcos_image_cache:/var/www/html -p 8080:8080/tcp registry.centos.org/centos/httpd-24-centos7:latest

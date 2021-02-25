generate-config
=========

This role generates the install-config.yaml template to deploy Red Hat Openshift

Requirements
------------

- Tested on Ansible 2.9 and above
- python3, python-pip3, and python3-netaddr

Role Variables
--------------

See inventory/hosts for full details of the role variables


Dependencies
------------

This role has no dependecines

Example Playbook
----------------

File: generate-config.yml
```
---
- name: IPI on Baremetal Installation Playbook
  hosts: localhost
  roles:
  - generate-config

  environment:
    http_proxy: "{{ http_proxy }}"
    https_proxy: "{{ https_proxy }}"
    no_proxy: "{{ no_proxy_list }}"
```

Then run:
```
$ ansible-playbook generate-config.yml

```

License
-------

Apache License, Version 2.0

Author Information
------------------

Manuel Rodriguez

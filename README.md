
OCP4 IPI Baremetal with OCS4
=========

A series of roles to deploy OCP4/OCS4 using Libvirt/KVM and ansible

Requirements
------------

- Tested on Ansible 2.9 and above
- openshift k8s collection (sudo pip3 install openshift)
- oc client (playbook needs to be executed in a server with access to API and variable KUBECONFIG defined)

Variables
--------------

See the role defaults/mail.yaml and role READMEs 


Example Execution:
----------------

Run:
```bash
$ ansible-playbook generate-config.yml
$ ansible-playbook install-ocp.yaml
$ ansible-playbook add-worker.yaml
$ ansible-playbook ocs-deploy.yml

```

License
-------

Apache License, Version 2.0

Author Information
------------------

Manuel Rodriguez


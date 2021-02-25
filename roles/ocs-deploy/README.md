
ocs-deploy
=========

This role Install Local Storage Operator (LSO) and Openshift Container Storage (OCS)

Requirements
------------

- Tested on Ansible 2.9 and above
- openshift k8s collection (sudo pip3 install openshift)
- oc client (playbook needs to be executed in a server with access to API and variable KUBECONFIG defined)

Role Variables
--------------

Modify defaults/mail.yaml with the disk lisk to setup


Dependencies
------------

This role has no dependencies


Files
------------

Files and task on the play are numbered in order of execution.

```bash
roles/ocs-deploy/
├── defaults
│   └── main.yaml					--> modify default vars for your env
├── files						--> templates with default values
│   ├── 01-local-storage-namespace.yaml
│   ├── 02-local-storage-operator.yaml
│   ├── 05-openshift-storage-namespace.yaml
│   ├── 06-openshift-storage-operatorgroup.yaml
│   ├── 09-ocs-rbd-pvc-test.yaml
│   └── 10-ocs-cephfs-pvc-test.yaml
├── tasks
│   └── main.yml
└── templates
    ├── 03-local-storage-operator-subscribe.j2
    ├── 04-local-storage-block.j2
    ├── 07-openshift-storage-operator-subscribe.j2
    └── 08-openshift-storage-cluster.j2
```

Example Playbook
----------------

File: generate-config.yml
```
---
- name: Ansible playbooks to install OCS resources
  gather_facts: false
  hosts: localhost
  roles:
    - ocs-deploy
```

Then run:
```
$ ansible-playbook ocs-deploy.yml

```

License
-------

Apache License, Version 2.0

Author Information
------------------

Manuel Rodriguez


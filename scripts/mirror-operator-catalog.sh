#!/usr/bin/env bash

export OCP_VERSION="v4.6"
export AUTH_FILE="/home/kni/pull-secret-update.json"
export MIRROR_REGISTRY_DNS="provisioner.example.com:5000"

# Build the catalog for redhat-operators
oc adm catalog build --appregistry-org redhat-operators \
  --from=registry.redhat.io/openshift4/ose-operator-registry:$OCP_VERSION \
  --to=${MIRROR_REGISTRY_DNS}/olm/redhat-operators:v1 \
  --registry-config=${AUTH_FILE} \
  --filter-by-os="linux/amd64" --insecure

# Mirror the catalog for redhat-operators
oc adm catalog mirror ${MIRROR_REGISTRY_DNS}/olm/redhat-operators:v1 \
${MIRROR_REGISTRY_DNS} --registry-config=${AUTH_FILE} --insecure

# Generate the imageContentSourcePolicy.yaml manifest
oc adm catalog mirror ${MIRROR_REGISTRY_DNS}/olm/redhat-operators:v1 \
${MIRROR_REGISTRY_DNS} --registry-config=${AUTH_FILE} --insecure --manifests-only=true

# Disable the default OperatorSources
oc patch OperatorHub cluster --type json -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'

# add any missing entries to the .yaml file and apply them to cluster.
oc apply -f redhat-operators-manifests/imageContentSourcePolicy.yaml

# verify that catalogsource and pod were created correctly.
oc get catalogsource,pod -n openshift-marketplace | grep redhat-operators

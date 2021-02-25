#!/usr/bin/env bash

REG_CREDS=~/pull-secret-update.json
MIRROR_SOURCE=registry.redhat.io
MIRROR_DESTINATION="provisioner.example.com:5000"
WORK_DIR=redhat-operator-index-manifests

# Before running script Authenticate with your target and origin registries:
#podman login ${MIRROR_SOURCE} 
#podman login ${MIRROR_DESTINATION}

# Run the source index image that you want to prune in a containe
podman run -d --name redhat_index_operator -p 50051:50051/tcp -it ${MIRROR_SOURCE}/redhat/redhat-operator-index:v4.6

# On another shell run this, then Ctrl+C the podman run in first shell
grpcurl -plaintext localhost:50051 api.Registry/ListPackages > packages.out

# prune the source index of all but the specified packages:
opm index prune \
    -f ${MIRROR_SOURCE}/redhat/redhat-operator-index:v4.6 \
    -p local-storage-operator,ocs-operator \
    -t ${MIRROR_DESTINATION}/olm/redhat-operator-index:v4.6 

# push the new index image to your target registry:
podman push ${MIRROR_DESTINATION}/olm/redhat-operator-index:v4.6

# Create creds variable and GODEBUG ignore
REG_CREDS=pull-secret-update.json
export GODEBUG=x509ignoreCN=0

# extract the contents of an index image to generate the manifests required for mirroring.
database=$(oc adm catalog mirror \
    ${MIRROR_DESTINATION}/olm/redhat-operator-index:v4.6 \
    ${MIRROR_DESTINATION} \
    -a ${REG_CREDS} \
    --insecure \
    --filter-by-os='.*' \
    --manifests-only | grep "using database at:" | awk '{print $4}')


echo "select * from related_image where operatorbundle_name like '%storage%';" | sqlite3 -line $database > ~/${WORK_DIR}/images.txt
echo "select * from related_image where operatorbundle_name like '%ocs%';" | sqlite3 -line $database >> ~/${WORK_DIR}/images.txt

awk '$1 ~ /image/ {print $3}' ~/${WORK_DIR}/images.txt > ~/${WORK_DIR}/images-filtered.txt

for line in $(cat ~/${WORK_DIR}/images-filtered.txt)
  do
    grep "$line" ~/${WORK_DIR}/mapping.txt
  done | sort -u > ~/${WORK_DIR}/mapping-custom.txt

#  use your modified mapping.txt file to mirror the images to your registry using the oc image mirror command:
oc image mirror -a ${REG_CREDS} -f ~/${WORK_DIR}/mapping-custom.txt


# Disable the sources for the default catalogs
oc patch OperatorHub cluster --type json \
	    -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'


# Create a CatalogSource object that references your index image.
cat << EOF > ~/${WORK_DIR}/imageContentSourcePolicy-custom.yaml
apiVersion: operator.openshift.io/v1alpha1
kind: ImageContentSourcePolicy
metadata:
  name: redhat-operator-index
spec:
  repositoryDigestMirrors:
EOF

for LINE in $(cat ${WORK_DIR}/mapping-custom.txt | awk -F"@" '{print $1}' | sort -u )
  do
    REPO=$( echo "$LINE" | awk -F"/" '{print $2"/"$3}')
    echo "  - mirrors:" >>  ~/${WORK_DIR}/imageContentSourcePolicy-custom.yaml
    echo "    - ${MIRROR_DESTINATION}/${REPO}" >> ~/${WORK_DIR}/imageContentSourcePolicy-custom.yaml
    echo "    source: ${MIRROR_SOURCE}/${REPO}" >> ~/${WORK_DIR}/imageContentSourcePolicy-custom.yaml
  done

# Apply the ImageContentSourcePolicy object:
oc apply -f ~/${WORK_DIR}/imageContentSourcePolicy-custom.yaml


# Create a CatalogSource object that references your index image.
cat << EOF > ~/${WORK_DIR}/catalogsource-custom.yaml
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: redhat-operators
  namespace: openshift-marketplace
spec:
  sourceType: grpc
  image: ${MIRROR_DESTINATION}/olm/redhat-operator-index:v4.6 
  displayName: Customized Catalog
  publisher: redhat-consulting
  updateStrategy:
    registryPoll: 
      interval: 30m
EOF

# Use the file to create the CatalogSource object:
oc create -f ~/${WORK_DIR}/catalogsource-custom.yaml

# clean up
rm ~/${WORK_DIR}/images.txt
rm ~/${WORK_DIR}/images-filtered.txt
rm ~/${WORK_DIR}/mapping.txt
podman stop redhat_index_operator
podman rm redhat_index_operator

#!/usr/bin/env bash

# Validate upgrades up to 4.6.19
if [[ $# -ne 1 ]]; then
 echo "Usage: $0 < VERSION >"
 echo "If using current 4.6.8, then you can update to 4.6.9 or 4.6.10"
 echo "Ex: $0 4.6.9"
 exit 1
else
 if [[ $1 =~ ^4\.6\.[9-19]$ ]]; then
  echo "Preparing upgrade to $1" 
 else
  echo "$1 does not appear to be a valid option."
  echo "Usage: $0 < VERSION >"
  echo "Ex: $0 4.6.9"
  exit 1
 fi
fi

# Define the version you want to install
export VERSION=$1


# This block will pull oc and openshift install clients using the specified version above
export RELEASE_IMAGE=$(curl -s https://mirror.openshift.com/pub/openshift-v4/clients/ocp/$VERSION/release.txt | grep 'Pull From: quay.io' | awk -F ' ' '{print $3}')
export cmd=openshift-baremetal-install
export pullsecret_file=~/pull-secret.txt
export extract_dir=$(pwd)
curl -s https://mirror.openshift.com/pub/openshift-v4/clients/ocp/$VERSION/openshift-client-linux.tar.gz | tar zxvf - oc
sudo cp oc /usr/local/bin
oc adm release extract --registry-config "${pullsecret_file}" --command=$cmd --to "${extract_dir}" ${RELEASE_IMAGE}


# From the chosen release the internal registry is synced
export UPSTREAM_REPO="quay.io/openshift-release-dev/ocp-release:$VERSION-x86_64"
export PULLSECRET=$HOME/pull-secret-update.json
export LOCAL_REPO='ocp4/openshift4'
export LOCAL_REG="provisioner.example.com:5000"
export GODEBUG=x509ignoreCN=0
/usr/local/bin/oc adm release mirror -a pull-secret-update.json --from=$UPSTREAM_REPO --to-release-image=$LOCAL_REG/$LOCAL_REPO:${VERSION} --to=$LOCAL_REG/$LOCAL_REPO --apply-release-image-signature


# Get the digest ID of the version to upgrade and trigger the upgrade
DIGEST=$(oc adm release info $UPSTREAM_REPO | sed -n 's/Pull From: .*@//p')
oc adm upgrade --allow-explicit-upgrade --to-image $LOCAL_REG/$LOCAL_REPO@$DIGEST


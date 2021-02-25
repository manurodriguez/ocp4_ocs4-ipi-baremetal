#!/usr/bin/env bash

# Modify variables accordingly
LOCATION="/home/kni/registry"
USER="foobar"
PASSWORD="wbU9RV0JrWFJIcVpwN01UT0ZDX0dM"
EMAIL="manrodri@redhat.com"
LOCAL_REG="provisioner.example.com:5000" 
VERSION=4.6.19


sudo yum -y install python3 podman httpd httpd-tools jq
sudo firewall-cmd --add-port=5000/tcp --zone=libvirt --permanent
sudo firewall-cmd --add-port=5000/tcp --zone=libvirt 

# UPDATE CERT VARIABLES
mkdir -p $LOCATION/{auth,certs,data}
host_fqdn=$( hostname --long )
cert_c="CA"
cert_s="Quebec"
cert_l="Montreal"
cert_o="RedHat"
cert_ou="Consulting"
cert_cn="${host_fqdn}"
openssl req     -newkey rsa:4096     -nodes     -sha256     -keyout $LOCATION/certs/domain.key     -x509     -days 365     -out $LOCATION/certs/domain.crt     -subj "/C=${cert_c}/ST=${cert_s}/L=${cert_l}/O=${cert_o}/OU=${cert_ou}/CN=${cert_cn}"
sudo cp $LOCATION/certs/domain.crt /etc/pki/ca-trust/source/anchors/
sudo update-ca-trust extract

htpasswd -bBc $LOCATION/auth/htpasswd $USER $PASSWORD

podman create   --name ocpdiscon-registry   -p 5000:5000   -e "REGISTRY_AUTH=htpasswd"   -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry"   -e "REGISTRY_HTTP_SECRET=ALongRandomSecretForRegistry"   -e "REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd"   -e "REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt"   -e "REGISTRY_HTTP_TLS_KEY=/certs/domain.key"   -e "REGISTRY_COMPATIBILITY_SCHEMA1_ENABLED=true"   -v $LOCATION/data:/var/lib/registry:z   -v $LOCATION/auth:/auth:z   -v $LOCATION/certs:/certs:z   docker.io/library/registry:2
podman start ocpdiscon-registry
podman ps

host_fqdn=$( hostname --long )
b64auth=$( echo -n "$USER:$PASSWORD" | openssl base64 ) 
AUTHSTRING="{\"$host_fqdn:5000\": {\"auth\": \"$b64auth\",\"email\": \"$EMAIL\"}}"                                                                                        
jq ".auths += $AUTHSTRING" < pull-secret.txt > pull-secret-update.json                                                                                                                 

export UPSTREAM_REPO="quay.io/openshift-release-dev/ocp-release:$VERSION-x86_64"
export PULLSECRET=$HOME/pull-secret-update.json
export LOCAL_REPO='ocp4/openshift4'
export GODEBUG=x509ignoreCN=0
/usr/local/bin/oc adm release mirror -a pull-secret-update.json --from=$UPSTREAM_REPO --to-release-image=$LOCAL_REG/$LOCAL_REPO:${VERSION} --to=$LOCAL_REG/$LOCAL_REPO

echo "additionalTrustBundle: |" >> install-config.yaml
sed -e 's/^/  /' $LOCATION/certs/domain.crt >> install-config.yaml

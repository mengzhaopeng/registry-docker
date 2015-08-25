#!/bin/bash
# Important! - the script is only tested on CentOS7 and please use root permissions to execute.
set -e
source config

NGINX_IMAGE_NAME=${NGINX_IMAGE_NAME:-h3nrik/nginx-ldap}

CA_PATH=/etc/pki/CA
SSL_PATH=/etc/ssl
ROOT_KEY=cakey.pem
ROOT_CERT=cacert.pem
NGINX_KEY=nginx.key
NGINX_CSR=nginx.csr
NGINX_CRT=nginx.crt
NGINX_CONF=nginx.conf
CERT_DAYS=3650

# Create root certificate and key
rm -rf ${CA_PATH}/serial ${CA_PATH}/index.txt ${CA_PATH}/private/${ROOT_KEY} ${CA_PATH}/${ROOT_CERT}
touch ${CA_PATH}/{serial,index.txt}
echo "00" > ${CA_PATH}/serial
openssl genrsa -out ${CA_PATH}/private/${ROOT_KEY} 2048
openssl req -new -x509 -key ${CA_PATH}/private/${ROOT_KEY} -subj \
  /C=${C}/ST=${ST}/L=${L}/O=${O}/OU=${OU}/CN=$HOSTNAME/emailAddress=${emailAddress} \
  -days ${CERT_DAYS} -out ${CA_PATH}/${ROOT_CERT}

# Create nginx certificate and key
rm -rf ${SSL_PATH}/${NGINX_KEY} ${SSL_PATH}/${NGINX_CSR} ${SSL_PATH}/${NGINX_CRT}
openssl genrsa -out ${SSL_PATH}/${NGINX_KEY} 2048
openssl req -new -key ${SSL_PATH}/${NGINX_KEY} -subj \
  /C=${C}/ST=${ST}/L=${L}/O=${O}/OU=${OU}/CN=$HOSTNAME/emailAddress=${emailAddress} \
  -out ${SSL_PATH}/${NGINX_CSR}
openssl ca -in ${SSL_PATH}/${NGINX_CSR} -days ${CERT_DAYS} -out ${SSL_PATH}/${NGINX_CRT} <<EOF
y
y
EOF

# import certificate
rm -rf /etc/pki/tls/certs/ca-bundle.crt.bak
cp /etc/pki/tls/certs/ca-bundle.crt{,.bak}
cat /etc/pki/CA/cacert.pem >> /etc/pki/tls/certs/ca-bundle.crt

#
rm -rf ~/registry-docker/${NGINX_CONF}
sed -e "s/{HOSTNAME}/$HOSTNAME/g" ~/registry-docker/${NGINX_CONF}.template > ~/registry-docker/${NGINX_CONF}
sed -i "s/{LDAP_SERVER}/${LDAP_SERVER}/g" ~/registry-docker/${NGINX_CONF}
sed -i "s/{LDAP_BASE_DN}/${LDAP_BASE_DN}/g" ~/registry-docker/${NGINX_CONF}
sed -i "s/{SLAPD_PASSWORD}/${SLAPD_PASSWORD}/g" ~/registry-docker/${NGINX_CONF}

docker run \
--name nginx \
-p 80:80 -p 443:443 \
-v ${SSL_PATH}/${NGINX_CRT}:${SSL_PATH}/${NGINX_CRT} \
-v ${SSL_PATH}/${NGINX_KEY}:${SSL_PATH}/${NGINX_KEY} \
-v ~/registry-docker/${NGINX_CONF}:/etc/nginx/${NGINX_CONF}:ro \
-d ${NGINX_IMAGE_NAME}

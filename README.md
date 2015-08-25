Private Docker Registry with Nginx(ldap)

Important! - the script is only tested on CentOS7 and please use root permissions to execute.

createRegistry.sh - create docker registry container\n
createNginxForRegistry.sh - create nginx(ldap) container
createRegistryUi.sh - create http service of registry container

Server Certificate:
    /etc/pki/CA/cacert.pem
Client:
    $ cp /etc/pki/tls/certs/ca-bundle.crt{,.bak}
    $ cat cacert.pem >> /etc/pki/tls/certs/ca-bundle.crt
    $ systemctl restart docker
    $ docker login https://{SERVER_HOSTNAME}

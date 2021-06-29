#!/usr/bin/env bash

# Generates a wildcard certificate for a given domain name.

set -e

# Get environment variables from the .env file
set -o allexport; source .env; set +o allexport

# Logging
function log_ok()   { echo -e "\e[32m✔ $1\e[39m"; }
function log_err()  { echo -e "\e[31m✗ $1\e[39m"; }
function log_info() { echo -e "\e[39m$1\e[39m"; }
function log_cmd_output { echo -n -e "\e[90m"; }

if [ -z "$1" ]; then
    log_err "\e[43mMissing domain name!\e[49m"
    echo
    log_info "Usage: $0 example.com"
    echo
    log_info "This will generate a wildcard certificate for the given domain name and its subdomains."
    exit 1
fi

DOMAIN=$1

if [ ! -f "$CA_KEY" ]; then
    log_err "Certificate Authority private key does not exist!"
    echo
    log_info "Please run \e[93mcreate-ca.sh\e[39m first."
    exit 1
fi

mkdir $DOMAIN
log_ok "Creating directory $DOMAIN complete"

# Generate a private key
openssl genrsa -out "$DOMAIN/$DOMAIN.key" $DOMAIN_KEY_BITS
log_ok "Creating private key complete ($DOMAIN/$DOMAIN.key)"

# Create a certificate signing request
openssl req -new -subj "/C=$SUBJ_C/ST=$SUBJ_ST/L=$SUBJ_L/O=$SUBJ_O/OU=$SUBJ_OU/emailAddress=$SUBJ_EMAIL/CN=$DOMAIN" -key "$DOMAIN/$DOMAIN.key" -out "$DOMAIN/$DOMAIN.csr"
log_ok "Creating certificate signing request complete ($DOMAIN/$DOMAIN.csr)"

# Create a config file for the extensions
>"$DOMAIN/$DOMAIN.ext" cat <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = $DOMAIN
DNS.2 = *.$DOMAIN
EOF

log_ok "Creating config file complete ($DOMAIN/$DOMAIN.ext)"

# Create the signed certificate
openssl x509 -req \
    -in "$DOMAIN/$DOMAIN.csr" \
    -extfile "$DOMAIN/$DOMAIN.ext" \
    -CA $CA_CRT \
    -CAkey $CA_KEY \
    -CAcreateserial \
    -out "$DOMAIN/$DOMAIN.crt" \
    -days 365 \
    -sha256

echo -e "\e[42mSuccess!\e[49m"
echo
echo -e "You can now use \e[93m$DOMAIN/$DOMAIN.key\e[39m and \e[93m$DOMAIN/$DOMAIN.crt\e[39m in your web server."
echo -e "Don't forget that \e[1myou must have imported \e[93mca.crt\e[39m in your browser\e[0m to make it accept the certificate."

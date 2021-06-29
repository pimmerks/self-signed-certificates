#!/usr/bin/env bash
set -e

# Get environment variables from the .env file
set -o allexport; source .env; set +o allexport

# Logging
function log_ok()   { echo -e "\e[32m✔ $1\e[39m"; }
function log_err()  { echo -e "\e[31m✗ $1\e[39m"; }
function log_info() { echo -e "\e[39m$1\e[39m"; }
function log_cmd_output { echo -n -e "\e[90m"; }


if [ -f "$CA_CRT" ] || [ -f "$CA_KEY" ]; then
    log_err "Certificate Authority files already exist!"
    echo
    log_info "You only need a single CA even if you need to create multiple certificates."
    log_info "This way, you only ever have to import the certificate in your browser once."
    echo
    log_info "If you want to restart from scratch, delete the \e[93m$CA_CRT\e[39m and \e[93m$CA_KEY\e[39m files."
    exit 1
fi

log_info "Specify a new password for your CA key, please keep this somewhere safe!"
echo -n "Password: "
read -s CA_PASSWORD
echo
log_cmd_output


# Generate private key
openssl genrsa -passout pass:$CA_PASSWORD -out $CA_KEY -aes256 $CA_KEY_BITS
log_ok "Created CA key file completed"


# Generate root certificate
openssl req -x509 -new \
  -subj "/C=$SUBJ_C/ST=$SUBJ_ST/L=$SUBJ_L/O=$SUBJ_O/OU=$SUBJ_OU/CN=$SUBJ_CN/emailAddress=$SUBJ_EMAIL" \
  -key $CA_KEY \
  -sha256 \
  -passin pass:$CA_PASSWORD \
  -days $CA_CRT_DAYS \
  -out $CA_CRT


log_ok "Creating root certificate completed"
echo
log_info "The following files have been written:"
log_info "  - \e[93m$CA_CRT\e[39m is the public certificate that should be imported in your browser"
log_info "  - \e[93m$CA_KEY\e[39m is the private key that will be used by \e[93mcreate-certificate.sh\e[39m"
echo
log_info "Next steps:"
log_info "  - Import \e[93m$CA_CRT\e[39m in your browser"
log_info "  - run \e[93mcreate-certificate.sh example.com\e[39m"

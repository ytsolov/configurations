#!/usr/bin/env bash

shopt -s expand_aliases
_xtrace() {
    case $1 in
        on) set -x ;;
        off) set +x ;;
    esac
}
alias xtrace='{ _xtrace $(cat); } 2>/dev/null <<<'

# SOURCE: https://jamielinux.com/docs/openssl-certificate-authority/sign-server-and-client-certificates.html

set -e

if [ $(echo "${1}" | wc -w) -eq 0 ]; then
    echo "You must supply a CA directory"
    exit 1
else
    CA_DIR_ROOT="${1}"
fi

if [ $(echo "${2}" | wc -w) -eq 0 ]; then
    echo "You must supply a CA name"
    exit 1
else
    CA_NAME="${2}"
    CA_CFG_NAME="${CA_NAME}-openssl.cnf"
    CA_CHAIN_CERTS_NAME="ca-chain-${CA_NAME}.cert.pem"
fi

if [ $(echo "${3}" | wc -w) -eq 0 ]; then
    echo "You must supply an output directory"
    exit 1
else
    DIR_ROOT="${3}"
fi

if [ $(echo "${4}" | wc -w) -eq 0 ]; then
    echo "You must supply a name"
    exit 1
else
    SSL_NAME="${4}"
    SSL_KEY_NAME="${SSL_NAME}.key.pem"
    SSL_CSR_NAME="${SSL_NAME}.csr.pem"
    SSL_CERT_NAME="${SSL_NAME}.cert.pem"
fi

SSL_KEY="${DIR_ROOT}/private/${SSL_KEY_NAME}"
SSL_CSR="${DIR_ROOT}/csr/${SSL_CSR_NAME}"
SSL_CERT="${DIR_ROOT}/certs/${SSL_CERT_NAME}"

CA_CFG="${CA_DIR_ROOT}/${CA_CFG_NAME}"
CA_CHAIN_CERTS="${CA_DIR_ROOT}/certs/${CA_CHAIN_CERTS_NAME}"

echo ""
echo "================================================================================"
echo "==> Creating and initializing \"${DIR_ROOT}\""
xtrace on
mkdir -p "${DIR_ROOT}"
cd "${DIR_ROOT}"
mkdir -p \
    "${DIR_ROOT}/certs" \
    "${DIR_ROOT}/csr" \
    "${DIR_ROOT}/private"
xtrace off
echo "${PWD}"

echo ""
echo "================================================================================"
echo "==> Create key"
xtrace on
rm -f "${SSL_KEY}"
openssl genrsa -aes256 -out "${SSL_KEY}" 2048
chmod 400 "${SSL_KEY}"
xtrace off

echo ""
echo "================================================================================"
echo "==> Create certificate signing request(COMMON NAME must be FQDN)"
xtrace on
openssl req -config "${CA_CFG}" \
      -key "${SSL_KEY}" \
      -new -sha256 \
      -out "${SSL_CSR}"
xtrace off

echo ""
echo "================================================================================"
echo "==> Create certificate"
xtrace on
cd ${DIRROOT}
rm -f "${SSL_CERT}"
openssl ca -config "${CA_CFG}" \
    -extensions server_cert -days 375 -notext -md sha256 \
    -in "${SSL_CSR}" \
    -out "${SSL_CERT}"
chmod 444 "${SSL_CERT}"
xtrace off

echo ""
echo "================================================================================"
echo "==> Verify issued certificate"
xtrace on
openssl x509 -noout -text -in "${SSL_CERT}"
xtrace off

echo ""
echo "================================================================================"
echo "==> Verify certificate against intermediate certificate"
xtrace on
openssl verify -CAfile "${CA_CHAIN_CERTS}" "${SSL_CERT}"
xtrace off

echo ""
echo "Work was done in: ${DIR_ROOT}"
echo "Private key: ${SSL_KEY}"
echo "Certificate: ${SSL_CERT}"


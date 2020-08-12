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
    CA_CERTS_CHAIN_NAME="chain-${CA_NAME}.cert.pem"
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
    SSL_CERT_PEM_NAME="${SSL_NAME}.cert.pem"
    SSL_CERT_DER_NAME="${SSL_NAME}.cert.der"
    SSL_CERT_CRT_NAME="${SSL_NAME}.cert.crt"
    SSL_CERT_CER_NAME="${SSL_NAME}.cert.cer"
    SSL_CERT_PKCS12_NAME="${SSL_NAME}.cert.p12"
    SSL_CERT_PKCS12_MS_CAPI_NAME="${SSL_NAME}.ms-capi.cert.p12"
fi

SSL_KEY="${DIR_ROOT}/private/${SSL_KEY_NAME}"
SSL_CSR="${DIR_ROOT}/csr/${SSL_CSR_NAME}"
SSL_CERT_PEM="${DIR_ROOT}/certs/${SSL_CERT_PEM_NAME}"
SSL_CERT_DER="${DIR_ROOT}/certs/${SSL_CERT_DER_NAME}"
SSL_CERT_CRT="${DIR_ROOT}/certs/${SSL_CERT_CRT_NAME}"
SSL_CERT_CER="${DIR_ROOT}/certs/${SSL_CERT_CER_NAME}"
SSL_CERT_PKCS12="${DIR_ROOT}/certs/${SSL_CERT_PKCS12_NAME}"
SSL_CERT_PKCS12_MS_CAPI="${DIR_ROOT}/certs/${SSL_CERT_PKCS12_MS_CAPI_NAME}"

CA_CFG="${CA_DIR_ROOT}/${CA_CFG_NAME}"
CA_CERTS_CHAIN="${CA_DIR_ROOT}/certs/${CA_CERTS_CHAIN_NAME}"


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
echo "==> Generate key"
xtrace on
rm -f "${SSL_KEY}"
openssl genrsa -aes256 -out "${SSL_KEY}" 2048
chmod 400 "${SSL_KEY}"
xtrace off


echo ""
echo "================================================================================"
echo "==> Generate certificate signing request(COMMON NAME must be FQDN)"
xtrace on
openssl req -config "${CA_CFG}" \
      -key "${SSL_KEY}" \
      -new -sha256 \
      -out "${SSL_CSR}"
xtrace off


echo ""
echo "================================================================================"
echo "==> Generate certificate(PEM)"
xtrace on
cd ${DIRROOT}
rm -f "${SSL_CERT_PEM}"
openssl ca -config "${CA_CFG}" \
    -extensions server_cert -days 375 -notext -md sha256 \
    -in "${SSL_CSR}" \
    -out "${SSL_CERT_PEM}"
chmod 444 "${SSL_CERT_PEM}"
xtrace off


echo ""
echo "================================================================================"
echo "==> Verify issued certificate"
xtrace on
openssl x509 -noout -text -in "${SSL_CERT_PEM}"
xtrace off


echo ""
echo "================================================================================"
echo "==> Verify certificate against intermediate certificate"
xtrace on
openssl verify -CAfile "${CA_CERTS_CHAIN}" "${SSL_CERT_PEM}"
xtrace off


echo ""
echo "================================================================================"
echo "==> Generate certificate(DER)"
xtrace on
rm -f "${SSL_CERT_DER}"
openssl x509 -outform der -in "${SSL_CERT_PEM}" -out "${SSL_CERT_DER}"
chmod 444 "${SSL_CERT_DER}"
xtrace off


echo ""
echo "================================================================================"
echo "==> Generate certificate(CRT)"
xtrace on
rm -f "${SSL_CERT_CRT}"
openssl x509 -outform der -in "${SSL_CERT_PEM}" -out "${SSL_CERT_CRT}"
chmod 444 "${SSL_CERT_CRT}"
xtrace off


echo ""
echo "================================================================================"
echo "==> Generate certificate(CER)"
xtrace on
rm -f "${SSL_CERT_CER}"
openssl x509 -inform der -in "${SSL_CERT_DER}" -out "${SSL_CERT_CER}"
chmod 444 "${SSL_CERT_CRT}"
xtrace off


echo ""
echo "================================================================================"
echo "==> Generate PKCS#12 certificate"
xtrace on
rm -f "${SSL_CERT_PKCS12}"
openssl pkcs12 -export -out "${SSL_CERT_PKCS12}" -inkey "${SSL_KEY}" -in "${SSL_CERT_PEM}" #-certfile "${CA_CERTS_CHAIN}"
chmod 444 "${SSL_CERT_PKCS12}"

rm -f "${SSL_CERT_PKCS12_MS_CAPI}"
openssl pkcs12 -export -out "${SSL_CERT_PKCS12_MS_CAPI}" -inkey "${SSL_KEY}" -in "${SSL_CERT_PEM}" #-certfile "${CA_CERTS_CHAIN}" -CSP "Microsoft RSA SChannel Cryptographic Provider"
chmod 444 "${SSL_CERT_PKCS12_MS_CAPI}"
xtrace off


echo ""
echo "================================================================================"
echo "Work was done in:         \"${DIR_ROOT}\""
echo "Private key:              \"${SSL_KEY}\""
echo "Certificate(PEM):         \"${SSL_CERT_PEM}\""
echo "Certificate(DER):         \"${SSL_CERT_DER}\""
echo "Certificate(CRT):         \"${SSL_CERT_CRT}\""
echo "Certificate(CER):         \"${SSL_CERT_CER}\""
echo "Certificate(PKCS12):      \"${SSL_CERT_PKCS12}\""
echo "Certificate(PKCS12-CAPI): \"${SSL_CERT_PKCS12_MS_CAPI}\""


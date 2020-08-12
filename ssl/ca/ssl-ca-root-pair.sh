#!/usr/bin/env bash

shopt -s expand_aliases
_xtrace() {
    case $1 in
        on) set -x ;;
        off) set +x ;;
    esac
}
alias xtrace='{ _xtrace $(cat); } 2>/dev/null <<<'

# SOURCE: https://jamielinux.com/docs/openssl-certificate-authority/create-the-root-pair.html

set -e

if [ $(echo "${1}" | wc -w) -eq 0 ]; then
    DIR_NAME="ca-root-pair-$(date "+%F-%T")"
    DIR_ROOT="/tmp/${DIR_NAME}"
else
    DIR_NAME=$(basename "${1}")
    DIR_ROOT="${1}"
fi

if [ $(echo "${2}" | wc -w) -eq 0 ]; then
    echo "You must supply a name"
    exit 1
else
    SSL_NAME="${2}"
    SSL_KEY_NAME="${SSL_NAME}.key.pem"
    SSL_CERT_NAME="${SSL_NAME}.cert.pem"
    SSL_CFG_NAME="${SSL_NAME}-openssl.cnf"
fi

SSL_KEY="${DIR_ROOT}/private/${SSL_KEY_NAME}"
SSL_CERT="${DIR_ROOT}/certs/${SSL_CERT_NAME}"
SSL_CFG="${DIR_ROOT}/${SSL_CFG_NAME}"

echo ""
echo "================================================================================"
echo "==> Creating and initializing \"${DIR_ROOT}\""
xtrace on
mkdir -p "${DIR_ROOT}"
cd "${DIR_ROOT}"
mkdir -p \
    "${DIR_ROOT}/certs" \
    "${DIR_ROOT}/crl" \
    "${DIR_ROOT}/newcerts" \
    "${DIR_ROOT}/private"
xtrace off
echo "${PWD}"


echo ""
echo "================================================================================"
echo "==> Creating"
xtrace on
chmod 700 ${DIR_ROOT}/private
touch ${DIR_ROOT}/index.txt
echo 1000 > ${DIR_ROOT}/serial
xtrace off


echo ""
echo "================================================================================"
echo "==> Generating configuration"
echo "${SSL_CFG}"
cat << EOF > "${SSL_CFG}"
#
# OpenSSL example configuration file.
# This is mostly being used for generation of certificate requests.
#

# Note that you can include other files from the main configuration
# file using the .include directive.
#.include filename

# This definition stops the following lines choking if HOME isn't
# defined.
HOME			= .

# Extra OBJECT IDENTIFIER info:
#oid_file		= $ENV::HOME/.oid
oid_section		= new_oids

# To use this configuration file with the "-extfile" option of the
# "openssl x509" utility, name here the section containing the
# X.509v3 extensions to use:
# extensions		=
# (Alternatively, use a configuration file that has only
# X.509v3 extensions in its main [= default] section.)

[ new_oids ]

# We can add new OIDs in here for use by 'ca', 'req' and 'ts'.
# Add a simple OID like this:
# testoid1=1.2.3.4
# Or use config file substitution like this:
# testoid2=${testoid1}.5.6

# Policies used by the TSA examples.
tsa_policy1 = 1.2.3.4.1
tsa_policy2 = 1.2.3.4.5.6
tsa_policy3 = 1.2.3.4.5.7

####################################################################
[ ca ]
default_ca	= CA_default		# The default ca section

####################################################################
[ CA_default ]

# Directory and file locations.
dir	            = ${DIR_ROOT}	    # Where everything is kept
certs		    = \$dir/certs		# Where the issued certs are kept
new_certs_dir	= \$dir/newcerts	# default place for new certs.
database	    = \$dir/index.txt	# database index file.
serial		    = \$dir/serial 		# The current serial number
RANDFILE        = \$dir/private/.rand

# The root key and root certificate.
private_key	= \$dir/private/${SSL_KEY_NAME}   # The private key
certificate	= \$dir/certs/${SSL_CERT_NAME} 	# The CA certificate

# For certificate revocation lists.
crlnumber	        = \$dir/crlnumber	    # the current crl number
crl		            = \$dir/crl/ca.crl.pem 	# The current CRL
crl_extensions	    = crl_ext
default_crl_days    = 30			        # how long before next CRL

# SHA-1 is deprecated, so use SHA-2 instead.
default_md	= sha256

name_opt 	    = ca_default	# Subject Name options
cert_opt 	    = ca_default	# Certificate field options
default_days	= 365			# how long to certify for
preserve	    = no			# keep passed DN ordering
policy		    = policy_strict

# Added
crl_dir	        = \$dir/crl		# Where the issued crl are kept
x509_extensions	= usr_cert		# The extensions to add to the cert
#unique_subject	= no			# Set to 'no' to allow creation of several certs with same subject.


# A few difference way of specifying how similar the request should look
# For type CA, the listed attributes must be the same, and the optional
# and supplied fields are just that :-)

[ policy_strict ]
# The root CA should only sign intermediate certificates that match.
# See the POLICY FORMAT section of \`man ca\`.
countryName             = match
stateOrProvinceName     = match
organizationName        = match
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ policy_loose ]
# Allow the intermediate CA to sign a more diverse range of certificates.
# See the POLICY FORMAT section of the \`ca\` man page.
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

####################################################################
[ req ]
default_bits		= 2048
distinguished_name	= req_distinguished_name
attributes		    = req_attributes

# This sets a mask for permitted string types. There are several options.
# default: PrintableString, T61String, BMPString.
# pkix	 : PrintableString, BMPString (PKIX recommendation before 2004)
# utf8only: only UTF8Strings (PKIX recommendation after 2004).
# nombstr : PrintableString, T61String (no BMPStrings or UTF8Strings).
# MASK:XXXX a literal mask value.
# WARNING: ancient versions of Netscape crash on BMPStrings or UTF8Strings.
string_mask = utf8only

# SHA-1 is deprecated, so use SHA-2 instead.
default_md          = sha256

x509_extensions	    = v3_ca	# The extensions to add to the self signed cert

# req_extensions = v3_req # The extensions to add to a certificate request

[ req_distinguished_name ]

countryName         = Country Name (2 letter code)
countryName_default = BG
countryName_min     = 2
countryName_max     = 2

stateOrProvinceName			= State or Province Name (full name)
stateOrProvinceName_default = Bulgaria

localityName            = Locality Name
localityName_default    =

0.organizationName      	= Organization Name
0.organizationName_default	= COMPANY

organizationalUnitName  = Organizational Unit Name
organizationalUnitName_default	= COMPANY Certificate Authority

commonName              = Common Name
commonName_max			= 64
commonName_default      = COMPANY Root CA

emailAddress            = Email Address
emailAddress_max		= 64

[ req_attributes ]
challengePassword		= A challenge password
challengePassword_min		= 4
challengePassword_max		= 20

unstructuredName		= An optional company name

[ v3_req ]

# Extensions to add to a certificate request

basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment

[ v3_ca ]
# Extensions for a typical CA (\`man x509v3_config\`).
subjectKeyIdentifier 	= hash
authorityKeyIdentifier 	= keyid:always,issuer
basicConstraints 		= critical, CA:true
keyUsage 				= critical, digitalSignature, cRLSign, keyCertSign

# Some might want this also
# nsCertType = sslCA, emailCA

# Include email address in subject alt name: another PKIX recommendation
# subjectAltName	= email:copy
# Copy issuer details
# issuerAltName		= issuer:copy

# DER hex encoding of an extension: beware experts only!
# obj=DER:02:03
# Where 'obj' is a standard or added object
# You can even override a supported extension:
# basicConstraints= critical, DER:30:03:01:01:FF

[ v3_intermediate_ca ]
# Extensions for a typical intermediate CA (\`man x509v3_config\`).
subjectKeyIdentifier	= hash
authorityKeyIdentifier	= keyid:always,issuer
basicConstraints		= critical, CA:true, pathlen:0
keyUsage				= critical, digitalSignature, cRLSign, keyCertSign

[ usr_cert ]
# Extensions for client certificates (\`man x509v3_config\`).
basicConstraints 		= CA:FALSE
nsCertType 				= client, email
nsComment 				= "OpenSSL Generated Client Certificate"
subjectKeyIdentifier 	= hash
authorityKeyIdentifier 	= keyid,issuer
keyUsage 				= critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage 		= clientAuth, emailProtection

[ server_cert ]
# Extensions for server certificates (\`man x509v3_config\`).
basicConstraints 		= CA:FALSE
nsCertType 				= server
nsComment 				= "OpenSSL Generated Server Certificate"
subjectKeyIdentifier 	= hash
authorityKeyIdentifier 	= keyid,issuer:always
keyUsage 				= critical, digitalSignature, keyEncipherment
extendedKeyUsage 		= serverAuth

[ crl_ext ]
# Extension for CRLs (\`man x509v3_config\`).
authorityKeyIdentifier	= keyid:always

[ ocsp ]
# Extension for OCSP signing certificates (\`man ocsp\`).
basicConstraints 		= CA:FALSE
subjectKeyIdentifier 	= hash
authorityKeyIdentifier 	= keyid,issuer
keyUsage 				= critical, digitalSignature
extendedKeyUsage 		= critical, OCSPSigning

################################################################################
################################################################################
################################################################################

[ proxy_cert_ext ]
# These extensions should be added when creating a proxy certificate

# This goes against PKIX guidelines but some CAs do it and some software
# requires this to avoid interpreting an end user certificate as a CA.

basicConstraints=CA:FALSE

# Here are some examples of the usage of nsCertType. If it is omitted
# the certificate can be used for anything *except* object signing.

# This is OK for an SSL server.
# nsCertType			= server

# For an object signing certificate this would be used.
# nsCertType = objsign

# For normal client use this is typical
# nsCertType = client, email

# and for everything including object signing:
# nsCertType = client, email, objsign

# This is typical in keyUsage for a client certificate.
# keyUsage = nonRepudiation, digitalSignature, keyEncipherment

# This will be displayed in Netscape's comment listbox.
nsComment			= "OpenSSL Generated Certificate"

# PKIX recommendations harmless if included in all certificates.
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer

# This stuff is for subjectAltName and issuerAltname.
# Import the email address.
# subjectAltName=email:copy
# An alternative to produce certificates that aren't
# deprecated according to PKIX.
# subjectAltName=email:move

# Copy subject details
# issuerAltName=issuer:copy

#nsCaRevocationUrl		= http://www.domain.dom/ca-crl.pem
#nsBaseUrl
#nsRevocationUrl
#nsRenewalUrl
#nsCaPolicyUrl
#nsSslServerName

# This really needs to be in place for it to be a proxy certificate.
proxyCertInfo=critical,language:id-ppl-anyLanguage,pathlen:3,policy:foo
EOF

echo ""
echo "================================================================================"
echo "==> Create the root key"
xtrace on
rm -f "${SSL_KEY}"
openssl genrsa -aes256 -out "${SSL_KEY}" 4096
chmod 400 "${SSL_KEY}"
xtrace off

echo ""
echo "================================================================================"
echo "==> Create the root certificate"
xtrace on
openssl req -config "${SSL_CFG}" \
	-key "${SSL_KEY}" \
	-new -x509 -days 7300 -sha256 -extensions v3_ca \
	-out "${SSL_CERT}"
xtrace off

echo ""
echo "================================================================================"
echo "==> Verify root certificate"
xtrace on
openssl x509 -noout -text -in "${SSL_CERT}"
xtrace off

echo ""
echo "Work was done in: ${DIR_ROOT}"
echo "Private key: ${SSL_KEY}"
echo "Certificate: ${SSL_CERT}"


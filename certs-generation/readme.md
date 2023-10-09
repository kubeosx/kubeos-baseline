Below we assume the existence of a subfolder .\mTLS under openssl command.

Openssl commands:

# Create CA
openssl req -x509 -sha256 -newkey rsa:4096 -keyout mTLS\ca.key -out mTLS\ca.crt -days 3650 -nodes -subj "/CN=My Cert Authority"

# Generate the Server Key, and Certificate and Sign with the CA Certificate
openssl req -out mTLS\server_dev.csr -newkey rsa:4096 -nodes -keyout mTLS\server_dev.key -config mTLS\server_dev.cnf
openssl x509 -req -sha256 -days 3650 -in mTLS\server_dev.csr -CA mTLS\ca.crt -CAkey mTLS\ca.key -set_serial 01 -out mTLS\server_dev.crt

# Generate the Client Key, and Certificate and Sign with the CA Certificate
openssl req -out mTLS\client_dev.csr -newkey rsa:4096 -nodes -keyout mTLS\client_dev.key -config mTLS\client_dev.cnf
openssl x509 -req -sha256 -days 3650 -in mTLS\client_dev.csr -CA mTLS\ca.crt -CAkey mTLS\ca.key -set_serial 02 -out mTLS\client_dev.crt

# to verify CSR and show SAN
openssl req -text -in mTLS\server_dev.csr -noout -verify
openssl req -text -in mTLS\client_dev.csr -noout -verify
Since API Management expects certs in Microsoft format such as .pfx and .cer, and Kubernetes expects certs in .crt and .key format, we need the following conversion.

# Convert .crt + .key to .pfx
openssl pkcs12 -export -out mTLS\ca.pfx -inkey mTLS\ca.key -in mTLS\ca.crt
openssl pkcs12 -export -out mTLS\client_dev.pfx -inkey mTLS\client_dev.key -in mTLS\client_dev.crt
openssl pkcs12 -export -out mTLS\server_dev.pfx -inkey mTLS\server_dev.key -in mTLS\server_dev.crt
#!/bin/bash

# Generate SERVER CA certs
openssl genrsa -out pki/server-ca.key 2048
openssl req -x509 -new -nodes -key pki/server-ca.key -sha256 -days 365 -out pki/server-ca.crt -subj "/C=BD/ST=Dhaka/L=Dhaka/O=ARINDAMGB/OU=MTLS-SERVER-CA/CN=certificate-authority"

# Generate Server certs
openssl genrsa -out pki/server.key 2048
openssl req -new -key pki/server.key -out pki/server.csr -subj "/C=BD/ST=Dhaka/L=Dhaka/O=ARINDAMGB/OU=MTLS-SERVER/CN=*.flaskmtlsdifferentca.com"
openssl x509 -req -in pki/server.csr -CA pki/server-ca.crt -CAkey pki/server-ca.key -CAcreateserial -out pki/server.crt -days 365 -sha256

# Generate CLIENT CA certs
openssl genrsa -out pki/client-ca.key 2048
openssl req -x509 -new -nodes -key pki/client-ca.key -sha256 -days 365 -out pki/client-ca.crt -subj "/C=BD/ST=Dhaka/L=Dhaka/O=ARINDAMGB/OU=MTLS-CLIENT-CA/CN=certificate-authority"

# Generate Client certs
openssl genrsa -out pki/client.key 2048
openssl req -new -key pki/client.key -out pki/client.csr -subj "/C=BD/ST=Dhaka/L=Dhaka/O=ARINDAMGB/OU=MTLS-CLIENT/CN=*.dummyclientdomain.com"
openssl x509 -req -in pki/client.csr -CA pki/client-ca.crt -CAkey pki/client-ca.key -CAcreateserial -out pki/client.crt -days 365 -sha256

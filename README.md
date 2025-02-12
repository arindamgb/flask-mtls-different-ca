# Flask api for mTLS using different CA
![Flask](https://img.shields.io/badge/flask-%23000.svg?style=for-the-badge&logo=flask&logoColor=white)![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)![Shell Script](https://img.shields.io/badge/shell_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)

### This is a practical implementation to understand how mTLS works with Server and Client Certificates signed by different CA Authority

## TLS vs mTLS
While TLS and mTLS provide encrypted communication, the primary difference lies in the authentication process. In TLS, only the server's identity is authenticated by the client, whereas in mTLS, both client and server identities are authenticated mutually.

![mtls alt text](/images/tlsvsmtls.png "TLS vs mTLS")

*Image Source: thesslstore.com*


## What is mTLS
Mutual TLS, or mTLS, is a type of mutual authentication in which the two parties in a connection authenticate each other using the TLS protocol. Also, Kubernetes uses this extensively to ensure secure commnucation between different cluster components.

![mtls alt text](/images/mtls.png "How mTLS works")

*Image Source: medium.com*

# Running this project in Docker

> Server certificate is signed by server-ca, Client certificate is signed by client-ca.

> Server certificate should be trusted at the client. Client certificate should be trusted at the server.

```
# git clone https://github.com/arindamgb/flask-mtls-different-ca
# cd flask-mtls-different-ca
# echo '127.0.0.1 api.flaskmtlsdifferentca.com' >> /etc/hosts
# bash cert-generate.sh
# bash run.sh
# docker logs flask-mtls-different-ca
INFO: *** Client auth is disabled ***
```

# Without mTLS
```
# curl https://api.flaskmtlsdifferentca.com:5002
curl failed to verify the legitimacy of the server and therefore could not establish a secure connection to it.
```

This is because we are using self-signed certificate that is not signed by an actual CA. We can use the **--insecure** or **-k** parameter to avoid this validation.

```
# curl https://api.flaskmtlsdifferentca.com:5002 -k
{"message":"Welcome to the mTLS Flask App!"}
```

Or, we can pass the server certificate of the server CA explicitly.
```
# curl https://api.flaskmtlsdifferentca.com:5002 --cacert pki/server-ca.crt
{"message":"Welcome to the mTLS Flask App!"}
```

But why do we need to use `--cacert pki/server-ca.crt`? Think of it this way: The browser comes with pre-installed certificates from all authorized CAs, making those certificates trusted by default. However, since we are using our own CA that we created, we need to install its certificate in the browser to explicitly tell it to trust our CA. Now, replace `browser` with `curl`—both are client applications. So, `--cacert pki/server-ca.crt` instructs curl to include our CA certificate as trusted.

Thus, we have validated the server certificate.

*Please note, the **-k** or **--cacert** option won't be needed if the server certificate is issued by an actual CA like **Digicert**, **Comodo** etc.*

# Enable mTLS and redeploy
```
# sed -i '/^#MTLS_ENABLED=true/s/^#//' .env
# bash run.sh
# docker logs flask-mtls-auth
INFO: *** mTLS is enabled ***
```


# With mTLS
```
# curl https://api.flaskmtlsdifferentca.com:5002 --cacert pki/server-ca.crt
curl: (56) OpenSSL SSL_read: error:0A00045C:SSL routines::tlsv13 alert certificate required, errno 0
```

This error indicates that the server we are trying to communicate with using curl is requiring a client certificate as part of mutual TLS (mTLS) authentication, but the client (our curl command) has not provided one.
```
# curl https://api.flaskmtlsdifferentca.com:5002 --cacert pki/server-ca.crt --cert pki/client.crt --key pki/client.key
{"message":"Welcome to the mTLS Flask App!"}
```
Now, we have authenticated ourselves using the client certificate and client key. Again **--cacert** option won't be needed in case of an actual CA.

# Troubleshooting

#### Scenario 1

```
# curl https://api.flaskmtlsauth.com:5002 --cacert pki/client-ca.crt
curl: (60) SSL certificate problem: unable to get local issuer certificate
```

The server CA certificate is not found because that was not passed using `--cacert` option. Pass the right CA certificate i.e. `server-ca.crt` to avoid this error.

#### Scenario 2

```
# curl https://api.flaskmtlsauth.com:5002 --cacert pki/server-ca.crt
curl: (60) SSL: certificate subject name '*.flaskmtlsdifferentca.com' does not match target host name 'api.flaskmtlsauth.com'
```

There is a domain name related issue in the certificate. The domain name must be present in the **CN** or **SAN** field defined in the server certificate. Use the domain name mentioned in the certificate, or generate another certificate mentioning the right domain to fix this issue.

Inspect the current certificate as below:
```
# openssl x509 -in pki/server.crt -noout -text | grep Subject:
Subject: C = BD, ST = Dhaka, L = Dhaka, O = ARINDAMGB, OU = MTLS-SERVER, CN = *.flaskmtlsdifferentca.com
```

> **Signing off, [Arindam Gustavo Biswas](https://www.linkedin.com/in/arindamgb/)**
>
> 12th February 2025, 04:41 AM

#!/bin/bash
set -euo pipefail

# ref. https://dev.mysql.com/doc/connector-j/5.1/en/connector-j-reference-using-ssl.html
# This script check ENVs and generate the java truststore if needed
if [[ -v CA_CERT_FILE ]] && [[ -v CLIENT_CERT_FILE ]] && [[ -v CLIENT_KEY_FILE ]]; then
    # the password is only used inside the container
    export STORE_PASS=playground
    export JAVA_ARGS="-Djavax.net.ssl.trustStore=/flyway/flyway-truststore -Djavax.net.ssl.trustStorePassword=${STORE_PASS} -Djavax.net.ssl.keyStore=/flyway/flyway-keystore -Djavax.net.ssl.keyStorePassword=${STORE_PASS}"

    echo "Generating a Java keystore..."
    # $CA_CERT_FILE, $CLIENT_KEY_FILE and $CLIENT_CERT_FILE are the paths to SSL certs for mysql client
    # for example
    # CA_CERT_FILE=/work/${CERTS}/ca.pem
    # CLIENT_KEY_FILE=/work/${CERTS}/client-key.pem
    # CLIENT_CERT_FILE=/work/${CERTS}/client-cert.pem

    # trust store for server authentication
    keytool -keystore flyway-truststore -storepass:env STORE_PASS -noprompt -trustcacerts -importcert -alias mysqlclient -file $CA_CERT_FILE

    # key store for client authentication
    openssl pkcs12 -export -in ${CLIENT_CERT_FILE} -inkey ${CLIENT_KEY_FILE} -out client.p12 -name mysql-client -passout pass:${STORE_PASS}
    keytool -importkeystore -deststorepass ${STORE_PASS} -destkeystore flyway-keystore -srckeystore client.p12 -srcstoretype PKCS12 -srcstorepass ${STORE_PASS} -alias mysql-client
fi

flyway $@

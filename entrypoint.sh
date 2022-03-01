#!/bin/bash
set -euo pipefail

# This script check ENVs and generate the java truststore if needed
if [[ -v CA_CERT_FILE ]] && [[ -v CLIENT_CERT_FILE ]] && [[ -v CLIENT_KEY_FILE ]]; then
    # the password is only used inside the container
    export STORE_PASS=playground
    export JAVA_ARGS="-Djavax.net.ssl.trustStore=/flyway/flyway-keystore -Djavax.net.ssl.trustStorePassword=${STORE_PASS}"

    echo "Generating a Java keystore..."
    # CA_CERT_FILE, CLIENT_KEY_FILE and CLIENT_CERT_FILE are ENVs with paths to SSL certs for a SQL client
    cat $CA_CERT_FILE $CLIENT_KEY_FILE $CLIENT_CERT_FILE > bundle.pem
    keytool -keystore flyway-keystore -storepass:env STORE_PASS -noprompt -trustcacerts -importcert -alias sqlclient -file bundle.pem
fi

flyway $@

#!/bin/bash

if [[ -n "$BASE64_ENCODED_BASTION_SSH_KEY" && -n "$DB_HOST" && -n "$BASTION_USERNAME" && -n "$BASTION_HOST" && -n "$BASTION_PORT" && -n "$DATABASE_PORT" ]];
then
    echo -n "$BASE64_ENCODED_BASTION_SSH_KEY" | base64 -d > /flyway/bastion_ssh_private_key
    chmod 600 /flyway/bastion_ssh_private_key
    chown flyway:flyway /flyway/bastion_ssh_private_key
    ssh -o "StrictHostKeyChecking no" -i /flyway/bastion_ssh_private_key -f ${BASTION_USERNAME}@${BASTION_HOST} -p ${BASTION_PORT} -L ${DATABASE_PORT}:${DB_HOST}:${DATABASE_PORT} -N
    echo "Connected"
else
    echo "WARNING: BASE64_ENCODED_BASTION_SSH_KEY, DB_HOST, BASTION_USERNAME, BASTION_HOST, BASTION_PORT, or DATABASE_PORT was not set. Note: BASTION HOST WILL NOT BE USED"
fi

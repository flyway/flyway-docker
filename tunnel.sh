#!/bin/bash

if [[ -n "$BASTION_SSH_KEY" && -n "$DB_HOST" && -n "$BASTION_USERNAME" && -n "$BASTION_HOST" && -n "$BASTION_PORT" && -n "$DATABASE_PORT" ]];
then
    echo "$BASTION_SSH_KEY" > /flyway/bastion_ssh_private_key
    chmod 600 /flyway/bastion_ssh_private_key
    chown flyway:flyway /flyway/bastion_ssh_private_key
    ssh -o "StrictHostKeyChecking no" -i /flyway/bastion_ssh_private_key -f ${BASTION_USERNAME}@${BASTION_HOST} -p ${BASTION_PORT} -L ${DATABASE_PORT}:${DB_HOST}:${DATABASE_PORT} -N
    echo "Connected"
    bash
else
    echo "WARNING: BASTION_SSH_KEY, DB_HOST, BASTION_USERNAME, BASTION_HOST, BASTION_PORT was not set. Note: BASTION HOST WILL NOT BE USED"
    bash
fi
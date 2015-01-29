#!/usr/bin/env bash

# Install Git
which git
STATUS_CODE=$?
if [ $STATUS_CODE -ne 0 ] ; then
    echo "Install git"
    apt-get -y install git
fi

PUPPET_REPO_DIR=/vagrant
PROVIS_DIR=${PUPPET_REPO_DIR}/provisioning

${PROVIS_DIR}/common.sh ${PUPPET_REPO_DIR} ${PROVIS_DIR}/vagrant/hiera.yaml local "Run vagrant ssh then:"


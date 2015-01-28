#!/usr/bin/env bash

# Install Git
which git
STATUS_CODE=$?
if [ $STATUS_CODE -ne 0 ] ; then
    echo "Install git"
    apt-get -y install git
fi

PROVIS_DIR=/vagrant/provisioning

${PROVIS_DIR}/common.sh /vagrant ${PROVIS_DIR}/vagrant/hiera.yaml local "Run vagrant ssh then:"


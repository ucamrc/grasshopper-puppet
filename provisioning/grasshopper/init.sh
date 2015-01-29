#!/usr/bin/env bash

# Include the Puppet APT repository
echo "Fetching Puppet"
cd /tmp
wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
dpkg -i puppetlabs-release-trusty.deb
apt-get update

# Install Puppet
echo "Installing Puppet"
apt-get install -y puppet

# Install Puppet APT
if [ ! -d /home/ubuntu/.puppet ] || [ ! -d /home/ubuntu/.puppet/modules ] || [ ! -d /home/ubuntu/.puppet/modules/apt ]; then
    puppet module install puppetlabs/apt
fi

PUPPET_REPO_DIR=/opt/grasshopper-puppet
PROVIS_DIR=${PUPPET_REPO_DIR}/provisioning
PUPPET_ENV=dev

${PROVIS_DIR}/common.sh ${PUPPET_REPO_DIR} ${PROVIS_DIR}/grasshopper/hiera.yaml ${PUPPET_ENV} "Run this command:"

echo "All the dependencies have been restarted, sleeping for a bit to give them time to start up properly"
sleep 5

# Start the app server
### PUPPET SHOULD DO THIS ALREADY?
#service grasshopper restart

echo "Sleeping 15 seconds to give the app server a little bit of time to start up"
sleep 15

curl http://localhost:2001/api/me

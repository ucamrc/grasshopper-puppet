#!/usr/bin/env bash

PUPPET_ENV=$1

if [[ X"" = X"$PUPPET_ENV" ]]; then
  echo "Usage: $0 environmentname"
  echo "  See environments directory for a list of valid environment names."
  exit 0;
fi

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

${PROVIS_DIR}/common.sh ${PUPPET_REPO_DIR} ${PROVIS_DIR}/grasshopper/hiera.yaml ${PUPPET_ENV} "Run this command:"


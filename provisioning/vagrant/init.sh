#!/usr/bin/env bash

cd /vagrant

# Install cURL
which curl
STATUS_CODE=$?
if [ $STATUS_CODE -ne 0 ] ; then
    echo "Installing curl"
    apt-get -y install curl
fi

# Install Git
which git
STATUS_CODE=$?
if [ $STATUS_CODE -ne 0 ] ; then
    echo "Install git"
    apt-get -y install git
fi

# Enable  multiverse repositories
echo "Enable multiverse repositories"
sed -i "/^# deb.*multiverse/ s/^# //" /etc/apt/sources.list
apt-get update

# Make sure all the submodules have been pulled down
cd /vagrant
sh bin/pull.sh

# Create the hiera config
cat > /etc/puppet/hiera.yaml <<EOF
:backends:
  - json
:json:
  :datadir: /vagrant/environments/%{::environment}/hiera
:hierarchy:
  - common
EOF

# Run puppet
echo "Applying puppet catalog. This might take a while (~30+ mins is not unreasonable)"
puppet apply --modulepath environments/local/modules:modules:/etc/puppet/modules --certname dev0 --environment local --hiera_config /etc/puppet/hiera.yaml site.pp

STATUS_CODE=$?
if [ $STATUS_CODE -ne 0 ] ; then
    echo "Got a ${STATUS_CODE} status code, which indicates the puppet catalog could not be properly applied."
    echo "There are a couple of possible things you can do:"
    echo " - Run vagrant ssh and try running cd /vagrant && sudo puppet apply --modulepath environments/local/modules:modules:/etc/puppet/modules --certname dev0 --environment local --hiera_config /etc/puppet/hiera.yaml site.pp"
    echo " - If you're familiar with puppet try to analyze the output and tweak the puppet scripts"
    echo "Since puppet didn't finish properly, we have to abort here"
    exit 1;
fi

exit 0;

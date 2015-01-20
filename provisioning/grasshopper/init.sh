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

# Install cURL
which curl
STATUS_CODE=$?
if [ $STATUS_CODE -ne 0 ] ; then
    echo "Installing cURL"
    apt-get install -y curl
fi

# Enable multiverse repositories
echo "Enable multiverse repositories"
sed -i "/^# deb.*multiverse/ s/^# //" /etc/apt/sources.list
apt-get update

# Make sure all the submodules have been pulled down
cd /opt/grasshopper-puppet
sh bin/pull.sh

# Create the hiera config
cat > /etc/puppet/hiera.yaml <<EOF
:backends:
  - json
:json:
  :datadir: /opt/grasshopper-puppet/environments/%{::environment}/hiera
:hierarchy:
  - %{::clientcert}_hiera_secure
  - %{::clientcert}
  - %{nodetype}_hiera_secure
  - %{nodetype}
  - common_hiera_secure
  - common
EOF

# Run puppet
echo "Applying Puppet catalog. This might take a while (~30+ mins is not unreasonable)"
sudo puppet apply --verbose --debug --modulepath environments/grasshopper-puppet/modules:modules:/etc/puppet/modules --certname dev0 --environment qa --hiera_config /etc/puppet/hiera.yaml site.pp

STATUS_CODE=$?
if [ $STATUS_CODE -ne 0 ] ; then
    echo "Got a ${STATUS_CODE} status code, which indicates the puppet catalog could not be properly applied."
    echo "There are a couple of possible things you can do:"
    echo " - Run sudo puppet apply --verbose --debug --modulepath environments/avocet-qa/modules:modules:/etc/puppet/modules --certname dev0 --environment avocet-dev --hiera_config /etc/puppet/hiera.yaml site.pp"
    echo " - If you're familiar with puppet try to analyze the output and tweak the puppet scripts"
    echo " - Hop onto #sakai on irc.freenode.org and ask if anyone has seen your error"
    echo " - Shoot an e-mail to oae-dev@sakaiproject.org with the above output"
    echo "Since puppet didn't finish properly, we have to abort here"
    exit 1;
fi

echo "All the dependencies have been restarted, sleeping for a bit to give them time to start up properly"
sleep 5

# Start the app server
service grasshopper restart

echo "Sleeping 15 seconds to give the app server a little bit of time to start up"
sleep 15

curl http://localhost:2001/api/me

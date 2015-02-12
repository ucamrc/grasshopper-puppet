#!/usr/bin/env bash

PUPPET_REPO_DIR=$1
PUPPET_HIERA=$2
PUPPET_ENV=$3
MANUALRUN_PREFIX=$4

# For now default to env=dev means node=dev0 etc
PUPPET_NODENAME="${PUPPET_ENV}0"

cd ${PUPPET_REPO_DIR}

# Install cURL
which curl
STATUS_CODE=$?
if [ $STATUS_CODE -ne 0 ] ; then
    echo "Installing curl"
    apt-get -y install curl
fi

# Enable multiverse repositories
echo "Enable multiverse repositories"
sed -i "/^# deb.*multiverse/ s/^# //" /etc/apt/sources.list
# No need to "apt-get update" as puppetlabs-apt will do it for us

# Make sure all the submodules have been pulled down
cd ${PUPPET_REPO_DIR}
sh bin/pull.sh

# Create the hiera config
cp ${PUPPET_HIERA} /etc/puppet/hiera.yaml

# Run puppet
PUPPET_EXTRA_OPTS="--verbose"
PUPPET_CMD="puppet apply ${PUPPET_EXTRA_OPTS} --modulepath environments/${PUPPET_ENV}/modules:modules:/etc/puppet/modules --certname ${PUPPET_NODENAME} --environment ${PUPPET_ENV} --hiera_config /etc/puppet/hiera.yaml site.pp"

echo "Applying puppet catalog. This might take a while (~30+ mins is not unreasonable)"
${PUPPET_CMD}

STATUS_CODE=$?
if [ $STATUS_CODE -ne 0 ] ; then
    echo "Got a ${STATUS_CODE} status code, which indicates the puppet catalog could not be properly applied."
    echo "There are a couple of possible things you can do:"
    echo " - "${MANUALRUN_PREFIX}
    echo "   cd ${PUPPET_REPO_DIR} && sudo ${PUPPET_CMD}"
    echo " - If you're familiar with puppet try to analyze the output and tweak the puppet scripts"
    echo "Since puppet didn't finish properly, we have to abort here"
    exit 1;
fi

echo "Success. To re-apply puppet catalog manually:"
echo " - "${MANUALRUN_PREFIX}
echo "   cd ${PUPPET_REPO_DIR} && sudo ${PUPPET_CMD}"

exit 0;

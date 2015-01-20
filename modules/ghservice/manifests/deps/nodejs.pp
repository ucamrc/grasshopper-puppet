class ghservice::deps::nodejs () {

    # Get the version from hiera
    $nodejs_version = hiera('nodejs_version', '0.10.35-1nodesource1~trusty1')

    # Apply the nodejs class which will configure the apt repo and install nodejs
    class { '::nodejs':
        version => $nodejs_version,
        manage_repo => true
    }
}

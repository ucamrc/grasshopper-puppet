class ghservice::deps::nodejs () {

    # Get the version from hiera
    $nodejs_version = hiera('nodejs_version', '0.10.36-1nodesource1~trusty1')

    # Apply the nodejs class which will configure the apt repo and install nodejs
    class { '::nodejs':
        # "before" line IS VITAL to ensure that things that depend on the parent class will actually wait for ::nodejs to finish first
        # otherwise e.g. npm install would try to run before npm was installed
        # not sure if there is a better way to do this
        before => Class['::ghservice::deps::nodejs'],
        version => $nodejs_version,
        manage_repo => true
    }
}

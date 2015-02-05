class localconfig::hostnames {

    $admin_hostname = hiera('admin_hostname')
    $tenant_hostname = hiera('tenant_hostname')

    # These are defined to allow puppet and setup scripts to access
    # the node server ports on 2000 and 2001 locally, whilst still
    # using external hostnames, and not opening those ports to the world
    # Additionally, on EC2 admin_hostname won't be in DNS either
    host { $admin_hostname: ip => '127.0.0.1' }
    host { $tenant_hostname: ip => '127.0.0.1' }
}

class localconfig::hostnames {

    $admin_hostname = hiera('admin_hostname')
    $tenant_hostname = hiera('tenant_hostname')

    # These are defined to allow puppet and setup scripts to
    # access localhost using the right servername
    host { $admin_hostname: ip => '127.0.0.1' }
    host { $tenant_hostname: ip => '127.0.0.1' }
}

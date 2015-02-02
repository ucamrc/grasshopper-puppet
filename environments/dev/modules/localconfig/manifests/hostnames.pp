class localconfig::hostnames {

    # FIXME this duplicates code in modules/ghservice/manifests/grasshopper.pp
    $web_domain = hiera('web_domain')
    $app_admin_tenant = hiera('app_admin_tenant', 'admin')
    $admin_domain = "${app_admin_tenant}.${web_domain}"

    # These are defined to allow puppet and setup scripts to access
    # the node server ports on 2000 and 2001 locally, whilst still
    # using external hostnames, and not opening those ports to the world
    # Additionally, admin_domain won't be in DNS either
    host { $admin_domain: ip => '127.0.0.1' }
    host { $web_domain: ip => '127.0.0.1' }
}
